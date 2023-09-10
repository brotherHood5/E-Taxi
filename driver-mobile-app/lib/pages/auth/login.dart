import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grab_eat_ui/api/SocketApi.dart';
import 'package:grab_eat_ui/components/components.dart';
import 'package:grab_eat_ui/pages/auth/sign_up.dart';
import 'package:grab_eat_ui/pages/root_app.dart';
import 'package:grab_eat_ui/widgets/text_field_container.dart';

import '../../../api/AuthService.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/helper.dart';
import 'finish_sign_up.dart';
import 'verify_otp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _hiddenPassword = true;
  String? _phoneNumberError;
  String? _passwordError;

  late final navigator = Navigator.of(context);

  @override
  void initState() {
    super.initState();
    // _phoneNumberController.text = "0972360214";
    // _passwordController.text = "Vinh1706!";

    _phoneNumberController.addListener(() {
      setState(() {
        if (_phoneNumberController.text.length != 10) {
          _phoneNumberError = "Số điện thoại không hợp lệ";
        } else {
          _phoneNumberError = null;
        }
      });
      if (_phoneNumberController.text.length > 10) {
        _phoneNumberController.text =
            _phoneNumberController.text.substring(0, 10);
        _phoneNumberController.selection = TextSelection.fromPosition(
            TextPosition(offset: _phoneNumberController.text.length));
      }
    });

    _passwordController.addListener(() {
      String password = _passwordController.text;
      setState(() {
        if (password.length < 8) {
          _passwordError = "Mật khẩu phải có ít nhất 8 ký tự";
        } else {
          if (!passwordRegExp.hasMatch(password)) {
            _passwordError =
                "Mật khẩu phải có ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt";
            return;
          }
          _passwordError = null;
        }
      });
      if (password.length > 32) {
        _passwordController.text = _passwordController.text.substring(0, 32);
        _passwordController.selection = TextSelection.fromPosition(
            TextPosition(offset: _passwordController.text.length));
      }
    });
  }

  Future<void> login([bool mounted = true]) async {
    String phoneNumber = _phoneNumberController.text;
    String password = _passwordController.text;
    FocusManager.instance.primaryFocus?.unfocus();

    EasyLoading.show(
        status: "Đang đăng nhập",
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);
    try {
      final res = await AuthService.login(phoneNumber, password);
      if (res.statusCode == 200) {
        var body = jsonDecode(res.body);
        EasyLoading.dismiss();

        if (body["user"]["phoneNumberVerified"] == "false") {
          return;
        }

        if (body["user"]["fullName"] == null ||
            body["user"]["fullName"] == "") {
          navigator.push(MaterialPageRoute(
              builder: (context) => const FinishSignUpScreen()));
          return;
        }

        saveCredential(
            userJsonEncoded: jsonEncode(body["user"]),
            accessToken: body["accessToken"],
            refreshToken: body["refreshToken"]);
        SocketApi.setAuthToken(body["accessToken"]);
        navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const RootApp()));
        return;
      }

      if (res.statusCode == 422) {
        EasyLoading.dismiss();
        var error = jsonDecode(res.body);
        if (error["message"] == "Your phone number is not verified!") {
          navigator.push(MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(
                    phoneNumber: phoneNumber,
                  )));
        } else {
          EasyLoading.showError("Số điện thoại hoặc mật khẩu không đúng",
              maskType: EasyLoadingMaskType.black, dismissOnTap: true);
        }
      }
    } catch (e) {
      print(e);
      EasyLoading.showError("Có lỗi xảy ra khi đăng nhập.\nVui lòng thử lại",
          maskType: EasyLoadingMaskType.black, dismissOnTap: true);
      await clearCredential();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color primary = Theme.of(context).primaryColor;

    Widget _loginForm = SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            const Upside(
              imgUrl: "assets/images/login.png",
            ),
            const PageTitleBar(title: 'Đăng nhập ngay'),
            Padding(
              padding: const EdgeInsets.only(top: 320.0),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Form(
                      child: Column(
                        children: [
                          TextFieldContainer(
                            child: TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              cursorColor: primary,
                              decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.phone,
                                    color: primary,
                                  ),
                                  hintText: "Số điện thoại",
                                  errorText: _phoneNumberError,
                                  suffixIcon: _phoneNumberController
                                          .text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear,
                                              color: Colors.grey),
                                          onPressed: () =>
                                              _phoneNumberController.clear(),
                                        )
                                      : null,
                                  hintStyle:
                                      const TextStyle(fontFamily: 'OpenSans'),
                                  border: InputBorder.none),
                            ),
                          ),
                          TextFieldContainer(
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _hiddenPassword,
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                FilteringTextInputFormatter.singleLineFormatter
                              ],
                              cursorColor: primary,
                              decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.lock,
                                    color: primary,
                                  ),
                                  hintText: "Mật khẩu",
                                  errorText: _passwordError,
                                  errorMaxLines: 3,
                                  hintStyle: TextStyle(fontFamily: 'OpenSans'),
                                  suffixIcon:
                                      _passwordController.text.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(
                                                  _hiddenPassword
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Colors.grey),
                                              onPressed: () => {
                                                setState(() {
                                                  _hiddenPassword =
                                                      !_hiddenPassword;
                                                })
                                              },
                                            )
                                          : null,
                                  border: InputBorder.none),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            width: size.width * 0.8,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(29),
                              child: ElevatedButton(
                                child: Text(
                                  "Đăng nhập",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                onPressed:
                                    _passwordController.text.isNotEmpty &&
                                            _phoneNumberController
                                                .text.isNotEmpty &&
                                            _phoneNumberError == null &&
                                            _passwordError == null
                                        ? login
                                        : null,
                                style: ElevatedButton.styleFrom(
                                    primary: primary,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 20),
                                    textStyle: TextStyle(
                                        letterSpacing: 1,
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'OpenSans')),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UnderPart(
                            title: "Chưa có tài khoản?",
                            navigatorText: "Đăng ký",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen()));
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );

    return SafeArea(
      child: Scaffold(
        body: _loginForm,
      ),
    );
  }
}
