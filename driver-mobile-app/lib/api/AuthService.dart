import 'package:http/http.dart' as http;

import '../utils/app_constants.dart';
import 'ApiClient.dart';

class AuthService {
  static final String _endpoint = "${ApiConstants.baseUrl}/drivers";
  static final ApiClient _client = ApiClient();

  static Future<http.Response> refreshToken(String token) {
    return http.post(Uri.parse("$_endpoint/refresh-token"), body: {
      'refreshToken': token,
    }).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> resolveToken(String token) {
    return http.post(Uri.parse("$_endpoint/resolve-token"), body: {
      'token': token,
    }).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> login(String phoneNumber, String password) {
    return http.post(Uri.parse("$_endpoint/login"), body: {
      'phoneNumber': phoneNumber,
      'password': password,
    }).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> logout() {
    return _client.get(Uri.parse("$_endpoint/logout"));
  }

  static Future<http.Response> signUp(String phoneNumber, String password) {
    return http.post(Uri.parse("$_endpoint/signup"), body: {
      'phoneNumber': phoneNumber,
      'password': password,
    }).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> verifyOtp(String phoneNumber, String otp) {
    return _client
        .get(Uri.parse(
            "$_endpoint/verify-otp?phoneNumber=$phoneNumber&otp=$otp"))
        .timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> finishSignUp(
      String id, String fullName, String vehicleType) {
    return http.put(Uri.parse("$_endpoint/$id"), body: {
      'fullName': fullName,
      'vehicleType': vehicleType,
      'driverStatus': 'ACTIVE',
    }).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> reSendOtp(String phoneNumber) {
    return _client
        .get(Uri.parse("$_endpoint/resend-otp?phoneNumber=$phoneNumber"));
  }
}
