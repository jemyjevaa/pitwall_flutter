import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pitbus_app/services/request_service.dart';
import 'package:pitbus_app/services/user_session_service.dart';
import '../services/response_service.dart';
import '../models/unit_model.dart';
import '../models/user_model.dart';

class UnitsViewModel extends ChangeNotifier {
  List<UnitModel> _units = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UnitModel> get units => _units;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void reset() {
    _units = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchUnitsByRole(UserModel user) async {
    _isLoading = true;
    _units = []; // Clear previous units
    _errorMessage = null;
    notifyListeners();

    try {
      String endpoint = '';
      Map<String, dynamic> params = {};

      switch (user.rol) {
        case 'ADMIN':
        case 'ADMINISTRADOR':
          endpoint = '/api/appPitwall/admin/';
          params = {"accion": "getUnidades"};
          break;
        case 'SUPERVISOR':
          endpoint = '/api/appPitwall/supervisor/';
          params = {"idSupervisor": user.id};
          break;
        case 'OPERADOR':
          // Using manual data filled by the user in OperatorDataView
          endpoint = '/api/appPitwall/operador/';
          params = {
            "operadorName": user.nombre.toLowerCase(),
            "operadorLastName1": user.apPaterno.toLowerCase(),
            "operadorLastName2": user.apMaterno.toLowerCase(),
            "unidad": user.assignedUnit ?? "B1019" // Fallback to provided B1019 if somehow missing
          };
          break;
        case 'TALLER':
          endpoint = '/api/appPitwall/taller/';
          params = {
            "accion": "getUnidades",
            "sucursal": user.sucursal
          };
          break;
        default:
          throw Exception('Rol no reconocido: ${user.rol}');
      }

      if (kDebugMode) {
        print("Fetching units for role ${user.rol} at $endpoint with params $params");
      }

      final response = await RequestServ.get(endpoint, params);
      
      if (kDebugMode) {
        print("Response status: ${response.statusCode}");
      }
      
      final data = ResponseServ.handleResponse(response);
      
      List<dynamic> unitsJson = [];
      if (data is List) {
        unitsJson = data;
      } else if (data is Map) {
        unitsJson = data['units'] ?? data['data'] ?? [];
      }
      
      if (kDebugMode) {
        print("Parsed ${unitsJson.length} units for role ${user.rol}");
      }
      
      _units = unitsJson.map((json) => UnitModel.fromJson(json)).toList();
      
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
      // Combine failure types with description
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

  // Placeholder for history fetch - will need endpoint confirmation
  Future<List<dynamic>> fetchUnitHistory(String unitName) async {
    try {
      // Assuming a similar pattern for history
      final response = await RequestServ.get('/api/appPitwall/citas/', {
        "action": "history",
        "unidad": unitName
      });
      final data = ResponseServ.handleResponse(response);
      return data is List ? data : [];
    } catch (e) {
      if (kDebugMode) print("Error fetching history: $e");
      return [];
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
}
