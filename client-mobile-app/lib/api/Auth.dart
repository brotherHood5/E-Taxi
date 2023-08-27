import 'package:grab_clone/api/ApiClient.dart';

import '../../constants.dart';
import 'package:http/http.dart' as http;

final ETaxiClient _client = ETaxiClient();

class Auth {
  static Future<http.Response> refreshToken(String token) {
    return http.post(
        Uri.parse("${ApiConstants.customersEndpoint}/refresh-token"),
        body: {
          'refreshToken': token,
        });
  }

  static Future<http.Response> resolveToken(String token) {
    return http.post(
        Uri.parse("${ApiConstants.customersEndpoint}/resolve-token"),
        body: {
          'token': token,
        });
  }

  static Future<http.Response> login(
      String phoneNumber, String password) async {
    final res = await http
        .post(Uri.parse("${ApiConstants.customersEndpoint}/login"), body: {
      'phoneNumber': phoneNumber,
      'password': password,
    });

    return res;
  }

  static Future<http.Response> signUp(
      String phoneNumber, String password) async {
    final res = await http
        .post(Uri.parse("${ApiConstants.customersEndpoint}/signup"), body: {
      'phoneNumber': phoneNumber,
      'password': password,
    });

    return res;
  }

  static Future<http.Response> verifyOtp(String phoneNumber, String otp) {
    return http.get(Uri.parse(
        "${ApiConstants.customersEndpoint}/verify-otp?phoneNumber=$phoneNumber&otp=$otp"));
  }

  static Future<http.Response> finishSignUp(String id, String fullName) {
    return http.put(Uri.parse("${ApiConstants.customersEndpoint}/$id"), body: {
      'fullName': fullName,
    });
  }

  static Future<http.Response> sendOtp(String phoneNumber) {
    return _client.get(Uri.parse(
        "${ApiConstants.customersEndpoint}/resend-otp?phoneNumber=$phoneNumber"));
  }
}
