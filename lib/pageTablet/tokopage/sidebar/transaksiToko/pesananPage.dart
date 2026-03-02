import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:unipos_app_335/utils/component/component_snackbar.dart';

import '../../../../utils/component/component_showModalBottom.dart';
import '../../../../utils/component/providerModel/refreshTampilanModel.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../../utils/component/component_orderBy.dart';
import '../../../../models/keranjangModel.dart';
import '../../../../models/tokoModel/riwayatTransaksiTokoModel.dart';
import '../../../../models/tokoModel/singleRiwayatModel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';

import '../../../../utils/printer/printerPage.dart';
import '../../../../utils/printer/printerenum.dart';
import '../../../../utils/component/component_color.dart';
import '../produkToko/produk.dart';
import 'pilihPelangganPage.dart';
import 'transaksi.dart';
import '../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_loading.dart';
import 'package:http/http.dart' as http;

String? transactionidValue;
bool isTagihan = false;

double asDouble(dynamic v, {double def = 0}) {
  if (v == null) return def;
  return double.tryParse(v.toString()) ?? def;
}

String moneyString(dynamic v, {bool isThousandUnit = false}) {
  double n = asDouble(v);
  if (isThousandUnit) n = n * 1000;
  return n.toStringAsFixed(2);
}

class SimpanPage extends StatefulWidget {
  String token;
  PageController pageController;
  final BlueThermalPrinter bluetooth;
  SimpanPage({
    Key? key,
    required this.token,
    required this.bluetooth,
    required this.pageController,
  }) : super(key: key);

  @override
  State<SimpanPage> createState() => _SimpanPageState();
}

class _SimpanPageState extends State<SimpanPage> {
  var detailUbah;

  List<TokoDataRiwayatModel>? datasRiwayat;
  List<DetailSingle>? datasSingleRiwayat;

  TextEditingController textController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  void scrollToTextField() {
    setState(() {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  List<String> cartProductIds = [];
  String? nameSingle, transaksiReference, idKategori;

  String textOrderBy = 'Tagihan Terbaru';
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
    super.initState();
    checkConnection(context);

    isTagihan = true;
    if (logoStrukPrinter != '') {
      getStrukPhoto();
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      datasRiwayat = await getRiwayatTransaksi(
        context,
        widget.token,
        '0',
        '',
        textvalueOrderBy,
      );

      setState(() {});
    });

    setState(() {
      print(datasRiwayat.toString());
      datasRiwayat;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  double? width;
  double widtValue = 120;

  double heightInformation = 0;
  double widthInformation = 0;

  @override
  Widget build(BuildContext context) {
    return datasRiwayat == null
        ? Container(
            margin: EdgeInsets.all(size16),
            padding: EdgeInsets.all(size16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size16),
              color: bnw100,
            ),
            child: Scaffold(
              backgroundColor: bnw100,
              body: Center(child: loading()),
            ),
          )
        : Padding(
            padding: EdgeInsets.all(size16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        widget.pageController.jumpToPage(0);
                        transactionidValue = '';
                        setState(() {});
                      },
                      child: Icon(
                        PhosphorIcons.arrow_left,
                        color: bnw900,
                        size: size48,
                      ),
                    ),
                    SizedBox(width: size12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Tagihan',
                          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                        ),
                        Text(
                          'Tagihan Yang Belum selesai dibayarkan',
                          style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: size16, bottom: size16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      orderBy(context),
                      buttonLoutlineColor(
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.info_fill,
                              color: danger500,
                              size: size24,
                            ),
                            SizedBox(width: size12),
                            Text(
                              '${datasRiwayat!.length} Tagihan Belum Dibayar',
                              style: TextStyle(
                                color: danger500,
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        danger100,
                        danger500,
                      ),
                    ],
                  ),
                ),
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
                                    topLeft: Radius.circular(size16),
                                    topRight: Radius.circular(size16),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size16,
                                    vertical: size12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          child: Text(
                                            'Nama Pemesan',
                                            style: heading4(
                                              FontWeight.w600,
                                              bnw100,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      Expanded(
                                        child: SizedBox(
                                          child: Text(
                                            'Total Harga',
                                            style: heading4(
                                              FontWeight.w600,
                                              bnw100,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      Expanded(
                                        child: SizedBox(
                                          child: Text(
                                            'Waktu',
                                            style: heading4(
                                              FontWeight.w600,
                                              bnw100,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      Expanded(
                                        child: SizedBox(
                                          child: Text(
                                            'Status',
                                            style: heading4(
                                              FontWeight.w600,
                                              bnw100,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primary100,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(size16),
                                      bottomRight: Radius.circular(size16),
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
                                      padding: EdgeInsets.zero,
                                      itemCount: datasRiwayat!.length,
                                      itemBuilder: (builder, index) {
                                        return GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            widthInformation = MediaQuery.of(
                                              context,
                                            ).size.width;
                                            heightInformation = MediaQuery.of(
                                              context,
                                            ).size.height;

                                            transactionidValue =
                                                datasRiwayat![index]
                                                    .transactionid
                                                    .toString();

                                            print(transactionidValue);

                                            String productId =
                                                transactionidValue.toString();

                                            if (cartProductIds.contains(
                                              productId,
                                            )) {
                                              cartProductIds.clear();
                                              width = null;
                                              widtValue = 120;
                                              heightInformation = 0;
                                              widthInformation = 0;

                                              cart.clear();
                                              cartMap.clear();
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
                                                      width: width1,
                                                    ),
                                                  ),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: size16,
                                                  vertical: size16,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        width: widtValue,
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
                                                    ),
                                                    SizedBox(width: size16),
                                                    Expanded(
                                                      child: SizedBox(
                                                        width: widtValue,
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
                                                    ),
                                                    SizedBox(width: size16),
                                                    Expanded(
                                                      child: SizedBox(
                                                        width: widtValue,
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
                                                    ),
                                                    SizedBox(width: size16),
                                                    Expanded(
                                                      child: SizedBox(
                                                        width: widtValue,
                                                        child: Text(
                                                          datasRiwayat![index]
                                                              .status
                                                              .toString(),
                                                          style: heading4(
                                                            FontWeight.w400,
                                                            succes500,
                                                            'Outfit',
                                                          ),
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
                      widthInformation != 0
                          ? SizedBox(width: size16)
                          : Container(),
                      widthInformation == 0
                          ? Container()
                          : Expanded(
                              child: FutureBuilder(
                                future: getSingleRiwayatTransaksi(
                                  widget.token,
                                  transactionidValue,
                                  '',
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    Map<String, dynamic>? data =
                                        snapshot.data!['data'];
                                    var detail = data!['detail'];
                                    detailUbah = detail;

                                    return AnimatedContainer(
                                      duration: Duration(seconds: 1),
                                      padding: EdgeInsets.all(size16),
                                      height: heightInformation,
                                      width: widthInformation,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          size8,
                                        ),
                                        border: Border.all(color: bnw300),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: ListView(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics: BouncingScrollPhysics(),
                                              children: [
                                                Text(
                                                  'Status Tagihan',
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
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal:
                                                                  size12,
                                                              vertical: size16,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: succes100,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                size8,
                                                              ),
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
                                                                succes500,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            Icon(
                                                              PhosphorIcons
                                                                  .info_fill,
                                                              color: succes500,
                                                              size: size24,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: size16),
                                                SizedBox(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Informasi Tagihan',
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
                                                                'Waktu Tagihan',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
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
                                                                  FontWeight
                                                                      .w400,
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
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                'Nama Pembeli',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
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
                                                                data['entrydate'] ??
                                                                    '',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                data['transactionid'] ??
                                                                    '',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                data['pic'] ??
                                                                    '',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                data['customer'] ??
                                                                    '',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
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
                                                    FontWeight.w600,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
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
                                                      var variants =
                                                          detail[index]['variants'];
                                                      List<String> variantInfo =
                                                          [];

                                                      // Mengecek apakah variants ada dan bukan kosong
                                                      if (variants != null &&
                                                          variants.isNotEmpty) {
                                                        for (var variant
                                                            in variants) {
                                                          // Menyusun nama kategori dan nama produk
                                                          for (var product
                                                              in variant['variant_products']) {
                                                            variantInfo.add(
                                                              '+ ${variant['variant_category_title']} (${product['variant_product_name']})',
                                                            );
                                                          }
                                                        }
                                                      }

                                                      nameSingle =
                                                          detail[index]['name'];

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
                                                                Container(
                                                                  margin: EdgeInsets.only(
                                                                    left: size8,
                                                                    right:
                                                                        size8,
                                                                  ),
                                                                  height: 48,
                                                                  width: 48,
                                                                  child: Image.network(
                                                                    detail[index]['product_image'],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    loadingBuilder:
                                                                        (
                                                                          context,
                                                                          child,
                                                                          loadingProgress,
                                                                        ) {
                                                                          if (loadingProgress ==
                                                                              null) {
                                                                            return child;
                                                                          }

                                                                          return Center(
                                                                            child:
                                                                                loading(),
                                                                          );
                                                                        },
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
                                                                          '',
                                                                      style: heading3(
                                                                        FontWeight
                                                                            .w600,
                                                                        bnw900,
                                                                        'Outfit',
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      FormatCurrency.convertToIdr(
                                                                        detail[index]['price'] ??
                                                                            '',
                                                                      ).toString(),
                                                                      style: body1(
                                                                        FontWeight
                                                                            .w400,
                                                                        bnw900,
                                                                        'Outfit',
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      'Varian:\n${variantInfo.join(', ')}',
                                                                      style: body1(
                                                                        FontWeight
                                                                            .w400,
                                                                        bnw900,
                                                                        'Outfit',
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      'Catatan : ${detail[index]['description']}',
                                                                      style: body1(
                                                                        FontWeight
                                                                            .w400,
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
                                                        CrossAxisAlignment
                                                            .start,
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
                                                                'Sub Total',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                'PPN',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                'Diskon',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
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
                                                                FormatCurrency.convertToIdr(
                                                                  data['total_before_dsc_tax'] ??
                                                                      '',
                                                                ).toString(),
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                FormatCurrency.convertToIdr(
                                                                  data['ppn'] ??
                                                                      '',
                                                                ).toString(),
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: size8,
                                                              ),
                                                              Text(
                                                                FormatCurrency.convertToIdr(
                                                                  data['discount'] ==
                                                                          ""
                                                                      ? 0
                                                                      : data['discount'] ??
                                                                            '',
                                                                ),
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              top: size8,
                                                              bottom: size8,
                                                            ),
                                                        child: Row(
                                                          children: List.generate(
                                                            300 ~/ 6,
                                                            (index) => Flexible(
                                                              child: Container(
                                                                color:
                                                                    index % 2 ==
                                                                        0
                                                                    ? Colors
                                                                          .transparent
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
                                                              'Outfit',
                                                            ),
                                                          ),
                                                          Text(
                                                            FormatCurrency.convertToIdr(
                                                              data['amount'] ??
                                                                  '',
                                                            ).toString(),
                                                            style: heading1(
                                                              FontWeight.w700,
                                                              bnw900,
                                                              'Outfit',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: size16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    log(
                                                      logoStrukPrinter
                                                          .toString(),
                                                    );

                                                    widget.bluetooth.isConnected.then((
                                                      isConnected,
                                                    ) {
                                                      if (isConnected == true) {
                                                        // widget.bluetooth
                                                        //     .printNewLine();
                                                        // widget.bluetooth
                                                        //     .printNewLine();
                                                        // widget.bluetooth.printImage(file.path);
                                                        // bluetooth.printImageBytes(
                                                        //     img); //image from Network
                                                        logoStrukPrinter!
                                                                .isEmpty
                                                            ? widget.bluetooth
                                                                  .printNewLine()
                                                            : bluetooth
                                                                  .printImageBytes(
                                                                    imageStruk,
                                                                  );
                                                        widget.bluetooth
                                                            .printNewLine();
                                                        // widget.bluetooth
                                                        //     .printNewLine();
                                                        widget.bluetooth
                                                            .printCustom(
                                                              printext
                                                                  .replaceAll(
                                                                    RegExp(
                                                                      '[|]',
                                                                    ),
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
                                                        // widget.bluetooth.printNewLine();
                                                        widget.bluetooth
                                                            .printNewLine();
                                                        widget.bluetooth
                                                            .paperCut();
                                                      } else {
                                                        dialogNoPrinter(
                                                          context,
                                                        );
                                                      }
                                                    });
                                                    setState(() {});
                                                  },
                                                  child: buttonXLoutline(
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          PhosphorIcons
                                                              .printer_fill,
                                                          color: primary500,
                                                          size: size20,
                                                        ),
                                                        SizedBox(width: size16),
                                                        Text(
                                                          'Cetak',
                                                          style: heading3(
                                                            FontWeight.w600,
                                                            primary500,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    MediaQuery.of(
                                                          context,
                                                        ).size.width /
                                                        5.7,
                                                    primary500,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(width: size16),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    final List<
                                                      Map<String, dynamic>
                                                    >
                                                    mapCalculateFinal = [];
                                                    for (final item
                                                        in mapCalculateFinal) {
                                                      cartMap.add({
                                                        "request_id":
                                                            (item["request_id"] ??
                                                                    "")
                                                                .toString(),
                                                        "product_id":
                                                            (item["product_id"] ??
                                                                    "")
                                                                .toString(),
                                                        "is_online":
                                                            (item["is_online"] ??
                                                                    false)
                                                                .toString(),
                                                        "is_customize":
                                                            (item["is_customize"] ??
                                                                    false)
                                                                .toString(),
                                                        "amount":
                                                            (item["amount"] ??
                                                                    "0")
                                                                .toString(),
                                                        "name":
                                                            (item["name"] ?? "")
                                                                .toString(),
                                                        "quantity":
                                                            (item["quantity"] ??
                                                                    1)
                                                                .toString(),
                                                        "description":
                                                            (item["description"] ??
                                                                    "")
                                                                .toString(),
                                                        // variants bentuknya list/map, tapi cartMap kamu Map<String,String> → simpan sebagai string JSON
                                                        "variants": jsonEncode(
                                                          item["variants"] ??
                                                              [],
                                                        ),
                                                      });
                                                    }

                                                    print(
                                                      "PAYLOAD cartMap(FIX): ${jsonEncode(cartMap)}",
                                                    );
                                                    for (final d in detail) {
                                                      final bool isCustom =
                                                          asBool(
                                                            d['is_customize'],
                                                          );
                                                      final bool isOnline =
                                                          asBool(
                                                            d['is_online'],
                                                          );

                                                      final dynamic
                                                      basePriceSource = isCustom
                                                          ? (d['amount_display'] ??
                                                                d['custom_amount'] ??
                                                                d['price'] ??
                                                                d['amount'])
                                                          : (d['price'] ??
                                                                d['amount']);

                                                      final String baseAmount =
                                                          moneyString(
                                                            basePriceSource,
                                                            isThousandUnit:
                                                                false,
                                                          );

                                                      final List variantsReq =
                                                          [];
                                                      final variants =
                                                          (d['variants']
                                                              as List?) ??
                                                          [];

                                                      for (final cat
                                                          in variants) {
                                                        final catId =
                                                            (cat['variant_category_id'] ??
                                                                    '')
                                                                .toString();
                                                        final variantProduct =
                                                            (cat['variant_products']
                                                                as List?) ??
                                                            [];

                                                        final List<
                                                          Map<String, dynamic>
                                                        >
                                                        variantArr = [];

                                                        for (final vp
                                                            in variantProduct) {
                                                          final bool
                                                          isVariantCustom = asBool(
                                                            vp['is_variant_customize'],
                                                          );

                                                          final double
                                                          vpPriceDouble =
                                                              double.tryParse(
                                                                (vp['price'] ??
                                                                        vp['variant_price'] ??
                                                                        '0')
                                                                    .toString(),
                                                              ) ??
                                                              0.0;

                                                          final int varPrice =
                                                              vpPriceDouble
                                                                  .round();

                                                          variantArr.add({
                                                            "variant_id":
                                                                (vp['variant_product_id'] ??
                                                                        '')
                                                                    .toString(),
                                                            "variant_price":
                                                                varPrice,
                                                            "is_variant_customize":
                                                                isVariantCustom
                                                                ? 1
                                                                : 0,
                                                          });
                                                        }
                                                        variantsReq.add({
                                                          "variant_category_id":
                                                              catId,
                                                          "variant": variantArr,
                                                        });
                                                      }
                                                      mapCalculateFinal.add({
                                                        "request_id":
                                                            (d['request_id'] ??
                                                                    '')
                                                                .toString(),
                                                        "product_id":
                                                            (d['product_id'] ??
                                                                    d['productid'] ??
                                                                    '')
                                                                .toString(),
                                                        "is_online": isOnline,
                                                        "is_customize":
                                                            isCustom,
                                                        "amount": baseAmount,
                                                        "name":
                                                            (d['name'] ?? '')
                                                                .toString(),
                                                        "quantity": asInt(
                                                          d['quantity'],
                                                          fallback: 1,
                                                        ),
                                                        "description":
                                                            d['description'],
                                                        "variants": variantsReq,
                                                      });

                                                      cartMap.clear();

                                                      for (final item
                                                          in mapCalculateFinal) {
                                                        cartMap.add({
                                                          "request_id":
                                                              (item["request_id"] ??
                                                                      "")
                                                                  .toString(),
                                                          "product_id":
                                                              (item["product_id"] ??
                                                                      "")
                                                                  .toString(),
                                                          "is_online": asBool(
                                                            item["is_online"],
                                                          ).toString(),
                                                          "is_customize": asBool(
                                                            item["is_customize"],
                                                          ).toString(),
                                                          "amount":
                                                              (item["amount"] ??
                                                                      "0")
                                                                  .toString(),
                                                          "name":
                                                              (item["name"] ??
                                                                      "")
                                                                  .toString(),
                                                          "quantity":
                                                              (item["quantity"] ??
                                                                      1)
                                                                  .toString(),
                                                          "description":
                                                              (item["description"] ??
                                                                      "")
                                                                  .toString(),
                                                          // ✅ simpan variants sebagai JSON string (biar cartMap tetap Map<String,String>)
                                                          "variants": jsonEncode(
                                                            item["variants"] ??
                                                                [],
                                                          ),
                                                        });
                                                      }

                                                      print(
                                                        "PAYLOAD cartMap(FINAL): ${jsonEncode(cartMap)}",
                                                      );
                                                    }

                                                    print(
                                                      "PAYLOAD cartMap: ${jsonEncode(mapCalculateFinal)}",
                                                    );
                                                    if (mapCalculateFinal
                                                        .isNotEmpty) {
                                                      isTagihan = true;

                                                      final cartForPayment = detail.map<CartTransaksi>((
                                                        d,
                                                      ) {
                                                        final m =
                                                            d
                                                                as Map<
                                                                  String,
                                                                  dynamic
                                                                >;
                                                        final qty = asInt(
                                                          m['quantity'],
                                                          fallback: 1,
                                                        );
                                                        final priceDouble =
                                                            double.tryParse(
                                                              (m['price'] ??
                                                                      m['amount'] ??
                                                                      '0')
                                                                  .toString(),
                                                            ) ??
                                                            0;

                                                        return CartTransaksi(
                                                          name:
                                                              (m['name'] ?? '')
                                                                  .toString(),
                                                          productid:
                                                              (m['product_id'] ??
                                                                      m['productid'] ??
                                                                      '')
                                                                  .toString(),
                                                          image:
                                                              (m['product_image'] ??
                                                                      m['image'] ??
                                                                      '')
                                                                  .toString(),
                                                          price: priceDouble,
                                                          quantity: qty,
                                                          desc:
                                                              (m['description'] ??
                                                                      '')
                                                                  .toString(),
                                                          idRequest:
                                                              (m['request_id'] ??
                                                                      '')
                                                                  .toString(),
                                                          variants: jsonEncode(
                                                            m['variants'] ?? [],
                                                          ),
                                                        );
                                                      }).toList();

                                                      // penting: update state utama
                                                      this.setState(() {
                                                        cart
                                                          ..clear()
                                                          ..addAll(
                                                            cartForPayment,
                                                          );
                                                      });

                                                      await calculateTransaction(
                                                        context,
                                                        widget.token,
                                                        mapCalculateFinal,
                                                        this.setState,
                                                        pelangganId,
                                                        '', // typePrice (kalau gak dipakai isi kosong / "price")
                                                        data['discountid'] ??
                                                            '', // ✅ discount yang bener
                                                        transactionidValue,
                                                      ).then((value) {
                                                        if (value == '00') {
                                                          width = null;
                                                          widtValue = 120;
                                                          heightInformation = 0;
                                                          widthInformation = 0;

                                                          // Menunda pemindahan halaman untuk memberikan waktu
                                                          Future.delayed(
                                                            const Duration(
                                                              seconds: 1,
                                                            ),
                                                            () {
                                                              widget
                                                                  .pageController
                                                                  .jumpToPage(
                                                                    1,
                                                                  );
                                                            },
                                                          );
                                                        } else {
                                                          isTagihan = true;
                                                        }
                                                      });

                                                      setState(() {
                                                        transactionidValue;
                                                        subTotal;
                                                        printext;
                                                        transaksiNama;
                                                        transaksiMetode;
                                                        transaksiPesanan;
                                                        transaksiKasir;
                                                      });
                                                    } else {
                                                      closeLoading(context);
                                                    }

                                                    setState(() {});
                                                  },
                                                  child: buttonXL(
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          PhosphorIcons
                                                              .wallet_fill,
                                                          color: bnw100,
                                                          size: size24,
                                                        ),
                                                        SizedBox(width: size16),
                                                        Text(
                                                          'Bayar',
                                                          style: heading3(
                                                            FontWeight.w600,
                                                            bnw100,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    180,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: size16),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    textController.text = '';
                                                    aturTagihan(context);
                                                  });
                                                },
                                                child: buttonXLoutline(
                                                  Icon(
                                                    PhosphorIcons
                                                        .dots_three_outline_vertical_fill,
                                                    size: size24,
                                                    color: primary500,
                                                  ),
                                                  0,
                                                  bnw100,
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
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  aturTagihan(BuildContext context) {
    final refreshSelectedProvider = Provider.of<RefreshSelected>(
      context,
      listen: false,
    );
    showModalBottom(
      context,
      MediaQuery.of(context).size.height,
      IntrinsicHeight(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atur Tagihan',
                        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      Text(
                        transactionidValue ?? '',
                        style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(PhosphorIcons.x_fill, color: bnw900),
                  ),
                ],
              ),
              SizedBox(height: size24),

              GestureDetector(
                onTap: () {
                  refreshSelectedProvider.valueSelected = null;
                  hapusAlasan(context);
                },
                behavior: HitTestBehavior.translucent,
                child: modalBottomValue('Hapus Tagihan', PhosphorIcons.trash),
              ),
            ],
          ),
        ),
      ),
    );
  }

  hapusAlasan(BuildContext context) {
    errorText = '';
    final refreshSelectedProvider = Provider.of<RefreshSelected>(
      context,
      listen: false,
    );
    final String txId = (transactionidValue ?? '').toString().trim();
    if (txId.isEmpty) {
      showSnackbar(context, {"rc": "99", "message": "Pilih tagihan dulu"});
      return;
    }
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: headerTagihan(context, widget.token, txId, 'hapus'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return StatefulBuilder(
                builder: (context, setState) {
                  transaksiReference = snapshot.data['transaksiid_reference'];
                  return IntrinsicHeight(
                    child: Container(
                      // padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      decoration: BoxDecoration(
                        color: bnw100,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(size16),
                          topLeft: Radius.circular(size16),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          size32,
                          size16,
                          size32,
                          size32,
                        ),
                        child: Column(
                          children: [
                            dividerShowdialog(),
                            SizedBox(height: size16),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (isTagihan == true) {
                                      isTagihan = false;
                                      cart.clear();
                                      cartMap.clear();

                                      total = [];
                                      subTotal = 0;
                                      sumTotal = 0;

                                      cartProductIds.clear();
                                      conCatatan.clear();
                                      transactionidValue = "";

                                      setState(() {});
                                    }
                                    refreshSelectedProvider.valueSelected =
                                        null;
                                  },
                                  child: Icon(
                                    PhosphorIcons.arrow_left,
                                    color: bnw900,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Batalkan Tagihan',
                                      style: heading2(
                                        FontWeight.w700,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                    Text(
                                      'Pilih alasan yang sesuai',
                                      style: heading4(
                                        FontWeight.w400,
                                        bnw600,
                                        'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: size16),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                physics: BouncingScrollPhysics(),
                                child: Container(
                                  width: double.infinity,
                                  color: bnw100,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Alasan Tidak Sesuai',
                                            style: heading3(
                                              FontWeight.w400,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                          Text(
                                            '*',
                                            style: heading3(
                                              FontWeight.w400,
                                              danger500,
                                              'Outfit',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: size16),
                                      Consumer<RefreshSelected>(
                                        builder: (context, value, _) {
                                          return Container(
                                            child: Wrap(
                                              spacing: size16,
                                              runSpacing: size16,
                                              children: List<Widget>.generate(
                                                snapshot.data['alasan'].length,
                                                (int index) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        transaksiReference =
                                                            snapshot
                                                                .data['transaksiid_reference'];

                                                        value.refreshTampilan(
                                                          index,
                                                        );
                                                        print(
                                                          value.valueSelected,
                                                        );
                                                        idKategori = snapshot
                                                            .data['alasan'][index]['idkategori'];
                                                      });
                                                    },
                                                    child: buttonL(
                                                      Center(
                                                        child: Text(
                                                          snapshot
                                                              .data['alasan'][index]['namakategori'],
                                                          style: heading4(
                                                            FontWeight.w400,
                                                            value.valueSelected ==
                                                                    index
                                                                ? primary500
                                                                : bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ),
                                                      value.valueSelected ==
                                                              index
                                                          ? primary100
                                                          : bnw100,
                                                      value.valueSelected ==
                                                              index
                                                          ? primary500
                                                          : bnw300,
                                                    ),
                                                  );
                                                },
                                              ).toList(),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(height: size16),
                                      Row(
                                        children: [
                                          Text(
                                            'Detail Alasan',
                                            style: heading4(
                                              FontWeight.w500,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                          Text(
                                            '*',
                                            style: heading4(
                                              FontWeight.w700,
                                              red500,
                                              'Outfit',
                                            ),
                                          ),
                                        ],
                                      ),
                                      IntrinsicHeight(
                                        child: TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          style: heading2(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              value.isEmpty
                                                  ? errorText = ''
                                                  : null;
                                            });
                                          },
                                          cursorColor: primary500,
                                          controller: textController,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: size16,
                                                ),
                                            hintText:
                                                'Cth : Transakasi salah karena ada kesalahan penginputan.',
                                            hintStyle: heading2(
                                              FontWeight.w600,
                                              bnw400,
                                              'Outfit',
                                            ),
                                            errorText: errorText.isNotEmpty
                                                ? errorText
                                                : null,
                                            errorStyle: body1(
                                              FontWeight.w500,
                                              red500,
                                              'Outfit',
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                width: 2,
                                                color: primary500,
                                              ),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                width: 1,
                                                color: bnw400,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    width: 2,
                                                    color: red500,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            textController.text.isEmpty
                                ? SizedBox()
                                : Column(
                                    children: [
                                      SizedBox(height: size32),
                                      SizedBox(
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        child: GestureDetector(
                                          onTap: () async {
                                            final String txId =
                                                (transactionidValue ?? '')
                                                    .toString()
                                                    .trim();
                                            final String cat =
                                                (idKategori ?? '')
                                                    .toString()
                                                    .trim();
                                            final String alasan = textController
                                                .text
                                                .trim();

                                            if (txId.isEmpty) {
                                              showSnackbar(context, {
                                                "rc": "99",
                                                "message": "Pilih tagihan dulu",
                                              });
                                              return;
                                            }
                                            if (cat.isEmpty) {
                                              setState(
                                                () => errorText =
                                                    "Alasan wajib dipilih",
                                              );
                                              return;
                                            }
                                            if (alasan.length < 15) {
                                              setState(
                                                () => errorText =
                                                    "Minimal lima belas karakter",
                                              );
                                              return;
                                            }

                                            whenLoading(context);

                                            final rc =
                                                await deleteTagihanTablet(
                                                  context,
                                                  token: widget.token,
                                                  transactionId: txId,
                                                  idkategori: cat,
                                                  detailAlasan: alasan,
                                                );

                                            closeLoading(context);

                                            if (rc == '00') {
                                              Navigator.of(context).popUntil(
                                                (route) => route.isFirst,
                                              );
                                            }
                                          },
                                          child: buttonXL(
                                            Center(
                                              child: Text(
                                                'Batalkan Tagihan',
                                                style: heading3(
                                                  FontWeight.w600,
                                                  bnw100,
                                                  'Outfit',
                                                ),
                                              ),
                                            ),
                                            double.infinity,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return SizedBox();
          },
        );
      },
    );
  }

  rincianText(String title, subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: size8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: heading4(FontWeight.w500, bnw900, 'Outfit')),
          Text(subtitle, style: heading4(FontWeight.w500, bnw900, 'Outfit')),
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
                                    orderByTagihanText.length,
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
                                            orderByTagihanText[index],
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
