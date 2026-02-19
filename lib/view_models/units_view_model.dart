import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/RequestServ.dart';
import '../services/UserSession.dart';
import '../services/ResponseServ.dart';
import '../models/unit_model.dart';
import '../models/user_model.dart';

class UnitsViewModel extends ChangeNotifier {
  List<UnitModel> _units = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _unitHistory = [];

  List<UnitModel> get units => _units;
  List<dynamic> get unitHistory => _unitHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  int page = 1;
  int totalPages = 0;

  void reset() {
    _units = [];
    _unitHistory = [];
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
          endpoint = '/api/appPitwall/operador/';
          params = {
            "operadorName": user.nombre.toLowerCase().trim(),
            "operadorLastName1": user.apPaterno.toLowerCase().trim(),
            "operadorLastName2": user.apMaterno.toLowerCase().trim(),
            "unidad": user.assignedUnit ?? "B1019"
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

  Future<void> fetchUnitHistory(UserModel user, String unitName) async {
    _isLoading = true;
    _unitHistory = [];
    notifyListeners();

    try {
      String endpoint = '';
      Map<String, dynamic> params = {};

      switch (user.rol.toUpperCase()) {
        case 'ADMIN':
        case 'ADMINISTRADOR':
          endpoint = '/api/appPitwall/admin/';
          params = {"accion": "getReportesUnidad", "unidad": unitName};
          break;
        case 'SUPERVISOR':
          endpoint = '/api/appPitwall/supervisor/';
          params = {"accion": "getReportesUnidad", "unidad": unitName};
          break;
        case 'TALLER':
          endpoint = '/api/appPitwall/taller/';
          params = {"accion": "getReportesUnidad", "unidad": unitName};
          break;
        case 'OPERADOR':
          endpoint = '/api/appPitwall/operador/';
          params = {
            "accion": "getReportesUnidad",
            "operadorName": user.nombre.toLowerCase().trim(),
            "unidad": unitName
          };
          break;
      }

      final response = await RequestServ.get(endpoint, params);
      final data = ResponseServ.handleResponse(response);
      
      if (data is List) {
        _unitHistory = data;
      } else if (data is Map) {
        _unitHistory = data['history'] ?? data['data'] ?? [];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCita(UserModel user, String unidadNombre, String reporteFalla, List<String> failureTypes, String fechaPedida) async {
    _isLoading = true;
    notifyListeners();
    try {
      final String combinedReport = failureTypes.isNotEmpty 
          ? "Tipos de falla: ${failureTypes.join(', ')}. \nDescripción: $reporteFalla"
          : reporteFalla;

      final body = {
        "action": "create",
        "unidad": unidadNombre,
        "usuarioId": user.id,
        "usuarioName": user.fullName,
        "reporteFalla": combinedReport,
        "fechaPedida": fechaPedida,
        "sucursal": user.sucursal
      };

      final response = await RequestServ.post('/api/appPitwall/citas/', body, asJson: true);
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

      final response = await RequestServ.post('/api/appPitwall/citas/', body, asJson: true);
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
}
