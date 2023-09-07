import 'package:http/http.dart' as http;

import '../utils/helper.dart';

class ApiClient extends http.BaseClient {
  Future<String?> _getAccessToken() async {
    var data = await getStoredData();
    return data["accessToken"];
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _getAccessToken();

    return {
      'Authorization': 'Bearer $token',
    };
  }

  static final ApiClient _singleton = ApiClient._internal();

  factory ApiClient() {
    return _singleton;
  }

  ApiClient._internal();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(await _getHeaders());
    print(request.url);
    return request.send().timeout(const Duration(seconds: 30));
  }
}
