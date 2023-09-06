import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:skeletons/skeletons.dart';

import '../../../../services/apimethod.dart';
import '../../../../utils/component.dart';

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

  String textOrderBy = 'Tanggal Terkini', textKeyword = '30 Hari Terakhir';
  String _textvalueOrderBy = 'tanggalTerkini',
      _textvalueKeyword = '1B',
      _textKeyword = '30 Hari Terakhir';

  int _valueOrder = 0, _valueKeyword = 0;

  GlobalKey _globalKey = GlobalKey();

  ScreenshotController screenshotController = ScreenshotController();

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = 100;
    return RepaintBoundary(
      key: _globalKey,
      child: Screenshot(
        controller: screenshotController,
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
                Spacer(),
                orderBy(context),
                SizedBox(width: size16),
                keyword(context),
                SizedBox(width: size16),
                // IntrinsicWidth(
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 6),
                //     height: 48,
                //     decoration: BoxDecoration(
                //       border: Border.all(color: bnw300, width: 1.6),
                //       borderRadius: BorderRadius.circular(size16),
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                //       children: [
                //         Icon(PhosphorIcons.storefront, color: bnw900),
                //         SizedBox(width: 4),
                //         Flexible(
                //           child: Text(
                //             'Semua Toko',
                //             maxLines: 1,
                //             overflow: TextOverflow.ellipsis,
                //             style: heading3(
                //               FontWeight.w600,
                //               bnw900,
                //               'Outfit',
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                // SizedBox(width: size16),
                GestureDetector(
                  onTap: () {
                    showBottomPilihan(
                      context,
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Bagikan Laporan',
                                style:
                                    heading1(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                              Text(
                                'Pilih format berbagi laporan',
                                style:
                                    heading2(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.6,
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => downloadFile(
                                        'https://api.prod.amio.my.id/storage/file/20230217-5524.pdf'),
                                    child: buttonXXLoutline(
                                      Column(
                                        children: [
                                          Icon(
                                            PhosphorIcons.file_text_fill,
                                            color: primary500,
                                          ),
                                          Text(
                                            'Pdf',
                                            style: heading2(FontWeight.w600,
                                                primary500, 'Outfit'),
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
                                      screenshotController
                                          .capture(
                                              delay: Duration(milliseconds: 10))
                                          .then((capturedImage) async {
                                        await ImageGallerySaver.saveImage(
                                            capturedImage!.buffer
                                                .asUint8List());
                                      }).catchError((onError) {
                                        print(onError);
                                      });
                                    },
                                    child: buttonXXLoutline(
                                      Column(
                                        children: [
                                          Icon(
                                            PhosphorIcons.user_circle,
                                            color: primary500,
                                          ),
                                          Text(
                                            'Gambar',
                                            style: heading2(FontWeight.w600,
                                                primary500, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      120,
                                      primary500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: buttonXXLoutline(
                                      Column(
                                        children: [
                                          Icon(
                                            PhosphorIcons.pencil_line,
                                            color: primary500,
                                          ),
                                          Text(
                                            'Teks',
                                            style: heading2(FontWeight.w600,
                                                primary500, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      110,
                                      primary500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
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
              ],
            ),
            SizedBox(height: size16),
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
                          'Tanggal',
                          style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: width + 10,
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
                  future: getLaporanDaily(
                    context,
                    widget.token,
                    _textvalueOrderBy,
                    _textvalueKeyword,
                    [''],
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Map<String, dynamic>? data = snapshot.data!['data'];
                      var detail = data!['detail'];
                      var header = data['header'];
                      // print(snapshot.data['data']);
                      return RefreshIndicator(
                        onRefresh: () async {
                          getLaporanDaily(
                            context,
                            widget.token,
                            _textvalueOrderBy,
                            _textvalueKeyword,
                            [''],
                          );
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
                                        detail[index]['tanggal'].toString(),
                                        style: heading4(
                                            FontWeight.w600, bnw900, 'Outfit'),
                                      ),
                                    ),
                                    SizedBox(
                                      width: width + 10,
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
                      padding: EdgeInsets.only(left: size16, right: size16),
                      itemCount: 5,
                      itemBuilder: (p0, p1) => SkeletonLine(
                        style: SkeletonLineStyle(
                          height: 40,
                          padding: EdgeInsets.only(bottom: size16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            FutureBuilder(
                future: getLaporanDaily(context, widget.token,
                    _textvalueOrderBy, _textvalueKeyword, ['']),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic>? data = snapshot.data!['data'];

                    var header = data!['header'];
                    return Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
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
                              style:
                                  heading4(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                          ),
                          SizedBox(
                            width: width + 10,
                            child: Text(
                              header['count'].toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  heading4(FontWeight.w400, bnw900, 'Outfit'),
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
                        ],
                      ),
                    );
                  }

                  return loading();
                }),
          ],
        ),
      ),
    );
  }

  GestureDetector buttonBagikanLaporan(link, icon, text) {
    return GestureDetector(
      onTap: () {
        downloadFile(link);
        //'https://api.prod.amio.my.id/storage/file/20230217-5524.pdf'
      },
      child: buttonXXLoutline(
        Column(
          children: [
            Icon(
              icon,
              color: primary500,
            ),
            Text(
              text,
              style: heading2(FontWeight.w600, primary500, 'Outfit'),
            ),
          ],
        ),
        110,
        primary500,
      ),
    );
  }

  orderBy(BuildContext context) {
    return IntrinsicWidth(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showModalBottomSheet(
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
                                SizedBox(height: 20),
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

  keyword(BuildContext context) {
    return IntrinsicWidth(
      child: GestureDetector(
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
                                SizedBox(height: 20),
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
                          SizedBox(height: size32),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                _textKeyword = pilihUrutan[_valueKeyword];
                                _textvalueKeyword =
                                    textvalueKeyword[_valueKeyword];
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
              Icon(
                PhosphorIcons.calendar,
                color: bnw900,
              ),
              SizedBox(width: size12),
              Text(
                _textKeyword,
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
      ),
    );
  }
}
