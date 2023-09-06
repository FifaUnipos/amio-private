import 'dart:developer';

import 'package:amio/utils/skeletons.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:amio/utils/printer/printerenum.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../models/tokoModel/riwayatTransaksiTokoModel.dart';
import '../../../../models/tokoModel/singleRiwayatModel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../../utils/component.dart';

class RiwayatPage extends StatefulWidget {
  RiwayatPage({
    Key? key,
    required this.token,
    required this.pageController,
    required this.tabController,
    required this.bluetooth,
  }) : super(key: key);

  PageController pageController;
  TabController tabController;
  String token;
  final BlueThermalPrinter bluetooth;

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<TokoDataRiwayatModel>? datasRiwayat;
  double heightInformation = 0;
  String? transactionidValue;
  double widtValue = 120;
  // double width = MediaQuery.of(context).size.width;
  double? width;

  double widthInformation = 0;
  List<String> cartProductIds = [];

  bool isDropdownOpen = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  // List<RiwayatSingleModel>? datasSingleRiwayat;

  @override
  void initState() {
    checkConnection(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        datasRiwayat = await getRiwayatTransaksi(
          context,
          widget.token,
          '',
          // '1',55
          '',
        );
        setState(() {});
      },
    );

    setState(() {
      print(datasRiwayat.toString());
      datasRiwayat;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var pageController = widget.pageController;
    TabController tabController = widget.tabController;
    // double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(size16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaksi',
            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
          ),
          Text(
            nameToko ?? '',
            style: heading3(FontWeight.w300, bnw900, 'Outfit'),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TabBar(
              controller: tabController,
              automaticIndicatorColorAdjustment: false,
              indicatorColor: primary500,
              unselectedLabelColor: bnw600,
              labelColor: primary500,
              labelStyle: heading2(FontWeight.w400, bnw900, 'Outfit'),
              physics: NeverScrollableScrollPhysics(),
              onTap: (value) {
                print(value);

                if (value == 0) {
                  pageController.animateToPage(
                    0,
                    duration: Duration(milliseconds: 10),
                    curve: Curves.ease,
                  );
                } else if (value == 1) {
                  pageController.animateToPage(
                    2,
                    duration: Duration(milliseconds: 10),
                    curve: Curves.ease,
                  );
                } else if (value == 2) {
                  pageController.animateToPage(
                    3,
                    duration: Duration(milliseconds: 10),
                    curve: Curves.ease,
                  );
                }
                setState(() {});
              },
              tabs: [
                Tab(
                  text: 'Kasir',
                ),
                Tab(
                  text: 'Riwayat',
                ),
                Tab(
                  text: 'Pengaturan',
                ),
              ],
            ),
          ),
          // Padding(
          //   padding:  EdgeInsets.only(top: size12, bottom: size12),
          //   child: buttonLoutline(
          //     GestureDetector(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: [
          //           Row(
          //             children: [
          //               Text(
          //                 'Urutkan',
          //                 style:
          //                     heading3(FontWeight.w600, bnw900, 'Outfit'),
          //               ),
          //               Text(
          //                 ' dari Nama Toko A ke Z',
          //                 style:
          //                     heading3(FontWeight.w400, bnw600, 'Outfit'),
          //               ),
          //             ],
          //           ),
          //            Icon(PhosphorIcons.caret_down),
          //         ],
          //       ),
          //     ),
          //     280,
          //     bnw300,
          //   ),
          // ),
          SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: size16, vertical: size16),
                        decoration: BoxDecoration(
                          color: primary500,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(size12),
                            topRight: Radius.circular(size12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Waktu Transaksi',
                                style:
                                    heading4(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              child: Text(
                                'Nama Pemesan',
                                style:
                                    heading4(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              child: Text(
                                'No Transaksi',
                                style:
                                    heading4(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              child: Text(
                                'Total',
                                style:
                                    heading4(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              child: Text(
                                'Status Transaksi',
                                style:
                                    heading4(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      datasRiwayat == null
                          ? SkeletonJustLine()
                          : Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: primary100,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(size12),
                                    bottomRight: Radius.circular(size12),
                                  ),
                                ),
                                child: RefreshIndicator(
                                  color: bnw100,
                                  backgroundColor: primary500,
                                  onRefresh: () async {
                                    initState();
                                    setState(() {});
                                  },
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: datasRiwayat!.length,
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (builder, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          // width = MediaQuery.of(context)
                                          //         .size
                                          //         .width /
                                          //     2.6;
                                          widtValue = 60;

                                          widthInformation =
                                              MediaQuery.of(context).size.width;
                                          heightInformation =
                                              MediaQuery.of(context)
                                                  .size
                                                  .height;

                                          transactionidValue =
                                              datasRiwayat![index]
                                                  .transactionid;

                                          print(transactionidValue);

                                          String productId =
                                              transactionidValue.toString();

                                          if (cartProductIds
                                              .contains(productId)) {
                                            // cartProductIds.remove(productId);
                                            cartProductIds.clear();
                                            width = null;
                                            widtValue = 120;
                                            heightInformation = 0;
                                            widthInformation = 0;
                                          } else {
                                            cartProductIds.clear();
                                            cartProductIds.add(productId);
                                          }

                                          setState(() {
                                            transactionidValue;
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: size12,
                                                  vertical: size12),
                                              decoration: BoxDecoration(
                                                color: cartProductIds.contains(
                                                        datasRiwayat![index]
                                                            .transactionid
                                                            .toString())
                                                    ? primary200
                                                    : null,
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: bnw300,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      datasRiwayat![index]
                                                          .entrydate
                                                          .toString(),
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ),
                                                  SizedBox(width: size16),
                                                  Expanded(
                                                    child: Text(
                                                      datasRiwayat![index]
                                                          .customer
                                                          .toString(),
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ),
                                                  SizedBox(width: size16),
                                                  Expanded(
                                                    child: Text(
                                                      datasRiwayat![index]
                                                          .transactionid
                                                          .toString(),
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ),
                                                  SizedBox(width: size16),
                                                  Expanded(
                                                    child: Text(
                                                      FormatCurrency
                                                              .convertToIdr(
                                                                  datasRiwayat![
                                                                          index]
                                                                      .amount)
                                                          .toString(),
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ),
                                                  SizedBox(width: size16),
                                                  Expanded(
                                                    child: Text(
                                                      datasRiwayat![index]
                                                          .status
                                                          .toString(),
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          datasRiwayat![index]
                                                                      .isPaid ==
                                                                  '1'
                                                              ? succes600
                                                              : datasRiwayat![index]
                                                                          .isPaid ==
                                                                      '2'
                                                                  ? waring500
                                                                  : danger500,
                                                          'Outfit'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                widthInformation != 0 ? SizedBox(width: size16) : SizedBox(),
                widthInformation == 0
                    ? Container()
                    : Expanded(
                        child: FutureBuilder(
                          future: getSingleRiwayatTransaksi(
                              widget.token, transactionidValue, ''),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Map<String, dynamic> data =
                                  snapshot.data!['data'];
                              List detail = data['detail'];

                              return Container(
                                padding: EdgeInsets.all(size16),
                                height: heightInformation,
                                width: widthInformation,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(size8),
                                  border: Border.all(color: bnw300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ListView(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics: BouncingScrollPhysics(),
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Informasi Transaksi',
                                                style: heading3(FontWeight.w600,
                                                    bnw900, 'Outfit'),
                                              ),
                                              SizedBox(height: size16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child:
                                                        buttonStatusTransaksi(
                                                            data),
                                                  ),
                                                  data['is_color'] == '1'
                                                      ? SizedBox()
                                                      : Column(
                                                          children: [
                                                            SizedBox(
                                                                width: size16),
                                                            GestureDetector(
                                                              onTap: () {
                                                                whenLoading(
                                                                    context);

                                                                transaksiViewReference(
                                                                  context,
                                                                  widget.token,
                                                                  data[
                                                                      'transactionid'],
                                                                ).then((value) {
                                                                  if (value[
                                                                          'rc'] ==
                                                                      '00') {
                                                                    Navigator.of(
                                                                            context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop();
                                                                    showBottomRiwayatPerubahan(
                                                                        context,
                                                                        data);
                                                                  } else {
                                                                    Navigator.of(
                                                                            context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop();
                                                                  }
                                                                });
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        size12,
                                                                    vertical:
                                                                        size16),
                                                                child: Text(
                                                                  'Lihat Riwayat',
                                                                  style: heading3(
                                                                      FontWeight
                                                                          .w600,
                                                                      primary500,
                                                                      'Outfit'),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                ],
                                              ),
                                              SizedBox(height: size16),
                                              SizedBox(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Waktu Transaksi',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                        Text(
                                                          'Nomor Transaksi',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                        Text(
                                                          'Kasir',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                        Text(
                                                          'Nama Pembeli',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          data['entrydate'] ??
                                                              '-',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                        Text(
                                                          data['transactionid'] ??
                                                              '-',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                        Text(
                                                          data['pic']
                                                              .toString(),
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                        Text(
                                                          data['customer'] ??
                                                              '-',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(
                                                            height: size12),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: size8,
                                                  bottom: size8,
                                                ),
                                                child: Text(
                                                  'Rincian Produk',
                                                  style: heading3(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                              ),
                                            ],
                                          ),
                                          //! error
                                          SizedBox(
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: detail.length,
                                              itemBuilder: (context, index) {
                                                return SizedBox(
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'x${detail[index]['quantity']}',
                                                            style: heading3(
                                                                FontWeight.w600,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          SizedBox(
                                                              width: size8),
                                                          SizedBox(
                                                            height: size48,
                                                            width: size48,
                                                            child: AspectRatio(
                                                              aspectRatio: 1,
                                                              child: Container(
                                                                child: Image
                                                                    .network(
                                                                  detail[index][
                                                                      'product_image'],
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      SvgPicture
                                                                          .asset(
                                                                    'assets/logoProduct.svg',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width: size8),
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                detail[index][
                                                                        'name'] ??
                                                                    '-',
                                                                style: heading3(
                                                                    FontWeight
                                                                        .w600,
                                                                    bnw900,
                                                                    'Outfit'),
                                                              ),
                                                              Text(
                                                                FormatCurrency.convertToIdr(
                                                                        detail[index]['amount'] ??
                                                                            '-')
                                                                    .toString(),
                                                                style: body1(
                                                                    FontWeight
                                                                        .w400,
                                                                    bnw900,
                                                                    'Outfit'),
                                                              ),
                                                              Text(
                                                                'Catatan : ${detail[index]['description']}',
                                                                style: body1(
                                                                    FontWeight
                                                                        .w400,
                                                                    bnw900,
                                                                    'Outfit'),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      Divider(),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Rincian Pembayaran',
                                                  style: heading3(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                                SizedBox(height: size8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Metode Pembayaran',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                        Text(
                                                          'Sub Total',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                        Text(
                                                          'PPN',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          data['payment_name'] ??
                                                              '-',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                        Text(
                                                          FormatCurrency
                                                                  .convertToIdr(
                                                                      data['total_before_dsc_tax'] ??
                                                                          '-')
                                                              .toString(),
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                        Text(
                                                          FormatCurrency
                                                                  .convertToIdr(
                                                                      data['ppn'] ??
                                                                          '-')
                                                              .toString(),
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: size8),
                                                dash(),
                                                SizedBox(height: size8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        SizedBox(height: size8),
                                                        Text(
                                                          'Uang Tunai',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                        Text(
                                                          'Kembalian',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        SizedBox(height: size8),
                                                        Text(
                                                          FormatCurrency
                                                                  .convertToIdr(
                                                                      data['amount'] ??
                                                                          '-')
                                                              .toString(),
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                        Text(
                                                          FormatCurrency.convertToIdr(
                                                                  (data['total_before_dsc_tax'] +
                                                                              data['ppn']) -
                                                                          data['amount'] ??
                                                                      '-')
                                                              .toString(),
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              primary500,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(height: size8),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: size8),
                                                dash(),
                                                SizedBox(height: size8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Total',
                                                      style: heading3(
                                                          FontWeight.w600,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                    Text(
                                                      FormatCurrency.convertToIdr(
                                                              data['amount'] ??
                                                                  '-')
                                                          .toString(),
                                                      style: heading3(
                                                          FontWeight.w600,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: size8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              widget.bluetooth.isConnected
                                                  .then((isConnected) {
                                                if (isConnected == true) {
                                                  widget.bluetooth
                                                      .printNewLine();
                                                  widget.bluetooth
                                                      .printNewLine();
                                                  // widget.bluetooth.printImage(file.path);
                                                  // bluetooth.printImageBytes(
                                                  //     img); //image from Network
                                                  widget.bluetooth
                                                      .printNewLine();
                                                  widget.bluetooth
                                                      .printNewLine();
                                                  widget.bluetooth.printCustom(
                                                      printext.replaceAll(
                                                          RegExp('[|]'), '\n'),
                                                      Size.bold.val,
                                                      0);
                                                  // widget.bluetooth.printCustom(
                                                  //     widget.printtext.replaceAll(RegExp('[|]'), '\n'),
                                                  //     Size.bold.val,
                                                  //     0);
                                                  widget.bluetooth
                                                      .printNewLine();
                                                  // widget.bluetooth.printNewLine();
                                                  widget.bluetooth.paperCut();

                                                  showSnackBarComponent(
                                                    context,
                                                    'Berhasil Cetak Struk',
                                                    '00',
                                                  );
                                                } else {
                                                  dialogNoPrinter(context);
                                                }
                                              });
                                              setState(() {});
                                            },
                                            child: buttonXLoutline(
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                        PhosphorIcons
                                                            .printer_fill,
                                                        color: primary500,
                                                        size: size24),
                                                    SizedBox(width: size12),
                                                    Text(
                                                      'Cetak Struk',
                                                      style: heading3(
                                                          FontWeight.w600,
                                                          primary500,
                                                          'Outfit'),
                                                    ),
                                                  ]),
                                              MediaQuery.of(context).size.width,
                                              primary500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: size12),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              width = null;
                                              widtValue = 120;
                                              heightInformation = 0;
                                              widthInformation = 0;
                                              printext = '';
                                              cartProductIds.clear();
                                              setState(() {});
                                            },
                                            child: buttonXL(
                                              Center(
                                                  child: Text(
                                                'Selesai',
                                                style: heading3(FontWeight.w600,
                                                    bnw100, 'Outfit'),
                                              )),
                                              MediaQuery.of(context).size.width,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasError) {
                              // return Text("Error: ${snapshot.error}");
                              return Center(child: loading());
                            }
                            return Center(child: loading());
                            // return Flexible(child: SkeletonJustLine());
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

  Future<dynamic> showBottomRiwayatPerubahan(
      BuildContext context, Map<String, dynamic> data) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder(
            future: transaksiViewReference(
              context,
              widget.token,
              data['transactionid'],
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var dataPerubahan = snapshot.data['data'];
                var detail = dataPerubahan['detail'];
                return StatefulBuilder(
                  builder: (context, setState) => Container(
                    margin: EdgeInsets.only(top: size32),
                    padding:
                        EdgeInsets.fromLTRB(size32, size16, size32, size32),
                    decoration: BoxDecoration(
                      color: bnw100,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(size12),
                        topLeft: Radius.circular(size12),
                      ),
                    ),
                    child: Column(
                      children: [
                        dividerShowdialog(),
                        SizedBox(height: size16),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Riwayat Perubahan',
                                style:
                                    heading1(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                              Text(
                                'Rincian riwayat perubahan transaksi',
                                style:
                                    heading4(FontWeight.w400, bnw500, 'Outfit'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size32),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            isDropdownOpen = !isDropdownOpen;
                            print(isDropdownOpen);
                            setState(() {});
                          },
                          child: Container(
                              margin: EdgeInsets.only(bottom: size16),
                              padding: EdgeInsets.symmetric(
                                  vertical: size12, horizontal: size16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(size16),
                                border: Border.all(color: bnw300),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Spacer(),
                                      Container(
                                          height: size40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(size8),
                                            color: danger100,
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: size16,
                                                    vertical: size12),
                                                child: Text(
                                                  'Pengisian Terakhir',
                                                  style: heading3(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                              ),
                                              SizedBox(width: size16),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: size12,
                                                    vertical: size8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size8),
                                                  color: danger500,
                                                ),
                                                child: Text(
                                                  dataPerubahan['estimate'] ??
                                                      '-',
                                                  style: heading3(
                                                      FontWeight.w400,
                                                      bnw100,
                                                      'Outfit'),
                                                ),
                                              ),
                                            ],
                                          )),
                                      SizedBox(width: size16),
                                      Icon(
                                        PhosphorIcons.caret_down,
                                        color: bnw900,
                                        size: size24,
                                      )
                                    ],
                                  ),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    margin: EdgeInsets.only(
                                        top: isDropdownOpen ? size16 : 0),
                                    child: isDropdownOpen
                                        ? Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2,
                                            width: double.infinity,
                                            padding: EdgeInsets.all(size16),
                                            decoration: BoxDecoration(
                                              color: bnw200,
                                              borderRadius:
                                                  BorderRadius.circular(size16),
                                            ),
                                            child: ListView(
                                              padding: EdgeInsets.zero,
                                              physics: BouncingScrollPhysics(),
                                              children: [
                                                Text(
                                                  'Status Transaksi',
                                                  style: heading3(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                                SizedBox(height: size12),
                                                SizedBox(
                                                    width: double.infinity,
                                                    child:
                                                        buttonStatusTransaksi(
                                                            data)),
                                                SizedBox(height: size16),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Informasi Transaksi',
                                                      style: heading3(
                                                          FontWeight.w600,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                    SizedBox(height: size12),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Waktu Tagihan',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              'Nomor Tagihan',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              'Kasir',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              'Alasan Batal',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                          ],
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              dataPerubahan[
                                                                      'entrydate'] ??
                                                                  '-',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              dataPerubahan[
                                                                      'transactionid'] ??
                                                                  '-',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              dataPerubahan[
                                                                      'pic'] ??
                                                                  '-',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              dataPerubahan[
                                                                          'reference']
                                                                      [
                                                                      'alasan_reference'] ??
                                                                  '-',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size16),
                                                    Text(
                                                      'Detail Alasan',
                                                      style: heading3(
                                                          FontWeight.w600,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                    SizedBox(height: size8),
                                                    Wrap(
                                                      children: [
                                                        for (final paragraph
                                                            in (dataPerubahan[
                                                                            'reference']
                                                                        [
                                                                        'detail_alasan_reference'] ??
                                                                    '')
                                                                .split('\n'))
                                                          Text(
                                                            paragraph,
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size16),
                                                    Text(
                                                      'Rincian Produk',
                                                      style: heading3(
                                                          FontWeight.w600,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                    SizedBox(
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        itemCount:
                                                            detail.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return SizedBox(
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'x${detail[index]['quantity']}',
                                                                      style: heading3(
                                                                          FontWeight
                                                                              .w600,
                                                                          bnw900,
                                                                          'Outfit'),
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            size8),
                                                                    SizedBox(
                                                                      height:
                                                                          size48,
                                                                      width:
                                                                          size48,
                                                                      child:
                                                                          AspectRatio(
                                                                        aspectRatio:
                                                                            1,
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Image.network(
                                                                            detail[index]['product_image'],
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            errorBuilder: (context, error, stackTrace) =>
                                                                                SvgPicture.asset(
                                                                              'assets/logoProduct.svg',
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            size8),
                                                                    Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          detail[index]['name'] ??
                                                                              '-',
                                                                          style: heading3(
                                                                              FontWeight.w600,
                                                                              bnw900,
                                                                              'Outfit'),
                                                                        ),
                                                                        Text(
                                                                          FormatCurrency.convertToIdr(detail[index]['amount'] ?? '-')
                                                                              .toString(),
                                                                          style: body1(
                                                                              FontWeight.w400,
                                                                              bnw900,
                                                                              'Outfit'),
                                                                        ),
                                                                        Text(
                                                                          'Catatan : ${detail[index]['description']}',
                                                                          style: body1(
                                                                              FontWeight.w400,
                                                                              bnw900,
                                                                              'Outfit'),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                                Divider(),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox(),
                                  ),
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                );
              }
              return SizedBox();
            },
          );
        });
  }

  buttonStatusTransaksi(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size12,
        vertical: size16,
      ),
      decoration: BoxDecoration(
        color: data['is_color'] == '1'
            ? succes100
            : data['is_color'] == '2'
                ? danger100
                : waring100,
        borderRadius: BorderRadius.circular(size8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            data['status_transactions'] ?? '-',
            style: body1(
                FontWeight.w400,
                data['is_color'] == '1'
                    ? succes500
                    : data['is_color'] == '2'
                        ? danger500
                        : waring500,
                'Outfit'),
          ),
          Icon(
            PhosphorIcons.info_fill,
            color: data['is_color'] == '1'
                ? succes500
                : data['is_color'] == '2'
                    ? danger500
                    : waring500,
            size: size24,
          ),
        ],
      ),
    );
  }
}
