import 'package:unipos_app_335/pageTablet/tokopage/sidebar/transaksiToko/transaksi.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/printer/printerPage.dart';
import 'package:flutter/services.dart';

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
import '../../../../utils/component/component_loading.dart';

class RiwayatPageGrup extends StatefulWidget {
  String token, merchid, namemerch;
  PageController pageController;
  TabController tabController;
  final BlueThermalPrinter bluetooth;
  RiwayatPageGrup({
    Key? key,
    required this.token,
    required this.merchid,
    required this.namemerch,
    required this.pageController,
    required this.tabController,
    required this.bluetooth,
  }) : super(key: key);

  @override
  State<RiwayatPageGrup> createState() => _RiwayatPageGrupState();
}

class _RiwayatPageGrupState extends State<RiwayatPageGrup> {
  List<TokoDataRiwayatModel>? datasRiwayat;
  // List<RiwayatSingleModel>? datasSingleRiwayat;
  bool isDropdownOpen = false;
  String textOrderBy = 'Riwayat Terbaru';
  String textvalueOrderBy = 'upDownCreate';

  late Uint8List imageStruk;

  getStrukPhoto() async {
    var response = await http.get(Uri.parse(logoStrukPrinter!));
    Uint8List bytesNetwork = response.bodyBytes;
    Uint8List imageBytesFromNetwork = bytesNetwork.buffer.asUint8List(
      bytesNetwork.offsetInBytes,
      bytesNetwork.lengthInBytes,
    );

    imageStruk = imageBytesFromNetwork;
    setState(() {});
  }

  @override
  void initState() {
    checkConnection(context);
    if (logoStrukPrinter != '') {
      getStrukPhoto();
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      datasRiwayat = await getRiwayatTransaksi(
        context,
        widget.token,
        '1',
        widget.merchid,
        textvalueOrderBy,
      );
      setState(() {});
    });

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
              Tab(text: 'Tagihan'),
              Tab(text: 'Riwayat'),
              Tab(text: 'Pengaturan'),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: size16,
                          vertical: size12,
                        ),
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
                                style: heading4(
                                  FontWeight.w600,
                                  bnw100,
                                  'Outfit',
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              child: Text(
                                'Nama Pemesan',
                                style: heading4(
                                  FontWeight.w600,
                                  bnw100,
                                  'Outfit',
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              child: Text(
                                'No Transaksi',
                                style: heading4(
                                  FontWeight.w600,
                                  bnw100,
                                  'Outfit',
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              child: Text(
                                'Total',
                                style: heading4(
                                  FontWeight.w600,
                                  bnw100,
                                  'Outfit',
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              child: Text(
                                'Status Transaksi',
                                style: heading4(
                                  FontWeight.w600,
                                  bnw100,
                                  'Outfit',
                                ),
                              ),
                            ),
                          ],
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

                                          widthInformation = MediaQuery.of(
                                            context,
                                          ).size.width;
                                          heightInformation = MediaQuery.of(
                                            context,
                                          ).size.height;

                                          transactionidValue =
                                              datasRiwayat![index]
                                                  .transactionid;
                                          merchidValue =
                                              datasRiwayat![index].merchantid;

                                          print(transactionidValue);

                                          String productId = transactionidValue
                                              .toString();

                                          if (cartProductIds.contains(
                                            productId,
                                          )) {
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
                                              decoration: BoxDecoration(
                                                color:
                                                    cartProductIds.contains(
                                                      datasRiwayat![index]
                                                          .transactionid
                                                          .toString(),
                                                    )
                                                    ? primary200
                                                    : null,
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: bnw300,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: size12,
                                                horizontal: size16,
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
                                                        'Outfit',
                                                      ),
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
                                                        'Outfit',
                                                      ),
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
                                                        'Outfit',
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: size16),
                                                  Expanded(
                                                    child: Text(
                                                      FormatCurrency.convertToIdr(
                                                        datasRiwayat![index]
                                                            .amount,
                                                      ).toString(),
                                                      style: heading4(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit',
                                                      ),
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
                                                                    .isColor ==
                                                                '1'
                                                            ? succes500
                                                            : datasRiwayat![index]
                                                                      .isColor ==
                                                                  '2'
                                                            ? danger500
                                                            : waring500,
                                                        'Outfit',
                                                      ),
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
                          widget.token,
                          transactionidValue,
                          widget.merchid,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            Map<String, dynamic> data = snapshot.data!['data'];
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
                                              style: heading3(
                                                FontWeight.w600,
                                                bnw900,
                                                'Outfit',
                                              ),
                                            ),
                                            SizedBox(height: size16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: buttonStatusTransaksi(
                                                    data,
                                                  ),
                                                ),

                                                // data['is_color'] == '1'
                                                //     ? SizedBox()
                                                //     : Column(
                                                //         children: [
                                                //           SizedBox(
                                                //             width: size16,
                                                //           ),
                                                //           GestureDetector(
                                                //             onTap: () {
                                                //               whenLoading(
                                                //                 context,
                                                //               );

                                                //               transaksiViewReference(
                                                //                 context,
                                                //                 widget
                                                //                     .token,
                                                //                 data['transactionid'],
                                                //               ).then((
                                                //                 value,
                                                //               ) {
                                                //                 if (value['rc'] ==
                                                //                     '00') {
                                                //                   Navigator.of(
                                                //                     context,
                                                //                     rootNavigator:
                                                //                         true,
                                                //                   ).pop();
                                                //                   showBottomRiwayatPerubahan(
                                                //                     context,
                                                //                     data,
                                                //                   );
                                                //                 } else {
                                                //                   Navigator.of(
                                                //                     context,
                                                //                     rootNavigator:
                                                //                         true,
                                                //                   ).pop();
                                                //                 }
                                                //               });
                                                //             },
                                                //             child: Container(
                                                //               padding: EdgeInsets.symmetric(
                                                //                 horizontal:
                                                //                     size12,
                                                //                 vertical:
                                                //                     size16,
                                                //               ),
                                                //               child: Text(
                                                //                 'Lihat Riwayat',
                                                //                 style: heading3(
                                                //                   FontWeight
                                                //                       .w600,
                                                //                   primary500,
                                                //                   'Outfit',
                                                //                 ),
                                                //               ),
                                                //             ),
                                                //           ),
                                                //         ],
                                                //       ),
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
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        'Nomor Transaksi',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        'Kasir',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        'Nama Pembeli',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        data['entrydate'] ??
                                                            '-',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        data['transactionid'] ??
                                                            '-',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        data['pic'].toString(),
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        data['customer'] ?? '-',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size12),
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
                                                  'Outfit',
                                                ),
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
                                              var variants =
                                                  detail[index]['variants'];
                                              List<String> variantInfo = [];

                                              // Mengecek apakah variants ada dan bukan kosong
                                              if (variants != null &&
                                                  variants.isNotEmpty) {
                                                for (var variant in variants) {
                                                  // Menyusun nama kategori dan nama produk
                                                  for (var product
                                                      in variant['variant_products']) {
                                                    variantInfo.add(
                                                      '+ ${variant['variant_category_title']} (${product['variant_product_name']})',
                                                    );
                                                  }
                                                }
                                              }

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
                                                            'Outfit',
                                                          ),
                                                        ),
                                                        SizedBox(width: size8),
                                                        SizedBox(
                                                          height: size48,
                                                          width: size48,
                                                          child: AspectRatio(
                                                            aspectRatio: 1,
                                                            child: Container(
                                                              child: Image.network(
                                                                detail[index]['product_image'],
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder:
                                                                    (
                                                                      context,
                                                                      error,
                                                                      stackTrace,
                                                                    ) => SvgPicture.asset(
                                                                      'assets/logoProduct.svg',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: size8),
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
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            Text(
                                                              FormatCurrency.convertToIdr(
                                                                double.tryParse(
                                                                  detail[index]['price']
                                                                      .toString(),
                                                                ),
                                                              ).toString(),
                                                              style: body1(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            Text(
                                                              'Varian:\n${variantInfo.join('\n')}',
                                                              style: body1(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            Text(
                                                              'Catatan : ${detail[index]['description']}',
                                                              style: body1(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
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
                                                  'Outfit',
                                                ),
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
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        'Sub Total',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        'PPN',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        'Diskon',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        data['payment_name'] ??
                                                            '-',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        FormatCurrency.convertToIdr(
                                                          double.tryParse(
                                                            data['total_before_dsc_tax'],
                                                          ),
                                                        ).toString(),
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        FormatCurrency.convertToIdr(
                                                          data['ppn'] ?? '-',
                                                        ).toString(),
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        FormatCurrency.convertToIdr(
                                                          data['discount'] == ""
                                                              ? 0
                                                              : data['discount'],
                                                        ).toString(),
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
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
                                                  Text(
                                                    'Total',
                                                    style: heading2(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  Text(
                                                    FormatCurrency.convertToIdr(
                                                      double.parse(
                                                        data['amount']
                                                            .toString(),
                                                      ),
                                                    ).toString(),
                                                    style: heading2(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ],
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
                                                      SizedBox(height: size8),
                                                      Text(
                                                        data['payment_method_id'] ==
                                                                '001'
                                                            ? 'Uang Tunai'
                                                            : 'Non Tunai',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        'Kembalian',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          primary500,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      SizedBox(height: size8),
                                                      Text(
                                                        FormatCurrency.convertToIdr(
                                                          double.tryParse(
                                                            data['money_paid']
                                                                .toString(),
                                                          ),
                                                        ).toString(),
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                      Text(
                                                        FormatCurrency.convertToIdr(
                                                          double.tryParse(
                                                            data['change_money']
                                                                    .toString() ??
                                                                "-",
                                                          ),
                                                        ).toString(),
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          primary500,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      SizedBox(height: size8),
                                                    ],
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
                                      data['is_color'] == '1'
                                          ? GestureDetector(
                                              onTap: () {
                                                // hapusAlasan(context);
                                              },
                                              child: Text(
                                                'Transaksi Tidak Sesuai',
                                                style: heading3(
                                                  FontWeight.w600,
                                                  danger500,
                                                  'Outfit',
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                      SizedBox(width: size12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            // if (logoStrukPrinter != '') {
                                            //   getStrukPhoto();
                                            // }

                                            // log("ini adalah struk ${printext}");

                                            widget.bluetooth.isConnected.then((
                                              isConnected,
                                            ) {
                                              if (isConnected == true) {
                                                showSnackBarComponent(
                                                  context,
                                                  'Berhasil cetak struk',
                                                  '00',
                                                );
                                                // widget.bluetooth
                                                //     .printNewLine();
                                                logoStrukPrinter!.isEmpty
                                                    ? widget.bluetooth
                                                          .printNewLine()
                                                    : bluetooth.printImageBytes(
                                                        imageStruk,
                                                      );
                                                widget.bluetooth.printNewLine();
                                                widget.bluetooth.printCustom(
                                                  printext.replaceAll(
                                                    RegExp('[|]'),
                                                    '\n',
                                                  ),
                                                  Size.bold.val,
                                                  0,
                                                );
                                                // widget.bluetooth.printCustom(
                                                //     widget.printtext.replaceAll(RegExp('[|]'), '\n'),
                                                //     Size.bold.val,
                                                //     0);
                                                // widget.bluetooth
                                                //     .printNewLine();
                                                widget.bluetooth.printNewLine();
                                                widget.bluetooth.paperCut();
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
                                                  PhosphorIcons.printer_fill,
                                                  color: primary500,
                                                  size: size24,
                                                ),
                                                SizedBox(width: size12),
                                                Text(
                                                  'Cetak Struk',
                                                  style: heading3(
                                                    FontWeight.w600,
                                                    primary500,
                                                    'Outfit',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            MediaQuery.of(context).size.width,
                                            primary500,
                                          ),
                                        ),
                                      ),
                                      data['is_color'] == '1'
                                          ? SizedBox()
                                          : Expanded(
                                              child: Row(
                                                children: [
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
                                                            style: heading3(
                                                              FontWeight.w600,
                                                              bnw100,
                                                              'Outfit',
                                                            ),
                                                          ),
                                                        ),
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
    );
  }

  Future<dynamic> showBottomRiwayatPerubahan(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
                  padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
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
                              style: heading1(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            Text(
                              'Rincian riwayat perubahan transaksi',
                              style: heading4(
                                FontWeight.w400,
                                bnw500,
                                'Outfit',
                              ),
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
                            vertical: size12,
                            horizontal: size16,
                          ),
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
                                      borderRadius: BorderRadius.circular(
                                        size8,
                                      ),
                                      color: danger100,
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: size16,
                                            vertical: size12,
                                          ),
                                          child: Text(
                                            'Pengisian Terakhir',
                                            style: heading3(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: size16),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: size12,
                                            vertical: size8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              size8,
                                            ),
                                            color: danger500,
                                          ),
                                          child: Text(
                                            dataPerubahan['estimate'] ?? '-',
                                            style: heading3(
                                              FontWeight.w400,
                                              bnw100,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Icon(
                                    PhosphorIcons.caret_down,
                                    color: bnw900,
                                    size: size24,
                                  ),
                                ],
                              ),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                margin: EdgeInsets.only(
                                  top: isDropdownOpen ? size16 : 0,
                                ),
                                child: isDropdownOpen
                                    ? Column(
                                        children: [
                                          Container(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height /
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
                                                    'Outfit',
                                                  ),
                                                ),
                                                SizedBox(height: size12),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: buttonStatusTransaksi(
                                                    data,
                                                  ),
                                                ),
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
                                                        'Outfit',
                                                      ),
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
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: size8,
                                                            ),
                                                            Text(
                                                              'Nomor Tagihan',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: size8,
                                                            ),
                                                            Text(
                                                              'Kasir',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: size8,
                                                            ),
                                                            Text(
                                                              'Alasan Batal',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              dataPerubahan['entrydate'] ??
                                                                  '-',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: size8,
                                                            ),
                                                            Text(
                                                              dataPerubahan['transactionid'] ??
                                                                  '-',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: size8,
                                                            ),
                                                            Text(
                                                              dataPerubahan['pic'] ??
                                                                  '-',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: size8,
                                                            ),
                                                            Text(
                                                              dataPerubahan['reference']['alasan_reference'] ??
                                                                  '-',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
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
                                                        'Outfit',
                                                      ),
                                                    ),
                                                    SizedBox(height: size8),
                                                    Wrap(
                                                      children: [
                                                        for (final paragraph
                                                            in (dataPerubahan['reference']['detail_alasan_reference'] ??
                                                                    '')
                                                                .split('\n'))
                                                          Text(
                                                            paragraph,
                                                            style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit',
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size16),
                                                    Text(
                                                      'Rincian Produk',
                                                      style: heading3(
                                                        FontWeight.w600,
                                                        bnw900,
                                                        'Outfit',
                                                      ),
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
                                                        itemBuilder: (context, index) {
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
                                                                        'Outfit',
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          size8,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          size48,
                                                                      width:
                                                                          size48,
                                                                      child: AspectRatio(
                                                                        aspectRatio:
                                                                            1,
                                                                        child: Container(
                                                                          child: Image.network(
                                                                            detail[index]['product_image'],
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            errorBuilder:
                                                                                (
                                                                                  context,
                                                                                  error,
                                                                                  stackTrace,
                                                                                ) => SvgPicture.asset(
                                                                                  'assets/logoProduct.svg',
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          size8,
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
                                                                          detail[index]['name'] ??
                                                                              '-',
                                                                          style: heading3(
                                                                            FontWeight.w600,
                                                                            bnw900,
                                                                            'Outfit',
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          FormatCurrency.convertToIdr(
                                                                            detail[index]['amount'] ??
                                                                                '-',
                                                                          ).toString(),
                                                                          style: body1(
                                                                            FontWeight.w400,
                                                                            bnw900,
                                                                            'Outfit',
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Catatan : ${detail[index]['description']}',
                                                                          style: body1(
                                                                            FontWeight.w400,
                                                                            bnw900,
                                                                            'Outfit',
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
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
                                          ),
                                          dataPerubahan['isApprove'] == 'false'
                                              ? Column(
                                                  children: [
                                                    SizedBox(height: size16),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              approveReference(
                                                                context,
                                                                widget.token,
                                                                data['transactionid'],
                                                                'true',
                                                              );
                                                            },
                                                            child: buttonXL(
                                                              Center(
                                                                child: Text(
                                                                  'Setuju',
                                                                  style: heading2(
                                                                    FontWeight
                                                                        .w600,
                                                                    bnw100,
                                                                    'Outfit',
                                                                  ),
                                                                ),
                                                              ),
                                                              double.infinity,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: size16),
                                                        Expanded(
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              approveReference(
                                                                context,
                                                                widget.token,
                                                                data['transactionid'],
                                                                'false',
                                                              );
                                                            },
                                                            child: buttonXLoutline(
                                                              Center(
                                                                child: Text(
                                                                  'Tidak Setuju',
                                                                  style: heading2(
                                                                    FontWeight
                                                                        .w600,
                                                                    danger500,
                                                                    'Outfit',
                                                                  ),
                                                                ),
                                                              ),
                                                              double.infinity,
                                                              danger500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              : SizedBox(),
                                        ],
                                      )
                                    : SizedBox(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SizedBox();
          },
        );
      },
    );
  }

  buttonStatusTransaksi(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size12, vertical: size16),
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
              'Outfit',
            ),
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

  orderBy(BuildContext context) {
    return IntrinsicWidth(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showModalBottomSheet(
              constraints: const BoxConstraints(maxWidth: double.infinity),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context, setState) => IntrinsicHeight(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        size32,
                        size16,
                        size32,
                        size32,
                      ),
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
                                    FontWeight.w700,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Text(
                                  'Tentukan data yang akan tampil',
                                  style: heading4(
                                    FontWeight.w400,
                                    bnw600,
                                    'Outfit',
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Pilih Urutan',
                                  style: heading3(
                                    FontWeight.w400,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Wrap(
                                  children: List<Widget>.generate(
                                    orderByRiwayatText.length,
                                    (int index) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: size16),
                                        child: ChoiceChip(
                                          padding: EdgeInsets.symmetric(
                                            vertical: size12,
                                          ),
                                          backgroundColor: bnw100,
                                          selectedColor: primary100,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color:
                                                  valueOrderByProduct == index
                                                  ? primary500
                                                  : bnw300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              size8,
                                            ),
                                          ),
                                          label: Text(
                                            orderByRiwayatText[index],
                                            style: heading4(
                                              FontWeight.w400,
                                              valueOrderByProduct == index
                                                  ? primary500
                                                  : bnw900,
                                              'Outfit',
                                            ),
                                          ),
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
                                print(orderByRiwayatText[valueOrderByProduct]);

                                textOrderBy =
                                    orderByRiwayatText[valueOrderByProduct];
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
                                      FontWeight.w600,
                                      bnw100,
                                      'Outfit',
                                    ),
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
                style: heading3(FontWeight.w600, bnw900, 'Outfit'),
              ),
              Text(
                ' dari $textOrderBy',
                style: heading3(FontWeight.w400, bnw900, 'Outfit'),
              ),
              SizedBox(width: size12),
              Icon(PhosphorIcons.caret_down, color: bnw900, size: size24),
            ],
          ),
          bnw300,
        ),
      ),
    );
  }
}
