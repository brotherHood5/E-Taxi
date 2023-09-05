import 'package:http/http.dart' as http;

import '../utils/app_constants.dart';
import 'ApiClient.dart';

class DriverService {
  static final String _endpoint = "${ApiConstants.baseUrl}/drivers";
  static final ApiClient _client = ApiClient();
}
