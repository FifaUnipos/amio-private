import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import 'package:unipos_app_335/utils/component/component_snackbar.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';

import 'metode_sandi.dart';
import '../../../services/apimethod.dart';
import '../../../../utils/component/component_color.dart';

import '../../daftarAkun.dart';
import '../../masukakun.dart';
import '../login_page.dart';
import '../otp_page.dart';import '../../../../../utils/component/component_button.dart';

class BuatSandiBaruPage extends StatefulWidget {
  String userid;
  BuatSandiBaruPage({
    Key? key,
    required this.userid,
  }) : super(key: key);

  @override
  State<BuatSandiBaruPage> createState() => _BuatSandiBaruPageState();
}

class _BuatSandiBaruPageState extends State<BuatSandiBaruPage> {
  FocusScopeNode _focusScopeNode = FocusScopeNode();

  var phoneEmailController = TextEditingController();
  var phoneEmailController2 = TextEditingController();
  bool _obscureText = true, _obscureText2 = true;
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
                                builder: (context) => LoginPage(),
                              )),
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
                      ]),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size12),
                  child: Row(
                    children: [
                      Expanded(
                        child: SvgPicture.asset(
                          'assets/newIllustration/KodeOTP.svg',
                        ),
                      ),
                      SizedBox(width: size16),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior:
                              ScrollBehavior().copyWith(overscroll: false),
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
                                      'Buat kata sandi baru',
                                      style: heading1(
                                          FontWeight.w700, bnw900, 'Outfit'),
                                    ),
                                    Text(
                                      'Silahkan buat kata sandi baru untuk akun kamu.',
                                      style: heading3(
                                          FontWeight.w500, bnw500, 'Outfit'),
                                    ),
                                    SizedBox(height: size24),
                                    Row(
                                      children: [
                                        Text(
                                          'Kata Sandi Baru ',
                                          style: heading4(FontWeight.w500,
                                              bnw900, 'Outfit'),
                                        ),
                                        Text(
                                          '*',
                                          style: heading4(FontWeight.w700,
                                              red500, 'Outfit'),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      child: IntrinsicHeight(
                                        child: TextFormField(
                                          style: heading2(FontWeight.w600,
                                              bnw900, 'Outfit'),
                                          cursorColor: primary500,
                                          controller: phoneEmailController,
                                          obscureText: _obscureText,
                                          obscuringCharacter: '*',
                                          onChanged: (value) {
                                            if (phoneEmailController
                                                    .text.isNotEmpty &&
                                                phoneEmailController2
                                                    .text.isNotEmpty) {
                                              onOffButton = primary500;
                                            }
                                            setState(() {});
                                          },
                                          decoration: InputDecoration(
                                            errorStyle: body1(FontWeight.w500,
                                                red500, 'Outfit'),
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
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: size12),
                                            hintText:
                                                'Masukkan Kata Sandi Baru',
                                            hintStyle: heading2(FontWeight.w600,
                                                bnw400, 'Outfit'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size16),
                                    Row(
                                      children: [
                                        Text(
                                          'Konfirmasi Kata Sandi ',
                                          style: heading4(FontWeight.w500,
                                              bnw900, 'Outfit'),
                                        ),
                                        Text(
                                          '*',
                                          style: heading4(FontWeight.w700,
                                              red500, 'Outfit'),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      child: IntrinsicHeight(
                                        child: TextFormField(
                                          style: heading2(FontWeight.w600,
                                              bnw900, 'Outfit'),
                                          cursorColor: primary500,
                                          controller: phoneEmailController2,
                                          obscureText: _obscureText2,
                                          obscuringCharacter: '*',
                                          onChanged: (value) {
                                            if (phoneEmailController
                                                    .text.isNotEmpty &&
                                                phoneEmailController2
                                                    .text.isNotEmpty) {
                                              onOffButton = primary500;
                                            }
                                            setState(() {});
                                          },
                                          decoration: InputDecoration(
                                            errorStyle: body1(FontWeight.w500,
                                                red500, 'Outfit'),
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
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                !_obscureText2
                                                    ? PhosphorIcons.eye_closed
                                                    : PhosphorIcons.eye,
                                                color: bnw900,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscureText2 =
                                                      !_obscureText2;
                                                  print(_obscureText2);
                                                });
                                              },
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: size12),
                                            hintText:
                                                'Ketik Ulang Kata Sandi Baru',
                                            hintStyle: heading2(FontWeight.w600,
                                                bnw400, 'Outfit'),
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
                                            if (onOffButton == primary500) {
                                              if (phoneEmailController.text ==
                                                  phoneEmailController2.text) {
                                                errorText = '';
                                                changePasswordChange(
                                                        context,
                                                        widget.userid,
                                                        phoneEmailController
                                                            .text,
                                                        phoneEmailController
                                                            .text)
                                                    .then((value) {
                                                  if (value == '00') {
                                                    Navigator.of(context)
                                                        .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            LoginPage(),
                                                      ),
                                                      (Route<dynamic> route) =>
                                                          false,
                                                    );
                                                  }
                                                });
                                              } else {
                                                showSnackBarComponent(
                                                    context,
                                                    'Kata sandi harus sama',
                                                    '30');
                                              }
                                            }
                                          });
                                        },
                                        child: buttonXXLonOff(
                                          Center(
                                            child: Text('Buat Sandi Baru',
                                                style: heading2(FontWeight.w600,
                                                    bnw100, 'Outfit')),
                                          ),
                                          double.infinity,
                                          onOffButton,
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
}
