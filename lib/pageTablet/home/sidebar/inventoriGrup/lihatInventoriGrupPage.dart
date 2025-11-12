import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/models/inventoriModel/inventoriModel.dart';
import 'package:unipos_app_335/models/produkmodel.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoriToko/pembelianTokoPage.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/produkToko/produk.dart';
import 'package:unipos_app_335/pagehelper/loginregis/daftar_akun_toko.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/services/checkConnection.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_loading.dart';
import 'package:unipos_app_335/utils/component/component_orderBy.dart';
import 'package:unipos_app_335/utils/component/component_showModalBottom.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/skeletons.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

class LihatInventoryPageGrup extends StatefulWidget {
  String token, nameMerch, merchID;
  PageController pageController;
  LihatInventoryPageGrup({
    Key? key,
    required this.token,
    required this.nameMerch,
    required this.merchID,
    required this.pageController,
  }) : super(key: key);

  @override
  State<LihatInventoryPageGrup> createState() => _InventoriPageTestState();
}

class _InventoriPageTestState extends State<LihatInventoryPageGrup>
    with TickerProviderStateMixin {
  PageController _pageController = new PageController();
  TextEditingController searchController = TextEditingController();
  String selectedValue = 'Urutkan';
  TabController? _tabController;
  String checkFill = 'kosong';
  bool isSelectionMode = false;
  List<String>? productIdCheckAll;
  List<String> listProduct = List.empty(growable: true);
  List<ModelDataInventori>? datasProduk;
  Map<int, bool> selectedFlag = {};
  List<String> cartProductIds = [];

  TextEditingController namaBarangController = TextEditingController();
  TextEditingController satuanController = TextEditingController();

  String? idproductDetail;

  double expandedPage = 0;

  int _selectedIndex = -1;

  String jenisProduct = '', idProduct = '';

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    checkConnection(context);
    _getProductList();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        List<String> value = [''];

        await getDataProduk(value);

        setState(() {
          // log(datasProduk.toString());
          datasProduk;
        });

        _pageController = PageController(
          initialPage: 0,
          keepPage: true,
          viewportFraction: 1,
        );
      },
    );

    super.initState();
  }

  autoReload() {
    setState(() {});
  }

  Future<dynamic> getDataProduk(List<String> value) async {
    return datasProduk = await getMasterData(
      widget.token,
      widget.merchID,
      '',
      '',
    );
  }

  Timer? _debounce;

  void _onChanged(String value) {
    List<String> merchandID = [widget.merchID];
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(seconds: 2), () async {
      datasProduk = await getMasterData(
        widget.token,
        widget.merchID,
        value,
        '',
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          color: bnw100,
          // borderRadius: BorderRadius.circular(size16),
        ),
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          pageSnapping: true,
          reverse: false,
          physics: NeverScrollableScrollPhysics(),
          children: [
            getAllProduct(context, _pageController),
            tambahBahanPage(),
            ubahBahanPage(),
          ],
        ),
      ),
    );
  }

  getAllProduct(BuildContext context, PageController pageController) {
    var edgeInsets = EdgeInsets;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            widget.pageController.jumpToPage(0);
                          },
                          child: Icon(
                            PhosphorIcons.arrow_left,
                            size: size48,
                            color: bnw900,
                          ),
                        ),
                        SizedBox(width: size16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inventori',
                              style:
                                  heading1(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                            Text(
                              widget.nameMerch,
                              style:
                                  heading3(FontWeight.w300, bnw900, 'Outfit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: size16),
                    Expanded(
                      child: SizedBox(
                        child: TextField(
                          cursorColor: primary500,
                          textAlignVertical: TextAlignVertical.center,
                          controller: searchController,
                          onChanged: _onChanged,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(vertical: size12),
                            isDense: true,
                            filled: true,
                            fillColor: bnw200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(size8),
                              borderSide: BorderSide(
                                color: bnw300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(size8),
                              borderSide: BorderSide(
                                width: 2,
                                color: primary500,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(size8),
                              borderSide: BorderSide(
                                color: bnw300,
                              ),
                            ),
                            prefixIcon: Container(
                              margin:
                                  EdgeInsets.only(left: size20, right: size12),
                              child: Icon(
                                PhosphorIcons.magnifying_glass,
                                color: bnw900,
                                size: size20,
                              ),
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      searchController.text = '';
                                      initState();
                                    },
                                    child: Icon(
                                      PhosphorIcons.x_fill,
                                      size: size20,
                                      color: bnw900,
                                    ),
                                  )
                                : null,
                            hintText: 'Cari nama persediaan',
                            hintStyle:
                                heading3(FontWeight.w500, bnw400, 'Outfit'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size16),
                    GestureDetector(
                      onTap: () {
                        // refreshDataProduk();
                        _pageController.jumpToPage(1);
                      },
                      child: buttonXL(
                        Row(
                          children: [
                            Icon(PhosphorIcons.plus, color: bnw100),
                            SizedBox(width: size16),
                            Text(
                              'Bahan',
                              style:
                                  heading3(FontWeight.w600, bnw100, 'Outfit'),
                            ),
                          ],
                        ),
                        0,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TabBar(
                        controller: _tabController,
                        automaticIndicatorColorAdjustment: false,
                        indicatorColor: primary500,
                        indicatorSize: TabBarIndicatorSize.tab,
                        unselectedLabelColor: bnw600,
                        labelColor: primary500,
                        labelStyle: heading2(FontWeight.w400, bnw900, 'Outfit'),
                        physics: NeverScrollableScrollPhysics(),
                        onTap: (value) {
                          // if (value == 0) {
                          //   _pageController.animateToPage(
                          //     0,
                          //     duration: Duration(milliseconds: 10),
                          //     curve: Curves.ease,
                          //   );
                          // } else if (value == 1) {
                          //   _pageController.animateToPage(
                          //     1,
                          //     duration: Duration(milliseconds: 10),
                          //     curve: Curves.ease,
                          //   );
                          // }
                          setState(() {});
                        },
                        tabs: [
                          Tab(
                            text: 'Bahan',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: _tabController,
                          children: [
                            persediaan(context),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  SizedBox persediaan(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  orderBy(context),
                  SizedBox(width: size12),
                ],
              ),
            ],
          ),
          //! table produk
          SizedBox(height: size16),
          Expanded(
            child: Row(
              children: [
                Expanded(
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
                        child: isSelectionMode == false
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    child: GestureDetector(
                                      onTap: () {
                                        _selectAll(productIdCheckAll);
                                      },
                                      child: SizedBox(
                                        width: 50,
                                        child: Icon(
                                          isSelectionMode
                                              ? PhosphorIcons.check
                                              : PhosphorIcons.square,
                                          color: bnw100,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      child: Text(
                                        'Nama Bahan',
                                        style: heading4(
                                            FontWeight.w700, bnw100, 'Outfit'),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      child: Text(
                                        'Qty',
                                        style: heading4(
                                            FontWeight.w600, bnw100, 'Outfit'),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      child: Text(
                                        'Satuan',
                                        style: heading4(
                                            FontWeight.w600, bnw100, 'Outfit'),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Opacity(
                                    opacity: 0,
                                    child: buttonL(
                                      Row(
                                        children: [
                                          Icon(
                                            PhosphorIcons.pencil_line_fill,
                                            color: bnw900,
                                            size: size24,
                                          ),
                                          SizedBox(width: size16),
                                          Text(
                                            'Atur',
                                            style: heading3(FontWeight.w600,
                                                bnw900, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      bnw100,
                                      bnw300,
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                ],
                              )
                            : Row(
                                children: [
                                  SizedBox(
                                    child: GestureDetector(
                                      onTap: () {
                                        _selectAll(productIdCheckAll);
                                      },
                                      child: SizedBox(
                                        width: 50,
                                        child: Icon(
                                          checkFill == 'penuh'
                                              ? PhosphorIcons.check_square_fill
                                              : isSelectionMode
                                                  ? PhosphorIcons
                                                      .check_square_fill
                                                  : PhosphorIcons.square,
                                          color: bnw100,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${listProduct.length}/${datasProduk!.length} Bahan Terpilih',
                                    // 'produk terpilih',
                                    style: heading4(
                                        FontWeight.w600, bnw100, 'Outfit'),
                                  ),
                                  SizedBox(width: size8),
                                  GestureDetector(
                                    onTap: () {
                                      showBottomPilihan(
                                        context,
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  'Yakin Ingin Menghapus Produk?',
                                                  style: heading1(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                                SizedBox(height: size16),
                                                Text(
                                                  'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                  style: heading2(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: size16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        // log(dataProduk.id.toString());

                                                        // print(" hell na ${listProduct}");
                                                        deleteMasterData(
                                                          context,
                                                          widget.token,
                                                          listProduct,
                                                        ).then(
                                                          (value) {
                                                            isSelectionMode =
                                                                false;
                                                            listProduct = [];
                                                            listProduct.clear();
                                                            selectedFlag
                                                                .clear();
                                                            setState(() {});
                                                            initState();
                                                          },
                                                        );
                                                      });
                                                      initState();
                                                    },
                                                    child: buttonXLoutline(
                                                      Center(
                                                        child: Text(
                                                          'Iya, Hapus',
                                                          style: heading3(
                                                              FontWeight.w600,
                                                              primary500,
                                                              'Outfit'),
                                                        ),
                                                      ),
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                      primary500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: size12),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: buttonXL(
                                                      Center(
                                                        child: Text(
                                                          'Batalkan',
                                                          style: heading3(
                                                              FontWeight.w600,
                                                              bnw100,
                                                              'Outfit'),
                                                        ),
                                                      ),
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: buttonL(
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(PhosphorIcons.trash_fill,
                                              color: bnw900),
                                          Text(
                                            'Hapus Semua',
                                            style: heading3(FontWeight.w600,
                                                bnw900, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      bnw100,
                                      bnw300,
                                    ),
                                  ),
                                  SizedBox(width: size8),
                                ],
                              ),
                      ),
                      datasProduk == null
                          ? SkeletonCardLine()
                          : Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: primary100,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(size12),
                                    bottomRight: Radius.circular(size12),
                                  ),
                                ),
                                child: RefreshIndicator(
                                  color: bnw100,
                                  backgroundColor: primary500,
                                  onRefresh: () async {
                                    setState(() {});
                                    initState();
                                  },
                                  child: ListView.builder(
                                    // physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: datasProduk!.length,
                                    itemBuilder: (builder, index) {
                                      ModelDataInventori data =
                                          datasProduk![index];
                                      selectedFlag[index] =
                                          selectedFlag[index] ?? false;
                                      bool? isSelected = selectedFlag[index];
                                      final dataProduk = datasProduk![index];
                                      productIdCheckAll = datasProduk!
                                          .map((data) => data.id!)
                                          .toList();

                                      return GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          idproductDetail = dataProduk.id;
                                          print(idproductDetail);
                                          expandedPage =
                                              MediaQuery.of(context).size.width;

                                          if (cartProductIds
                                              .contains(dataProduk.id)) {
                                            cartProductIds.clear();
                                            expandedPage = 0;
                                          } else {
                                            cartProductIds.clear();
                                            cartProductIds.add(dataProduk.id!);
                                          }
                                          setState(() {});
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: size12),
                                          decoration: BoxDecoration(
                                            color: cartProductIds.contains(
                                                    datasProduk![index]
                                                        .id
                                                        .toString())
                                                ? primary200
                                                : null,
                                            border: Border(
                                              bottom: BorderSide(
                                                  color: bnw300, width: width1),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              InkWell(
                                                // onTap: () => onTap(isSelected, index),
                                                onTap: () {
                                                  onTap(
                                                    isSelected,
                                                    index,
                                                    dataProduk.id,
                                                  );
                                                  // log(data.nameItem.toString());
                                                  // print(dataProduk.isActive);

                                                  print(listProduct);
                                                },
                                                child: SizedBox(
                                                  width: 50,
                                                  child: _buildSelectIcon(
                                                    isSelected!,
                                                    data,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          datasProduk![index]
                                                                  .nameItem ??
                                                              '',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: size16),
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        double.parse(
                                                                datasProduk![
                                                                        index]
                                                                    .qty
                                                                    .toString())
                                                            .toInt()
                                                            .toString(),
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: heading4(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit'),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: size16),
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        datasProduk![index]
                                                                .unitName ??
                                                            '',
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: heading4(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit'),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: size16),
                                              GestureDetector(
                                                onTap: () {
                                                  showModalBottom(
                                                    context,
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height,
                                                    IntrinsicHeight(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            28.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
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
                                                                      dataProduk
                                                                          .nameItem!,
                                                                      style: heading2(
                                                                          FontWeight
                                                                              .w600,
                                                                          bnw900,
                                                                          'Outfit'),
                                                                    ),
                                                                    Text(
                                                                      dataProduk
                                                                          .unitName!,
                                                                      style: heading4(
                                                                          FontWeight
                                                                              .w400,
                                                                          bnw900,
                                                                          'Outfit'),
                                                                    ),
                                                                  ],
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  child: Icon(
                                                                    PhosphorIcons
                                                                        .x_fill,
                                                                    color:
                                                                        bnw900,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  Navigator.pop(
                                                                      context);
                                                                  whenLoading(
                                                                      context);
                                                                  getSingleMasterData(
                                                                    context,
                                                                    widget
                                                                        .token,
                                                                    dataProduk
                                                                        .id,
                                                                  ).then(
                                                                    (value) {
                                                                      namaBarangController
                                                                              .text =
                                                                          name_itemBahan;

                                                                      satuanController
                                                                              .text =
                                                                          unit_idBahan;

                                                                      value ==
                                                                              '00'
                                                                          ? _pageController
                                                                              .jumpToPage(
                                                                              2,
                                                                            )
                                                                          : null;

                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  );
                                                                });
                                                              },
                                                              behavior:
                                                                  HitTestBehavior
                                                                      .translucent,
                                                              child:
                                                                  modalBottomValue(
                                                                'Ubah Bahan',
                                                                PhosphorIcons
                                                                    .pencil_line,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                            GestureDetector(
                                                              behavior:
                                                                  HitTestBehavior
                                                                      .translucent,
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                                showBottomPilihan(
                                                                  context,
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Column(
                                                                        children: [
                                                                          Text(
                                                                            'Yakin Ingin Menghapus Bahan?',
                                                                            style: heading1(
                                                                                FontWeight.w600,
                                                                                bnw900,
                                                                                'Outfit'),
                                                                          ),
                                                                          SizedBox(
                                                                              height: size16),
                                                                          Text(
                                                                            'Data bahan yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                                            style: heading2(
                                                                                FontWeight.w400,
                                                                                bnw900,
                                                                                'Outfit'),
                                                                          ),
                                                                          SizedBox(
                                                                              height: size16),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                GestureDetector(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  // log(dataProduk.id.toString());
                                                                                  List<String> dataBahan = [
                                                                                    datasProduk![index].id.toString()
                                                                                  ];

                                                                                  setState(() {
                                                                                    deleteMasterData(
                                                                                      context,
                                                                                      widget.token,
                                                                                      dataBahan,
                                                                                    ).then(
                                                                                      (value) {
                                                                                        setState(() {});
                                                                                        initState();
                                                                                      },
                                                                                    );
                                                                                  });
                                                                                });
                                                                              },
                                                                              child: buttonXLoutline(
                                                                                Center(
                                                                                  child: Text(
                                                                                    'Iya, Hapus',
                                                                                    style: heading3(FontWeight.w600, primary500, 'Outfit'),
                                                                                  ),
                                                                                ),
                                                                                MediaQuery.of(context).size.width,
                                                                                primary500,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 12),
                                                                          Expanded(
                                                                            child:
                                                                                GestureDetector(
                                                                              onTap: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: buttonXL(
                                                                                Center(
                                                                                  child: Text(
                                                                                    'Batalkan',
                                                                                    style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                                                                                  ),
                                                                                ),
                                                                                MediaQuery.of(context).size.width,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                              child:
                                                                  modalBottomValue(
                                                                'Hapus Bahan',
                                                                PhosphorIcons
                                                                    .trash,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: buttonL(
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        PhosphorIcons
                                                            .pencil_line_fill,
                                                        color: bnw900,
                                                        size: size24,
                                                      ),
                                                      SizedBox(width: size16),
                                                      Text(
                                                        'Atur',
                                                        style: heading3(
                                                            FontWeight.w600,
                                                            bnw900,
                                                            'Outfit'),
                                                      ),
                                                    ],
                                                  ),
                                                  bnw100,
                                                  bnw300,
                                                ),
                                              ),
                                              SizedBox(width: size16)
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    // itemCount: staticData!.length,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                expandedPage != 0 ? SizedBox(width: size16) : SizedBox(),
                expandedPage == 0
                    ? Container()
                    : Expanded(
                        child: FutureBuilder(
                          future: getSingleDetailMasterData(
                            context,
                            widget.token,
                            idproductDetail!,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Map<String, dynamic> data =
                                  snapshot.data!['data'];
                              List detail = data['detail'];

                              // print('Detail: $data');

                              if (detail.isEmpty) {
                                return Center(
                                    child: Text("Data tidak tersedia"));
                              }

                              return Container(
                                padding: EdgeInsets.all(size16),
                                width: expandedPage,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(size8),
                                  border: Border.all(color: bnw300),
                                ),
                                child: ListView(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(size8),
                                              color: primary100,
                                            ),
                                            padding: EdgeInsets.all(size8),
                                            child: Icon(
                                              PhosphorIcons.archive_box_fill,
                                              color: primary500,
                                            ),
                                          ),
                                          SizedBox(width: size12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(data['item_name'],
                                                  style: heading4(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit')),
                                              Text(data['unit_abbreviation'],
                                                  style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit'))
                                            ],
                                          ),
                                          SizedBox(width: size12),
                                          VerticalDivider(
                                            color: bnw900,
                                            thickness: 1,
                                          ),
                                          SizedBox(width: size12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Qty',
                                                  style: heading4(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit')),
                                              Text(data['total_qty'].toString(),
                                                  // FormatCurrency.convertToIdr(
                                                  //         data['price'])
                                                  //     .toString(),
                                                  style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit'))
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: size12),
                                    Divider(),
                                    SizedBox(height: size12),

                                    /// Menampilkan seluruh list `detail`
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: detail.length,
                                      itemBuilder: (context, index) {
                                        final item = detail[index];

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        size8),
                                                            color: item['activity_type'] ==
                                                                    'adjustment'
                                                                ? waring500
                                                                : item['activity_type'] ==
                                                                        'purchase'
                                                                    ? green500
                                                                    : item['activity_type'] ==
                                                                            'sales'
                                                                        ? primary500
                                                                        : item['activity_type'] ==
                                                                                'starting'
                                                                            ? bnw500
                                                                            : bnw100,
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  size12),
                                                          child: Text(
                                                            capitalizeEachWord(
                                                                item['activity_type'] ??
                                                                    ''),
                                                            style: heading4(
                                                                FontWeight.w600,
                                                                bnw100,
                                                                'Outfit'),
                                                          ),
                                                        ),
                                                        // Text(' - ',
                                                        //     style: heading4(
                                                        //         FontWeight.w600,
                                                        //         bnw900,
                                                        //         'Outfit')),
                                                        // Text(
                                                        //     item['activity_type'] ??
                                                        //         '',
                                                        //     style: heading4(
                                                        //         FontWeight.w600,
                                                        //         bnw900,
                                                        //         'Outfit')),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: size12),
                                            Text(
                                              "Aktivitas: ${item['activity_date'] ?? ''} - Oleh ${item['merchant_name'] ?? ''}",
                                              style: body1(FontWeight.w300,
                                                  bnw900, 'Outfit'),
                                            ),
                                            SizedBox(height: size8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    (item['conversion_factor']) ==
                                                            null
                                                        ? "Jumlah: ${item['qty']}"
                                                        : "Jumlah: ${item['qty_converted']}",
                                                    style: body1(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit')),
                                                Text(
                                                    "Harga Satuan: ${item['price'] ?? 0}",
                                                    style: body1(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit')),
                                                Text(
                                                    "Total: ${item['total_price'] ?? 0}",
                                                    style: body1(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit')),
                                              ],
                                            ),
                                            Divider(
                                              color: bnw300,
                                              height: size16,
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    SizedBox(height: size16),

                                    /// Informasi tambahan dari `data` utama
                                    Text(
                                      "Total Jumlah: ${data['total_qty'] ?? 0}",
                                      style: heading4(
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                    Text(
                                      "Aktifitas Terakhir: ${data['lastest_activity'] ?? ''}",
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(child: Text("Terjadi kesalahan"));
                            }

                            return Center(child: CircularProgressIndicator());
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

  tambahBahanPage() {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                getDataProduk(['']);

                _pageController.jumpToPage(0);
              },
              child: Icon(
                PhosphorIcons.arrow_left,
                size: size48,
                color: bnw900,
              ),
            ),
            SizedBox(width: size16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Bahan',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Penambahan bahan - bahan dari sebuah Produk',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size16),
        Expanded(
            child: Column(
          children: [
            fieldTambahBahan(
              'Nama Barang',
              namaBarangController,
              'Matcha',
            ),
            SizedBox(height: size16),
            kategoriList(context, false),
          ],
        )),
        SizedBox(height: size16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    whenLoading(context);
                    createMasterData(
                      context,
                      widget.token,
                      widget.merchID,
                      namaBarangController.text,
                      idProduct,
                    ).then(
                      (value) {
                        if (value == "00") {
                          namaBarangController.clear();
                          satuanController.clear();
                        }
                      },
                    );
                  });
                },
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Simpan & Tambah Baru',
                      style: heading3(FontWeight.w600, primary500, 'Outfit'),
                    ),
                  ),
                  double.infinity,
                  primary500,
                ),
              ),
            ),
            SizedBox(width: size12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    // print(idProduct);
                    whenLoading(context);
                    createMasterData(
                      context,
                      widget.token,
                      widget.merchID,
                      namaBarangController.text,
                      idProduct,
                    ).then(
                      (value) {
                        value == '00' ? _pageController.jumpToPage(0) : null;
                        refreshTextfield();
                        setState(() {});
                        initState();
                      },
                    );
                  });
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Simpan',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  double.infinity,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  ubahBahanPage() {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                getDataProduk(['']);
                refreshTextfield();
                _pageController.jumpToPage(0);
              },
              child: Icon(
                PhosphorIcons.arrow_left,
                size: size48,
                color: bnw900,
              ),
            ),
            SizedBox(width: size16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubah Bahan',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Ubah bahan - bahan dari sebuah Produk',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size16),
        Expanded(
            child: Column(
          children: [
            fieldTambahBahan(
              'Nama Barang',
              namaBarangController,
              'Matcha',
            ),
            // SizedBox(height: size16),
            // kategoriList(context, false),
          ],
        )),
        SizedBox(height: size16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    // print(idProduct);
                    whenLoading(context);
                    updateMasterData(
                      context,
                      widget.token,
                      idBahan,
                      namaBarangController.text,
                    ).then(
                      (value) {
                        value == '00' ? _pageController.jumpToPage(0) : null;
                        namaBarangController.clear();
                        satuanController.clear();
                        setState(() {});
                        initState();
                      },
                    );
                  });
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Simpan',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  double.infinity,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  fieldTambahBahan(title, mycontroller, hintText) {
    return Container(
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
          IntrinsicHeight(
            child: TextFormField(
              cursorColor: primary500,
              // keyboardType: numberNo,
              style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              controller: mycontroller,
              onSaved: (value) {
                mycontroller.text = value;
                setState(() {});
              },
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: primary500,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: size12),
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.5,
                    color: bnw500,
                  ),
                ),
                hintText: 'Cth : $hintText',
                hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
              ),
            ),
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
                                    orderByProductText.length,
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
                                          label: Text(orderByProductText[index],
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
                                print(orderByProductText[valueOrderByProduct]);

                                textOrderBy =
                                    orderByProductText[valueOrderByProduct];
                                textvalueOrderBy =
                                    orderByProduct[valueOrderByProduct];
                                orderByProduct[valueOrderByProduct];
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

  void onTap(bool isSelected, int index, productId) {
    if (index >= 0 && index < selectedFlag.length) {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);

      if (selectedFlag[index] == true) {
        // Periksa apakah productId sudah ada di dalam listProduct sebelum menambahkannya
        if (!listProduct.contains(productId)) {
          listProduct.add(productId);
        }
      } else {
        // Hapus productId dari listProduct jika sudah ada
        listProduct.remove(productId);
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

  Widget _buildSelectIcon(bool isSelected, ModelDataInventori data) {
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

  void _selectAll(productId) {
    bool isFalseAvailable = selectedFlag.containsValue(false);

    selectedFlag.updateAll((key, value) => isFalseAvailable);
    setState(
      () {
        if (selectedFlag.containsValue(false)) {
          checkFill = 'kosong';
          listProduct.clear();
          isSelectionMode = selectedFlag.containsValue(false);
          isSelectionMode = selectedFlag.containsValue(true);
        } else {
          checkFill = 'penuh';
          listProduct.clear();
          listProduct.addAll(productId);
          isSelectionMode = selectedFlag.containsValue(true);
        }
      },
    );
  }

  kategoriList(BuildContext context, edit) {
    bool isKeyboardActive = false;

    return GestureDetector(
      onTap: () {
        setState(
          () {
            // log(jenisProduct.toString());
            kategoriListForm(context, isKeyboardActive);
          },
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bnw100,
          border: Border(
            bottom: BorderSide(
              width: 1.5,
              color: bnw500,
            ),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Unit/Satuan',
                    style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  Text(
                    ' *',
                    style: heading4(FontWeight.w400, red500, 'Outfit'),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: size12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      edit == true
                          ? name_itemBahan
                          : jenisProduct == ''
                              ? 'Pilih Unit/Satuan'
                              : capitalizeEachWord(jenisProduct.toString()),
                      style: heading2(FontWeight.w600,
                          jenisProduct == '' ? bnw500 : bnw900, 'Outfit'),
                    ),
                    Icon(
                      PhosphorIcons.caret_down,
                      color: bnw900,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> kategoriListForm(
      BuildContext context, bool isKeyboardActive) {
    setState(() {});
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) => FractionallySizedBox(
            heightFactor: isKeyboardActive ? 0.9 : 0.80,
            child: GestureDetector(
              onTap: () => textFieldFocusNode.unfocus(),
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                // height: MediaQuery.of(context).size.height / 1,
                decoration: BoxDecoration(
                  color: bnw100,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(size12),
                    topLeft: Radius.circular(size12),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
                  child: Column(
                    children: [
                      dividerShowdialog(),
                      SizedBox(height: size16),
                      FocusScope(
                        child: Focus(
                          onFocusChange: (value) {
                            isKeyboardActive = value;
                            setState(() {});
                          },
                          child: TextField(
                            cursorColor: primary500,
                            controller: searchController,
                            focusNode: textFieldFocusNode,
                            onChanged: (value) {
                              //   isKeyboardActive = value.isNotEmpty;
                              _runSearchProduct(value);
                              setState(() {});
                            },
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: size12),
                                isDense: true,
                                filled: true,
                                fillColor: bnw200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(size8),
                                  borderSide: BorderSide(
                                    color: bnw300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(size8),
                                  borderSide: BorderSide(
                                    width: 2,
                                    color: primary500,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(size8),
                                  borderSide: BorderSide(
                                    color: bnw300,
                                  ),
                                ),
                                suffixIcon: searchController.text.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          searchController.text = '';
                                          _runSearchProduct('');
                                          setState(() {});
                                        },
                                        child: Icon(
                                          PhosphorIcons.x_fill,
                                          size: size20,
                                          color: bnw900,
                                        ),
                                      )
                                    : null,
                                prefixIcon: Icon(
                                  PhosphorIcons.magnifying_glass,
                                  color: bnw500,
                                ),
                                hintText: 'Cari',
                                hintStyle: heading3(
                                    FontWeight.w500, bnw500, 'Outfit')),
                          ),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _getProductList();
                            setState(() {});
                            initState();
                          },
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: BouncingScrollPhysics(),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: searchResultListProduct?.length,
                            itemBuilder: (context, index) {
                              final product = searchResultListProduct?[index];
                              final isSelected = product == selectedProduct;

                              return Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: bnw300, width: width1),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: size16),
                                      title: Text(
                                        product['name'] != null
                                            ? capitalizeEachWord(
                                                product['name'].toString())
                                            : '',
                                      ),
                                      trailing: Icon(
                                        isSelected
                                            ? PhosphorIcons.radio_button_fill
                                            : PhosphorIcons.radio_button,
                                        color: isSelected ? primary500 : bnw900,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          textFieldFocusNode.unfocus();
                                          jenisProduct = product['name'];

                                          jenisProduct = product['name'];

                                          idProduct = product['id'].toString();

                                          _selectProduct(product);

                                          print(product['name']);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          autoReload();
                          Navigator.pop(context);
                        },
                        child: buttonXXL(
                          Center(
                            child: Text(
                              'Selesai',
                              style:
                                  heading2(FontWeight.w600, bnw100, 'Outfit'),
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
            ),
          ),
        );
      },
    );
  }

  refreshTextfield() {
    setState(() {
      namaBarangController.clear();
      satuanController.clear();
      idProduct = '';
      jenisProduct = '';
    });
  }

  List? typeproductList;
  List<dynamic>? searchResultListProduct;

  dynamic selectedProduct;
  bool isItemSelected = false;

  String provinceInfoUrl = '$url/api/unit';
  Future _getProductList() async {
    await http.post(Uri.parse(provinceInfoUrl), body: {
      "deviceid": identifier,
    }, headers: {
      "token": widget.token,
    }).then((response) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // log("data product $data");
        if (data != null && data['data'] != null) {
          setState(() {
            typeproductList = List<dynamic>.from(data['data']);
            searchResultListProduct = typeproductList;
          });
        }
      }
    });
  }

  void _runSearchProduct(String searchText) {
    setState(() {
      searchResultListProduct = typeproductList
          ?.where((product) => product
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void _selectProduct(dynamic product) {
    setState(() {
      log("ini product $product");
      selectedProduct = product;
      isItemSelected = true;
    });
  }
}
