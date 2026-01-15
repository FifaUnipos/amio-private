import '../dashboardMobile.dart';
import 'daftarAkunMobile.dart';
import 'loginRegisMobile/loginPageMobile.dart';

import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';import '../../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';
class MasukAkunPageMobile extends StatefulWidget {
  const MasukAkunPageMobile({super.key});

  @override
  State<MasukAkunPageMobile> createState() => _MasukAkunPageMobileState();
}

class _MasukAkunPageMobileState extends State<MasukAkunPageMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(size16, 0, size16, size32),
          child: Column(
            children: [
              SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                      ]),
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/uniposLogoText.svg',
                        color: primary500,
                        height: size48,
                      ),
                      SizedBox(width: size16),
                      Expanded(
                        child: SvgPicture.asset(
                            'assets/newIllustration/OnBoarding1.svg'),
                      ),
                      SizedBox(height: size48),
                      Text(
                        'Daftar Sekarang Untuk Menggunakan Aplikasi',
                        style: heading2(
                          FontWeight.w700,
                          bnw900,
                          'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size64),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DaftarAkunPageMobile(),
                          ));
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: buttonM(
                        Center(
                          child: Text(
                            'Daftar',
                            style: body1(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        primary500,
                      ),
                    ),
                  ),
                  SizedBox(height: size12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPageMobile(),));
                    },
                    child: buttonMoutlineColor(
                      Center(
                        child: Text(
                          'Masuk',
                          style: body1(FontWeight.w600, primary500, 'Outfit'),
                        ),
                      ),
                      primary500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
