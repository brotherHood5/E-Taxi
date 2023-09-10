import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grab_eat_ui/api/AuthService.dart';
import 'package:grab_eat_ui/components/components.dart';
import 'package:grab_eat_ui/pages/auth/verify_otp.dart';
import 'package:grab_eat_ui/theme/colors.dart';
import 'package:grab_eat_ui/utils/helper.dart';
import 'package:grab_eat_ui/widgets/text_field_container.dart';

import '../../utils/app_constants.dart';
import 'login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _phoneNumberError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _hiddenPassword = true;

  @override
  void initState() {
    super.initState();
    // _phoneNumberController.text = "0972360012";
    // _passwordController.text = "Vinh1706!";
    // _confirmPasswordController.text = "Vinh1706!";

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

    _confirmPasswordController.addListener(() {
      String confirmPassword = _confirmPasswordController.text;
      String password = _passwordController.text;
      setState(() {
        if (confirmPassword.isEmpty || confirmPassword == password) {
          _confirmPasswordError = null;
          return;
        }
        _confirmPasswordError = "Mật khẩu không khớp";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final theme = Theme.of(context);

    Future<void> signup([bool mounted = true]) async {
      String phoneNumber = _phoneNumberController.text;
      String password = _passwordController.text;
      FocusManager.instance.primaryFocus?.unfocus();

      EasyLoading.show(
          status: "Đang đăng ký",
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      try {
        final res = await AuthService.signUp(phoneNumber, password);
        if (res.statusCode == 200) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(
                    phoneNumber: phoneNumber,
                  )));
          var body = jsonDecode(res.body);
          EasyLoading.dismiss();
          saveCredential(
              userJsonEncoded: jsonEncode(body["user"]),
              accessToken: body["accessToken"],
              refreshToken: body["refreshToken"]);
          return;
        } else {
          if (res.statusCode == 422) {
            EasyLoading.showError("Số điện thoại đã được đăng ký",
                maskType: EasyLoadingMaskType.black, dismissOnTap: true);
          } else {
            EasyLoading.showError(
                "Có lỗi xảy ra khi đăng ký.\nVui lòng thử lại",
                maskType: EasyLoadingMaskType.black,
                dismissOnTap: true);
          }
        }
      } catch (e) {
        print(e);
        EasyLoading.showError("Có lỗi xảy ra khi đăng ký.\nVui lòng thử lại",
            maskType: EasyLoadingMaskType.black, dismissOnTap: true);
      }
    }

    final VoidCallback? _onSignupPressed =
        _passwordController.text.isNotEmpty &&
                _phoneNumberController.text.isNotEmpty &&
                _confirmPasswordController.text.isNotEmpty &&
                _phoneNumberError == null &&
                _passwordError == null &&
                _confirmPasswordError == null
            ? signup
            : null;

    Widget _signupForm = SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            const Upside(
              imgUrl: "assets/images/signUp.png",
            ),
            const PageTitleBar(title: 'Tạo tài khoản mới'),
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
                              autofocus: true,
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              cursorColor: kPrimaryColor,
                              decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.phone,
                                    color: kPrimaryColor,
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
                              cursorColor: kPrimaryColor,
                              decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.lock,
                                    color: kPrimaryColor,
                                  ),
                                  hintText: "Mật khẩu",
                                  hintStyle: TextStyle(fontFamily: 'OpenSans'),
                                  errorText: _passwordError,
                                  errorMaxLines: 3,
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
                          TextFieldContainer(
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _hiddenPassword,
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                FilteringTextInputFormatter.singleLineFormatter
                              ],
                              cursorColor: kPrimaryColor,
                              decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.lock,
                                    color: kPrimaryColor,
                                  ),
                                  hintText: "Xác nhận mật khẩu",
                                  hintStyle: TextStyle(fontFamily: 'OpenSans'),
                                  errorText: _confirmPasswordError,
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
                                  "Đăng ký",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                                onPressed: _onSignupPressed,
                                style: ElevatedButton.styleFrom(
                                    primary: kPrimaryColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 20),
                                    textStyle: TextStyle(
                                        letterSpacing: 2,
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
                            title: "Bạn đã có tài khoản?",
                            navigatorText: "Đăng nhập",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()));
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
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
        body: _signupForm,
      ),
    );
  }
}
