import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/component/component_color.dart';
import 'pagehelper/splashscreen.dart';
import 'services/apimethod.dart';
import 'utils/component/providerModel/refreshTampilanModel.dart';
import 'utils/component/providerModel/timerModel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var mytokenGet = prefs.getString('token');
  var onBoard = prefs.getString('onboard');

  // await Firebase.initializeApp();

  await FlutterDownloader.initialize(
    debug: true,
    // ignoreSsl: true,
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

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      // DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
    ],
  ).then(
    (value) => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TimerProvider()),
          ChangeNotifierProvider(create: (_) => RefreshTampilan()),
          ChangeNotifierProvider(create: (_) => RefreshSelected()),
          // ChangeNotifierProvider(create: (_) => ProductProvider()),
          // ChangeNotifierProvider(create: (_) {
          //   TimerProvider();
          //   RefreshTampilan();
          //   RefreshSelected();
          // }),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: false,
            
            progressIndicatorTheme: ProgressIndicatorThemeData(
              color: primary500,
            ),
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: bnw100,
            // errorColor: red500,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            primaryColor: primary500,
            focusColor: primary500,
            primaryColorDark: primary500,
            primaryColorLight: primary500,
            indicatorColor: primary500,
            // inputDecorationTheme: InputDecorationTheme(
            //   focusedBorder: OutlineInputBorder(
            //     borderSide: BorderSide(color: primary500),
            //   ),
            //   filled: true,
            //   fillColor: primary500,
            // ),
            colorScheme: ThemeData().colorScheme.copyWith(primary: primary500),
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

  // if (Device.get().isTablet) {
  //   SystemChrome.setPreferredOrientations(
  //     [
  //       DeviceOrientation.landscapeRight,
  //       DeviceOrientation.landscapeLeft,
  //       // DeviceOrientation.portraitUp,
  //       // DeviceOrientation.portraitDown,
  //     ],
  //   ).then(
  //     // (_) => runApp(MyApp()),

  //     (_) => runApp(
  //       MultiProvider(
  //         providers: [
  //           ChangeNotifierProvider(create: (_) => TimerProvider()),
  //           ChangeNotifierProvider(create: (_) => RefreshTampilan()),
  //           ChangeNotifierProvider(create: (_) => RefreshSelected()),
  //           // ChangeNotifierProvider(create: (_) {
  //           //   TimerProvider();
  //           //   RefreshTampilan();
  //           //   RefreshSelected();
  //           // }),
  //         ],
  //         child: MaterialApp(
  //           debugShowCheckedModeBanner: false,
  //           theme: ThemeData(
  //             primarySwatch: Colors.blue,
  //             scaffoldBackgroundColor: bnw100,
  //             errorColor: red500,
  //             visualDensity: VisualDensity.adaptivePlatformDensity,
  //             primaryColor: Colors.blue,
  //             focusColor: Colors.blue,
  //             colorScheme:
  //                 ThemeData().colorScheme.copyWith(primary: primary500),
  //           ),
  //           title: 'UniPOS',
  //           home: mytokenGet == null
  //               ? onBoard == null
  //                   ? Scaffold(
  //                       body: SplashScreen(isTab: true),
  //                     )
  //                   : Scaffold(
  //                       body: SplashScreenBoard(isTab: true),
  //                     )
  //               : Scaffold(
  //                   body: SplashChecker(isTab: true),
  //                 ),
  //         ),
  //       ),
  //     ),
  //   );
  // } else if (Device.get().isPhone) {
  //   SystemChrome.setPreferredOrientations(
  //     [
  //       DeviceOrientation.portraitUp,
  //       DeviceOrientation.portraitDown,
  //     ],
  //   ).then(
  //     (_) => runApp(
  //       MaterialApp(
  //           debugShowCheckedModeBanner: false,
  //           theme: ThemeData(
  //             primarySwatch: Colors.blue,
  //             scaffoldBackgroundColor: bnw100,
  //             errorColor: red500,
  //             primaryColor: Colors.blue,
  //             focusColor: Colors.blue,
  //             colorScheme:
  //                 ThemeData().colorScheme.copyWith(primary: primary500),
  //           ),
  //           title: 'UniPOS',
  //           home: Scaffold(
  //             body: mytokenGet == null
  //                 ? onBoard == null
  //                     ? Scaffold(
  //                         body: SplashScreen(isTab: false),
  //                       )
  //                     : Scaffold(
  //                         body: SplashScreenBoard(isTab: false,),
  //                       )
  //                 : Scaffold(
  //                     body: SplashChecker(isTab: false),
  //                   ),
  //           )),
  //     ),
  //   );
  // }
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
