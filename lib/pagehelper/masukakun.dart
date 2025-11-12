import 'daftarAkun.dart';
import 'loginregis/login_page.dart';
import 'loginregis/register_page.dart';

import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';

class MasukAkunPage extends StatelessWidget {
  const MasukAkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bnw100,
        appBar: AppBar(
          leading: Container(),
          toolbarHeight: size48,
          elevation: 0,
          backgroundColor: bnw100,
          flexibleSpace: SafeArea(
            child: Container(
              color: Colors.transparent,
              child: Center(
                  child: SvgPicture.asset(
                'assets/logoHorizontalUnipos.svg',
                color: primary500,
                // width: 240,
                height: size48,
              )),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: size32),
          child: Row(
            children: [
              Expanded(
                child: SvgPicture.asset(
                  'assets/newIllustration/OnBoarding1.svg',
                ),
              ),
              SizedBox(width: size16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Text('Hai, Pengusaha Kreatif & Inovatif',
                          style: heading1(FontWeight.w700, bnw900, 'Outfit')),
                    ),
                    SizedBox(height: size12),
                    SizedBox(
                      child: Text(
                        'Yuk, Mulai gunakan sistem kasir yang dapat mempermudah dan mempercepat transaksi bisnismu.',
                        style: heading2(FontWeight.w500, bnw900, 'Outfit'),
                      ),
                    ),
                    SizedBox(height: size32),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DaftarAkunPage(),
                        ),
                      ),
                      child: buttonXXL(
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: bnw100,
                              ),
                              SizedBox(width: size12),
                              Text(
                                'Daftar',
                                style:
                                    heading2(FontWeight.w600, bnw100, 'Outfit'),
                              )
                            ],
                          ),
                        ),
                        double.infinity,
                      ),
                    ),
                    SizedBox(height: size16),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        ),
                        child: buttonXXLoutline(
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login, color: primary500),
                                SizedBox(width: size12),
                                Text(
                                  'Masuk',
                                  style: heading2(
                                      FontWeight.w600, primary500, 'Outfit'),
                                )
                              ],
                            ),
                          ),
                          double.infinity,
                          primary500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
