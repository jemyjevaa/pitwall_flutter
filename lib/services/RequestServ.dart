import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestServ {
  static const String baseUrl = 'https://nuevosistema.busmen.net';
  static const bool modeDebug = true;

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool asJson = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    Map<String, String> headers = {};
    dynamic encodedBody;

    if (asJson) {
      headers = {'Content-Type': 'application/json'};
      encodedBody = jsonEncode(body);
    } else {
      headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      encodedBody = body.map((key, value) => MapEntry(key, value.toString()));
    }

    if (modeDebug) {
      print("[ POST ] FINAL URL: $url");
      print("[ POST ] FINAL PARAM: $body");
      print("[ POST ] AS JSON: $asJson");
    }

    return await http.post(
      url,
      headers: headers,
      body: encodedBody,
    );
  }

  static Future<http.Response> get(String endpoint, Map<String, dynamic>? queryParams) async {
    final url = Uri.parse(baseUrl + endpoint).replace(
      queryParameters: queryParams?.map((key, value) => MapEntry(key, value.toString())) ?? {},
    );

    if (modeDebug) {
      print("[ GET ] FINAL URL: $url");
      print("[ GET ] FINAL PARAM: $queryParams");
    }

    return await http.get(url, headers: {
      "Content-Type": "application/json",
    });
  }

  // region REQUEST PARSE
  RequestServ._privateConstructor();
  static final RequestServ instance = RequestServ._privateConstructor();

  Future<String?> handlingRequest({
    required String urlParam,
    Map<String, dynamic>? params,
    String method = "GET",
    bool asJson = false,
    urlFull = false
  }) async {
    try {
      // Decide base URL
      // bool isNormUrl = urlParam == urlValidateUser ||
      //     urlParam == urlGetRoute ||
      //     urlParam == urlStopInRoute ||
      //     urlParam == urlUnitAsiggned;

      final base = baseUrl; //isNormUrl ? baseUrlNor : baseUrlAdm;
      String fullUrl = urlFull? urlParam :base + urlParam;

      http.Response response;
      if (RequestServ.modeDebug){
        print("[ $method ] fullUrl => $fullUrl");
        print("[ $method ] params => $params");
      }

      // Agregar parámetros para GET en query string
      if (method.toUpperCase() == 'GET' && params != null && params.isNotEmpty) {
        final uri = Uri.parse(fullUrl).replace(queryParameters: params);
        response = await http.get(uri).timeout(const Duration(seconds: 10));
      } else {
        // Construir el body según asJson o form-url-encoded
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
            response = await http
                .post(uri, body: body, headers: headers)
                .timeout(const Duration(seconds: 10));
            break;
          case 'PUT':
            response = await http
                .put(uri, body: body, headers: headers)
                .timeout(const Duration(seconds: 10));
            break;
          case 'PATCH':
            response = await http
                .patch(uri, body: body, headers: headers)
                .timeout(const Duration(seconds: 10));
            break;
          case 'DELETE':
            response = await http
                .delete(uri, body: body, headers: headers)
                .timeout(const Duration(seconds: 10));
            break;
          default:
            throw UnsupportedError("HTTP method $method no soportado");
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 500) {
        return response.body;
      } else {
        if (RequestServ.modeDebug){
          print("HTTP error: ${response.statusCode}");
          print("Response body: ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (RequestServ.modeDebug){
        print("Error en handlingRequest: $e");
      }
      return null;
    }
  }

  /// Función genérica para parsear JSON a objeto
  Future<T?> handlingRequestParsed<T>(
      {required String urlParam,
        Map<String, dynamic>? params,
        String method = "GET",
        bool asJson = false,
        required T Function(dynamic json) fromJson, urlFull = false} ) async {
    final responseString = await handlingRequest(
        urlParam: urlParam, params: params, method: method, asJson: asJson, urlFull: urlFull);

    if (responseString == null) return null;

    try {
      final jsonMap = jsonDecode(responseString);
      return fromJson(jsonMap);
    } catch (e) {
      if (RequestServ.modeDebug){
        print("Error en handlingRequestParsed: $e");
      }
      return null;
    }
  }
  // endregion REQUEST PARSE
}
