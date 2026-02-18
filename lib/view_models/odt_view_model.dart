import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/odt_model.dart';

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
    // Auto-select first if available
    if (_allFolios.isNotEmpty) {
      selectFolio(_allFolios.first);
    }
  }

  Future<void> fetchFolios() async {
    _isLoading = true; 
    notifyListeners();
    
    try {
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
      if (kDebugMode) print("Error fetching folios: $e");
      _errorMessage = "Error de conexión";
    } finally {
      // Don't stop loading yet if we are going to auto-select, but for safety:
      // If no folios, stop.
      if (_allFolios.isEmpty) {
        _isLoading = false; 
        notifyListeners();
      }
      // If we have folios, _init calls selectFolio which handles its own loading state/notify.
    }
  }

  Future<void> selectFolio(String folio) async {
    _selectedFolio = folio;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://nuevosistema.busmen.net/WS/aplicacionmovil/app_odt_job.php/'),
        body: {"folio_odt": folio}
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
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
            byFamily: {} // Simplification
          );
        }
        
        _applyFilters();
        
      } else {
        _errorMessage = "Error al cargar detalle ODT";
      }
    } catch (e) {
       if (kDebugMode) print("Error loading ODT $folio: $e");
       _errorMessage = "Error al cargar detalle";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Called when user types in search bar
  void search(String query) {
    _currentSearchTerm = query;
    // If the query matches a folio exactly, select it? 
    // Or just filter the CURRENT displayed services?
    // User request: "UNA VES SELECCIONADA UNA ODT EN EL BUSCADOR"
    // This expects the search bar to define the ODT.
    
    // Strategy:
    // If query matches a known Folio, we could show a suggestion or Auto-select?
    // Let's assume the user might want to filter the *services* of the current ODT too.
    // Dual purpose:
    // 1. If matches a Folio in _allFolios -> Allow switching?
    // 2. Filter local services.
    
    // Simplest approach for Request:
    // Search Bar filters the *services* (Activity/etc).
    // To switch ODT, maybe we need a separate "Change Folio" button or the search bar *is* a Folio Selector?
    // "UNA VES SELECCIONADA UNA ODT EN EL BUSCADOR" -> The Search Bar IS the Folio Selector.
    
    // Ok, so `search` should filter `_allFolios`?
    // But if they select one, we load it.
    // Let's implement `filterServices` for searching within the ODT (Activity).
    // And `findFolio` for switching.
    
    // Compromise:
    // `search(query)` filters the *services* (Activity).
    // To switch ODT, we'll rely on the user using a "picker" or typing a folio that matches exactly?
    // Let's assume `search` filters the visible content (services).
    // The "Selection" might have been implied as "Find the folio".
    _applyFilters();
  }
  
  // Call this to switch ODT
  void onFolioSelected(String folio) {
    selectFolio(folio);
  }

  void filterByFamily(String family) {
    _selectedFamily = family; // "TODOS", "GASOLINA", "SERVICIOS"
    _applyFilters();
  }

  void _applyFilters() {
    _filteredServices = _services.where((s) {
      final matchesQuery = s.folio.contains(_currentSearchTerm) || // In case they search folio
                           s.activity.toLowerCase().contains(_currentSearchTerm.toLowerCase());
      
      final matchesFamily = _selectedFamily == "TODOS" || s.family == _selectedFamily;

      return matchesQuery && matchesFamily;
    }).toList();
    notifyListeners();
  }
}
