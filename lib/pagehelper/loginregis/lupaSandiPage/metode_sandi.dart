import 'package:amio/pagehelper/loginregis/login_page.dart';
import 'package:amio/pagehelper/loginregis/otp_page.dart';
import 'package:amio/pagehelper/loginregis/register_page.dart';
import 'package:amio/services/apimethod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/component.dart';
import '../../masukakun.dart';
import '../daftar_akun_toko.dart';

class MetodeSandiPage extends StatefulWidget {
  const MetodeSandiPage({super.key});

  @override
  State<MetodeSandiPage> createState() => _MetodeSandiPageState();
}

class _MetodeSandiPageState extends State<MetodeSandiPage> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bnw100,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: size32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Metode Verifikasi',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Pilih satu metode untuk dikirimkan kode verifikasi (OTP).',
                    style: heading3(FontWeight.w500, bnw500, 'Outfit'),
                  ),
                ],
              ),
              SizedBox(height: size16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: cardDaftarAkun(
                          context,
                          'Email',
                          userEmail,
                          PhosphorIcons.envelope_open_fill,
                          Otppage(userPhone, userEmail, '', 'forgotPass')
                          // RegisterPage(),
                          ),
                    ),
                    SizedBox(width: size16),
                    Expanded(
                      child: cardDaftarAkun(
                        context,
                        'Whatsapp',
                        userPhone,
                        PhosphorIcons.whatsapp_logo_fill,
                        Otppage(userPhone, '', '', 'forgotPass'),
                        // DaftarAkunTokoPage(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size16),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector cardDaftarAkun(
    BuildContext context,
    title,
    subTitle,
    IconData iconData,
    Widget widgetKu,
  ) {
    return GestureDetector(
        onTap: () {
          if (title == 'Email') {
            changePasswordRequestOtp(context, 'email', userId);
          } else {
            changePasswordRequestOtp(context, 'whatsapp', userId);
          }
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => widgetKu));
        },
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: size20, vertical: size16),
              decoration: BoxDecoration(
                border: Border.all(color: bnw300),
                borderRadius: BorderRadius.circular(size8),
              ),
              child: Row(children: [
                Icon(
                  iconData,
                  size: size56,
                  color: primary500,
                ),
                SizedBox(width: size16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    title,
                    style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  Text(
                    subTitle,
                  ),
                ]),
              ]),
            ),
          ),
        ));
  }
}
