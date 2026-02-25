import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pitbus_app/services/context_app.dart';
import '../models/history_model.dart';
import '../services/RequestServ.dart';
import '../services/ResponseServ.dart';
import '../models/unit_model.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';

class UnitsViewModel extends ChangeNotifier {
  List<UnitModel> _units = [];
  bool _isLoading = false;
  bool _isLoadingCitations = false;
  String? _errorMessage;
  List<ReportModel> _unitHistory = [];
  List<Map<String, dynamic>> _pendingCitations = [];
  bool _showOnlyCitations = false;
  final requestSer = RequestServ.instance;

  List<UnitModel> get units {
    if (_showOnlyCitations) {
      return _units.where((u) => u.idPreOdt != null && u.idPreOdt! > 0).toList();
    }
    return _units;
  }
  
  bool get showOnlyCitations => _showOnlyCitations;
  List<ReportModel> get unitHistory => _unitHistory;
  List<Map<String, dynamic>> get pendingCitations => _pendingCitations;
  bool get isLoading => _isLoading;
  bool get isLoadingCitations => _isLoadingCitations;
  String? get errorMessage => _errorMessage;
  
  int page = 1;
  int totalPages = 0;

  void reset() {
    _units = [];
    _unitHistory = [];
    _pendingCitations = [];
    _isLoading = false;
    _isLoadingCitations = false;
    _errorMessage = null;
    _showOnlyCitations = false;
    page = 1;
    totalPages = 0;
    notifyListeners();
  }

  void toggleShowOnlyCitations() {
    _showOnlyCitations = !_showOnlyCitations;
    notifyListeners();
  }

  /// Fetches all pending citations across all units for a supervisor/admin.
  Future<void> fetchAllPendingCitations(UserModel user) async {
    _isLoadingCitations = true;
    _pendingCitations = [];
    notifyListeners();

    try {
      // First get all units in sucursal
      final response = await RequestServ.get('/api/appPitwall/admin/', {
        "accion": "getUnidades",
        "sucursal": user.sucursal,
        "page": 1
      });
      final data = ResponseServ.handleResponse(response);
      List<dynamic> unitsJson = [];
      if (data is List) unitsJson = data;
      else if (data is Map) unitsJson = data['units'] ?? data['data'] ?? [];

      final allUnits = unitsJson.map((j) => UnitModel.fromJson(j)).toList();

      // Fetch reports for each unit in parallel
      await Future.wait(allUnits.map((unit) async {
        try {
          final hResponse = await RequestServ.get('/api/appPitwall/admin/', {
            "accion": "getReportesUnidad",
            "unidad": unit.id
          });
          final hData = ResponseServ.handleResponse(hResponse);
          List<dynamic> reportes = [];
          if (hData is List) reportes = hData;
          else if (hData is Map) reportes = hData['reportes'] ?? hData['data'] ?? hData['history'] ?? [];

          for (var r in reportes) {
            final status = (r['status_name'] ?? r['status'] ?? '').toString().toLowerCase();
            if (status.contains('pendiente')) {
              if( user.rol.toUpperCase() == "SUPERVISOR" && r['status'].toString().toLowerCase() == "PENDEINTE" ){
                _pendingCitations.add({
                  ...Map<String, dynamic>.from(r),
                  '__unit_name': unit.name,
                  '__unit_id': unit.id,
                });
              }
              else if( user.rol.toUpperCase() == "TALLER" || r['status'].toString().toLowerCase() == "EN ESPERA" ){
                _pendingCitations.add({
                  ...Map<String, dynamic>.from(r),
                  '__unit_name': unit.name,
                  '__unit_id': unit.id,
                });
              }
            }

          }
        } catch (_) {}
      }));

      // Sort by date descending
      _pendingCitations.sort((a, b) {
        final da = a['date_create'] ?? a['fecha'] ?? '';
        final db = b['date_create'] ?? b['fecha'] ?? '';
        return db.toString().compareTo(da.toString());
      });

    } catch (e) {
      if (RequestServ.modeDebug) print("[ UnitsViewModel ] Error fetching all citations: $e");
    } finally {
      _isLoadingCitations = false;
      notifyListeners();
    }
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
        case 'OPERADOR':
          // Operators fetch their specific unit directly via the admin endpoint
          endpoint = '/api/appPitwall/operador/';
          params = {
            "accion": "getUnidades",
            "sucursal": user.sucursal,
            "unidad": ContextApp().unitAssOperator,
            "operadorName": ContextApp().fullNameOperator,
            "operadorLastName1": ContextApp().firstLastNameOperator,
            "operadorLastName2": ContextApp().secondLastNameOperator,
          };
          break;
        case 'SUPERVISOR':
          // Supervisors get a paginated list of all units in the sucursal
          endpoint = '/api/appPitwall/supervisor/';
          params = {
            "accion": "getUnidades",
            "sucursal": user.sucursal,
            "page": page
          };
          if (RequestServ.modeDebug) {
            print("[ UnitsViewModel ] SUPERVISOR fetching via ADMIN endpoint for sucursal: ${user.sucursal}");
          }
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
      
      if (RequestServ.modeDebug) {
        print("[ UnitsViewModel ] FETCHED ${_units.length} units");
        for (var i = 0; i < _units.length; i++) {
          final u = _units[i];
          final raw = unitsJson[i];
          print("[ UnitsViewModel ] UNIT: ${u.name} (idPreOdt: ${u.idPreOdt})");
          if (u.name == 'B10' || u.name == 'B-10' || u.id == '8') {
             print("[ UnitsViewModel:B10 ] RAW JSON: ${jsonEncode(raw)}");
          }
        }
      }

      // Strict filter for Operators: only their assigned unit
      if (user.rol.toUpperCase() == 'OPERADOR' && user.assignedUnit != null && user.assignedUnit!.isNotEmpty) {
        // Use a more relaxed matching that ignores spaces, hyphens and case
        final String targetUnit = user.assignedUnit!.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
        
        if (RequestServ.modeDebug) {
          print("[ UnitsViewModel ] OPERATOR: ${user.fullName}");
          print("[ UnitsViewModel ] ASSIGNED UNIT: '${user.assignedUnit}'");
          print("[ UnitsViewModel ] TARGET FOR MATCH: '$targetUnit'");
          print("[ UnitsViewModel ] RAW UNITS FROM API: ${_units.map((u) => u.name).toList()}");
        }
        
        _units = _units.where((u) {
          final String cleanName = u.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
          final match = cleanName == targetUnit;
          if (RequestServ.modeDebug) {
            print("[ UnitsViewModel ] CHECKING UNIT '${u.name}' (Clean: '$cleanName'): MATCH = $match");
          }
          return match;
        }).toList();
        
        if (RequestServ.modeDebug) print("[ UnitsViewModel ] FILTERED LIST SIZE: ${_units.length}");
      }

      // Deeper diagnostic: If management role and citations are null, try checking history for the first units
      final role = user.rol.toUpperCase();
      if ((role == 'SUPERVISOR' || role == 'ADMIN' || role == 'ADMINISTRADOR') && _units.isNotEmpty) {
        if (RequestServ.modeDebug) print("[ UnitsViewModel ] Management role detected. Fetching pending citations for units...");
        
        // Fetch citations for units in parallel (limit to avoid overwhelm)
        final unitsToSearch = _units.take(15).toList();
        await Future.wait(unitsToSearch.map((unit) async {
          try {
            final hResponse = await RequestServ.get('/api/appPitwall/admin/', {
              "accion": "getReportesUnidad",
              "unidad": unit.id
            });
            final hData = ResponseServ.handleResponse(hResponse);
            List<dynamic> history = [];
            if (hData is List) history = hData;
            else if (hData is Map) history = hData['data'] ?? hData['history'] ?? [];

            // Find first pending citation
            for (var h in history) {
              final hStatus = (h['status_name'] ?? h['status'] ?? '').toString().toLowerCase();
              if (hStatus.contains('pendiente')) {
                final id = int.tryParse((h['Id_pre_odt'] ?? h['id_pre_odt'] ?? '0').toString());
                if (id != null && id > 0) {
                  // Update unit with found ID
                  final unitIdx = _units.indexWhere((u) => u.id == unit.id);
                  if (unitIdx != -1) {
                    _units[unitIdx] = _units[unitIdx].copyWith(idPreOdt: id);
                    if (RequestServ.modeDebug) print("[ UnitsViewModel ] Found pending citation $id for unit ${unit.name}");
                  }
                  break; 
                }
              }
            }
          } catch (e) {
            if (RequestServ.modeDebug) print("[ UnitsViewModel ] Error fetching citation for ${unit.name}: $e");
          }
        }));
      }
      
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnitHistory(UserModel user, String unitId) async {
    _isLoading = true;
    _unitHistory = [];
    _errorMessage = null;
    notifyListeners();

    try {
      // String endpoint = '';
      // Map<String, dynamic> params = {};
      //
      // final role = user.rol.toUpperCase();
      // if (role == 'ADMIN' || role == 'ADMINISTRADOR' || role == 'SUPERVISOR') {
      //   endpoint = '/api/appPitwall/admin/';
      //   params = {"accion": "getReportesUnidad", "unidad": unitId};
      // } else if (role == 'TALLER') {
      //   endpoint = '/api/appPitwall/taller/';
      //   params = {"accion": "getReportesUnidad", "unidad": unitId};
      // } else {
      //   endpoint = '/api/appPitwall/operador/';
      //   params = {
      //     "accion": "getReportesUnidad",
      //     "operadorName": user.fullName,
      //     "unidad": unitId
      //   };
      // }
      //
      // final response = await RequestServ.get(endpoint, params);
      // final data = ResponseServ.handleResponse(response);
      //
      // if (data is List) {
      //   _unitHistory = data;
      // } else if (data is Map) {
      //   _unitHistory = data['history'] ?? data['data'] ?? [];
      // }

      ReportResponse? reponse = await requestSer.handlingRequestParsed(
        urlParam: "/api/appPitwall/citas/",
        method: "GET",
        params: {
          "action":"getReportesUnidad",
          "id_unit": unitId
        },
        asJson: false,
        fromJson: (json) {
          print(json);
          return ReportResponse.fromJson(json);
        }
      );

      if (reponse?.status != 200){
        if( ContextApp().isDebugMode ){
          print("[ unitCiteHistory ] => ${reponse?.status}");
        }
        return;
      }

      _unitHistory = reponse!.reportes;


    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCita(UserModel user, String unitId, String reporteFalla, List<String> failureTypes, String fechaPedida) async {
    _isLoading = true;
    notifyListeners();
    try {
      final String combinedReport = failureTypes.isNotEmpty 
          ? failureTypes.join(', ')
          : reporteFalla;

      final body = {
        "action": "create",
        "unidad": unitId, 
        "usuarioId": user.id,
        "usuarioName": user.fullName,
        "reporteFalla": combinedReport,
        "fechaPedida": fechaPedida,
        "sucursal": user.sucursal,
        "actividades": failureTypes.map((t) => {"descripcion": t}).toList(),
      };

      final response = await RequestServ.post('/api/appPitwall/citas/', body, asJson: true);
      ResponseServ.handleResponse(response);
      print("create => ${response.body}");
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCitaStatus(UserModel user, int idPreOdt, int status, {String? motivo}) async {
    try {
      final body = {
        "action": "validate",
        "Id_pre_odt": idPreOdt,
        "status": status,
        "usuario": user.id,
        if (motivo != null) "motivo": motivo,
      };

      final response = await RequestServ.post('/api/appPitwall/citas/', body, asJson: true);
      ResponseServ.handleResponse(response);
      return true;
    } catch (e) {
      return false;
    }
  }
}
