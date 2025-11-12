import 'dart:developer';
import 'dart:typed_data';

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
    Uint8List imageBytesFromNetwork = bytesNetwork.buffer
        .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

    imageStruk = imageBytesFromNetwork;
    setState(() {});
  }

  @override
  void initState() {
    checkConnection(context);

    isTagihan = true;
    if (logoStrukPrinter != '') {
      getStrukPhoto();
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        datasRiwayat = await getRiwayatTransaksi(
          context,
          widget.token,
          '0',
          '',
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
                    // mainAxisAlignment: MainAxisAlignment.end,
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
                                      horizontal: size16, vertical: size12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          child: Text(
                                            'Nama Pemesan',
                                            style: heading4(FontWeight.w600,
                                                bnw100, 'Outfit'),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      Expanded(
                                        child: SizedBox(
                                          child: Text(
                                            'Total Harga',
                                            style: heading4(FontWeight.w600,
                                                bnw100, 'Outfit'),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      Expanded(
                                        child: SizedBox(
                                          child: Text(
                                            'Waktu',
                                            style: heading4(FontWeight.w600,
                                                bnw100, 'Outfit'),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      Expanded(
                                        child: SizedBox(
                                          child: Text(
                                            'Status',
                                            style: heading4(FontWeight.w600,
                                                bnw100, 'Outfit'),
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
                                      // physics:  BouncingScrollPhysics(),
                                      itemBuilder: (builder, index) {
                                        return GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            // width = MediaQuery.of(context)
                                            //         .size
                                            //         .width /
                                            //     2.6;
                                            // widtValue = 100;

                                            widthInformation =
                                                MediaQuery.of(context)
                                                    .size
                                                    .width;
                                            heightInformation =
                                                MediaQuery.of(context)
                                                    .size
                                                    .height;

                                            transactionidValue =
                                                datasRiwayat![index]
                                                    .transactionid;

                                            print(transactionidValue);

                                            // getSingleRiwayatTransaksi(
                                            //     widget.token,
                                            //     datasRiwayat![index]
                                            //         .transactionid);

                                            // cart.add(
                                            //   CartTransaksi(
                                            //     name: name,
                                            //     productid: productid,
                                            //     image: image,
                                            //     price: price,
                                            //     quantity: 1,
                                            // quantity: cart[i].quantity,
                                            //   ),
                                            // );

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
                                                              datasRiwayat![
                                                                      index]
                                                                  .transactionid
                                                                  .toString())
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
                                                    vertical: size16),
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
                                                              'Outfit'),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: size16),
                                                    Expanded(
                                                      child: SizedBox(
                                                        width: widtValue,
                                                        child: Text(
                                                          FormatCurrency.convertToIdr(
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
                                                              'Outfit'),
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
                                                              'Outfit'),
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
                                  widget.token, transactionidValue, ''),
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
                                      borderRadius:
                                          BorderRadius.circular(size8),
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
                                              //! error
                                              Text(
                                                'Status Tagihan',
                                                style: heading3(FontWeight.w600,
                                                    bnw900, 'Outfit'),
                                              ),
                                              SizedBox(height: size16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: size12,
                                                        vertical: size16,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: succes100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    size8),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            data[
                                                                'status_transactions'],
                                                            style: body1(
                                                                FontWeight.w400,
                                                                succes500,
                                                                'Outfit'),
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
                                                              'Nama Pembeli',
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
                                                              data['entrydate'],
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              data[
                                                                  'transactionid'],
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              data['pic'],
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              data['customer'],
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
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: size16),
                                              Text(
                                                'Rincian Produk',
                                                style: heading3(FontWeight.w600,
                                                    bnw900, 'Outfit'),
                                              ),
                                              SizedBox(height: size16),
                                              SizedBox(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.zero,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount: detail.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    // dynamic details;

                                                    // cartMap.forEach((element) {
                                                    //   var myelement = element[
                                                    //       'product_image'];
                                                    //   details = myelement;

                                                    //   // log('a' +
                                                    //   //     element.toString());
                                                    // });

                                                    // log(cartMap.toString());

                                                    // cartMap.clear();

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
                                                                    'Outfit'),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            size8,
                                                                        right:
                                                                            size8),
                                                                height: 48,
                                                                width: 48,
                                                                child: Image
                                                                    .network(
                                                                  detail[index][
                                                                      'product_image'],
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  loadingBuilder:
                                                                      (context,
                                                                          child,
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
                                                                        [
                                                                        'name'],
                                                                    style: heading3(
                                                                        FontWeight
                                                                            .w600,
                                                                        bnw900,
                                                                        'Outfit'),
                                                                  ),
                                                                  Text(
                                                                    FormatCurrency.convertToIdr(detail[index]
                                                                            [
                                                                            'price'])
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
                                                              'Sub Total',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              'PPN',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              'Diskon',
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
                                                              FormatCurrency
                                                                      .convertToIdr(
                                                                          data[
                                                                              'total_before_dsc_tax'])
                                                                  .toString(),
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              FormatCurrency
                                                                      .convertToIdr(
                                                                          data[
                                                                              'ppn'])
                                                                  .toString(),
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size8),
                                                            Text(
                                                              FormatCurrency
                                                                  .convertToIdr(
                                                                      data['discount'] ==
                                                                              ""
                                                                          ? 0
                                                                          : data[
                                                                              'discount']),
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
                                                              color: index %
                                                                          2 ==
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
                                                              'Outfit'),
                                                        ),
                                                        Text(
                                                          FormatCurrency
                                                                  .convertToIdr(
                                                                      data[
                                                                          'amount'])
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
                                        SizedBox(height: size16),
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
                                                  log(logoStrukPrinter
                                                      .toString());

                                                  widget.bluetooth.isConnected
                                                      .then((isConnected) {
                                                    if (isConnected == true) {
                                                      // widget.bluetooth
                                                      //     .printNewLine();
                                                      // widget.bluetooth
                                                      //     .printNewLine();
                                                      // widget.bluetooth.printImage(file.path);
                                                      // bluetooth.printImageBytes(
                                                      //     img); //image from Network
                                                      logoStrukPrinter!.isEmpty
                                                          ? widget.bluetooth
                                                              .printNewLine()
                                                          : bluetooth
                                                              .printImageBytes(
                                                                  imageStruk);
                                                      widget.bluetooth
                                                          .printNewLine();
                                                      // widget.bluetooth
                                                      //     .printNewLine();
                                                      widget.bluetooth
                                                          .printCustom(
                                                              printext
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          '[|]'),
                                                                      '\n'),
                                                              Size.bold.val,
                                                              0);
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
                                                      dialogNoPrinter(context);
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
                                                              'Outfit'),
                                                        ),
                                                      ]),
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      5.7,
                                                  primary500,
                                                ),
                                              ),
                                            ),

                                            SizedBox(width: size16),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  // whenLoading(context);
                                                  cart.clear();
                                                  cartMap.clear();

                                                  int newtotal = 0;
                                                  for (var element in cartMap) {
                                                    var myelement = int.parse(
                                                        element['amount']!);

                                                    newtotal =
                                                        newtotal + myelement;
                                                  }

                                                  sumTotal = newtotal;
                                                  total = [];
                                                  subTotal = 0;
                                                  sumTotal = 0;
                                                  transactionidValue;
                                                  printext = '';
                                                  pelangganName = '';
                                                  pelangganId = '';
                                                  namaCustomerCalculate = '';

                                                  log('data $detail');

                                                  int i;
                                                  for (i = 0;
                                                      i < detail.length;
                                                      i++) {
                                                    // print(detail[i]['name']);

                                                    // log("hello im detail $detail");

                                                    Map<String, String> map1 =
                                                        {};
                                                    map1['name'] = detail[i]
                                                            ['name']
                                                        .toString();
                                                    map1['productid'] =
                                                        detail![i]['productid']
                                                            .toString();
                                                    map1['quantity'] = detail[i]
                                                            ['quantity']
                                                        .toString();
                                                    map1['image'] = detail[i]
                                                            ['product_image']
                                                        .toString();

                                                    // map1['amount_display'] =
                                                    //     detail[i]['original_price']
                                                    //         .toString();

                                                    map1['amount'] = detail[i]
                                                            // ['original_price']
                                                            ['price']
                                                        .toString();

                                                    //ini yang diubah
                                                    map1['description'] =
                                                        detail[i]
                                                            ['description'];

                                                    cartMap.add(map1);

                                                    String name = detail[i]
                                                            ['name']
                                                        .toString()
                                                        .trim();
                                                    String productid = detail[i]
                                                            ['productid']
                                                        .toString()
                                                        .trim();
                                                    String image = detail![i]
                                                            ['product_image']
                                                        .toString()
                                                        .trim();
                                                    int? price =
                                                        detail[i]['price'];
                                                    // detail[i]['amount'];
                                                    int quantity =
                                                        detail[i]['quantity'];

                                                    String desc = detail[i]
                                                            ['description']
                                                        .toString()
                                                        .trim();

                                                    sumTotal = sumTotal +
                                                        price!.toInt();
                                                    // subTotal =
                                                    //     subTotal + price.toInt();
                                                    total.add(price);

                                                    cart.add(
                                                      CartTransaksi(
                                                          name: name,
                                                          productid: productid,
                                                          image: image,
                                                          price: price,
                                                          quantity: quantity,
                                                          desc: desc,
                                                          idRequest: ""
                                                          // quantity:
                                                          //     cart[i].quantity,
                                                          ),
                                                    );
                                                  }

                                                  // print(detail);
                                                  // print(detail);

                                                  if (cartMap.isNotEmpty) {
                                                    // initState();

                                                    isTagihan = true;

                                                    // log("hello world $cartMap");

                                                    // log(pelangganId.toString());

                                                    await calculateTransaction(
                                                      context,
                                                      widget.token,
                                                      cartMap,
                                                      setState,
                                                      pelangganId,
                                                      data['discountid'] ?? '',
                                                      "",
                                                    ).then((value) {
                                                      if (value == '00') {
                                                        width = null;
                                                        widtValue = 120;
                                                        heightInformation = 0;
                                                        widthInformation = 0;

                                                        Future.delayed(
                                                          const Duration(
                                                              seconds: 1),
                                                          () {
                                                            widget
                                                                .pageController
                                                                .jumpToPage(1);
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

                                                  total;
                                                  subTotal;
                                                  sumTotal;
                                                  namaCustomerCalculate;
                                                  subTotal;
                                                  ppnTransaksi;

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
                            )),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  aturTagihan(BuildContext context) {
    final refreshSelectedProvider =
        Provider.of<RefreshSelected>(context, listen: false);
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
                    child: Icon(
                      PhosphorIcons.x_fill,
                      color: bnw900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size24),
              // GestureDetector(
              //   behavior: HitTestBehavior.translucent,
              //   onTap: () async {
              //     setState(() async {
              //       refreshSelectedProvider.valueSelected = null;
              //       widget.pageController.jumpToPage(0);
              //       cart.clear();
              //       cartMap.clear();

              //       int newtotal = 0;
              //       for (var element in cartMap) {
              //         var myelement = int.parse(element['amount']!);

              //         newtotal = newtotal + myelement;
              //       }

              //       sumTotal = newtotal;
              //       total = [];
              //       subTotal = 0;
              //       sumTotal = 0;
              //       transactionidValue;
              //       printext = '';
              //       pelangganName = '';
              //       pelangganId = '';
              //       namaCustomerCalculate = '';

              //       int i;
              //       for (i = 0; i < detailUbah.length; i++) {
              //         // print(detailUbah[i]['name']);

              //         Map<String, String> map1 = {};
              //         map1['name'] = detailUbah[i]['name'].toString();
              //         map1['productid'] =
              //             detailUbah![i]['productid'].toString();
              //         map1['quantity'] = detailUbah[i]['quantity'].toString();
              //         map1['image'] = detailUbah[i]['product_image'].toString();
              //         map1['amount'] = detailUbah[i]['amount'].toString();
              //         map1['description'] = 'berhasil';

              //         cartMap.add(map1);

              //         String name = detailUbah[i]['name'].toString().trim();
              //         String productid =
              //             detailUbah[i]['productid'].toString().trim();
              //         String image =
              //             detailUbah![i]['product_image'].toString().trim();
              //         int? price = detailUbah[i]['amount'];
              //         int quantity = detailUbah[i]['quantity'];
              //         String desc =
              //             detailUbah![i]['description'].toString().trim();

              //         sumTotal = sumTotal + price!.toInt();
              //         // subTotal =
              //         //     subTotal + price.toInt();
              //         total.add(price);

              //         cart.add(
              //           CartTransaksi(
              //             name: name,
              //             productid: productid,
              //             image: image,
              //             price: price,
              //             quantity: quantity,
              //             desc: desc,
              //             // desc: 'berhasil',
              //             // quantity:
              //             //     cart[i].quantity,
              //           ),
              //         );
              //       }

              //       if (cartMap.isNotEmpty) {
              //         // initState();
              //         widget.pageController.jumpToPage(0);
              //         setState(() {
              //           transactionidValue;
              //           subTotal;
              //           printext;
              //           transaksiNama;
              //           transaksiMetode;
              //           transaksiPesanan;
              //           transaksiKasir;
              //         });
              //       }

              //       transactionidValue == '' ? log("kosong") : log("ada");

              //       setState(() {});
              //     });
              //   },
              //   child: modalBottomValue(
              //     'Ubah Produk',
              //     PhosphorIcons.pencil_line,
              //   ),
              // ),
              // SizedBox(height: size12),
              GestureDetector(
                onTap: () {
                  refreshSelectedProvider.valueSelected = null;
                  hapusAlasan(context);
                },
                behavior: HitTestBehavior.translucent,
                child: modalBottomValue(
                  'Hapus Tagihan',
                  PhosphorIcons.trash,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  hapusAlasan(BuildContext context) {
    errorText = '';
    final refreshSelectedProvider =
        Provider.of<RefreshSelected>(context, listen: false);
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: headerTagihan(
            context,
            widget.token,
            transactionidValue,
            'hapus',
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return StatefulBuilder(builder: (context, setState) {
                transaksiReference = snapshot.data['transaksiid_reference'];
                return IntrinsicHeight(
                  child: Container(
                    // padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    decoration: BoxDecoration(
                      color: bnw100,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(size16),
                        topLeft: Radius.circular(size16),
                      ),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(size32, size16, size32, size32),
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

                                    // isItemAdded = false;

                                    total = [];
                                    subTotal = 0;
                                    sumTotal = 0;

                                    cartProductIds.clear();
                                    conCatatan.clear();
                                    // conCounterPreview.clear();
                                    // refreshTampilan();
                                    transactionidValue = "";

                                    // refreshColor();
                                    setState(() {});
                                  }
                                  refreshSelectedProvider.valueSelected = null;
                                },
                                child: Icon(PhosphorIcons.arrow_left,
                                    color: bnw900, size: 28),
                              ),
                              SizedBox(width: size16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Batalkan Tagihan',
                                    style: heading2(
                                        FontWeight.w700, bnw900, 'Outfit'),
                                  ),
                                  Text(
                                    'Pilih alasan yang sesuai',
                                    style: heading4(
                                        FontWeight.w400, bnw600, 'Outfit'),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Alasan Tidak Sesuai',
                                          style: heading3(FontWeight.w400,
                                              bnw900, 'Outfit'),
                                        ),
                                        Text(
                                          '*',
                                          style: heading3(FontWeight.w400,
                                              danger500, 'Outfit'),
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
                                                      transaksiReference = snapshot
                                                              .data[
                                                          'transaksiid_reference'];

                                                      value.refreshTampilan(
                                                          index);
                                                      print(
                                                          value.valueSelected);
                                                      idKategori = snapshot
                                                              .data['alasan']
                                                          [index]['idkategori'];
                                                    });
                                                  },
                                                  child: buttonL(
                                                    Center(
                                                        child: Text(
                                                      snapshot.data['alasan']
                                                              [index]
                                                          ['namakategori'],
                                                      style: heading4(
                                                        FontWeight.w400,
                                                        value.valueSelected ==
                                                                index
                                                            ? primary500
                                                            : bnw900,
                                                        'Outfit',
                                                      ),
                                                    )),
                                                    value.valueSelected == index
                                                        ? primary100
                                                        : bnw100,
                                                    value.valueSelected == index
                                                        ? primary500
                                                        : bnw300,
                                                  ));
                                            },
                                          ).toList(),
                                        ),
                                      );
                                    }),
                                    SizedBox(height: size16),
                                    Row(
                                      children: [
                                        Text(
                                          'Detail Alasan',
                                          style: heading4(FontWeight.w500,
                                              bnw900, 'Outfit'),
                                        ),
                                        Text(
                                          '*',
                                          style: heading4(FontWeight.w700,
                                              red500, 'Outfit'),
                                        ),
                                      ],
                                    ),
                                    IntrinsicHeight(
                                      child: TextFormField(
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        style: heading2(
                                            FontWeight.w600, bnw900, 'Outfit'),
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
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: size16),
                                          hintText:
                                              'Cth : Transakasi salah karena ada kesalahan penginputan.',
                                          hintStyle: heading2(FontWeight.w600,
                                              bnw400, 'Outfit'),
                                          errorText: errorText.isNotEmpty
                                              ? errorText
                                              : null,
                                          errorStyle: body1(FontWeight.w500,
                                              red500, 'Outfit'),
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
                                      width: MediaQuery.of(context).size.width,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            whenLoading(context);
                                            // print(
                                            //     '$transaksiReference $idKategori ${textController.text}');

                                            // print(snapshot
                                            //     .data['transaksiid_reference']);
                                            //cartProductIds.clear();
                                            width = null;
                                            widtValue = 120;
                                            heightInformation = 0;
                                            widthInformation = 0;

                                            //cart.clear();
                                            //cartMap.clear();

                                            deleteReference(
                                                    context,
                                                    widget.token,
                                                    snapshot.data[
                                                        'transaksiid_reference'],
                                                    idKategori,
                                                    textController.text,
                                                    transactionidValue)
                                                .then((value) {
                                              if (value != '00') {
                                                setState(() async {
                                                  datasRiwayat =
                                                      await getRiwayatTransaksi(
                                                    context,
                                                    widget.token,
                                                    '0',
                                                    '',
                                                    textvalueOrderBy,
                                                  );
                                                  Future.delayed(
                                                      Duration(seconds: 1));
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) {
                                                    scrollToTextField();
                                                    closeLoading(context);
                                                  });
                                                  initState();
                                                  setState(() {});
                                                });
                                              }
                                              closeLoading(context);
                                            });
                                            setState(() {});
                                            initState();
                                          });
                                        },
                                        child: buttonXL(
                                          Center(
                                            child: Text(
                                              'Batalkan Tagihan',
                                              style: heading3(FontWeight.w600,
                                                  bnw100, 'Outfit'),
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
              });
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
          Text(
            title,
            style: heading4(FontWeight.w500, bnw900, 'Outfit'),
          ),
          Text(
            subtitle,
            style: heading4(FontWeight.w500, bnw900, 'Outfit'),
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
