import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/unit_model.dart';
import '../models/user_model.dart';
import '../models/history_model.dart';
import '../services/RequestServ.dart';
import '../services/ResponseServ.dart';

class UnitsViewModel extends ChangeNotifier {
  List<UnitModel> _units = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UnitModel> get units => _units;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  int page = 1;
  int totalPages = 0;

  void reset() {
    _units = [];
    _isLoading = false;
    _errorMessage = null;
    page = 1;
    totalPages = 0;
    notifyListeners();
  }

  Future<void> nextPage(UserModel user) async {
    if (page < totalPages) {
      page++;
      await fetchUnitsByRole(user);
    }
  }

  Future<void> previousPage(UserModel user) async {
    if (page > 1) {
      page--;
      await fetchUnitsByRole(user);
    }
  }

  Future<void> goToFirstPage(UserModel user) async {
    if (page != 1) {
      page = 1;
      await fetchUnitsByRole(user);
    }
  }

  Future<void> goToLastPage(UserModel user) async {
    if (page != totalPages && totalPages > 0) {
      page = totalPages;
      await fetchUnitsByRole(user);
    }
  }

  Future<void> fetchUnitsByRole(UserModel user) async {
    _isLoading = true;
    _units = []; 
    _errorMessage = null;
    notifyListeners();

    try {
      String endpoint = '';
      Map<String, dynamic> params = {};

      switch (user.rol.toUpperCase()) {
        case 'ADMIN':
        case 'ADMINISTRADOR':
          endpoint = '/api/appPitwall/admin/';
          params = {
            "accion": "getUnidades",
            "page": page
          };
          break;
        case 'SUPERVISOR':
          endpoint = '/api/appPitwall/supervisor/';
          params = {
            "idSupervisor": user.id,
            "page": page
          };
          break;
        case 'OPERADOR':
          final adminResponse = await RequestServ.get('/api/appPitwall/operador/', {
            "operadorName": user.nombre,
            "operadorLastName1": user.apPaterno,
            "operadorLastName2": user.apMaterno,
            "unidad": "B1019",
            "page": page
          });
          final adminData = ResponseServ.handleResponse(adminResponse);
          
          List<dynamic> allUnitsJson = [];
          if (adminData is List) {
            allUnitsJson = adminData;
          } else if (adminData is Map) {
            allUnitsJson = adminData['units'] ?? adminData['data'] ?? [];
          }

          final allUnits = allUnitsJson.map((json) => UnitModel.fromJson(json)).toList();
          
          final myUnit = allUnits.firstWhere(
            (u) => u.operadorId == user.id.toString(),
            orElse: () => throw Exception('No se encontró una unidad asignada para este operador.'),
          );

          endpoint = '/api/appPitwall/operador/';
          params = {
            "operadorName": user.nombre,
            "operadorLastName1": user.apPaterno,
            "operadorLastName2": user.apMaterno,
            "unidad": myUnit.name
          };
          break;
        case 'TALLER':
          endpoint = '/api/appPitwall/taller/';
          params = {
            "accion": "getUnidades",
            "sucursal": user.sucursal,
            "page": page
          };
          break;
        default:
          throw Exception('Rol no reconocido: ${user.rol}');
      }

      if (RequestServ.modeDebug) {
        print("Fetching units for role ${user.rol} at $endpoint with params $params");
      }

      final response = await RequestServ.get(endpoint, params);
      final data = ResponseServ.handleResponse(response);
      
      List<dynamic> unitsJson = [];
      if (data is List) {
        unitsJson = data;
      } else if (data is Map) {
        unitsJson = data['units'] ?? data['data'] ?? [];
        if (data.containsKey('pagination')) {
          totalPages = data['pagination']["totalPages"] ?? 0;
        }
      }
      
      _units = unitsJson.map((json) => UnitModel.fromJson(json)).toList();
      
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCita(UserModel user, String unidadNombre, String reporteFalla, String fechaPedida) async {
    _isLoading = true;
    notifyListeners();
    try {
      final body = {
        "usuarioName": user.fullName,
        "usuarioId": user.id,
        "action": "create",
        "unidad": unidadNombre,
        "reporteFalla": reporteFalla,
        "fechaPedida": fechaPedida,
        "sucursal": user.sucursal
      };

      final response = await RequestServ.post('/api/appPitwall/citas/', body);
      ResponseServ.handleResponse(response);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCitaStatus(UserModel user, int idPreOdt, int status) async {
    _isLoading = true;
    notifyListeners();
    try {
      final body = {
        "Id_pre_odt": idPreOdt,
        "status": status,
        "usuario": user.id
      };

      final response = await RequestServ.post('/api/appPitwall/citas/', body);
      ResponseServ.handleResponse(response);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // region HISTORY
  final String urlhistory= "https://nuevosistema.busmen.net/WS/aplicacionmovil/app_history_pre_odt.php";
  bool isLoadingHistory = false;
  List<HistoryModel> unitHistory = [];

  Future<void> fetchHistory(String idUnit) async {
    isLoadingHistory = true;
    unitHistory = [];
    notifyListeners();

    RequestServ requestServ = RequestServ();

    try {
      final responseString = await requestServ.handlingRequest(
        urlParam: urlhistory,
        params: {
          "id": idUnit,
        },
      );

      if (responseString == null) return;

      final Map<String, dynamic> responseJson = jsonDecode(responseString);
      
      if (responseJson.containsKey('data') && responseJson['data'] is List) {
        final List<dynamic> dataList = responseJson['data'];
        unitHistory = dataList.map((json) => HistoryModel.fromJson(json)).toList();
      }

      if (RequestServ.modeDebug) {
        print("History loaded: ${unitHistory.length} items");
      }

    } catch (e) {
      if (RequestServ.modeDebug) print("Error fetching history: $e");
    } finally {
      isLoadingHistory = false;
      notifyListeners();
    }
  }
  // endregion HISTORY

}
