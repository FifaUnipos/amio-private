import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../utils/component/component_color.dart';

import 'loginregis/daftar_akun_toko.dart';
import 'loginregis/register_page.dart';
import 'masukakun.dart';

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
                                  builder: (context) => MasukAkunPage())),
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
