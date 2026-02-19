import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestServ {
  static const String baseUrl = 'https://nuevosistema.busmen.net';
  static const bool modeDebug = true;


  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');

    if(modeDebug){
      print("[ POST ] FINAL URL: $url");
      print("[ POST ] FINAL PARAM: $body");
    }

    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String endpoint, Map<String, dynamic>? queryParams) async {
    final url = Uri.parse(baseUrl + endpoint).replace(
      queryParameters: queryParams?.map((key, value) => MapEntry(key, value.toString())) ?? {},
    );

    if(modeDebug){
      print("[ GET ] FINAL URL: $url");
      print("[ GET ] FINAL PARAM: $queryParams");
    }

    return await http.get(url, headers: {
      "Content-Type": "application/json",
    });
  }

  Future<String?> handlingRequest({
    required String urlParam,
    Map<String, dynamic>? params,
    String method = "GET",
    bool asJson = false,
  }) async {
    try {

      String fullUrl = urlParam;

      http.Response response;
      print("[ $method ] url => $fullUrl");
      print("[ $method ] params => $params");

      if (method.toUpperCase() == 'GET') {
        // Si es GET, arma la URL con o sin parámetros
        Uri uri;
        if (params != null && params.isNotEmpty) {
          uri = Uri.parse(fullUrl).replace(queryParameters: params);
        } else {
          uri = Uri.parse(fullUrl);
        }
        response = await http.get(uri).timeout(const Duration(seconds: 10));
      } else {
        // Para otros métodos, construye body y headers
        dynamic body;
        Map<String, String>? headers;

        if (params != null) {
          if (asJson) {
            body = jsonEncode(params);
            headers = {'Content-Type': 'application/json'};
          } else {
            body = params.map((k, v) => MapEntry(k, v.toString()));
            headers = {'Content-Type': 'application/x-www-form-urlencoded'};
          }
        }

        Uri uri = Uri.parse(fullUrl);

        switch (method.toUpperCase()) {
          case 'POST':
            response = await http.post(uri, body: body, headers: headers)
                .timeout(const Duration(seconds: 10));
            break;
          case 'PUT':
            response = await http.put(uri, body: body, headers: headers)
                .timeout(const Duration(seconds: 10));
            break;
          case 'PATCH':
            response = await http.patch(uri, body: body, headers: headers)
                .timeout(const Duration(seconds: 10));
            break;
          case 'DELETE':
            response = await http.delete(uri, body: body, headers: headers)
                .timeout(const Duration(seconds: 10));
            break;
          default:
            throw UnsupportedError("HTTP method $method no soportado");
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        // print("HTTP error: ${response.statusCode}");
        // print("response => ${response.headers}");
        return null;
      }
    } catch (e) {
      // print("Error en handlingRequest: $e");
      return null;
    }
  }

}
