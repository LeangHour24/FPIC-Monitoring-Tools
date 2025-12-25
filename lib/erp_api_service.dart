import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple ERPNext API helper using API Key + API Secret authentication.
class ErpApiService {
  static String baseUrl = 'https://erp.farmsnexus.com';
  static String apiKey = '';
  static String apiSecret = '';

  static void setBaseUrl(String url) => baseUrl = url;
  static void setCredentials(String key, String secret) {
    apiKey = key;
    apiSecret = secret;
  }

  static Map<String, String> get headers {
    final auth = apiKey.isNotEmpty && apiSecret.isNotEmpty
        ? {'Authorization': 'token $apiKey:$apiSecret'}
        : <String, String>{};
    return {
      ...auth,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// GET request to ERPNext. `endpoint` should include the leading path,
  /// for example `/api/resource/Customer` or `/api/method/frappe.auth.get_logged_user`.
  static Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final res = await http.get(uri, headers: headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('GET failed (${res.statusCode}): ${res.body}');
  }

  /// POST request with JSON body.
  static Future<dynamic> post(String endpoint, Map data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final res = await http.post(uri, headers: headers, body: jsonEncode(data));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('POST failed (${res.statusCode}): ${res.body}');
  }
}
