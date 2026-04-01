import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:unipos_app_335/pageMobile/dashboardMobile.dart';
import 'package:unipos_app_335/pageTablet/home/sidebar/notifikasigrup.dart';
import 'package:unipos_app_335/pageTablet/test/dashboardnew.dart';
import 'package:unipos_app_335/providers/notifications/payload_provider.dart';
import 'package:unipos_app_335/providers/product/product_sorting_provider.dart';
import 'package:unipos_app_335/providers/merchant/merchant_sorting_provider.dart';
import 'package:unipos_app_335/providers/transactions/history/delete_list_reasons_provider.dart';
import 'package:unipos_app_335/providers/transactions/history/delete_provider.dart';
import 'package:unipos_app_335/providers/transactions/history/view_deleted_history_provider.dart';
import 'package:unipos_app_335/providers/notifications/unipos_notification_provider.dart';
import 'package:unipos_app_335/routes/navigation_route.dart';
import 'package:unipos_app_335/services/api/product/product_sorting_service.dart';
import 'package:unipos_app_335/services/api/merchant/merchant_sorting_service.dart';
import 'package:unipos_app_335/services/api/transaction/history/delete.dart';

import 'package:unipos_app_335/services/api/transaction/history/delete_get_reasons.dart';
import 'package:unipos_app_335/services/api/transaction/history/view_deleted_history.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/services/provider.dart';
import 'package:unipos_app_335/services/unipos_notification_service.dart';
import 'package:unipos_app_335/services/websocket_service.dart';
import '../utils/component/component_color.dart';
import 'pagehelper/splashscreen.dart';
import 'utils/component/providerModel/refreshTampilanModel.dart';
import 'utils/component/providerModel/timerModel.dart';

bool isTabletLayout(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final SidebarXController sidebarController = SidebarXController(
  selectedIndex: 0,
  extended: true,
);
final ValueNotifier<int> mobileTabIndex = ValueNotifier<int>(0);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final notificationAppLaunchDetails = await flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final notificationResponse =
        notificationAppLaunchDetails!.notificationResponse;
    route = NavigationRoute.notificationRoute.name;
    payload = notificationResponse?.payload;
  }

  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final UniposNotificationService notifService = UniposNotificationService();
  await notifService.init();
  await notifService.requestPermissions();

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
  typeAccount = prefs.getString('merchantType');
  roleAccount = prefs.getString('roleProfile');
  try {
    await dashboard(identifier, checkToken ?? '');
  } catch (e) {
    print('Dashboard skip: $e');
  }
  merchantType;

  // Set status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Jalankan app
  runApp(
    UniPOSApp(
      mytokenGet: mytokenGet,
      onBoard: onBoard,
      notifService: notifService,
    ),
  );
}

// Pisahkan App ke widget agar bisa deteksi phone/tablet pakai MediaQuery
class UniPOSApp extends StatelessWidget {
  final String? mytokenGet;
  final String? onBoard;
  final UniposNotificationService notifService;

  const UniPOSApp({
    super.key,
    this.mytokenGet,
    this.onBoard,
    required this.notifService,
  });

  @override
  Widget build(BuildContext context) {
    // di main.dart atau file terpisah

    return MultiProvider(
      providers: [
        Provider<UniposNotificationService>.value(value: notifService),
        ChangeNotifierProvider(
          create: (context) {
            final ws = WebSocketService();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (checkToken != null) {
                debugPrint('Global WebSocket connect... token: $checkToken');
                ws.connect(checkToken, identifier);
              }
            });
            return ws;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => UniposNotificationProvider(
            context.read<UniposNotificationService>()..requestPermissions(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ProductVariantProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => RefreshTampilan()),
        ChangeNotifierProvider(create: (_) => RefreshSelected()),
        Provider(create: (context) => TransactionHistoryDeleteReasonsService()),
        ChangeNotifierProvider(
          create: (context) => TransactionHistoryDeleteReasonsProvider(
            context.read<TransactionHistoryDeleteReasonsService>(),
          ),
        ),
        Provider(create: (context) => TransactionViewDeletedHistoryService()),
        ChangeNotifierProvider(
          create: (context) => TransactionViewDeletedHistoryProvider(
            context.read<TransactionViewDeletedHistoryService>(),
          ),
        ),
        Provider(create: (context) => TransactionHistoryDeleteService()),
        ChangeNotifierProvider(
          create: (context) => TransactionHistoryDeleteProvider(
            context.read<TransactionHistoryDeleteService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PayloadProvider(payload: payload),
        ),
        Provider(create: (context) => ProductSortingService()),
        ChangeNotifierProvider(
          create: (context) =>
              ProductSortingProvider(context.read<ProductSortingService>()),
        ),
        Provider(create: (context) => MerchantSortingService()),
        ChangeNotifierProvider(
          create: (context) =>
              MerchantSortingProvider(context.read<MerchantSortingService>()),
        ),
      ],
      child: MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: MediaQuery.of(context).padding.copyWith(
                bottom: MediaQuery.of(context).viewPadding.bottom,
              ),
            ),
            child: child!,
          );
        },
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
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
          colorScheme: ThemeData().colorScheme.copyWith(
            primary: primary500,
            surfaceContainer: bnw200,
          ),
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
        routes: {
          NavigationRoute.notificationRoute.name: (context) =>
              DashboardPageMobile(token: checkToken, initialIndex: 1),
        NavigationRoute.notificationGroupTabletRoute.name: (context) =>
              NotifikasiGrup(),
        },
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
String? payload;
String? route;

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
