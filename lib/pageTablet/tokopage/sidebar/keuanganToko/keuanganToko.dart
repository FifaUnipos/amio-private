import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../models/tokoModel/keuanganModel.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import '../../../../utils/component/component_showModalBottom.dart';
import '../../../../../services/apimethod.dart';

import '../../../../../utils/component/component_button.dart';
import '../../../../main.dart';
import '../../../../utils/component/component_color.dart';
import '../../../../utils/component/component_loading.dart';

class LihatKeuanganToko extends StatefulWidget {
  String token;

  LihatKeuanganToko({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<LihatKeuanganToko> createState() => _LihatKeuanganTokoState();
}

class _LihatKeuanganTokoState extends State<LihatKeuanganToko>
    with TickerProviderStateMixin {
  List<PendapatanLainModel>? datasPendapatan;
  List<PengeluaranLainModel>? datasPengeluaran;
  TextEditingController keteranganRekon = TextEditingController();
  TextEditingController conKeterangan = TextEditingController();
  TextEditingController conPemasukkan = TextEditingController();
  PageController pageController = PageController();
  TabController? tabController;

  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};

  String? yearRekon, monthRekon;
  int tapTrue = 0;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        datasPendapatan = await getPendapatan(
          context,
          widget.token,
          'IN',
          '',
        );
        setState(() {});
      },
    );

    pageController = PageController(
      initialPage: 0,
      keepPage: true,
      viewportFraction: 1,
    );

    setState(() {
      // print(datasPendapatan.toString());

      datasPendapatan;
    });
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    conKeterangan.dispose();
    conPemasukkan.dispose();
    super.dispose();
  }

  // double width = MediaQuery.of(context).size.width;
  double? width;
  double widtValue = 80;

  double heightInformation = 0;
  double widthInformation = 0;
  String? ppmId;
  int selectedIndex = 0;

  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    bool isFalseAvailable = selectedFlag.containsValue(false);

    return WillPopScope(
      onWillPop: () async {
        if (tabController!.index.round() == 0) {
          showModalBottomExit(context);
          return false;
        } else {
          pageController.jumpToPage(0);
          tabController!.animateTo(tabController!.index - 1);
          print(tabController!.previousIndex);
          return Future.value(false);
        }
      },
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.all(size16),
          margin: EdgeInsets.all(size16),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.circular(size16),
          ),
          child: PageView(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              mainPageKeuangan(context, isFalseAvailable),
              tambahPendapatan(setState, context),
              tambahPengeluaran(setState, context),
              ubahPendapatanPage(setState, context),
              ubahPengeluaranPage(setState, context),
            ],
          ),
        ),
      ),
    );
  }

  mainPageKeuangan(BuildContext context, bool isFalseAvailable) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keuangan',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    nameToko ?? '',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              ),
              tabController!.index == 2
                  ? GestureDetector(
                      onTap: () {
                        showModalBottomProfile(
                          context,
                          MediaQuery.of(context).size.height / 2.8,
                          Column(
                            children: [
                              dividerShowdialog(),
                              SizedBox(height: size16),
                              Text(
                                'Kamu yakin ingin Memposting Data Rekonsialisasi?',
                                style:
                                    heading1(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                              SizedBox(height: size8),
                              Text(
                                'Data yang telah diposting tidak dapat diubah kembali.',
                                style:
                                    heading2(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                              SizedBox(height: size32),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: buttonXLoutline(
                                        Center(
                                          child: Text(
                                            'Batal',
                                            style: heading3(FontWeight.w600,
                                                primary500, 'Outfit'),
                                          ),
                                        ),
                                        MediaQuery.of(context).size.width,
                                        primary500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        whenLoading(context);
                                        postingRekon(context, widget.token,
                                            yearRekon, monthRekon, '');
                                      },
                                      child: buttonXL(
                                        Center(
                                          child: Text(
                                            'Ya, Posting',
                                            style: heading3(FontWeight.w600,
                                                bnw100, 'Outfit'),
                                          ),
                                        ),
                                        MediaQuery.of(context).size.width,
                                        // primary500,
                                        // primary500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      child: buttonXL(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(PhosphorIcons.plus, color: bnw100),
                            SizedBox(width: size12),
                            Text(
                              'Posting',
                              style:
                                  heading3(FontWeight.w600, bnw100, 'Outfit'),
                            ),
                          ],
                        ),
                        0,
                      ))
                  : SizedBox(),
            ],
          ),
          // SizedBox(
          //   width: MediaQuery.of(context).size.width,
          //   child: TabBar(
          //     controller: tabController,
          //     unselectedLabelColor: bnw600,
          //     labelColor: primary500,
          //     labelStyle: heading2(FontWeight.w400, bnw900, 'Outfit'),
          //     physics: const NeverScrollableScrollPhysics(),
          //     onTap: (value) {
          //       setState(() {
          //         if (value == 0) {
          //           selectedIndex = 0;
          //         } else if (value == 1) {
          //           selectedIndex = 1;
          //         } else if (value == 2) {
          //           selectedIndex = 2;
          //         }
          //       });
          //     },
          //     tabs: const [
          //       // Tab(
          //       //   text: 'Pendapatan Lain-Lain',
          //       // ),
          //       // Tab(
          //       //   text: 'Pengeluaran Lain-Lain',
          //       // ),
          //       Tab(
          //         text: 'Rekonsiliasi',
          //       ),
          //     ],
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 10, bottom: 10),
          //   child: buttonLoutline(
          //     GestureDetector(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: [
          //           Row(
          //             children: [
          //               Text(
          //                 'Urutkan',
          //                 style: heading3(FontWeight.w600, bnw900, 'Outfit'),
          //               ),
          //               Text(
          //                 ' dari Nama Toko A ke Z',
          //                 style: heading3(FontWeight.w400, bnw600, 'Outfit'),
          //               ),
          //             ],
          //           ),
          //           const Icon(PhosphorIcons.caret_down),
          //         ],
          //       ),
          //     ),
          //     bnw300,
          //   ),
          // ),
          SizedBox(height: size16),
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                getYear(),
                getMonth(),
                RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                    await getRekon(widget.token, yearRekon, monthRekon, '');
                  },
                  child: FutureBuilder(
                    future: getRekon(widget.token, yearRekon, monthRekon, ''),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        //List<RekonModel>? data = snapshot.data;
                        var data = snapshot.data;
                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: primary500,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(size12),
                                  topRight: Radius.circular(size12),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              tabController!.animateTo(
                                                1,
                                                duration: Duration
                                                    .zero, // kurva animasi
                                              );
                                              setState(() {});
                                            },
                                            child: Icon(
                                                PhosphorIcons.arrow_left,
                                                color: bnw100),
                                          ),
                                          SizedBox(width: size16),
                                          Text(
                                            'Rekonsiliasi - Bulan ${data['bulanTahun']}',
                                            style: heading4(FontWeight.w700,
                                                bnw100, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                                child: Container(
                              decoration: BoxDecoration(
                                color: primary100,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(size12),
                                  bottomRight: Radius.circular(size12),
                                ),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: data['rekonsiliasi'].length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1.5,
                                          color: bnw300,
                                        ),
                                      ),
                                    ),
                                    child: ExpansionTile(
                                      onExpansionChanged: (bool expanded) {
                                        setState(() {
                                          if (expanded) {
                                            setState(() {
                                              _expandedIndex = index;
                                            });
                                          }
                                        });
                                      },
                                      initiallyExpanded:
                                          _expandedIndex == index,
                                      backgroundColor: primary200,
                                      trailing: Icon(
                                        PhosphorIcons.caret_down_fill,
                                        color: bnw900,
                                      ),
                                      title: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  data['rekonsiliasi'][index]
                                                      ['hari'],
                                                  style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit')),
                                              Text(
                                                  data['rekonsiliasi'][index]
                                                      ['tanggal'],
                                                  style: heading4(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit')),
                                            ],
                                          ),
                                          Spacer(),
                                          data['rekonsiliasi'][index]['status']
                                                          ['belumDiCek']
                                                      .toString() ==
                                                  '0'
                                              ? Container()
                                              : buttonLoutlineColor(
                                                  Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text('Belum Dicek : ',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w600,
                                                                  danger500,
                                                                  'Outfit')),
                                                          Text(
                                                              data['rekonsiliasi']
                                                                              [
                                                                              index]
                                                                          [
                                                                          'status']
                                                                      [
                                                                      'belumDiCek']
                                                                  .toString(),
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w600,
                                                                  danger500,
                                                                  'Outfit')),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  danger100,
                                                  danger100,
                                                ),
                                          SizedBox(width: size16),
                                          data['rekonsiliasi'][index]['status']
                                                          ['tidakSesuai']
                                                      .toString() ==
                                                  '0'
                                              ? Container()
                                              : buttonLoutlineColor(
                                                  Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                              'Tidak Sesuai : ',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw500,
                                                                  'Outfit')),
                                                          Text(
                                                              data['rekonsiliasi']
                                                                              [
                                                                              index]
                                                                          [
                                                                          'status']
                                                                      [
                                                                      'tidakSesuai']
                                                                  .toString(),
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw500,
                                                                  'Outfit')),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  bnw200,
                                                  bnw200,
                                                ),
                                          SizedBox(width: size16),
                                          data['rekonsiliasi'][index]['status']
                                                          ['sesuai']
                                                      .toString() ==
                                                  '0'
                                              ? Container()
                                              : buttonLoutlineColor(
                                                  Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text('Sesuai : ',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w600,
                                                                  succes500,
                                                                  'Outfit')),
                                                          Text(
                                                              data['rekonsiliasi']
                                                                              [
                                                                              index]
                                                                          [
                                                                          'status']
                                                                      ['sesuai']
                                                                  .toString(),
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w600,
                                                                  succes500,
                                                                  'Outfit')),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  succes100,
                                                  succes100,
                                                ),
                                          SizedBox(width: size16),
                                        ],
                                      ),
                                      children: [
                                        if (data['rekonsiliasi'][index]
                                                ['detail']
                                            .isEmpty)
                                          Container(),
                                        Container(
                                          width: double.infinity,
                                          margin: EdgeInsets.all(size16),
                                          child: Wrap(
                                            spacing: size8,
                                            runSpacing: size8,
                                            children: data['rekonsiliasi']
                                                    [index]['detail']
                                                .map<Widget>((detailItem) {
                                              return Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.7,
                                                padding: EdgeInsets.all(size8),
                                                decoration: BoxDecoration(
                                                  color: bnw100,
                                                  border:
                                                      Border.all(color: bnw300),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${detailItem['payment_method']['payment_method']}',
                                                          style: heading4(
                                                              FontWeight.w600,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        Text(
                                                            FormatCurrency
                                                                .convertToIdr(
                                                                    detailItem[
                                                                        'amount']),
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit')),
                                                        // Add other details from 'detailItem'
                                                      ],
                                                    ),
                                                    Spacer(),
                                                    detailItem['isDone'] == '0'
                                                        ? buttonLoutlineColor(
                                                            Row(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                        'Belum Dicek',
                                                                        style: heading4(
                                                                            FontWeight.w600,
                                                                            danger500,
                                                                            'Outfit')),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            danger100,
                                                            danger100,
                                                          )
                                                        : detailItem[
                                                                    'isDone'] ==
                                                                '1'
                                                            ? buttonLoutlineColor(
                                                                Row(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                            'Tidak Sesuai',
                                                                            style: heading4(
                                                                                FontWeight.w600,
                                                                                bnw900,
                                                                                'Outfit')),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                bnw200,
                                                                bnw200,
                                                              )
                                                            : buttonLoutlineColor(
                                                                Row(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                            'Sesuai',
                                                                            style: heading4(
                                                                                FontWeight.w600,
                                                                                succes500,
                                                                                'Outfit')),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                succes100,
                                                                succes100,
                                                              ),
                                                    SizedBox(width: size16),
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (detailItem[
                                                                'isDone'] ==
                                                            '0') {
                                                          tapTrue = 0;
                                                        } else if (detailItem[
                                                                'isDone'] ==
                                                            '1') {
                                                          tapTrue = 1;
                                                        } else if (detailItem[
                                                                'isDone'] ==
                                                            '2') {
                                                          tapTrue = 2;
                                                        } else {
                                                          tapTrue = 0;
                                                        }

                                                        showModalBottomSheet(
                                                          constraints:
                                                              const BoxConstraints(
                                                            maxWidth:
                                                                double.infinity,
                                                          ),
                                                          isScrollControlled:
                                                              true,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25),
                                                          ),
                                                          context: context,
                                                          builder: (context) =>
                                                              StatefulBuilder(
                                                            builder: (context,
                                                                    setState) =>
                                                                IntrinsicHeight(
                                                              child: Container(
                                                                padding: EdgeInsets.only(
                                                                    bottom: MediaQuery.of(
                                                                            context)
                                                                        .viewInsets
                                                                        .bottom),
                                                                // height: MediaQuery.of(context).size.height / 1,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: bnw100,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topRight: Radius
                                                                        .circular(
                                                                            12),
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            12),
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          size32,
                                                                          size16,
                                                                          size32,
                                                                          size32),
                                                                  child: Column(
                                                                    children: [
                                                                      dividerShowdialog(),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          SizedBox(
                                                                              height: size16),
                                                                          Text(
                                                                            'Tunai',
                                                                            style: heading1(
                                                                                FontWeight.w700,
                                                                                bnw900,
                                                                                'Outfit'),
                                                                          ),
                                                                          Text(
                                                                            'Konfirmasi data sesuai atau tidak tidak ',
                                                                            style: heading4(
                                                                                FontWeight.w400,
                                                                                bnw700,
                                                                                'Outfit'),
                                                                          ),
                                                                          SizedBox(
                                                                              height: size16),
                                                                          Container(
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  'Pilih Tipe Pesanan',
                                                                                  style: heading2(FontWeight.w400, bnw900, 'Outfit'),
                                                                                ),
                                                                                SizedBox(height: size16),
                                                                                Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: GestureDetector(
                                                                                        onTap: () {
                                                                                          setState(() {
                                                                                            tapTrue = 2;
                                                                                          });
                                                                                        },
                                                                                        child: IntrinsicWidth(
                                                                                          child: Container(
                                                                                            height: size56,
                                                                                            padding: EdgeInsets.symmetric(horizontal: size20),
                                                                                            decoration: ShapeDecoration(
                                                                                              color: tapTrue == 2 ? primary100 : bnw100,
                                                                                              shape: RoundedRectangleBorder(
                                                                                                side: BorderSide(
                                                                                                  width: width2,
                                                                                                  color: tapTrue == 2 ? primary500 : bnw300,
                                                                                                ),
                                                                                                borderRadius: BorderRadius.circular(size8),
                                                                                              ),
                                                                                            ),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                Text('Sesuai', style: heading3(FontWeight.w400, tapTrue == 2 ? primary500 : bnw900, 'Outfit')),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(width: size16),
                                                                                    Expanded(
                                                                                      child: GestureDetector(
                                                                                        onTap: () {
                                                                                          setState(() {
                                                                                            tapTrue = 1;
                                                                                          });
                                                                                        },
                                                                                        child: IntrinsicWidth(
                                                                                          child: Container(
                                                                                            height: size56,
                                                                                            padding: EdgeInsets.symmetric(horizontal: size20),
                                                                                            decoration: ShapeDecoration(
                                                                                              color: tapTrue == 1 ? primary100 : bnw100,
                                                                                              shape: RoundedRectangleBorder(
                                                                                                side: BorderSide(
                                                                                                  width: width2,
                                                                                                  color: tapTrue == 1 ? primary500 : bnw300,
                                                                                                ),
                                                                                                borderRadius: BorderRadius.circular(size8),
                                                                                              ),
                                                                                            ),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                Text('Tidak Sesuai', style: heading3(FontWeight.w400, tapTrue == 1 ? primary500 : bnw900, 'Outfit')),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: size16),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                'Keterangan ',
                                                                                style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                                                                              ),
                                                                              Text(
                                                                                '*',
                                                                                style: heading4(FontWeight.w400, danger500, 'Outfit'),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          FocusScope(
                                                                            child:
                                                                                Focus(
                                                                              onFocusChange: (value) {
                                                                                setState(() {});
                                                                              },
                                                                              child: TextFormField(
                                                                                controller: keteranganRekon,
                                                                                cursorColor: primary500,
                                                                                style: heading2(
                                                                                  FontWeight.w600,
                                                                                  bnw900,
                                                                                  'Outfit',
                                                                                ),
                                                                                decoration: InputDecoration(
                                                                                    focusedBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        width: 2,
                                                                                        color: primary500,
                                                                                      ),
                                                                                    ),
                                                                                    focusColor: primary500,
                                                                                    hintText: 'Cth : Tidak sesuai dengan pengeluaran',
                                                                                    hintStyle: heading2(
                                                                                      FontWeight.w600,
                                                                                      bnw400,
                                                                                      'Outfit',
                                                                                    )),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              size32),
                                                                      tapTrue ==
                                                                              0
                                                                          ? Container()
                                                                          : Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: GestureDetector(
                                                                                    onTap: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: buttonXLoutline(
                                                                                      Center(
                                                                                        child: Text(
                                                                                          'Batal',
                                                                                          style: heading3(FontWeight.w600, primary500, 'Outfit'),
                                                                                        ),
                                                                                      ),
                                                                                      MediaQuery.of(context).size.width,
                                                                                      primary500,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: size16),
                                                                                Expanded(
                                                                                  child: GestureDetector(
                                                                                    onTap: () {
                                                                                      whenLoading(context);
                                                                                      saveRekon(context, widget.token, detailItem['id'], tapTrue.toString(), keteranganRekon.text);
                                                                                      errorText = '';

                                                                                      setState(() {
                                                                                        getRekon(widget.token, yearRekon, monthRekon, '');
                                                                                        data = snapshot.data;
                                                                                      });
                                                                                    },
                                                                                    child: buttonXL(
                                                                                      Center(
                                                                                        child: Text(
                                                                                          'Simpan',
                                                                                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                                                                                        ),
                                                                                      ),
                                                                                      MediaQuery.of(context).size.width,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Icon(
                                                        PhosphorIcons
                                                            .pencil_line,
                                                        color: primary500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )),
                            SizedBox(height: size16),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showModalBottomSheet(
                                          constraints: const BoxConstraints(
                                            maxWidth: double.infinity,
                                          ),
                                          isScrollControlled: true,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          context: context,
                                          builder: (context) {
                                            return IntrinsicHeight(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom),
                                                decoration: BoxDecoration(
                                                  color: bnw100,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(size12),
                                                    topLeft:
                                                        Radius.circular(size12),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      size32,
                                                      size16,
                                                      size32,
                                                      size32),
                                                  child: Column(
                                                    children: [
                                                      dividerShowdialog(),
                                                      SizedBox(height: size16),
                                                      Container(
                                                        width: double.infinity,
                                                        color: bnw100,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Detail',
                                                              style: heading2(
                                                                  FontWeight
                                                                      .w700,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            Text(
                                                              'Tentukan data yang akan tampil',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw600,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size32),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    children: [
                                                                      detailCard(
                                                                          data,
                                                                          'Total Keseluruhan',
                                                                          'total_keseluruhan',
                                                                          false),
                                                                      SizedBox(
                                                                          height:
                                                                              size16),
                                                                      detailCard(
                                                                          data,
                                                                          'Tidak Sesuai',
                                                                          'tidakSesuai',
                                                                          true),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        size16),
                                                                Expanded(
                                                                  child: Column(
                                                                    children: [
                                                                      detailCard(
                                                                          data,
                                                                          'Sesuai',
                                                                          'sesuai',
                                                                          true),
                                                                      SizedBox(
                                                                          height:
                                                                              size16),
                                                                      detailCard(
                                                                          data,
                                                                          'Belum Dicek',
                                                                          'belumDiCek',
                                                                          true),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: size32),
                                                      SizedBox(
                                                        width: double.infinity,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: buttonXL(
                                                            Center(
                                                              child: Text(
                                                                'Selesai',
                                                                style: heading3(
                                                                    FontWeight
                                                                        .w600,
                                                                    bnw100,
                                                                    'Outfit'),
                                                              ),
                                                            ),
                                                            0,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(size8),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(size8),
                                        border: Border.all(color: bnw300),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: primary100,
                                              borderRadius:
                                                  BorderRadius.circular(size8),
                                            ),
                                            padding: EdgeInsets.all(size12),
                                            child: Center(
                                              child: Icon(
                                                PhosphorIcons.money_fill,
                                                color: primary500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: size16),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Total Keseluruhan',
                                                style: heading3(FontWeight.w600,
                                                    bnw900, 'Outfit'),
                                              ),
                                              Text(
                                                  FormatCurrency.convertToIdr(
                                                      data[
                                                          'total_keseluruhan']),
                                                  style: heading3(
                                                      FontWeight.w700,
                                                      primary500,
                                                      'Outfit')),
                                            ],
                                          ),
                                          Spacer(),
                                          Icon(
                                            PhosphorIcons.dots_three_vertical,
                                            color: bnw900,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: size16),
                                pendapatanDetail(data, 'Belum Dicek',
                                    'belumDiCek', PhosphorIcons.square),
                                SizedBox(width: size16),
                                pendapatanDetail(data, 'Tidak Sesuai',
                                    'tidakSesuai', PhosphorIcons.x),
                                SizedBox(width: size16),
                                pendapatanDetail(data, 'Sesuai', 'sesuai',
                                    PhosphorIcons.check_square),
                              ],
                            )
                          ],
                        );
                      } else if (snapshot.hasError) {
                        print(snapshot.error);
                        print(snapshot.data);

                        return Center(
                          child: SizedBox(
                            child: loading(),
                          ),
                        );
                      }
                      return Center(
                        child: SizedBox(
                          child: loading(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container detailCard(data, title, subTitle, bool detail) {
    return Container(
        padding: EdgeInsets.all(size8),
        decoration: BoxDecoration(
          border: Border.all(color: bnw300),
          borderRadius: BorderRadius.circular(
            size16,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(size8),
              decoration: BoxDecoration(
                color: primary100,
                borderRadius: BorderRadius.circular(size8),
              ),
              child: Center(
                child: Icon(
                  PhosphorIcons.money_fill,
                  color: primary500,
                ),
              ),
            ),
            SizedBox(width: size8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: heading3(FontWeight.w600, bnw900, 'Outfit')),
                Text(
                    FormatCurrency.convertToIdr(
                      detail == true
                          ? data['detail'][subTitle]
                          : data[subTitle],
                    ).toString(),
                    style: heading2(FontWeight.w700, primary500, 'Outfit')),
              ],
            )
          ],
        ));
  }

  Row getYear() {
    return Row(
      children: [
        AnimatedContainer(
          duration: Duration(seconds: 1),
          width: width,
          child: Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primary500,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size12),
                      topRight: Radius.circular(size12),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.calendar_blank_fill,
                                  color: bnw100),
                              SizedBox(width: size16),
                              Text(
                                'Pilih Tahun Rekonsiliasi',
                                style:
                                    heading4(FontWeight.w700, bnw100, 'Outfit'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primary100,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(size12),
                        bottomRight: Radius.circular(size12),
                      ),
                    ),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        initState();
                      },
                      child: FutureBuilder(
                          future: getYearRekon(widget.token, ''),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var data = snapshot.data;
                              // print(snapshot.data);
                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: snapshot.data.length,
                                // physics: BouncingScrollPhysics(),
                                itemBuilder: (builder, index) {
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          setState(() {
                                            yearRekon = (data![index]['year']
                                                .toString());
                                          });
                                          tabController!.animateTo(
                                            1,
                                            duration: Duration.zero,
                                          );
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.fromLTRB(
                                              16, size12, 0, size12),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                        PhosphorIcons
                                                            .calendar_blank_fill,
                                                        color: bnw900),
                                                    SizedBox(width: size16),
                                                    Text(
                                                      data![index]['year']
                                                          .toString(),
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(thickness: 1.2)
                                    ],
                                  );
                                },
                              );
                            }

                            return Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: loading(),
                              ),
                            );
                          }),
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

  getMonth() {
    return Row(
      children: [
        AnimatedContainer(
          duration: Duration(seconds: 1),
          width: width,
          child: Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primary500,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size12),
                      topRight: Radius.circular(size12),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  tabController!.animateTo(
                                    0,
                                    duration: Duration.zero,
                                  );
                                },
                                child: Icon(PhosphorIcons.arrow_left,
                                    color: bnw100),
                              ),
                              SizedBox(width: size16),
                              Text(
                                'Bulan',
                                style:
                                    heading4(FontWeight.w700, bnw100, 'Outfit'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primary100,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(size12),
                        bottomRight: Radius.circular(size12),
                      ),
                    ),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        getMonthRekon(widget.token, yearRekon, '');
                        setState(() {});
                      },
                      child: FutureBuilder(
                          future: getMonthRekon(widget.token, yearRekon, ''),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var data = snapshot.data;
                              // print(snapshot.data);
                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: snapshot.data.length,
                                // physics: BouncingScrollPhysics(),
                                itemBuilder: (builder, index) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setState(() {
                                        monthRekon =
                                            data![index]['bulan'].toString();
                                        getRekon(widget.token, yearRekon,
                                            monthRekon, '');
                                      });

                                      tabController!.animateTo(
                                        2,
                                        duration: Duration.zero,
                                      );
                                      setState(() {});
                                    },
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              16, size12, size12, size12),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                      PhosphorIcons
                                                          .calendar_blank_fill,
                                                      color: bnw900),
                                                  SizedBox(width: size16),
                                                  Text(
                                                    data![index]['bulanTahun']
                                                        .toString(),
                                                    style: heading4(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit'),
                                                  ),
                                                ],
                                              ),
                                              data![index]['angka'] == 0
                                                  ? Container(
                                                      width: 80,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: danger100,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'Sesuai',
                                                          style: heading4(
                                                              FontWeight.w600,
                                                              danger500,
                                                              'Outfit'),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 80,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: succes100,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'Sesuai ',
                                                          style: heading4(
                                                              FontWeight.w600,
                                                              succes600,
                                                              'Outfit'),
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                        Divider(thickness: 1.2)
                                      ],
                                    ),
                                  );
                                },
                              );
                            }

                            return Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: loading(),
                              ),
                            );
                          }),
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

  Container pendapatanDetail(data, title, status, iconData) {
    return Container(
        padding: EdgeInsets.all(size8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size8),
          border: Border.all(color: bnw300),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: primary100,
                borderRadius: BorderRadius.circular(size8),
              ),
              padding: EdgeInsets.all(size12),
              child: Center(
                child: Icon(
                  iconData,
                  color: primary500,
                ),
              ),
            ),
            SizedBox(width: size16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                ),
                Text(data['status']['$status'].toString(),
                    style: heading3(FontWeight.w700, primary500, 'Outfit')),
              ],
            ),
            SizedBox(width: size16),
          ],
        ));
  }

  pendapatanLain(bool isFalseAvailable) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          width: width,
          child: Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primary500,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _selectAll,
                          child: SizedBox(
                            width: width,
                            child: Icon(
                              isFalseAvailable
                                  ? PhosphorIcons.square
                                  : PhosphorIcons.check_square_fill,
                              color: bnw100,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            'Tanggal',
                            style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue + 40,
                          child: Text(
                            'Jenis Pendapatan',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            'Keterangan',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            'Nilai',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue + 10,
                          child: Text(
                            'ID Pendaatan',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            '',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primary100,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: datasPendapatan!.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (builder, index) {
                        PendapatanLainModel data = datasPendapatan![index];
                        selectedFlag[index] = selectedFlag[index] ?? false;
                        bool? isSelected = selectedFlag[index];

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      onTap(isSelected, index);
                                    },
                                    child: SizedBox(
                                      width: width,
                                      child:
                                          _buildSelectIcon(isSelected!, data),
                                    ),
                                  ),
                                  SizedBox(
                                    width: widtValue,
                                    child: Text(
                                      datasPendapatan![index]
                                          .tanggal
                                          .toString(),
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: widtValue + 40,
                                    child: Text(
                                      datasPendapatan![index]
                                          .peruntukanPPM
                                          .toString(),
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: widtValue,
                                    child: Text(
                                      datasPendapatan![index]
                                          .deskripsi
                                          .toString(),
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: widtValue,
                                    child: Text(
                                      FormatCurrency.convertToIdr(
                                              datasPendapatan![index].jumlah)
                                          .toString(),
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: widtValue + 10,
                                    child: Text(
                                      datasPendapatan![index].pPMID.toString(),
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        ppmId = datasPendapatan![index].pPMID;
                                      });
                                      pageController.jumpToPage(3);
                                    },
                                    child: SizedBox(
                                        width: widtValue,
                                        child: buttonLoutline(
                                          Row(
                                            children: [
                                              Icon(PhosphorIcons.pencil,
                                                  color: bnw900),
                                              Text('Atur',
                                                  style: heading4(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit')),
                                            ],
                                          ),
                                          bnw300,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(thickness: 1.2)
                          ],
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

  tambahPendapatan(StateSetter setState, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  pageController.jumpToPage(0);
                },
                child: Icon(PhosphorIcons.arrow_left, size: 24),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Pemasukkan',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Tamabah Pemasukkan keuangan lain-lain',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: ListView(
              // padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              children: [
                fieldAddDrop(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                jenisList(context),
                fieldAdd(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                fieldAdd(
                  'Total Pemasukkan',
                  'Rp. 1.500.000',
                  conPemasukkan,
                  TextInputType.number,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  print('hallo');
                  // Clipboard.setData(ClipboardData(text: img64));
                },
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Simpan & Tambah Baru',
                      style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                  bnw900,
                ),
              ),
              GestureDetector(
                onTap: () {
                  createPendapatan(
                    context,
                    widget.token,
                    'Beliang Bar',
                    'IN',
                    conKeterangan.text,
                    conPemasukkan.text,
                    '',
                    pageController,
                  );

                  initState();
                  setState(() {});
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Tambah',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  ubahPendapatanPage(StateSetter setState, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  pageController.jumpToPage(0);
                },
                child: Icon(PhosphorIcons.arrow_left, size: 24),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubah Pemasukkan',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Ubah Pemasukkan keuangan lain-lain',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: ListView(
              // padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              children: [
                fieldAddDrop(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                jenisList(context),
                fieldAdd(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                fieldAdd(
                  'Total Pemasukkan',
                  'Rp. 1.500.000',
                  conPemasukkan,
                  TextInputType.number,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  print('hallo');
                  // Clipboard.setData(ClipboardData(text: img64));
                },
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Simpan & Tambah Baru',
                      style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                  bnw900,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ubahPendapatan(
                    context,
                    widget.token,
                    ppmId,
                    'beli',
                    conKeterangan.text,
                    conPemasukkan.text,
                    '',
                    pageController,
                  );

                  initState();
                  setState(() {});
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Tambah',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  pengeluaranLain(bool isFalseAvailable) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          width: width,
          child: Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primary500,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _selectAll,
                          child: SizedBox(
                            width: width,
                            child: Icon(
                              isFalseAvailable
                                  ? PhosphorIcons.square
                                  : PhosphorIcons.check_square_fill,
                              color: bnw100,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            'Tanggal',
                            style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue + 40,
                          child: Text(
                            'Jenis Pendapatan',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            'Keterangan',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            'Nilai',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue + 10,
                          child: Text(
                            'ID Pendaatan',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            '',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primary100,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: FutureBuilder(
                        future: getPengeluaran(
                          context,
                          widget.token,
                          'OUT',
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data;
                            // print(snapshot.data);
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: snapshot.data.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (builder, index) {
                                selectedFlag[index] =
                                    selectedFlag[index] ?? false;
                                bool? isSelected = selectedFlag[index];

                                Widget _buildSelectIcon2(
                                  bool isSelected,
                                  data,
                                ) {
                                  return Icon(
                                    isSelected
                                        ? PhosphorIcons.check_square_fill
                                        : PhosphorIcons.square,
                                    color: primary500,
                                  );
                                }

                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 12, 0, 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              onTap(isSelected, index);
                                            },
                                            child: SizedBox(
                                              width: width,
                                              child: _buildSelectIcon2(
                                                  isSelected!, data),
                                            ),
                                          ),
                                          SizedBox(
                                            width: widtValue,
                                            child: Text(
                                              data![index]['tanggal']
                                                  .toString(),
                                              style: heading4(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: widtValue + 40,
                                            child: Text(
                                              data![index]['peruntukan_PPM']
                                                  .toString(),
                                              style: heading4(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: widtValue,
                                            child: Text(
                                              data![index]['deskripsi']
                                                  .toString(),
                                              style: heading4(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: widtValue,
                                            child: Text(
                                              FormatCurrency.convertToIdr(
                                                      data![index]['jumlah'])
                                                  .toString(),
                                              style: heading4(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: widtValue + 10,
                                            child: Text(
                                              data![index]['PPM_ID'].toString(),
                                              style: heading4(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                ppmId = data![index]['PPM_ID'];
                                              });
                                              pageController.jumpToPage(4);
                                            },
                                            child: SizedBox(
                                                width: widtValue,
                                                child: buttonLoutline(
                                                  Row(
                                                    children: [
                                                      Icon(PhosphorIcons.pencil,
                                                          color: bnw900),
                                                      Text('Atur',
                                                          style: heading4(
                                                              FontWeight.w600,
                                                              bnw900,
                                                              'Outfit')),
                                                    ],
                                                  ),
                                                  bnw300,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(thickness: 1.2)
                                  ],
                                );
                              },
                            );
                          }

                          return loading();
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  tambahPengeluaran(StateSetter setState, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  pageController.jumpToPage(0);
                },
                child: Icon(PhosphorIcons.arrow_left, size: 24),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Pemasukkan',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Tamabah Pemasukkan keuangan lain-lain',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: ListView(
              // padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              children: [
                fieldAddDrop(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                jenisList(context),
                fieldAdd(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                fieldAdd(
                  'Total Pemasukkan',
                  'Rp. 1.500.000',
                  conPemasukkan,
                  TextInputType.number,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  print('hallo');
                  // Clipboard.setData(ClipboardData(text: img64));
                },
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Simpan & Tambah Baru',
                      style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                  bnw900,
                ),
              ),
              GestureDetector(
                onTap: () {
                  createPendapatan(
                    context,
                    widget.token,
                    'Beli barang',
                    'OUT',
                    conKeterangan.text,
                    conPemasukkan.text,
                    '',
                    pageController,
                  );

                  initState();
                  setState(() {});
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Tambah',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  ubahPengeluaranPage(StateSetter setState, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  pageController.jumpToPage(0);
                },
                child: Icon(PhosphorIcons.arrow_left, size: 24),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubah Pengeluaran',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Ubah Pengeluaran keuangan lain-lain',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: ListView(
              // padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              children: [
                fieldAddDrop(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                jenisList(context),
                fieldAdd(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                fieldAdd(
                  'Total Pemasukkan',
                  'Rp. 1.500.000',
                  conPemasukkan,
                  TextInputType.number,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  print('hallo');
                  // Clipboard.setData(ClipboardData(text: img64));
                },
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Simpan & Tambah Baru',
                      style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                  bnw900,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ubahPendapatan(
                    context,
                    widget.token,
                    ppmId,
                    'beli',
                    conKeterangan.text,
                    conPemasukkan.text,
                    '',
                    pageController,
                  );

                  initState();
                  setState(() {});
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Tambah',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  fieldAddDrop(title, hint, mycontroller, TextInputType numberNo) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: body1(FontWeight.w500, bnw900, 'Outfit'),
              ),
              Text(
                ' *',
                style: body1(FontWeight.w700, red500, 'Outfit'),
              ),
            ],
          ),
          TextFormField(
            cursorColor: primary500,
            keyboardType: numberNo,
            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
            controller: mycontroller,
            onChanged: (value) {},
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: primary500,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: bnw500,
                ),
              ),
              hintText: '$hint',
              suffixIcon: Icon(PhosphorIcons.calendar_fill, color: bnw900),
              hintStyle: heading3(FontWeight.w600, bnw500, 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }

  fieldAdd(title, hint, mycontroller, TextInputType numberNo) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: body1(FontWeight.w500, bnw900, 'Outfit'),
              ),
              Text(
                ' *',
                style: body1(FontWeight.w700, red500, 'Outfit'),
              ),
            ],
          ),
          TextFormField(
            cursorColor: primary500,
            keyboardType: numberNo,
            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
            controller: mycontroller,
            onChanged: (value) {},
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: primary500,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: bnw500,
                ),
              ),
              hintText: 'Cth : $hint',
              hintStyle: heading3(FontWeight.w600, bnw500, 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }

  jenisList(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(
          () {
            showModalBottomSheet(
              constraints: const BoxConstraints(
                maxWidth: double.infinity,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context, setState) => Container(
                    height: MediaQuery.of(context).size.height / 1.8,
                    decoration: BoxDecoration(
                      color: bnw100,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            height: 4,
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: bnw300,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(left: 15),
                            padding: const EdgeInsets.only(right: 15, top: 15),
                            decoration: BoxDecoration(
                              color: bnw100,
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.5,
                                  color: bnw500,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Kategori',
                                          style: heading4(FontWeight.w400,
                                              bnw900, 'Outfit'),
                                        ),
                                        Text(
                                          ' *',
                                          style: heading4(FontWeight.w400,
                                              red500, 'Outfit'),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      jenisProductEdit == null
                                          ? 'Pilih Kategori'
                                          : jenisProductEdit
                                              .toString()
                                              .toLowerCase(),
                                      style: heading2(
                                          FontWeight.w600, bnw500, 'Outfit'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: typeproductList?.map(
                                    (item) {
                                      return GestureDetector(
                                        onTap: () {
                                          // log(item['jenisproduct']);
                                          // log(item['kodeproduct']);
                                          setState(() {
                                            jenisProductEdit =
                                                item['jenisproduct'];
                                            // jenisProduct = item['jenisproduct'];

                                            // idProduct = item['kodeproduct'];
                                            _myProvince = item['kodeproduct'];
                                          });
                                        },
                                        child: Container(
                                          height: 58,
                                          width: double.infinity,
                                          padding: const EdgeInsets.only(
                                              right: 15, top: 15),
                                          decoration: BoxDecoration(
                                            color: bnw100,
                                            border: Border(
                                              bottom: BorderSide(
                                                width: 1,
                                                color: bnw300,
                                              ),
                                            ),
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              item['jenisproduct']
                                                  .toString()
                                                  .toLowerCase(),
                                              style: heading3(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList() ??
                                  [],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // _getRegenciesList(_myProvince);
                              // autoReload();
                              Navigator.pop(context);
                            },
                            child: buttonXXL(
                              Center(
                                child: Text(
                                  'Selesai',
                                  style: heading2(
                                      FontWeight.w600, bnw100, 'Outfit'),
                                ),
                              ),
                              double.infinity,
                            ),
                          ),
                          const SizedBox(height: 8)
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      child: TextFormField(
        cursorColor: primary500,
        style: heading3(FontWeight.w600, bnw900, 'Outfit'),
        enabled: false,
        onTap: () {},
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: primary500,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 1.5,
              color: bnw500,
            ),
          ),
          hintText: 'Pilih Jenis Pemasukkan',
          suffixIcon: Icon(PhosphorIcons.caret_down_fill, color: bnw900),
          hintStyle: heading3(FontWeight.w600, bnw500, 'Outfit'),
        ),
      ),
      // Container(
      //   width: double.infinity,
      //   margin: const EdgeInsets.only(top: 15),
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     border: Border(
      //       bottom: BorderSide(
      //         width: 1.5,
      //         color: bnw500,
      //       ),
      //     ),
      //   ),
      //   child: Padding(
      //     padding: const EdgeInsets.only(bottom: 8.0),
      //     child: Align(
      //       alignment: Alignment.centerLeft,
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text(
      //             'Kategori *',
      //             style: heading4(FontWeight.w400, bnw900, 'Outfit'),
      //           ),
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               Text(
      //                 jenisProductEdit == null
      //                     ? 'Kategori'
      //                     : jenisProductEdit.toString().toLowerCase(),
      //                 style: heading2(FontWeight.w600,
      //                     jenisProductEdit == null ? bnw500 : bnw900, 'Outfit'),
      //               ),
      //             ],
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  void _selectAll() {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    // If false will be available then it will select all the checkbox
    // If there will be no false then it will de-select all
    selectedFlag.updateAll((key, value) => isFalseAvailable);
    setState(() {
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }

  void onTap(bool isSelected, int index) {
    setState(() {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);
    });
    // if (isSelectionMode) {
    // } else {
    //   // Open Detail Page
    // }
  }

  Widget _buildSelectIcon(bool isSelected, PendapatanLainModel data) {
    return Icon(
      isSelected ? PhosphorIcons.check_square_fill : PhosphorIcons.square,
      color: primary500,
    );
    // if (isSelectionMode) {
    // } else {
    //   return CircleAvatar(
    //     child: Text('${data['id']}'),
    //   );
    // }
  }

  List? typeproductList;
  String? _myProvince;

  String provinceInfoUrl = '$url/api/typeproduct';
  Future _getProvinceList() async {
    await http.post(Uri.parse(provinceInfoUrl), body: {
      "deviceid": identifier,
    }).then((response) {
      var data = json.decode(response.body);

      setState(() {
        typeproductList = data['data'];
      });
    });
  }
}
