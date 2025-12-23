import 'dart:convert';
import 'dart:developer';

import 'package:unipos_app_335/pageMobile/pageHelperMobile/masukAkunMobile.dart';

import '../masukakun.dart';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:hash_password/password_hasher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../utils/component/component_loading.dart';
import 'package:unipos_app_335/main.dart';
import '../../../../utils/component/component_color.dart';
import '../../pageTablet/home/dashboard.dart';
import '../../pageTablet/tokopage/dashboardtoko.dart';
import '../../services/apimethod.dart';
import '../../services/notification.dart';
import '../daftarAkun.dart';
import 'lupaSandiPage/lupa_sandi.dart';
import 'otp_page.dart';
import 'register_page.dart';
import '../../../../../utils/component/component_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusScopeNode _focusScopeNode = FocusScopeNode();

  var phoneEmailController = TextEditingController();
  var pass, email;
  var name = 'login';

  bool _validate = false;

  Color onOffButton = bnw300;

  String validated = '';

  @override
  void dispose() {
    phoneEmailController.dispose();
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
          padding: EdgeInsets.symmetric(horizontal: size32),
          child: Column(
            children: [
              SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MasukAkunPage(),
                          ),
                        ),
                        child: Icon(
                          PhosphorIcons.arrow_left,
                          size: size40,
                          color: bnw900,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          helpQuestionShow(context);
                        },
                        child: Icon(
                          PhosphorIcons.question,
                          size: size40,
                          color: bnw900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size12),
                  child: Row(
                    children: [
                      Expanded(
                        child: SvgPicture.asset(
                          'assets/newIllustration/Login.svg',
                        ),
                      ),
                      SizedBox(width: size16),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollBehavior().copyWith(
                            overscroll: false,
                          ),
                          child: Container(
                            child: SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: EdgeInsets.only(bottom: size16),
                              child: IntrinsicHeight(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Masuk',
                                      style: heading1(
                                        FontWeight.w700,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                    Text(
                                      'Masukkan nomor telepon atau email yang telah terdaftar.',
                                      style: heading3(
                                        FontWeight.w500,
                                        bnw500,
                                        'Outfit',
                                      ),
                                    ),
                                    SizedBox(height: size24),
                                    Row(
                                      children: [
                                        Text(
                                          'Nomor Telpon / Email ',
                                          style: heading4(
                                            FontWeight.w500,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        Text(
                                          '*',
                                          style: heading4(
                                            FontWeight.w700,
                                            red500,
                                            'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      child: IntrinsicHeight(
                                        child: TextFormField(
                                          // focusNode: _focusScopeNode,
                                          style: heading2(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              if (value.contains('@') ||
                                                  value.endsWith('.com')) {
                                                validated = 'email';
                                                onOffButton = primary500;
                                              } else if (value.startsWith(
                                                    '08',
                                                  ) ||
                                                  value.length < 10) {
                                                validated = 'number';
                                                onOffButton = primary500;
                                              }
                                            });
                                          },
                                          cursorColor: primary500,
                                          controller: phoneEmailController,
                                          decoration: InputDecoration(
                                            errorText: _validate
                                                ? errorText
                                                : null,
                                            errorStyle: body1(
                                              FontWeight.w500,
                                              red500,
                                              'Outfit',
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                width: 2,
                                                color: primary500,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    width: 2,
                                                    color: red500,
                                                  ),
                                                ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: size12,
                                                ),
                                            hintText:
                                                'Cth : 08123456789 / nabil@email.com ',
                                            hintStyle: heading2(
                                              FontWeight.w600,
                                              bnw400,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size32),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            errorText = '';
                                            _focusScopeNode.unfocus();
                                            if (validated == 'number') {
                                              getOtp(
                                                Otppage(
                                                  phoneEmailController.text,
                                                  name.toString(),
                                                  // pass.toString(),
                                                  email.toString(),
                                                  'login_page',
                                                ),
                                              );
                                            } else if (validated == 'email') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginWithEmail(
                                                        email:
                                                            phoneEmailController
                                                                .text,
                                                      ),
                                                ),
                                              );
                                              // getOtpEmail(
                                              // );
                                            }
                                          });
                                        },
                                        child: buttonXXLonOff(
                                          Center(
                                            child: Text(
                                              'Masuk',
                                              style: heading2(
                                                FontWeight.w600,
                                                bnw100,
                                                'Outfit',
                                              ),
                                            ),
                                          ),
                                          double.infinity,
                                          onOffButton,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size32),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Belum Memiliki Akun?',
                                          style: heading4(
                                            FontWeight.w500,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        SizedBox(width: size12),
                                        GestureDetector(
                                          // onTap: () async => getOtp(),
                                          onTap: () =>
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DaftarAkunPage(),
                                                ),
                                              ),
                                          child: Text(
                                            'Daftar',
                                            style: heading4(
                                              FontWeight.w500,
                                              primary500,
                                              'Outfit',
                                            ),
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

  Future getOtp(page) async {
    whenLoading(context);
    final response = await http.post(
      Uri.parse(loginbyotp),
      body: {
        // 'phonenumber': '085947737725',
        'phonenumber': phoneEmailController.text,
        'deviceid': identifier.toString(),
      },
    );
    var jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop();
      print(jsonResponse['data']);
      print("succes");
      _validate = false;
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    } else {
      setState(() {
        closeLoading(context);
        errorText = jsonResponse['message'];
        _validate = true;
      });
    }
  }

  Future getOtpEmail(page) async {
    try {
      var response = await Dio().post(
        checkpass,
        data: {
          // 'phonenumber': '085947737725',
          'deviceid': identifier.toString(),
          'email': phoneEmailController.text,
        },
      );
      print(phoneEmailController);
      if (response.statusCode == 200) {
        print("succes");
        if (response.data['data'][1]) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

//! ------------------- Login Email --------------------------- !//

class LoginWithEmail extends StatefulWidget {
  String email;
  LoginWithEmail({Key? key, required this.email}) : super(key: key);

  @override
  State<LoginWithEmail> createState() => _LoginWithEmailState();
}

class _LoginWithEmailState extends State<LoginWithEmail> {
  TextEditingController passController = TextEditingController();
  bool _obscureText = true;
  bool _validate = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size32),
        child: Column(
          children: [
            SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: size12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MasukAkunPageMobile(),
                        ),
                      ),
                      child: Icon(
                        PhosphorIcons.arrow_left,
                        size: size32,
                        color: bnw900,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        helpQuestionShow(context);
                      },
                      child: Icon(
                        PhosphorIcons.question,
                        size: size32,
                        color: bnw900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: size12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: SvgPicture.asset(
                          'assets/newIllustration/Login.svg',
                        ),
                      ),
                    ),
                    SizedBox(width: size16),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollBehavior().copyWith(overscroll: false),
                        child: Container(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.only(bottom: size16),
                            child: IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Masukkan Kata Sandi',
                                    style: heading1(
                                      FontWeight.w700,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                  Text(
                                    'Masukkan kata sandi anda.',
                                    style: heading3(
                                      FontWeight.w500,
                                      bnw500,
                                      'Outfit',
                                    ),
                                  ),
                                  SizedBox(height: size24),
                                  Row(
                                    children: [
                                      Text(
                                        'Kata Sandi ',
                                        style: heading4(
                                          FontWeight.w500,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      Text(
                                        '*',
                                        style: heading4(
                                          FontWeight.w700,
                                          red500,
                                          'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    child: IntrinsicHeight(
                                      child: TextFormField(
                                        style: heading2(
                                          FontWeight.w600,
                                          bnw900,
                                          'Outfit',
                                        ),
                                        cursorColor: primary500,
                                        controller: passController,
                                        obscureText: _obscureText,
                                        obscuringCharacter: '*',
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          errorText: _validate
                                              ? errorText
                                              : null,
                                          errorStyle: body1(
                                            FontWeight.w500,
                                            red500,
                                            'Outfit',
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 2,
                                              color: primary500,
                                            ),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              !_obscureText
                                                  ? PhosphorIcons.eye_closed
                                                  : PhosphorIcons.eye,
                                              color: bnw900,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureText = !_obscureText;
                                                print(_obscureText);
                                              });
                                            },
                                          ),
                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 2,
                                                  color: red500,
                                                ),
                                              ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: size12,
                                          ),
                                          hintText: 'Masukkan Kata Sandi',
                                          hintStyle: heading2(
                                            FontWeight.w600,
                                            bnw400,
                                            'Outfit',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        // onTap: () async => getOtp(),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ForgotPasswordPage(),
                                          ),
                                        ),
                                        child: Text(
                                          'Lupa Kata Sandi',
                                          style: heading4(
                                            FontWeight.w500,
                                            primary500,
                                            'Outfit',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size32),
                                  GestureDetector(
                                    onTap: () {
                                      loginEmail();
                                    },
                                    child: buttonXXL(
                                      Center(
                                        child: Text(
                                          'Masuk',
                                          style: heading2(
                                            FontWeight.w600,
                                            bnw100,
                                            'Outfit',
                                          ),
                                        ),
                                      ),
                                      double.infinity,
                                      // onOffButton,
                                    ),
                                  ),
                                  SizedBox(height: size32),
                                ],
                              ),
                            ),
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
    );
  }

  Future loginEmail() async {
    try {
      whenLoading(context);

      final response = await http.post(
        Uri.parse(loginEmailLink),
        body: {
          'deviceid': identifier,
          'email': widget.email,
          'password': passController.text,
        },
      );
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("succes login with email");

        myprofile(jsonResponse['token']);
        // late FirebaseMessaging messaging;
        // messaging = FirebaseMessaging.instance;
        // messaging.getToken().then((value) {
        //   setState(() {
        //     print("firebase token : $value");
        //     firebaseToken(value, jsonResponse['token']);
        //   });
        // });
        // final NotifFCM = FCM();

        // NotifFCM.setNotifiications();
        Future.delayed(const Duration(seconds: 3), () {
          closeLoading(context);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => merchantType == 'Group_Merchant'
                  ? SidebarXExampleApp(
                      id: identifier.toString(),
                      token: jsonResponse['token'],
                    )
                  : SidebarXExampleAppToko(
                      token: jsonResponse['token'],
                      id: identifier.toString(),
                    ),
            ),
            (Route<dynamic> route) => false,
          );
        });

        print(jsonResponse['data']);

        _validate = false;
        errorText = '';
      } else {
        setState(() {
          closeLoading(context);
          errorText = jsonResponse['message'];
          _validate = true;
        });
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
