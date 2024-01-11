import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amio/models/tokoModel/keuanganModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../../services/apimethod.dart';
import '../../../../../utils/component.dart';
import '../../../../main.dart';
import 'rekonToko.dart';

class LihatKeuanganToko extends StatefulWidget {
  String token;

  LihatKeuanganToko({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<LihatKeuanganToko> createState() => _LihatKeuanganTokoState();
}

class _LihatKeuanganTokoState extends State<LihatKeuanganToko>
    with TickerProviderStateMixin {
  List<PendapatanLainModel>? datasPendapatan;
  List<PengeluaranLainModel>? datasPengeluaran;
  TextEditingController conKeterangan = TextEditingController();
  TextEditingController conPemasukkan = TextEditingController();
  PageController pageController = PageController();
  TabController? tabController;

  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};

  @override
  void initState() {
    tabController = TabController(length: 1, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        datasPendapatan = await getPendapatan(
          context,
          widget.token,
          'IN',
        );
        setState(() {});
      },
    );

    pageController = PageController(
      initialPage: 0,
      keepPage: true,
      viewportFraction: 1,
    );

    setState(() {
      // print(datasPendapatan.toString());
      datasPendapatan;
    });
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    conKeterangan.dispose();
    conPemasukkan.dispose();
    super.dispose();
  }

  // double width = MediaQuery.of(context).size.width;
  double? width;
  double widtValue = 80;

  double heightInformation = 0;
  double widthInformation = 0;
  String? ppmId;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    bool isFalseAvailable = selectedFlag.containsValue(false);

    return datasPendapatan == null
        ? SafeArea(
            child: Container(
              padding: EdgeInsets.all(size16),
              margin: EdgeInsets.all(size16),
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: BorderRadius.circular(size16),
              ),
              child: Scaffold(
                backgroundColor: bnw100,
                body: Center(child: loading()),
              ),
            ),
          )
        : SafeArea(
            child: Container(
              padding: EdgeInsets.all(size16),
              margin: EdgeInsets.all(size16),
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: BorderRadius.circular(size16),
              ),
              child: PageView(
                controller: pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  mainPageKeuangan(context, isFalseAvailable),
                  tambahPendapatan(setState, context),
                  tambahPengeluaran(setState, context),
                  ubahPendapatanPage(setState, context),
                  ubahPengeluaranPage(setState, context),
                ],
              ),
            ),
          );
  }

  mainPageKeuangan(BuildContext context, bool isFalseAvailable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keuangan',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  nameToko ?? '',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
            rekonPageController.initialPage == 0
                ? GestureDetector(
                    onTap: () {
                      showModalBottomProfile(
                        context,
                        MediaQuery.of(context).size.height / 2.8,
                        Column(
                          children: [
                            dividerShowdialog(),
                            SizedBox(height: size16),
                            Text(
                              'Kamu yakin ingin Memposting Data Rekonsialisasi?',
                              style:
                                  heading1(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                            SizedBox(height: size8),
                            Text(
                              'Data yang telah diposting tidak dapat diubah kembali.',
                              style:
                                  heading2(FontWeight.w400, bnw900, 'Outfit'),
                            ),
                            SizedBox(height: size32),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: buttonXLoutline(
                                      Center(
                                        child: Text(
                                          'Batal',
                                          style: heading3(FontWeight.w600,
                                              primary500, 'Outfit'),
                                        ),
                                      ),
                                      MediaQuery.of(context).size.width,
                                      primary500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      whenLoading(context);
                                      postingRekon(context, widget.token,
                                          yearRekon, monthRekon);
                                    },
                                    child: buttonXL(
                                      Center(
                                        child: Text(
                                          'Ya, Posting',
                                          style: heading3(FontWeight.w600,
                                              bnw100, 'Outfit'),
                                        ),
                                      ),
                                      MediaQuery.of(context).size.width,
                                      // primary500,
                                      // primary500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    child: buttonXL(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(PhosphorIcons.plus, color: bnw100),
                          SizedBox(width: size12),
                          Text(
                            'Posting',
                            style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ],
                      ),
                      0,
                    ),
                  )
                : Container(),
          ],
        ),
        // SizedBox(
        //   width: MediaQuery.of(context).size.width,
        //   child: TabBar(
        //     controller: tabController,
        //     unselectedLabelColor: bnw600,
        //     labelColor: primary500,
        //     labelStyle: heading2(FontWeight.w400, bnw900, 'Outfit'),
        //     physics: const NeverScrollableScrollPhysics(),
        //     onTap: (value) {
        //       setState(() {
        //         if (value == 0) {
        //           selectedIndex = 0;
        //         } else if (value == 1) {
        //           selectedIndex = 1;
        //         } else if (value == 2) {
        //           selectedIndex = 2;
        //         }
        //       });
        //     },
        //     tabs: const [
        //       // Tab(
        //       //   text: 'Pendapatan Lain-Lain',
        //       // ),
        //       // Tab(
        //       //   text: 'Pengeluaran Lain-Lain',
        //       // ),
        //       Tab(
        //         text: 'Rekonsiliasi',
        //       ),
        //     ],
        //   ),
        // ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 10, bottom: 10),
        //   child: buttonLoutline(
        //     GestureDetector(
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceAround,
        //         children: [
        //           Row(
        //             children: [
        //               Text(
        //                 'Urutkan',
        //                 style: heading3(FontWeight.w600, bnw900, 'Outfit'),
        //               ),
        //               Text(
        //                 ' dari Nama Toko A ke Z',
        //                 style: heading3(FontWeight.w400, bnw600, 'Outfit'),
        //               ),
        //             ],
        //           ),
        //           const Icon(PhosphorIcons.caret_down),
        //         ],
        //       ),
        //     ),
        //     bnw300,
        //   ),
        // ),
        SizedBox(height: size16),
        Expanded(
          child: TabBarView(
            controller: tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              // pendapatanLain(isFalseAvailable),
              // pengeluaranLain(isFalseAvailable),
              RekonToko(token: widget.token),
            ],
          ),
        ),
      ],
    );
  }

  pendapatanLain(bool isFalseAvailable) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          width: width,
          child: Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primary500,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _selectAll,
                          child: SizedBox(
                            width: width,
                            child: Icon(
                              isFalseAvailable
                                  ? PhosphorIcons.square
                                  : PhosphorIcons.check_square_fill,
                              color: bnw100,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            'Tanggal',
                            style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue + 40,
                          child: Text(
                            'Jenis Pendapatan',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            'Keterangan',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            'Nilai',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue + 10,
                          child: Text(
                            'ID Pendaatan',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            '',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primary100,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: datasPendapatan!.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (builder, index) {
                        PendapatanLainModel data = datasPendapatan![index];
                        selectedFlag[index] = selectedFlag[index] ?? false;
                        bool? isSelected = selectedFlag[index];

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      onTap(isSelected, index);
                                    },
                                    child: SizedBox(
                                      width: width,
                                      child:
                                          _buildSelectIcon(isSelected!, data),
                                    ),
                                  ),
                                  SizedBox(
                                    width: widtValue,
                                    child: Text(
                                      datasPendapatan![index]
                                          .tanggal
                                          .toString(),
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: widtValue + 40,
                                    child: Text(
                                      datasPendapatan![index]
                                          .peruntukanPPM
                                          .toString(),
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: widtValue,
                                    child: Text(
                                      datasPendapatan![index]
                                          .deskripsi
                                          .toString(),
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: widtValue,
                                    child: Text(
                                      FormatCurrency.convertToIdr(
                                              datasPendapatan![index].jumlah)
                                          .toString(),
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: widtValue + 10,
                                    child: Text(
                                      datasPendapatan![index].pPMID.toString(),
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        ppmId = datasPendapatan![index].pPMID;
                                      });
                                      pageController.jumpToPage(3);
                                    },
                                    child: SizedBox(
                                        width: widtValue,
                                        child: buttonLoutline(
                                          Row(
                                            children: [
                                              Icon(PhosphorIcons.pencil,
                                                  color: bnw900),
                                              Text('Atur',
                                                  style: heading4(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit')),
                                            ],
                                          ),
                                          bnw300,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(thickness: 1.2)
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  tambahPendapatan(StateSetter setState, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  pageController.jumpToPage(0);
                },
                child: Icon(PhosphorIcons.arrow_left, size: 24),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Pemasukkan',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Tamabah Pemasukkan keuangan lain-lain',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: ListView(
              // padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              children: [
                fieldAddDrop(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                jenisList(context),
                fieldAdd(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                fieldAdd(
                  'Total Pemasukkan',
                  'Rp. 1.500.000',
                  conPemasukkan,
                  TextInputType.number,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  print('hallo');
                  // Clipboard.setData(ClipboardData(text: img64));
                },
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Simpan & Tambah Baru',
                      style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                  bnw900,
                ),
              ),
              GestureDetector(
                onTap: () {
                  createPendapatan(
                    context,
                    widget.token,
                    'Beliang Bar',
                    'IN',
                    conKeterangan.text,
                    conPemasukkan.text,
                    '',
                    pageController,
                  );

                  initState();
                  setState(() {});
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Tambah',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  ubahPendapatanPage(StateSetter setState, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  pageController.jumpToPage(0);
                },
                child: Icon(PhosphorIcons.arrow_left, size: 24),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubah Pemasukkan',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Ubah Pemasukkan keuangan lain-lain',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: ListView(
              // padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              children: [
                fieldAddDrop(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                jenisList(context),
                fieldAdd(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                fieldAdd(
                  'Total Pemasukkan',
                  'Rp. 1.500.000',
                  conPemasukkan,
                  TextInputType.number,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  print('hallo');
                  // Clipboard.setData(ClipboardData(text: img64));
                },
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Simpan & Tambah Baru',
                      style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                  bnw900,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ubahPendapatan(
                    context,
                    widget.token,
                    ppmId,
                    'beli',
                    conKeterangan.text,
                    conPemasukkan.text,
                    '',
                    pageController,
                  );

                  initState();
                  setState(() {});
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Tambah',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  pengeluaranLain(bool isFalseAvailable) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          width: width,
          child: Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primary500,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _selectAll,
                          child: SizedBox(
                            width: width,
                            child: Icon(
                              isFalseAvailable
                                  ? PhosphorIcons.square
                                  : PhosphorIcons.check_square_fill,
                              color: bnw100,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            'Tanggal',
                            style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue + 40,
                          child: Text(
                            'Jenis Pendapatan',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            'Keterangan',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            'Nilai',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue + 10,
                          child: Text(
                            'ID Pendaatan',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                        SizedBox(
                          width: widtValue,
                          child: Text(
                            '',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primary100,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: FutureBuilder(
                        future: getPengeluaran(
                          context,
                          widget.token,
                          'OUT',
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data;
                            // print(snapshot.data);
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: snapshot.data.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (builder, index) {
                                selectedFlag[index] =
                                    selectedFlag[index] ?? false;
                                bool? isSelected = selectedFlag[index];

                                Widget _buildSelectIcon2(
                                  bool isSelected,
                                  data,
                                ) {
                                  return Icon(
                                    isSelected
                                        ? PhosphorIcons.check_square_fill
                                        : PhosphorIcons.square,
                                    color: primary500,
                                  );
                                }

                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 12, 0, 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              onTap(isSelected, index);
                                            },
                                            child: SizedBox(
                                              width: width,
                                              child: _buildSelectIcon2(
                                                  isSelected!, data),
                                            ),
                                          ),
                                          SizedBox(
                                            width: widtValue,
                                            child: Text(
                                              data![index]['tanggal']
                                                  .toString(),
                                              style: heading4(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: widtValue + 40,
                                            child: Text(
                                              data![index]['peruntukan_PPM']
                                                  .toString(),
                                              style: heading4(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: widtValue,
                                            child: Text(
                                              data![index]['deskripsi']
                                                  .toString(),
                                              style: heading4(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: widtValue,
                                            child: Text(
                                              FormatCurrency.convertToIdr(
                                                      data![index]['jumlah'])
                                                  .toString(),
                                              style: heading4(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: widtValue + 10,
                                            child: Text(
                                              data![index]['PPM_ID'].toString(),
                                              style: heading4(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                ppmId = data![index]['PPM_ID'];
                                              });
                                              pageController.jumpToPage(4);
                                            },
                                            child: SizedBox(
                                                width: widtValue,
                                                child: buttonLoutline(
                                                  Row(
                                                    children: [
                                                      Icon(PhosphorIcons.pencil,
                                                          color: bnw900),
                                                      Text('Atur',
                                                          style: heading4(
                                                              FontWeight.w600,
                                                              bnw900,
                                                              'Outfit')),
                                                    ],
                                                  ),
                                                  bnw300,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(thickness: 1.2)
                                  ],
                                );
                              },
                            );
                          }

                          return loading();
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  tambahPengeluaran(StateSetter setState, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  pageController.jumpToPage(0);
                },
                child: Icon(PhosphorIcons.arrow_left, size: 24),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Pemasukkan',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Tamabah Pemasukkan keuangan lain-lain',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: ListView(
              // padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              children: [
                fieldAddDrop(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                jenisList(context),
                fieldAdd(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                fieldAdd(
                  'Total Pemasukkan',
                  'Rp. 1.500.000',
                  conPemasukkan,
                  TextInputType.number,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  print('hallo');
                  // Clipboard.setData(ClipboardData(text: img64));
                },
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Simpan & Tambah Baru',
                      style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                  bnw900,
                ),
              ),
              GestureDetector(
                onTap: () {
                  createPendapatan(
                    context,
                    widget.token,
                    'Beli barang',
                    'OUT',
                    conKeterangan.text,
                    conPemasukkan.text,
                    '',
                    pageController,
                  );

                  initState();
                  setState(() {});
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Tambah',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  ubahPengeluaranPage(StateSetter setState, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  pageController.jumpToPage(0);
                },
                child: Icon(PhosphorIcons.arrow_left, size: 24),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubah Pengeluaran',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Ubah Pengeluaran keuangan lain-lain',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: ListView(
              // padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              children: [
                fieldAddDrop(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                jenisList(context),
                fieldAdd(
                  'Keterangan',
                  'Investasi saham',
                  conKeterangan,
                  TextInputType.text,
                ),
                fieldAdd(
                  'Total Pemasukkan',
                  'Rp. 1.500.000',
                  conPemasukkan,
                  TextInputType.number,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  print('hallo');
                  // Clipboard.setData(ClipboardData(text: img64));
                },
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Simpan & Tambah Baru',
                      style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                  bnw900,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ubahPendapatan(
                    context,
                    widget.token,
                    ppmId,
                    'beli',
                    conKeterangan.text,
                    conPemasukkan.text,
                    '',
                    pageController,
                  );

                  initState();
                  setState(() {});
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Tambah',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width / 2.65,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  fieldAddDrop(title, hint, mycontroller, TextInputType numberNo) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: body1(FontWeight.w500, bnw900, 'Outfit'),
              ),
              Text(
                ' *',
                style: body1(FontWeight.w700, red500, 'Outfit'),
              ),
            ],
          ),
          TextFormField(
            keyboardType: numberNo,
            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
            controller: mycontroller,
            onChanged: (value) {},
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: bnw500,
                ),
              ),
              hintText: '$hint',
              suffixIcon: Icon(PhosphorIcons.calendar_fill, color: bnw900),
              hintStyle: heading3(FontWeight.w600, bnw500, 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }

  fieldAdd(title, hint, mycontroller, TextInputType numberNo) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: body1(FontWeight.w500, bnw900, 'Outfit'),
              ),
              Text(
                ' *',
                style: body1(FontWeight.w700, red500, 'Outfit'),
              ),
            ],
          ),
          TextFormField(
            keyboardType: numberNo,
            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
            controller: mycontroller,
            onChanged: (value) {},
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: bnw500,
                ),
              ),
              hintText: 'Cth : $hint',
              hintStyle: heading3(FontWeight.w600, bnw500, 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }

  jenisList(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(
          () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context, setState) => Container(
                    height: MediaQuery.of(context).size.height / 1.8,
                    decoration: BoxDecoration(
                      color: bnw100,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            height: 4,
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: bnw300,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(left: 15),
                            padding: const EdgeInsets.only(right: 15, top: 15),
                            decoration: BoxDecoration(
                              color: bnw100,
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.5,
                                  color: bnw500,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Kategori',
                                          style: heading4(FontWeight.w400,
                                              bnw900, 'Outfit'),
                                        ),
                                        Text(
                                          ' *',
                                          style: heading4(FontWeight.w400,
                                              red500, 'Outfit'),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      jenisProductEdit == null
                                          ? 'Pilih Kategori'
                                          : jenisProductEdit
                                              .toString()
                                              .toLowerCase(),
                                      style: heading2(
                                          FontWeight.w600, bnw500, 'Outfit'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: typeproductList?.map(
                                    (item) {
                                      return GestureDetector(
                                        onTap: () {
                                          // log(item['jenisproduct']);
                                          // log(item['kodeproduct']);
                                          setState(() {
                                            jenisProductEdit =
                                                item['jenisproduct'];
                                            // jenisProduct = item['jenisproduct'];

                                            // idProduct = item['kodeproduct'];
                                            _myProvince = item['kodeproduct'];
                                          });
                                        },
                                        child: Container(
                                          height: 58,
                                          width: double.infinity,
                                          padding: const EdgeInsets.only(
                                              right: 15, top: 15),
                                          decoration: BoxDecoration(
                                            color: bnw100,
                                            border: Border(
                                              bottom: BorderSide(
                                                width: 1,
                                                color: bnw300,
                                              ),
                                            ),
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              item['jenisproduct']
                                                  .toString()
                                                  .toLowerCase(),
                                              style: heading3(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList() ??
                                  [],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // _getRegenciesList(_myProvince);
                              // autoReload();
                              Navigator.pop(context);
                            },
                            child: buttonXXL(
                              Center(
                                child: Text(
                                  'Selesai',
                                  style: heading2(
                                      FontWeight.w600, bnw100, 'Outfit'),
                                ),
                              ),
                              double.infinity,
                            ),
                          ),
                          const SizedBox(height: 8)
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      child: TextFormField(
        style: heading3(FontWeight.w600, bnw900, 'Outfit'),
        enabled: false,
        onTap: () {},
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 1.5,
              color: bnw500,
            ),
          ),
          hintText: 'Pilih Jenis Pemasukkan',
          suffixIcon: Icon(PhosphorIcons.caret_down_fill, color: bnw900),
          hintStyle: heading3(FontWeight.w600, bnw500, 'Outfit'),
        ),
      ),
      // Container(
      //   width: double.infinity,
      //   margin: const EdgeInsets.only(top: 15),
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     border: Border(
      //       bottom: BorderSide(
      //         width: 1.5,
      //         color: bnw500,
      //       ),
      //     ),
      //   ),
      //   child: Padding(
      //     padding: const EdgeInsets.only(bottom: 8.0),
      //     child: Align(
      //       alignment: Alignment.centerLeft,
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text(
      //             'Kategori *',
      //             style: heading4(FontWeight.w400, bnw900, 'Outfit'),
      //           ),
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               Text(
      //                 jenisProductEdit == null
      //                     ? 'Kategori'
      //                     : jenisProductEdit.toString().toLowerCase(),
      //                 style: heading2(FontWeight.w600,
      //                     jenisProductEdit == null ? bnw500 : bnw900, 'Outfit'),
      //               ),
      //             ],
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  void _selectAll() {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    // If false will be available then it will select all the checkbox
    // If there will be no false then it will de-select all
    selectedFlag.updateAll((key, value) => isFalseAvailable);
    setState(() {
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }

  void onTap(bool isSelected, int index) {
    setState(() {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);
    });
    // if (isSelectionMode) {
    // } else {
    //   // Open Detail Page
    // }
  }

  Widget _buildSelectIcon(bool isSelected, PendapatanLainModel data) {
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

  List? typeproductList;
  String? _myProvince;

  String provinceInfoUrl = '$url/api/typeproduct';
  Future _getProvinceList() async {
    await http.post(Uri.parse(provinceInfoUrl), body: {
      "deviceid": identifier,
    }).then((response) {
      var data = json.decode(response.body);

      setState(() {
        typeproductList = data['data'];
      });
    });
  }
}
