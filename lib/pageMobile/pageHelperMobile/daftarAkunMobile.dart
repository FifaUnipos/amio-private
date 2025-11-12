import 'loginRegisMobile/registerTokoPageMobile.dart';
import 'loginRegisMobile/regiterGrupPageMobile.dart';
import '../../pagehelper/loginregis/login_page.dart';
import '../../pagehelper/loginregis/register_page.dart';
import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/component/component_color.dart';

import '../../utils/component/component_appbar.dart';

class DaftarAkunPageMobile extends StatefulWidget {
  const DaftarAkunPageMobile({super.key});

  @override
  State<DaftarAkunPageMobile> createState() => _DaftarAkunPageMobileState();
}

class _DaftarAkunPageMobileState extends State<DaftarAkunPageMobile> {
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
              appbarMobile(context, true),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Pilih tipe akun yang cocok dengan jenis usaha kamu',
                    style: heading3(FontWeight.w500, bnw500, 'Outfit'),
                  ),
                ],
              ),
              SizedBox(height: size16),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: cardDaftarAkun(
                        context,
                        'Toko',
                        'Mendaftar sebagai seorang pemilik Toko yang hanya memiliki 1 Toko saja.',
                        'SignUpToko',
                        DaftarAkunTokoPageMobile(),
                      ),
                    ),
                    SizedBox(height: size16),
                    Expanded(
                      child: cardDaftarAkun(
                        context,
                        'Grup Toko',
                        'Mendaftar sebagai seorang pemilik usaha yang memiliki lebih dari 1 toko cabang.',
                        'SignUpGrupToko',
                        RegisterGrupPageMobile(),
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
      BuildContext context, String title, desc, img, Widget widgetKu) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => widgetKu)),
      child: Container(
        padding: EdgeInsets.all(size32),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: bnw300),
            borderRadius: BorderRadius.circular(size16),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SvgPicture.asset(
                'assets/newIllustration/$img.svg',
                height: MediaQuery.of(context).size.height / 2.4,
              ),
            ),
            SizedBox(height: size12),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  title,
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  desc,
                  style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
