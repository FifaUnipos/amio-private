import 'dart:developer';

import 'package:unipos_app_335/pageTablet/tokopage/sidebar/transaksiToko/transaksi.dart';
import 'package:unipos_app_335/utils/printer/printerPage.dart';
import 'package:flutter/services.dart';

import '../../../../utils/component/component_loading.dart';
import '../../../../utils/component/skeletons.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import '../../../../utils/printer/printerenum.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../models/tokoModel/riwayatTransaksiTokoModel.dart';
import '../../../../models/tokoModel/singleRiwayatModel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';
import '../../../../utils/component/component_orderBy.dart';

class TagihanPageGrup extends StatefulWidget {
  String token, merchid, namemerch;
  PageController pageController;
  TabController tabController;
  final BlueThermalPrinter bluetooth;
  TagihanPageGrup({
    Key? key,
    required this.token,
    required this.merchid,
    required this.namemerch,
    required this.pageController,
    required this.tabController,
    required this.bluetooth,
  }) : super(key: key);

  @override
  State<TagihanPageGrup> createState() => _TagihanPageGrupState();
}

class _TagihanPageGrupState extends State<TagihanPageGrup> {
  List<TokoDataRiwayatModel>? datasRiwayat;
  String textOrderBy = 'Tagihan Terbaru';
  String textvalueOrderBy = 'upDownCreate';

  late Uint8List imageStruk;

  getStrukPhoto() async {
    var response = await http.get(Uri.parse(logoStrukPrinter!));
    Uint8List bytesNetwork = response.bodyBytes;
    Uint8List imageBytesFromNetwork = bytesNetwork.buffer
        .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

    imageStruk = imageBytesFromNetwork;
    setState(() {});
  }

  @override
  void initState() {
    if (logoStrukPrinter != '') {
      getStrukPhoto();
    }
    checkConnection(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        datasRiwayat = await getRiwayatTransaksi(
          context,
          widget.token,
          '0',
          widget.merchid,
          textvalueOrderBy,
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  // double width = MediaQuery.of(context).size.width;
  List<String> cartProductIds = [];

  double? width;
  double widtValue = 120;

  double heightInformation = 0;
  double widthInformation = 0;

  String? transactionidValue, merchidValue;

  @override
  Widget build(BuildContext context) {
    var pageController = widget.pageController;
    TabController tabController = widget.tabController;
    // double width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                widget.pageController.jumpToPage(0);
              },
              child: Icon(
                PhosphorIcons.arrow_left,
                size: size48,
                color: bnw900,
              ),
            ),
            SizedBox(width: size12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaksi',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  widget.namemerch,
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: TabBar(
            controller: tabController,
            automaticIndicatorColorAdjustment: false,
            indicatorColor: primary500,
            labelColor: primary500,
            labelStyle: heading2(FontWeight.w400, bnw900, 'Outfit'),
            unselectedLabelColor: bnw600,
            physics: NeverScrollableScrollPhysics(),
            onTap: (value) {
              print(value);

              if (value == 0) {
                pageController.animateToPage(
                  1,
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
                text: 'Tagihan',
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
        SizedBox(height: size16),
        orderBy(context),
        SizedBox(height: size16),
        Flexible(
          child: Row(
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
                          padding: EdgeInsets.only(left: size16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: widtValue,
                                child: Text(
                                  'Nama Pemesan',
                                  style: heading4(
                                      FontWeight.w600, bnw100, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: widtValue,
                                child: Text(
                                  'No Pesanan',
                                  style: heading4(
                                      FontWeight.w600, bnw100, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: widtValue,
                                child: Text(
                                  'Kasir',
                                  style: heading4(
                                      FontWeight.w600, bnw100, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: widtValue,
                                child: Text(
                                  'Total',
                                  style: heading4(
                                      FontWeight.w600, bnw100, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: widtValue,
                                child: Text(
                                  'Waktu',
                                  style: heading4(
                                      FontWeight.w600, bnw100, 'Outfit'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      datasRiwayat == null
                          ? SkeletonJustLine()
                          : Flexible(
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
                                    // shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: datasRiwayat!.length,
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (builder, index) {
                                      return GestureDetector(
                                        behavior: HitTestBehavior.translucent,
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

                                          merchidValue =
                                              datasRiwayat![index].merchantid;

                                          String productId =
                                              transactionidValue.toString();

                                          print(transactionidValue);

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

                                          setState(() {
                                            transactionidValue;
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: cartProductIds.contains(
                                                        datasRiwayat![index]
                                                            .transactionid
                                                            .toString())
                                                    ? primary200
                                                    : Colors.transparent,
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: bnw300,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              padding: EdgeInsets.fromLTRB(
                                                  size16, size12, 0, size12),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: widtValue,
                                                    child: Text(
                                                      datasRiwayat![index]
                                                              .customer ??
                                                          '',
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: widtValue,
                                                    child: Text(
                                                      datasRiwayat![index]
                                                              .transactionid ??
                                                          '',
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: widtValue,
                                                    child: Text(
                                                      datasRiwayat![index]
                                                              .pic ??
                                                          '',
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: widtValue,
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
                                                  SizedBox(
                                                    width: widtValue,
                                                    child: Text(
                                                      datasRiwayat![index]
                                                              .entrydate ??
                                                          '',
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
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
              ),
              SizedBox(width: size16),
              widthInformation == 0
                  ? Container()
                  : Expanded(
                      child: FutureBuilder(
                      future: getSingleRiwayatTransaksi(
                          widget.token, transactionidValue, widget.merchid),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Map<String, dynamic>? data = snapshot.data!['data'];
                          var detail = data!['detail'];

                          return AnimatedContainer(
                            duration: Duration(seconds: 1),
                            padding: EdgeInsets.all(size16),
                            height: heightInformation,
                            width: widthInformation,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(size8),
                              border: Border.all(color: bnw300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: ListView(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics: BouncingScrollPhysics(),
                                    children: [
                                      //! error
                                      Text(
                                        'Status Tagihan',
                                        style: heading3(
                                            FontWeight.w600, bnw900, 'Outfit'),
                                      ),
                                      SizedBox(height: size16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: size12,
                                                vertical: size16,
                                              ),
                                              decoration: BoxDecoration(
                                                color: waring100,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    data['status_transactions'],
                                                    style: body1(
                                                        FontWeight.w400,
                                                        waring500,
                                                        'Outfit'),
                                                  ),
                                                  Icon(
                                                    PhosphorIcons.info_fill,
                                                    color: waring500,
                                                    size: size24,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // SizedBox(width: size16),
                                          // Container(
                                          //   padding:
                                          //       EdgeInsets.symmetric(
                                          //           horizontal: size12,
                                          //           vertical: size16),
                                          //   child: Text(
                                          //     'Lihat Riwayat',
                                          //     style: heading3(
                                          //         FontWeight.w600,
                                          //         primary500,
                                          //         'Outfit'),
                                          //   ),
                                          // )
                                        ],
                                      ),
                                      SizedBox(height: size16),
                                      SizedBox(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Informasi Tagihan',
                                              style: heading3(FontWeight.w600,
                                                  bnw900, 'Outfit'),
                                            ),
                                            SizedBox(height: size8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Waktu Tagihan',
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                    SizedBox(height: size8),
                                                    Text(
                                                      'Nomor Tagihan',
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
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      data['entrydate'] ?? '',
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                    SizedBox(height: size8),
                                                    Text(
                                                      data['transactionid'] ??
                                                          '',
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                    SizedBox(height: size8),
                                                    Text(
                                                      data['pic'] ?? '',
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                    SizedBox(height: size8),
                                                    Text(
                                                      data['customer'] ?? '',
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: size16),
                                      Text(
                                        'Rincian Produk',
                                        style: heading3(
                                            FontWeight.w600, bnw900, 'Outfit'),
                                      ),
                                      SizedBox(height: size16),
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
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    size8),
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: size8,
                                                                  right: size8),
                                                          height: 48,
                                                          width: 48,
                                                          child: Image.network(
                                                            detail[index][
                                                                    'product_image'] ??
                                                                '',
                                                            fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null) {
                                                                return child;
                                                              }

                                                              return Center(
                                                                  child:
                                                                      loading());
                                                            },
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                SizedBox(
                                                              child: SvgPicture
                                                                  .asset(
                                                                      'assets/logoProduct.svg'),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            detail[index]
                                                                    ['name'] ??
                                                                '',
                                                            style: heading3(
                                                                FontWeight.w600,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          Text(
                                                            FormatCurrency.convertToIdr(
                                                                    detail[index]
                                                                        [
                                                                        'amount'])
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

                                      SizedBox(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Rincian Pembayaran',
                                              style: heading3(FontWeight.w600,
                                                  bnw900, 'Outfit'),
                                            ),
                                            SizedBox(height: size8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
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
                                                    SizedBox(height: size8),
                                                    Text(
                                                      'Diskon',
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      FormatCurrency
                                                              .convertToIdr(data[
                                                                  'total_before_dsc_tax'])
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
                                                                  data['ppn'])
                                                          .toString(),
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                    SizedBox(height: size8),
                                                    Text(
                                                      FormatCurrency.convertToIdr(
                                                              data['discount'] ==
                                                                      ""
                                                                  ? 0
                                                                  : data[
                                                                      'discount'])
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
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: size8,
                                                bottom: size8,
                                              ),
                                              child: Row(
                                                children: List.generate(
                                                  300 ~/ 6,
                                                  (index) => Flexible(
                                                    child: Container(
                                                      color: index % 2 == 0
                                                          ? Colors.transparent
                                                          : bnw900,
                                                      height: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Total Tagihan',
                                                  style: heading3(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                                Text(
                                                  FormatCurrency.convertToIdr(
                                                          data['amount'])
                                                      .toString(),
                                                  style: heading1(
                                                      FontWeight.w700,
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
                                Row(
                                  children: [
                                    // Expanded(
                                    //   child: GestureDetector(
                                    //     onTap: () async {
                                    //       width = null;
                                    //       widtValue = 120;
                                    //       heightInformation = 0;
                                    //       widthInformation = 0;

                                    //       cart.clear();
                                    //       cartMap.clear();

                                    //       await deletePesanan(
                                    //         context,
                                    //         widget.token,
                                    //         transactionidValue,
                                    //       );
                                    //       setState(() {});
                                    //       initState();
                                    //     },
                                    //     child: buttonXLoutline(
                                    //         Row(
                                    //           mainAxisAlignment:
                                    //               MainAxisAlignment
                                    //                   .center,
                                    //           children: [
                                    //             Icon(
                                    //               PhosphorIcons
                                    //                   .trash_fill,
                                    //               color: danger500,
                                    //             ),
                                    //              SizedBox(
                                    //                 width: size12),
                                    //             Text(
                                    //               'Hapus',
                                    //               style: heading3(
                                    //                 FontWeight.w600,
                                    //                 danger500,
                                    //                 'Outfit',
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //         180,
                                    //         danger500),
                                    //   ),
                                    // ),

                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.bluetooth.isConnected
                                              .then((isConnected) {
                                            if (isConnected == true) {
                                              widget.bluetooth.printNewLine();
                                              // widget.bluetooth.printNewLine();
                                              // widget.bluetooth.printImage(file.path);
                                              // bluetooth.printImageBytes(
                                              //     img); //image from Network
                                              logoStrukPrinter!.isEmpty
                                                  ? widget.bluetooth
                                                      .printNewLine()
                                                  : bluetooth.printImageBytes(
                                                      imageStruk);
                                              widget.bluetooth.printNewLine();
                                              widget.bluetooth.printNewLine();
                                              widget.bluetooth.printCustom(
                                                  printext.replaceAll(
                                                      RegExp('[|]'), '\n'),
                                                  Size.bold.val,
                                                  0);
                                              // widget.bluetooth.printCustom(
                                              //     widget.printtext.replaceAll(RegExp('[|]'), '\n'),
                                              //     Size.bold.val,
                                              //     0);
                                              widget.bluetooth.printNewLine();
                                              // widget.bluetooth.printNewLine();
                                              widget.bluetooth.paperCut();
                                            } else {}
                                          });
                                          setState(() {});
                                        },
                                        child: buttonXLoutline(
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  PhosphorIcons.printer_fill,
                                                  color: primary500,
                                                  size: size20,
                                                ),
                                                SizedBox(width: size16),
                                                Text(
                                                  'Cetak',
                                                  style: heading3(
                                                      FontWeight.w600,
                                                      primary500,
                                                      'Outfit'),
                                                ),
                                              ]),
                                          MediaQuery.of(context).size.width /
                                              5.7,
                                          primary500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        }
                        return Center(child: loading());
                      },
                    )),
            ],
          ),
        ),
      ],
    );
  }

  orderBy(BuildContext context) {
    return IntrinsicWidth(
      child: GestureDetector(
        onTap: () {
          setState(() {
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
                  builder: (BuildContext context, setState) => IntrinsicHeight(
                    child: Container(
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
                          Container(
                            width: double.infinity,
                            color: bnw100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Urutkan',
                                  style: heading2(
                                      FontWeight.w700, bnw900, 'Outfit'),
                                ),
                                Text(
                                  'Tentukan data yang akan tampil',
                                  style: heading4(
                                      FontWeight.w400, bnw600, 'Outfit'),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Pilih Urutan',
                                  style: heading3(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                                Wrap(
                                  children: List<Widget>.generate(
                                    orderByTagihanText.length,
                                    (int index) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: size16),
                                        child: ChoiceChip(
                                          padding: EdgeInsets.symmetric(
                                              vertical: size12),
                                          backgroundColor: bnw100,
                                          selectedColor: primary100,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color:
                                                  valueOrderByProduct == index
                                                      ? primary500
                                                      : bnw300,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(size8),
                                          ),
                                          label: Text(orderByTagihanText[index],
                                              style: heading4(
                                                  FontWeight.w400,
                                                  valueOrderByProduct == index
                                                      ? primary500
                                                      : bnw900,
                                                  'Outfit')),
                                          selected:
                                              valueOrderByProduct == index,
                                          onSelected: (bool selected) {
                                            setState(() {
                                              print(index);
                                              // _value =
                                              //     selected ? index : null;
                                              valueOrderByProduct = index;
                                            });
                                            setState(() {});
                                          },
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size32),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                print(valueOrderByProduct);
                                print(orderByTagihanText[valueOrderByProduct]);

                                textOrderBy =
                                    orderByTagihanText[valueOrderByProduct];
                                textvalueOrderBy =
                                    orderByRiwayatTagihan[valueOrderByProduct];
                                orderByRiwayatTagihan[valueOrderByProduct];
                                Navigator.pop(context);
                                initState();
                              },
                              child: buttonXL(
                                Center(
                                  child: Text(
                                    'Tampilkan',
                                    style: heading3(
                                        FontWeight.w600, bnw100, 'Outfit'),
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
        child: buttonLoutline(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Urutkan',
                style: heading3(
                  FontWeight.w600,
                  bnw900,
                  'Outfit',
                ),
              ),
              Text(
                ' dari $textOrderBy',
                style: heading3(
                  FontWeight.w400,
                  bnw900,
                  'Outfit',
                ),
              ),
              SizedBox(width: size12),
              Icon(
                PhosphorIcons.caret_down,
                color: bnw900,
                size: size24,
              )
            ],
          ),
          bnw300,
        ),
      ),
    );
  }
}
