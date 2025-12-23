import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unipos_app_335/pageTablet/test/dashboardnew.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/services/provider.dart';
import '../utils/component/component_color.dart';
import 'pagehelper/splashscreen.dart';
import 'utils/component/providerModel/refreshTampilanModel.dart';
import 'utils/component/providerModel/timerModel.dart';

bool isTabletLayout(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  var mytokenGet = prefs.getString('token');
  var onBoard = prefs.getString('onboard');
  var role = prefs.getString('roleProfile');
  var type = prefs.getString('merchantType');

  await FlutterDownloader.initialize(debug: true);

  checkToken = mytokenGet;
  roleAccount = role;
  typeAccount = type;

  log('myToken: $mytokenGet');
  log('onBoard: $onBoard');
  log('role: $role');
  log('type: $type');

  sessCode = generateSessCode(16);
  await deviceDetails();

  myprofile(prefs.getString('token') ?? '');
  dashboard(identifier, checkToken ?? '');
  merchantType;

  // Set status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Jalankan app
  runApp(UniPOSApp(mytokenGet: mytokenGet, onBoard: onBoard));
}

// ✅ Pisahkan App ke widget agar bisa deteksi phone/tablet pakai MediaQuery
class UniPOSApp extends StatelessWidget {
  final String? mytokenGet;
  final String? onBoard;

  const UniPOSApp({super.key, this.mytokenGet, this.onBoard});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductVariantProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => RefreshTampilan()),
        ChangeNotifierProvider(create: (_) => RefreshSelected()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UniPOS',
        theme: ThemeData(
          useMaterial3: false,
          progressIndicatorTheme: ProgressIndicatorThemeData(color: primary500),
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: bnw100,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor: primary500,
          focusColor: primary500,
          primaryColorDark: primary500,
          primaryColorLight: primary500,
          indicatorColor: primary500,
          colorScheme: ThemeData().colorScheme.copyWith(primary: primary500),
        ),
        home: OrientationBuilder(
          builder: (context, orientation) {
            final isTablet = isTabletLayout(context);

            // 🔹 Set orientasi otomatis berdasarkan device
            if (isTablet) {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeRight,
                DeviceOrientation.landscapeLeft,
              ]);
            } else {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
            }

            return _buildHome(isTablet);
          },
        ),
      ),
    );
  }

  Widget _buildHome(bool isTablet) {
    if (mytokenGet == null) {
      if (onBoard == null) {
        return Scaffold(body: SplashScreen(isTab: isTablet));
      } else {
        return Scaffold(body: SplashScreenBoard(isTab: isTablet));
      }
    } else {
      return Scaffold(body: SplashChecker(isTab: isTablet));
    }
  }
}

// 🔧 Global variables
var checkToken;

//! GET Device ID
String? deviceName;
String? identifier, roleAccount, typeAccount;
final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

Future<void> deviceDetails() async {
  try {
    if (Platform.isAndroid) {
      final buildAnd = await deviceInfoPlugin.androidInfo;

      // ✅ Akses field baru dari .data map (device_info_plus v12+)
      deviceName = buildAnd.data["model"];
      identifier = buildAnd.data["id"]; // pengganti androidId
    } else if (Platform.isIOS) {
      final data = await deviceInfoPlugin.iosInfo;

      deviceName = data.name;
      identifier = data.identifierForVendor;
    }
  } on PlatformException {
    debugPrint('⚠️ Failed to get platform version');
  }
}
