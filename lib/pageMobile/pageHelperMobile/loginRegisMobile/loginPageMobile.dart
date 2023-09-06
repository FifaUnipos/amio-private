import 'package:amio/pageMobile/dashboardMobile.dart';
import 'package:amio/utils/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';

class LoginPageMobile extends StatefulWidget {
  const LoginPageMobile({super.key});

  @override
  State<LoginPageMobile> createState() => _LoginPageMobileState();
}

class _LoginPageMobileState extends State<LoginPageMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(size16, 0, size16, size32),
        child: Column(
          children: [
            appbar(context, false),
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
          ],
        ),
      ),
    );
  }
}
