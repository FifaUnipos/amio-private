import 'metode_sandi.dart';
import '../../../services/apimethod.dart';
import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../utils/component/component_color.dart';

import '../../daftarAkun.dart';
import '../../masukakun.dart';
import '../login_page.dart';
import '../otp_page.dart';import '../../../../../utils/component/component_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
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
                          onTap: () => Navigator.pop(context),
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
                          'assets/newIllustration/Login.svg',
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
                                      'Atur ulang kata sandi',
                                      style: heading1(
                                          FontWeight.w700, bnw900, 'Outfit'),
                                    ),
                                    Text(
                                      'Masukkan email atau nomor telepon yang telah terdaftar untuk di atur/buat ulang kata sandi. Kami akan kirimkan kode verifikasi.',
                                      style: heading3(
                                          FontWeight.w500, bnw500, 'Outfit'),
                                    ),
                                    SizedBox(height: size24),
                                    Row(
                                      children: [
                                        Text(
                                          'Nomor Telpon / Email ',
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
                                          focusNode: _focusScopeNode,
                                          style: heading2(FontWeight.w600,
                                              bnw900, 'Outfit'),
                                          onChanged: (value) {
                                            setState(() {
                                              if (value.contains('@') ||
                                                  value.endsWith('.com')) {
                                                validated = 'email';
                                                onOffButton = primary500;
                                              } else if (value
                                                      .startsWith('08') ||
                                                  value.length < 10) {
                                                validated = 'whatsapp';
                                                onOffButton = primary500;
                                              }
                                            });
                                          },
                                          cursorColor: primary500,
                                          controller: phoneEmailController,
                                          decoration: InputDecoration(
                                            errorText: errorText.isNotEmpty
                                                ? errorText
                                                : null,
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
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: size12),
                                            hintText:
                                                'Cth : 08123456789 / nabil@email.com ',
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
                                            errorText = '';
                                            _focusScopeNode.unfocus();
                                            changePasswordRequest(
                                                    context,
                                                    validated,
                                                    phoneEmailController.text)
                                                .then((value) {
                                              if (value == '00') {
                                                errorText = '';
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MetodeSandiPage()),
                                                );
                                              }
                                            });
                                          });
                                        },
                                        child: buttonXXLonOff(
                                          Center(
                                            child: Text('Selanjutnya',
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
