import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import './pages/splash_screen.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'vi_VN': {
          "app_name": "E-Taxi",
          "welcome_text": "E-Taxi - Tài xế",
          "guild_text": "Đăng nhập / Đăng ký tài khoản E-Taxi ngay bây giờ",
          "login_btn_text": "Đăng nhập",
          "signup_btn_text": "Đăng ký",
          "sdt_text": "Số Di động",
          "sdt_hint_text": "Nhập số điện thoại của bạn",
          "password_text": "Mật khẩu",
          "password_hint_text": "Nhập mật khẩu của bạn",
          "confirm_password_text": "Xác nhận mật khẩu",
          "confirm_password_hint_text": "Nhập lại mật khẩu của bạn",
          "continue_text": "tiếp tục",
          "password_screen_title": "Nhập mật khẩu",
          "password_screen_hint": "Bạn đang đăng nhập với số điện thoại",
          "forgot_password_text": "Quên mật khẩu",
          "password_wrong_text": "Mật khẩu không đúng, bạn còn {} lần thử lại",
          "otp_screen_title": "Nhập mã xác thực",
          "otp_screen_hint_1": "Mã xác thực sẽ được gửi đến số",
          "otp_screen_hint_2":
              "Vui lòng kiểm tra tin nhắn và nhập mã xác thực vào đây.",
          "invalid_otp": "Mã xác thực không chính xác. Vui lòng nhập lại.",
          "resend_otp_text": "Gửi lại mã xác thực",
          "finish_signup_title": "Hoàn tất đăng ký",
          "name_label": "họ và tên",
          "name_hint": "VD: Nguyễn Văn A",
          "address_label": "địa chỉ",
          "address_hint": "VD: 123 Nguyễn Văn A, P.1, Q.1, TP.HCM",
          "navigation_home_label": "Trang chủ",
          "navigation_account_label": "Tài khoản",
          "home_top_text_1": "Cùng đi nào!",
          "home_top_text_2": "Chúng tối sẽ đưa bạn đến bất cứ đâu!",
          "home_search_bar_hint": "Chọn điểm đón"
        }
      };
}

void main() async {
  runApp(GetMaterialApp(
    translations: Messages(),
    locale: Locale('vi', 'VN'),
    debugShowCheckedModeBanner: false,
    fallbackLocale: const Locale('vi', 'VN'),
    theme: ThemeData(
      primarySwatch: Colors.indigo,
    ),
    home: SplashScreen(),
    builder: EasyLoading.init(),
  ));
}
