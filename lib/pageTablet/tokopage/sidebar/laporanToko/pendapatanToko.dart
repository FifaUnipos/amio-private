import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';
import 'package:skeletons/skeletons.dart';

import '../../../../services/apimethod.dart';
import '../../../../utils/component.dart';

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
                        color: bnw900,
                        size: size32,
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
                Spacer(),
                orderBy(context),
                SizedBox(width: size16),
                keyword(context),
                SizedBox(width: size16),
                // Expanded(
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 6),
                //     height: 48,
                //     decoration: BoxDecoration(
                //       border: Border.all(color: bnw300, width: 1.6),
                //       borderRadius: BorderRadius.circular(size12),
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                //       children: [
                //         Icon(PhosphorIcons.storefront, color: bnw900),
                //         SizedBox(width: 4),
                //         Text(
                //           'Semua Toko',
                //           maxLines: 1,
                //           overflow: TextOverflow.ellipsis,
                //           style: heading3(
                //             FontWeight.w600,
                //             bnw900,
                //             'Outfit',
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

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
                    48,
                    primary500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
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
                  future: getLaporanMerchant(
                    context,
                    widget.token,
                    _textvalueKeyword,
                    _textvalueOrderBy,
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
                          getLaporanMerchant(
                            context,
                            widget.token,
                            _textvalueKeyword,
                            _textvalueOrderBy,
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
                future: getLaporanMerchant(
                  context,
                  widget.token,
                  _textvalueKeyword,
                  _textvalueOrderBy,
                  [''],
                ),
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
                              style:
                                  heading4(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                          ),
                          SizedBox(
                            width: width + size12,
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
                  } else if (snapshot.hasError) {
                    return loading();
                  }

                  return loading();
                }),
          ],
        ),
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
                                  SizedBox(height: 20),
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
                                SizedBox(height: 20),
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
}
