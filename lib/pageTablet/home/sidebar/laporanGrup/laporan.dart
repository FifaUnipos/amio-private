import 'dart:convert';
import 'dart:developer';import '../../../../utils/component/component_showModalBottom.dart';
import 'dart:io' as Io;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


import 'package:sidebarx/sidebarx.dart';
import '../../../../utils/component/component_loading.dart';
import '../../../../../main.dart';
import '../../../../../models/tokoModel/singletokomodel.dart';
import '../../../../../models/tokomodel.dart';
import '../../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../tokopage/sidebar/laporanToko/classLaporan.dart';
import '../../../tokopage/sidebar/laporanToko/pendapatanHarian.dart';import '../../../../utils/component/component_color.dart';
import '../../../tokopage/sidebar/laporanToko/pendapatanPerProduk.dart';
import '../../../tokopage/sidebar/laporanToko/pendapatanToko.dart';import '../../../../../utils/component/component_button.dart';

Color maainColor = Color(0xFF1363DF);

class LaporanGrup extends StatefulWidget {
  String token;
  LaporanGrup({
    Key? key,
    required this.token,
    required this.controller,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  State<LaporanGrup> createState() => _LaporanGrupState();
}

class _LaporanGrupState extends State<LaporanGrup> {
  PageController _pageController = PageController();
  TextEditingController hapusController = TextEditingController();
  bool _validate = false;

  List<ModelDataToko>? datas;

  String _textOrderBy = 'Tanggal Terkini',
      textOrderByToko = 'Toko Terbaru',
      textOrderByProduct = 'Product Terbaru',
      _textKeyword = '30 Hari Terakhir';
  String _textvalueOrderBy = 'tanggalTerkini', _textvalueKeyword = '1B';
  String textvalueOrderByToko = 'tokoTerbaru',
      textvalueOrderByProduct = 'productTerbaru';
  int _valueOrder = 0, _valueKeyword = 0;

  @override
  void initState() {
    checkConnection(context);
    print(_textvalueOrderBy);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    hapusController.dispose();
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  List pilihUrutan = [
    "Tanggal Terkini",
    "Tanggal Terlama",
    "Transaksi Tertinggi",
    "Transaksi Terendah",
    "PPN Tertinggi",
    "PPN Terendah",
    "Total Tertinggi",
    "Total Terendah"
  ];

  List pendapatanHarianText = [
    "tanggalTerkini",
    "tanggalTerlama",
    "transaksiTertinggi",
    "transaksiTerendah",
    "ppnTertinggi",
    "ppnTerendah",
    "totalTertinggi",
    "totalTerendah"
  ];

  List pilihUrutanToko = [
    "Toko Terbaru",
    "Toko Terlama",
    "Transaksi Terbanyak",
    "Transaksi Terendah",
    "Nilai Transaksi Tertinggi",
    "Nilai Transaksi Terendah",
    "PPN Tertinggi",
    "PPN Terendah",
    "Total PerToko Tertinggi",
    "Total PerToko Terendah",
  ];

  List pendapatanTokoText = [
    "tokoTerbaru",
    "tokoTerlama",
    "countTertinggi",
    "countTerendah",
    "transaksiTertinggi",
    "transaksiTerendah",
    "ppnTertinggi",
    "ppnTerendah",
    "totalTertinggi",
    "totalTerendah"
  ];

  List pilihUrutanProduct = [
    "Product Terbaru",
    "Product Terlama",
    "Transaksi Terbanyak",
    "Transaksi Terendah",
    "Nilai Transaksi Tertinggi",
    "Nilai Transaksi Terendah",
    "PPN Tertinggi",
    "PPN Terendah",
    "Total PerProduk Tertinggi",
    "Total PerProduk Terendah"
  ];

  List pendapatanProductText = [
    "productTerbaru",
    "productTerlama",
    "countTertinggi",
    "countTerendah",
    "transaksiTertinggi",
    "transaksiTerendah",
    "ppnTertinggi",
    "ppnTerendah",
    "totalTertinggi",
    "totalTerendah"
  ];

  Widget build(BuildContext context) {
    List<ObjectLaporan> objects = [
      ObjectLaporan('Pendapatan Harian', 'Laporan Pendapatan Harian Toko',
          PhosphorIcons.calendar_fill),
      ObjectLaporan('Pendapatan Toko', 'Laporan Pendapatan Keseluruhan Toko',
          PhosphorIcons.storefront_fill),
      ObjectLaporan('Pendapatan Per Produk', 'Laporan Pendapatan Per Produk',
          PhosphorIcons.shopping_bag_open_fill),
      // ObjectLaporan('Profit Harian', 'Laporan Profit Harian Toko',
      //     PhosphorIcons.chart_line),
      // ObjectLaporan(
      //     'Profit Toko', 'Laporan Profit Toko', PhosphorIcons.chart_line),
    ];

    return ScreenUtilInit(builder: (context, child) {
      return Container(
        margin: EdgeInsets.fromLTRB(size16, size48, size16, size16),
        padding: EdgeInsets.all(size16),
        decoration: BoxDecoration(
          color: bnw100,
          borderRadius: BorderRadius.circular(size16),
        ),
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          pageSnapping: true,
          reverse: false,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            print('$index');
          },
          children: [
            lihatLaporanPage(objects),
            LaporanPendapatanHarianPage(
                pageController: _pageController, token: widget.token),
            LaporanPendapatanTokoPage(
                pageController: _pageController, token: widget.token),
            LaporanPendapatanPerProduk(
                pageController: _pageController, token: widget.token),
            profitHarian(context),
            profitHarian(context),
          ],
        ),
      );
    });
  }

  pendapatanHarianToko(BuildContext context) {
    double width = 100;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                _pageController.jumpToPage(0);
              },
              child: Icon(
                PhosphorIcons.arrow_left,
                color: bnw900,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pendapatan Harian',
                  style: heading1(FontWeight.w700, Colors.black, 'Outfit'),
                ),
                Text(
                  'Laporan',
                  style: heading3(FontWeight.w400, Colors.black, 'Outfit'),
                ),
              ],
            ),
            orderBy(context, pilihUrutan, pendapatanHarianText, _textOrderBy),
            keyword(context),
            buttonXLoutline(
              Padding(
                padding: EdgeInsets.only(left: 6, right: size8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(PhosphorIcons.storefront, color: bnw900),
                    Text(
                      'Semua Toko',
                      style: heading3(
                        FontWeight.w600,
                        bnw900,
                        'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              MediaQuery.of(context).size.width / 6.4,
              bnw300,
            ),
            GestureDetector(
              onTap: () {
                showBottomPilihan(
                  context,
                  Column(
                    children: [Text('Bagikan Laporan')],
                  ),
                );
              },
              child: buttonXLoutline(
                Center(
                  child: Icon(
                    PhosphorIcons.share_network_fill,
                    color: primary500,
                  ),
                ),
                48,
                primary500,
              ),
            ),
          ],
        ),
        SizedBox(height: size16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: width + size16,
                child: Row(
                  children: [
                    Text(
                      'Tanggal',
                      style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: width + size16,
                child: Text(
                  'Jumlah Transaksi',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Nilai Transaksi',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Total PPN',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Total',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: size16),
            decoration: BoxDecoration(
              color: primary100,
            ),
            child: FutureBuilder(
              future: getLaporanDaily(context, widget.token, _textvalueOrderBy,
                  _textvalueKeyword, [''], ''),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic>? data = snapshot.data!['data'];
                  var detail = data!['detail'];
                  var header = data['header'];
                  // print(snapshot.data['data']);
                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: detail.length,
                    itemBuilder: (builder, index) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: width + size16,
                                child: Text(
                                  detail[index]['tanggal'].toString(),
                                  style: heading4(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width + size16,
                                child: Text(
                                  detail[index]['totalTransaksi'].toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['nilaiTransaksi'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['totalPPN'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['total'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                            ],
                          ),
                          Divider(thickness: 1.2)
                        ],
                      );
                    },
                    // itemCount: staticData!.length,
                  );
                }
                return loading();
              },
            ),
          ),
        ),
        FutureBuilder(
            future: getLaporanDaily(context, widget.token, _textvalueOrderBy,
                _textvalueKeyword, [''], ''),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? data = snapshot.data!['data'];

                var header = data!['header'];
                return Container(
                  padding: EdgeInsets.only(top: size16, bottom: size16),
                  decoration: BoxDecoration(
                    color: primary200,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(size12),
                      bottomRight: Radius.circular(size12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: width + size16,
                        child: Text(
                          'Total',
                          style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: width + size16,
                        child: Text(
                          header['count'].toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: Text(
                          FormatCurrency.convertToIdr(header['nilaiTransaksi'])
                              .toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: Text(
                          FormatCurrency.convertToIdr(header['totalPPN'])
                              .toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: Text(
                          FormatCurrency.convertToIdr(header['total'])
                              .toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return loading();
            }),
      ],
    );
  }

  pendapatanToko(BuildContext context) {
    double width = 100;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                _pageController.jumpToPage(0);
              },
              child: Icon(
                PhosphorIcons.arrow_left,
                color: bnw900,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pendapatan Toko',
                  style: heading1(FontWeight.w700, Colors.black, 'Outfit'),
                ),
                Text(
                  'Laporan',
                  style: heading3(FontWeight.w400, Colors.black, 'Outfit'),
                ),
              ],
            ),
            orderByToko(
                context, pilihUrutanToko, pendapatanTokoText, textOrderByToko),
            keyword(context),
            buttonXLoutline(
              Padding(
                padding: EdgeInsets.only(left: 6, right: size8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(PhosphorIcons.storefront, color: bnw900),
                    Text(
                      'Semua Toko',
                      style: heading3(
                        FontWeight.w600,
                        bnw900,
                        'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              MediaQuery.of(context).size.width / 6.4,
              bnw300,
            ),
            buttonXLoutline(
              Center(
                child: Icon(
                  PhosphorIcons.share_network_fill,
                  color: primary500,
                ),
              ),
              48,
              primary500,
            ),
          ],
        ),
        SizedBox(height: size16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: width + size16,
                child: Row(
                  children: [
                    Text(
                      'Toko',
                      style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: width + size16,
                child: Text(
                  'Jumlah Transaksi',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Nilai Transaksi',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Total PPN',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Total Per Toko',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: size16),
            decoration: BoxDecoration(
              color: primary100,
            ),
            child: FutureBuilder(
              future: getLaporanMerchant(
                context,
                widget.token,
                _textvalueKeyword,
                textvalueOrderByToko,
                [''],
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic>? data = snapshot.data!['data'];
                  var detail = data!['detail'];
                  var header = data['header'];
                  // print(snapshot.data['data']);
                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: detail.length,
                    itemBuilder: (builder, index) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: width + size16,
                                child: Text(
                                  detail[index]['namerToko'].toString(),
                                  style: heading4(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width + size16,
                                child: Text(
                                  detail[index]['totalTransaksi'].toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['nilaiTransaksi'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['totalPPN'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['total'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                            ],
                          ),
                          Divider(thickness: 1.2)
                        ],
                      );
                    },
                    // itemCount: staticData!.length,
                  );
                }
                return loading();
              },
            ),
          ),
        ),
        FutureBuilder(
            future: getLaporanDaily(context, widget.token, _textvalueOrderBy,
                _textvalueKeyword, [''], ''),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? data = snapshot.data!['data'];

                var header = data!['header'];
                return Container(
                  padding: EdgeInsets.only(top: size16, bottom: size16),
                  decoration: BoxDecoration(
                    color: primary200,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(size12),
                      bottomRight: Radius.circular(size12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: width + size16,
                        child: Text(
                          'Total',
                          style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: width + size16,
                        child: Text(
                          header['count'].toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: Text(
                          FormatCurrency.convertToIdr(header['nilaiTransaksi'])
                              .toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: Text(
                          FormatCurrency.convertToIdr(header['totalPPN'])
                              .toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: Text(
                          FormatCurrency.convertToIdr(header['total'])
                              .toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return loading();
            }),
      ],
    );
  }

  pendapatanPerProduk(BuildContext context) {
    double width = 100;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                _pageController.jumpToPage(0);
              },
              child: Icon(
                PhosphorIcons.arrow_left,
                color: bnw900,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pendapatan Per Produk',
                  style: heading1(FontWeight.w700, Colors.black, 'Outfit'),
                ),
                Text(
                  'Laporan',
                  style: heading3(FontWeight.w400, Colors.black, 'Outfit'),
                ),
              ],
            ),
            orderByProduct(
              context,
              pilihUrutanProduct,
              pendapatanProductText,
              textOrderByProduct,
            ),
            keyword(context),
            buttonXLoutline(
              Padding(
                padding: EdgeInsets.only(left: 6, right: size8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(PhosphorIcons.storefront, color: bnw900),
                    Text(
                      'Semua Toko',
                      style: heading3(
                        FontWeight.w600,
                        bnw900,
                        'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              MediaQuery.of(context).size.width / 6.4,
              bnw300,
            ),
            buttonXLoutline(
              Center(
                child: Icon(
                  PhosphorIcons.share_network_fill,
                  color: primary500,
                ),
              ),
              48,
              primary500,
            ),
          ],
        ),
        SizedBox(height: size16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: width + size16,
                child: Row(
                  children: [
                    Text(
                      'Produk',
                      style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: width + size16,
                child: Text(
                  'Jumlah Transaksi',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Nilai Transaksi',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Total PPN',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Total Per Toko',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: size16),
            decoration: BoxDecoration(
              color: primary100,
            ),
            child: FutureBuilder(
              future: getLaporanPerProduk(
                context,
                widget.token,
                _textvalueKeyword,
                textvalueOrderByProduct,
                [''],
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic>? data = snapshot.data!['data'];
                  var detail = data!['detail'];
                  var header = data['header'];
                  // print(snapshot.data['data']);
                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: detail.length,
                    itemBuilder: (builder, index) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: width + size16,
                                child: Text(
                                  detail[index]['nameProduk'].toString(),
                                  style: heading4(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width + size16,
                                child: Text(
                                  detail[index]['totalTransaksi'].toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['nilaiTransaksi'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['totalPPN'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['total'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                            ],
                          ),
                          Divider(thickness: 1.2)
                        ],
                      );
                    },
                    // itemCount: staticData!.length,
                  );
                }
                return loading();
              },
            ),
          ),
        ),
        FutureBuilder(
            future: getLaporanDaily(context, widget.token, _textvalueOrderBy,
                _textvalueKeyword, [''], ''),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? data = snapshot.data!['data'];

                var header = data!['header'];
                return Container(
                  padding: EdgeInsets.only(top: size16, bottom: size16),
                  decoration: BoxDecoration(
                    color: primary200,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(size12),
                      bottomRight: Radius.circular(size12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: width + size16,
                        child: Text(
                          'Total Keseluruhan',
                          style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: width + size16,
                        child: Text(
                          header['count'].toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: Text(
                          FormatCurrency.convertToIdr(header['nilaiTransaksi'])
                              .toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: Text(
                          FormatCurrency.convertToIdr(header['totalPPN'])
                              .toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: Text(
                          FormatCurrency.convertToIdr(header['total'])
                              .toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return loading();
            }),
      ],
    );
  }

  profitHarian(BuildContext context) {
    double width = 100;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                _pageController.jumpToPage(0);
              },
              child: Icon(
                PhosphorIcons.arrow_left,
                color: bnw900,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profit Harian',
                  style: heading1(FontWeight.w700, Colors.black, 'Outfit'),
                ),
                Text(
                  'Laporan',
                  style: heading3(FontWeight.w400, Colors.black, 'Outfit'),
                ),
              ],
            ),
            orderBy(context, pilihUrutan, pendapatanHarianText, _textOrderBy),
            buttonXLoutline(
              Padding(
                padding: EdgeInsets.only(left: 6, right: size8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(PhosphorIcons.calendar, color: bnw900),
                    Text(
                      '30 Hari Terakhir',
                      style: heading3(
                        FontWeight.w600,
                        bnw900,
                        'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              MediaQuery.of(context).size.width / 6,
              bnw300,
            ),
            buttonXLoutline(
              Padding(
                padding: EdgeInsets.only(left: 6, right: size8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(PhosphorIcons.storefront, color: bnw900),
                    Text(
                      'Semua Toko',
                      style: heading3(
                        FontWeight.w600,
                        bnw900,
                        'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              MediaQuery.of(context).size.width / 6.4,
              bnw300,
            ),
            buttonXLoutline(
              Center(
                child: Icon(
                  PhosphorIcons.share_network_fill,
                  color: primary500,
                ),
              ),
              48,
              primary500,
            ),
          ],
        ),
        SizedBox(height: size16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: width - size16,
                child: Row(
                  children: [
                    Text(
                      'Tanggal',
                      style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: width + size16,
                child: Text(
                  'Penjualan + PPN',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Pendapatan Lain-lain',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Pengeluaran Inventory',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Pengeluaran Lain-lain',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: width,
                child: Text(
                  'Profit/Loss',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: size16),
            decoration: BoxDecoration(
              color: primary100,
            ),
            child: FutureBuilder(
              future: getLaporanDaily(context, widget.token, _textvalueOrderBy,
                  _textvalueKeyword, [''], ''),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic>? data = snapshot.data!['data'];
                  var detail = data!['detail'];
                  var header = data['header'];
                  // print(snapshot.data['data']);
                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: detail.length,
                    itemBuilder: (builder, index) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: width - size16,
                                child: Text(
                                  detail[index]['tanggal'].toString(),
                                  style: heading4(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width + size16,
                                child: Text(
                                  detail[index]['totalTransaksi'].toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['nilaiTransaksi'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['totalPPN'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['total'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Text(
                                  FormatCurrency.convertToIdr(
                                          detail[index]['total'])
                                      .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                            ],
                          ),
                          Divider(thickness: 1.2)
                        ],
                      );
                    },
                    // itemCount: staticData!.length,
                  );
                }
                return loading();
              },
            ),
          ),
        ),
        FutureBuilder(
            future: getLaporanDaily(context, widget.token, _textvalueOrderBy,
                _textvalueKeyword, [''], ''),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? data = snapshot.data!['data'];

                var header = data!['header'];
                return Container(
                  padding: EdgeInsets.only(top: size16, bottom: size16),
                  decoration: BoxDecoration(
                    color: primary200,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(size12),
                      bottomRight: Radius.circular(size12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: width - size16,
                            child: Text(
                              'Total Nilai',
                              style:
                                  heading4(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: Text(
                              FormatCurrency.convertToIdr(header['totalPPN'])
                                  .toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  heading4(FontWeight.w400, bnw900, 'Outfit'),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: Text(
                              FormatCurrency.convertToIdr(header['totalPPN'])
                                  .toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  heading4(FontWeight.w400, bnw900, 'Outfit'),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: Text(
                              FormatCurrency.convertToIdr(header['totalPPN'])
                                  .toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  heading4(FontWeight.w400, bnw900, 'Outfit'),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: Text(
                              FormatCurrency.convertToIdr(header['total'])
                                  .toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  heading4(FontWeight.w400, bnw900, 'Outfit'),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: Text(
                              '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  heading4(FontWeight.w400, bnw900, 'Outfit'),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 0.6,
                        color: bnw900,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: width + size16,
                            child: Text(
                              'Total Keseluruhan',
                              style:
                                  heading4(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: Text(
                              FormatCurrency.convertToIdr(header['totalPPN'])
                                  .toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  heading4(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: Text(
                              FormatCurrency.convertToIdr(header['totalPPN'])
                                  .toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  heading4(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: Text(
                              FormatCurrency.convertToIdr(header['total'])
                                  .toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: heading4(
                                  FontWeight.w400, succes600, 'Outfit'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              return loading();
            }),
      ],
    );
  }

  lihatLaporanPage(List<ObjectLaporan> objects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laporan',
                  style: heading1(FontWeight.w700, Colors.black, 'Outfit'),
                ),
                Text(
                  'Laporan pendapatan dan profit toko',
                  style: heading3(FontWeight.w400, Colors.black, 'Outfit'),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GridView.count(
                  physics: BouncingScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3.275,
                  crossAxisSpacing: size16,
                  mainAxisSpacing: size16,
                  shrinkWrap: true,
                  children: List.generate(
                    objects.length,
                    (i) => GestureDetector(
                      onTap: () {
                        print(i);
                        // widget.controller.toggleExtendedTrue();
                        // showingMenuSidebar = false;
                        _pageController.jumpToPage(i + 1);
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.all(size16),
                        margin: EdgeInsets.only(right: size8, bottom: size8),
                        height: 180,
                        width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(size16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(objects[i].title,
                                          style: heading2(FontWeight.w700,
                                              bnw900, 'Outfit')),
                                      Text(objects[i].description,
                                          style: body1(FontWeight.w400, bnw800,
                                              'Outfit')),
                                    ],
                                  ),
                                  Icon(
                                    objects[i].icon,
                                    color: bnw900,
                                    size: 36,
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Container(
                              height: 40,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: bnw100,
                                border: Border.all(color: primary500),
                                borderRadius: BorderRadius.circular(size8),
                              ),
                              child: Center(
                                child: Text(
                                  'Lihat Laporan',
                                  style: heading4(
                                    FontWeight.w600,
                                    primary500,
                                    'Outfit',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  orderBy(
      BuildContext context, pilihUrutan, pendapatanHarianText, textOrderBy) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showModalBottomSheet(
      constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size24),
            ),
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) => Container(
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                    color: bnw100,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size12),
                      topLeft: Radius.circular(size12),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: size12, right: size12),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(right: size16, top: size16),
                          color: bnw100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Urutkan',
                                style:
                                    heading2(FontWeight.w700, bnw900, 'Outfit'),
                              ),
                              Text(
                                'Tentukan data yang akan tampil',
                                style:
                                    heading4(FontWeight.w400, bnw600, 'Outfit'),
                              ),
                              SizedBox(height: size16),
                              Text(
                                'Pilih Urutan',
                                style:
                                    heading3(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                              Wrap(
                                children: List<Widget>.generate(
                                  pilihUrutan.length,
                                  (int index) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: size8),
                                      child: ChoiceChip(
                                        padding: EdgeInsets.fromLTRB(
                                            0, size16, 0, size16),
                                        backgroundColor: bnw100,
                                        selectedColor: primary200,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: _valueOrder == index
                                                ? primary500
                                                : bnw300,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(size8),
                                        ),
                                        label: Text(pilihUrutan[index],
                                            style: heading4(
                                                FontWeight.w400,
                                                _valueOrder == index
                                                    ? primary500
                                                    : bnw900,
                                                'Outfit')),
                                        selected: _valueOrder == index,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            print(index);
                                            // _value =
                                            //     selected ? index : null;
                                            _valueOrder = index;
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
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            // print(_valueOrder);
                            // print(pilihUrutan[_valueOrder]);

                            textOrderByProduct = pilihUrutan[_valueOrder];
                            _textvalueOrderBy = pilihUrutan[_valueOrder];
                            pendapatanHarianText[_valueOrder];
                            textvalueOrderByToko =
                                pendapatanHarianText[_valueOrder];

                            // print(_textvalueOrderBy);
                            refresh();
                            Navigator.pop(context);
                            // initState();
                          },
                          child: buttonXL(
                            Center(
                              child: Text(
                                'Tampilkan',
                                style:
                                    heading3(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ),
                            double.infinity,
                          ),
                        ),
                        SizedBox(height: size8)
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
      },
      child: buttonXLExpanded(
        Padding(
          padding: EdgeInsets.only(left: 6, right: size8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SvgPicture.asset('assets/minimize.svg'),
              SizedBox(width: 4),
              Text(
                textOrderBy,
                style: heading3(
                  FontWeight.w600,
                  bnw900,
                  'Outfit',
                ),
              ),
            ],
          ),
        ),
        bnw300,
      ),
    );
  }

  orderByToko(
      BuildContext context, pilihUrutan, pendapatanHarianText, textOrderBy) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showModalBottomSheet(
      constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size24),
            ),
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) => Container(
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                    color: bnw100,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size12),
                      topLeft: Radius.circular(size12),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: size12, right: size12),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(right: size16, top: size16),
                          color: bnw100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Urutkan',
                                style:
                                    heading2(FontWeight.w700, bnw900, 'Outfit'),
                              ),
                              Text(
                                'Tentukan data yang akan tampil',
                                style:
                                    heading4(FontWeight.w400, bnw600, 'Outfit'),
                              ),
                              SizedBox(height: size16),
                              Text(
                                'Pilih Urutan',
                                style:
                                    heading3(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                              Wrap(
                                children: List<Widget>.generate(
                                  pilihUrutan.length,
                                  (int index) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: size8),
                                      child: ChoiceChip(
                                        padding: EdgeInsets.fromLTRB(
                                            0, size16, 0, size16),
                                        backgroundColor: bnw100,
                                        selectedColor: primary200,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: _valueOrder == index
                                                ? primary500
                                                : bnw300,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(size8),
                                        ),
                                        label: Text(pilihUrutan[index],
                                            style: heading4(
                                                FontWeight.w400,
                                                _valueOrder == index
                                                    ? primary500
                                                    : bnw900,
                                                'Outfit')),
                                        selected: _valueOrder == index,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            print(index);
                                            // _value =
                                            //     selected ? index : null;
                                            _valueOrder = index;
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
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            // print(_valueOrder);
                            // print(pilihUrutan[_valueOrder]);

                            pendapatanHarianText[_valueOrder];
                            textvalueOrderByToko =
                                pendapatanHarianText[_valueOrder];

                            // print(_textvalueOrderBy);
                            refresh();
                            Navigator.pop(context);
                            // initState();
                          },
                          child: buttonXL(
                            Center(
                              child: Text(
                                'Tampilkan',
                                style:
                                    heading3(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ),
                            double.infinity,
                          ),
                        ),
                        SizedBox(height: size8)
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
      },
      child: buttonXLExpanded(
        Padding(
          padding: EdgeInsets.only(left: 6, right: size8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SvgPicture.asset('assets/minimize.svg'),
              SizedBox(width: 4),
              Text(
                textOrderBy,
                style: heading3(
                  FontWeight.w600,
                  bnw900,
                  'Outfit',
                ),
              ),
            ],
          ),
        ),
        bnw300,
      ),
    );
  }

  orderByProduct(
      BuildContext context, pilihUrutan, pendapatanHarianText, textOrderBy) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showModalBottomSheet(
      constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size24),
            ),
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) => Container(
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                    color: bnw100,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size12),
                      topLeft: Radius.circular(size12),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: size12, right: size12),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(right: size16, top: size16),
                          color: bnw100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Urutkan',
                                style:
                                    heading2(FontWeight.w700, bnw900, 'Outfit'),
                              ),
                              Text(
                                'Tentukan data yang akan tampil',
                                style:
                                    heading4(FontWeight.w400, bnw600, 'Outfit'),
                              ),
                              SizedBox(height: size16),
                              Text(
                                'Pilih Urutan',
                                style:
                                    heading3(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                              Wrap(
                                children: List<Widget>.generate(
                                  pilihUrutan.length,
                                  (int index) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: size8),
                                      child: ChoiceChip(
                                        padding: EdgeInsets.fromLTRB(
                                            0, size16, 0, size16),
                                        backgroundColor: bnw100,
                                        selectedColor: primary200,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: _valueOrder == index
                                                ? primary500
                                                : bnw300,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(size8),
                                        ),
                                        label: Text(pilihUrutan[index],
                                            style: heading4(
                                                FontWeight.w400,
                                                _valueOrder == index
                                                    ? primary500
                                                    : bnw900,
                                                'Outfit')),
                                        selected: _valueOrder == index,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            print(index);
                                            // _value =
                                            //     selected ? index : null;
                                            _valueOrder = index;
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
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            // print(_valueOrder);
                            // print(pilihUrutan[_valueOrder]);

                            textOrderByProduct =
                                pendapatanHarianText[_valueOrder];
                            textvalueOrderByProduct =
                                pendapatanHarianText[_valueOrder];

                            // print(_textvalueOrderBy);
                            refresh();
                            Navigator.pop(context);
                            // initState();
                          },
                          child: buttonXL(
                            Center(
                              child: Text(
                                'Tampilkan',
                                style:
                                    heading3(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ),
                            double.infinity,
                          ),
                        ),
                        SizedBox(height: size8)
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
      },
      child: buttonXLExpanded(
        Padding(
          padding: EdgeInsets.only(left: 6, right: size8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SvgPicture.asset('assets/minimize.svg'),
              SizedBox(width: 4),
              Text(
                textOrderByProduct,
                style: heading3(
                  FontWeight.w600,
                  bnw900,
                  'Outfit',
                ),
              ),
            ],
          ),
        ),
        bnw300,
      ),
    );
  }

  keyword(BuildContext context) {
    return GestureDetector(
      onTap: () {
        List pilihUrutan = [
          '30 Hari Terakhir',
          '3 Bulan Terakhir',
          '6 Bulan Terakhir',
          '1 Tahun Terakhir',
        ];
        List textvalueKeyword = [
          '1B',
          '3B',
          '6B',
          '1Y',
        ];

        setState(() {
          showModalBottomSheet(
      constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size24),
            ),
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) => Container(
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                    color: bnw100,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size12),
                      topLeft: Radius.circular(size12),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: size12, right: size12),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(right: size16, top: size16),
                          color: bnw100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pilih Tanggal',
                                style:
                                    heading2(FontWeight.w700, bnw900, 'Outfit'),
                              ),
                              Text(
                                'Tentukan data yang akan tampil',
                                style:
                                    heading4(FontWeight.w400, bnw600, 'Outfit'),
                              ),
                              SizedBox(height: size16),
                              Text(
                                'Pilih Urutan',
                                style:
                                    heading3(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                              Wrap(
                                children: List<Widget>.generate(
                                  pilihUrutan.length,
                                  (int index) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: size8),
                                      child: ChoiceChip(
                                        padding: EdgeInsets.fromLTRB(
                                            0, size16, 0, size16),
                                        backgroundColor: bnw100,
                                        selectedColor: primary200,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: _valueKeyword == index
                                                ? primary500
                                                : bnw300,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(size8),
                                        ),
                                        label: Text(pilihUrutan[index],
                                            style: heading4(
                                                FontWeight.w400,
                                                _valueKeyword == index
                                                    ? primary500
                                                    : bnw900,
                                                'Outfit')),
                                        selected: _valueKeyword == index,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            print(index);
                                            // _value =
                                            //     selected ? index : null;
                                            _valueKeyword = index;
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
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            // print(_valueKeyword);
                            // print(pilihUrutan[_valueKeyword]);
                            _textKeyword = pilihUrutan[_valueKeyword];
                            _textvalueKeyword = textvalueKeyword[_valueKeyword];
                            refresh();
                            Navigator.pop(context);
                          },
                          child: buttonXL(
                            Center(
                              child: Text(
                                'Tampilkan',
                                style:
                                    heading3(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ),
                            double.infinity,
                          ),
                        ),
                        SizedBox(height: size8)
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
      },
      child: buttonXLExpanded(
        Padding(
          padding: EdgeInsets.only(left: 6, right: size8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(PhosphorIcons.calendar),
              SizedBox(width: 4),
              Text(
                _textKeyword,
                style: heading3(
                  FontWeight.w600,
                  bnw900,
                  'Outfit',
                ),
              ),
            ],
          ),
        ),
        bnw300,
      ),
    );
  }
}
