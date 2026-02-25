import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pitbus_app/services/context_app.dart';
import '../models/odt_model.dart';
import '../services/RequestServ.dart';

class OdtViewModel extends ChangeNotifier {
  // State 1: Folios List (for search/selection)
  List<String> _allFolios = []; 
  List<String> _filteredFolios = []; // For search suggestions if needed, but we stick to direct Selection
  
  // State 2: Selected ODT Details
  String? _selectedFolio;
  List<OdtService> _services = [];
  List<OdtService> _filteredServices = []; // Filtered by Family/Search locally within ODT
  OdtSummary _summary = OdtSummary.empty();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filter State within the ODT
  String _serviceSearchQuery = "";
  String _selectedFamily = "TODOS"; 

  List<String> get allFolios => _allFolios;
  List<OdtService> get services => _filteredServices;
  OdtSummary get summary => _summary;
  String? get selectedFolio => _selectedFolio;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFamily => _selectedFamily;

  // Use this for the search bar text
  String _currentSearchTerm = "";
  String get currentSearchTerm => _currentSearchTerm;

  OdtViewModel() {
    _init();
  }
  
  Future<void> _init() async {
    await fetchFolios();
    // Auto-selection removed to start with an empty search bar
  }

  Future<void> fetchFolios() async {
    _isLoading = true; 
    notifyListeners();
    
    try {

      if( ContextApp().isDebugMode ){
        print(" [ POST ] FETCH ODT url => https://nuevosistema.busmen.net/WS/aplicacionmovil/app_odt_job.php/");
        print(" [ POST ] FETCH ODT params => null");
      }

       final url = Uri.parse('https://nuevosistema.busmen.net/WS/aplicacionmovil/app_odt_job.php/');
       final response = await http.post(url); 

       if (response.statusCode == 200) {
         final dynamic decoded = json.decode(response.body);
         List<dynamic> list = [];
         
         if (decoded is Map && decoded.containsKey('data')) {
           list = decoded['data'];
         } else if (decoded is List) {
           list = decoded;
         }
         
         // Parse just the folio strings
         _allFolios = list.map((e) => e['folio'].toString()).where((s) => s != 'null' && s.isNotEmpty).toList();
         _filteredFolios = List.from(_allFolios);
       }
    } catch (e) {
      if (RequestServ.modeDebug) print("Error fetching folios: $e");
      _errorMessage = "Error de conexión";
    } finally {
      _isLoading = false; 
      notifyListeners();
    }
  }

  Future<void> selectFolio(String folio) async {
    _selectedFolio = folio;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {

      if( ContextApp().isDebugMode ){
        print(" [ POST ] FETCH ODT url => https://nuevosistema.busmen.net/WS/aplicacionmovil/app_odt_job.php/");
        print(" [ POST ] FETCH ODT params => ${
            {"folio_odt": folio}
        }");
      }

      final response = await http.post(
        Uri.parse('https://nuevosistema.busmen.net/WS/aplicacionmovil/app_odt_job.php/'),
        body: {"folio_odt": folio}
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (RequestServ.modeDebug) print("[ FETCH ODT ] response => $data");
        // Parse services
        List<OdtService> newServices = [];
        if (data['data'] != null && data['data']['data'] != null) {
          final List<dynamic> items = data['data']['data'];
          newServices = items.map((i) => OdtService.fromJson(i)).toList();
        }
        _services = newServices;
        
        // Parse Summary
        if (data['data'] != null && data['data']['resumen'] != null) {
          _summary = OdtSummary.fromJson(data['data']['resumen']);
        } else {
          // Calculate manually if missing (fallback)
          _summary = OdtSummary(
            total: _services.length,
            unfinished: _services.where((s) => !s.isFinished).length,
            finished: _services.where((s) => s.isFinished).length,
            byFamily: {} 
          );
        }
        
        _applyFilters();
        
      } else {
        _errorMessage = "Error al cargar detalle ODT";
      }
    } catch (e) {
       if (RequestServ.modeDebug) print("Error loading ODT $folio: $e");
       _errorMessage = "Error al cargar detalle";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _currentSearchTerm = query;
    _applyFilters();
  }
  
  void onFolioSelected(String folio) {
    selectFolio(folio);
  }

  void filterByFamily(String family) {
    _selectedFamily = family; 
    _applyFilters();
  }

  void _applyFilters() {
    _filteredServices = _services.where((s) {
      final matchesQuery = s.folio.contains(_currentSearchTerm) ||
                           s.activity.toLowerCase().contains(_currentSearchTerm.toLowerCase());
      
      final matchesFamily = _selectedFamily == "TODOS" || s.family == _selectedFamily;

      return matchesQuery && matchesFamily;
    }).toList();
    notifyListeners();
  }
}
