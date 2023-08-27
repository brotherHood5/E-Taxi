import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grab_clone/api/Auth.dart';
import 'package:grab_clone/constants.dart';
import 'package:grab_clone/helpers/helper.dart';

import '../main_layout.dart';

class FinishSignUpScreen extends StatefulWidget {
  const FinishSignUpScreen({Key? key}) : super(key: key);

  @override
  State<FinishSignUpScreen> createState() => _FinishSignUpScreenState();
}

class _FinishSignUpScreenState extends State<FinishSignUpScreen> {
  Color enabled = const Color.fromARGB(255, 63, 56, 89);
  Color backgroundColor = const Color(0xFF1F1A30);

  final TextEditingController _nameController = TextEditingController();
  String? _nameError;

  bool validateForm() {
    if (_nameController.text.isEmpty) {
      setState(() {
        _nameError = null;
        _nameError = "Vui lòng nhập họ và tên";
      });
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("finish_signup_title".tr()),
        titleTextStyle: theme.textTheme.titleLarge,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.grey[300],
        child: SingleChildScrollView(
            child: Container(
          margin: const EdgeInsets.only(top: layoutMedium),
          padding: const EdgeInsets.symmetric(
              horizontal: layoutMedium, vertical: layoutXMedium),
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText:
                      "${toBeginningOfSentenceCase("name_label".tr())} *",
                  hintText: "name_hint".tr(),
                  labelStyle: theme.textTheme.titleMedium,
                  floatingLabelStyle: theme.textTheme.titleLarge!
                      .merge(TextStyle(color: theme.colorScheme.primary)),
                  errorText: _nameError,
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey[300]!, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: theme.colorScheme.primary, width: 1.0),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  suffixIcon: _nameController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => _nameController.clear(),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: layoutXMedium, horizontal: layoutMedium),
                ),
              ),
            ],
          ),
        )),
      ),
      bottomSheet: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: 80,
        padding: const EdgeInsets.all(layoutMedium),
        child: ElevatedButton(
            onPressed: () async {
              if (validateForm()) {
                EasyLoading.show(
                    status: "Đang cập nhật",
                    maskType: EasyLoadingMaskType.black,
                    dismissOnTap: false);
                try {
                  var data = await getStoredData();
                  await Auth.finishSignUp(
                      data["user"].id!, _nameController.text.trim());
                  await getNewCredential();

                  EasyLoading.dismiss();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()));
                } catch (e) {
                  EasyLoading.showError("Có lỗi xảy ra.\nVui lòng thử lại",
                      maskType: EasyLoadingMaskType.black, dismissOnTap: true);
                  print(e);
                }
              }
            },
            style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(0),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadiusSmall),
                ))),
            child: Text(
              "Xong",
              style: theme.textTheme.titleMedium!.merge(const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
            )),
      ),
    );
  }
}
