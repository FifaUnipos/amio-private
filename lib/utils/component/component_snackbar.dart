import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';

import '../../pagehelper/loginregis/login_page.dart';

import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'component_size.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'component_color.dart';

Future<dynamic> showDialogBilling(BuildContext context, text) {
  return showModalBottomSheet(
    constraints: const BoxConstraints(maxWidth: double.infinity),
    isScrollControlled: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    context: context,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: bnw100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size8),
            topRight: Radius.circular(size8),
          ),
        ),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(size32, size12, size32, size32),
              child: Column(
                children: [
                  dividerShowdialog(),
                  SizedBox(height: size16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2.2,
                    child: SvgPicture.asset('assets/newIllustration/Help.svg'),
                  ),
                  SizedBox(height: size16),
                  Text(
                    text,
                    style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  Text(
                    "Silahkan untuk menghubungi customer service untuk menanyakan permasalahan.",
                    style: heading2(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: size32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: buttonXLoutline(
                            Center(
                              child: Text(
                                'Gak jadi',
                                style: heading3(
                                  FontWeight.w600,
                                  primary500,
                                  'Outfit',
                                ),
                              ),
                            ),
                            100,
                            primary500,
                          ),
                        ),
                      ),
                      SizedBox(width: size16),
                      Expanded(
                        child: SizedBox(
                          child: GestureDetector(
                            onTap: () {},
                            child: buttonXL(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    PhosphorIcons.whatsapp_logo_fill,
                                    color: bnw100,
                                    size: 18,
                                  ),
                                  SizedBox(width: size12),
                                  Text(
                                    'Hubungkan ke Customer Service',
                                    style: heading3(
                                      FontWeight.w600,
                                      bnw100,
                                      'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                              double.infinity,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showSnackbar(BuildContext context, jsonResponse) async {
  String? rc = jsonResponse['rc']?.toString();
  String? message = jsonResponse['message'] ?? jsonResponse['data'];

  if (rc == '63007') {
    showDialogBilling(context, message ?? 'Error');
  } else if (rc == '00') {
    showSnackBarComponent(context, message ?? 'Berhasil', rc ?? '00');
  } else {
    showSnackBarComponent(
      context,
      message ?? 'Error tidak diketahui',
      rc ?? '99',
    );

    if (rc == '63' || rc == '14') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      prefs.remove('deviceid');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }
}

void showSnackBarComponent(BuildContext context, String text, String rc) {
  final snackBar = SnackBar(
    content: Container(
      margin: const EdgeInsets.all(20),
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size8),
        color: (rc == '00') ? succes600 : red500, // ✅ rc sudah dicek
      ),
      child: Center(
        child: Text(text, style: heading2(FontWeight.w700, bnw100, 'Outfit')),
      ),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
  );

  try {
    final messenger =
        ScaffoldMessenger.maybeOf(context) ??
        ScaffoldMessenger.of(
          Navigator.of(context, rootNavigator: true).context,
        );
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(snackBar);
  } catch (e) {
    debugPrint('⚠️ showSnackBarComponent gagal: $e');
  }
}
