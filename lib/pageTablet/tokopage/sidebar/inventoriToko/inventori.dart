import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:unipos_app_335/models/inventoriModel/detailPembelianModel.dart';
import 'package:unipos_app_335/models/inventoriModel/inventoriModel.dart';
import 'package:unipos_app_335/models/inventoriModel/pembelianInventoriModel.dart';
import 'package:unipos_app_335/models/inventoriModel/penyesuaianInventoriModel.dart';
import 'package:unipos_app_335/models/inventoriModel/unitConvertionModel.dart';
import 'package:unipos_app_335/models/produkmodel.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoriToko/inventoriTokoPage.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoriToko/pembelianTokoPage.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoriToko/ubahPenyesuaianPageToko.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoriToko/ubahPersediaanTokoPage.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoriToko/ubahProdukMaterial.dart';
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

import '../../../../models/inventoriModel/bomModel.dart';

class InventoriPageTest extends StatefulWidget {
  String token;
  InventoriPageTest({Key? key, required this.token}) : super(key: key);

  @override
  State<InventoriPageTest> createState() => _InventoriPageTestState();
}

class _InventoriPageTestState extends State<InventoriPageTest>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  //! bagain bom
  List<UnitConvertionModel> unitList = [];
  UnitConvertionModel? selectedUnit;
  TextEditingController unitController = TextEditingController();
  TextEditingController searchProductID = TextEditingController();

  TextEditingController tambahController = TextEditingController();
  TextEditingController judulPembelian = TextEditingController();
  TextEditingController tambahProdukCon = TextEditingController();
  TextEditingController judulPenyesuaian = TextEditingController();

  FocusNode focusNodeHarga = FocusNode();
  FocusNode focusNodeQty = FocusNode();

  TextEditingController nameConController = TextEditingController();
  TextEditingController faktorCon = TextEditingController();

  int conFactor = 0;

  //! bagian inven
  PageController _pageController = new PageController();
  TextEditingController searchController = TextEditingController();
  String selectedValue = 'Urutkan';
  TabController? _tabController;
  String checkFill = 'kosong';
  bool isSelectionMode = false;
  List<String>? productIdCheckAll;
  List<String>? productIdCheckAllPenyesuaian;
  List<String> listProduct = List.empty(growable: true);

  List<PenyesuaianModel>? datasProduk;
  List<BOMModel>? datasProdukBOM;
  List<UnitConvertionModel>? datasProdukUnit;

  List<PembelianModel>? datasProdukPemesanan;
  List<ModelDataInventori>? datasBahan;
  Map<int, bool> selectedFlag = {};
  List<String> cartProductIds = [];

  String unitIdUbah = '';

  int pagesOn = 0;

  String? idproductDetail;

  List<Map<String, String>> cartMap = [];

  double expandedPage = 0;

  int _selectedIndex = -1;

  DateTime? _selectedDate, _selectedDate2;
  String tanggalAwal = '', tanggalAkhir = '';

  List<Map<String, dynamic>> dataPemakaian = [];
  final Map<String, Map<String, dynamic>> selectedDataPemakaian = {};

  List<Map<String, dynamic>> orderInventory = [];

  void fetchUnits() async {
    List<UnitConvertionModel> units = await getUnitConvertion(
      widget.token,
      '',
      '',
      '',
    );
    setState(() {
      unitList = units;
    });
  }

  void getMasterDataTokoAndUpdateState() async {
    try {
      final result = await getMasterDataToko(context, widget.token, "", "", "");
      setState(() {
        dataPemakaian = result;
      });
    } catch (e) {
      print("Error fetching data: $e");
      showSnackbar(context, {"message": e.toString()});
    }
  }

  //! bagian bom
  // void getMasterDataTokoAndUpdateState() async {
  //   try {
  //     final result = await getMasterDataToko(
  //       context,
  //       widget.token,
  //       "",
  //     );
  //     setState(() {
  //       dataPemakaian = result;
  //     });
  //   } catch (e) {
  //     print("Error fetching data: $e");
  //     showSnackbar(context, {"message": e.toString()});
  //   }
  // }

  // void fetchUnits() async {
  //   List<UnitConvertionModel> units =
  //       await getUnitConvertion(widget.token, '', '', '');
  //   setState(() {
  //     unitList = units;
  //   });
  // }

  // void fetchBOMSingle(id) async {
  //   final details = await getSingleBOM(widget.token, '', id, context).then(
  //     (value) {
  //       Future.delayed(Duration(seconds: 1)).then((value) {
  //         _pageController.jumpToPage(9);
  //         initState();
  //       });
  //     },
  //   );

  //   dataPemakaian = details.map((detail) {
  //     return {
  //       'id': detail['inventory_master_id'],
  //       'name_item': detail['item_name'],
  //       'unit_name': detail['unit_name'],
  //     };
  //   }).toList();

  //   // Jika ingin langsung checklist juga:
  //   for (var detail in details) {
  //     selectedDataPemakaian[detail['inventory_master_id']] = {
  //       "inventory_master_id": detail['inventory_master_id'],
  //       "unit": detail['unit_name'],
  //       "qty": detail['qty'] ?? 0,
  //       "unit_conversion_id": '',
  //     };
  //   }

  //   setState(() {}); // untuk render ulang jika di dalam StatefulWidget
  // }

  Future<dynamic> getDataProduk(List<String> value) async {
    return datasProdukBOM = await getBOM(widget.token, '', '', '');
  }

  Future<dynamic> getUnit(List<String> value) async {
    log('getUnit dipanggil');
    final result = await getUnitConvertion(widget.token, '', '', '');
    log('Hasil getUnitConvertion = $result');
    return datasProdukUnit = result;
  }

  Timer? _debounce;

  Future<void> _onChanged(String value) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(seconds: 2), () async {
      datasProdukBOM = await getBOM(
        widget.token,
        "",
        value,
        textvalueOrderByBahan,
      );
      setState(() {});
    });
  }

  Future<void> _onChangedBahan(String value) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(seconds: 2), () async {
      datasBahan = await getMasterData(
        widget.token,
        "",
        value,
        textvalueOrderByBahan,
      );
      setState(() {});
    });
  }

  List<TextEditingController> qtyController = [];
  List<TextEditingController> hargaSatuanControllers = [];
  List<TextEditingController> textController = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: _currentIndex,
      length: 5,
      vsync: this,
    );

    checkConnection(context);
    getMasterDataTokoAndUpdateState();
    fetchUnits();
    getDataProdukAdjustment(['']);
    getUnit(['']);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      List<String> value = [''];

      await getDatabahan(value);
      getDataProdukPemesanan(value);
      getDataProduk(value);

      setState(() {
        // log(datasProduk.toString());
        datasProduk;
        datasProdukPemesanan;
        datasProdukUnit;
      });

      _pageController = PageController(
        initialPage: 0,
        keepPage: true,
        viewportFraction: 1,
      );
    });

    qtyController = List.generate(
      dataPemakaian.length,
      (index) => TextEditingController(),
    );
    hargaSatuanControllers = List.generate(
      dataPemakaian.length,
      (index) => TextEditingController(),
    );
    textController = List.generate(
      dataPemakaian.length,
      (index) => TextEditingController(text: '-'),
    );

    initializeControllers();
    _tabController!.addListener(() {
      // Gunakan index langsung (bukan hanya saat indexIsChanging)
      setState(() {
        _currentIndex = _tabController!.index;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in hargaSatuanControllers) {
      controller.dispose();
    }
    for (var controller in qtyController) {
      controller.dispose();
    }
    for (var controller in textController) {
      controller.dispose();
    }
    super.dispose();
  }

  void initializeControllers() {
    for (int i = 0; i < dataPemakaian.length; i++) {
      qtyController[i].text = dataPemakaian[i]['qty']?.toString() ?? '0';
      hargaSatuanControllers[i].text =
          dataPemakaian[i]['price']?.toString() ?? '0';
      textController[i].text = dataPemakaian[i]['unit'] ?? '-';
    }
  }

  void addNewItem() {
    setState(() {
      hargaSatuanControllers.add(TextEditingController());
      qtyController.add(TextEditingController());
      textController.add(TextEditingController(text: '-'));
    });
  }

  refreshPage() {
    List<String> value = [''];

    getDatabahan(value);
    getDataProdukPemesanan(value);
    getDataProduk(value);

    setState(() {
      // log(datasProduk.toString());
      datasProduk;
      datasProdukPemesanan;
    });
  }

  refreshController() {
    judulPembelian.clear();
    judulPenyesuaian.clear();
    qtyController.clear();
    // hargaSatuanController.clear();
    setState(() {});
  }

  Future<dynamic> getDataProdukAdjustment(List<String> value) async {
    return datasProduk = await getAdjustment(widget.token, '', '', '');
  }

  Future<dynamic> getDataProdukPemesanan(List<String> value) async {
    return datasProdukPemesanan = await getPembelian(widget.token, '', '', '');
  }

  Future<dynamic> getDatabahan(List<String> value) async {
    return datasBahan = await getMasterData(widget.token, '', '', '');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showModalBottomExit(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        // resizeToAvoidBottomInset: false,
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
                tambahPembelian(),
                tambahPemakaian(),
                UbahPersediaanPage(
                  token: widget.token,
                  pageController: _pageController,
                  groupId: groupIdInventoryUbah ?? '',
                ),
                UbahPenyesuaianToko(
                  token: widget.token,
                  pageController: _pageController,
                  groupId: groupIdInventoryUbah ?? '',
                ),
                tambahProdukMaterial(),
                tambahUnitConvertion(),
                ubahUnitConvertion(),
                // ubahProdukMaterial(),
                UbahProdukMaterial(
                  token: widget.token,
                  groupId: productMaterialIdUbah ?? '',
                  pageController: _pageController,
                ),
              ],
            ),
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
                    pagesOn == 0 || pagesOn == 3
                        ? Expanded(
                            child: SizedBox(
                              child: TextField(
                                cursorColor: primary500,
                                textAlignVertical: TextAlignVertical.center,
                                controller: searchController,
                                onChanged: (value) {
                                  // print('Search value: $value');
                                  pagesOn == 0
                                      ? _onChangedBahan(value)
                                      : pagesOn == 3
                                      ? _onChanged(value)
                                      : null;
                                  // _onChangedBahan(value);
                                  // _onChanged(value);
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: size12,
                                  ),
                                  isDense: true,
                                  filled: true,
                                  fillColor: bnw200,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(size8),
                                    borderSide: BorderSide(color: bnw300),
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
                                    borderSide: BorderSide(color: bnw300),
                                  ),
                                  prefixIcon: Container(
                                    margin: EdgeInsets.only(
                                      left: size20,
                                      right: size12,
                                    ),
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
                                  hintText: pagesOn == 0
                                      ? 'Cari nama bahan'
                                      : pagesOn == 3
                                      ? 'Cari nama produk'
                                      : '',
                                  hintStyle: heading3(
                                    FontWeight.w500,
                                    bnw400,
                                    'Outfit',
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Spacer(),
                    SizedBox(width: size16),
                    pagesOn == 0
                        ? SizedBox()
                        : GestureDetector(
                            onTap: () {
                              qtyController.clear();
                              print(_currentIndex);
                              refreshController();
                              selectedDataPemakaian.clear();
                              tanggalAwal = '';
                              if (pagesOn == 1) {
                                _pageController.jumpToPage(2);
                              } else if (pagesOn == 2) {
                                _pageController.jumpToPage(3);
                              } else if (pagesOn == 3) {
                                _pageController.jumpToPage(6);
                              } else if (pagesOn == 4) {
                                _pageController.jumpToPage(7);
                              }

                              // pagesOn == 0
                              //     ? _pageController.jumpToPage(2)
                              //     : _pageController.jumpToPage(3);
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => TestPageAsoy(),));
                            },
                            child: buttonXL(
                              Row(
                                children: [
                                  Icon(PhosphorIcons.plus, color: bnw100),
                                  SizedBox(width: size16),
                                  Text(
                                    pagesOn == 1
                                        ? 'Persediaan'
                                        : pagesOn == 2
                                        ? 'Sesuaikan'
                                        : pagesOn == 3
                                        ? 'Produk Material'
                                        : pagesOn == 4
                                        ? 'Unit Convertion'
                                        : '',
                                    style: heading3(
                                      FontWeight.w600,
                                      bnw100,
                                      'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                              0,
                            ),
                          ),
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
                          // isSelectionMode = false;
                          // listProduct.clear();
                          // productIdCheckAll = [];
                          // selectedDataPemakaian.clear();
                          tanggalAwal = '';
                          setState(() {});
                        },
                        tabs: [
                          Tab(text: 'Bahan'),
                          Tab(text: 'Persediaan'),
                          Tab(text: 'Sesuaikan'),
                          Tab(text: 'Produk Material'),
                          Tab(text: 'Unit Convertion'),
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
                            // PemesananPage(
                            //   token: widget.token,
                            //   pageController: _pageController,
                            // ),
                            bahan(context),
                            pemesanan(context),
                            persediaan(context),
                            produkmaterial(context),
                            unitConversion(context),
                          ],
                        ),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(width: size16),
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: Text(
                                  'Nama Bahan',
                                  style: heading4(
                                    FontWeight.w700,
                                    bnw100,
                                    'Outfit',
                                  ),
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
                                    FontWeight.w600,
                                    bnw100,
                                    'Outfit',
                                  ),
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
                                    FontWeight.w600,
                                    bnw100,
                                    'Outfit',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
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
                                    refreshPage();
                                    // initState();
                                  },
                                  child: ListView.builder(
                                    // physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: datasBahan!.length,
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
                                          print(idproductDetail);
                                          expandedPage = MediaQuery.of(
                                            context,
                                          ).size.width;

                                          if (cartProductIds.contains(
                                            dataProduk.id,
                                          )) {
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
                                            vertical: size12,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                cartProductIds.contains(
                                                  datasBahan![index].id
                                                      .toString(),
                                                )
                                                ? primary200
                                                : null,
                                            border: Border(
                                              bottom: BorderSide(
                                                color: bnw300,
                                                width: width1,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(width: size16),
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
                                                            'Outfit',
                                                          ),
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
                                                          datasBahan![index].qty
                                                              .toString(),
                                                        ).toStringAsFixed(2),
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
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
                                                          'Outfit',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: size16),
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
                                  child: Text("Data tidak tersedia"),
                                );
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
                                              Text(
                                                data['item_name'],
                                                style: heading4(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              Text(
                                                data['unit_abbreviation'],
                                                style: heading4(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
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
                                              Text(
                                                'Qty',
                                                style: heading4(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              Text(
                                                data['total_qty'].toString(),
                                                // FormatCurrency.convertToIdr(
                                                //         data['price'])
                                                //     .toString(),
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
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  size8,
                                                                ),
                                                            color:
                                                                item['activity_type'] ==
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
                                                                size12,
                                                              ),
                                                          child: Text(
                                                            capitalizeEachWord(
                                                              item['activity_type'] ??
                                                                  '',
                                                            ),
                                                            style: heading4(
                                                              FontWeight.w600,
                                                              bnw100,
                                                              'Outfit',
                                                            ),
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
                                              style: body1(
                                                FontWeight.w300,
                                                bnw900,
                                                'Outfit',
                                              ),
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
                                                    'Outfit',
                                                  ),
                                                ),
                                                Text(
                                                  "Harga Satuan: ${item['price'] ?? 0}",
                                                  style: body1(
                                                    FontWeight.w400,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                                Text(
                                                  "Total: ${item['total_price'] ?? 0}",
                                                  style: body1(
                                                    FontWeight.w400,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
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
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                    Text(
                                      "Aktifitas Terakhir: ${data['lastest_activity'] ?? ''}",
                                      style: heading4(
                                        FontWeight.w400,
                                        bnw900,
                                        'Outfit',
                                      ),
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
                  // orderBy(context),
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
                                        _selectAll(
                                          productIdCheckAllPenyesuaian,
                                        );
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
                                          FontWeight.w700,
                                          bnw100,
                                          'Outfit',
                                        ),
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
                                    FontWeight.w700,
                                    bnw100,
                                    'Outfit',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            // Expanded(
                            //   flex: 4,
                            //   child: Container(
                            //     child: Text(
                            //       'Total Harga',
                            //       style: heading4(
                            //           FontWeight.w700, bnw100, 'Outfit'),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(width: size16),
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
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                                bnw100,
                                bnw300,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            SizedBox(
                              child: GestureDetector(
                                onTap: () {
                                  _selectAll(productIdCheckAllPenyesuaian);
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
                              style: heading4(
                                FontWeight.w600,
                                bnw100,
                                'Outfit',
                              ),
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
                                              'Outfit',
                                            ),
                                          ),
                                          SizedBox(height: size16),
                                          Text(
                                            'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                            style: heading2(
                                              FontWeight.w400,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: size16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                deleteAdjustment(
                                                  context,
                                                  widget.token,
                                                  listProduct,
                                                ).then((value) {
                                                  setState(() {});
                                                  initState();
                                                });

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
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ),
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
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
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ),
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
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
                                    Icon(
                                      PhosphorIcons.trash_fill,
                                      color: bnw900,
                                    ),
                                    Text(
                                      'Hapus Semua',
                                      style: heading3(
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
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
                              refreshPage();
                            },
                            child: ListView.builder(
                              // physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: datasProduk!.length,
                              itemBuilder: (builder, index) {
                                PenyesuaianModel data = datasProduk![index];
                                selectedFlag[index] =
                                    selectedFlag[index] ?? false;
                                bool? isSelected = selectedFlag[index];
                                final dataProduk = datasProduk![index];
                                productIdCheckAllPenyesuaian = datasProduk!
                                    .map((data) => data.groupId!)
                                    .toList();

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: size12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: bnw300,
                                        width: width1,
                                      ),
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
                                            Flexible(
                                              child: Text(
                                                datasProduk![index].title ?? '',
                                                style: heading4(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
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
                                          style: heading4(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // SizedBox(width: size16),
                                      // Expanded(
                                      //   flex: 4,
                                      //   child: Text(
                                      //     FormatCurrency.convertToIdr(
                                      //       datasProduk![index].totalPrice,
                                      //     ),
                                      //     style: heading4(FontWeight.w600,
                                      //         bnw900, 'Outfit'),
                                      //     maxLines: 3,
                                      //     overflow: TextOverflow.ellipsis,
                                      //   ),
                                      // ),
                                      // SizedBox(width: size16),
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
                                                              datasProduk![index]
                                                                      .title ??
                                                                  '',
                                                              // dataProduk
                                                              //     .nameItem!,
                                                              style: heading2(
                                                                FontWeight.w600,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            Text(
                                                              datasProduk![index]
                                                                      .activityDate ??
                                                                  '',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        GestureDetector(
                                                          onTap: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: Icon(
                                                            PhosphorIcons
                                                                .x_fill,
                                                            color: bnw900,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size24),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);

                                                        groupIdInventoryUbah =
                                                            datasProduk![index]
                                                                .groupId
                                                                .toString();

                                                        print(
                                                          groupIdInventoryUbah,
                                                        );

                                                        // print(
                                                        //     groupIdInventoryUbah);

                                                        getSelectedDataPenyesuaian(
                                                          context,
                                                          widget.token,
                                                          datasProduk![index]
                                                              .groupId
                                                              .toString(),
                                                        ).then((value) {
                                                          Future.delayed(
                                                            Duration(
                                                              seconds: 1,
                                                            ),
                                                          ).then(
                                                            (value) =>
                                                                _pageController
                                                                    .jumpToPage(
                                                                      5,
                                                                    ),
                                                          );

                                                          setState(() {});
                                                        });
                                                        setState(() {});
                                                      },
                                                      behavior: HitTestBehavior
                                                          .translucent,
                                                      child: modalBottomValue(
                                                        'Ubah Penyesuaian',
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
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        size16,
                                                                  ),
                                                                  Text(
                                                                    'Data bahan yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                                    style: heading2(
                                                                      FontWeight
                                                                          .w400,
                                                                      bnw900,
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        size16,
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        setState(() {
                                                                          // log(dataProduk.id.toString());
                                                                          List<
                                                                            String
                                                                          >
                                                                          dataBahan = [
                                                                            datasProduk![index].groupId.toString(),
                                                                          ];

                                                                          String
                                                                          jsonData = jsonEncode(
                                                                            dataBahan,
                                                                          );

                                                                          log(
                                                                            jsonData.toString(),
                                                                          );

                                                                          deleteAdjustment(
                                                                            context,
                                                                            widget.token,
                                                                            dataBahan,
                                                                          ).then((
                                                                            value,
                                                                          ) {
                                                                            setState(() {
                                                                              isSelectionMode = false;
                                                                              listProduct = [];
                                                                              listProduct.clear();
                                                                              selectedFlag.clear();
                                                                            });
                                                                            initState();
                                                                            initState();
                                                                          });
                                                                        });
                                                                      },
                                                                      child: buttonXLoutline(
                                                                        Center(
                                                                          child: Text(
                                                                            'Iya, Hapus',
                                                                            style: heading3(
                                                                              FontWeight.w600,
                                                                              primary500,
                                                                              'Outfit',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width,
                                                                        primary500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  Expanded(
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                      },
                                                                      child: buttonXL(
                                                                        Center(
                                                                          child: Text(
                                                                            'Batalkan',
                                                                            style: heading3(
                                                                              FontWeight.w600,
                                                                              bnw100,
                                                                              'Outfit',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width,
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
                                                        'Hapus Penyesuaian',
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
                                                style: heading3(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
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

  SizedBox pemesanan(context) {
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
                  // orderBy(context),
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
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  Container(
                                    child: Text(
                                      'Judul',
                                      style: heading4(
                                        FontWeight.w700,
                                        bnw100,
                                        'Outfit',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: Text(
                                  'Tanggal Pembelian',
                                  style: heading4(
                                    FontWeight.w700,
                                    bnw100,
                                    'Outfit',
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: Text(
                                  'Total Harga',
                                  style: heading4(
                                    FontWeight.w700,
                                    bnw100,
                                    'Outfit',
                                  ),
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
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                                bnw100,
                                bnw300,
                              ),
                            ),
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
                              '${listProduct.length}/${datasProdukPemesanan!.length} Produk Terpilih',
                              // 'produk terpilih',
                              style: heading4(
                                FontWeight.w600,
                                bnw100,
                                'Outfit',
                              ),
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
                                              'Outfit',
                                            ),
                                          ),
                                          SizedBox(height: size16),
                                          Text(
                                            'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                            style: heading2(
                                              FontWeight.w400,
                                              bnw900,
                                              'Outfit',
                                            ),
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
                                                  deletePembelian(
                                                    context,
                                                    widget.token,
                                                    listProduct,
                                                  ).then((value) {
                                                    setState(() {
                                                      isSelectionMode = false;
                                                      listProduct = [];
                                                      listProduct.clear();
                                                      selectedFlag.clear();
                                                    });
                                                    initState();
                                                  });
                                                });

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
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ),
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
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
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ),
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
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
                                    Icon(
                                      PhosphorIcons.trash_fill,
                                      color: bnw900,
                                    ),
                                    Text(
                                      'Hapus Semua',
                                      style: heading3(
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
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
                datasProdukPemesanan == null
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
                              refreshPage();
                              // initState();
                            },
                            child: ListView.builder(
                              // physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: datasProdukPemesanan!.length,
                              itemBuilder: (builder, index) {
                                PembelianModel data =
                                    datasProdukPemesanan![index];
                                selectedFlag[index] =
                                    selectedFlag[index] ?? false;
                                bool? isSelected = selectedFlag[index];
                                final dataProduk = datasProdukPemesanan![index];
                                productIdCheckAll = datasProdukPemesanan!
                                    .map((data) => data.groupId!)
                                    .toList();

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: size12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: bnw300,
                                        width: width1,
                                      ),
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
                                            Flexible(
                                              child: Text(
                                                datasProdukPemesanan![index]
                                                        .title ??
                                                    '',
                                                style: heading4(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          datasProdukPemesanan![index]
                                                  .activityDate ??
                                              '',
                                          style: heading4(
                                            FontWeight.w600,
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
                                            datasProdukPemesanan![index]
                                                .totalPrice,
                                          ),
                                          style: heading4(
                                            FontWeight.w600,
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
                                                              datasProdukPemesanan![index]
                                                                      .title ??
                                                                  '',
                                                              // dataProduk
                                                              //     .nameItem!,
                                                              style: heading2(
                                                                FontWeight.w600,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            Text(
                                                              datasProdukPemesanan![index]
                                                                      .activityDate ??
                                                                  '',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        GestureDetector(
                                                          onTap: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: Icon(
                                                            PhosphorIcons
                                                                .x_fill,
                                                            color: bnw900,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size24),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        groupIdInventoryUbah =
                                                            datasProdukPemesanan![index]
                                                                .groupId
                                                                .toString();

                                                        getDetailPembelian(
                                                          context,
                                                          widget.token,
                                                          datasProdukPemesanan![index]
                                                              .groupId
                                                              .toString(),
                                                        ).then((value) {
                                                          Future.delayed(
                                                            Duration(
                                                              seconds: 1,
                                                            ),
                                                          ).then(
                                                            (value) =>
                                                                _pageController
                                                                    .jumpToPage(
                                                                      4,
                                                                    ),
                                                          );
                                                        });

                                                        // Future.delayed(Duration(
                                                        //         seconds: 2))
                                                        //     .then((value) => widget
                                                        //         .pageController
                                                        //         .jumpToPage(4));
                                                        setState(() {});
                                                      },
                                                      behavior: HitTestBehavior
                                                          .translucent,
                                                      child: modalBottomValue(
                                                        'Ubah Persediaan',
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
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        size16,
                                                                  ),
                                                                  Text(
                                                                    'Data bahan yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                                    style: heading2(
                                                                      FontWeight
                                                                          .w400,
                                                                      bnw900,
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        size16,
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        setState(() {
                                                                          List<
                                                                            String
                                                                          >
                                                                          dataBahan = [
                                                                            datasProdukPemesanan![index].groupId.toString(),
                                                                          ];
                                                                          deletePembelian(
                                                                            context,
                                                                            widget.token,
                                                                            dataBahan,
                                                                          ).then((
                                                                            value,
                                                                          ) {
                                                                            setState(() {
                                                                              isSelectionMode = false;
                                                                              listProduct = [];
                                                                              listProduct.clear();
                                                                              selectedFlag.clear();
                                                                            });
                                                                            // initState();
                                                                          });
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
                                                                              'Outfit',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width,
                                                                        primary500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  Expanded(
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                      },
                                                                      child: buttonXL(
                                                                        Center(
                                                                          child: Text(
                                                                            'Batalkan',
                                                                            style: heading3(
                                                                              FontWeight.w600,
                                                                              bnw100,
                                                                              'Outfit',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width,
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
                                                        'Hapus Persediaan',
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
                                                style: heading3(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
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
                              style: heading4(
                                FontWeight.w700,
                                bnw100,
                                'Outfit',
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
                                'Harga Normal',
                                style: heading4(
                                  FontWeight.w600,
                                  bnw100,
                                  'Outfit',
                                ),
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
                                style: heading4(
                                  FontWeight.w600,
                                  bnw100,
                                  'Outfit',
                                ),
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
                              style: heading4(
                                FontWeight.w600,
                                bnw100,
                                'Outfit',
                              ),
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
                              style: heading4(
                                FontWeight.w600,
                                bnw100,
                                'Outfit',
                              ),
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
                                          style: heading1(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        SizedBox(height: size16),
                                        Text(
                                          'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                          style: heading2(
                                            FontWeight.w400,
                                            bnw900,
                                            'Outfit',
                                          ),
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
                                                    'Outfit',
                                                  ),
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
                                                    'Outfit',
                                                  ),
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
                                      FontWeight.w600,
                                      bnw900,
                                      'Outfit',
                                    ),
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
                      // initState();
                      refreshPage();
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: dataPemakaian.length,
                      itemBuilder: (context, index) {
                        // Mendapatkan data dari dataPemakaian
                        final Map<String, dynamic> data = dataPemakaian[index];
                        final productId = data['id'];
                        final isSelected = selectedDataPemakaian.containsKey(
                          productId,
                        );

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
                                                overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                                selectedDataPemakaian.remove(
                                                  productId,
                                                );
                                              } else {
                                                selectedDataPemakaian[productId] =
                                                    {
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
                                                : Icons.check_box_outline_blank,
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
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedDataPemakaian[productId]!['quantity'] =
                                                    int.tryParse(value) ?? 1;
                                              });
                                            },
                                            controller: TextEditingController(
                                              text:
                                                  selectedDataPemakaian[productId]?['quantity']
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
                    ),
                  ),
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
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
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
                                              Text(
                                                'Matcha',
                                                style: heading2(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              Text(
                                                'Kilogram',
                                                style: heading4(
                                                  FontWeight.w600,
                                                  bnw700,
                                                  'Outfit',
                                                ),
                                              ),
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
                        ),
                      ],
                    ),
                  ),
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
        ),
      ],
    );
  }

  tambahPembelian() {
    return Form(
      key: _formKey,
      child: Column(
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
                        orderInventory.clear();
                        // pagesOn = 0;
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
                          'Tambah Persediaan',
                          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                        ),
                        Text(
                          'Persediaan',
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
                            bottom: BorderSide(width: 1.5, color: bnw500),
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
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                  Text(
                                    ' *',
                                    style: heading4(
                                      FontWeight.w400,
                                      red500,
                                      'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate:
                                        _selectedDate ?? DateTime.now(),
                                    firstDate: DateTime(2022),
                                    lastDate: DateTime(2101),
                                  ).then((selectedDate) {
                                    DateTime selectedDateTime = DateTime(
                                      selectedDate!.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                    );

                                    _selectedDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                    );

                                    tanggalAwal =
                                        "${selectedDateTime.year}-${selectedDateTime.month}-${selectedDateTime.day}";
                                    print(tanggalAwal);
                                    setState(() {});
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: size12,
                                  ),
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
                                          'Outfit',
                                        ),
                                      ),
                                      Icon(
                                        PhosphorIcons.calendar_fill,
                                        color: bnw900,
                                      ),
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
                  'Persediaan yang akan dipesan',
                  style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                ),
                SizedBox(height: size8),
                Text(
                  '*Jika jumlah bahan (qty) bernilai negatif, maka saat ditambahkan ke dalam persediaan, perhitungannya akan dimulai dari nol, bukan dari nilai negatif.',
                  style: heading4(FontWeight.w700, waring500, 'Outfit'),
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
                                  Opacity(
                                    opacity: 0,
                                    child: SizedBox(
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
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Nama Produk',
                                      style: heading4(
                                        FontWeight.w700,
                                        bnw100,
                                        'Outfit',
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Satuan',
                                      style: heading4(
                                        FontWeight.w700,
                                        bnw100,
                                        'Outfit',
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Jumlah',
                                      style: heading4(
                                        FontWeight.w700,
                                        bnw100,
                                        'Outfit',
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Harga Satuan',
                                      style: heading4(
                                        FontWeight.w700,
                                        bnw100,
                                        'Outfit',
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Total Harga',
                                      style: heading4(
                                        FontWeight.w700,
                                        bnw100,
                                        'Outfit',
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Icon(PhosphorIcons.x_fill, color: primary500),
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
                                    style: heading4(
                                      FontWeight.w600,
                                      bnw100,
                                      'Outfit',
                                    ),
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
                                                    'Outfit',
                                                  ),
                                                ),
                                                SizedBox(height: size16),
                                                Text(
                                                  'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                  style: heading2(
                                                    FontWeight.w400,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
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
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ),
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width,
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
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ),
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width,
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
                                          Icon(
                                            PhosphorIcons.trash_fill,
                                            color: bnw900,
                                          ),
                                          Text(
                                            'Hapus Semua',
                                            style: heading3(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
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
                            // physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: orderInventory.length,
                            itemBuilder: (context, index) {
                              // Mendapatkan data dari dataPemakaian
                              final Map<String, dynamic> data =
                                  orderInventory[index];
                              final productId = data['id'];
                              final isSelected = selectedDataPemakaian
                                  .containsKey(productId);

                              // print('dataku : $data');

                              return Container(
                                margin: EdgeInsets.symmetric(vertical: size12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: bnw300, width: 1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Opacity(
                                      opacity: 0,
                                      child: InkWell(
                                        // onTap: () => onTap(isSelected, index),
                                        onTap: () {
                                          // print('onTap called $data');
                                          // onTap(
                                          //   isSelected,
                                          //   index,
                                          //   productId,
                                          // );
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
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        data['unit'] ?? '',
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
                                        data['unit_name'] ?? '',
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
                                          (double.tryParse(
                                                    data['price']
                                                        .toString()
                                                        .replaceAll(',', ''),
                                                  ) ??
                                                  0) *
                                              (num.tryParse(
                                                    data['qty'].toString(),
                                                  ) ??
                                                  0),
                                        ).toString(),
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
                                        var removedItem = orderInventory[index];
                                        var itemId =
                                            removedItem['inventory_master_id'];
                                        selectedDataPemakaian.remove(itemId);
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
              if (selectedDataPemakaian.isEmpty) {
                selectedDataPemakaian.clear();
              }
              qtyController = List.generate(
                dataPemakaian.length,
                (index) => TextEditingController(),
              );
              hargaSatuanControllers = List.generate(
                dataPemakaian.length,
                (index) => TextEditingController(),
              );
              textController = List.generate(
                dataPemakaian.length,
                (index) => TextEditingController(text: '-'),
              );

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
                                        FontWeight.w400,
                                        bnw500,
                                        'Outfit',
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(
                                        context,
                                      ).viewInsets.bottom,
                                    ),
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
                                                      // print(
                                                      // "tapped ${unitList[index].id}");
                                                      // print(
                                                      //     'Checkbox changed: ${item['unit_name']}');
                                                      if (value == true) {
                                                        selectedDataPemakaian[item['id']] = {
                                                          "inventory_master_id":
                                                              item['id'],
                                                          "unit":
                                                              item['name_item'],
                                                          "qty": 0,
                                                          "unit_conversion_id":
                                                              item['unit_conversion_id'],
                                                          // unitList[index]
                                                          //     .id
                                                          //     .toString(),
                                                          "unit_name":
                                                              item['unit_name'],
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
                                                    'Outfit',
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  item['unit_name'] ?? '',
                                                  style: heading4(
                                                    FontWeight.w400,
                                                    bnw700,
                                                    'Outfit',
                                                  ),
                                                ),
                                                trailing: Icon(
                                                  selectedDataPemakaian
                                                          .containsKey(
                                                            item['id'],
                                                          )
                                                      ? Icons.expand_less
                                                      : Icons.expand_more,
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    addNewItem();
                                                    if (selectedDataPemakaian
                                                        .containsKey(
                                                          item['id'],
                                                        )) {
                                                      selectedDataPemakaian
                                                          .remove(item['id']);
                                                    } else {
                                                      selectedDataPemakaian[item['id']] = {
                                                        "inventory_master_id":
                                                            item['id'],
                                                        "qty": 0,
                                                        "unit":
                                                            item['name_item'],
                                                        "unit_conversion_id":
                                                            '',
                                                        // unitList[index]
                                                        //     .id
                                                        //     .toString(),
                                                        "unit_name":
                                                            item['unit_name'],
                                                      };
                                                    }
                                                  });
                                                },
                                              ),
                                              if (selectedDataPemakaian
                                                  .containsKey(item['id']))
                                                Container(
                                                  padding: EdgeInsets.all(
                                                    size8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: primary100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          size8,
                                                        ),
                                                  ),

                                                  //ubah cu
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Harga Satuan      : ',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              // Text(
                                                              //   '*',
                                                              //   style: heading4(
                                                              //       FontWeight.w400,
                                                              //       danger500,
                                                              //       'Outfit'),
                                                              // ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: size12,
                                                          ),
                                                          SizedBox(
                                                            key: ValueKey(
                                                              index,
                                                            ),
                                                            width: 120,
                                                            child: TextField(
                                                              controller:
                                                                  hargaSatuanControllers[index],
                                                              // onTap: () {
                                                              //   FocusScope.of(
                                                              //           context)
                                                              //       .requestFocus(
                                                              //           focusNodeHarga);
                                                              // },
                                                              decoration: InputDecoration(
                                                                focusedBorder: UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                        width:
                                                                            2,
                                                                        color:
                                                                            primary500,
                                                                      ),
                                                                ),
                                                                focusColor:
                                                                    primary500,
                                                                hintText:
                                                                    'Cth : 10.000',
                                                                hintStyle:
                                                                    heading2(
                                                                      FontWeight
                                                                          .w600,
                                                                      bnw400,
                                                                      'Outfit',
                                                                    ),
                                                              ),
                                                              onChanged: (value) {
                                                                setState(() {});
                                                                selectedDataPemakaian[item['id']]!['price'] =
                                                                    value;
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: size12),
                                                      Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Qty      : ',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              // Text(
                                                              //   '*',
                                                              //   style: heading4(
                                                              //       FontWeight.w400,
                                                              //       danger500,
                                                              //       'Outfit'),
                                                              // ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: size12,
                                                          ),
                                                          SizedBox(
                                                            width: 120,
                                                            child: TextField(
                                                              controller:
                                                                  qtyController[index],
                                                              decoration: InputDecoration(
                                                                focusedBorder: UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                        width:
                                                                            2,
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
                                                                    ),
                                                              ),
                                                              onChanged: (value) {
                                                                selectedDataPemakaian[item['id']]!['qty'] =
                                                                    value;
                                                                setState(() {});
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: size12,
                                                          ),
                                                          Text(
                                                            '|',
                                                            style: heading3(
                                                              FontWeight.w600,
                                                              bnw900,
                                                              'Outfit',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: size12,
                                                          ),
                                                          Text(
                                                            // 'Qty Total : ${qtyController.length}',
                                                            // qtyController.text,
                                                            // (selectedDataPemakaian[dataPemakaian[index]['id']]!['updated_at']) ?? "0",
                                                            '1 qty = ${(double.tryParse(qtyController[index].text.isNotEmpty ? qtyController[index].text : '0') ?? 0) * (double.tryParse(selectedDataPemakaian[dataPemakaian[index]['id']]?['unit_factor'] ?? '0.0') ?? 0.0)} ${item['unit_name']}',

                                                            // '1 qty = ${dataPemakaian.isNotEmpty && index < dataPemakaian.length && index < unitList.length ? ((int.tryParse(qtyController[index].text) ?? 0) * (double.tryParse(selectedDataPemakaian[dataPemakaian[index]['id']]?['unit_factor']?.replaceAll(',', '.') ?? "0.0") ?? 0.0)) : 0.0} ${item['unit_name']}',
                                                            style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: size12),
                                                      Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Unit Convertion : ',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                              // Text(
                                                              //   '*',
                                                              //   style: heading4(
                                                              //       FontWeight
                                                              //           .w400,
                                                              //       danger500,
                                                              //       'Outfit'),
                                                              // ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: size12,
                                                          ),
                                                          SizedBox(
                                                            width: 120,
                                                            child: TextField(
                                                              // enabled: false,
                                                              // controller:
                                                              //     textController,
                                                              readOnly: true,
                                                              decoration: InputDecoration(
                                                                focusedBorder: UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                        width:
                                                                            2,
                                                                        color:
                                                                            primary500,
                                                                      ),
                                                                ),
                                                                focusColor:
                                                                    primary500,
                                                                hintText:
                                                                    textController[index]
                                                                        .text ??
                                                                    '',
                                                                hintStyle:
                                                                    heading2(
                                                                      FontWeight
                                                                          .w600,
                                                                      bnw800,
                                                                      'Outfit',
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: size12,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              // print(selectedDataPemakaian[
                                                              //     dataPemakaian[
                                                              //             index]
                                                              //         [
                                                              //         'id']]!['unit']);
                                                              final selected =
                                                                  await showModalBottomSheet<
                                                                    UnitConvertionModel
                                                                  >(
                                                                    context:
                                                                        context,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.vertical(
                                                                        top: Radius.circular(
                                                                          size16,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    builder: (context) {
                                                                      return Column(
                                                                        children: [
                                                                          Expanded(
                                                                            child: ListView(
                                                                              padding: EdgeInsets.all(
                                                                                size16,
                                                                              ),
                                                                              children: unitList.map(
                                                                                (
                                                                                  unit,
                                                                                ) {
                                                                                  return ListTile(
                                                                                    title: Text(
                                                                                      unit.name,
                                                                                    ),
                                                                                    leading: Icon(
                                                                                      PhosphorIcons.radio_button,
                                                                                    ),
                                                                                    onTap: () {
                                                                                      print(
                                                                                        selectedDataPemakaian[item['id']],
                                                                                      );
                                                                                      textController[index].text = unit.name;

                                                                                      // Update hanya pada item yang sedang aktif (index)
                                                                                      selectedDataPemakaian[item['id']]!['unit'] = item['name_item'];
                                                                                      selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_name'] = unit.name;
                                                                                      selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_factor'] = unit.conversionFactor;
                                                                                      selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_conversion_id'] = unit.id.isEmpty
                                                                                          ? null
                                                                                          : unit.id;
                                                                                      // Jika ingin menyimpan id juga:
                                                                                      // selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_conversion_id'] = unit.id;

                                                                                      Navigator.pop(
                                                                                        context,
                                                                                        unit,
                                                                                      );
                                                                                      setState(
                                                                                        () {},
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                },
                                                                              ).toList(),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            width:
                                                                                double.infinity,
                                                                            padding: EdgeInsets.all(
                                                                              size12,
                                                                            ),
                                                                            child: GestureDetector(
                                                                              onTap: () {
                                                                                textController[index].text = '-';
                                                                                // selectedDataPemakaian[dataPemakaian[index]['id']]!['unit'] = '';
                                                                                // selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_name'] = '';
                                                                                selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_factor'] = '';
                                                                                selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_conversion_id'] = '';

                                                                                setState(
                                                                                  () {},
                                                                                );
                                                                                Navigator.pop(
                                                                                  context,
                                                                                );
                                                                              },
                                                                              child: buttonXL(
                                                                                Center(
                                                                                  child: Text(
                                                                                    'Hapus',
                                                                                    style: heading3(
                                                                                      FontWeight.w600,
                                                                                      bnw100,
                                                                                      'Outfit',
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                double.infinity,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );

                                                              if (selected !=
                                                                  null) {
                                                                unitController
                                                                        .text =
                                                                    selected
                                                                        .name;
                                                                selectedUnit =
                                                                    selected;

                                                                setState(() {});
                                                              }
                                                            },
                                                            child: Icon(
                                                              PhosphorIcons
                                                                  .caret_down,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: size12),
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
                                        style: heading3(
                                          FontWeight.w600,
                                          primary500,
                                          'Outfit',
                                        ),
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
                                      orderInventory = selectedDataPemakaian
                                          .values
                                          .toList();

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
                                          FontWeight.w600,
                                          bnw100,
                                          'Outfit',
                                        ),
                                      ),
                                    ),
                                    double.infinity,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            child: SizedBox(
              width: double.infinity,
              child: buttonXLoutline(
                Center(
                  child: Text(
                    'Persediaan',
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
                    // print(orderInventory);
                    setState(() {
                      createPembelian(
                        context,
                        widget.token,
                        tanggalAwal,
                        judulPembelian.text,
                        orderInventory,
                      );

                      tanggalAwal = '';
                      judulPembelian.clear();
                      orderInventory.clear();
                      selectedDataPemakaian.clear();
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
                    // for (var item in orderInventory) {
                    //   if (item.containsKey('qty')) {
                    //     item['qty'] = item['qty'];
                    //     item.remove('qty');
                    //   }
                    // }

                    createPembelian(
                      context,
                      widget.token,
                      tanggalAwal,
                      judulPembelian.text,
                      orderInventory,
                    ).then((value) {
                      if (value == '00') {
                        _pageController.jumpToPage(0);
                        orderInventory.clear();
                        tanggalAwal = '';
                        setState(() {});
                        refreshPage();
                      }
                    });

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
          ),
        ],
      ),
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
                      orderInventory.clear();
                      pagesOn = 2;
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
                        'Tambah Penyesuaian',
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        'Penyesuaian',
                        style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                ],
              ),
              fieldTambahBahan('Judul', judulPenyesuaian, 'Penyesuaian Matcha'),
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
                                Opacity(
                                  opacity: 0,
                                  child: SizedBox(
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
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Nama Produk',
                                    style: heading4(
                                      FontWeight.w700,
                                      bnw100,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Satuan',
                                    style: heading4(
                                      FontWeight.w700,
                                      bnw100,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Jumlah',
                                    style: heading4(
                                      FontWeight.w700,
                                      bnw100,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                                SizedBox(width: size16),
                                // Expanded(
                                //   flex: 4,
                                //   child: Text(
                                //     'Harga Satuan',
                                //     style: heading4(
                                //         FontWeight.w700, bnw100, 'Outfit'),
                                //   ),
                                // ),
                                // SizedBox(width: size16),
                                // Expanded(
                                //   flex: 4,
                                //   child: Text(
                                //     'Total Harga',
                                //     style: heading4(
                                //         FontWeight.w700, bnw100, 'Outfit'),
                                //   ),
                                // ),
                                // SizedBox(width: size16),
                                Icon(PhosphorIcons.x_fill, color: primary500),
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
                                  style: heading4(
                                    FontWeight.w600,
                                    bnw100,
                                    'Outfit',
                                  ),
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
                                                  'Outfit',
                                                ),
                                              ),
                                              SizedBox(height: size16),
                                              Text(
                                                'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                style: heading2(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
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
                                                          'Outfit',
                                                        ),
                                                      ),
                                                    ),
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width,
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
                                                          'Outfit',
                                                        ),
                                                      ),
                                                    ),
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width,
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
                                        Icon(
                                          PhosphorIcons.trash_fill,
                                          color: bnw900,
                                        ),
                                        Text(
                                          'Hapus Semua',
                                          style: heading3(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
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
                          // physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: orderInventory.length,
                          itemBuilder: (context, index) {
                            // Mendapatkan data dari dataPemakaian
                            final Map<String, dynamic> data =
                                orderInventory[index];
                            final productId = data['id'];
                            final isSelected = selectedDataPemakaian
                                .containsKey(productId);

                            // print('Dataku: $data');

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: size12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: bnw300, width: 1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Opacity(
                                    opacity: 0,
                                    child: InkWell(
                                      // onTap: () => onTap(isSelected, index),
                                      onTap: () {
                                        onTap(isSelected, index, productId);
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
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      data['unit'] ?? '',
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
                                      data['unit_name'] ?? '',
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

                                  // SizedBox(width: size16),
                                  // Expanded(
                                  //   flex: 4,
                                  //   child: Text(
                                  //     data['price'].toString(),
                                  //     style: heading4(
                                  //       FontWeight.w400,
                                  //       bnw900,
                                  //       'Outfit',
                                  //     ),
                                  //     maxLines: 3,
                                  //     overflow: TextOverflow.ellipsis,
                                  //   ),
                                  // ),
                                  // SizedBox(width: size16),
                                  // Expanded(
                                  //   flex: 4,
                                  //   child: Text(
                                  //     FormatCurrency.convertToIdr(
                                  //       (double.tryParse(
                                  //                   data['price'].toString()) ??
                                  //               0.0) *
                                  //           (int.tryParse(
                                  //                   data['qty'].toString()) ??
                                  //               0),
                                  //     ),
                                  //     maxLines: 3,
                                  //     overflow: TextOverflow.ellipsis,
                                  //   ),
                                  // ),
                                  // SizedBox(width: size16),
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
            if (selectedDataPemakaian.isEmpty) {
              selectedDataPemakaian.clear();
            }
            qtyController = List.generate(
              dataPemakaian.length,
              (index) => TextEditingController(),
            );
            hargaSatuanControllers = List.generate(
              dataPemakaian.length,
              (index) => TextEditingController(),
            );
            textController = List.generate(
              dataPemakaian.length,
              (index) => TextEditingController(text: '-'),
            );

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
                                      FontWeight.w400,
                                      bnw500,
                                      'Outfit',
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
                                  ),
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
                                                    // print(
                                                    // "tapped ${unitList[index].id}");
                                                    // print(
                                                    //     'Checkbox changed: ${item['unit_name']}');
                                                    if (value == true) {
                                                      selectedDataPemakaian[item['id']] = {
                                                        "inventory_master_id":
                                                            item['id'],
                                                        "unit":
                                                            item['name_item'],
                                                        "qty": 0,
                                                        "unit_conversion_id":
                                                            item['unit_conversion_id'],
                                                        // unitList[index]
                                                        //     .id
                                                        //     .toString(),
                                                        "unit_name":
                                                            item['unit_name'],
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
                                                  'Outfit',
                                                ),
                                              ),
                                              subtitle: Text(
                                                item['unit_name'] ?? '',
                                                style: heading4(
                                                  FontWeight.w400,
                                                  bnw700,
                                                  'Outfit',
                                                ),
                                              ),
                                              trailing: Icon(
                                                selectedDataPemakaian
                                                        .containsKey(item['id'])
                                                    ? Icons.expand_less
                                                    : Icons.expand_more,
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  addNewItem();
                                                  if (selectedDataPemakaian
                                                      .containsKey(
                                                        item['id'],
                                                      )) {
                                                    selectedDataPemakaian
                                                        .remove(item['id']);
                                                  } else {
                                                    selectedDataPemakaian[item['id']] =
                                                        {
                                                          "inventory_master_id":
                                                              item['id'],
                                                          "qty": 0,
                                                          "unit":
                                                              item['name_item'],
                                                          "unit_conversion_id":
                                                              '',
                                                          // unitList[index]
                                                          //     .id
                                                          //     .toString(),
                                                          "unit_name":
                                                              item['unit_name'],
                                                        };
                                                  }
                                                });
                                              },
                                            ),
                                            if (selectedDataPemakaian
                                                .containsKey(item['id']))
                                              Container(
                                                padding: EdgeInsets.all(size8),
                                                decoration: BoxDecoration(
                                                  color: primary100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        size8,
                                                      ),
                                                ),

                                                //ubah cu
                                                child: Column(
                                                  children: [
                                                    // Row(
                                                    //   children: [
                                                    //     Row(
                                                    //       children: [
                                                    //         Text(
                                                    //           'Harga Satuan      : ',
                                                    //           style: heading4(
                                                    //               FontWeight
                                                    //                   .w400,
                                                    //               bnw900,
                                                    //               'Outfit'),
                                                    //         ),
                                                    //         // Text(
                                                    //         //   '*',
                                                    //         //   style: heading4(
                                                    //         //       FontWeight.w400,
                                                    //         //       danger500,
                                                    //         //       'Outfit'),
                                                    //         // ),
                                                    //       ],
                                                    //     ),
                                                    //     SizedBox(
                                                    //         width: size12),
                                                    //     SizedBox(
                                                    //       key:
                                                    //           ValueKey(index),
                                                    //       width: 120,
                                                    //       child: TextField(
                                                    //         controller:
                                                    //             hargaSatuanControllers[
                                                    //                 index],
                                                    //         onTap: () {
                                                    //           FocusScope.of(
                                                    //                   context)
                                                    //               .requestFocus(
                                                    //                   focusNodeHarga);
                                                    //         },
                                                    //         decoration:
                                                    //             InputDecoration(
                                                    //           focusedBorder:
                                                    //               UnderlineInputBorder(
                                                    //             borderSide:
                                                    //                 BorderSide(
                                                    //               width: 2,
                                                    //               color:
                                                    //                   primary500,
                                                    //             ),
                                                    //           ),
                                                    //           focusColor:
                                                    //               primary500,
                                                    //           hintText:
                                                    //               'Cth : 10.000',
                                                    //           hintStyle:
                                                    //               heading2(
                                                    //             FontWeight
                                                    //                 .w600,
                                                    //             bnw400,
                                                    //             'Outfit',
                                                    //           ),
                                                    //         ),
                                                    //         onChanged:
                                                    //             (value) {
                                                    //           setState(() {});
                                                    //           selectedDataPemakaian[
                                                    //                   item[
                                                    //                       'id']]![
                                                    //               'price'] = value;
                                                    //         },
                                                    //         keyboardType:
                                                    //             TextInputType
                                                    //                 .number,
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    // SizedBox(height: size12),
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Qty      : ',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            // Text(
                                                            //   '*',
                                                            //   style: heading4(
                                                            //       FontWeight.w400,
                                                            //       danger500,
                                                            //       'Outfit'),
                                                            // ),
                                                          ],
                                                        ),
                                                        SizedBox(width: size12),
                                                        SizedBox(
                                                          width: 120,
                                                          child: TextField(
                                                            controller:
                                                                qtyController[index],
                                                            decoration: InputDecoration(
                                                              focusedBorder:
                                                                  UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                          width:
                                                                              2,
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
                                                                  ),
                                                            ),
                                                            onChanged: (value) {
                                                              setState(() {});
                                                              selectedDataPemakaian[item['id']]!['qty'] =
                                                                  value;
                                                            },
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                          ),
                                                        ),
                                                        SizedBox(width: size12),
                                                        Text(
                                                          '|',
                                                          style: heading3(
                                                            FontWeight.w600,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                        SizedBox(width: size12),
                                                        Text(
                                                          // 'Qty Total : ${qtyController.length}',
                                                          // qtyController.text,
                                                          // (selectedDataPemakaian[dataPemakaian[index]['id']]!['updated_at']) ?? "0",
                                                          '1 qty = ${dataPemakaian.isNotEmpty && index < dataPemakaian.length && index < unitList.length ? ((int.tryParse(qtyController[index].text) ?? 0) * (double.tryParse(selectedDataPemakaian[dataPemakaian[index]['id']]?['unit_factor']?.replaceAll(',', '.') ?? "0") ?? 0)) : 0} ${item['unit_name']}',

                                                          style: heading4(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size12),
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Unit Convertion : ',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            // Text(
                                                            //   '*',
                                                            //   style: heading4(
                                                            //       FontWeight
                                                            //           .w400,
                                                            //       danger500,
                                                            //       'Outfit'),
                                                            // ),
                                                          ],
                                                        ),
                                                        SizedBox(width: size12),
                                                        SizedBox(
                                                          width: 120,
                                                          child: TextField(
                                                            // enabled: false,
                                                            // controller:
                                                            //     textController,
                                                            readOnly: true,
                                                            decoration: InputDecoration(
                                                              focusedBorder:
                                                                  UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                          width:
                                                                              2,
                                                                          color:
                                                                              primary500,
                                                                        ),
                                                                  ),
                                                              focusColor:
                                                                  primary500,
                                                              hintText:
                                                                  textController[index]
                                                                      .text ??
                                                                  '',
                                                              hintStyle:
                                                                  heading2(
                                                                    FontWeight
                                                                        .w600,
                                                                    bnw800,
                                                                    'Outfit',
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: size12),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            // print(selectedDataPemakaian[
                                                            //     dataPemakaian[
                                                            //             index]
                                                            //         [
                                                            //         'id']]!['unit']);
                                                            final selected =
                                                                await showModalBottomSheet<
                                                                  UnitConvertionModel
                                                                >(
                                                                  context:
                                                                      context,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.vertical(
                                                                          top: Radius.circular(
                                                                            size16,
                                                                          ),
                                                                        ),
                                                                  ),
                                                                  builder: (context) {
                                                                    return Column(
                                                                      children: [
                                                                        Expanded(
                                                                          child: ListView(
                                                                            padding: EdgeInsets.all(
                                                                              size16,
                                                                            ),
                                                                            children: unitList.map((
                                                                              unit,
                                                                            ) {
                                                                              return ListTile(
                                                                                title: Text(
                                                                                  unit.name,
                                                                                ),
                                                                                leading: Icon(
                                                                                  PhosphorIcons.radio_button,
                                                                                ),
                                                                                onTap: () {
                                                                                  print(
                                                                                    selectedDataPemakaian[item['id']],
                                                                                  );
                                                                                  textController[index].text = unit.name;

                                                                                  // Update hanya pada item yang sedang aktif (index)
                                                                                  selectedDataPemakaian[item['id']]!['unit'] = item['name_item'];
                                                                                  selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_name'] = unit.name;
                                                                                  selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_factor'] = unit.conversionFactor;
                                                                                  selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_conversion_id'] = unit.id;
                                                                                  // Jika ingin menyimpan id juga:
                                                                                  selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_conversion_id'] = unit.id.isEmpty
                                                                                      ? null
                                                                                      : unit.id;

                                                                                  Navigator.pop(
                                                                                    context,
                                                                                    unit,
                                                                                  );
                                                                                  setState(
                                                                                    () {},
                                                                                  );
                                                                                },
                                                                              );
                                                                            }).toList(),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              double.infinity,
                                                                          padding: EdgeInsets.all(
                                                                            size12,
                                                                          ),
                                                                          child: GestureDetector(
                                                                            onTap: () {
                                                                              textController[index].text = '-';
                                                                              // selectedDataPemakaian[dataPemakaian[index]['id']]!['unit'] = '';
                                                                              // selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_name'] = '';
                                                                              selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_factor'] = '';
                                                                              selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_conversion_id'] = '';

                                                                              setState(
                                                                                () {},
                                                                              );
                                                                              Navigator.pop(
                                                                                context,
                                                                              );
                                                                            },
                                                                            child: buttonXL(
                                                                              Center(
                                                                                child: Text(
                                                                                  'Hapus',
                                                                                  style: heading3(
                                                                                    FontWeight.w600,
                                                                                    bnw100,
                                                                                    'Outfit',
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              double.infinity,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );

                                                            if (selected !=
                                                                null) {
                                                              unitController
                                                                      .text =
                                                                  selected.name;
                                                              selectedUnit =
                                                                  selected;

                                                              setState(() {});
                                                            }
                                                          },
                                                          child: Icon(
                                                            PhosphorIcons
                                                                .caret_down,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size12),
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
                                      style: heading3(
                                        FontWeight.w600,
                                        primary500,
                                        'Outfit',
                                      ),
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
                                    orderInventory = selectedDataPemakaian
                                        .values
                                        .toList();

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
                                        FontWeight.w600,
                                        bnw100,
                                        'Outfit',
                                      ),
                                    ),
                                  ),
                                  double.infinity,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          child: SizedBox(
            width: double.infinity,
            child: buttonXLoutline(
              Center(
                child: Text(
                  'Sesuaikan',
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
                    tanggalAkhir,
                    judulPenyesuaian.text,
                    orderInventory,
                  ).then((value) {
                    if (value == '00') {
                      _pageController.jumpToPage(0);
                      orderInventory.clear();
                      tanggalAwal = '';
                      setState(() {});
                      refreshPage();
                      // initState();
                    }
                  });

                  // print(orderInventory);
                  // print(dataPemakaian);
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
        ),
      ],
    );
  }

  SizedBox produkmaterial(BuildContext context) {
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
                  // orderBy(context),
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
                                          FontWeight.w700,
                                          bnw100,
                                          'Outfit',
                                        ),
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
                                  'Nama Produk',
                                  style: heading4(
                                    FontWeight.w700,
                                    bnw100,
                                    'Outfit',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            // Expanded(
                            //   flex: 4,
                            //   child: Container(
                            //     child: Text(
                            //       'Total Harga',
                            //       style: heading4(
                            //           FontWeight.w700, bnw100, 'Outfit'),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(width: size16),
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
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                                bnw100,
                                bnw300,
                              ),
                            ),
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
                              '${listProduct.length}/${datasProdukBOM!.length} Produk Terpilih',
                              // 'produk terpilih',
                              style: heading4(
                                FontWeight.w600,
                                bnw100,
                                'Outfit',
                              ),
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
                                              'Outfit',
                                            ),
                                          ),
                                          SizedBox(height: size16),
                                          Text(
                                            'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                            style: heading2(
                                              FontWeight.w400,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: size16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                deleteBOM(
                                                  context,
                                                  widget.token,
                                                  listProduct,
                                                  '',
                                                ).then((value) {
                                                  setState(() {
                                                    isSelectionMode = false;
                                                    listProduct = [];
                                                    listProduct.clear();
                                                    selectedFlag.clear();
                                                  });
                                                  initState();
                                                  initState();
                                                });

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
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ),
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
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
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ),
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
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
                                    Icon(
                                      PhosphorIcons.trash_fill,
                                      color: bnw900,
                                    ),
                                    Text(
                                      'Hapus Semua',
                                      style: heading3(
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
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
                datasProdukBOM == null
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
                              // initState();
                            },
                            child: ListView.builder(
                              // physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: datasProdukBOM!.length,
                              itemBuilder: (builder, index) {
                                BOMModel data = datasProdukBOM![index];
                                selectedFlag[index] =
                                    selectedFlag[index] ?? false;
                                bool? isSelected = selectedFlag[index];
                                final dataProduk = datasProdukBOM![index];
                                productIdCheckAll = datasProdukBOM!
                                    .map((data) => data.id!)
                                    .toList();

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: size12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: bnw300,
                                        width: width1,
                                      ),
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
                                                setState(() {
                                                  onTap(
                                                    isSelected,
                                                    index,
                                                    dataProduk.id,
                                                  );
                                                  print(dataProduk.productName);
                                                  print(dataProduk.productId);

                                                  print(listProduct);
                                                });
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
                                              datasProdukBOM![index].title ??
                                                  '',
                                              style: heading4(
                                                FontWeight.w600,
                                                bnw900,
                                                'Outfit',
                                              ),
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
                                          datasProdukBOM![index].productName ??
                                              '',
                                          style: heading4(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // SizedBox(width: size16),
                                      // Expanded(
                                      //   flex: 4,
                                      //   child: Text(
                                      //     FormatCurrency.convertToIdr(
                                      //       datasProdukBOM![index].totalPrice,
                                      //     ),
                                      //     style: heading4(FontWeight.w600,
                                      //         bnw900, 'Outfit'),
                                      //     maxLines: 3,
                                      //     overflow: TextOverflow.ellipsis,
                                      //   ),
                                      // ),
                                      // SizedBox(width: size16),
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
                                                              datasProdukBOM![index]
                                                                      .title ??
                                                                  '',
                                                              // dataProduk
                                                              //     .nameItem!,
                                                              style: heading2(
                                                                FontWeight.w600,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            Text(
                                                              datasProdukBOM![index]
                                                                      .productName ??
                                                                  '',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        GestureDetector(
                                                          onTap: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: Icon(
                                                            PhosphorIcons
                                                                .x_fill,
                                                            color: bnw900,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size24),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        Navigator.pop(context);

                                                        productMaterialIdUbah =
                                                            datasProdukBOM![index]
                                                                .id
                                                                .toString();

                                                        print(
                                                          productMaterialIdUbah,
                                                        );

                                                        // fetchBOMSingle(
                                                        //   datasProdukBOM![index]
                                                        //       .id
                                                        //       .toString(),
                                                        // );

                                                        getSingleBOM(
                                                          context,
                                                          widget.token,
                                                          '',
                                                          productMaterialIdUbah,
                                                        ).then((value) {
                                                          Future.delayed(
                                                            Duration(
                                                              seconds: 1,
                                                            ),
                                                          ).then((value) {
                                                            _pageController
                                                                .jumpToPage(9);
                                                            initState();
                                                          });
                                                        });
                                                      },
                                                      behavior: HitTestBehavior
                                                          .translucent,
                                                      child: modalBottomValue(
                                                        'Ubah Produk Material',
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
                                                                    'Yakin Ingin Menghapus Unit?',
                                                                    style: heading1(
                                                                      FontWeight
                                                                          .w600,
                                                                      bnw900,
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        size16,
                                                                  ),
                                                                  Text(
                                                                    'Data bahan yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                                    style: heading2(
                                                                      FontWeight
                                                                          .w400,
                                                                      bnw900,
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        size16,
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        setState(() {
                                                                          // log(dataProduk.id.toString());
                                                                          List<
                                                                            String
                                                                          >
                                                                          dataBahan = [
                                                                            datasProdukBOM![index].id.toString(),
                                                                          ];

                                                                          deleteBOM(
                                                                            context,
                                                                            widget.token,
                                                                            dataBahan,
                                                                            '',
                                                                          ).then((
                                                                            value,
                                                                          ) {
                                                                            setState(() {
                                                                              isSelectionMode = false;
                                                                              listProduct = [];
                                                                              listProduct.clear();
                                                                              selectedFlag.clear();
                                                                            });
                                                                            initState();
                                                                            initState();
                                                                          });
                                                                        });
                                                                      },
                                                                      child: buttonXLoutline(
                                                                        Center(
                                                                          child: Text(
                                                                            'Iya, Hapus',
                                                                            style: heading3(
                                                                              FontWeight.w600,
                                                                              primary500,
                                                                              'Outfit',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width,
                                                                        primary500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  Expanded(
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                      },
                                                                      child: buttonXL(
                                                                        Center(
                                                                          child: Text(
                                                                            'Batalkan',
                                                                            style: heading3(
                                                                              FontWeight.w600,
                                                                              bnw100,
                                                                              'Outfit',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width,
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
                                                        'Hapus Produk Material',
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
                                                style: heading3(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
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

  SizedBox unitConversion(BuildContext context) {
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
                  // orderBy(context),
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
                                        // 'Convertion Factor',
                                        'Convertion Name',
                                        style: heading4(
                                          FontWeight.w700,
                                          bnw100,
                                          'Outfit',
                                        ),
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
                                  'Convertion Factor',
                                  style: heading4(
                                    FontWeight.w700,
                                    bnw100,
                                    'Outfit',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            // Expanded(
                            //   flex: 4,
                            //   child: Container(
                            //     child: Text(
                            //       'Total Harga',
                            //       style: heading4(
                            //           FontWeight.w700, bnw100, 'Outfit'),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(width: size16),
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
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                                bnw100,
                                bnw300,
                              ),
                            ),
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
                              '${listProduct.length}/${datasProdukUnit!.length} Produk Terpilih',
                              // 'produk terpilih',
                              style: heading4(
                                FontWeight.w600,
                                bnw100,
                                'Outfit',
                              ),
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
                                              'Outfit',
                                            ),
                                          ),
                                          SizedBox(height: size16),
                                          Text(
                                            'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                            style: heading2(
                                              FontWeight.w400,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: size16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                deleteUNIT(
                                                  context,
                                                  widget.token,
                                                  listProduct,
                                                  '',
                                                ).then((value) {
                                                  setState(() {
                                                    isSelectionMode = false;
                                                    listProduct = [];
                                                    listProduct.clear();
                                                    selectedFlag.clear();
                                                  });
                                                  initState();
                                                  initState();
                                                });

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
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ),
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
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
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ),
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
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
                                    Icon(
                                      PhosphorIcons.trash_fill,
                                      color: bnw900,
                                    ),
                                    Text(
                                      'Hapus Semua',
                                      style: heading3(
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
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
                datasProdukUnit == null
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
                              // initState();
                              fetchUnits();
                            },
                            child: ListView.builder(
                              // physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: datasProdukUnit!.length,
                              itemBuilder: (builder, index) {
                                UnitConvertionModel data =
                                    datasProdukUnit![index];
                                selectedFlag[index] =
                                    selectedFlag[index] ?? false;
                                bool? isSelected = selectedFlag[index];
                                final dataProduk = datasProdukUnit![index];
                                productIdCheckAll = datasProdukUnit!
                                    .map((data) => data.id.toString())
                                    .toList();

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: size12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: bnw300,
                                        width: width1,
                                      ),
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
                                                setState(() {
                                                  onTap(
                                                    isSelected,
                                                    index,
                                                    dataProduk.id.toString(),
                                                  );
                                                  print(dataProduk.name);
                                                  print(dataProduk.id);

                                                  print(listProduct);
                                                });
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
                                              datasProdukUnit![index].name ??
                                                  '',
                                              style: heading4(
                                                FontWeight.w600,
                                                bnw900,
                                                'Outfit',
                                              ),
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
                                          // 'hello',
                                          double.tryParse(
                                            datasProdukUnit![index]
                                                .conversionFactor,
                                          ).toString(),
                                          style: heading4(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // SizedBox(width: size16),
                                      // Expanded(
                                      //   flex: 4,
                                      //   child: Text(
                                      //     FormatCurrency.convertToIdr(
                                      //       datasProdukUnit![index].totalPrice,
                                      //     ),
                                      //     style: heading4(FontWeight.w600,
                                      //         bnw900, 'Outfit'),
                                      //     maxLines: 3,
                                      //     overflow: TextOverflow.ellipsis,
                                      //   ),
                                      // ),
                                      // SizedBox(width: size16),
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
                                                              datasProdukUnit![index]
                                                                  .name
                                                                  .toString(),
                                                              // dataProduk
                                                              //     .nameItem!,
                                                              style: heading2(
                                                                FontWeight.w600,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            // Text(0
                                                            //   datasProdukUnit![
                                                            //               index]
                                                            //           .merchantId ??
                                                            //       '',
                                                            //   style: heading4(
                                                            //       FontWeight
                                                            //           .w400,
                                                            //       bnw900,
                                                            //       'Outfit'),
                                                            // ),
                                                          ],
                                                        ),
                                                        GestureDetector(
                                                          onTap: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: Icon(
                                                            PhosphorIcons
                                                                .x_fill,
                                                            color: bnw900,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size24),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        unitIdUbah =
                                                            datasProdukUnit![index]
                                                                .id
                                                                .toString();

                                                        print(
                                                          datasProdukUnit![index]
                                                              .id
                                                              .toString(),
                                                        );

                                                        getSingleUnitConvertion(
                                                          widget.token,
                                                          '',
                                                          datasProdukUnit![index]
                                                              .id
                                                              .toString(),
                                                          context,
                                                        ).then((value) {
                                                          Future.delayed(
                                                            Duration(
                                                              seconds: 1,
                                                            ),
                                                          ).then(
                                                            (value) =>
                                                                _pageController
                                                                    .jumpToPage(
                                                                      8,
                                                                    ),
                                                          );
                                                        });
                                                      },
                                                      behavior: HitTestBehavior
                                                          .translucent,
                                                      child: modalBottomValue(
                                                        'Ubah Unit',
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
                                                                    'Yakin Ingin Menghapus Unit?',
                                                                    style: heading1(
                                                                      FontWeight
                                                                          .w600,
                                                                      bnw900,
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        size16,
                                                                  ),
                                                                  Text(
                                                                    'Data Unit yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                                    style: heading2(
                                                                      FontWeight
                                                                          .w400,
                                                                      bnw900,
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        size16,
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        setState(() {
                                                                          // log(dataProduk.id.toString());
                                                                          List<
                                                                            String
                                                                          >
                                                                          dataBahan = [
                                                                            datasProdukUnit![index].id.toString(),
                                                                          ];

                                                                          log(
                                                                            dataBahan.toString(),
                                                                          );

                                                                          deleteUNIT(
                                                                            context,
                                                                            widget.token,
                                                                            dataBahan,
                                                                            '',
                                                                          ).then((
                                                                            value,
                                                                          ) {
                                                                            setState(() {
                                                                              isSelectionMode = false;
                                                                              listProduct = [];
                                                                              listProduct.clear();
                                                                              selectedFlag.clear();
                                                                            });
                                                                            initState();
                                                                            initState();
                                                                          });
                                                                        });
                                                                      },
                                                                      child: buttonXLoutline(
                                                                        Center(
                                                                          child: Text(
                                                                            'Iya, Hapus',
                                                                            style: heading3(
                                                                              FontWeight.w600,
                                                                              primary500,
                                                                              'Outfit',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width,
                                                                        primary500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  Expanded(
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                      },
                                                                      child: buttonXL(
                                                                        Center(
                                                                          child: Text(
                                                                            'Batalkan',
                                                                            style: heading3(
                                                                              FontWeight.w600,
                                                                              bnw100,
                                                                              'Outfit',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width,
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
                                                        'Hapus Unit',
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
                                                style: heading3(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
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

  fieldTambah(title, mycontroller, hintText) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: heading4(FontWeight.w500, bnw900, 'Outfit')),
              Text(' *', style: heading4(FontWeight.w700, red500, 'Outfit')),
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
                borderSide: BorderSide(width: 2, color: primary500),
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: size12),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(width: 1.5, color: bnw500),
              ),
              hintText: hintText,
              hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }

  //!bom
  tambahProdukMaterial() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      getDataProduk(['']);
                      orderInventory.clear();
                      // pagesOn = 0;
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
                        'Tambah Bill Of Material',
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        'Produk Material',
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
                          bottom: BorderSide(width: 1.5, color: bnw500),
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
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                print('hello');
                                showProductSelector(
                                  context,
                                  widget.token,
                                  [],
                                  searchProductID,
                                );
                              },
                              child: Container(
                                child: fieldTambahProductID(
                                  'Produk',
                                  tambahProdukCon,
                                  'Matcha',
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
                                Opacity(
                                  opacity: 0,
                                  child: SizedBox(
                                    child: GestureDetector(
                                      onTap: () {
                                        // _selectAll(productIdCheckAll);
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
                                ),
                                // Expanded(
                                //   flex: 4,
                                //   child: Text(
                                //     'No',
                                //     style: heading4(
                                //         FontWeight.w700, bnw100, 'Outfit'),
                                //   ),
                                // ),
                                // SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Inventory Master',
                                    style: heading4(
                                      FontWeight.w700,
                                      bnw100,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Qty',
                                    style: heading4(
                                      FontWeight.w700,
                                      bnw100,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Unit Convertion',
                                    style: heading4(
                                      FontWeight.w700,
                                      bnw100,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Icon(PhosphorIcons.x_fill, color: primary500),
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
                                  '${listProduct.length}/${datasProdukBOM!.length} Produk Terpilih',
                                  // 'produk terpilih',
                                  style: heading4(
                                    FontWeight.w600,
                                    bnw100,
                                    'Outfit',
                                  ),
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
                                                  'Outfit',
                                                ),
                                              ),
                                              SizedBox(height: size16),
                                              Text(
                                                'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                style: heading2(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
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
                                                          'Outfit',
                                                        ),
                                                      ),
                                                    ),
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width,
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
                                                          'Outfit',
                                                        ),
                                                      ),
                                                    ),
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width,
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
                                        Icon(
                                          PhosphorIcons.trash_fill,
                                          color: bnw900,
                                        ),
                                        Text(
                                          'Hapus Semua',
                                          style: heading3(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
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
                          // physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: orderInventory.length,
                          itemBuilder: (context, index) {
                            // Mendapatkan data dari dataPemakaian
                            final Map<String, dynamic> data =
                                orderInventory[index];
                            final productId = data['id'];
                            final isSelected = selectedDataPemakaian
                                .containsKey(productId);

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: size12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: bnw300, width: 1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Opacity(
                                    opacity: 0,
                                    child: InkWell(
                                      // onTap: () => onTap(isSelected, index),
                                      onTap: () {
                                        // onTap(
                                        //   isSelected,
                                        //   index,
                                        //   productId,
                                        // );
                                        // // log(data.name.toString());
                                        // // print(dataProduk.isActive);

                                        // print(listProduct);
                                      },
                                      child: SizedBox(
                                        width: 50,
                                        child: _buildSelectIconInventori(
                                          isSelected!,
                                          data,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Expanded(
                                  //   flex: 4,
                                  //   child: Text(
                                  //     data['name'] ?? '',
                                  //     style: heading4(
                                  //       FontWeight.w400,
                                  //       bnw900,
                                  //       'Outfit',
                                  //     ),
                                  //     maxLines: 3,
                                  //     overflow: TextOverflow.ellipsis,
                                  //   ),
                                  // ),
                                  // SizedBox(width: size16),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      data['unit'] ?? '',
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
                                      '${data['unit_name'] ?? ''}',
                                      // '${((double.tryParse(data['unit_factor'].toString().replaceAll(',', '.')) ?? 0) * (num.tryParse(data['qty'].toString()) ?? 0)).toStringAsFixed(2)}',
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
            if (selectedDataPemakaian.isEmpty) {
              selectedDataPemakaian.clear();
            }
            qtyController = List.generate(
              dataPemakaian.length,
              (index) => TextEditingController(),
            );
            hargaSatuanControllers = List.generate(
              dataPemakaian.length,
              (index) => TextEditingController(),
            );
            textController = List.generate(
              dataPemakaian.length,
              (index) => TextEditingController(text: '-'),
            );

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
                                      FontWeight.w400,
                                      bnw500,
                                      'Outfit',
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
                                  ),
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
                                                    // print(
                                                    // "tapped ${unitList[index].id}");
                                                    // print(
                                                    //     'Checkbox changed: ${item['unit_name']}');
                                                    if (value == true) {
                                                      selectedDataPemakaian[item['id']] = {
                                                        "inventory_master_id":
                                                            item['id'],
                                                        "unit":
                                                            item['name_item'],
                                                        "qty": 0,
                                                        "unit_conversion_id":
                                                            item['unit_conversion_id'],
                                                        // unitList[index]
                                                        //     .id
                                                        //     .toString(),
                                                        "unit_name":
                                                            item['unit_name'],
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
                                                  'Outfit',
                                                ),
                                              ),
                                              subtitle: Text(
                                                item['unit_name'] ?? '',
                                                style: heading4(
                                                  FontWeight.w400,
                                                  bnw700,
                                                  'Outfit',
                                                ),
                                              ),
                                              trailing: Icon(
                                                selectedDataPemakaian
                                                        .containsKey(item['id'])
                                                    ? Icons.expand_less
                                                    : Icons.expand_more,
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  addNewItem();
                                                  if (selectedDataPemakaian
                                                      .containsKey(
                                                        item['id'],
                                                      )) {
                                                    selectedDataPemakaian
                                                        .remove(item['id']);
                                                  } else {
                                                    selectedDataPemakaian[item['id']] =
                                                        {
                                                          "inventory_master_id":
                                                              item['id'],
                                                          "qty": 0,
                                                          "unit":
                                                              item['name_item'],
                                                          "unit_conversion_id":
                                                              '',
                                                          // unitList[index]
                                                          //     .id
                                                          //     .toString(),
                                                          "unit_name":
                                                              item['unit_name'],
                                                        };
                                                  }
                                                });
                                              },
                                            ),
                                            if (selectedDataPemakaian
                                                .containsKey(item['id']))
                                              Container(
                                                padding: EdgeInsets.all(size8),
                                                decoration: BoxDecoration(
                                                  color: primary100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        size8,
                                                      ),
                                                ),

                                                //ubah cu
                                                child: Column(
                                                  children: [
                                                    // Row(
                                                    //   children: [
                                                    //     Row(
                                                    //       children: [
                                                    //         Text(
                                                    //           'Harga Satuan      : ',
                                                    //           style: heading4(
                                                    //               FontWeight
                                                    //                   .w400,
                                                    //               bnw900,
                                                    //               'Outfit'),
                                                    //         ),
                                                    //         // Text(
                                                    //         //   '*',
                                                    //         //   style: heading4(
                                                    //         //       FontWeight.w400,
                                                    //         //       danger500,
                                                    //         //       'Outfit'),
                                                    //         // ),
                                                    //       ],
                                                    //     ),
                                                    //     SizedBox(
                                                    //         width: size12),
                                                    //     SizedBox(
                                                    //       key:
                                                    //           ValueKey(index),
                                                    //       width: 120,
                                                    //       child: TextField(
                                                    //         controller:
                                                    //             hargaSatuanControllers[
                                                    //                 index],
                                                    //         // onTap: () {
                                                    //         //   FocusScope.of(
                                                    //         //           context)
                                                    //         //       .requestFocus(
                                                    //         //           focusNodeHarga);
                                                    //         // },
                                                    //         decoration:
                                                    //             InputDecoration(
                                                    //           focusedBorder:
                                                    //               UnderlineInputBorder(
                                                    //             borderSide:
                                                    //                 BorderSide(
                                                    //               width: 2,
                                                    //               color:
                                                    //                   primary500,
                                                    //             ),
                                                    //           ),
                                                    //           focusColor:
                                                    //               primary500,
                                                    //           hintText:
                                                    //               'Cth : 10.000',
                                                    //           hintStyle:
                                                    //               heading2(
                                                    //             FontWeight
                                                    //                 .w600,
                                                    //             bnw400,
                                                    //             'Outfit',
                                                    //           ),
                                                    //         ),
                                                    //         onChanged:
                                                    //             (value) {
                                                    //           setState(() {});
                                                    //           selectedDataPemakaian[
                                                    //                   item[
                                                    //                       'id']]![
                                                    //               'price'] = value;
                                                    //         },
                                                    //         keyboardType:
                                                    //             TextInputType
                                                    //                 .number,
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    // SizedBox(height: size12),
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Qty      : ',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            // Text(
                                                            //   '*',
                                                            //   style: heading4(
                                                            //       FontWeight.w400,
                                                            //       danger500,
                                                            //       'Outfit'),
                                                            // ),
                                                          ],
                                                        ),
                                                        SizedBox(width: size12),
                                                        SizedBox(
                                                          width: 120,
                                                          child: TextField(
                                                            controller:
                                                                qtyController[index],
                                                            decoration: InputDecoration(
                                                              focusedBorder:
                                                                  UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                          width:
                                                                              2,
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
                                                                  ),
                                                            ),
                                                            onChanged: (value) {
                                                              selectedDataPemakaian[item['id']]!['qty'] =
                                                                  value;
                                                              setState(() {});
                                                            },
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                          ),
                                                        ),
                                                        SizedBox(width: size12),
                                                        Text(
                                                          '|',
                                                          style: heading3(
                                                            FontWeight.w600,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                        SizedBox(width: size12),
                                                        Text(
                                                          // 'Qty Total : ${qtyController.length}',
                                                          // qtyController.text,
                                                          // (selectedDataPemakaian[dataPemakaian[index]['id']]!['updated_at']) ?? "0",
                                                          '1 qty = ${(double.tryParse(qtyController[index].text.isNotEmpty ? qtyController[index].text : '0') ?? 0) * (double.tryParse(selectedDataPemakaian[dataPemakaian[index]['id']]?['unit_factor'] ?? '0.0') ?? 0.0)} ${item['unit_name']}',

                                                          // '1 qty = ${dataPemakaian.isNotEmpty && index < dataPemakaian.length && index < unitList.length ? ((int.tryParse(qtyController[index].text) ?? 0) * (double.tryParse(selectedDataPemakaian[dataPemakaian[index]['id']]?['unit_factor']?.replaceAll(',', '.') ?? "0.0") ?? 0.0)) : 0.0} ${item['unit_name']}',
                                                          style: heading4(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size12),
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Unit Convertion : ',
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            // Text(
                                                            //   '*',
                                                            //   style: heading4(
                                                            //       FontWeight
                                                            //           .w400,
                                                            //       danger500,
                                                            //       'Outfit'),
                                                            // ),
                                                          ],
                                                        ),
                                                        SizedBox(width: size12),
                                                        SizedBox(
                                                          width: 120,
                                                          child: TextField(
                                                            // enabled: false,
                                                            // controller:
                                                            //     textController,
                                                            readOnly: true,
                                                            decoration: InputDecoration(
                                                              focusedBorder:
                                                                  UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                          width:
                                                                              2,
                                                                          color:
                                                                              primary500,
                                                                        ),
                                                                  ),
                                                              focusColor:
                                                                  primary500,
                                                              hintText:
                                                                  textController[index]
                                                                      .text ??
                                                                  '',
                                                              hintStyle:
                                                                  heading2(
                                                                    FontWeight
                                                                        .w600,
                                                                    bnw800,
                                                                    'Outfit',
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: size12),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            // print(selectedDataPemakaian[
                                                            //     dataPemakaian[
                                                            //             index]
                                                            //         [
                                                            //         'id']]!['unit']);
                                                            final selected =
                                                                await showModalBottomSheet<
                                                                  UnitConvertionModel
                                                                >(
                                                                  context:
                                                                      context,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.vertical(
                                                                          top: Radius.circular(
                                                                            size16,
                                                                          ),
                                                                        ),
                                                                  ),
                                                                  builder: (context) {
                                                                    return Column(
                                                                      children: [
                                                                        Expanded(
                                                                          child: ListView(
                                                                            padding: EdgeInsets.all(
                                                                              size16,
                                                                            ),
                                                                            children: unitList.map((
                                                                              unit,
                                                                            ) {
                                                                              return ListTile(
                                                                                title: Text(
                                                                                  unit.name,
                                                                                ),
                                                                                leading: Icon(
                                                                                  PhosphorIcons.radio_button,
                                                                                ),
                                                                                onTap: () {
                                                                                  print(
                                                                                    selectedDataPemakaian[item['id']],
                                                                                  );
                                                                                  textController[index].text = unit.name;

                                                                                  // Update hanya pada item yang sedang aktif (index)
                                                                                  selectedDataPemakaian[item['id']]!['unit'] = item['name_item'];
                                                                                  selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_name'] = unit.name;
                                                                                  selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_factor'] = unit.conversionFactor;
                                                                                  selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_conversion_id'] = unit.id;
                                                                                  // Jika ingin menyimpan id juga:
                                                                                  selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_conversion_id'] = unit.id.isEmpty
                                                                                      ? null
                                                                                      : unit.id;

                                                                                  Navigator.pop(
                                                                                    context,
                                                                                    unit,
                                                                                  );
                                                                                  setState(
                                                                                    () {},
                                                                                  );
                                                                                },
                                                                              );
                                                                            }).toList(),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              double.infinity,
                                                                          padding: EdgeInsets.all(
                                                                            size12,
                                                                          ),
                                                                          child: GestureDetector(
                                                                            onTap: () {
                                                                              textController[index].text = '-';
                                                                              // selectedDataPemakaian[dataPemakaian[index]['id']]!['unit'] = '';
                                                                              // selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_name'] = '';
                                                                              selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_factor'] = '';
                                                                              selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_conversion_id'] = '';

                                                                              setState(
                                                                                () {},
                                                                              );
                                                                              Navigator.pop(
                                                                                context,
                                                                              );
                                                                            },
                                                                            child: buttonXL(
                                                                              Center(
                                                                                child: Text(
                                                                                  'Hapus',
                                                                                  style: heading3(
                                                                                    FontWeight.w600,
                                                                                    bnw100,
                                                                                    'Outfit',
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              double.infinity,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );

                                                            if (selected !=
                                                                null) {
                                                              unitController
                                                                      .text =
                                                                  selected.name;
                                                              selectedUnit =
                                                                  selected;

                                                              setState(() {});
                                                            }
                                                          },
                                                          child: Icon(
                                                            PhosphorIcons
                                                                .caret_down,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size12),
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
                                      style: heading3(
                                        FontWeight.w600,
                                        primary500,
                                        'Outfit',
                                      ),
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
                                    orderInventory = selectedDataPemakaian
                                        .values
                                        .toList();

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
                                        FontWeight.w600,
                                        bnw100,
                                        'Outfit',
                                      ),
                                    ),
                                  ),
                                  double.infinity,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          child: SizedBox(
            width: double.infinity,
            child: buttonXLoutline(
              Center(
                child: Text(
                  'Tambah',
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
                  List<Map<String, dynamic>> convertedOrderInventory =
                      selectedDataPemakaian.values.map((e) {
                        final quantityValue =
                            double.tryParse(e['qty'].toString())?.toInt() ?? 0;

                        // Remove qty, set quantity_needed
                        final newMap = {...e};
                        newMap.remove('qty'); // ✅ Hapus qty lama
                        newMap['quantity_needed'] =
                            quantityValue; // ✅ Pakai quantity_needed

                        return newMap;
                      }).toList();

                  createBOM(
                    context,
                    widget.token,
                    '',
                    judulPembelian.text,
                    searchProductID.text,
                    convertedOrderInventory,
                  ).then((value) {
                    if (value == '00') {
                      // _pageController.jumpToPage(0);
                      convertedOrderInventory.clear();
                      judulPembelian.clear();
                      searchProductID.clear();
                      listProduct.clear();
                      tambahProdukCon.clear();
                      orderInventory.clear();

                      setState(() {});
                      initState();
                    }
                  });
                  print(convertedOrderInventory);
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
                  List<Map<String, dynamic>> convertedOrderInventory =
                      selectedDataPemakaian.values.map((e) {
                        final quantityValue =
                            double.tryParse(e['qty'].toString())?.toInt() ?? 0;

                        // Remove qty, set quantity_needed
                        final newMap = {...e};
                        newMap.remove('qty'); // ✅ Hapus qty lama
                        newMap['quantity_needed'] =
                            quantityValue; // ✅ Pakai quantity_needed

                        return newMap;
                      }).toList();
                  createBOM(
                    context,
                    widget.token,
                    '',
                    judulPembelian.text,
                    searchProductID.text,
                    convertedOrderInventory,
                  ).then((value) {
                    if (value == '00') {
                      _pageController.jumpToPage(0);
                      convertedOrderInventory.clear();

                      setState(() {});
                      initState();
                    }
                  });
                  print(convertedOrderInventory);
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
        ),
      ],
    );
  }

  tambahUnitConvertion() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      getDataProduk(['']);
                      orderInventory.clear();
                      // pagesOn = 0;
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
                        'Tambah Unit Convertion',
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        'Unit Convertion',
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
                          bottom: BorderSide(width: 1.5, color: bnw500),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            fieldTambahBahan(
                              'Nama Konversi',
                              nameConController,
                              'Box',
                            ),
                            SizedBox(height: size16),
                            fieldTambahBahanNumber(
                              'Konversi Faktor',
                              faktorCon,
                              '12',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: size16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  print(orderInventory);
                  setState(() {
                    createUnitConvertion(
                      context,
                      widget.token,
                      '',
                      nameConController.text,
                      faktorCon.text,
                    ).then((value) {
                      if (value == '00') {
                        // _pageController.jumpToPage(0);
                        orderInventory.clear();

                        nameConController.clear();
                        faktorCon.clear();

                        setState(() {});
                        initState();
                      }
                    });
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
                  createUnitConvertion(
                    context,
                    widget.token,
                    '',
                    nameConController.text,
                    faktorCon.text,
                  ).then((value) {
                    if (value == '00') {
                      _pageController.jumpToPage(0);
                      orderInventory.clear();

                      nameConController.clear();
                      faktorCon.clear();

                      setState(() {});
                      initState();
                    }
                  });
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
        ),
      ],
    );
  }

  ubahUnitConvertion() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      getDataProduk(['']);
                      orderInventory.clear();
                      pagesOn = 0;
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
                        'Ubah Unit Convertion',
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        'Unit Convertion',
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
                          bottom: BorderSide(width: 1.5, color: bnw500),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            fieldTambahBahan(
                              'Nama Konversi',
                              nameUnitConUbah,
                              'Box',
                            ),
                            SizedBox(height: size16),
                            fieldTambahBahanNumber(
                              'Konversi Faktor',
                              faktorConUnitUbah,
                              '12',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: size16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // int hasil = double.parse(faktorConUnitUbah.text).toInt();

                  updateUnitConvertion(
                    context,
                    widget.token,
                    '',
                    unitIdUbah,
                    nameUnitConUbah.text,
                    '',
                    faktorConUnitUbah.text,
                  ).then((value) {
                    if (value == '00') {
                      _pageController.jumpToPage(0);
                      orderInventory.clear();

                      nameConController.clear();
                      faktorCon.clear();

                      nameUnitConUbah.clear();
                      faktorConUnitUbah.clear();

                      setState(() {});
                      initState();
                    }
                  });

                  //  print(hasil);
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
        ),
      ],
    );
  }

  orderBy(BuildContext context) {
    return IntrinsicWidth(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showModalBottomSheet(
              constraints: const BoxConstraints(maxWidth: double.infinity),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context, setState) => IntrinsicHeight(
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
                                SizedBox(height: 20),
                                Text(
                                  'Pilih Urutan',
                                  style: heading3(
                                    FontWeight.w400,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Wrap(
                                  children: List<Widget>.generate(
                                    orderByProductText.length,
                                    (int index) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: size16),
                                        child: ChoiceChip(
                                          padding: EdgeInsets.symmetric(
                                            vertical: size12,
                                          ),
                                          backgroundColor: bnw100,
                                          selectedColor: primary100,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color:
                                                  valueOrderByProduct == index
                                                  ? primary500
                                                  : bnw300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              size8,
                                            ),
                                          ),
                                          label: Text(
                                            orderByProductText[index],
                                            style: heading4(
                                              FontWeight.w400,
                                              valueOrderByProduct == index
                                                  ? primary500
                                                  : bnw900,
                                              'Outfit',
                                            ),
                                          ),
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
                                textvalueOrderByBahan =
                                    orderByBahanInventory[valueOrderByProduct];
                                orderByBahanInventory[valueOrderByProduct];
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
                style: heading3(FontWeight.w600, bnw900, 'Outfit'),
              ),
              Text(
                ' dari $textOrderBy',
                style: heading3(FontWeight.w400, bnw900, 'Outfit'),
              ),
              SizedBox(width: size12),
              Icon(PhosphorIcons.caret_down, color: bnw900, size: size24),
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

  Widget _buildSelectIcon(bool isSelected, data) {
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
    setState(() {
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
    });
  }

  fieldTambahBahan(title, mycontroller, hintText) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: body1(FontWeight.w500, bnw900, 'Outfit')),
              Text(' *', style: body1(FontWeight.w700, red500, 'Outfit')),
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
                  borderSide: BorderSide(width: 2, color: primary500),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: size12),
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1.5, color: bnw500),
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

  void showProductSelector(
    BuildContext context,
    String token,
    List<String> merchid,
    TextEditingController controller,
  ) async {
    final products = await getProduct(context, token, '', merchid, '');

    if (products != null && products.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return SizedBox(
            height: 400,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(product.productImage ?? ''),
                    onBackgroundImageError: (_, __) {},
                  ),
                  title: Text(product.name ?? '-'),
                  subtitle: Text(product.typeproducts?.toString() ?? ''),
                  onTap: () {
                    // Isi controller dan tutup sheet
                    controller.text = product.productid ?? '';
                    tambahProdukCon.text = product.name ?? '';

                    // ubahProdukBOM.text = product.name ?? '';
                    ubahProdukBOMid = product.productid ?? '';
                    Navigator.pop(context);
                  },
                );
              },
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Produk tidak ditemukan')));
    }
  }

  fieldTambahProductID(title, mycontroller, hintText) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: body1(FontWeight.w500, bnw900, 'Outfit')),
              Text('', style: body1(FontWeight.w700, red500, 'Outfit')),
            ],
          ),
          IntrinsicHeight(
            child: TextFormField(
              readOnly: true,
              enabled: false,
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
                  borderSide: BorderSide(width: 2, color: primary500),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: size12),
                isDense: true,
                suffixIconConstraints: BoxConstraints(
                  minHeight: 36,
                  minWidth: 36,
                ),
                suffixIcon: Icon(PhosphorIcons.caret_down),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1.5, color: bnw500),
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

  fieldTambahBahanNumber(title, mycontroller, hintText) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: body1(FontWeight.w500, bnw900, 'Outfit')),
              Text(' *', style: body1(FontWeight.w700, red500, 'Outfit')),
            ],
          ),
          IntrinsicHeight(
            child: TextFormField(
              cursorColor: primary500,
              keyboardType: TextInputType.number,
              style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              controller: mycontroller,
              onSaved: (value) {
                mycontroller.text = value;
                setState(() {});
              },
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color: primary500),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: size12),
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1.5, color: bnw500),
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
}
