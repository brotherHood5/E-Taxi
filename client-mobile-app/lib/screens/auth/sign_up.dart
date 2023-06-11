import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:grab_clone/constants.dart';

import '../../core/animations/fade.animation.dart';
import '../../core/colors/hex.color.dart';

enum FormData { Name, Phone, Email, Gender, password, ConfirmPassword }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  Color enabled = const Color.fromARGB(255, 63, 56, 89);
  Color enabledtxt = Colors.white;
  Color deaible = Colors.grey;
  Color backgroundColor = const Color(0xFF1F1A30);

  FormData? selected;

  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _addressController = new TextEditingController();

  bool validateForm() {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _nameController.addListener(() {
      setState(() {});
    });
    _addressController.addListener(() {
      setState(() {});
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("finish_signup_title".tr()),
        shape: Border(bottom: BorderSide(color: Colors.grey[350]!, width: 2)),
        titleTextStyle: theme.textTheme.titleLarge,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        elevation: 10,
        leading: IconButton(
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.arrow_back)),
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
                  errorText: _nameController.text.isEmpty
                      ? "Vui lòng nhập họ và tên"
                      : null,
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
              const SizedBox(height: layoutXMedium),
              TextField(
                controller: _addressController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText:
                      "${toBeginningOfSentenceCase("address_label".tr())} *",
                  hintText: "address_hint".tr(),
                  labelStyle: theme.textTheme.titleMedium,
                  floatingLabelStyle: theme.textTheme.titleLarge!
                      .merge(TextStyle(color: theme.colorScheme.primary)),
                  errorText: _addressController.text.isEmpty
                      ? "Vui lòng nhập địa chỉ"
                      : null,
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
                  suffixIcon: _addressController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => _addressController.clear(),
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
            onPressed: () {
              if (validateForm()) {}
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
    // return Scaffold(
    //   body: Container(
    //     decoration: BoxDecoration(
    //       gradient: LinearGradient(
    //         begin: Alignment.topLeft,
    //         end: Alignment.bottomRight,
    //         stops: const [0.1, 0.4, 0.7, 0.9],
    //         colors: [
    //           HexColor("#4b4293").withOpacity(0.8),
    //           HexColor("#4b4293"),
    //           HexColor("#08418e"),
    //           HexColor("#08418e")
    //         ],
    //       ),
    //       image: DecorationImage(
    //         fit: BoxFit.cover,
    //         colorFilter: ColorFilter.mode(
    //             HexColor("#fff").withOpacity(0.2), BlendMode.dstATop),
    //         image: const NetworkImage(
    //           'https://mir-s3-cdn-cf.behance.net/project_modules/fs/01b4bd84253993.5d56acc35e143.jpg',
    //         ),
    //       ),
    //     ),
    //     child: Center(
    //       child: SingleChildScrollView(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Card(
    //               elevation: 5,
    //               color:
    //                   const Color.fromARGB(255, 171, 211, 250).withOpacity(0.4),
    //               child: Container(
    //                 width: 400,
    //                 padding: const EdgeInsets.all(40.0),
    //                 decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(8),
    //                 ),
    //                 child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     FadeAnimation(
    //                       delay: 0.8,
    //                       child: Image.network(
    //                         "https://cdni.iconscout.com/illustration/premium/thumb/job-starting-date-2537382-2146478.png",
    //                         width: 100,
    //                         height: 100,
    //                       ),
    //                     ),
    //                     const SizedBox(
    //                       height: 10,
    //                     ),
    //                     FadeAnimation(
    //                       delay: 1,
    //                       child: Container(
    //                         child: Text(
    //                           "Create your account",
    //                           style: TextStyle(
    //                               color: Colors.white.withOpacity(0.9),
    //                               letterSpacing: 0.5),
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(
    //                       height: 20,
    //                     ),
    //                     FadeAnimation(
    //                       delay: 1,
    //                       child: Container(
    //                         width: 300,
    //                         height: 40,
    //                         decoration: BoxDecoration(
    //                           borderRadius: BorderRadius.circular(12.0),
    //                           color: selected == FormData.Email
    //                               ? enabled
    //                               : backgroundColor,
    //                         ),
    //                         padding: const EdgeInsets.all(5.0),
    //                         child: TextField(
    //                           controller: nameController,
    //                           onTap: () {
    //                             setState(() {
    //                               selected = FormData.Name;
    //                             });
    //                           },
    //                           decoration: InputDecoration(
    //                             enabledBorder: InputBorder.none,
    //                             border: InputBorder.none,
    //                             prefixIcon: Icon(
    //                               Icons.title,
    //                               color: selected == FormData.Name
    //                                   ? enabledtxt
    //                                   : deaible,
    //                               size: 20,
    //                             ),
    //                             hintText: 'Full Name',
    //                             hintStyle: TextStyle(
    //                                 color: selected == FormData.Name
    //                                     ? enabledtxt
    //                                     : deaible,
    //                                 fontSize: 12),
    //                           ),
    //                           textAlignVertical: TextAlignVertical.center,
    //                           style: TextStyle(
    //                               color: selected == FormData.Name
    //                                   ? enabledtxt
    //                                   : deaible,
    //                               fontWeight: FontWeight.bold,
    //                               fontSize: 12),
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(
    //                       height: 20,
    //                     ),
    //                     FadeAnimation(
    //                       delay: 1,
    //                       child: Container(
    //                         width: 300,
    //                         height: 40,
    //                         decoration: BoxDecoration(
    //                           borderRadius: BorderRadius.circular(12.0),
    //                           color: selected == FormData.Phone
    //                               ? enabled
    //                               : backgroundColor,
    //                         ),
    //                         padding: const EdgeInsets.all(5.0),
    //                         child: TextField(
    //                           controller: phoneController,
    //                           onTap: () {
    //                             setState(() {
    //                               selected = FormData.Phone;
    //                             });
    //                           },
    //                           decoration: InputDecoration(
    //                             enabledBorder: InputBorder.none,
    //                             border: InputBorder.none,
    //                             prefixIcon: Icon(
    //                               Icons.phone_android_rounded,
    //                               color: selected == FormData.Phone
    //                                   ? enabledtxt
    //                                   : deaible,
    //                               size: 20,
    //                             ),
    //                             hintText: 'Phone Number',
    //                             hintStyle: TextStyle(
    //                                 color: selected == FormData.Phone
    //                                     ? enabledtxt
    //                                     : deaible,
    //                                 fontSize: 12),
    //                           ),
    //                           textAlignVertical: TextAlignVertical.center,
    //                           style: TextStyle(
    //                               color: selected == FormData.Phone
    //                                   ? enabledtxt
    //                                   : deaible,
    //                               fontWeight: FontWeight.bold,
    //                               fontSize: 12),
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(
    //                       height: 20,
    //                     ),
    //                     FadeAnimation(
    //                       delay: 1,
    //                       child: Container(
    //                         width: 300,
    //                         height: 40,
    //                         decoration: BoxDecoration(
    //                           borderRadius: BorderRadius.circular(12.0),
    //                           color: selected == FormData.Email
    //                               ? enabled
    //                               : backgroundColor,
    //                         ),
    //                         padding: const EdgeInsets.all(5.0),
    //                         child: TextField(
    //                           controller: emailController,
    //                           onTap: () {
    //                             setState(() {
    //                               selected = FormData.Email;
    //                             });
    //                           },
    //                           decoration: InputDecoration(
    //                             enabledBorder: InputBorder.none,
    //                             border: InputBorder.none,
    //                             prefixIcon: Icon(
    //                               Icons.email_outlined,
    //                               color: selected == FormData.Email
    //                                   ? enabledtxt
    //                                   : deaible,
    //                               size: 20,
    //                             ),
    //                             hintText: 'Email',
    //                             hintStyle: TextStyle(
    //                                 color: selected == FormData.Email
    //                                     ? enabledtxt
    //                                     : deaible,
    //                                 fontSize: 12),
    //                           ),
    //                           textAlignVertical: TextAlignVertical.center,
    //                           style: TextStyle(
    //                               color: selected == FormData.Email
    //                                   ? enabledtxt
    //                                   : deaible,
    //                               fontWeight: FontWeight.bold,
    //                               fontSize: 12),
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(
    //                       height: 20,
    //                     ),
    //                     FadeAnimation(
    //                       delay: 1,
    //                       child: Container(
    //                         width: 300,
    //                         height: 40,
    //                         decoration: BoxDecoration(
    //                             borderRadius: BorderRadius.circular(12.0),
    //                             color: selected == FormData.password
    //                                 ? enabled
    //                                 : backgroundColor),
    //                         padding: const EdgeInsets.all(5.0),
    //                         child: TextField(
    //                           controller: passwordController,
    //                           onTap: () {
    //                             setState(() {
    //                               selected = FormData.password;
    //                             });
    //                           },
    //                           decoration: InputDecoration(
    //                               enabledBorder: InputBorder.none,
    //                               border: InputBorder.none,
    //                               prefixIcon: Icon(
    //                                 Icons.lock_open_outlined,
    //                                 color: selected == FormData.password
    //                                     ? enabledtxt
    //                                     : deaible,
    //                                 size: 20,
    //                               ),
    //                               suffixIcon: IconButton(
    //                                 icon: ispasswordev
    //                                     ? Icon(
    //                                         Icons.visibility_off,
    //                                         color: selected == FormData.password
    //                                             ? enabledtxt
    //                                             : deaible,
    //                                         size: 20,
    //                                       )
    //                                     : Icon(
    //                                         Icons.visibility,
    //                                         color: selected == FormData.password
    //                                             ? enabledtxt
    //                                             : deaible,
    //                                         size: 20,
    //                                       ),
    //                                 onPressed: () => setState(
    //                                     () => ispasswordev = !ispasswordev),
    //                               ),
    //                               hintText: 'Password',
    //                               hintStyle: TextStyle(
    //                                   color: selected == FormData.password
    //                                       ? enabledtxt
    //                                       : deaible,
    //                                   fontSize: 12)),
    //                           obscureText: ispasswordev,
    //                           textAlignVertical: TextAlignVertical.center,
    //                           style: TextStyle(
    //                               color: selected == FormData.password
    //                                   ? enabledtxt
    //                                   : deaible,
    //                               fontWeight: FontWeight.bold,
    //                               fontSize: 12),
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(
    //                       height: 20,
    //                     ),
    //                     FadeAnimation(
    //                       delay: 1,
    //                       child: Container(
    //                         width: 300,
    //                         height: 40,
    //                         decoration: BoxDecoration(
    //                             borderRadius: BorderRadius.circular(12.0),
    //                             color: selected == FormData.ConfirmPassword
    //                                 ? enabled
    //                                 : backgroundColor),
    //                         padding: const EdgeInsets.all(5.0),
    //                         child: TextField(
    //                           controller: confirmPasswordController,
    //                           onTap: () {
    //                             setState(() {
    //                               selected = FormData.ConfirmPassword;
    //                             });
    //                           },
    //                           decoration: InputDecoration(
    //                               enabledBorder: InputBorder.none,
    //                               border: InputBorder.none,
    //                               prefixIcon: Icon(
    //                                 Icons.lock_open_outlined,
    //                                 color: selected == FormData.ConfirmPassword
    //                                     ? enabledtxt
    //                                     : deaible,
    //                                 size: 20,
    //                               ),
    //                               suffixIcon: IconButton(
    //                                 icon: ispasswordev
    //                                     ? Icon(
    //                                         Icons.visibility_off,
    //                                         color: selected ==
    //                                                 FormData.ConfirmPassword
    //                                             ? enabledtxt
    //                                             : deaible,
    //                                         size: 20,
    //                                       )
    //                                     : Icon(
    //                                         Icons.visibility,
    //                                         color: selected ==
    //                                                 FormData.ConfirmPassword
    //                                             ? enabledtxt
    //                                             : deaible,
    //                                         size: 20,
    //                                       ),
    //                                 onPressed: () => setState(
    //                                     () => ispasswordev = !ispasswordev),
    //                               ),
    //                               hintText: 'Confirm Password',
    //                               hintStyle: TextStyle(
    //                                   color:
    //                                       selected == FormData.ConfirmPassword
    //                                           ? enabledtxt
    //                                           : deaible,
    //                                   fontSize: 12)),
    //                           obscureText: ispasswordev,
    //                           textAlignVertical: TextAlignVertical.center,
    //                           style: TextStyle(
    //                               color: selected == FormData.ConfirmPassword
    //                                   ? enabledtxt
    //                                   : deaible,
    //                               fontWeight: FontWeight.bold,
    //                               fontSize: 12),
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(
    //                       height: 25,
    //                     ),
    //                     FadeAnimation(
    //                       delay: 1,
    //                       child: TextButton(
    //                           onPressed: () {},
    //                           child: Text(
    //                             "Sign Up",
    //                             style: TextStyle(
    //                               color: Colors.white,
    //                               letterSpacing: 0.5,
    //                               fontSize: 16.0,
    //                               fontWeight: FontWeight.bold,
    //                             ),
    //                           ),
    //                           style: TextButton.styleFrom(
    //                               backgroundColor: const Color(0xFF2697FF),
    //                               padding: const EdgeInsets.symmetric(
    //                                   vertical: 14.0, horizontal: 80),
    //                               shape: RoundedRectangleBorder(
    //                                   borderRadius:
    //                                       BorderRadius.circular(12.0)))),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),

    //             //End of Center Card
    //             //Start of outer card
    //             const SizedBox(
    //               height: 20,
    //             ),

    //             FadeAnimation(
    //               delay: 1,
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   const Text("If you have an account ",
    //                       style: TextStyle(
    //                         color: Colors.grey,
    //                         letterSpacing: 0.5,
    //                       )),
    //                   GestureDetector(
    //                     onTap: () {
    //                       Navigator.pop(context);
    //                       // Navigator.of(context)
    //                       //     .push(MaterialPageRoute(builder: (context) {
    //                       //   return LoginScreen();
    //                       // }));
    //                     },
    //                     child: Text("Sing in",
    //                         style: TextStyle(
    //                             color: Colors.white.withOpacity(0.9),
    //                             fontWeight: FontWeight.bold,
    //                             letterSpacing: 0.5,
    //                             fontSize: 14)),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
