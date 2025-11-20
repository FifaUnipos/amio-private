import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:unipos_app_335/models/keranjangModel.dart';
import 'package:unipos_app_335/models/kulasedayaMemberModel.dart';
import 'package:unipos_app_335/models/tokomodel.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/transaksiToko/transaksi.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'testLine.dart';
import '../../services/checkConnection.dart';
import '../../utils/component/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
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
    length,
    (index) => characters[random.nextInt(characters.length)],
  ).join();
}

class Dashboarpagenew extends StatefulWidget {
  String token;
  Dashboarpagenew({Key? key, required this.token}) : super(key: key);

  @override
  State<Dashboarpagenew> createState() => _DashboarpagenewState();
}

class _DashboarpagenewState extends State<Dashboarpagenew> {
  PageController _pageController = PageController();
  List<ModelDataToko>? datas;
  WebViewController? webController;

  late Future<List<KulasedayaMember>> futureMembers;

  @override
  void initState() {
    print("token $checkToken");
    checkConnection(context);
    getKulasedaya(context, widget.token, '');
    // connectWeb();
    dashboardKulasedaya(widget.token);
    futureMembers = dashboardKulasedaya(widget.token);

    // dashboard(identifier, widget.token);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      datas = await getAllToko(context, widget.token, '', '');

      //   datas;
      setState(() {});

      _pageController = PageController(
        initialPage: 0,
        keepPage: true,
        viewportFraction: 1,
      );
    });
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

  final xValues = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  final yValues = [100000, 320000, 150000, 11000, 28000, 820000, 520000];

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
                            Image.asset(
                              'assets/images/fifapaylogo.png',
                              width: 100,
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
                            FutureBuilder<List<KulasedayaMember>>(
                              future: futureMembers,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(child: Text(''));
                                  // child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                    child: Text('No data available'),
                                  );
                                } else {
                                  List<KulasedayaMember> members =
                                      snapshot.data!;
                                  return ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: members.length,
                                    itemBuilder: (context, index) {
                                      KulasedayaMember member = members[index];
                                      return Container(
                                        margin: EdgeInsets.only(bottom: size12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: bnw300,
                                            width: width2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            size8,
                                          ),
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
                                            SizedBox(height: size12),
                                            Text(
                                              member.memberCode,
                                              style: heading2(
                                                FontWeight.w600,
                                                bnw900,
                                                'Outfit',
                                              ),
                                            ),
                                            SizedBox(height: size12),
                                            Text(
                                              member.nama,
                                              style: heading2(
                                                FontWeight.w400,
                                                bnw900,
                                                'Outfit',
                                              ),
                                            ),
                                            SizedBox(height: size12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Saldo: ',
                                                  style: heading2(
                                                    FontWeight.w400,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                                Text(
                                                  FormatCurrency.convertToIdr(
                                                    int.parse(member.saldo),
                                                  ),
                                                  style: heading2(
                                                    FontWeight.w400,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: size12),
                                            Text(
                                              member.isBinded == '1'
                                                  ? 'Terhubung'
                                                  : 'Tidak Terhubung',
                                              style: heading2(
                                                FontWeight.w400,
                                                orange500,
                                                'Outfit',
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      // ListTile(
                                      //   title: Text(member.nama),
                                      //   subtitle:
                                      //       Text('Saldo: ${member.saldo}'),
                                      //   trailing: Text(member.isBinded == '1'
                                      //       ? 'Binded'
                                      //       : 'Not Binded'),
                                      // );
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: size12),
                        typeAccount != 'Group_Merchant'
                            ? GestureDetector(
                                onTap: () {
                                  // pastikan query pertama pakai ? bukan &
                                  String sessCodeFix = "?sess_code=$sessCode";

                                  // pastikan URL ada https://
                                  final fullUrl = bindingUrl + sessCodeFix;
                                  print("URL yang dimuat => $fullUrl");

                                  try {
                                    webController = WebViewController()
                                      ..setJavaScriptMode(
                                        JavaScriptMode.unrestricted,
                                      )
                                      ..addJavaScriptChannel(
                                        'flutterCallback',
                                        onMessageReceived:
                                            (JavaScriptMessage message) {
                                              print(
                                                "Message from web: ${message.message}",
                                              );
                                              setState(() {
                                                dashboardKulasedaya(
                                                  widget.token,
                                                );
                                                Navigator.of(context).popUntil(
                                                  (route) => route.isFirst,
                                                );
                                              });
                                            },
                                      )
                                      ..setNavigationDelegate(
                                        NavigationDelegate(
                                          onPageFinished: (String url) {
                                            webController?.runJavaScript("""
                  FlutterCallback.postMessage('Halo dari Web!');
              """);
                                          },
                                        ),
                                      )
                                      ..loadRequest(Uri.parse(fullUrl));

                                    print(
                                      "WebController initialized successfully",
                                    );
                                  } catch (e) {
                                    print(
                                      "Error initializing WebController: $e",
                                    );
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        appBar: AppBar(
                                          title: Text(
                                            'Hubungkan FifaPay',
                                            style: heading2(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                        body: webController == null
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            : WebViewWidget(
                                                controller: webController!,
                                              ),
                                      ),
                                    ),
                                  );
                                },
                                child: buttonXXL(
                                  Center(
                                    child: Text(
                                      'Hubungkan FifaPay',
                                      style: heading2(
                                        FontWeight.w600,
                                        bnw100,
                                        'Outfit',
                                      ),
                                    ),
                                  ),
                                  double.infinity,
                                ),
                              )
                            : SizedBox(),
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
        Row(
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
            Spacer(),
            FutureBuilder<Map<String, dynamic>>(
              future: getBilling(context, widget.token), // Fetch data from API
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  var data = snapshot.data!['data'];
                  var dueDate = data['due_date'] ?? 'Not Available';
                  var name = data['name'] ?? 'Not Available';

                  // Now, use the data to populate the UI
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size12),
                      border: Border.all(color: bnw300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: bnw200,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(size12),
                              topRight: Radius.circular(size12),
                            ),
                          ),
                          padding: EdgeInsets.all(size8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Berlangganan: $name',
                                style: heading4(
                                  FontWeight.w500,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              SizedBox(width: size56),
                              Icon(Icons.alarm, color: bnw900), // Clock icon
                            ],
                          ),
                        ),
                        // Bottom section with white background
                        Container(
                          decoration: BoxDecoration(
                            color: bnw100, // White background
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(size12),
                              bottomRight: Radius.circular(size12),
                            ),
                          ),
                          padding: EdgeInsets.all(size8),
                          child: Text(
                            'Berlaku hingga : $dueDate', // Dynamic due date from API
                            style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Text('No data available.'),
                  ); // No data state
                }
              },
            ),
          ],
        ),
        SizedBox(height: size16),
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
                                                    'Outfit',
                                                  ),
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
                                                    'Outfit',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        FormatCurrency.convertToIdr(
                                          int.parse(saldoKulasedaya ?? '0'),
                                        ),
                                        style: heading1(
                                          FontWeight.w700,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
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
                                                    'Outfit',
                                                  ),
                                                ),
                                              ),
                                              MediaQuery.of(context).size.width,
                                            ),
                                          ),
                                        ),
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
                                          vertical: size16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: bnw200,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              PhosphorIcons.info_fill,
                                              size: size24,
                                              color: bnw600,
                                            ),
                                            SizedBox(width: size12),
                                            Text(
                                              'Dibawah ini adalah data dalam kurun waktu (${snapshot.data['rangeDate']}).',
                                              style: heading4(
                                                FontWeight.w400,
                                                bnw600,
                                                'Outfit',
                                              ),
                                            ),
                                          ],
                                        ),
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
                                                    pendapatanDas,
                                                  ),
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
                                                    rataTransaksiDas,
                                                  ),
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
                                    size8,
                                    0,
                                    size8,
                                    size8,
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: size8),
                                        child: SkeletonLine(
                                          style: SkeletonLineStyle(height: 60),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: size8),
                                        child: SkeletonLine(
                                          style: SkeletonLineStyle(height: 60),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      ChartPage(token: widget.token),
                      ChartPagePendapatan(token: widget.token),

                      // FutureBuilder(
                      //   future: getDataChart(context, widget.token),
                      //   builder: (context, snapshot) {
                      //     // log(data.toString());

                      //     if (snapshot.hasData) {
                      //       var data = snapshot.data!['data']['banner'];
                      //       return SizedBox(
                      //         width: MediaQuery.of(context).size.width,
                      //         child: ListView.builder(
                      //           padding: EdgeInsets.zero,
                      //           shrinkWrap: true,
                      //           physics: NeverScrollableScrollPhysics(),
                      //           itemCount: data.length,
                      //           itemBuilder: (context, index) => Container(
                      //             decoration: BoxDecoration(
                      //               // border: Border.all(color: bnw300),
                      //               borderRadius: BorderRadius.circular(size8),
                      //             ),
                      //             child: Container(
                      //               margin: EdgeInsets.only(top: size16),
                      //               decoration: BoxDecoration(
                      //                 borderRadius:
                      //                     BorderRadius.circular(size16),
                      //                 border: Border.all(color: bnw300),
                      //               ),
                      //               child: ClipRRect(
                      //                 borderRadius:
                      //                     BorderRadius.circular(size16),
                      //                 child: Image.network(
                      //                   data[index]['banner'],
                      //                   fit: BoxFit.cover,
                      //                   errorBuilder:
                      //                       (context, error, stackTrace) =>
                      //                           const SkeletonLine(
                      //                               style: SkeletonLineStyle(
                      //                                   height: 200)),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     }
                      //     return SkeletonLine(
                      //         style: SkeletonLineStyle(height: 200));
                      //   },
                      // ),

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
                                padding: EdgeInsets.only(
                                  top: size8,
                                  bottom: size12,
                                ),
                                child: Text(
                                  'Penjualan Terlaris',
                                  style: heading2(
                                    FontWeight.w600,
                                    bnw900,
                                    'Outfit',
                                  ),
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
                                            top: 4,
                                            bottom: 4,
                                          ),
                                          padding: EdgeInsets.only(
                                            left: size12,
                                            right: size12,
                                          ),
                                          height: 80,
                                          width: 240,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              size8,
                                            ),
                                            color: bnw100,
                                            border: Border.all(
                                              color: bnw300,
                                              width: 1.4,
                                            ),
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
                                                      'Outfit',
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    left: size8,
                                                    right: size8,
                                                  ),
                                                  height: 48,
                                                  width: 48,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          size8,
                                                        ),
                                                    child: Image.network(
                                                      datatop[index]['product_image'],
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => SizedBox(
                                                            child: SvgPicture.asset(
                                                              'assets/logoProduct.svg',
                                                            ),
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
                                                          datatop[index]['name'],
                                                          style: heading3(
                                                            FontWeight.w600,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        datatop[index]['typeproducts'],
                                                        style: body1(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
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
                                                    'Outfit',
                                                  ),
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
                                    FontWeight.w600,
                                    bnw900,
                                    'Outfit',
                                  ),
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
                                            top: 4,
                                            bottom: 4,
                                          ),
                                          padding: EdgeInsets.only(
                                            left: size12,
                                            right: size12,
                                          ),
                                          height: 80,
                                          width: 240,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              size8,
                                            ),
                                            color: bnw100,
                                            border: Border.all(
                                              color: bnw300,
                                              width: 1.4,
                                            ),
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
                                                      'Outfit',
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    left: size8,
                                                    right: size8,
                                                  ),
                                                  height: 48,
                                                  width: 48,
                                                  child: Image.network(
                                                    dataunder[index]['product_image'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => SizedBox(
                                                          child: SvgPicture.asset(
                                                            'assets/logoProduct.svg',
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
                                                          dataunder[index]['name'],
                                                          style: heading3(
                                                            FontWeight.w600,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        dataunder[index]['typeproducts'],
                                                        style: body1(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
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
                                                    'Outfit',
                                                  ),
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
                                style: heading2(
                                  FontWeight.w600,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              skeletonLinePenjualan(),
                              skeletonLinePenjualan(),
                              skeletonLinePenjualan(),
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Penjualan Terendah',
                                  style: heading2(
                                    FontWeight.w600,
                                    bnw900,
                                    'Outfit',
                                  ),
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
              child: Icon(icon, color: primary500, size: 30),
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
                            style: heading3(
                              FontWeight.w700,
                              primary500,
                              'Outfit',
                            ),
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
            ),
          ],
        ),
      ),
    );
  }
}

/// ====== PAGE: ambil data via getValueDataChart() ======
class ChartPage extends StatefulWidget {
  const ChartPage({super.key, required this.token});
  final String token;

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  String selectedRange = '6B'; // opsi: 1W, 1B, 3B, 6B, (1Y kalau ada)
  late Future<ChartData> futureData;

  @override
  void initState() {
    super.initState();
    futureData = _fetch(selectedRange);
  }

  Future<ChartData> _fetch(String tipe) async {
    // panggil fungsi KAMU (di file lain) → Map response
    final Map<String, dynamic> resp = await getValueDataChart(
      context,
      widget.token,
      tipe,
    );
    // parsing ke model chart
    return ChartData.fromPayload(resp);
  }

  void _reload(String tipe) {
    setState(() {
      selectedRange = tipe;
      futureData = _fetch(tipe);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: size12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Analisis Penjualan',
                style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              ),
            ),
            SizedBox(width: size8),
            // beri batas lebar agar pas di ujung kanan
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.65,
              ),
              child: _RangeSelector(
                selected: selectedRange,
                onSelected: (v) => _reload(v),
              ),
            ),
          ],
        ),
        SizedBox(height: size12),

        // ===== FutureBuilder: render chart dari API =====
        FutureBuilder<ChartData>(
          future: futureData,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: EdgeInsets.all(size24),
                child: CircularProgressIndicator(),
              );
            }
            if (snap.hasError) {
              return Padding(
                padding: EdgeInsets.all(size16),
                child: Text(
                  'Gagal memuat: ${snap.error}',
                  style: body3(FontWeight.w600, danger500, 'Outfit'),
                ),
              );
            }
            final data = snap.data!;
            return Column(
              children: [
                ChartCard(
                  xValues: data.xValues,
                  yValues: data.yValues,
                  qtyValues: data.qtyValues,
                  // opsional: atur batas Y manual bila ingin
                  // yMaxOverride: 1_000_000,
                  // yTickValues: const [0, 200000, 400000, 600000, 800000, 1000000],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rentang: $selectedRange • Total Rp ${_formatThousands(data.yValues.fold<num>(0, (a, b) => a + b).round())}',
                    style: body2(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// ====== PAGE: ambil data via getValueDataChart() ======
class ChartPagePendapatan extends StatefulWidget {
  const ChartPagePendapatan({super.key, required this.token});
  final String token;

  @override
  State<ChartPagePendapatan> createState() => _ChartPagePendapatanState();
}

class _ChartPagePendapatanState extends State<ChartPagePendapatan> {
  String selectedRange = '6B'; // opsi: 1W, 1B, 3B, 6B, (1Y kalau ada)
  late Future<ChartData> futureData;

  @override
  void initState() {
    super.initState();
    futureData = _fetch(selectedRange);
  }

  Future<ChartData> _fetch(String tipe) async {
    // panggil fungsi KAMU (di file lain) → Map response
    final Map<String, dynamic> resp = await getValueDataChartPendapatan(
      context,
      widget.token,
      tipe,
    );
    // parsing ke model chart
    return ChartData.fromPayload(resp);
  }

  void _reload(String tipe) {
    setState(() {
      selectedRange = tipe;
      futureData = _fetch(tipe);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: size12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Analisis Pendapatan',
                style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              ),
            ),
            SizedBox(width: size8),
            // beri batas lebar agar pas di ujung kanan
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.65,
              ),
              child: _RangeSelector(
                selected: selectedRange,
                onSelected: (v) => _reload(v),
              ),
            ),
          ],
        ),

        SizedBox(height: size12),

        // ===== FutureBuilder: render chart dari API =====
        FutureBuilder<ChartData>(
          future: futureData,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: EdgeInsets.all(size24),
                child: CircularProgressIndicator(),
              );
            }
            if (snap.hasError) {
              return Padding(
                padding: EdgeInsets.all(size16),
                child: Text(
                  'Gagal memuat: ${snap.error}',
                  style: body3(FontWeight.w600, danger500, 'Outfit'),
                ),
              );
            }
            final data = snap.data!;
            return Column(
              children: [
                ChartCard(
                  xValues: data.xValues,
                  yValues: data.yValues,
                  qtyValues: data.qtyValues,
                  // opsional: atur batas Y manual bila ingin
                  // yMaxOverride: 1_000_000,
                  // yTickValues: const [0, 200000, 400000, 600000, 800000, 1000000],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rentang: $selectedRange • Total Rp ${_formatThousands(data.yValues.fold<num>(0, (a, b) => a + b).round())}',
                    style: body2(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ======= tambahkan di bawah kelas _ChartPageState (atau di file yang sama) =======

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected; // '1W' | '1B' | '3B' | '6B' | '1Y'
  final ValueChanged<String> onSelected;

  static const _options = <_RangeOption>[
    _RangeOption('1 Mg', '1W'),
    _RangeOption('1 Bln', '1B'),
    _RangeOption('3 Bln', '3B'),
    _RangeOption('6 Bln', '6B'),
    _RangeOption('1 Thn', '1Y'),
  ];

  @override
  Widget build(BuildContext context) {
    final pills = _options.map((o) {
      final isSel = o.value == selected;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: _RangePill(
          label: o.label,
          selected: isSel,
          onTap: () => onSelected(o.value),
        ),
      );
    }).toList();

    // IMPORTANT: horizontal scroll + fixed height (biar nggak error viewport)
    return SizedBox(
      height: 42,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: pills),
      ),
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2A63FF);
    final borderColor = selected ? blue : const Color(0xFFD1D5DB); // gray-300
    final fill = selected ? const Color(0x1A2A63FF) : Colors.white; // ~10% blue
    final textColor = selected ? blue : const Color(0xFF374151); // gray-700

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _RangeOption {
  final String label;
  final String value;
  const _RangeOption(this.label, this.value);
}

/// ====== MODEL & PARSER sesuai struktur respons BARU (fallback lama) ======
class ChartData {
  final List<String> xValues;
  final List<double> yValues; // value / rp
  final List<int> qtyValues; // <-- NEW: buat tooltip
  final List<String>? dateRanges;

  ChartData(this.xValues, this.yValues, this.qtyValues, {this.dateRanges});

  factory ChartData.fromPayload(Map<String, dynamic> m) {
    final rec =
        (m['data']?['record'] as List?) ??
        (m['data']?['graph'] as List?) ??
        const [];

    final xs = <String>[];
    final ys = <double>[];
    final qs = <int>[];
    final dr = <String>[];

    for (final e in rec) {
      final row = e as Map<String, dynamic>;
      xs.add((row['caption'] ?? '').toString());

      // Y dari 'value' (baru) -> fallback 'rp' (lama)
      final rawY = row.containsKey('value') ? row['value'] : row['rp'];
      ys.add((rawY is num) ? rawY.toDouble() : double.tryParse('$rawY') ?? 0.0);

      // --- qty utk tooltip
      final rawQ = row['qty'];
      qs.add((rawQ is num) ? rawQ.toInt() : int.tryParse('${rawQ ?? 0}') ?? 0);

      dr.add((row['date_range'] ?? row['date-range'] ?? '').toString());
    }

    return ChartData(xs, ys, qs, dateRanges: dr);
  }
}

/// ====== INTERACTIVE CHART (hover/tap tooltip) ======
class ChartCard extends StatefulWidget {
  const ChartCard({
    super.key,
    required this.xValues,
    required this.yValues,
    this.qtyValues,
    this.dateRanges,
    this.yMaxOverride,
    this.yTickValues,
  });

  final List<String> xValues;
  final List<double> yValues;
  final List<int>? qtyValues; // tampil di tooltip
  final List<String>? dateRanges; // tampil di tooltip
  final double? yMaxOverride;
  final List<num>? yTickValues;

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  int? hoverIndex;
  Offset? hoverPosCanvas;

  List<Offset> _computePoints(Rect chartRect, double maxY) {
    const minY = 0.0;
    final pts = <Offset>[];
    final n = widget.yValues.length;
    final den = (n - 1) <= 0 ? 1 : (n - 1); // guard 1 titik
    for (int i = 0; i < n; i++) {
      final dx = chartRect.left + chartRect.width * (i / den);
      final norm =
          (widget.yValues[i] - minY) / (maxY - minY == 0 ? 1 : (maxY - minY));
      final dy = chartRect.bottom - chartRect.height * norm;
      pts.add(Offset(dx, dy));
    }
    return pts;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const leftPad = 88.0, rightPad = 12.0, topPad = 16.0, bottomPad = 36.0;
        // pastikan ukuran FINITE (hindari infinite constraints)
        final width = (c.hasBoundedWidth && c.maxWidth.isFinite)
            ? c.maxWidth
            : MediaQuery.sizeOf(context).width;
        final height = width / 2.9; // AspectRatio 2.9
        final size = Size(width, height);

        final chartRect = Rect.fromLTWH(
          leftPad,
          topPad,
          width - leftPad - rightPad,
          height - topPad - bottomPad,
        );

        final rawMax = widget.yValues.isEmpty
            ? 1.0
            : widget.yValues.reduce((a, b) => a > b ? a : b);
        final maxY = (widget.yMaxOverride ?? _niceMax(rawMax)).toDouble();

        return MouseRegion(
          onExit: (_) => setState(() {
            hoverIndex = null;
            hoverPosCanvas = null;
          }),
          onHover: (e) {
            final pos = e.localPosition;
            if (!chartRect.contains(pos)) return;
            final pts = _computePoints(chartRect, maxY);
            int best = 0;
            double bestDx = double.infinity;
            for (int i = 0; i < pts.length; i++) {
              final d = (pts[i].dx - pos.dx).abs();
              if (d < bestDx) {
                bestDx = d;
                best = i;
              }
            }
            setState(() {
              hoverIndex = best;
              hoverPosCanvas = pts[best];
            });
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              final pos = d.localPosition;
              if (!chartRect.contains(pos)) return;
              final pts = _computePoints(chartRect, maxY);
              int best = 0;
              double bestDx = double.infinity;
              for (int i = 0; i < pts.length; i++) {
                final d2 = (pts[i].dx - pos.dx).abs();
                if (d2 < bestDx) {
                  bestDx = d2;
                  best = i;
                }
              }
              setState(() {
                hoverIndex = best;
                hoverPosCanvas = pts[best];
              });
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: size.width,
                  height: size.height,
                  child: CustomPaint(
                    painter: _LineAreaChartPainter(
                      data: widget.yValues,
                      xLabels: widget.xValues,
                      ySteps: 5,
                      curveSmoothness: 0.22,
                      lineColor: const Color(0xFF2A63FF),
                      fillColor: const Color(0x332A63FF),
                      gridColor: const Color(0x22000000),
                      labelColor: const Color(0xFF6B7280),
                      yMaxOverride: widget.yMaxOverride,
                      yTickValues: widget.yTickValues,
                      hoverIndex: hoverIndex,
                    ),
                  ),
                ),
                if (hoverIndex != null && hoverPosCanvas != null)
                  Positioned(
                    left: (hoverPosCanvas!.dx - 60).clamp(0, size.width - 160),
                    top: (hoverPosCanvas!.dy - 56).clamp(0, size.height - 72),
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(blurRadius: 12, color: Color(0x22000000)),
                        ],
                        border: Border.all(color: const Color(0x11000000)),
                      ),
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ... di dalam Column tooltip:
                            Text(
                              widget.xValues[hoverIndex!],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (widget.dateRanges != null &&
                                hoverIndex! < widget.dateRanges!.length)
                              Text(
                                widget.dateRanges![hoverIndex!],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            Text(
                              'Rp. ${_formatThousands(widget.yValues[hoverIndex!].round())}',
                            ),
                            if (widget.qtyValues != null &&
                                hoverIndex! < widget.qtyValues!.length)
                              Text(
                                'Qty: ${_formatThousands(widget.qtyValues![hoverIndex!])}',
                              ), // <-- NEW
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ====== Painter (anti-overshoot + highlight) ======
class _LineAreaChartPainter extends CustomPainter {
  _LineAreaChartPainter({
    required this.data,
    required this.xLabels,
    this.ySteps = 5,
    this.curveSmoothness = .22,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    required this.labelColor,
    this.yMaxOverride,
    this.yTickValues,
    this.hoverIndex,
  });

  final List<double> data;
  final List<String> xLabels;
  final int ySteps;
  final double curveSmoothness;
  final Color lineColor, fillColor, gridColor, labelColor;
  final double? yMaxOverride;
  final List<num>? yTickValues;
  final int? hoverIndex;

  final double leftPad = 88, rightPad = 12, topPad = 16, bottomPad = 36;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartRect = Rect.fromLTWH(
      leftPad,
      topPad,
      size.width - leftPad - rightPad,
      size.height - topPad - bottomPad,
    );

    final rawMax = data.reduce(max);
    final maxY = (yMaxOverride ?? _niceMax(rawMax)).toDouble();
    const minY = 0.0;

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    if (yTickValues != null && yTickValues!.isNotEmpty) {
      final ticks = [
        ...{0, ...yTickValues!.map((e) => e.round())},
      ]..sort();
      for (final tv in ticks) {
        final t = (tv - minY) / (maxY - minY);
        final y = _lerp(chartRect.bottom, chartRect.top, t.clamp(0.0, 1.0));
        _dashed(
          canvas,
          Offset(chartRect.left, y),
          Offset(chartRect.right, y),
          gridPaint,
        );
        final tp = _tp(
          _rupiahShort(tv.toDouble()),
          12,
          labelColor,
          FontWeight.w500,
        )..layout(maxWidth: leftPad - 12);
        tp.paint(
          canvas,
          Offset(chartRect.left - tp.width - 8, y - tp.height / 2),
        );
      }
    } else {
      for (int i = 0; i <= ySteps; i++) {
        final t = i / ySteps;
        final y = _lerp(chartRect.bottom, chartRect.top, t);
        _dashed(
          canvas,
          Offset(chartRect.left, y),
          Offset(chartRect.right, y),
          gridPaint,
        );
        final value = _lerp(minY, maxY, t);
        final tp = _tp(_rupiahShort(value), 12, labelColor, FontWeight.w500)
          ..layout(maxWidth: leftPad - 12);
        tp.paint(
          canvas,
          Offset(chartRect.left - tp.width - 8, y - tp.height / 2),
        );
      }
    }

    // label X
    final n = data.length;
    final den = (n - 1) <= 0 ? 1 : (n - 1);
    for (int i = 0; i < n; i++) {
      final dx = chartRect.left + chartRect.width * (i / den);
      final tp = _tp(
        i < xLabels.length ? xLabels[i] : '',
        14,
        Colors.black87,
        FontWeight.w600,
      )..layout();
      tp.paint(canvas, Offset(dx - tp.width / 2, chartRect.bottom + 8));
    }

    // points
    final pts = <Offset>[];
    for (int i = 0; i < n; i++) {
      final dx = chartRect.left + chartRect.width * (i / den);
      final norm = (data[i] - minY) / (maxY - minY == 0 ? 1 : (maxY - minY));
      final dy = chartRect.bottom - chartRect.height * norm;
      pts.add(Offset(dx, dy));
    }

    // path halus anti-overshoot
    final linePath = _smoothSafe(pts, chartRect, smooth: curveSmoothness);

    // fill
    final area = Path.from(linePath)
      ..lineTo(pts.last.dx, chartRect.bottom)
      ..lineTo(pts.first.dx, chartRect.bottom)
      ..close();
    canvas.drawPath(area, Paint()..color = fillColor);

    // garis
    final pen = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, pen);

    // highlight
    if (hoverIndex != null && hoverIndex! >= 0 && hoverIndex! < pts.length) {
      final p = pts[hoverIndex!];
      final guide = Paint()
        ..color = lineColor.withOpacity(.25)
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(p.dx, chartRect.top),
        Offset(p.dx, chartRect.bottom),
        guide,
      );
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 4, Paint()..color = lineColor);
    }
  }

  // smooth + clamp CP agar tak “nyungsep”
  Path _smoothSafe(List<Offset> pts, Rect bounds, {required double smooth}) {
    if (pts.length < 2) return Path();
    final p = Path()..moveTo(pts[0].dx, pts[0].dy);

    Offset clampCP(Offset cp, Offset a, Offset b) {
      final minY = min(a.dy, b.dy), maxY = max(a.dy, b.dy);
      final minX = min(a.dx, b.dx), maxX = max(a.dx, b.dx);
      return Offset(
        cp.dx.clamp(minX, maxX).clamp(bounds.left, bounds.right).toDouble(),
        cp.dy.clamp(minY, maxY).clamp(bounds.top, bounds.bottom).toDouble(),
      );
    }

    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i == 0 ? pts[i] : pts[i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;

      var cp1 = p1 + (p2 - p0) * smooth;
      var cp2 = p2 - (p3 - p1) * smooth;

      cp1 = clampCP(cp1, p1, p2);
      cp2 = clampCP(cp2, p1, p2);

      final mid = Offset((cp1.dx + cp2.dx) / 2, (cp1.dy + cp2.dy) / 2);
      p.quadraticBezierTo(cp1.dx, cp1.dy, mid.dx, mid.dy);
      p.quadraticBezierTo(cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return p;
  }

  void _dashed(
    Canvas c,
    Offset a,
    Offset b,
    Paint paint, {
    double dash = 6,
    double gap = 6,
  }) {
    final total = (b - a).distance;
    final dir = (b - a) / total;
    double covered = 0;
    while (covered < total) {
      final s = a + dir * covered;
      final e = a + dir * min(covered + dash, total);
      c.drawLine(s, e, paint);
      covered += dash + gap;
    }
  }

  String _rupiahShort(double v) {
    if (v >= 1e9)
      return 'Rp. ${(v / 1e9).toStringAsFixed(v % 1e9 == 0 ? 0 : 1)} M';
    if (v >= 1e6)
      return 'Rp. ${(v / 1e6).toStringAsFixed(v % 1e6 == 0 ? 0 : 1)} Juta';
    return 'Rp. ${_formatThousands(v.round())}';
  }

  TextPainter _tp(String text, double size, Color color, FontWeight w) =>
      TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: size, color: color, fontWeight: w),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      );

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant _LineAreaChartPainter old) =>
      old.data != data ||
      old.xLabels != xLabels ||
      old.ySteps != ySteps ||
      old.lineColor != lineColor ||
      old.fillColor != fillColor ||
      old.gridColor != gridColor ||
      old.labelColor != labelColor ||
      old.curveSmoothness != curveSmoothness ||
      old.yMaxOverride != yMaxOverride ||
      old.yTickValues != yTickValues ||
      old.hoverIndex != hoverIndex;
}

/// ===== util kecil =====
double _niceMax(double raw) {
  if (raw <= 0) return 1.0;
  const steps = [
    10000,
    20000,
    25000,
    40000,
    50000,
    80000,
    100000,
    200000,
    500000,
    1000000,
    2000000,
    5000000,
    10000000,
  ];
  for (final s in steps) {
    final m = (raw / s).ceil() * s;
    if (m >= raw && (m - raw) / (m == 0 ? 1 : m) < 0.45) return m.toDouble();
  }
  final p10 = pow(10, raw.toStringAsFixed(0).length - 1).toDouble();
  return ((raw / p10).ceil() * p10).toDouble();
}

String _formatThousands(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    b.write(s[s.length - 1 - i]);
    if (i % 3 == 2 && i != s.length - 1) b.write('.');
  }
  return b.toString().split('').reversed.join();
}
