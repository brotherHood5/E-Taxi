import 'package:http/http.dart' as http;

import '../constants.dart';
import 'ApiClient.dart';

class GeoService {
  static final String _endpoint = "${ApiConstants.baseUrl}/geo";
  static final ApiClient _client = ApiClient();

  static Future<http.Response> geocode(String query) {
    return _client.get(Uri.parse("$_endpoint/geocode?q=$query"));
  }

  static Future<http.Response> reverseGeocode(double lat, double lon) {
    return _client.get(Uri.parse("$_endpoint/reverse?lat=$lat&lon=$lon"));
  }
}
