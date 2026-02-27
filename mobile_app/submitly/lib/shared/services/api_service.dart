import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class ApiService {
  static final _client = http.Client();

  static Future<http.Response> get(String path,
      {Map<String, String>? queryParams}) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}$path').replace(queryParameters: queryParams);
    return _client.get(uri, headers: _headers);
  }

  static Future<http.Response> post(String path,
      {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    return _client.post(uri, headers: _headers, body: jsonEncode(body));
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };
}
