import '../../pagehelper/loginregis/login_page.dart';

import 'package:flutter/material.dart';import 'package:amio/utils/component/component_textHeading.dart';import 'component_size.dart';

import 'package:shared_preferences/shared_preferences.dart';import 'component_color.dart';

void showSnackbar(BuildContext context, jsonResponse) async {
  showSnackBarComponent(
    context,
    jsonResponse['message'] ?? jsonResponse['data'],
    jsonResponse['rc'],
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (jsonResponse['rc'] == '63' || jsonResponse['rc'] == '14') {
    prefs.remove('token');
    prefs.remove('deviceid');

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => LoginPage(),
    //   ),
    // );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
      (Route<dynamic> route) => false,
    );
  }
}

void showSnackBarComponent(BuildContext context, String text, String rc) {
  final snackBar = SnackBar(
    content: Container(
      margin: const EdgeInsets.all(20),
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size8), // Adjust radius as needed
        color: rc == '00' ? succes600 : red500,
      ),
      child: Center(
        child: Text(
          text,
          style: heading2(FontWeight.w700, bnw100, 'Outfit'),
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    duration:
        Duration(seconds: 2), // Duration for which the SnackBar is visible
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
