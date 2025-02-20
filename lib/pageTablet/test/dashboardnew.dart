import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:amio/models/keranjangModel.dart';
import 'package:amio/models/tokomodel.dart';
import 'package:amio/pageTablet/tokopage/sidebar/transaksiToko/transaksi.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'testLine.dart';
import '../../services/checkConnection.dart';
import '../../utils/component/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:amio/utils/utilities.dart';
import 'package:amio/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import '../../main.dart';
import '../../services/apimethod.dart';

import 'package:flutter_svg/svg.dart';
import '../../../../utils/component/component_showModalBottom.dart';
import 'package:skeletons/skeletons.dart';
import '../../../../utils/component/component_color.dart';
import '../../../../utils/component/component_button.dart';

String? sessCode;
String generateSessCode(int length) {
  const characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();

  return List.generate(
      length, (index) => characters[random.nextInt(characters.length)]).join();
}

class Dashboarpagenew extends StatefulWidget {
  String token;
  Dashboarpagenew({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<Dashboarpagenew> createState() => _DashboarpagenewState();
}

class _DashboarpagenewState extends State<Dashboarpagenew> {
  PageController _pageController = PageController();
  List<ModelDataToko>? datas;
  late WebViewController webController;

  @override
  void initState() {
    checkConnection(context);
    getKulasedaya(context, widget.token, '');
    // connectWeb();
    dashboardKulasedaya(widget.token);
    // dashboard(identifier, widget.token);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        datas = await getAllToko(context, widget.token, '', '');

        //   datas;
        setState(() {});

        _pageController = PageController(
          initialPage: 0,
          keepPage: true,
          viewportFraction: 1,
        );
      },
    );
    pendapatanDas;
    membersDas;
    transaksiDas;
    rataTransaksiDas;
    // rangeDate;

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showModalBottomExit(context);
        return false;
      },
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.all(size16),
          padding: EdgeInsets.all(size16),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.circular(size16),
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: [
              dashboardPage(context),
              Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _pageController.jumpToPage(0);
                        },
                        child: Icon(
                          PhosphorIcons.arrow_left,
                          size: size48,
                          color: bnw900,
                        ),
                      ),
                      SizedBox(width: size16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hubungkan FifaPay',
                            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          Text(
                            'Menghubungkan dengan akun FifaPay',
                            style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://fifapay.co.id/assets/img/logo.png',
                              width: 200,
                            ),
                            SizedBox(height: size12),
                            Text(
                              'Akun FifaPay yang terhubung dengan nomor ini',
                              style: heading2(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            SizedBox(height: size12),
                            Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: bnw300, width: width2),
                                borderRadius: BorderRadius.circular(size8),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: size32,
                                horizontal: 150,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    PhosphorIcons.user_circle_fill,
                                    color: bnw900,
                                    size: size64,
                                  ),
                                  Text(
                                    phoneProfile ?? '',
                                    style: heading2(
                                        FontWeight.w600, bnw900, 'Outfit'),
                                  ),
                                  SizedBox(height: size12),
                                  Text(
                                    nameProfile ?? '',
                                    style: heading2(
                                        FontWeight.w400, bnw900, 'Outfit'),
                                  ),
                                  SizedBox(height: size12),
                                  Text(
                                    'Akun tidak terhubung',
                                    style: heading2(
                                        FontWeight.w400, orange500, 'Outfit'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size12),
                        GestureDetector(
                          onTap: () {
                            String sessCodeFix = "&sess_code=$sessCode";
                            print("my code $bindingUrl$sessCodeFix");
                            try {
                              webController = WebViewController()
                                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                ..loadRequest(
                                    Uri.parse(bindingUrl + sessCodeFix));
                              print("WebController initialized successfully");
                            } catch (e) {
                              print("Error initializing WebController: $e");
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: Text(
                                      'Hubungkan FifaPay',
                                      style: heading2(
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                  ),
                                  body: WebViewWidget(
                                    controller: webController
                                      ..setJavaScriptMode(JavaScriptMode
                                          .unrestricted) // Aktifkan JavaScript
                                      ..addJavaScriptChannel(
                                        'flutterCallback', // Nama channel yang digunakan
                                        onMessageReceived:
                                            (JavaScriptMessage message) {
                                          print(
                                              "Message from web: ${message.message}");

                                          setState(() {
                                            dashboardKulasedaya(widget.token);

                                            Navigator.of(context).popUntil(
                                                (route) => route.isFirst);
                                          });
                                        },
                                      )
                                      ..setNavigationDelegate(
                                        NavigationDelegate(
                                          onPageFinished: (String url) {
                                            // Pastikan halaman sudah selesai dimuat sebelum menjalankan kode JavaScript
                                            webController.runJavaScript("""
                                              console.log('flutterCallback tersedia:', typeof flutterCallback !== 'undefined');
                                              console.log('Menguji pengiriman pesan');
                                              FlutterCallback.postMessage('Halo dari Web!');
                                            """);
                                          },
                                        ),
                                      )
                                      ..loadRequest(Uri.parse(
                                          bindingUrl)), // Ganti dengan URL halaman web
                                  ),
                                ),
                              ),
                            );
                          },
                          child: buttonXXL(
                            Center(
                              child: Text(
                                'Hubungkan FifaPay',
                                style:
                                    heading2(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ),
                            double.infinity,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column dashboardPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: heading1(FontWeight.w700, bnw900, 'Outfit'),
            ),
            Text(
              'Papan Informasi Toko',
              style: heading3(FontWeight.w300, bnw900, 'Outfit'),
            ),
            SizedBox(height: size16),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            physics: BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // height: 330,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(size16),
                          border: Border.all(color: bnw300),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(size12),
                              decoration: BoxDecoration(
                                color: primary100,
                                borderRadius: BorderRadius.circular(size16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/fifapaylogo.png',
                                              height: 40,
                                            ),
                                            SizedBox(width: size12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'FifaPay',
                                                  style: heading2(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                                Text(
                                                  statusKulasedaya == 'true'
                                                      ? 'Terhubung'
                                                      : 'Belum Terhubung',
                                                  style: body1(
                                                      FontWeight.w300,
                                                      statusKulasedaya == 'true'
                                                          ? primary500
                                                          : red500,
                                                      'Outfit'),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Text(
                                        FormatCurrency.convertToIdr(
                                          int.parse(saldoKulasedaya ?? '0'),
                                        ),
                                        style: heading1(
                                            FontWeight.w700, bnw900, 'Outfit'),
                                      )
                                    ],
                                  ),
                                  statusKulasedaya == 'true'
                                      ? SizedBox()
                                      : SizedBox(height: size16),
                                  statusKulasedaya == 'true'
                                      ? SizedBox()
                                      : GestureDetector(
                                          onTap: () {
                                            _pageController.jumpToPage(1);
                                          },
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: buttonXL(
                                              Center(
                                                child: Text(
                                                  'Hubungkan FifaPay',
                                                  style: heading3(
                                                      FontWeight.w600,
                                                      bnw100,
                                                      'Outfit'),
                                                ),
                                              ),
                                              MediaQuery.of(context).size.width,
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            ),
                            FutureBuilder(
                                future: dashboard(identifier, widget.token),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      children: [
                                        SizedBox(height: size16),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size16,
                                              vertical: size16),
                                          decoration: BoxDecoration(
                                            color: bnw200,
                                          ),
                                          child: Row(children: [
                                            Icon(
                                              PhosphorIcons.info_fill,
                                              size: size24,
                                              color: bnw600,
                                            ),
                                            SizedBox(width: size12),
                                            Text(
                                                'Dibawah ini adalah data dalam kurun waktu (${snapshot.data['rangeDate']}).',
                                                style: heading4(FontWeight.w400,
                                                    bnw600, 'Outfit')),
                                          ]),
                                        ),
                                        SizedBox(height: size16),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            // vertical: size16,
                                            horizontal: size16,
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  frameDash(
                                                    'Pendapatan',
                                                    FormatCurrency.convertToIdr(
                                                        pendapatanDas),
                                                    // 'Rp. $pendapatanDas',
                                                    '',
                                                    PhosphorIcons.money_fill,
                                                  ),
                                                  SizedBox(width: size16),
                                                  frameDash(
                                                    'Total Pelanggan',
                                                    membersDas,
                                                    'Pelanggan',
                                                    PhosphorIcons
                                                        .users_three_fill,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: size16),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  frameDash(
                                                    'Transaksi',
                                                    transaksiDas,
                                                    'Produk Terjual',
                                                    PhosphorIcons
                                                        .shopping_cart_simple_fill,
                                                  ),
                                                  SizedBox(width: size16),
                                                  frameDash(
                                                    'Rata - rata Perhari',
                                                    FormatCurrency.convertToIdr(
                                                        rataTransaksiDas),
                                                    'Transaksi',
                                                    PhosphorIcons
                                                        .shopping_cart_simple_fill,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: size16),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return Container(
                                    padding: EdgeInsets.fromLTRB(
                                        size8, 0, size8, size8),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: size8),
                                          child: SkeletonLine(
                                              style: SkeletonLineStyle(
                                                  height: 60)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: size8),
                                          child: SkeletonLine(
                                              style: SkeletonLineStyle(
                                                  height: 60)),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),

                      FutureBuilder(
                        future: getDataChart(context, widget.token),
                        builder: (context, snapshot) {
                          // log(data.toString());

                          if (snapshot.hasData) {
                            var data = snapshot.data!['data']['banner'];
                            return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: data.length,
                                itemBuilder: (context, index) => Container(
                                  decoration: BoxDecoration(
                                    // border: Border.all(color: bnw300),
                                    borderRadius: BorderRadius.circular(size8),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.only(top: size16),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(size16),
                                      border: Border.all(color: bnw300),
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(size16),
                                      child: Image.network(
                                        data[index]['banner'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const SkeletonLine(
                                                    style: SkeletonLineStyle(
                                                        height: 200)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return SkeletonLine(
                              style: SkeletonLineStyle(height: 200));
                        },
                      ),

                      // LineChartExample(),

                      // LineChartSample2(),

                      // Container(
                      //   height: 200,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(8),
                      //     border: Border.all(color: bnw200),
                      //     color: bnw100,
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: bnw400,
                      //         // spreadRadius: 5,
                      //         blurRadius: 7,
                      //         // offset: Offset(0, 3), // changes position of shadow
                      //       ),
                      //     ],
                      //   ),
                      //   child: FutureBuilder<List<dynamic>>(
                      //     future: getDataChart(widget
                      //         .token), // function that makes the HTTP POST request
                      //     builder: (context, snapshot) {
                      //       if (snapshot.hasData) {
                      //         List<FlSpot> spots = [];
                      //         for (int i = 0; i < snapshot.data!.length; i++) {
                      //           spots.add(FlSpot(i.toDouble(),
                      //               snapshot.data![i]['qty'].toDouble()));
                      //         }
                      //         return SizedBox(
                      //           child: LineChartSample2(spots: spots),
                      //         );
                      //       } else if (snapshot.hasError) {
                      //         return Text("${snapshot.error}");
                      //       }
                      //       return CircularProgressIndicator();
                      //     },
                      //   ),
                      //   // child: LineChartSample2(),
                      // ),

                      // Container(
                      //   margin:  EdgeInsets.only(top: 20),
                      //   height: 200,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(8),
                      //     border: Border.all(color: bnw200),
                      //     color: bnw100,
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: bnw400,
                      //         // spreadRadius: 5,
                      //         blurRadius: 7,
                      //         // offset: Offset(0, 3),
                      //       ),
                      //     ],
                      //   ),
                      //   child: FutureBuilder<List<dynamic>>(
                      //     future: getDataChart(widget
                      //         .token), // function that makes the HTTP POST request
                      //     builder: (context, snapshot) {
                      //       if (snapshot.hasData) {
                      //         List<FlSpot> spots = [];
                      //         for (int i = 0; i < snapshot.data!.length; i++) {
                      //           spots.add(FlSpot(i.toDouble(),
                      //               snapshot.data![i]['qty'].toDouble()));
                      //         }
                      //         return SizedBox(
                      //           child: LineChartSample2(spots: spots),
                      //         );
                      //       } else if (snapshot.hasError) {
                      //         return Text("${snapshot.error}");
                      //       }
                      //       return CircularProgressIndicator();
                      //     },
                      //   ),
                      //   // child: LineChartSample2(),
                      // ),

                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Text(
                      //       'Inventori',
                      //       style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                      //     ),
                      //     Row(
                      //       children: [
                      //         frame70(
                      //           'Stok Persediaan Habis',
                      //           '2',
                      //           'Barang',
                      //           200,
                      //           red500,
                      //         ),
                      //          SizedBox(width: 8),
                      //         frame70(
                      //           'Stok Persediaan Habis',
                      //           '2',
                      //           'Barang',
                      //           260,
                      //           orange500,
                      //         ),
                      //       ],
                      //     )
                      //   ],
                      // )
                    ],
                  ),
                ),
                SizedBox(width: size16),
                Expanded(
                  child: SizedBox(
                    child: FutureBuilder(
                      future: dashboardSide(context, widget.token),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List datatop =
                              snapshot.data!['data']['product']['top-three'];
                          List dataunder =
                              snapshot.data!['data']['product']['under-three'];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(top: size8, bottom: size12),
                                child: Text(
                                  'Penjualan Terlaris',
                                  style: heading2(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                ),
                              ),
                              datatop.isNotEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: datatop.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: EdgeInsets.only(
                                              top: 4, bottom: 4),
                                          padding: EdgeInsets.only(
                                            left: size12,
                                            right: size12,
                                          ),
                                          height: 80,
                                          width: 240,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(size8),
                                            color: bnw100,
                                            border: Border.all(
                                                color: bnw300, width: 1.4),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Container(
                                                  width: 20,
                                                  padding: EdgeInsets.all(4),
                                                  child: Text(
                                                    (index + 1).toString(),
                                                    style: heading2(
                                                        FontWeight.w700,
                                                        bnw900,
                                                        'Outfit'),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: size8,
                                                      right: size8),
                                                  height: 48,
                                                  width: 48,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size8),
                                                    child: Image.network(
                                                      datatop[index]
                                                          ['product_image'],
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          SizedBox(
                                                        child: SvgPicture.asset(
                                                            'assets/logoProduct.svg'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 100,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          datatop[index]
                                                              ['name'],
                                                          style: heading3(
                                                              FontWeight.w600,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                      ),
                                                      Text(
                                                        datatop[index]
                                                            ['typeproducts'],
                                                        style: body1(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacer(),
                                                Text(
                                                  datatop[index]['qty'],
                                                  style: heading2(
                                                      FontWeight.w700,
                                                      primary500,
                                                      'Outfit'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Text('Belum Melakukan Transaksi'),
                              Padding(
                                padding: EdgeInsets.only(top: size12),
                                child: Text(
                                  'Penjualan Terendah',
                                  style: heading2(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                ),
                              ),
                              dataunder.isNotEmpty
                                  ? ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: dataunder.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: EdgeInsets.only(
                                              top: 4, bottom: 4),
                                          padding: EdgeInsets.only(
                                              left: size12, right: size12),
                                          height: 80,
                                          width: 240,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(size8),
                                            color: bnw100,
                                            border: Border.all(
                                                color: bnw300, width: 1.4),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Container(
                                                  width: 20,
                                                  padding: EdgeInsets.all(4),
                                                  child: Text(
                                                    (index + 1).toString(),
                                                    style: heading2(
                                                        FontWeight.w700,
                                                        bnw900,
                                                        'Outfit'),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: size8,
                                                      right: size8),
                                                  height: 48,
                                                  width: 48,
                                                  child: Image.network(
                                                    dataunder[index]
                                                        ['product_image'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        SizedBox(
                                                      child: SvgPicture.asset(
                                                          'assets/logoProduct.svg'),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 100,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          dataunder[index]
                                                              ['name'],
                                                          style: heading3(
                                                              FontWeight.w600,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                      ),
                                                      Text(
                                                        dataunder[index]
                                                            ['typeproducts'],
                                                        style: body1(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacer(),
                                                Text(
                                                  dataunder[index]['qty'],
                                                  style: heading2(
                                                      FontWeight.w700,
                                                      primary500,
                                                      'Outfit'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Text('Belum Melakukan Transaksi'),
                            ],
                          );
                        }
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Penjualan Terlaris',
                                style:
                                    heading2(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                              skeletonLinePenjualan(),
                              skeletonLinePenjualan(),
                              skeletonLinePenjualan(),
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Penjualan Terendah',
                                  style: heading2(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                ),
                              ),
                              skeletonLinePenjualan(),
                              skeletonLinePenjualan(),
                              skeletonLinePenjualan(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Padding skeletonLinePenjualan() {
    return Padding(
      padding: EdgeInsets.only(top: size8),
      child: SkeletonLine(style: SkeletonLineStyle(height: 70)),
    );
  }

  // Container frame70(String title, value, subtitle, double width, Color color) {
  //   return Container(
  //     padding:  EdgeInsets.all(size16),
  //     height: 100,
  //     width: width,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(size16),
  //       border: Border.all(color: bnw300),
  //       color: bnw100,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           title,
  //           style: heading3(FontWeight.w600, bnw900, 'Outfit'),
  //         ),
  //         Text(
  //           value,
  //           style: heading2(FontWeight.w700, color, 'Outfit'),
  //         ),
  //         Text(
  //           subtitle,
  //           style: heading4(FontWeight.w400, bnw900, 'Outfit'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // SizedBox analisisBttn(String title) {
  //   return SizedBox(
  //     child: Row(
  //       children: [
  //         Container(
  //           margin: EdgeInsets.only(left: 6),
  //           width: 42,
  //           height: 38,
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(8),
  //             border: Border.all(color: bnw900),
  //           ),
  //           child: Center(
  //             child: Text(
  //               title,
  //               style: heading4(FontWeight.w600, bnw900, 'Outfit'),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  frameDash(String title, value, desc, IconData icon) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size8),
          // color: primary200,
        ),
        child: Row(
          children: [
            Container(
              height: 49,
              width: 49,
              decoration: BoxDecoration(
                color: primary100,
                borderRadius: BorderRadius.circular(size8),
              ),
              child: Icon(
                icon,
                color: primary500,
                size: 30,
              ),
            ),
            SizedBox(width: size16),
            Expanded(
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          Text(
                            '$value',
                            style:
                                heading3(FontWeight.w700, primary500, 'Outfit'),
                          ),
                        ],
                      ),
                    ),
                    // Icon(
                    //   PhosphorIcons.caret_right_fill,
                    //   size: size16,
                    //   color: primary500,
                    // )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Container sideCard(String numb) {
  //   return Container(
  //     margin:  EdgeInsets.only(top: 4, bottom: 4),
  //     padding:  EdgeInsets.only(left: 10, right: 10),
  //     height: 80,
  //     width: 240,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8),
  //       color: bnw100,
  //       border: Border.all(color: bnw300, width: 1.4),
  //     ),
  //     child: Center(
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           Text(
  //             numb,
  //             style: heading2(FontWeight.w700, bnw900, 'Outfit'),
  //           ),
  //           Padding(
  //             padding:  EdgeInsets.only(left: 8, right: 8),
  //             child: Image.asset('assets/product.png'),
  //           ),
  //           SizedBox(
  //             width: 100,
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Flexible(
  //                   child: Text(
  //                     'Matcha Latte Cappuchino',
  //                     style: heading3(FontWeight.w600, bnw900, 'Outfit'),
  //                   ),
  //                 ),
  //                 Text(
  //                   'Makanan',
  //                   style: body1(FontWeight.w400, bnw900, 'Outfit'),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Expanded(
  //             child: Text(
  //               '3.2 Jt',
  //               style: heading2(FontWeight.w700, primary500, 'Outfit'),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
