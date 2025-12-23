import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/component/component_color.dart';
import '../../../main.dart';
import '../../../services/apimethod.dart';
import '../../../services/notification.dart';

import '../../../utils/component/component_appbar.dart';

class OtpPageMobile extends StatefulWidget {
  String phone, name, email, pageidentify;
  OtpPageMobile({
    Key? key,
    required this.phone,
    required this.name,
    required this.email,
    required this.pageidentify,
  }) : super(key: key);

  @override
  State<OtpPageMobile> createState() => _OtpPageMobileState();
}

class _OtpPageMobileState extends State<OtpPageMobile> {
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
    String hiddenPart = phoneNumber
        .substring(0, length - visibleDigits)
        .replaceAll(RegExp(r'\d'), '*');
    String visiblePart = phoneNumber.substring(length - visibleDigits);

    return '$hiddenPart$visiblePart';
  }

  @override
  void initState() {
    startTimeout();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(size16),
        child: Column(
          children: [
            appbarMobile(context, false),
            SizedBox(height: size16),
            Expanded(
              child: SvgPicture.asset('assets/newIllustration/KodeOTP.svg'),
            ),
            SizedBox(width: size16),
            Expanded(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(bottom: size16),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Masukkan Kode Verifikasi',
                          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                        ),
                        Text(
                          'Kode Verifikasi (OTP) sudah dikirim ke nomor telepon yang telah anda daftarkan yaitu ${hidePhoneNumber(widget.phone)}',
                          textAlign: TextAlign.center,
                          style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                        ),
                        SizedBox(height: size16),
                        Column(
                          children: [
                            Container(
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
                                  selectedBorderWidth: 2,
                                  inactiveBorderWidth: 1,
                                ),
                                cursorColor: primary500,
                                // controller: textEditingController,
                                keyboardType: TextInputType.number,
                                textStyle: heading1(
                                  FontWeight.w700,
                                  bnw900,
                                  'Outfit',
                                ),
                                onCompleted: (pin) {
                                  print("Completed: " + pin);
                                  if (widget.pageidentify == 'login_page') {
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
                                  }
                                },
                                onChanged: (value) {
                                  debugPrint(value);
                                  errorText = '';
                                  setState(() {
                                    // currentText = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: errorText.isNotEmpty ? size16 : 0),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                errorText.isNotEmpty ? errorText : '',
                                style: heading4(
                                  FontWeight.w500,
                                  red500,
                                  'Outfit',
                                ),
                              ),
                            ),
                            SizedBox(height: errorText.isNotEmpty ? size16 : 0),
                            SizedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Waktu kirim ulang : ',
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // if (widget.pageidentify ==
                                      //     'login_page') {
                                      //   getOtpAgain();
                                      // } else if (widget
                                      //         .pageidentify ==
                                      //     'register_page') {
                                      //   registerAgain();
                                      // } else if (widget
                                      //         .pageidentify ==
                                      //     'global_register_page') {}
                                      // log(timerText);
                                    },
                                    child: timerText == '00: 00'
                                        ? GestureDetector(
                                            onTap: () {
                                              // getOtpAgain();
                                              startTimeout();
                                            },
                                            // onTap: () => registerAgain(),
                                            child: Text(
                                              'Kirim Ulang Code',
                                              style: heading4(
                                                FontWeight.w600,
                                                primary500,
                                                'Outfit',
                                              ),
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
                                                  'Outfit',
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future registErentryOtp(pin) async {
    try {
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
        print("success");

        errorText = '';

        // Menggunakan Future.delayed untuk navigasi setelah 3 detik
        if (jsonResponse.containsKey('token') &&
            jsonResponse['token'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', jsonResponse['token']);
          checkToken = jsonResponse['token'];
          String token = jsonResponse['token'];

          // Ignore: use_build_context_synchronously
          myprofile(token);

          // late FirebaseMessaging messaging;
          // messaging = FirebaseMessaging.instance;

          // messaging.getToken().then((value) {
          //   setState(() {
          //     print("firebase token : $value");
          //     firebaseToken(value, token);
          //   });
          // });

          // final NotifFCM = FCM();
          // NotifFCM.setNotifiications();

          showDialog(
            barrierDismissible: true,
            useRootNavigator: true,
            context: context,
            builder: (context) {
              Future.delayed(const Duration(seconds: 3), () {
                // Navigasi setelah 3 detik
                sessionPageMobile(
                  context,
                  token,
                  jsonResponse['type_account'],
                  jsonResponse['type_role'],
                );
              });

              return const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        } else {
          print("Token tidak ditemukan di response");
          errorText = 'Token tidak ditemukan';
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        // Menampilkan error berdasarkan response message
        errorText = jsonResponse['message'] ?? 'Terjadi kesalahan';
      }

      return null;
    } catch (e) {
      // Menangani error dengan lebih jelas
      print('Error: ${e.toString()}');
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future getOtpAgain() async {
    try {
      var response = await Dio().post(
        loginbyotp,
        data: {'phonenumber': widget.phone, 'deviceid': identifier},
      );
      print(widget.phone);
      if (response.statusCode == 200) {
        print("succes");
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future registerAgain() async {
    try {
      var response = await Dio().post(
        registerbyotp,
        data: {
          'phonenumber': widget.phone,
          'fullname': widget.name,
          // 'password': widget.pass,
          'email': widget.email,
          'deviceid': identifier.toString(),
        },
      );

      if (response.statusCode == 200) {
        print("succes");
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
        },
      );

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
        prefs.setString('token', jsonResponse['token']);
        prefs.setString('deviceid', identifier.toString());
        checkToken = jsonResponse['token'];

        myprofile(jsonResponse['token']);

        if (jsonResponse['token'] != null) {
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.of(context, rootNavigator: true).pop();
            sessionPageMobile(
              context,
              jsonResponse['token'].toString(),
              jsonResponse['type_account'],
              jsonResponse['type_role'],
            );
          });
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

  Future globalRegisterEntry(pin) async {
    try {
      final response = await http.post(
        Uri.parse(registerGlobalMerchEntry),
        body: {'phonenumber': widget.phone, 'otp': pin, 'deviceid': identifier},
      );
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("succes");
        errorText = '';
      } else {
        // dialogError(context, jsonResponse['message'], jsonResponse['rc']);
        errorText = jsonResponse['message'];
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
