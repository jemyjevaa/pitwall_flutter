import 'package:flutter/foundation.dart';
import '../models/unit_model.dart';
import '../models/user_model.dart';
import '../services/RequestServ.dart';
import '../services/ResponseServ.dart';

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
          // 1. Get ALL units first from admin to find the assignment
          final adminResponse = await RequestServ.get('/api/appPitwall/admin/', {"accion": "getUnidades"});
          final adminData = ResponseServ.handleResponse(adminResponse);
          
          List<dynamic> allUnitsJson = [];
          if (adminData is List) {
            allUnitsJson = adminData;
          } else if (adminData is Map) {
            allUnitsJson = adminData['units'] ?? adminData['data'] ?? [];
          }

          final allUnits = allUnitsJson.map((json) => UnitModel.fromJson(json)).toList();
          
          // 2. Find the unit where operadorId matches user.id
          final myUnit = allUnits.firstWhere(
            (u) => u.operadorId == user.id.toString(),
            orElse: () => throw Exception('No se encontró una unidad asignada para este operador.'),
          );

          // 3. Now get the SPECIFIC details for that unit
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
}
