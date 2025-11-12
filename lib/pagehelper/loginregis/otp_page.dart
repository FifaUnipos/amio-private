import 'dart:convert';
import 'dart:developer';

import 'package:unipos_app_335/utils/component/component_loading.dart';

import '../../main.dart';
import '../../pageTablet/tokopage/dashboardtoko.dart';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../utils/component/component_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../pageTablet/home/dashboard.dart';
import '../../services/apimethod.dart';
import '../../services/notification.dart';

import '../../utils/component/component_appbar.dart';
import 'login_page.dart';
import 'register_page.dart';

class Otppage extends StatefulWidget {
  //pass
  final String phone, name, email, pageidentify;
  const Otppage(this.phone, this.name, this.email, this.pageidentify,
      {super.key});

  @override
  State<Otppage> createState() => _OtppageState();
}

class _OtppageState extends State<Otppage> {
  OtpFieldController otpController = OtpFieldController();
  TextEditingController textEditingController = TextEditingController();
  String currentText = "";
  final formKey = GlobalKey<FormState>();
  // String otpfix = '';

  final interval = const Duration(seconds: 1);

  final int timerMaxSeconds = 120;

  int currentSeconds = 0;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout([int? milliseconds]) {
    var duration = interval;
    Timer.periodic(duration, (timer) {
      setState(() {
        // print(timer.tick);
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) timer.cancel();
      });
    });
  }

  String hidePhoneNumber(String phoneNumber) {
    int visibleDigits = 4;
    int length = phoneNumber.length;

    if (length <= visibleDigits) {
      return '*' * length;
    }

    String hiddenPart = phoneNumber
        .substring(0, length - visibleDigits)
        .replaceAll(RegExp(r'\d'), '*');
    String visiblePart = phoneNumber.substring(length - visibleDigits);

    return '$hiddenPart$visiblePart';
  }

  late String phoneNumber;

  @override
  void initState() {
    phoneNumber = hidePhoneNumber(widget.phone);
    startTimeout();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bnw100,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              appbar(context, false),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: SvgPicture.asset(
                          'assets/newIllustration/KodeOTP.svg',
                        ),
                      ),
                      SizedBox(width: size16),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: const ScrollBehavior()
                              .copyWith(overscroll: false),
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.only(bottom: size16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Masukkan Kode Verifikasi',
                                  style: heading1(
                                      FontWeight.w700, bnw900, 'Outfit'),
                                ),
                                Text(
                                  'Kode Verifikasi (OTP) sudah dikirim ke nomor telepon anda $phoneNumber',
                                  textAlign: TextAlign.center,
                                  style: heading3(
                                      FontWeight.w400, bnw500, 'Outfit'),
                                ),
                                SizedBox(height: size32),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 103),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Form(
                                          key: formKey,
                                          child: PinCodeTextField(
                                            appContext: context,
                                            animationType: AnimationType.fade,
                                            length: 6,
                                            errorTextSpace: 0,
                                            pinTheme: PinTheme(
                                              activeColor: errorText.isEmpty
                                                  ? primary500
                                                  : red500,
                                              inactiveColor: bnw300,
                                              selectedColor: primary500,
                                              selectedBorderWidth: 2,
                                              inactiveBorderWidth: 1,
                                            ),
                                            cursorColor: primary500,
                                            controller: textEditingController,
                                            keyboardType: TextInputType.number,
                                            textStyle: heading1(FontWeight.w700,
                                                bnw900, 'Outfit'),
                                            onCompleted: (pin) {
                                              print("Completed: " + pin);
                                              if (widget.pageidentify ==
                                                  'login_page') {
                                                print('login');
                                                login(pin);
                                                print('login_succes');
                                              } else if (widget.pageidentify ==
                                                  'register_page') {
                                                registErentryOtp(pin);
                                                print('register_succes');
                                              } else if (widget.pageidentify ==
                                                  'public_register_page') {
                                                globalRegisterEntry(pin);
                                              } else if (widget.pageidentify ==
                                                  'forgotPass') {
                                                changePasswordVerify(
                                                    context, userId, pin);
                                              }
                                            },
                                            onChanged: (value) {
                                              debugPrint(value);
                                              errorText = '';
                                              setState(() {
                                                currentText = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: errorText.isNotEmpty
                                              ? size16
                                              : 0),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          errorText.isNotEmpty ? errorText : '',
                                          style: heading4(FontWeight.w500,
                                              red500, 'Outfit'),
                                        ),
                                      ),
                                      SizedBox(
                                          height: errorText.isNotEmpty
                                              ? size16
                                              : 0),
                                      SizedBox(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Waktu kirim ulang : ',
                                              style: heading4(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (widget.pageidentify ==
                                                    'login_page') {
                                                  getOtpAgain();
                                                } else if (widget
                                                        .pageidentify ==
                                                    'register_page') {
                                                  registerAgain();
                                                } else if (widget
                                                        .pageidentify ==
                                                    'global_register_page') {}
                                                // log(timerText);
                                              },
                                              child: timerText == '00: 00'
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        getOtpAgain();
                                                        startTimeout();
                                                      },
                                                      // onTap: () => registerAgain(),
                                                      child: Text(
                                                        'Kirim Ulang Code',
                                                        style: heading4(
                                                            FontWeight.w600,
                                                            primary500,
                                                            'Outfit'),
                                                      ),
                                                    )
                                                  : Row(
                                                      children: [
                                                        SizedBox(
                                                          height: 8,
                                                          width: 8,
                                                          child:
                                                              const CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          timerText,
                                                          style: body1(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future registErentryOtp(pin) async {
    try {
      whenLoading(context);
      final response = await http.post(
        Uri.parse(registerentryotp),
        body: {
          'phonenumber': widget.phone,
          'otp': pin,
          'deviceid': identifier.toString(),
        },
      );
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("succes aman tentram register");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', jsonResponse['token'].toString());
        prefs.setString('deviceid', identifier.toString());
        prefs.setString('roleAccount', jsonResponse['type_role'].toString());
        prefs.setString('typeAccount', jsonResponse['type_account'].toString());
        // prefs.setString('typeAccount', 'Merchant');

        dashboardKulasedaya(jsonResponse['token']);

        roleAccount = prefs.getString('roleAccount');
        typeAccount = prefs.getString('typeAccount');

        myprofile(jsonResponse['token']);
        if (jsonResponse['token'] != null) {
          sessionPage(
            context,
            jsonResponse['token'].toString(),
            jsonResponse['type_account'],
            jsonResponse['type_role'],
          );
        }
        closeLoading(context);
      } else {
        // dialogError(context, jsonResponse['message'], jsonResponse['rc']);
        errorText = jsonResponse['message'];
        closeLoading(context);
      }
      return null;
    } catch (e) {
      closeLoading(context);
      throw Exception(e.toString());
    }
  }

  Future registerAgain() async {
    try {
      Map<String, String?> bodyEmail = {
        'type': 'Group_Merchant',
        'deviceid': identifier,
        'phonenumber': widget.phone,
        'fullname': widget.name,
        'email': widget.email,
      };

      final response = await http.post(
        Uri.parse(registerLink),
        body: bodyEmail,
      );
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        errorText = '';
        print("succes kirim otp");
        print(jsonResponse['data']);
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future login(otp) async {
    try {
      showDialog(
          barrierDismissible: false,
          useRootNavigator: true,
          context: context,
          builder: (context) {
            return const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
            );
          });

      final response = await http.post(
        Uri.parse(loginentryotp),
        body: {
          'phonenumber': widget.phone,
          'otp': otp,
          'deviceid': identifier.toString(),
        },
      );

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("succes aman tentram login");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', jsonResponse['token'].toString());
        prefs.setString('deviceid', identifier.toString());
        prefs.setString('roleAccount', jsonResponse['type_role'].toString());
        prefs.setString('typeAccount', jsonResponse['type_account'].toString());
        // prefs.setString('typeAccount', 'Merchant');

        dashboardKulasedaya(jsonResponse['token']);

        roleAccount = prefs.getString('roleAccount');
        typeAccount = prefs.getString('typeAccount');

        //log(jsonResponse);

        myprofile(jsonResponse['token']);

        if (jsonResponse['token'] != null) {
          Future.delayed(
            const Duration(seconds: 3),
            () {
              Navigator.of(context, rootNavigator: true).pop();
              sessionPage(
                context,
                jsonResponse['token'].toString(),
                jsonResponse['type_account'],
                jsonResponse['type_role'],
              );
            },
          );
        }

        errorText = '';
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        errorText = jsonResponse['message'];
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future getOtpAgain() async {
    try {
      var response = await Dio().post(loginbyotp, data: {
        'phonenumber': widget.phone,
        'deviceid': identifier,
      });
      print(widget.phone);
      if (response.statusCode == 200) {
        errorText = '';
        print("succes");
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future globalRegisterEntry(pin) async {
    try {
      whenLoading(context);
      final response = await http.post(
        Uri.parse(registerentryotp),
        body: {
          'phonenumber': widget.phone,
          'otp': pin,
          'deviceid': identifier.toString(),
        },
      );
      var jsonResponse = jsonDecode(response.body);

      log(jsonDecode(response.body).toString());

      if (response.statusCode == 200) {
        print("succes");
        errorText = '';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', jsonResponse['token'].toString());
        prefs.setString('deviceid', identifier.toString());
        prefs.setString('roleAccount', jsonResponse['type_role'].toString());
        prefs.setString('typeAccount', jsonResponse['type_account'].toString());
        // prefs.setString('typeAccount', 'Merchant');

        dashboardKulasedaya(jsonResponse['token']);

        roleAccount = prefs.getString('roleAccount');
        typeAccount = prefs.getString('typeAccount');
        myprofile(jsonResponse['token']);

        // ignore: use_build_context_synchronously
        if (jsonResponse['token'] != null) {
          sessionPage(
            context,
            jsonResponse['token'].toString(),
            jsonResponse['type_account'],
            jsonResponse['type_role'],
          );
        }
        closeLoading(context);
      } else {
        // dialogError(context, jsonResponse['message'], jsonResponse['rc']);
        closeLoading(context);
        errorText = jsonResponse['message'];
      }
      return null;
    } catch (e) {
      closeLoading(context);
      throw Exception(e.toString());
    }
  }
}
