import 'dart:developer';

import 'package:unipos_app_335/pagehelper/loginregis/login_page.dart';

import '../pageMobile/pageHelperMobile/loginRegisMobile/loginPageMobile.dart';
import '../pageMobile/pageHelperMobile/masukAkunMobile.dart';

import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';

import '../pageTablet/kasirPage/dashboardKasir.dart';
import 'masukakun.dart';
import 'onboard/onboard.dart';

import '../main.dart';
import '../pageTablet/home/dashboard.dart';
import '../pageTablet/tokopage/dashboardtoko.dart';
import '../services/apimethod.dart';

//? just splashScreen
class SplashScreen extends StatefulWidget {
  bool isTab;
  SplashScreen({Key? key, required this.isTab}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    deviceDetails();
    Future.delayed(const Duration(seconds: 3)).then(
      (value) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Onbording(isTablet: widget.isTab),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 400,
        width: 400,
        child: Image.asset('assets/images/UniPOSLogo.png'),
      ),
    );
  }
}

//? check user first install or not
class SplashScreenBoard extends StatefulWidget {
  bool isTab;
  SplashScreenBoard({Key? key, required this.isTab}) : super(key: key);

  @override
  State<SplashScreenBoard> createState() => _SplashScreenBoardState();
}

class _SplashScreenBoardState extends State<SplashScreenBoard> {
  @override
  void initState() {
    super.initState();
    deviceDetails();
    Future.delayed(const Duration(seconds: 3)).then(
      (value) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              widget.isTab ? MasukAkunPage() : MasukAkunPageMobile(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 400,
        width: 400,
        child: Image.asset('assets/images/UniPOSLogo.png'),
      ),
    );
  }
}

//? check status merchant/group
class SplashChecker extends StatefulWidget {
  bool isTab;
  SplashChecker({Key? key, required this.isTab}) : super(key: key);

  @override
  State<SplashChecker> createState() => _SplashCheckerState();
}

class _SplashCheckerState extends State<SplashChecker> {
  @override
  void initState() {
    myprofile(checkToken);
    dashboard(identifier, checkToken);
    log("Statusku $checkToken");
    log("Type Account $typeAccount");
    log("Role Account $roleAccount");
    saldoKulasedaya = '0';
    dashboardKulasedaya(checkToken);
    super.initState();
    deviceDetails();
    Future.delayed(const Duration(seconds: 3)).then(
      (value) => {
        widget.isTab
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    if (typeAccount == 'Group_Merchant') {
                      return SidebarXExampleApp(
                        id: identifier.toString(),
                        token: checkToken ?? '',
                      );
                    } else if (typeAccount == 'Merchant_Only') {
                      return SidebarXExampleAppToko(
                        token: checkToken ?? '',
                        id: identifier.toString(),
                      );
                    } else if (typeAccount == 'Merchant' &&
                        roleAccount == 'cashier') {
                      return SidebarXKasirPage(
                        token: checkToken ?? '',
                        id: identifier.toString(),
                      );
                    } else if (typeAccount == 'Merchant') {
                      return SidebarXExampleAppToko(
                        token: checkToken ?? '',
                        id: identifier.toString(),
                      );
                      // return Container(child: Text('HEllo cashier'));
                    }
                    return LoginPage();
                  },
                  // => statusProfile == 'Group_Merchant'
                  //     ? SidebarXExampleApp(
                  //         id: identifier.toString(),
                  //         token: checkToken,
                  //       )
                  //     : SidebarXExampleAppToko(
                  //         token: checkToken,
                  //         id: identifier.toString(),
                  //       ),
                ),
              )
            : sessionPageMobile(context, checkToken, '', ''),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 400,
        width: 400,
        child: Image.asset('assets/images/UniPOSLogo.png'),
      ),
    );
  }
}
