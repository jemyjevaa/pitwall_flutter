import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestServ {
  static const String baseUrl = 'https://nuevosistema.busmen.net';
  static const bool modeDebug = true;


  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String endpoint, Map<String, dynamic>? queryParams) async {
    final uri = Uri.parse(baseUrl + endpoint).replace(
      queryParameters: queryParams?.map((key, value) => MapEntry(key, value.toString())) ?? {},
    );

    if(modeDebug){
      print("FINAL URL: $uri");
    }

    return await http.get(uri, headers: {
      "Content-Type": "application/json",
    });
  }
}
