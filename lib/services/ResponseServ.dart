import 'dart:convert';
import 'package:http/http.dart' as http;
import 'RequestServ.dart';

class ResponseServ {
  static dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {

      if(RequestServ.modeDebug){
        print("RESPONSE BODY: ${response.body}");
      }

      final decodedData = jsonDecode(response.body);
      
      // If success is explicitly false, throw error
      // if (decodedData['success'] == false) {
      //   throw Exception(decodedData['message'] ?? 'Error informado por el servidor');
      // }
      
      // Return data if present, otherwise return the whole body
      return decodedData['data'] ?? decodedData;
    } else {
      return [];
      throw Exception('Error de conexión: ${response.statusCode}');
    }
  }
}
