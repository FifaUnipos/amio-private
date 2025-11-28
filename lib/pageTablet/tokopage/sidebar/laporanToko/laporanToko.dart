import 'dart:convert';
import 'dart:developer';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/laporanToko/laporanMoveInvenPage.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/laporanToko/laporanPenggunaanProduk.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/laporanToko/pendapatanPembayaran.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/laporanToko/stokInventarisPage.dart';

import '../../../../utils/component/component_showModalBottom.dart';
import 'dart:io' as Io;
import 'dart:io';
import 'dart:typed_data';

import 'pendapatanHarian.dart';
import 'pendapatanPerProduk.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import '../../../../services/checkConnection.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import '../../../../utils/component/component_orderBy.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../utils/component/component_loading.dart';

import '../../../../utils/component/component_button.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../../../utils/component/component_color.dart';
import '../../../../../main.dart';
import '../../../../../models/tokoModel/singletokomodel.dart';
import '../../../../../models/tokomodel.dart';
import '../../../../../services/apimethod.dart';
import '../../../tokopage/sidebar/laporanToko/classLaporan.dart';
import 'pendapatanToko.dart';

class LaporanToko extends StatefulWidget {
  String token;
  LaporanToko({
    Key? key,
    required this.token,
    required this.controller,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  State<LaporanToko> createState() => _LaporanTokoState();
}

class _LaporanTokoState extends State<LaporanToko> {
  PageController pageController = PageController();
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
    // print(_textvalueOrderBy);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        pageController = PageController(
          initialPage: 0,
          keepPage: true,
          viewportFraction: 1,
        );
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
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

  @override
  Widget build(BuildContext context) {
    List<ObjectLaporan> objects = [
      ObjectLaporan('Pendapatan Harian', 'Laporan Pendapatan Harian Toko',
          PhosphorIcons.calendar_fill),
      if (statusProfile == 'Group_Merchant')
        ObjectLaporan('Pendapatan Toko', 'Laporan Pendapatan Keseluruhan Toko',
            PhosphorIcons.storefront_fill),
      ObjectLaporan('Pendapatan Per Produk', 'Laporan Pendapatan Per Produk',
          PhosphorIcons.shopping_bag_open_fill),
      ObjectLaporan(
          'Pendapatan Per Metode Pembayaran',
          'Laporan Pendapatan Per Metode Pembayaran',
          PhosphorIcons.credit_card_fill),
      ObjectLaporan('Stok Inventaris', 'Laporan Stok Inventaris',
          PhosphorIcons.clipboard_fill),
      ObjectLaporan('Pergerakan Inventaris', 'Laporan Pergerakan Inventaris',
          PhosphorIcons.swap_fill),
      // ObjectLaporan(
      //     'Penggunaan Bahan Produk',
      //     'Laporan Penggunaan Bahan Produk',
      //     PhosphorIcons.archive_box_fill),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (pageController.page!.round() == 0) {
          showModalBottomExit(context);
          return false;
        } else {
          pageController.jumpToPage(0);
          return Future.value(false);
        }
      },
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.all(size16),
          padding: EdgeInsets.all(size16),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.circular(size16),
          ),
          child: PageView(
            controller: pageController,
            scrollDirection: Axis.vertical,
            pageSnapping: true,
            reverse: false,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              print('index berganti ke $index');
            },
            children: [
              lihatLaporanPage(objects),
              LaporanPendapatanHarianPage(
                  pageController: pageController, token: widget.token),
              if (statusProfile == 'Group_Merchant')
                LaporanPendapatanTokoPage(
                    pageController: pageController, token: widget.token),
              LaporanPendapatanPerProduk(
                  pageController: pageController, token: widget.token),
              LaporanPembayaranPage(
                  pageController: pageController, token: widget.token),
              LaporanStokInventarisPage(
                  pageController: pageController, token: widget.token),
              LaporanPergerakanInventarisPage(
                  pageController: pageController, token: widget.token),
              LaporanPenggunaanProdukPage(
                  pageController: pageController, token: widget.token),
              // profitHarian(context),5
            ],
          ),
        ),
      ),
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
                pageController.jumpToPage(0);
              },
              child: Icon(
                PhosphorIcons.arrow_left,
                size: size40,
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
            orderBy(context),
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
            GestureDetector(
              child: buttonXLoutline(
                Center(
                  child: Icon(
                    PhosphorIcons.share_network_fill,
                    color: primary500,
                  ),
                ),
                size48,
                primary500,
              ),
            ),
          ],
        ),
        SizedBox(height: size24),
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
                width: width - 20,
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
                width: width + 10,
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
            padding: EdgeInsets.only(top: 10),
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
                                width: width - 20,
                                child: Text(
                                  detail[index]['tanggal'].toString(),
                                  style: heading4(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: width + 10,
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
                padding: EdgeInsets.only(top: 10, bottom: 10),
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
                          width: width - 20,
                          child: Text(
                            'Total Nilai',
                            style: heading4(FontWeight.w700, bnw900, 'Outfit'),
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
                        SizedBox(
                          width: width,
                          child: Text(
                            '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
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
                          width: width + 20,
                          child: Text(
                            'Total Keseluruhan',
                            style: heading4(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: Text(
                            FormatCurrency.convertToIdr(header['totalPPN'])
                                .toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: heading4(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: Text(
                            FormatCurrency.convertToIdr(header['totalPPN'])
                                .toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: heading4(FontWeight.w700, bnw900, 'Outfit'),
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
                                heading4(FontWeight.w400, succes600, 'Outfit'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return loading();
          },
        ),
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
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Laporan pendapatan dan profit toko',
                  style: heading3(FontWeight.w400, bnw900, 'Outfit'),
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
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: objects.length >= 6 ? 6 : objects.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 item per row
                    crossAxisSpacing: size16,
                    mainAxisSpacing: size16,
                    childAspectRatio: 3, // sesuaikan ukuran kotak
                  ),
                  itemBuilder: (context, i) {
                    final obj = objects[i];
                    return GestureDetector(
                      onTap: () {
                        pageController.jumpToPage(i + 1);
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.all(size16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(size16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(obj.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.visible,
                                          style: heading2(
                                              FontWeight.w700, bnw900, 'Outfit')),
                                      Text(obj.description,
                                          style: body1(
                                              FontWeight.w400, bnw800, 'Outfit')),
                                    ],
                                  ),
                                ),
                                Icon(obj.icon, color: bnw900, size: 36),
                              ],
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
                                      FontWeight.w600, primary500, 'Outfit'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        )
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
                                  'Rentang Waktu',
                                  style: heading2(
                                      FontWeight.w700, bnw900, 'Outfit'),
                                ),
                                Text(
                                  'Tentukan data yang akan tampil',
                                  style: heading4(
                                      FontWeight.w400, bnw600, 'Outfit'),
                                ),
                                SizedBox(height: size24),
                                Text(
                                  'Pilih Rentang Waktu',
                                  style: heading3(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                                Wrap(
                                  children: List<Widget>.generate(
                                    pilihUrutan.length,
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
                          SizedBox(height: size32),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                textOrderBy = pilihUrutan[_valueOrder];
                                _textvalueOrderBy =
                                    pendapatanHarianText[_valueOrder];
                                pendapatanHarianText[_valueOrder];

                                refresh();
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
        child: buttonXLoutline(
          Row(
            children: [
              SvgPicture.asset('assets/minimize.svg'),
              SizedBox(width: size12),
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
          double.infinity,
          bnw300,
        ),
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
              borderRadius: BorderRadius.circular(25),
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
                          padding: EdgeInsets.only(right: 15, top: 15),
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
                              SizedBox(height: size24),
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
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 0, 10),
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
              borderRadius: BorderRadius.circular(25),
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
                          padding: EdgeInsets.only(right: 15, top: 15),
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
                              SizedBox(height: size24),
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
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 0, 10),
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
              borderRadius: BorderRadius.circular(25),
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
                          padding: EdgeInsets.only(right: 15, top: 15),
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
                              SizedBox(height: size24),
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
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 0, 10),
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
