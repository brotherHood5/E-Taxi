import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../api/AuthService.dart';
import '../../utils/app_constants.dart';
import '../../utils/helper.dart';
import 'login.dart';
import 'verify_otp.dart';

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

  String? _phoneNumberError = null;
  String? _passwordError = null;
  String? _confirmPasswordError = null;

  bool _hiddenPassword = true;

  @override
  void initState() {
    super.initState();
    _phoneNumberController.text = "0972360012";
    _passwordController.text = "Vinh1706!";
    _confirmPasswordController.text = "Vinh1706!";

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

    Widget _signupForm = Center(
      child: SingleChildScrollView(
          child: Container(
        margin: const EdgeInsets.only(top: layoutXLarge),
        padding: const EdgeInsets.symmetric(horizontal: layoutMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("welcome_text".tr, style: theme.textTheme.titleLarge),
            const SizedBox(height: layoutSmall),
            Text("guild_text".tr, style: theme.textTheme.titleMedium),
            const SizedBox(height: layoutXLarge),
            Text("sdt_text".tr, style: theme.textTheme.titleSmall),
            const SizedBox(height: layoutSmall),
            TextField(
              autofocus: true,
              controller: _phoneNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                errorText: _phoneNumberController.text.isNotEmpty
                    ? _phoneNumberError
                    : null,
                hintText: "sdt_hint_text".tr,
                border: const OutlineInputBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(borderRadiusSmall)),
                ),
                suffixIcon: _phoneNumberController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => _phoneNumberController.clear(),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: layoutSmall),
            Text("password_text".tr, style: theme.textTheme.titleSmall),
            const SizedBox(height: layoutSmall),
            TextField(
              controller: _passwordController,
              obscureText: _hiddenPassword,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter
              ],
              decoration: InputDecoration(
                hintText: "password_hint_text".tr,
                errorText: _passwordError,
                errorMaxLines: 3,
                border: const OutlineInputBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(borderRadiusSmall)),
                ),
                suffixIcon: _passwordController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                            _hiddenPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey),
                        onPressed: () => {
                          setState(() {
                            _hiddenPassword = !_hiddenPassword;
                          })
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: layoutSmall),
            Text("confirm_password_text".tr, style: theme.textTheme.titleSmall),
            const SizedBox(height: layoutSmall),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _hiddenPassword,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter
              ],
              decoration: InputDecoration(
                errorText: _confirmPasswordError,
                hintText: "confirm_password_hint_text".tr,
                border: const OutlineInputBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(borderRadiusSmall)),
                ),
                suffixIcon: _passwordController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                            _hiddenPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey),
                        onPressed: () => {
                          setState(() {
                            _hiddenPassword = !_hiddenPassword;
                          })
                        },
                      )
                    : null,
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () => {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginScreen()))
                      },
                  child: Text('login_btn_text'.tr)),
            ),
            const SizedBox(height: layoutSmall),
            ElevatedButton(
                onPressed: _onSignupPressed,
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                      const Size(double.infinity, minTouchSize)),
                  elevation: MaterialStateProperty.all(0),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadiusXSmall),
                    ),
                  ),
                ),
                child: Text("signup_btn_text".tr)),
          ],
        ),
      )),
    );

    return Scaffold(
      body: _signupForm,
    );
  }
}
