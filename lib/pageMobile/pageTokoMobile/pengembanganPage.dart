import '../pageHelperMobile/loginRegisMobile/loginPageMobile.dart';

import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../utils/component/component_color.dart';
import '../../main.dart';
import '../../services/apimethod.dart';import '../../../../../utils/component/component_button.dart';

class TahapPengembanganPage extends StatefulWidget {
  const TahapPengembanganPage({super.key});

  @override
  State<TahapPengembanganPage> createState() => _TahapPengembanganPageState();
}

class _TahapPengembanganPageState extends State<TahapPengembanganPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(size32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/newIllustration/ErrorPayment.svg',
              height: 200,
              width: 200,
            ),
            Text(
              'Maaf, Fitur ini sedang dalam tahap pengembangan',
              textAlign: TextAlign.center,
              style: heading1(FontWeight.w600, bnw900, 'Outfit'),
            ),
            SizedBox(height: size16),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  logout(
                    checkToken,
                    identifier,
                    context,
                    LoginPageMobile(),
                  ).whenComplete(() async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove('token');
                    prefs.remove('deviceid');

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => LoginPageMobile()),
                      // (route) => false,
                    );
                  });
                },
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Keluar',
                      style: heading3(FontWeight.w600, primary500, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width,
                  primary500,
                  // primary500,
                  // primary500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
