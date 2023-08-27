import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../main_layout.dart';
import './sign_up.dart';
import '../../../api/Auth.dart';
import '../../../constants.dart';

import '../../helpers/helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  bool _hiddenPassword = true;
  String? _phoneNumberError = null;
  String? _passwordError = null;

  @override
  void initState() {
    super.initState();
    _phoneNumberController.text = "0972360214";
    _passwordController.text = "Vinh1706!";

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Future<void> login([bool mounted = true]) async {
      String phoneNumber = _phoneNumberController.text;
      String password = _passwordController.text;
      FocusManager.instance.primaryFocus?.unfocus();

      EasyLoading.show(
          status: "Đang đăng nhập",
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);
      try {
        final res = await Auth.login(phoneNumber, password);
        await Future.delayed(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          var body = jsonDecode(res.body);
          EasyLoading.dismiss();
          saveCredential(
              userJsonEncoded: jsonEncode(body["user"]),
              accessToken: body["accessToken"],
              refreshToken: body["refreshToken"]);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()));
          return;
        }

        if (res.statusCode == 422) {
          EasyLoading.showError("Số điện thoại hoặc mật khẩu không đúng",
              maskType: EasyLoadingMaskType.black, dismissOnTap: true);
        }
      } catch (e) {
        print(e);
        EasyLoading.showError("Có lỗi xảy ra khi đăng nhập.\nVui lòng thử lại",
            maskType: EasyLoadingMaskType.black, dismissOnTap: true);
      }
    }

    final VoidCallback? _onLoginPressed = _passwordController.text.isNotEmpty &&
            _phoneNumberController.text.isNotEmpty &&
            _phoneNumberError == null &&
            _passwordError == null
        ? login
        : null;

    Widget _loginForm = Center(
      child: SingleChildScrollView(
          child: Container(
        margin: const EdgeInsets.only(top: layoutXLarge),
        padding: const EdgeInsets.symmetric(horizontal: layoutMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("welcome_text".tr(), style: theme.textTheme.titleLarge),
            const SizedBox(height: layoutSmall),
            Text("guild_text".tr(), style: theme.textTheme.titleMedium),
            const SizedBox(height: layoutXLarge),
            Text("sdt_text".tr(), style: theme.textTheme.titleSmall),
            const SizedBox(height: layoutSmall),
            TextField(
              autofocus: true,
              controller: _phoneNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: "sdt_hint_text".tr(),
                errorText: _phoneNumberError,
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
            Text("password_text".tr(), style: theme.textTheme.titleSmall),
            const SizedBox(height: layoutSmall),
            TextField(
              controller: _passwordController,
              obscureText: _hiddenPassword,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter
              ],
              decoration: InputDecoration(
                hintText: "password_hint_text".tr(),
                errorText: _passwordError,
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
                            builder: (context) => const SignUpScreen()))
                      },
                  child: Text('signup_btn_text'.tr())),
            ),
            const SizedBox(height: layoutSmall),
            ElevatedButton(
                onPressed: _onLoginPressed,
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
                child: Text(toBeginningOfSentenceCase("login_btn_text".tr())!)),
          ],
        ),
      )),
    );

    return Scaffold(
      body: _loginForm,
    );
  }
}
