import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClient {
  Future<Map<String, dynamic>> getJson(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final res = await http.get(uri, headers: headers);
    final body = res.body;

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        "GET ${uri.toString()} failed: ${res.statusCode} - $body",
      );
    }

    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postJson(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final res = await http.post(uri, headers: headers, body: body);
    final raw = res.body;

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        "POST ${uri.toString()} failed: ${res.statusCode} - $raw",
      );
    }

    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
