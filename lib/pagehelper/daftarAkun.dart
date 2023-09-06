import 'package:amio/pagehelper/loginregis/login_page.dart';
import 'package:amio/pagehelper/loginregis/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/component.dart';
import 'loginregis/daftar_akun_toko.dart';

class DaftarAkunPage extends StatefulWidget {
  const DaftarAkunPage({super.key});

  @override
  State<DaftarAkunPage> createState() => _DaftarAkunPageState();
}

class _DaftarAkunPageState extends State<DaftarAkunPage> {
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
              appbar(context, true),
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
                child: Row(
                  children: [
                    Expanded(
                      child: cardDaftarAkun(
                        context,
                        'Toko',
                        'Mendaftar sebagai seorang pemilik Toko yang hanya memiliki 1 Toko saja.',
                        'SignUpToko',
                        DaftarAkunTokoPage(),
                        // RegisterPage(),
                      ),
                    ),
                    SizedBox(width: size16),
                    Expanded(
                      child: cardDaftarAkun(
                        context,
                        'Grup Toko',
                        'Mendaftar sebagai seorang pemilik usaha yang memiliki lebih dari 1 toko cabang.',
                        'SignUpGrupToko',
                        RegisterPage(),
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
