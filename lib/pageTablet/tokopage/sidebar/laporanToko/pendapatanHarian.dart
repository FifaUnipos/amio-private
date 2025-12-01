import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../utils/component/component_showModalBottom.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletons/skeletons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import '../../../../models/tokomodel.dart';
import '../../../../services/apimethod.dart';
import '../../../../utils/component/component_color.dart';
import '../../../../utils/component/component_loading.dart';

class LaporanPendapatanHarianPage extends StatefulWidget {
  String token;
  PageController pageController = PageController();
  LaporanPendapatanHarianPage({
    Key? key,
    required this.token,
    required this.pageController,
  }) : super(key: key);

  @override
  State<LaporanPendapatanHarianPage> createState() =>
      LaporanPendapatanHarianPageState();
}

class LaporanPendapatanHarianPageState
    extends State<LaporanPendapatanHarianPage> {
  List pilihUrutan = [
    "Tanggal Terkini",
    "Tanggal Terlama",
    "Transaksi Tertinggi",
    "Transaksi Terendah",
    "PPN Tertinggi",
    "PPN Terendah",
    "Total Tertinggi",
    "Total Terendah",
  ];

  List pendapatanText = [
    "tanggalTerkini",
    "tanggalTerlama",
    "transaksiTertinggi",
    "transaksiTerendah",
    "ppnTertinggi",
    "ppnTerendah",
    "totalTertinggi",
    "totalTerendah",
  ];

  String textOrderBy = 'Tanggal Terkini', textKeyword = '30 Hari Terakhir';
  String _textvalueOrderBy = 'tanggalTerkini',
      _textvalueKeyword = '1B',
      _textKeyword = '30 Hari Terakhir';

  String tanggalSelect = '';

  int _valueOrder = 0, _valueKeyword = 0;

  GlobalKey _globalKey = GlobalKey();

  bool isTokoSelected = false;
  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};
  List<String> listToko = List.empty(growable: true);

  double _leftWidthFactor = 1.0;
  bool _isSecondContainerVisible = false;

  double heightInformation = 0;
  double widthInformation = 0;

  int? _selectedIndex;

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = 100;
    return RepaintBoundary(
      key: _globalKey,
      child: Column(
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.pageController.jumpToPage(0);
                    },
                    child: Icon(
                      PhosphorIcons.arrow_left,
                      size: size40,
                      color: bnw900,
                    ),
                  ),
                  SizedBox(width: size8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pendapatan Harian',
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        'Laporan',
                        style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                ],
              ),
              // Spacer(),
              SizedBox(width: size16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      orderBy(context),
                      SizedBox(width: size16),
                      keyword(context),
                      SizedBox(width: size16),
                      sortToko(context),
                      SizedBox(width: size16),

                      // Tombol share
                      GestureDetector(
                        onTap: () {
                          showBottomPilihan(
                            context,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Bagikan Laporan',
                                        style: heading1(
                                          FontWeight.w600,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      Text(
                                        'Pilih format berbagi laporan',
                                        style: heading2(
                                          FontWeight.w400,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: size20),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2.6,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            _selectedIndex == null
                                                ? getLaporanDailyExport(
                                                    context,
                                                    widget.token,
                                                    _textvalueOrderBy,
                                                    _textvalueKeyword,
                                                    listToko,
                                                    'pdf',
                                                  ).then((value) {
                                                    try {
                                                      launch(value['data']);
                                                      downloadFile(
                                                        value['data'],
                                                      );
                                                    } catch (_) {}
                                                  })
                                                : getSinglePendapatanHarian(
                                                    widget.token,
                                                    tanggalSelect,
                                                    "totalTertinggi",
                                                    "pdf",
                                                    listToko,
                                                  ).then((value) {
                                                    try {
                                                      launch(value['data']);
                                                      downloadFile(
                                                        value['data'],
                                                      );
                                                    } catch (_) {}
                                                  });
                                          },
                                          child: buttonXXLoutline(
                                            Column(
                                              children: [
                                                Icon(
                                                  PhosphorIcons.file_text_fill,
                                                  color: primary500,
                                                ),
                                                Text(
                                                  'Pdf',
                                                  style: heading2(
                                                    FontWeight.w600,
                                                    primary500,
                                                    'Outfit',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            110,
                                            primary500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            _selectedIndex == null
                                                ? getLaporanDailyExport(
                                                    context,
                                                    widget.token,
                                                    _textvalueOrderBy,
                                                    _textvalueKeyword,
                                                    listToko,
                                                    'excel',
                                                  ).then((value) {
                                                    try {
                                                      launch(value['data']);
                                                      downloadFile(
                                                        value['data'],
                                                      );
                                                    } catch (_) {}
                                                  })
                                                : getSinglePendapatanHarian(
                                                    widget.token,
                                                    tanggalSelect,
                                                    "totalTertinggi",
                                                    "excel",
                                                    listToko,
                                                  ).then((value) {
                                                    try {
                                                      launch(value['data']);
                                                      downloadFile(
                                                        value['data'],
                                                      );
                                                    } catch (_) {}
                                                  });
                                          },
                                          child: buttonXXLoutline(
                                            Column(
                                              children: [
                                                Icon(
                                                  PhosphorIcons
                                                      .microsoft_excel_logo_fill,
                                                  color: primary500,
                                                ),
                                                Text(
                                                  'Excel',
                                                  style: heading2(
                                                    FontWeight.w600,
                                                    primary500,
                                                    'Outfit',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            120,
                                            primary500,
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
                        child: buttonXLoutline(
                          Center(
                            child: Icon(
                              PhosphorIcons.share_network_fill,
                              color: primary500,
                            ),
                          ),
                          0,
                          primary500,
                        ),
                      ),

                      SizedBox(
                        width: size16,
                      ), // padding ujung kanan biar enak scroll
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Row(
                      children: [
                        Flexible(
                          flex: (_leftWidthFactor * 100).toInt(),
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
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      child: SizedBox(
                                        width: width + size20,
                                        child: Row(
                                          children: [
                                            Text(
                                              'Tanggal',
                                              style: heading4(
                                                FontWeight.w700,
                                                bnw100,
                                                'Outfit',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: SizedBox(
                                        width: width + 10,
                                        child: Text(
                                          'Jumlah Transaksi',
                                          style: heading4(
                                            FontWeight.w600,
                                            bnw100,
                                            'Outfit',
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: SizedBox(
                                        width: width,
                                        child: Text(
                                          'Nilai Transaksi',
                                          style: heading4(
                                            FontWeight.w600,
                                            bnw100,
                                            'Outfit',
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: SizedBox(
                                        width: width,
                                        child: Text(
                                          'Total PPN',
                                          style: heading4(
                                            FontWeight.w600,
                                            bnw100,
                                            'Outfit',
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: SizedBox(
                                        width: width,
                                        child: Text(
                                          'Total',
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
                              Expanded(
                                child: FutureBuilder(
                                  future: getLaporanDaily(
                                    context,
                                    widget.token,
                                    _textvalueOrderBy,
                                    _textvalueKeyword,
                                    listToko,
                                    '',
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      Map<String, dynamic>? data =
                                          snapshot.data!['data'];
                                      var detail = data!['detail'];
                                      var header = data['header'];
                                      // print(snapshot.data['data']);
                                      return RefreshIndicator(
                                        color: bnw100,
                                        onRefresh: () async {
                                          getLaporanDaily(
                                            context,
                                            widget.token,
                                            _textvalueOrderBy,
                                            _textvalueKeyword,
                                            listToko,
                                            '',
                                          );
                                          setState(() {});
                                        },
                                        child: ListView.builder(
                                          // physics: BouncingScrollPhysics(),
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          itemCount: detail.length,
                                          itemBuilder: (builder, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  tanggalSelect =
                                                      detail[index]['tanggal'];
                                                  widthInformation =
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width;
                                                  heightInformation =
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height;

                                                  _isSecondContainerVisible =
                                                      true;
                                                  _leftWidthFactor = 0.5;

                                                  _selectedIndex = index;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: size12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _selectedIndex == index
                                                      ? primary200
                                                      : Colors.transparent,
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: bnw300,
                                                      width: 1.2,
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Flexible(
                                                      child: SizedBox(
                                                        width: width + size20,
                                                        child: Text(
                                                          detail[index]['tanggal']
                                                              .toString(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: heading4(
                                                            FontWeight.w600,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: SizedBox(
                                                        width: width + 10,
                                                        child: Text(
                                                          detail[index]['totalTransaksi']
                                                              .toString(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: heading4(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: SizedBox(
                                                        width: width,
                                                        child: Text(
                                                          FormatCurrency.convertToIdr(
                                                            detail[index]['nilaiTransaksi'],
                                                          ).toString(),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: heading4(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: SizedBox(
                                                        width: width,
                                                        child: Text(
                                                          FormatCurrency.convertToIdr(
                                                            detail[index]['totalPPN'],
                                                          ).toString(),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: heading4(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: SizedBox(
                                                        width: width,
                                                        child: Text(
                                                          FormatCurrency.convertToIdr(
                                                            detail[index]['total'],
                                                          ).toString(),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: heading4(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          // itemCount: staticData!.length,
                                        ),
                                      );
                                    }
                                    return SkeletonListView(
                                      padding: EdgeInsets.only(
                                        left: size16,
                                        right: size16,
                                      ),
                                      itemCount: 5,
                                      itemBuilder: (p0, p1) => SkeletonLine(
                                        style: SkeletonLineStyle(
                                          height: 40,
                                          padding: EdgeInsets.only(
                                            bottom: size16,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              FutureBuilder(
                                future: getLaporanDaily(
                                  context,
                                  widget.token,
                                  _textvalueOrderBy,
                                  _textvalueKeyword,
                                  listToko,
                                  '',
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    Map<String, dynamic>? data =
                                        snapshot.data!['data'];

                                    var header = data!['header'];
                                    return Container(
                                      padding: EdgeInsets.only(
                                        top: size16,
                                        bottom: size16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primary200,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(size16),
                                          bottomRight: Radius.circular(size16),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Flexible(
                                            child: SizedBox(
                                              width: width + size20,
                                              child: Text(
                                                'Total',
                                                style: heading4(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: SizedBox(
                                              width: width + 10,
                                              child: Text(
                                                header['count'].toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: heading4(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: SizedBox(
                                              width: width,
                                              child: Text(
                                                FormatCurrency.convertToIdr(
                                                  header['nilaiTransaksi'],
                                                ).toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: heading4(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: SizedBox(
                                              width: width,
                                              child: Text(
                                                FormatCurrency.convertToIdr(
                                                  header['totalPPN'],
                                                ).toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: heading4(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: SizedBox(
                                              width: width,
                                              child: Text(
                                                FormatCurrency.convertToIdr(
                                                  header['total'],
                                                ).toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: heading4(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return loading();
                                },
                              ),
                            ],
                          ),
                        ),
                        // Right container is shown only if _isSecondContainerVisible is true
                        if (_isSecondContainerVisible)
                          Expanded(
                            flex: ((1 - _leftWidthFactor) * 100).toInt(),
                            child: FutureBuilder<Map<String, dynamic>>(
                              future: getSinglePendapatanHarian(
                                widget.token,
                                tanggalSelect,
                                "totalTertinggi",
                                "",
                                listToko,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState !=
                                    ConnectionState.done) {
                                  return Center(child: loading());
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!['rc'] != '00') {
                                  return const Center(
                                    child: Text('Tidak Ada Data!'),
                                  );
                                }

                                final data = (snapshot.data!['data'] as Map)
                                    .cast<String, dynamic>();
                                final header = (data['header'] as Map)
                                    .cast<String, dynamic>();
                                final List<Map<String, dynamic>> detailList =
                                    ((data['detail'] as List?) ?? [])
                                        .map(
                                          (e) => (e as Map)
                                              .cast<String, dynamic>(),
                                        )
                                        .toList();

                                return ListView.builder(
                                  padding: EdgeInsets.only(
                                    left: size8,
                                    right: size8,
                                    bottom: size16,
                                  ),
                                  itemCount: detailList.length, // <-- WAJIB
                                  itemBuilder: (context, idx) {
                                    final merchant = detailList[idx];
                                    final merchantName =
                                        (merchant['nameToko'] ??
                                                merchant['merchant_name'] ??
                                                '')
                                            .toString();

                                    final products =
                                        ((merchant['detail']?['product']
                                                    as List?) ??
                                                [])
                                            .map(
                                              (e) => (e as Map)
                                                  .cast<String, dynamic>(),
                                            )
                                            .toList();

                                    // Cek apakah merchant['detail']['paymentMethod'] adalah Map dan cast dengan benar
                                    final paymentMethod =
                                        (merchant['detail']?['paymentMethod']
                                            is Map)
                                        ? (merchant['detail']?['paymentMethod']
                                              as Map<String, dynamic>)
                                        : {};

                                    return Container(
                                      margin: EdgeInsets.only(top: size12),
                                      padding: EdgeInsets.symmetric(
                                        vertical: size16,
                                        horizontal: size20,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          size8,
                                        ),
                                        border: Border.all(color: bnw300),
                                      ),
                                      // PENTING: Column (bukan ListView) di dalam item ListView
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Informasi Pendapatan ${header['tanggal']}',
                                            style: heading2(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                          SizedBox(height: size16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Jumlah Transaksi',
                                                    style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  SizedBox(height: size8),
                                                  Text(
                                                    'Nilai Transaksi',
                                                    style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  SizedBox(height: size8),
                                                  Text(
                                                    'Total PPN',
                                                    style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  SizedBox(height: size8),
                                                  Text(
                                                    'Total Diskon',
                                                    style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  SizedBox(height: size8),
                                                  Text(
                                                    'Total Keseluruhan',
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
                                                    '${header['count']}',
                                                    style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  SizedBox(height: size8),
                                                  Text(
                                                    FormatCurrency.convertToIdr(
                                                      header['nilaiTransaksi'],
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
                                                      header['totalPPN'],
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
                                                      merchant['totalDiscount'] ??
                                                          0,
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
                                                      header['total'],
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
                                          SizedBox(height: size16),
                                          Text(
                                            'Rincian Pembayaran',
                                            style: heading2(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                          SizedBox(height: size8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Cash',
                                                    style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  SizedBox(height: size8),
                                                  Text(
                                                    'Fifapay',
                                                    style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  SizedBox(height: size8),
                                                  Text(
                                                    'QRIS',
                                                    style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  SizedBox(height: size8),
                                                  Text(
                                                    'Credit',
                                                    style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  SizedBox(height: size8),
                                                  Text(
                                                    'Debit',
                                                    style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  SizedBox(height: size8),
                                                  Text(
                                                    'Coin',
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
                                                    FormatCurrency.convertToIdr(
                                                      paymentMethod['Cash'] ??
                                                          0,
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
                                                      paymentMethod['fifapay'] ??
                                                          0,
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
                                                      paymentMethod['qris'] ??
                                                          0,
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
                                                      paymentMethod['credit'] ??
                                                          0,
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
                                                      paymentMethod['debit'] ??
                                                          0,
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
                                                      paymentMethod['coin'] ??
                                                          0,
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
                                          SizedBox(height: size16),
                                          Text(
                                            'Rincian Produk',
                                            style: heading2(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),

                                          // DAFTAR PRODUK: builder bersarang yang aman
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: products.length,
                                            itemBuilder: (context, pIndex) {
                                              final product = products[pIndex];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
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
                                                              '${product['nameProduk'] ?? product['product_name'] ?? '-'}',
                                                              style: heading3(
                                                                FontWeight.w600,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            Text(
                                                              merchantName, // <-- pakai nama merchant yg bener
                                                              style: heading3(
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
                                                              "Total Per Produk",
                                                              style: heading3(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            Text(
                                                              FormatCurrency.convertToIdr(
                                                                product['total'] ??
                                                                    0,
                                                              ).toString(),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Divider(
                                                      thickness: 1,
                                                      color: bnw900,
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
                                                              'Total Transaksi',
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
                                                              'Nilai Transaksi',
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
                                                              'Total PPN',
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
                                                              'Total Diskon',
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
                                                              '${product['totalTransaksi'] ?? 0}',
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
                                                              FormatCurrency.convertToIdr(
                                                                product['nilaiTransaksi'] ??
                                                                    0,
                                                              ).toString(),
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
                                                              FormatCurrency.convertToIdr(
                                                                product['totalPPN'] ??
                                                                    0,
                                                              ).toString(),
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
                                                              FormatCurrency.convertToIdr(
                                                                product['totalDiskon'] ??
                                                                    0,
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
                                                    SizedBox(height: size16),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),

                                          SizedBox(height: size16),
                                          GestureDetector(
                                            onTap: () {
                                              getSinglePendapatanHarian(
                                                widget.token,
                                                tanggalSelect,
                                                "totalTertinggi",
                                                "pdf",
                                                listToko,
                                              ).then((value) {
                                                try {
                                                  launch(value['data']);
                                                  downloadFile(value['data']);
                                                } catch (_) {}
                                              });
                                            },
                                            child: buttonXXLoutline(
                                              Column(
                                                children: [
                                                  Icon(
                                                    PhosphorIcons
                                                        .file_text_fill,
                                                    color: primary500,
                                                  ),
                                                  Text(
                                                    'Pdf',
                                                    style: heading2(
                                                      FontWeight.w600,
                                                      primary500,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              110,
                                              primary500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    // Draggable handle appears only if the right container is visible
                    if (_isSecondContainerVisible)
                      Positioned(
                        left: _leftWidthFactor * constraints.maxWidth + 2,
                        top: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              // Update left container width based on drag
                              _leftWidthFactor +=
                                  details.delta.dx / constraints.maxWidth;

                              // Ensure the width stays within bounds: 10% to 50%
                              _leftWidthFactor = _leftWidthFactor.clamp(
                                0.1,
                                0.5,
                              );

                              // If dragging to the right and reaching max width, hide the right container
                              if (_leftWidthFactor >= 0.5 &&
                                  details.delta.dx > 0) {
                                _isSecondContainerVisible = false;
                                _leftWidthFactor = 1.0; // Reset to full width
                              }
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 64,
                            color: Colors.grey.withOpacity(0),
                            child: Center(
                              child: Container(
                                margin: EdgeInsets.only(right: size16),
                                height: 80,
                                width: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  orderBy(BuildContext context) {
    return SizedBox(
      // biar tinggi konsisten
      height: 48,
      child: GestureDetector(
        onTap: () {
          setState(() {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(
                  context,
                ).size.width, // ⟵ full lebar device
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              builder: (context) {
                return SafeArea(
                  child: SingleChildScrollView(
                    // ⟵ anti overflow & keyboard
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: StatefulBuilder(
                      builder: (context, setState) => IntrinsicHeight(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: size16),
                              Center(child: dividerShowdialog()),
                              SizedBox(height: size16),
                              Text(
                                'Rentang Waktu',
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
                              SizedBox(height: size24),
                              Text(
                                'Pilih Rentang Waktu',
                                style: heading3(
                                  FontWeight.w400,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),

                              // Wrap sudah aman untuk sempit/lebarnya layar
                              Wrap(
                                spacing: size16,
                                runSpacing: size12,
                                children: List<Widget>.generate(
                                  pilihUrutan.length,
                                  (int index) {
                                    final selected = _valueOrder == index;
                                    return ChoiceChip(
                                      padding: EdgeInsets.symmetric(
                                        vertical: size12,
                                      ),
                                      backgroundColor: bnw100,
                                      selectedColor: primary100,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: selected ? primary500 : bnw300,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          size8,
                                        ),
                                      ),
                                      label: Text(
                                        pilihUrutan[index],
                                        style: heading4(
                                          FontWeight.w400,
                                          selected ? primary500 : bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      selected: selected,
                                      onSelected: (_) {
                                        setState(() => _valueOrder = index);
                                      },
                                    );
                                  },
                                ),
                              ),

                              SizedBox(height: size32),
                              SizedBox(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: () {
                                    textOrderBy = pilihUrutan[_valueOrder];
                                    _textvalueOrderBy =
                                        pendapatanText[_valueOrder];
                                    refresh();
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
                                    0, // ⟵ biar wrap ke konten
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          });
        },

        // ==== TOMBOL ORDER BY (auto-width & anti overflow) ====
        child: FittedBox(
          // ⟵ skala turun kalau ruang sempit (opsional)
          fit: BoxFit.scaleDown,
          child: buttonXLoutline(
            Row(
              mainAxisSize: MainAxisSize.min, // ⟵ biar sekecil konten
              children: [
                SvgPicture.asset('assets/minimize.svg'),
                SizedBox(width: size12),
                Flexible(
                  // ⟵ biar teks bisa ellipsis
                  child: Text(
                    textOrderBy,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                ),
              ],
            ),
            0, // ⟵ JANGAN double.infinity, biar nggak overflow
            bnw300,
          ),
        ),
      ),
    );
  }

  keyword(BuildContext context) {
    final List<String> pilihUrutan = [
      '30 Hari Terakhir',
      '3 Bulan Terakhir',
      '6 Bulan Terakhir',
      '1 Tahun Terakhir',
    ];
    final List<String> textvalueKeyword = ['1B', '3B', '6B', '1Y'];

    return SizedBox(
      height: 48, // tinggi konsisten seperti orderBy
      child: GestureDetector(
        onTap: () {
          setState(() {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              barrierColor: Colors.black.withOpacity(0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size24),
              ),
              // full width device, tinggi wrap konten
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
              ),
              builder: (context) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: StatefulBuilder(
                    builder: (context, setModalState) => IntrinsicHeight(
                      child: Container(
                        decoration: BoxDecoration(
                          color: bnw100,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(size16),
                            topLeft: Radius.circular(size16),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: size16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize:
                                MainAxisSize.min, // tinggi ikut konten
                            children: [
                              SizedBox(height: size16),
                              Center(child: dividerShowdialog()),
                              SizedBox(height: size16),
                              Text(
                                'Pilih Tanggal',
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
                              SizedBox(height: size24),
                              Text(
                                'Pilih Urutan',
                                style: heading3(
                                  FontWeight.w400,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              SizedBox(height: size12),

                              // Wrap aman untuk lebar sempit/luas
                              Wrap(
                                spacing: size12,
                                runSpacing: size12,
                                children: List<Widget>.generate(
                                  pilihUrutan.length,
                                  (int index) {
                                    final selected = _valueKeyword == index;
                                    return ChoiceChip(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      backgroundColor: bnw100,
                                      selectedColor: primary200,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: selected ? primary500 : bnw300,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          size8,
                                        ),
                                      ),
                                      label: Text(
                                        pilihUrutan[index],
                                        style: heading4(
                                          FontWeight.w400,
                                          selected ? primary500 : bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      selected: selected,
                                      onSelected: (_) {
                                        // update HANYA state modal
                                        setModalState(
                                          () => _valueKeyword = index,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),

                              SizedBox(height: size24),
                              SizedBox(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: () {
                                    _textKeyword = pilihUrutan[_valueKeyword];
                                    _textvalueKeyword =
                                        textvalueKeyword[_valueKeyword];
                                    refresh();
                                    Navigator.pop(context);
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
                                    0, // wrap konten
                                  ),
                                ),
                              ),
                              SizedBox(height: size16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          });
        },

        // Tombol pemicu: auto-width + anti overflow
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: buttonXLoutline(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIcons.calendar),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _textKeyword,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                ),
              ],
            ),
            0, // JANGAN double.infinity
            bnw300,
          ),
        ),
      ),
    );
  }

  sortToko(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showModalBottomSheet(
            constraints: const BoxConstraints(maxWidth: double.infinity),
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            context: context,
            builder: (context) {
              return FutureBuilder(
                future: getAllToko(context, widget.token, '', ''),
                builder: (context, snapshot) {
                  return StatefulBuilder(
                    builder: (BuildContext context, setState) => Container(
                      height: MediaQuery.of(context).size.height / 1.4,
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
                                  'Pilih Toko',
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
                                SizedBox(height: size20),
                                Text(
                                  '${listToko.length} Toko Terpilih',
                                  style: heading2(
                                    FontWeight.w600,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                SizedBox(height: size24),
                              ],
                            ),
                          ),
                          snapshot.data == null
                              ? Center(child: CircularProgressIndicator())
                              : Expanded(
                                  child: GridView.builder(
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          mainAxisExtent: size120,
                                          // childAspectRatio: 2.977,
                                          crossAxisCount: 2,
                                          crossAxisSpacing: size16,
                                          mainAxisSpacing: size16,
                                        ),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, i) {
                                      ModelDataToko data = snapshot.data![i];
                                      selectedFlag[i] =
                                          selectedFlag[i] ?? false;
                                      bool? isSelected = selectedFlag[i];
                                      return GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          // valueMerchid.add(data.merchantid);
                                          // log(data.name.toString());
                                          setState(() {
                                            onTap(
                                              isSelected,
                                              i,
                                              data.merchantid,
                                            );
                                            print(listToko);
                                          });

                                          // print(dataProduk.productid);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(size16),
                                          // margin:  EdgeInsets.only(right: size16),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              size16,
                                            ),
                                            border: Border.all(color: bnw300),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          1000,
                                                        ),
                                                    child: SizedBox(
                                                      height: 60,
                                                      width: 60,
                                                      child:
                                                          snapshot
                                                                  .data![i]
                                                                  .logomerchant_url !=
                                                              null
                                                          ? Image.network(
                                                              snapshot
                                                                  .data![i]
                                                                  .logomerchant_url
                                                                  .toString(),
                                                              fit: BoxFit.cover,
                                                              errorBuilder:
                                                                  (
                                                                    context,
                                                                    error,
                                                                    stackTrace,
                                                                  ) => SizedBox(
                                                                    child: Icon(
                                                                      PhosphorIcons
                                                                          .storefront_fill,
                                                                      size: 60,
                                                                      color:
                                                                          bnw900,
                                                                    ),
                                                                  ),
                                                            )
                                                          : Icon(
                                                              PhosphorIcons
                                                                  .storefront_fill,
                                                              size: 60,
                                                            ),
                                                    ),
                                                  ),
                                                  SizedBox(width: size20),
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          snapshot
                                                                  .data![i]
                                                                  .name ??
                                                              '',
                                                          style: heading2(
                                                            FontWeight.w700,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                        Text(
                                                          '${snapshot.data![i].address}',
                                                          style: body1(
                                                            FontWeight.w400,
                                                            bnw800,
                                                            'Outfit',
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 50,
                                                    child: _buildSelectIcon(
                                                      isSelected!,
                                                      data,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          snapshot.data == null
                              ? Spacer()
                              : SizedBox(height: size32),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                print(listToko);
                                // getLaporanDaily(
                                //   context,
                                //   widget.token,
                                //   _textvalueOrderBy,
                                //   _textvalueKeyword,
                                //   listToko,
                                //   '',
                                // );
                                Navigator.pop(context);
                                initState();
                                setState(() {});
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
                  );
                },
              );
            },
          );
        });
      },
      child: buttonXLoutline(
        Row(
          children: [
            Icon(PhosphorIcons.storefront, color: bnw900),
            SizedBox(width: size12),
            Text(
              listToko.isEmpty ? 'Semua' : '${listToko.length} Toko',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: heading3(FontWeight.w600, bnw900, 'Outfit'),
            ),
          ],
        ),
        double.infinity,
        bnw300,
      ),
    );
  }

  void onTap(bool isSelected, int index, merchId) {
    if (index >= 0 && index < selectedFlag.length) {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);

      if (selectedFlag[index] == true) {
        // Periksa apakah productId sudah ada di dalam listProduct sebelum menambahkannya
        if (!listToko.contains(merchId)) {
          listToko.add(merchId);
        }
      } else {
        // Hapus productId dari listProduct jika sudah ada
        listToko.remove(merchId);
      }

      setState(() {});
    }
  }

  void onLongPress(bool isSelected, int index) {
    setState(() {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }

  Widget _buildSelectIcon(bool isSelected, ModelDataToko data) {
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
}
