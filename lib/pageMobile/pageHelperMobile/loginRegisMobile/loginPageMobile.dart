import 'dart:convert';

import 'package:unipos_app_335/pagehelper/loginregis/login_page.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/services/config/app_endpoints.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';

import '../../../main.dart';
import 'otpPageMobile.dart';
import 'package:http/http.dart' as http;
import '../../dashboardMobile.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../utils/component/component_color.dart';
import '../../../utils/component/component_appbar.dart';
import '../../../../../utils/component/component_button.dart';
import '../../../../components/atoms/button/unipos_button.dart';

class LoginPageMobile extends StatefulWidget {
  const LoginPageMobile({super.key});

  @override
  State<LoginPageMobile> createState() => _LoginPageMobileState();
}

class _LoginPageMobileState extends State<LoginPageMobile> {
  TextEditingController phoneEmailCon = TextEditingController();

  bool _validate = false;
  bool _isLoading = false;

  String validated = '';

  @override
  void dispose() {
    phoneEmailCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(size16, 0, size16, size32),
          child: Column(
            children: [
              appbarMobile(context, false),
              SizedBox(height: size16),
              Expanded(
                child: SvgPicture.asset('assets/newIllustration/Login.svg'),
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
                              'Masuk',
                              style: heading2(
                                FontWeight.w700,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            Text(
                              'Masukkan nomor telepon atau email yang telah terdaftar.',
                              style: body2(FontWeight.w400, bnw700, 'Outfit'),
                            ),
                            SizedBox(height: size24),
                            Row(
                              children: [
                                Text(
                                  'Nomor Telepon / Email ',
                                  style: body2(
                                    FontWeight.w400,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Text(
                                  '*',
                                  style: body2(
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
                                  onChanged: (value) {
                                    setState(() {
                                      errorText = '';
                                      _validate = false;
                                      if (value.contains('@')) {
                                        validated = 'email';
                                      } else if (value.startsWith('08') ||
                                          value.length < 10) {
                                        validated = 'number';
                                      }
                                    });
                                  },
                                  cursorColor: primary500,
                                  controller: phoneEmailCon,
                                  decoration: InputDecoration(
                                    errorText: _validate ? errorText : null,
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
                                    focusedErrorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: red500,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: UniposButton(
                  text: 'Berikutnya',
                  loading: _isLoading,
                  onTap: phoneEmailCon.text.isEmpty
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                            errorText = '';
                            emailProfile = phoneEmailCon.text;
                          });

                          if (validated == 'number') {
                            await getOtp(
                              OtpPageMobile(
                                phone: phoneEmailCon.text,
                                name: '',
                                email: '',
                                pageidentify: 'login_page',
                              ),
                            );
                          } else if (validated == 'email') {
                            try {
                              final value = await checkEmail(checkToken, setState);
                              if (value == '00') {
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginWithEmail(
                                      email: phoneEmailCon.text,
                                    ),
                                  ),
                                );
                              } else {
                                setState(() {
                                  errorText = 'Email tidak terdaftar';
                                  _validate = true;
                                });
                              }
                            } catch (e) {
                              if (mounted) {
                                showSnackbar(context, {
                                  "message": "Terjadi kesalahan: ${e.toString()}"
                                });
                              }
                            }
                          }
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                ),
              ),
              SizedBox(height: size16),
            ],
          ),
        ),
      ),
    );
  }

  Future getOtp(page) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.loginbyotp),
        body: {
          // 'phonenumber': '085947737725',
          'phonenumber': phoneEmailCon.text,
          'deviceid': identifier.toString(),
        },
      );
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print(jsonResponse['data']);
        print("succes");
        _validate = false;
        // ignore: use_build_context_synchronously
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      } else {
        setState(() {
          errorText = jsonResponse['message'];
          _validate = true;
        });
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, {
          "rc": "99",
          "message": "Terjadi kesalahan jaringan atau server."
        });
      }
    }
  }

  // Future getOtpEmail(page) async {
  //   try {
  //     var response = await Dio().post(data: {
  //       // 'phonenumber': '085947737725',
  //       'deviceid': identifier,
  //       'email': phoneEmailController.text,
  //     });
  //     print(phoneEmailController);
  //     if (response.statusCode == 200) {
  //       print("succes");
  //       if (response.data['data'][1]) {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => page,
  //           ),
  //         );
  //       }
  //     }
  //     return null;
  //   } catch (e) {
  //     throw Exception(e.toString());
  //   }
  // }
}
