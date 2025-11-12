import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/models/inventoriModel/pembelianInventoriModel.dart';
import 'package:unipos_app_335/models/produkmodel.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoriToko/inventoriTokoPage.dart';
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
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/skeletons.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import '../../../../models/inventoriModel/inventoriModel.dart';

class InventoriPageMerchantOnly extends StatefulWidget {
  String token;
  InventoriPageMerchantOnly({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<InventoriPageMerchantOnly> createState() =>
      _InventoriPageMerchantOnlyState();
}

class _InventoriPageMerchantOnlyState extends State<InventoriPageMerchantOnly>
    with TickerProviderStateMixin {
  PageController _pageController = new PageController();
  TextEditingController searchController = TextEditingController();
  String selectedValue = 'Urutkan';
  TabController? _tabController;
  String checkFill = 'kosong';
  bool isSelectionMode = false;
  List<String>? productIdCheckAll;
  List<String> listProduct = List.empty(growable: true);
  List<PembelianModel>? datasProduk;
  List<ModelDataInventori>? datasBahan;
  Map<int, bool> selectedFlag = {};
  List<String> cartProductIds = [];

  int pagesOn = 0;

  List<Map<String, String>> cartMap = [];

  double expandedPage = 0;

  int _selectedIndex = -1;

  TextEditingController tambahController = TextEditingController();
  TextEditingController namaBarangController = TextEditingController();
  TextEditingController satuanController = TextEditingController();
  TextEditingController judulPembelian = TextEditingController();
  TextEditingController judulPenyesuaian = TextEditingController();
  late TextEditingController judulEditPenyesuaian =
      TextEditingController(text: titleEdit);

  String? idproductDetail;

  DateTime? _selectedDate, _selectedDate2;
  String tanggalAwal = '', tanggalAkhir = '';

  List<Map<String, dynamic>> dataPemakaian = [];
  final Map<String, Map<String, dynamic>> selectedDataPemakaian = {};

  List<Map<String, dynamic>> orderInventory = [];

  String jenisProduct = '', idProduct = '';

  void getMasterDataTokoAndUpdateState() async {
    try {
      final result = await getMasterDataToko(
        context,
        widget.token,
        "",
        "",
        "",
      );
      setState(() {
        dataPemakaian = result;
      });
    } catch (e) {
      print("Error fetching data: $e");
      showSnackbar(context, {"message": e.toString()});
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    checkConnection(context);
    getMasterDataTokoAndUpdateState();
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
    getDataBahan(['']);
    datasBahan;

    super.initState();
  }

  autoReload() {
    setState(() {});
  }

  Future<dynamic> getDataBahan(List<String> value) async {
    return datasBahan = await getMasterData(
      widget.token,
      '',
      '',
      '',
    );
  }

  Future<dynamic> getDataProduk(List<String> value) async {
    return datasProduk = await getAdjustment(widget.token, '', '', '');
  }

  Timer? _debounce;

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(seconds: 2), () async {
      // datasTransaksi = await getProductTransaksi(
      //   context,
      //   widget.token,
      //   value,
      //   [''],
      //   textvalueOrderBy,
      // );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(size16),
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
            children: [
              getAllProduct(context, _pageController),
              tambahInventori(),
              tambahBahanPage(),
              tambahPemakaian(),
              tambahPembelian(),
              ubahBahanPage(),
              ubahPemakaian(),
            ],
          ),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventori',
                          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                        ),
                        Text(
                          nameToko ?? '',
                          style: heading3(FontWeight.w300, bnw900, 'Outfit'),
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
                        if (pagesOn == 0) {
                          _pageController.jumpToPage(2);
                        } else if (pagesOn == 1) {
                          _pageController.jumpToPage(3);
                        } else if (pagesOn == 2) {
                          _pageController.jumpToPage(4);
                        }
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => TestPageAsoy(),));
                      },
                      child: buttonXL(
                        Row(
                          children: [
                            Icon(PhosphorIcons.plus, color: bnw100),
                            SizedBox(width: size16),
                            Text(
                              pagesOn == 0
                                  ? 'Bahan'
                                  : pagesOn == 1
                                      ? 'Persediaan'
                                      : 'Pembelian',
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
                          pagesOn = value;
                          setState(() {});
                        },
                        tabs: [
                          Tab(
                            text: 'Bahan',
                          ),
                          Tab(
                            text: 'Penyesuaian',
                          ),
                          Tab(
                            text: 'Pembelian',
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
                            bahan(context),
                            persediaan(context),
                            // PemesananPage(
                            //   token: widget.token,
                            //   pageController: _pageController,
                            // ),
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
              // buttonLoutlineColor(
              //     Row(
              //       children: [
              //         Icon(
              //           PhosphorIcons.archive_box_fill,
              //           color: orange500,
              //           size: size24,
              //         ),
              //         SizedBox(width: size12),
              //         Text(
              //           'Persediaan Habis : 1',
              //           style: TextStyle(
              //             color: orange500,
              //             fontFamily: 'Outfit',
              //             fontWeight: FontWeight.w400,
              //           ),
              //         ),
              //       ],
              //     ),
              //     orange100,
              //     orange500),
            ],
          ),
          //! table produk
          SizedBox(height: size16),
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
                          children: [
                            Expanded(
                              flex: 4,
                              child: Row(
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
                                    flex: 4,
                                    child: Container(
                                      child: Text(
                                        'Judul',
                                        style: heading4(
                                            FontWeight.w700, bnw100, 'Outfit'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: Text(
                                  'Tanggal Penyesuaian',
                                  style: heading4(
                                      FontWeight.w700, bnw100, 'Outfit'),
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: Text(
                                  'Total Harga',
                                  style: heading4(
                                      FontWeight.w700, bnw100, 'Outfit'),
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
                                      style: heading3(
                                          FontWeight.w600, bnw900, 'Outfit'),
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
                                            ? PhosphorIcons.check_square_fill
                                            : PhosphorIcons.square,
                                    color: bnw100,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              '${listProduct.length}/${datasProduk!.length} Produk Terpilih',
                              // 'produk terpilih',
                              style:
                                  heading4(FontWeight.w600, bnw100, 'Outfit'),
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
                                            style: heading1(FontWeight.w600,
                                                bnw900, 'Outfit'),
                                          ),
                                          SizedBox(height: size16),
                                          Text(
                                            'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                            style: heading2(FontWeight.w400,
                                                bnw900, 'Outfit'),
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
                                                  deleteAdjustment(
                                                    context,
                                                    widget.token,
                                                    listProduct,
                                                  ).then(
                                                    (value) {
                                                      isSelectionMode = false;
                                                      listProduct = [];
                                                      listProduct.clear();
                                                      selectedFlag.clear();
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
                                      style: heading3(
                                          FontWeight.w600, bnw900, 'Outfit'),
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
                                PembelianModel data = datasProduk![index];
                                selectedFlag[index] =
                                    selectedFlag[index] ?? false;
                                bool? isSelected = selectedFlag[index];
                                final dataProduk = datasProduk![index];
                                productIdCheckAll = datasProduk!
                                    .map((data) => data.groupId!)
                                    .toList();

                                return Container(
                                  padding:
                                      EdgeInsets.symmetric(vertical: size12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: bnw300, width: width1),
                                    ),
                                  ),
                                  child: Row(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Row(
                                          children: [
                                            InkWell(
                                              // onTap: () => onTap(isSelected, index),
                                              onTap: () {
                                                onTap(
                                                  isSelected,
                                                  index,
                                                  dataProduk.groupId,
                                                );
                                                // log(data.name.toString());
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
                                            Text(
                                              datasProduk![index].title ?? '',
                                              style: heading4(FontWeight.w600,
                                                  bnw900, 'Outfit'),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          datasProduk![index].activityDate ??
                                              '',
                                          style: heading4(FontWeight.w600,
                                              bnw900, 'Outfit'),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          FormatCurrency.convertToIdr(
                                            datasProduk![index].totalPrice,
                                          ),
                                          style: heading4(FontWeight.w600,
                                              bnw900, 'Outfit'),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      GestureDetector(
                                        onTap: () {
                                          showModalBottom(
                                            context,
                                            MediaQuery.of(context).size.height,
                                            IntrinsicHeight(
                                              child: Padding(
                                                padding: EdgeInsets.all(28.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
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
                                                              datasProduk![
                                                                          index]
                                                                      .groupId ??
                                                                  '',
                                                              // dataProduk
                                                              //     .nameItem!,
                                                              style: heading2(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            Text(
                                                              datasProduk![
                                                                          index]
                                                                      .activityDate ??
                                                                  '',
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
                                                            color: bnw900,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 20),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        _pageController
                                                            .jumpToPage(6);
                                                      },
                                                      behavior: HitTestBehavior
                                                          .translucent,
                                                      child: modalBottomValue(
                                                        'Ubah Bahan',
                                                        PhosphorIcons
                                                            .pencil_line,
                                                      ),
                                                    ),
                                                    SizedBox(height: size12),
                                                    GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .translucent,
                                                      onTap: () {
                                                        Navigator.pop(context);
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
                                                                        FontWeight
                                                                            .w600,
                                                                        bnw900,
                                                                        'Outfit'),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          size16),
                                                                  Text(
                                                                    'Data bahan yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                                    style: heading2(
                                                                        FontWeight
                                                                            .w400,
                                                                        bnw900,
                                                                        'Outfit'),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          size16),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          // log(dataProduk.id.toString());
                                                                          List<String>
                                                                              dataBahan =
                                                                              [
                                                                            datasProduk![index].groupId.toString()
                                                                          ];

                                                                          String
                                                                              jsonData =
                                                                              jsonEncode(dataBahan);

                                                                          log(jsonData
                                                                              .toString());

                                                                          deleteAdjustment(
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
                                                                      },
                                                                      child:
                                                                          buttonXLoutline(
                                                                        Center(
                                                                          child:
                                                                              Text(
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
                                                                  SizedBox(
                                                                      width:
                                                                          12),
                                                                  Expanded(
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          buttonXL(
                                                                        Center(
                                                                          child:
                                                                              Text(
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
                                                      child: modalBottomValue(
                                                        'Hapus Bahan',
                                                        PhosphorIcons.trash,
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
        ],
      ),
    );
  }

  tambahInventori() {
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
                  'Pemakaian Tersedia',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Produk akan ditambahkan kedalam Toko yang telah dipilih',
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                            flex: 4,
                            child: Text(
                              'Nama Produk',
                              style:
                                  heading4(FontWeight.w700, bnw100, 'Outfit'),
                            ),
                          ),
                          SizedBox(width: size16),
                          Expanded(
                            flex: 2,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width / size8,
                                minWidth:
                                    MediaQuery.of(context).size.width / size8,
                              ),
                              child: Text(
                                'Harga Normal',
                                style:
                                    heading4(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ),
                          ),
                          SizedBox(width: size16),
                          Expanded(
                            flex: 2,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width / size8,
                                minWidth:
                                    MediaQuery.of(context).size.width / size8,
                              ),
                              child: Text(
                                'Harga Online',
                                style:
                                    heading4(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ),
                          ),
                          SizedBox(width: size16),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width / 18,
                              minWidth: MediaQuery.of(context).size.width / 18,
                            ),
                            child: Text(
                              'PPN',
                              style:
                                  heading4(FontWeight.w600, bnw100, 'Outfit'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: size16),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width / size12,
                              minWidth:
                                  MediaQuery.of(context).size.width / size12,
                            ),
                            child: Text(
                              'Tampil Kasir',
                              style:
                                  heading4(FontWeight.w600, bnw100, 'Outfit'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: size16),
                          Container(width: 96),
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
                                          ? PhosphorIcons.minus_circle_fill
                                          : PhosphorIcons.square,
                                  color: bnw100,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '${listProduct.length}/${datasProduk!.length} Produk Terpilih',
                            // 'produk terpilih',
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
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
                                          style: heading1(FontWeight.w600,
                                              bnw900, 'Outfit'),
                                        ),
                                        SizedBox(height: size16),
                                        Text(
                                          'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                          style: heading2(FontWeight.w400,
                                              bnw900, 'Outfit'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              // deleteProduk(
                                              //   context,
                                              //   widget.token,
                                              //   listProduct,
                                              //   "",
                                              // ).then(
                                              //   (value) async {
                                              //     if (value == '00') {
                                              //       refreshDataProduk();
                                              //       await Future.delayed(Duration(seconds: 1));
                                              //       conNameProduk.text = '';
                                              //       conHarga.text = '';
                                              //       idProduct = '';
                                              //       _pageController.jumpToPage(0);
                                              //       setState(() {});
                                              //       initState();
                                              //     }
                                              //   },
                                              // );
                                              // refreshDataProduk();

                                              setState(() {});
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
                                              MediaQuery.of(context).size.width,
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
                            child: buttonL(
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(PhosphorIcons.trash_fill, color: bnw900),
                                  Text(
                                    'Hapus Semua',
                                    style: heading3(
                                        FontWeight.w600, bnw900, 'Outfit'),
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
              Expanded(
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
                        padding: EdgeInsets.zero,
                        itemCount: dataPemakaian.length,
                        itemBuilder: (context, index) {
                          // Mendapatkan data dari dataPemakaian
                          final Map<String, dynamic> data =
                              dataPemakaian[index];
                          final productId = data['id'];
                          final isSelected =
                              selectedDataPemakaian.containsKey(productId);

                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: bnw300, width: 1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // Menampilkan informasi produk
                                    Expanded(
                                      flex: 4,
                                      child: Row(
                                        children: [
                                          SizedBox(width: size16),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['name'] ?? 'Nama Produk',
                                                  style: heading4(
                                                    FontWeight.w600,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  data['typeproducts'] ??
                                                      'Tipe Produk',
                                                  style: heading4(
                                                    FontWeight.w400,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: size16),
                                    // Menampilkan status pemilihan dan jumlah pemakaian
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          // Checkbox untuk memilih item
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (isSelected) {
                                                  selectedDataPemakaian
                                                      .remove(productId);
                                                } else {
                                                  selectedDataPemakaian[
                                                      productId] = {
                                                    ...data,
                                                    'quantity':
                                                        1, // Default quantity
                                                  };
                                                }
                                              });
                                            },
                                            child: Icon(
                                              isSelected
                                                  ? Icons.check_box
                                                  : Icons
                                                      .check_box_outline_blank,
                                              color: isSelected
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                          ),
                                          // TextField untuk mengatur jumlah pemakaian
                                          if (isSelected)
                                            TextField(
                                              decoration: InputDecoration(
                                                labelText: 'Jumlah',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedDataPemakaian[
                                                              productId]![
                                                          'quantity'] =
                                                      int.tryParse(value) ?? 1;
                                                });
                                              },
                                              controller: TextEditingController(
                                                text: selectedDataPemakaian[
                                                        productId]?['quantity']
                                                    .toString(),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      )),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size16),
        GestureDetector(
          onTap: () {
            showModalBottom(
              context,
              double.infinity,
              StatefulBuilder(
                builder: (context, setState) => IntrinsicHeight(
                  child: Container(
                      margin: EdgeInsets.all(size16),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Pemakaian',
                            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          Text(
                            'Pilih bahan yang sudah terpakai.',
                            style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                          ),
                          SizedBox(height: size16),
                          Container(
                            height: MediaQuery.sizeOf(context).height / 2,
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              shrinkWrap: true,
                              itemCount: 2, // Jumlah item
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        setState(() {
                                          if (_selectedIndex == index) {
                                            _selectedIndex =
                                                -1; // Jika item yang sama diklik lagi, sembunyikan TextField
                                          } else {
                                            _selectedIndex =
                                                index; // Simpan index item yang diklik
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: size16),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                print('hello world');
                                              },
                                              child: Icon(
                                                isSelectionMode
                                                    ? PhosphorIcons.check
                                                    : PhosphorIcons.square,
                                                color: bnw900,
                                              ),
                                            ),
                                            SizedBox(width: size12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Matcha',
                                                    style: heading2(
                                                        FontWeight.w600,
                                                        bnw900,
                                                        'Outfit')),
                                                Text('Kilogram',
                                                    style: heading4(
                                                        FontWeight.w600,
                                                        bnw700,
                                                        'Outfit')),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Jika index yang di klik sama dengan index item, tampilkan TextField
                                    if (_selectedIndex == index)
                                      Container(
                                        margin: EdgeInsets.only(bottom: size12),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            fillColor: primary100,
                                            labelText: 'Input something here',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          )
                        ],
                      )),
                ),
              ),
            );
          },
          child: SizedBox(
            width: double.infinity,
            child: buttonXLoutline(
              Center(
                child: Text(
                  'Tambah Pemakaian',
                  style: heading3(FontWeight.w600, primary500, 'Outfit'),
                ),
              ),
              double.infinity,
              primary500,
            ),
          ),
        ),
        SizedBox(height: size16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // print(idProduct);

                  List<String> value = [""];

                  initState();
                  setState(() {});
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Simpan Pemakaian',
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

  tambahPembelian() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      getDataProduk(['']);
                      pagesOn == 2;
                      orderInventory.clear();
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
                        'Pesanan pembelian',
                        style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
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
                            fieldTambahBahan(
                              'Judul',
                              judulPembelian,
                              'Pembelian Matcha',
                            ),
                            SizedBox(height: size16),
                            Row(
                              children: [
                                Text(
                                  'Waktu Mulai',
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                                Text(
                                  ' *',
                                  style: heading4(
                                      FontWeight.w400, red500, 'Outfit'),
                                ),
                              ],
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(2022),
                                  lastDate: DateTime(2101),
                                ).then((selectedDate) {
                                  DateTime selectedDateTime = DateTime(
                                    selectedDate!.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                  );

                                  _selectedDate = DateTime(selectedDate.year,
                                      selectedDate.month, selectedDate.day);

                                  tanggalAwal =
                                      "${selectedDateTime.year}-${selectedDateTime.month}-${selectedDateTime.day}";
                                  print(tanggalAwal);
                                  setState(() {});
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: size12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tanggalAwal == ''
                                          ? 'Pilih Tanggal'
                                          : tanggalAwal,
                                      style: heading2(
                                          FontWeight.w600,
                                          tanggalAwal == '' ? bnw500 : bnw900,
                                          'Outfit'),
                                    ),
                                    Icon(
                                      PhosphorIcons.calendar_fill,
                                      color: bnw900,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size16),
              Text(
                'Bahan yang akan dipesan',
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: size16),
              Container(
                height: 200,
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
                              // mainAxisAlignment: MainAxisAlignment.start,
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
                                  flex: 4,
                                  child: Text(
                                    'Nama Produk',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Satuan',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Jumlah',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Harga Satuan',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Total Harga',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Icon(
                                  PhosphorIcons.x_fill,
                                  color: primary500,
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
                                                    .minus_circle_fill
                                                : PhosphorIcons.square,
                                        color: bnw100,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${listProduct.length}/${datasProduk!.length} Produk Terpilih',
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
                                                style: heading1(FontWeight.w600,
                                                    bnw900, 'Outfit'),
                                              ),
                                              SizedBox(height: size16),
                                              Text(
                                                'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                style: heading2(FontWeight.w400,
                                                    bnw900, 'Outfit'),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // deleteProduk(
                                                    //   context,
                                                    //   widget.token,
                                                    //   listProduct,
                                                    //   "",
                                                    // ).then(
                                                    //   (value) async {
                                                    //     if (value == '00') {
                                                    //       refreshDataProduk();
                                                    //       await Future.delayed(Duration(seconds: 1));
                                                    //       conNameProduk.text = '';
                                                    //       conHarga.text = '';
                                                    //       idProduct = '';
                                                    //       _pageController.jumpToPage(0);
                                                    //       setState(() {});
                                                    //       initState();
                                                    //     }
                                                    //   },
                                                    // );
                                                    // refreshDataProduk();

                                                    setState(() {});
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
                    Container(
                      // width: double.infinity,
                      decoration: BoxDecoration(
                        color: primary100,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(size12),
                          bottomRight: Radius.circular(size12),
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: orderInventory.length,
                        itemBuilder: (context, index) {
                          // Mendapatkan data dari dataPemakaian
                          final Map<String, dynamic> data =
                              orderInventory[index];
                          final productId = data['id'];
                          final isSelected =
                              selectedDataPemakaian.containsKey(productId);

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: size12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: bnw300, width: 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  // onTap: () => onTap(isSelected, index),
                                  onTap: () {
                                    onTap(
                                      isSelected,
                                      index,
                                      productId,
                                    );
                                    // log(data.name.toString());
                                    // print(dataProduk.isActive);

                                    print(listProduct);
                                  },
                                  child: SizedBox(
                                    width: 50,
                                    child: _buildSelectIconInventori(
                                      isSelected!,
                                      data,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data['name'] ?? '',
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data['category'] ?? '',
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data['qty'].toString(),
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data['price'].toString(),
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    FormatCurrency.convertToIdr(
                                        (data['price'] * data['qty'])),
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                GestureDetector(
                                  onTap: () {
                                    orderInventory.removeAt(index);
                                    setState(() {});
                                  },
                                  child: Icon(
                                    PhosphorIcons.x_fill,
                                    color: red500,
                                  ),
                                ),
                                SizedBox(width: size16),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size16),
            ],
          ),
        ),
        SizedBox(height: size16),
        GestureDetector(
          onTap: () {
            showModalBottom(
              context,
              double.infinity,
              StatefulBuilder(
                builder: (context, setState) => IntrinsicHeight(
                  child: Container(
                      margin: EdgeInsets.all(size16),
                      padding: EdgeInsets.all(size12),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Pemakaian',
                            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          Text(
                            'Pilih bahan yang sudah terpakai.',
                            style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                          ),
                          SizedBox(height: size16),
                          Container(
                            height: MediaQuery.sizeOf(context).height / 1.8,
                            child: dataPemakaian.isEmpty
                                ? Center(
                                    child: Text(
                                      'Bahan tidak ditemukan.',
                                      style: heading3(
                                          FontWeight.w400, bnw500, 'Outfit'),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: dataPemakaian.length,
                                    itemBuilder: (context, index) {
                                      final item = dataPemakaian[index];
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return Column(
                                            children: [
                                              ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Checkbox(
                                                  activeColor: primary500,
                                                  value: selectedDataPemakaian
                                                      .containsKey(item['id']),
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      if (value == true) {
                                                        selectedDataPemakaian[
                                                            item['id']] = {
                                                          "inventory_master_id":
                                                              item['id'],
                                                          "name":
                                                              item['name_item'],
                                                          "category":
                                                              item['unit_name'],
                                                          "qty": 0,
                                                          "price": 0,
                                                        };
                                                      } else {
                                                        selectedDataPemakaian
                                                            .remove(item['id']);
                                                      }
                                                    });
                                                  },
                                                ),
                                                title: Text(
                                                  item['name_item'] ?? '',
                                                  style: heading2(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                                subtitle: Text(
                                                  item['unit_name'] ?? '',
                                                  style: heading4(
                                                      FontWeight.w400,
                                                      bnw700,
                                                      'Outfit'),
                                                ),
                                                trailing: Icon(
                                                    selectedDataPemakaian
                                                            .containsKey(
                                                                item['id'])
                                                        ? Icons.expand_less
                                                        : Icons.expand_more),
                                                onTap: () {
                                                  setState(() {
                                                    if (selectedDataPemakaian
                                                        .containsKey(
                                                            item['id'])) {
                                                      selectedDataPemakaian
                                                          .remove(item['id']);
                                                    } else {
                                                      selectedDataPemakaian[
                                                          item['id']] = {
                                                        "inventory_master_id":
                                                            item['id'],
                                                        "name":
                                                            item['name_item'],
                                                        "category":
                                                            item['unit_name'],
                                                        "qty": 0,
                                                        "price": 0,
                                                      };
                                                    }
                                                  });
                                                },
                                              ),
                                              if (selectedDataPemakaian
                                                  .containsKey(item['id']))
                                                Container(
                                                  padding:
                                                      EdgeInsets.all(size8),
                                                  decoration: BoxDecoration(
                                                    color: primary100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size8),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Jumlah Pesanan ',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          Text(
                                                            '*',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                danger500,
                                                                'Outfit'),
                                                          ),
                                                        ],
                                                      ),
                                                      TextField(
                                                        decoration:
                                                            InputDecoration(
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: 2,
                                                                    color:
                                                                        primary500,
                                                                  ),
                                                                ),
                                                                focusColor:
                                                                    primary500,
                                                                hintText:
                                                                    'Cth : 10',
                                                                hintStyle:
                                                                    heading2(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw400,
                                                                  'Outfit',
                                                                )),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) {
                                                          selectedDataPemakaian[
                                                                  item['id']]![
                                                              'qty'] = int
                                                                  .tryParse(
                                                                      value) ??
                                                              0;
                                                        },
                                                      ),
                                                      SizedBox(height: size12),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Harga Satuan ',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          Text(
                                                            '*',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                danger500,
                                                                'Outfit'),
                                                          ),
                                                        ],
                                                      ),
                                                      TextField(
                                                        decoration:
                                                            InputDecoration(
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: 2,
                                                                    color:
                                                                        primary500,
                                                                  ),
                                                                ),
                                                                focusColor:
                                                                    primary500,
                                                                hintText:
                                                                    'Cth : Rp 10.000',
                                                                hintStyle:
                                                                    heading2(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw400,
                                                                  'Outfit',
                                                                )),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) {
                                                          selectedDataPemakaian[
                                                                  item['id']]![
                                                              'price'] = int
                                                                  .tryParse(
                                                                      value) ??
                                                              0;
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                          SizedBox(height: size16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: buttonXLoutline(
                                    Center(
                                      child: Text(
                                        'Batal',
                                        style: heading3(FontWeight.w600,
                                            primary500, 'Outfit'),
                                      ),
                                    ),
                                    double.infinity,
                                    primary500,
                                  ),
                                ),
                              ),
                              SizedBox(width: size16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      orderInventory =
                                          selectedDataPemakaian.values.toList();

                                      dataPemakaian = orderInventory;
                                      print("Saved Data: $orderInventory");
                                    });
                                    Navigator.pop(context);
                                    initState();
                                  },
                                  child: buttonXL(
                                    Center(
                                      child: Text(
                                        'Simpan',
                                        style: heading3(
                                            FontWeight.w600, bnw100, 'Outfit'),
                                      ),
                                    ),
                                    double.infinity,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                ),
              ),
            );
          },
          child: SizedBox(
            width: double.infinity,
            child: buttonXLoutline(
              Center(
                child: Text(
                  'Tambah Bahan',
                  style: heading3(FontWeight.w600, primary500, 'Outfit'),
                ),
              ),
              double.infinity,
              primary500,
            ),
          ),
        ),
        SizedBox(height: size16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    createPembelian(
                      context,
                      widget.token,
                      tanggalAwal,
                      judulPembelian.text,
                      orderInventory,
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
            SizedBox(width: size16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  createPembelian(
                    context,
                    widget.token,
                    tanggalAwal,
                    judulPembelian.text,
                    orderInventory,
                  ).then(
                    (value) {
                      if (value == '00') {
                        getDataProduk(['']);
                        pagesOn == 2;
                        tanggalAwal = '';
                        orderInventory.clear();
                        _pageController.jumpToPage(0);
                        judulPembelian.clear();

                        setState(() {});
                        initState();
                      }
                    },
                  );
                  print(orderInventory);
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

  tambahPemakaian() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      getDataProduk(['']);
                      pagesOn == 1;
                      orderInventory.clear();
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
                        'Tambah Pemesanan',
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        'Pesanan penyesuaian',
                        style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size16),
              fieldTambahBahan(
                'Judul',
                judulPenyesuaian,
                'Penyesuaian Matcha',
              ),
              SizedBox(height: size16),
              Container(
                height: 200,
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
                              // mainAxisAlignment: MainAxisAlignment.start,
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
                                  flex: 4,
                                  child: Text(
                                    'Nama Produk',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Satuan',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Jumlah',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Harga Satuan',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Total Harga',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Icon(
                                  PhosphorIcons.x_fill,
                                  color: primary500,
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
                                                    .minus_circle_fill
                                                : PhosphorIcons.square,
                                        color: bnw100,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${listProduct.length}/${datasProduk!.length} Produk Terpilih',
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
                                                style: heading1(FontWeight.w600,
                                                    bnw900, 'Outfit'),
                                              ),
                                              SizedBox(height: size16),
                                              Text(
                                                'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                style: heading2(FontWeight.w400,
                                                    bnw900, 'Outfit'),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // deleteProduk(
                                                    //   context,
                                                    //   widget.token,
                                                    //   listProduct,
                                                    //   "",
                                                    // ).then(
                                                    //   (value) async {
                                                    //     if (value == '00') {
                                                    //       refreshDataProduk();
                                                    //       await Future.delayed(Duration(seconds: 1));
                                                    //       conNameProduk.text = '';
                                                    //       conHarga.text = '';
                                                    //       idProduct = '';
                                                    //       _pageController.jumpToPage(0);
                                                    //       setState(() {});
                                                    //       initState();
                                                    //     }
                                                    //   },
                                                    // );
                                                    // refreshDataProduk();

                                                    setState(() {});
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
                    Container(
                      // width: double.infinity,
                      decoration: BoxDecoration(
                        color: primary100,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(size12),
                          bottomRight: Radius.circular(size12),
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: orderInventory.length,
                        itemBuilder: (context, index) {
                          // Mendapatkan data dari dataPemakaian
                          final Map<String, dynamic> data =
                              orderInventory[index];
                          final productId = data['id'];
                          final isSelected =
                              selectedDataPemakaian.containsKey(productId);

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: size12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: bnw300, width: 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  // onTap: () => onTap(isSelected, index),
                                  onTap: () {
                                    onTap(
                                      isSelected,
                                      index,
                                      productId,
                                    );
                                    // log(data.name.toString());
                                    // print(dataProduk.isActive);

                                    print(listProduct);
                                  },
                                  child: SizedBox(
                                    width: 50,
                                    child: _buildSelectIconInventori(
                                      isSelected!,
                                      data,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data['name'] ?? '',
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data['category'] ?? '',
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data['qty'].toString(),
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data['price'].toString(),
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    FormatCurrency.convertToIdr(
                                        (data['price'] * data['qty'])),
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                GestureDetector(
                                  onTap: () {
                                    orderInventory.removeAt(index);
                                    setState(() {});
                                  },
                                  child: Icon(
                                    PhosphorIcons.x_fill,
                                    color: red500,
                                  ),
                                ),
                                SizedBox(width: size16),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size16),
            ],
          ),
        ),
        SizedBox(height: size16),
        GestureDetector(
          onTap: () {
            showModalBottom(
              context,
              double.infinity,
              StatefulBuilder(
                builder: (context, setState) => IntrinsicHeight(
                  child: Container(
                      margin: EdgeInsets.all(size16),
                      padding: EdgeInsets.all(size12),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Pemakaian',
                            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          Text(
                            'Pilih bahan yang sudah terpakai.',
                            style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                          ),
                          SizedBox(height: size16),
                          Container(
                            height: MediaQuery.sizeOf(context).height / 1.8,
                            child: dataPemakaian.isEmpty
                                ? Center(
                                    child: Text(
                                      'Bahan tidak ditemukan.',
                                      style: heading3(
                                          FontWeight.w400, bnw500, 'Outfit'),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: dataPemakaian.length,
                                    itemBuilder: (context, index) {
                                      final item = dataPemakaian[index];
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return Column(
                                            children: [
                                              ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Checkbox(
                                                  activeColor: primary500,
                                                  value: selectedDataPemakaian
                                                      .containsKey(item['id']),
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      if (value == true) {
                                                        selectedDataPemakaian[
                                                            item['id']] = {
                                                          "inventory_master_id":
                                                              item['id'],
                                                          "name":
                                                              item['name_item'],
                                                          "category":
                                                              item['unit_name'],
                                                          "qty": 0,
                                                          "price": 0,
                                                        };
                                                      } else {
                                                        selectedDataPemakaian
                                                            .remove(item['id']);
                                                      }
                                                    });
                                                  },
                                                ),
                                                title: Text(
                                                  item['name_item'] ?? '',
                                                  style: heading2(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                                subtitle: Text(
                                                  item['unit_name'] ?? '',
                                                  style: heading4(
                                                      FontWeight.w400,
                                                      bnw700,
                                                      'Outfit'),
                                                ),
                                                trailing: Icon(
                                                    selectedDataPemakaian
                                                            .containsKey(
                                                                item['id'])
                                                        ? Icons.expand_less
                                                        : Icons.expand_more),
                                                onTap: () {
                                                  setState(() {
                                                    if (selectedDataPemakaian
                                                        .containsKey(
                                                            item['id'])) {
                                                      selectedDataPemakaian
                                                          .remove(item['id']);
                                                    } else {
                                                      selectedDataPemakaian[
                                                          item['id']] = {
                                                        "inventory_master_id":
                                                            item['id'],
                                                        "name":
                                                            item['name_item'],
                                                        "category":
                                                            item['unit_name'],
                                                        "qty": 0,
                                                        "price": 0,
                                                      };
                                                    }
                                                  });
                                                },
                                              ),
                                              if (selectedDataPemakaian
                                                  .containsKey(item['id']))
                                                Container(
                                                  padding:
                                                      EdgeInsets.all(size8),
                                                  decoration: BoxDecoration(
                                                    color: primary100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size8),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Jumlah Pesanan ',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          Text(
                                                            '*',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                danger500,
                                                                'Outfit'),
                                                          ),
                                                        ],
                                                      ),
                                                      TextField(
                                                        decoration:
                                                            InputDecoration(
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: 2,
                                                                    color:
                                                                        primary500,
                                                                  ),
                                                                ),
                                                                focusColor:
                                                                    primary500,
                                                                hintText:
                                                                    'Cth : 10',
                                                                hintStyle:
                                                                    heading2(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw400,
                                                                  'Outfit',
                                                                )),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) {
                                                          selectedDataPemakaian[
                                                                  item['id']]![
                                                              'qty'] = int
                                                                  .tryParse(
                                                                      value) ??
                                                              0;
                                                        },
                                                      ),
                                                      SizedBox(height: size12),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Harga Satuan ',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          Text(
                                                            '*',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                danger500,
                                                                'Outfit'),
                                                          ),
                                                        ],
                                                      ),
                                                      TextField(
                                                        decoration:
                                                            InputDecoration(
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: 2,
                                                                    color:
                                                                        primary500,
                                                                  ),
                                                                ),
                                                                focusColor:
                                                                    primary500,
                                                                hintText:
                                                                    'Cth : Rp 10.000',
                                                                hintStyle:
                                                                    heading2(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw400,
                                                                  'Outfit',
                                                                )),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) {
                                                          selectedDataPemakaian[
                                                                  item['id']]![
                                                              'price'] = int
                                                                  .tryParse(
                                                                      value) ??
                                                              0;
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                          SizedBox(height: size16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: buttonXLoutline(
                                    Center(
                                      child: Text(
                                        'Batal',
                                        style: heading3(FontWeight.w600,
                                            primary500, 'Outfit'),
                                      ),
                                    ),
                                    double.infinity,
                                    primary500,
                                  ),
                                ),
                              ),
                              SizedBox(width: size16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      orderInventory =
                                          selectedDataPemakaian.values.toList();

                                      dataPemakaian = orderInventory;
                                      print("Saved Data: $orderInventory");
                                    });
                                    Navigator.pop(context);
                                    initState();
                                  },
                                  child: buttonXL(
                                    Center(
                                      child: Text(
                                        'Simpan',
                                        style: heading3(
                                            FontWeight.w600, bnw100, 'Outfit'),
                                      ),
                                    ),
                                    double.infinity,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                ),
              ),
            );
          },
          child: SizedBox(
            width: double.infinity,
            child: buttonXLoutline(
              Center(
                child: Text(
                  'Tambah Pemakaian',
                  style: heading3(FontWeight.w600, primary500, 'Outfit'),
                ),
              ),
              double.infinity,
              primary500,
            ),
          ),
        ),
        SizedBox(height: size16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  createPenyesuaian(
                    context,
                    widget.token,
                    tanggalAwal,
                    judulPenyesuaian.text,
                    orderInventory,
                  ).then(
                    (value) {
                      if (value == '00') {
                        _pageController.jumpToPage(0);
                        orderInventory.clear();
                        tanggalAwal = '';
                        setState(() {});
                        initState();
                      }
                    },
                  );
                  print(orderInventory);
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

  ubahPemakaian() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      getDataProduk(['']);
                      pagesOn == 1;
                      orderInventory.clear();
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
                        'Ubah Pemesanan',
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        'Pesanan penyesuaian',
                        style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size16),
              fieldTambahBahan(
                'Judul',
                judulEditPenyesuaian,
                'Penyesuaian Matcha',
              ),
              SizedBox(height: size16),
              Container(
                height: 200,
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
                              // mainAxisAlignment: MainAxisAlignment.start,
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
                                  flex: 4,
                                  child: Text(
                                    'Nama Produk',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Satuan',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Jumlah',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Harga Satuan',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Total Harga',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Icon(
                                  PhosphorIcons.x_fill,
                                  color: primary500,
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
                                                    .minus_circle_fill
                                                : PhosphorIcons.square,
                                        color: bnw100,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${listProduct.length}/${datasProduk!.length} Produk Terpilih',
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
                                                style: heading1(FontWeight.w600,
                                                    bnw900, 'Outfit'),
                                              ),
                                              SizedBox(height: size16),
                                              Text(
                                                'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                style: heading2(FontWeight.w400,
                                                    bnw900, 'Outfit'),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // deleteProduk(
                                                    //   context,
                                                    //   widget.token,
                                                    //   listProduct,
                                                    //   "",
                                                    // ).then(
                                                    //   (value) async {
                                                    //     if (value == '00') {
                                                    //       refreshDataProduk();
                                                    //       await Future.delayed(Duration(seconds: 1));
                                                    //       conNameProduk.text = '';
                                                    //       conHarga.text = '';
                                                    //       idProduct = '';
                                                    //       _pageController.jumpToPage(0);
                                                    //       setState(() {});
                                                    //       initState();
                                                    //     }
                                                    //   },
                                                    // );
                                                    // refreshDataProduk();

                                                    setState(() {});
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
                    Container(
                      // width: double.infinity,
                      decoration: BoxDecoration(
                        color: primary100,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(size12),
                          bottomRight: Radius.circular(size12),
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: orderInventoryEdit.length,
                        itemBuilder: (context, index) {
                          // Mendapatkan data dari dataPemakaian
                          final Map<String, dynamic> data =
                              orderInventoryEdit[index];
                          final productId = data['id'];
                          final isSelected =
                              selectedDataPemakaian.containsKey(productId);

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: size12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: bnw300, width: 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  // onTap: () => onTap(isSelected, index),
                                  onTap: () {
                                    onTap(
                                      isSelected,
                                      index,
                                      productId,
                                    );
                                    // log(data.name.toString());
                                    // print(dataProduk.isActive);

                                    print(listProduct);
                                  },
                                  child: SizedBox(
                                    width: 50,
                                    child: _buildSelectIconInventori(
                                      isSelected!,
                                      data,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data['name'] ?? '',
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data['category'] ?? '',
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data['qty'].toString(),
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data['price'].toString(),
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    FormatCurrency.convertToIdr(
                                        (data['price'] * data['qty'])),
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size16),
                                GestureDetector(
                                  onTap: () {
                                    orderInventory.removeAt(index);
                                    setState(() {});
                                  },
                                  child: Icon(
                                    PhosphorIcons.x_fill,
                                    color: red500,
                                  ),
                                ),
                                SizedBox(width: size16),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size16),
            ],
          ),
        ),
        SizedBox(height: size16),
        GestureDetector(
          onTap: () {
            showModalBottom(
              context,
              double.infinity,
              StatefulBuilder(
                builder: (context, setState) => IntrinsicHeight(
                  child: Container(
                      margin: EdgeInsets.all(size16),
                      padding: EdgeInsets.all(size12),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Pemakaian',
                            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          Text(
                            'Pilih bahan yang sudah terpakai.',
                            style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                          ),
                          SizedBox(height: size16),
                          Container(
                            height: MediaQuery.sizeOf(context).height / 1.8,
                            child: dataPemakaian.isEmpty
                                ? Center(
                                    child: Text(
                                      'Bahan tidak ditemukan.',
                                      style: heading3(
                                          FontWeight.w400, bnw500, 'Outfit'),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: dataPemakaian.length,
                                    itemBuilder: (context, index) {
                                      final item = dataPemakaian[index];
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return Column(
                                            children: [
                                              ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Checkbox(
                                                  activeColor: primary500,
                                                  value: selectedDataPemakaian
                                                      .containsKey(item['id']),
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      if (value == true) {
                                                        selectedDataPemakaian[
                                                            item['id']] = {
                                                          "inventory_master_id":
                                                              item['id'],
                                                          "name":
                                                              item['name_item'],
                                                          "category":
                                                              item['unit_name'],
                                                          "qty": 0,
                                                          "price": 0,
                                                        };
                                                      } else {
                                                        selectedDataPemakaian
                                                            .remove(item['id']);
                                                      }
                                                    });
                                                  },
                                                ),
                                                title: Text(
                                                  item['name_item'] ?? '',
                                                  style: heading2(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                                subtitle: Text(
                                                  item['unit_name'] ?? '',
                                                  style: heading4(
                                                      FontWeight.w400,
                                                      bnw700,
                                                      'Outfit'),
                                                ),
                                                trailing: Icon(
                                                    selectedDataPemakaian
                                                            .containsKey(
                                                                item['id'])
                                                        ? Icons.expand_less
                                                        : Icons.expand_more),
                                                onTap: () {
                                                  setState(() {
                                                    if (selectedDataPemakaian
                                                        .containsKey(
                                                            item['id'])) {
                                                      selectedDataPemakaian
                                                          .remove(item['id']);
                                                    } else {
                                                      selectedDataPemakaian[
                                                          item['id']] = {
                                                        "inventory_master_id":
                                                            item['id'],
                                                        "name":
                                                            item['name_item'],
                                                        "category":
                                                            item['unit_name'],
                                                        "qty": 0,
                                                        "price": 0,
                                                      };
                                                    }
                                                  });
                                                },
                                              ),
                                              if (selectedDataPemakaian
                                                  .containsKey(item['id']))
                                                Container(
                                                  padding:
                                                      EdgeInsets.all(size8),
                                                  decoration: BoxDecoration(
                                                    color: primary100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size8),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Jumlah Pesanan ',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          Text(
                                                            '*',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                danger500,
                                                                'Outfit'),
                                                          ),
                                                        ],
                                                      ),
                                                      TextField(
                                                        decoration:
                                                            InputDecoration(
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: 2,
                                                                    color:
                                                                        primary500,
                                                                  ),
                                                                ),
                                                                focusColor:
                                                                    primary500,
                                                                hintText:
                                                                    'Cth : 10',
                                                                hintStyle:
                                                                    heading2(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw400,
                                                                  'Outfit',
                                                                )),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) {
                                                          selectedDataPemakaian[
                                                                  item['id']]![
                                                              'qty'] = int
                                                                  .tryParse(
                                                                      value) ??
                                                              0;
                                                        },
                                                      ),
                                                      SizedBox(height: size12),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Harga Satuan ',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          Text(
                                                            '*',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                danger500,
                                                                'Outfit'),
                                                          ),
                                                        ],
                                                      ),
                                                      TextField(
                                                        decoration:
                                                            InputDecoration(
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: 2,
                                                                    color:
                                                                        primary500,
                                                                  ),
                                                                ),
                                                                focusColor:
                                                                    primary500,
                                                                hintText:
                                                                    'Cth : Rp 10.000',
                                                                hintStyle:
                                                                    heading2(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw400,
                                                                  'Outfit',
                                                                )),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) {
                                                          selectedDataPemakaian[
                                                                  item['id']]![
                                                              'price'] = int
                                                                  .tryParse(
                                                                      value) ??
                                                              0;
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                          SizedBox(height: size16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: buttonXLoutline(
                                    Center(
                                      child: Text(
                                        'Batal',
                                        style: heading3(FontWeight.w600,
                                            primary500, 'Outfit'),
                                      ),
                                    ),
                                    double.infinity,
                                    primary500,
                                  ),
                                ),
                              ),
                              SizedBox(width: size16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      orderInventoryEdit =
                                          selectedDataPemakaian.values.toList();

                                      dataPemakaian = orderInventoryEdit;
                                      print("Saved Data: $orderInventoryEdit");
                                    });
                                    Navigator.pop(context);
                                    initState();
                                  },
                                  child: buttonXL(
                                    Center(
                                      child: Text(
                                        'Simpan',
                                        style: heading3(
                                            FontWeight.w600, bnw100, 'Outfit'),
                                      ),
                                    ),
                                    double.infinity,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                ),
              ),
            );
          },
          child: SizedBox(
            width: double.infinity,
            child: buttonXLoutline(
              Center(
                child: Text(
                  'Tambah Pemakaian',
                  style: heading3(FontWeight.w600, primary500, 'Outfit'),
                ),
              ),
              double.infinity,
              primary500,
            ),
          ),
        ),
        SizedBox(height: size16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  createPenyesuaian(
                    context,
                    widget.token,
                    tanggalAwal,
                    judulPenyesuaian.text,
                    orderInventoryEdit,
                  ).then(
                    (value) {
                      if (value == '00') {
                        _pageController.jumpToPage(0);
                        orderInventoryEdit.clear();
                        tanggalAwal = '';
                        setState(() {});
                        initState();
                      }
                    },
                  );
                  print(orderInventoryEdit);
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
            kategoriList(context),
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
                      '',
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
                      '',
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

  fieldTambah(title, mycontroller, hintText) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: heading4(FontWeight.w500, bnw900, 'Outfit'),
              ),
              Text(
                ' *',
                style: heading4(FontWeight.w700, red500, 'Outfit'),
              ),
            ],
          ),
          TextFormField(
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
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: size12),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: bnw500,
                ),
              ),
              hintText: hintText,
              hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
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

  SizedBox bahan(BuildContext context) {
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
                                    '${listProduct.length}/${datasBahan!.length} Bahan Terpilih',
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
                      datasBahan == null
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
                                    itemCount: datasBahan!.length ?? 0,
                                    itemBuilder: (builder, index) {
                                      ModelDataInventori data =
                                          datasBahan![index];
                                      selectedFlag[index] =
                                          selectedFlag[index] ?? false;
                                      bool? isSelected = selectedFlag[index];
                                      final dataProduk = datasBahan![index];
                                      productIdCheckAll = datasBahan!
                                          .map((data) => data.id!)
                                          .toList();

                                      return GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          idproductDetail = dataProduk.id;
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
                                                    datasBahan![index]
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
                                                  child: _buildSelectIconBahan(
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
                                                          datasBahan![index]
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
                                                        datasBahan![index]
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
                                                                              5,
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
                                                                                // print(datasBahan![index].id.toString());
                                                                                List<String> dataBahan = [
                                                                                  datasBahan![index].id.toString()
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

                              return Container(
                                padding: EdgeInsets.all(size16),
                                width: expandedPage,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(size8),
                                  border: Border.all(color: bnw300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ListView(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics: BouncingScrollPhysics(),
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size8),
                                                      color: primary100,
                                                    ),
                                                    padding:
                                                        EdgeInsets.all(size8),
                                                    child: Icon(
                                                      PhosphorIcons
                                                          .archive_box_fill,
                                                      color: primary500,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(width: size12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    detail[0]['item_name'] ??
                                                        '',
                                                    style: heading4(
                                                        FontWeight.w600,
                                                        bnw900,
                                                        'Outfit'),
                                                  ),
                                                  Text(
                                                    detail[0]['unit_name'] ??
                                                        '',
                                                    style: heading4(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size16),
                                          Container(
                                            padding:
                                                EdgeInsets.only(bottom: size12),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: bnw900,
                                                  width: width1,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        right: BorderSide(
                                                          color: bnw900,
                                                          width: width1,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Jumlah",
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        Text(
                                                          double.parse(detail[0]
                                                                      ['qty']
                                                                  .toString())
                                                              .toInt()
                                                              .toString(),
                                                          style: heading4(
                                                              FontWeight.w600,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // SizedBox(width: size12),
                                                // Expanded(
                                                //   child: Column(
                                                //     crossAxisAlignment:
                                                //         CrossAxisAlignment
                                                //             .start,
                                                //     children: [
                                                //       Text(
                                                //         "Harga Per Item",
                                                //         style: heading4(
                                                //             FontWeight.w400,
                                                //             bnw900,
                                                //             'Outfit'),
                                                //       ),
                                                //       Text(
                                                //         double.parse(detail[0][
                                                //                     'qty_after_activity']
                                                //                 .toString())
                                                //             .toInt()
                                                //             .toString(),
                                                //         style: heading4(
                                                //             FontWeight.w600,
                                                //             bnw900,
                                                //             'Outfit'),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: size16),
                                          Text(
                                            "Riwayat Persediaan",
                                            style: heading3(FontWeight.w600,
                                                bnw900, 'Outfit'),
                                          ),
                                          SizedBox(height: size16),
                                          orderBy(context),
                                          SizedBox(height: size16),
                                          Container(
                                            padding: EdgeInsets.all(size8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(size8),
                                              border: Border.all(color: bnw300),
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      bottom: size8),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: bnw300,
                                                        width: width1,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      size8),
                                                          color: bnw200,
                                                        ),
                                                        padding: EdgeInsets.all(
                                                            size8),
                                                        child: Icon(
                                                          PhosphorIcons
                                                              .file_text_fill,
                                                          color: bnw900,
                                                        ),
                                                      ),
                                                      SizedBox(width: size12),
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              detail[0][
                                                                      'activity_date'] ??
                                                                  '',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            Text(
                                                              'Oleh ${detail[0]['merchant_name']}',
                                                              style: body1(
                                                                FontWeight.w300,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: size12),
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: size16,
                                                          vertical: size4,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: waring100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      size8),
                                                        ),
                                                        child: Text(
                                                          data[
                                                              'lastest_activity'],
                                                          style: heading4(
                                                              FontWeight.w600,
                                                              waring500,
                                                              'Outfit'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: size16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Jumlah',
                                                      style: body1(
                                                          FontWeight.w400,
                                                          bnw800,
                                                          'Outfit'),
                                                    ),
                                                    Text(
                                                      data['total_qty']
                                                          .toString(),
                                                      style: body1(
                                                          FontWeight.w400,
                                                          bnw800,
                                                          'Outfit'),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: size4),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Harga Satuan',
                                                      style: body1(
                                                          FontWeight.w400,
                                                          bnw800,
                                                          'Outfit'),
                                                    ),
                                                    Text(
                                                      data['price'].toString(),
                                                      style: body1(
                                                          FontWeight.w400,
                                                          bnw800,
                                                          'Outfit'),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: size4),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Total Harga',
                                                      style: heading4(
                                                          FontWeight.w600,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                    Text(
                                                      data['price'].toString(),
                                                      style: heading4(
                                                          FontWeight.w600,
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
                                    SizedBox(height: size8),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasError) {
                              // return Text("Error: ${snapshot.error}");
                              return Center(child: loading());
                            }
                            return Center(child: loading());
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
            // fieldTambahBahan(
            //   'Satuan',
            //   satuanController,
            //   'Kilogram, Gram, Miligram',
            // ),
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

  kategoriList(BuildContext context) {
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
                    'Kategori',
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
                      jenisProduct == ''
                          ? 'Pilih Kategori'
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

  Widget _buildSelectIcon(bool isSelected, PembelianModel data) {
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

  Widget _buildSelectIconBahan(bool isSelected, ModelDataInventori data) {
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

  Widget _buildSelectIconInventori(bool isSelected, data) {
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
