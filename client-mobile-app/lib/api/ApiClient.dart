import 'package:http/http.dart' as http;

import '../helpers/helper.dart';

class ETaxiClient extends http.BaseClient {
  static Future<Map<String, String>> _getHeaders() async {
    var data = await getStoredData();

    return {
      'Authentication': 'Bearer ${data["accessToken"]}',
    };
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(await _getHeaders());
    print(request.headers);
    return request.send();
  }
}
