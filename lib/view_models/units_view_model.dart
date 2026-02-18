import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pitbus_app/services/request_service.dart';
import 'package:pitbus_app/services/user_session_service.dart';
import '../models/unit_model.dart';
import '../models/operator_model.dart';

class UnitsViewModel extends ChangeNotifier {
  List<UnitModel> _units = [];
  List<OperatorModel> _operators = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UnitModel> get units => _units;
  List<OperatorModel> get operators => _operators;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UnitsViewModel() {
    fetchUnits(); // Load initial data
    fetchOperators(); // Load operators for appointments
  }

  Future<void> fetchOperators() async {

    RequestServ serv = RequestServ.instance;

    if( RequestServ.modeDebug ){
      print(" rolUser => ${UserSession().rolUser}");
    }

    String role = UserSession().rolUser.trim().toLowerCase();
    String result = switch (role) {
      "operator"   => RequestServ.urlOperator,
      "supervisor" => RequestServ.urlSupervisor,
      "taller"     => RequestServ.urlWorkStation,
      "admin"      => RequestServ.urlAdmin,
      _            => "null"
    };

    try {

      final unitRequest = await serv.handlingRequestParsed(
          urlParam: result,
          params: {
            "idSupervisor": 155,
            "accion": "getUnidades"
          },
          method: "GET",
          asJson: true,
          fromJson: (json) => json
      );

      if( RequestServ.modeDebug ){
        print(" unitRequest => $unitRequest");
      }

      final response = await http.post(
        Uri.parse('https://nuevosistema.busmen.net/WS/aplicacionmovil/app_get_operation.php'),
        body: json.encode({"id": 1}), // Using '1' as requested
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> ops = data['data'] ?? [];
        _operators = ops.map((j) => OperatorModel.fromJson(j)).toList();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching operators: $e");
    }
  }

  Future<bool> createAppointment({
    required String unitId,
    required String operatorId,
    required String date,
    required String activities,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // app_create_report_new.php
      // params["id"] = 155, unit=..., report="", id_operador=..., activitis=..., date=...
      final url = Uri.parse('https://nuevosistema.busmen.net/WS/aplicacionmovil/app_create_report_new.php');
      
      // Sending as standard POST fields (form-data or x-www-form-urlencoded), not JSON body for PHP usually?
      // The user just said "params[...]", often implies form fields.
      // I'll use a map body which http.post sends as form-urlencoded by default if no correct JSON header.
      // But previous endpoints strictly needed JSON content-type. 
      // I will try form fields first as "Multipart" was mentioned in my thought process, 
      // but standard post body map is safer for PHP $_POST unless it's a raw input stream.
      // Let's use simple map.
      
      final response = await http.post(
        url,
        body: {
          "id": "155",
          "unit": unitId,
          "report": "",
          "id_operador": operatorId,
          "activitis": activities,
          "date": date,
        },
      );

      _isLoading = false;
      notifyListeners();
      
      if (response.statusCode == 200) {
         if (kDebugMode) print("Appointment Created: ${response.body}");
         return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUnits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('https://nuevosistema.busmen.net/api/unidad/');
      
      // Using JSON encoding as parameters were provided in JSON format
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json", 
          "Accept": "application/json"
        },
        body: json.encode({
          "accion": "getMaintenanceAllUnits",
          "sucursal": 1, // sending as int as per example
          "order": "modelo",
          "activa": 1,   // sending as int as per example
        }),
      );

      // if (kDebugMode) {
      //   print("API Response Code: ${response.statusCode}");
      //   print("API Response Body: ${response.body}");
      // }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> unitsJson = data['units'] ?? [];
        
        _units = unitsJson.map((json) => UnitModel.fromJson(json)).toList();
      } else {
        _errorMessage = "Error: ${response.statusCode}";
      }
    } catch (e) {
      if (kDebugMode) {
        print("API Error: $e");
      }
      _errorMessage = "Error de conexión";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
