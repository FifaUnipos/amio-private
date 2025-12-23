import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';

import 'package:skeletons/skeletons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/component/component_button.dart';
import '../../../../models/tokomodel.dart';
import '../../../../services/apimethod.dart';

import '../../../../utils/component/component_color.dart';
import '../../../../utils/component/component_loading.dart';
import '../../../../utils/component/component_showModalBottom.dart';

class LaporanPenggunaanProdukPage extends StatefulWidget {
  String token;
  PageController pageController = PageController();
  LaporanPenggunaanProdukPage({
    Key? key,
    required this.token,
    required this.pageController,
  }) : super(key: key);

  @override
  State<LaporanPenggunaanProdukPage> createState() =>
      LaporanPendapatanPerProdukState();
}

class LaporanPendapatanPerProdukState
    extends State<LaporanPenggunaanProdukPage> {
  List pilihUrutan = [
    "Stok Akhir A-Z", // endingStockAsc
    "Stok Akhir Z-A", // endingStockDesc
    "Stok Awal A-Z", // startingStockAsc
    "Stok Awal Z-A", // startingStockDesc
    "Nama Inventori A-Z", // inventoryNameAsc
    "Nama Inventori Z-A", // inventoryNameDesc
    "Inventori Keluar A-Z", // outgoingInventoryAsc
    "Inventori Keluar Z-A", // outgoingInventoryDesc
    "Inventori Masuk A-Z", // incomingInventoryAsc
    "Inventori Masuk Z-A", // incomingInventoryDesc
  ];

  List pendapatanText = [
    "endingStockAsc",
    "endingStockDesc",
    "startingStockAsc",
    "startingStockDesc",
    "inventoryNameAsc",
    "inventoryNameDesc",
    "outgoingInventoryAsc",
    "outgoingInventoryDesc",
    "incomingInventoryAsc",
    "incomingInventoryDesc",
  ];
  String textOrderBy = 'Stok Akhir A-Z', textKeyword = '30 Hari Terakhir';
  String _textvalueOrderBy = 'endingStockAsc',
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
                        'Laporan Penggunaan Bahan Produk',
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
                                          style: heading1(FontWeight.w600,
                                              bnw900, 'Outfit'),
                                        ),
                                        Text(
                                          'Pilih format berbagi laporan',
                                          style: heading2(FontWeight.w400,
                                              bnw900, 'Outfit'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size20),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          2.6,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                                getPenggunaanProduk(
                                                        context,
                                                        widget.token,
                                                        listToko,
                                                        _textvalueKeyword,
                                                        _textvalueOrderBy,
                                                        "",
                                                        "pdf")
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
                                                          .file_text_fill,
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
                                                getPenggunaanProduk(
                                                        context,
                                                        widget.token,
                                                        listToko,
                                                        _textvalueKeyword,
                                                        _textvalueOrderBy,
                                                        "",
                                                        "excel")
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
                    )),
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
                topLeft: Radius.circular(size16),
                topRight: Radius.circular(size16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(width: size24),
                Expanded(
                  child: SizedBox(
                    child: Row(
                      children: [
                        Text(
                          'Nama Produk',
                          style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                        ),
                      ],
                    ),
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
                future: getPenggunaanProduk(context, widget.token, listToko,
                    _textvalueKeyword, _textvalueOrderBy, "", ""),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic>? data = snapshot.data!['data'];
                    final List<Map<String, dynamic>> details =
                        ((data?['detail'] as List?) ?? [])
                            .map((e) => (e as Map).cast<String, dynamic>())
                            .toList();

                    String asString(dynamic v) => v?.toString() ?? '';
                    double asDouble(dynamic v) {
                      if (v is num) return v.toDouble();
                      return double.tryParse(v?.toString() ?? '') ?? 0.0;
                    }

                    String fmtNum(num v) {
                      final d = v.toDouble();
                      return d == d.truncateToDouble()
                          ? d.toStringAsFixed(0)
                          : d.toStringAsFixed(2);
                    }

                    return RefreshIndicator(
                      color: bnw100,
                      onRefresh: () async {
                        setState(() {}); // rebuild supaya Future jalan lagi
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: details.length,
                        itemBuilder: (context, dIdx) {
                          final row = details[dIdx];
                          final String merchantName =
                              asString(row['merchant_name']); // disimpan saja
                          final List<Map<String, dynamic>> products =
                              ((row['product_materials'] as List?) ?? [])
                                  .map(
                                      (e) => (e as Map).cast<String, dynamic>())
                                  .toList();

                          // List accordion per-produk
                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, pIdx) {
                              final prod = products[pIdx];
                              final String productName =
                                  asString(prod['product_name']);
                              final String productId = asString(
                                  prod['product_id']); // bisa String/int

                              final List<Map<String, dynamic>> usages =
                                  ((prod['product_material_usage'] as List?) ??
                                          [])
                                      .map((e) =>
                                          (e as Map).cast<String, dynamic>())
                                      .toList();

                              return Column(
                                children: [
                                  Theme(
                                    // biar divider ExpansionTile rapi
                                    data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: size24, right: size24),
                                      child: ExpansionTile(
                                        tilePadding: EdgeInsets.zero,
                                        childrenPadding: EdgeInsets.zero,
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                productName.isEmpty
                                                    ? '(Tanpa nama)'
                                                    : productName,
                                                style: heading3(FontWeight.w700,
                                                    bnw900, 'Outfit'),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // subtitle: Text(
                                        //   'ID: $productId',
                                        //   style: body1(
                                        //       FontWeight.w400, bnw700, 'Outfit'),
                                        //   overflow: TextOverflow.ellipsis,
                                        // ),

                                        // === isi accordion: header kolom + list material ===
                                        children: [
                                          // header kolom
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: size12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: Text('Bahan',
                                                      style: heading4(
                                                          FontWeight.w700,
                                                          bnw900,
                                                          'Outfit')),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text('Unit',
                                                      style: heading4(
                                                          FontWeight.w700,
                                                          bnw900,
                                                          'Outfit')),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text('Jumlah',
                                                      style: heading4(
                                                          FontWeight.w700,
                                                          bnw900,
                                                          'Outfit')),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(thickness: 1),

                                          // list material (tetap list)
                                          ListView.separated(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: usages.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(height: 6),
                                            itemBuilder: (context, uIdx) {
                                              final u = usages[uIdx];
                                              final String invName =
                                                  asString(u['inventory_name']);
                                              final String unitName = asString(
                                                  u['inventory_unit_name']);
                                              final double qty = asDouble(u[
                                                  'quantity']); // "10.000000" → 10.0

                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                      invName,
                                                      style: heading4(
                                                          FontWeight.w600,
                                                          bnw900,
                                                          'Outfit'),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      unitName,
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      fmtNum(qty),
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          const Divider(thickness: 1.2),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider()
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  }
                  return SkeletonListView(
                    padding: EdgeInsets.only(left: size8, right: size8),
                    itemCount: 5,
                    itemBuilder: (p0, p1) => SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 40,
                        padding: EdgeInsets.only(bottom: size8),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // FutureBuilder(
          //     future: getPenggunaanProduk(context, widget.token, listToko,
          //         _textvalueKeyword, _textvalueOrderBy, ""),
          //     builder: (context, snapshot) {
          //       if (snapshot.hasData) {
          //         Map<String, dynamic>? data = snapshot.data!['data'];

          //         var header = data!['header'];
          //         return Container(
          //           padding: EdgeInsets.only(top: 10, bottom: 10),
          //           decoration: BoxDecoration(
          //             color: primary200,
          //             borderRadius: BorderRadius.only(
          //               bottomLeft: Radius.circular(size16),
          //               bottomRight: Radius.circular(size16),
          //             ),
          //           ),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceAround,
          //             children: [
          //               SizedBox(width: size24),
          //               Expanded(
          //                 child: SizedBox(
          //                   child: Text(
          //                     'Total Keseluruhan',
          //                     style:
          //                         heading4(FontWeight.w600, bnw900, 'Outfit'),
          //                   ),
          //                 ),
          //               ),
          //               // SizedBox(
          //               //   width: width,
          //               //   child: Text(
          //               //     FormatCurrency.convertToIdr(header['total'])
          //               //         .toString(),
          //               //     maxLines: 2,
          //               //     overflow: TextOverflow.ellipsis,
          //               //     style: heading4(FontWeight.w400, bnw900, 'Outfit'),
          //               //   ),
          //               // ),
          //             ],
          //           ),
          //         );
          //       }

          //       return loading();
          //     }),
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
                maxWidth:
                    MediaQuery.of(context).size.width, // ⟵ full lebar device
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
                              size32, size16, size32, size32),
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
                              Center(
                                child: dividerShowdialog(),
                              ),
                              SizedBox(height: size16),
                              Text('Rentang Waktu',
                                  style: heading2(
                                      FontWeight.w700, bnw900, 'Outfit')),
                              Text('Tentukan data yang akan tampil',
                                  style: heading4(
                                      FontWeight.w400, bnw600, 'Outfit')),
                              SizedBox(height: size24),
                              Text('Pilih Rentang Waktu',
                                  style: heading3(
                                      FontWeight.w400, bnw900, 'Outfit')),

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
                                          vertical: size12),
                                      backgroundColor: bnw100,
                                      selectedColor: primary100,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: selected ? primary500 : bnw300,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(size8),
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
                                            FontWeight.w600, bnw100, 'Outfit'),
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
                    style: heading3(
                      FontWeight.w600,
                      bnw900,
                      'Outfit',
                    ),
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
    final List<String> textvalueKeyword = [
      '1B',
      '3B',
      '6B',
      '1Y',
    ];

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
                              Center(
                                child: dividerShowdialog(),
                              ),
                              SizedBox(height: size16),
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      backgroundColor: bnw100,
                                      selectedColor: primary200,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: selected ? primary500 : bnw300,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(size8),
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
                                            () => _valueKeyword = index);
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
                                            FontWeight.w600, bnw100, 'Outfit'),
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
                    style: heading3(
                      FontWeight.w600,
                      bnw900,
                      'Outfit',
                    ),
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
                                  getLaporanPerProduk(
                                    context,
                                    widget.token,
                                    _textvalueOrderBy,
                                    _textvalueKeyword,
                                    listToko,""
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
