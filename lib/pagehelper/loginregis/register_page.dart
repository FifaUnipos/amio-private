import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;
import '../../services/apimethod.dart';
import '../../utils/component/component_appbar.dart';
import 'login_page.dart';
import '../../../../utils/component/component_loading.dart';
import 'otp_page.dart';
import '../../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var phoneController = TextEditingController();
  var nameController = TextEditingController();
  // var passController = TextEditingController();
  var emailController = TextEditingController();

  Color onOffButton = bnw300;

  String emailError = '';

  refreshText() {
    emailError = '';
    errorText = '';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: bnw100,

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: size32),
          child: Column(
            children: [
              appbar(context, false),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SvgPicture.asset(
                        'assets/newIllustration/SignUpGrupToko.svg',
                      ),
                    ),
                    SizedBox(width: size16),
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daftar Sebagai Grup Toko',
                              style:
                                  heading1(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                            Text(
                              'Isikan data anda dengan lengkap',
                              style:
                                  heading3(FontWeight.w500, bnw500, 'Outfit'),
                            ),
                            SizedBox(height: size24),
                            Row(
                              children: [
                                Text(
                                  'Nama Lengkap ',
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                                Text(
                                  '*',
                                  style: heading4(
                                      FontWeight.w700, red500, 'Outfit'),
                                ),
                              ],
                            ),
                            fieldMethod('Cth : Muhammad Nabil Musyaffa',
                                nameController),
                            SizedBox(height: size16),
                            Row(
                              children: [
                                Text(
                                  'Nomor Telepon ',
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                                Text(
                                  '*',
                                  style: heading4(
                                      FontWeight.w700, red500, 'Outfit'),
                                ),
                              ],
                            ),
                            fieldMethodPhone('08123456789', phoneController),
                            SizedBox(height: size16),
                            Text(
                              'Email',
                              style:
                                  heading4(FontWeight.w400, bnw900, 'Outfit'),
                            ),
                            fieldMethod(
                                'Cth: nabil@gmail.com', emailController),
                            // emailError.isNotEmpty
                            //     ? Column(
                            //         children: [
                            //           SizedBox(height: size16),
                            //           Text(
                            //             emailError.isNotEmpty ? emailError : '',
                            //             style: heading4(
                            //                 FontWeight.w500, red500, 'Outfit'),
                            //           ),
                            //         ],
                            //       )
                            //     : SizedBox(),
                            SizedBox(height: size48),
                            Column(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: GestureDetector(
                                    onTap: () {
                                      refreshText();
                                      if (onOffButton == primary500) {
                                        register(
                                          context,
                                          Otppage(
                                            phoneController.text,
                                            nameController.text,
                                            // passController.text,
                                            emailController.text,
                                            'register_page',
                                          ),
                                        );
                                      }
                                    },
                                    child: buttonXXLonOff(
                                      Center(
                                        child: Text(
                                          'Daftar',
                                          style: heading2(FontWeight.w600,
                                              bnw100, 'Outfit'),
                                        ),
                                      ),
                                      double.infinity,
                                      onOffButton,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Sudah Memiliki Akun?',
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                    SizedBox(width: size12),
                                    GestureDetector(
                                      onTap: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                      ),
                                      child: Text(
                                        'Masuk',
                                        style: heading4(FontWeight.w400,
                                            primary500, 'Outfit'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox fieldMethod(String text, mycontroller) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
        onChanged: (value) {
          setState(() {
            refreshText();
            if (value.contains('@') || value.endsWith('.com')) {
              onOffButton = primary500;
            } else if (value.startsWith('08') || value.length < 10) {
              onOffButton = primary500;
            }
          });
        },
        controller: mycontroller,
        decoration: InputDecoration(
          focusColor: primary500,
          contentPadding: EdgeInsets.symmetric(vertical: size12),
          hintText: text,
          hintStyle: heading2(FontWeight.w600, bnw400, 'Outfit'),
          errorStyle: body1(FontWeight.w500, red500, 'Outfit'),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: primary500,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: bnw400,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: red500,
            ),
          ),
        ),
      ),
    );
  }

  fieldMethodPhone(String text, mycontroller) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        cursorColor: primary500,
        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            refreshText();
            if (value.contains('@') || value.endsWith('.com')) {
              onOffButton = primary500;
            } else if (value.startsWith('08') && value.length >= 8) {
              onOffButton = primary500;
            } else {
              onOffButton = bnw300;
            }
          });
        },
        controller: mycontroller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: size12),
          hintText: text,
          hintStyle: heading2(FontWeight.w600, bnw400, 'Outfit'),
          errorStyle: body1(FontWeight.w500, red500, 'Outfit'),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: primary500,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: bnw400,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: red500,
            ),
          ),
        ),
      ),
    );
  }

  Future register(context, page) async {
    whenLoading(context);
    Map<String, String?> bodyEmail = {
      'type': 'Group_Merchant',
      'deviceid': identifier,
      'phonenumber': phoneController.text,
      'fullname': nameController.text,
      'email': emailController.text,
    };

    if (emailController.text.isEmpty) {
      bodyEmail.remove('email');
    } else {
      bodyEmail['email'] = emailController.text;
    }

    final response = await http.post(
      Uri.parse(registerLink),
      body: bodyEmail,
    );
    var jsonResponse = jsonDecode(response.body);

    print(jsonResponse['data']);
    if (response.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop();
      print("succes");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page,
        ),
      );
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      emailError = jsonResponse['data']['email'];
      showSnackbar(context, jsonResponse);
    }
    setState(() {});
    return null;
  }
}
