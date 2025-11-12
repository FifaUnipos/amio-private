import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skeletons/skeletons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/tokomodel.dart';
import '../../../../services/apimethod.dart';

import '../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';
import '../../../../utils/component/component_loading.dart';
import '../../../../utils/component/component_showModalBottom.dart';

class LaporanPendapatanTokoPage extends StatefulWidget {
  String token;
  PageController pageController = PageController();
  LaporanPendapatanTokoPage({
    Key? key,
    required this.token,
    required this.pageController,
  }) : super(key: key);

  @override
  State<LaporanPendapatanTokoPage> createState() =>
      LaporanPendapatanTokoPageState();
}

class LaporanPendapatanTokoPageState extends State<LaporanPendapatanTokoPage> {
  List pilihUrutan = [
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

  List pendapatanText = [
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

  // String textvalueOrderBy = 'tokoTerbaru', _textvalueKeyword = '1B';

  String textOrderBy = 'Toko Terbaru', textKeyword = '30 Hari Terakhir';
  String _textvalueOrderBy = 'tokoTerbaru',
      _textvalueKeyword = '1B',
      _textKeyword = '30 Hari Terakhir';

  int _valueOrder = 0, _valueKeyword = 0;

  bool isTokoSelected = false;
  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};
  List<String> listToko = List.empty(growable: true);

  GlobalKey _globalKey = GlobalKey();

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        'Pendapatan Toko',
                        style:
                            heading1(FontWeight.w700, Colors.black, 'Outfit'),
                      ),
                      Text(
                        'Laporan',
                        style:
                            heading3(FontWeight.w400, Colors.black, 'Outfit'),
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
                    GestureDetector(
                      onTap: () {
                        showBottomPilihan(
                          context,
                          Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Bagikan Laporan',
                                      style: heading1(
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                    Text(
                                      'Pilih format berbagi laporan',
                                      style: heading2(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ],
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
                                            // log(_textvalueOrderBy);
                                            Navigator.pop(context);
                                            getLaporanMerchantExport(
                                                    context,
                                                    widget.token,
                                                    _textvalueKeyword,
                                                    _textvalueOrderBy,
                                                    listToko,
                                                    'pdf')
                                                .then((value) {
                                              try {
                                                launch(value['data']);
                                                downloadFile(value['data']);
                                              } catch (e) {}
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
                                                      'Outfit'),
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
                                            getLaporanMerchantExport(
                                                    context,
                                                    widget.token,
                                                    _textvalueKeyword,
                                                    _textvalueOrderBy,
                                                    listToko,
                                                    'excel')
                                                .then((value) {
                                              try {
                                                launch(value['data']);
                                                downloadFile(value['data']);
                                              } catch (e) {}
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
                                                      'Outfit'),
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
                                )
                              ],
                            ),
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
                  ],
                ),
              ))
            ],
          ),
          SizedBox(height: size24),
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: width + 20,
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
                  width: width + size12,
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
              padding: EdgeInsets.only(top: size12),
              decoration: BoxDecoration(
                color: primary100,
              ),
              child: FutureBuilder(
                future: getLaporanMerchant(context, widget.token,
                    _textvalueKeyword, _textvalueOrderBy, listToko),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic>? data = snapshot.data!['data'];
                    var detail = data!['detail'];
                    var header = data['header'];
                    // print(snapshot.data['data']);
                    return RefreshIndicator(
                      color: bnw100,
                      onRefresh: () async {
                        getLaporanMerchant(context, widget.token,
                            _textvalueKeyword, _textvalueOrderBy, listToko);
                        setState(() {});
                      },
                      child: ListView.builder(
                        // physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: detail.length,
                        itemBuilder: (builder, index) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: width + 20,
                                    child: Text(
                                      detail[index]['namerToko'].toString(),
                                      style: heading4(
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: width + size12,
                                    child: Text(
                                      detail[index]['totalTransaksi']
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
                      ),
                    );
                  }
                  return SkeletonListView(
                    padding: EdgeInsets.only(left: size12, right: size12),
                    itemCount: 5,
                    itemBuilder: (p0, p1) => SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 40,
                        padding: EdgeInsets.only(bottom: size12),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          FutureBuilder(
              future: getLaporanMerchant(context, widget.token,
                  _textvalueKeyword, _textvalueOrderBy, listToko),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic>? data = snapshot.data!['data'];

                  var header = data!['header'];
                  return Container(
                    padding: EdgeInsets.only(top: size12, bottom: size12),
                    decoration: BoxDecoration(
                      color: primary200,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(size16),
                        bottomRight: Radius.circular(size16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: width + 20,
                          child: Text(
                            'Total',
                            style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: width + size12,
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
                            FormatCurrency.convertToIdr(
                                    header['nilaiTransaksi'])
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
                } else if (snapshot.hasError) {
                  return loading();
                }

                return loading();
              }),
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
                      decoration: BoxDecoration(
                        color: bnw100,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(size16),
                          topLeft: Radius.circular(size16),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: size16, right: size16),
                        child: Column(
                          children: [
                            SizedBox(height: size16),
                            dividerShowdialog(),
                            Container(
                              width: double.infinity,
                              padding:
                                  EdgeInsets.only(right: size16, top: size16),
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
                                  SizedBox(height: size24),
                                  Text(
                                    'Pilih Urutan',
                                    style: heading3(
                                        FontWeight.w400, bnw900, 'Outfit'),
                                  ),
                                  Wrap(
                                    children: List<Widget>.generate(
                                      pilihUrutan.length,
                                      (int index) {
                                        return Padding(
                                          padding:
                                              EdgeInsets.only(right: size12),
                                          child: ChoiceChip(
                                            padding: EdgeInsets.fromLTRB(
                                                0, size12, 0, size12),
                                            backgroundColor: bnw100,
                                            selectedColor: primary200,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                color: _valueOrder == index
                                                    ? primary500
                                                    : bnw300,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(size12),
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
                            SizedBox(height: size16),
                            SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () {
                                  // print(_valueOrder);
                                  // print(pilihUrutan[_valueOrder]);

                                  textOrderBy = pilihUrutan[_valueOrder];
                                  _textvalueOrderBy =
                                      pendapatanText[_valueOrder];
                                  pendapatanText[_valueOrder];

                                  refresh();
                                  Navigator.pop(context);
                                },
                                child: buttonXL(
                                  Center(
                                    child: Text(
                                      'Tampilkan',
                                      style: heading3(
                                          FontWeight.w600, bnw100, 'Outfit'),
                                    ),
                                  ),
                                  double.infinity,
                                ),
                              ),
                            ),
                            SizedBox(height: size16),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          });
        },
        child: buttonXLoutline(
          Padding(
            padding: EdgeInsets.only(left: 6, right: size12),
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
          0,
          bnw300,
        ),
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
                builder: (BuildContext context, setState) => IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      color: bnw100,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(size16),
                        topLeft: Radius.circular(size16),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: size16, right: size16),
                      child: Column(
                        children: [
                          SizedBox(height: size16),
                          dividerShowdialog(),
                          Container(
                            width: double.infinity,
                            padding:
                                EdgeInsets.only(right: size16, top: size16),
                            color: bnw100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pilih Tanggal',
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
                                  'Pilih Urutan',
                                  style: heading3(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                                Wrap(
                                  children: List<Widget>.generate(
                                    pilihUrutan.length,
                                    (int index) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: size12),
                                        child: ChoiceChip(
                                          padding: EdgeInsets.fromLTRB(
                                              0, size12, 0, size12),
                                          backgroundColor: bnw100,
                                          selectedColor: primary200,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color: _valueKeyword == index
                                                  ? primary500
                                                  : bnw300,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(size12),
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
                          SizedBox(height: size16),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                // print(_valueKeyword);
                                // print(pilihUrutan[_valueKeyword]);
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
                                        FontWeight.w600, bnw100, 'Outfit'),
                                  ),
                                ),
                                double.infinity,
                              ),
                            ),
                          ),
                          SizedBox(height: size16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
      },
      child: buttonXLoutline(
        Padding(
          padding: EdgeInsets.only(left: 6, right: size12),
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
        0,
        bnw300,
      ),
    );
  }

  sortToko(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showModalBottomSheet(
            constraints: const BoxConstraints(
              maxWidth: double.infinity,
            ),
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
                                    'Pilih Toko',
                                    style: heading2(
                                        FontWeight.w700, bnw900, 'Outfit'),
                                  ),
                                  Text(
                                    'Tentukan data yang akan tampil',
                                    style: heading4(
                                        FontWeight.w400, bnw600, 'Outfit'),
                                  ),
                                  SizedBox(height: size20),
                                  Text(
                                    '${listToko.length} Toko Terpilih',
                                    style: heading2(
                                        FontWeight.w600, bnw900, 'Outfit'),
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
                                              onTap(isSelected, i,
                                                  data.merchantid);
                                              print(listToko);
                                            });

                                            // print(dataProduk.productid);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(size16),
                                            // margin:  EdgeInsets.only(right: size16),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(size16),
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
                                                              1000),
                                                      child: SizedBox(
                                                        height: 60,
                                                        width: 60,
                                                        child: snapshot.data![i]
                                                                    .logomerchant_url !=
                                                                null
                                                            ? Image.network(
                                                                snapshot
                                                                    .data![i]
                                                                    .logomerchant_url
                                                                    .toString(),
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder: (context,
                                                                        error,
                                                                        stackTrace) =>
                                                                    SizedBox(
                                                                        child:
                                                                            Icon(
                                                                  PhosphorIcons
                                                                      .storefront_fill,
                                                                  size: 60,
                                                                  color: bnw900,
                                                                )),
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
                                                            snapshot.data![i]
                                                                    .name ??
                                                                '',
                                                            style: heading2(
                                                                FontWeight.w700,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          Text(
                                                            '${snapshot.data![i].address}',
                                                            style: body1(
                                                                FontWeight.w400,
                                                                bnw800,
                                                                'Outfit'),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 50,
                                                      child: _buildSelectIcon(
                                                          isSelected!, data),
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
                                  listToko;
                                  getLaporanMerchant(
                                    context,
                                    widget.token,
                                    _textvalueOrderBy,
                                    _textvalueKeyword,
                                    listToko,
                                  );
                                  Navigator.pop(context);
                                  initState();
                                  setState(() {});
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
                    );
                  });
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
