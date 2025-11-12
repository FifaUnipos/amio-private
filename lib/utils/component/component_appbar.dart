//* Appbar
import 'package:unipos_app_335/pageMobile/pageHelperMobile/loginRegisMobile/loginPageMobile.dart';
import 'package:unipos_app_335/pagehelper/loginregis/login_page.dart';

import 'package:unipos_app_335/utils/utilities.dart';
import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';
import 'component_size.dart';

import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import '../component/component_color.dart';

appbar(BuildContext context, bool login) {
  return SafeArea(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: size12),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => login
                  ? Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ))
                  : Navigator.of(context).pop(),
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
  );
}

appbarMobile(BuildContext context, bool login) {
  return SafeArea(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: size12),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => login
                  ? Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPageMobile(),
                      ))
                  : Navigator.of(context).pop(),
              child: Icon(
                PhosphorIcons.arrow_left,
                size: 32,
                color: bnw900,
              ),
            ),
            GestureDetector(
              onTap: () {
                helpQuestionShow(context);
              },
              child: Icon(
                PhosphorIcons.question,
                size: 32,
                color: bnw900,
              ),
            ),
          ]),
    ),
  );
}
