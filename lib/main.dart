import 'dart:developer';
import 'dart:io';

import 'package:amio/services/apimethod.dart';
import 'package:amio/utils/component.dart';
import 'package:amio/utils/providerModel/refreshTampilanModel.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'pagehelper/onboard/onboard.dart';
import 'pagehelper/splashscreen.dart';
import 'utils/providerModel/timerModel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var mytokenGet = prefs.getString('token');
  var onBoard = prefs.getString('onboard');

  await Firebase.initializeApp();

  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );

  checkToken = mytokenGet;

  log('myToken ' + mytokenGet.toString());
  log(onBoard.toString());

  myprofile(checkToken);
  dashboard(identifier, checkToken);
  deviceDetails();
  statusProfile;

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  if (Device.get().isTablet) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
        // DeviceOrientation.portraitUp,
        // DeviceOrientation.portraitDown,
      ],
    ).then(
      // (_) => runApp(MyApp()),

      (_) => runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TimerProvider()),
            ChangeNotifierProvider(create: (_) => RefreshTampilan()),
            ChangeNotifierProvider(create: (_) => RefreshSelected()),
            // ChangeNotifierProvider(create: (_) {
            //   TimerProvider();
            //   RefreshTampilan();
            //   RefreshSelected();
            // }),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: bnw100,
              errorColor: red500,
              primaryColor: Colors.blue,
              focusColor: Colors.blue,
              colorScheme:
                  ThemeData().colorScheme.copyWith(primary: primary500),
            ),
            title: 'UniPOS',
            home: mytokenGet == null
                ? onBoard == null
                    ? Scaffold(
                        body: SplashScreen(isTab: true),
                      )
                    : Scaffold(
                        body: SplashScreenBoard(isTab: true),
                      )
                : Scaffold(
                    body: SplashChecker(isTab: true),
                  ),
          ),
        ),
      ),
    );
  } else if (Device.get().isPhone) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    ).then(
      (_) => runApp(
        MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: bnw100,
              errorColor: red500,
              primaryColor: Colors.blue,
              focusColor: Colors.blue,
              colorScheme:
                  ThemeData().colorScheme.copyWith(primary: primary500),
            ),
            title: 'UniPOS',
            home: Scaffold(
              body: mytokenGet == null
                  ? onBoard == null
                      ? Scaffold(
                          body: SplashScreen(isTab: false),
                        )
                      : Scaffold(
                          body: SplashScreenBoard(isTab: false,),
                        )
                  : Scaffold(
                      body: SplashChecker(isTab: false),
                    ),
            )),
      ),
    );
  }
}

var checkToken;

//! GET Device ID
String? deviceName;
//String? deviceVersion;
String? identifier;
final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
AndroidDeviceInfo? buildAnd;

Future<void> deviceDetails() async {
  try {
    if (Platform.isAndroid) {
      buildAnd = await deviceInfoPlugin.androidInfo;

      deviceName = buildAnd?.model;
      // deviceVersion =build.version.toString();
      identifier = buildAnd?.androidId;

      //UUID for Android
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;

      deviceName = data.name;
      //deviceVersion = data.systemVersion;
      identifier = data.identifierForVendor;
    }
  } on PlatformException {
    debugPrint('Failed to get platform version');
  }
}
