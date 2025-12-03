import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:unipos_app_335/models/inventoriModel/bomModel.dart';
import 'package:unipos_app_335/models/inventoriModel/unitConvertionModel.dart';
import 'package:unipos_app_335/models/inventoriModel/unitMasterModel.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/produkToko/produk.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/services/checkConnection.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_orderBy.dart';
import 'package:unipos_app_335/utils/component/component_showModalBottom.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/skeletons.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

class UnitConvertionPage extends StatefulWidget {
  String token;
  UnitConvertionPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<UnitConvertionPage> createState() => _InventoriPageTestState();
}

class _InventoriPageTestState extends State<UnitConvertionPage>
    with TickerProviderStateMixin {
  PageController _pageController = new PageController();
  TextEditingController searchController = TextEditingController();
  String selectedValue = 'Urutkan';
  TabController? _tabController;
  String checkFill = 'kosong';
  bool isSelectionMode = false;
  List<String>? productIdCheckAll;
  List<String> listProduct = List.empty(growable: true);
  List<BOMModel>? datasProdukBOM;
  List<UnitConvertionModel>? datasProdukUnit;
  Map<int, bool> selectedFlag = {};
  List<String> cartProductIds = [];

  int pagesOn = 0;

  List<Map<String, String>> cartMap = [];

  double expandedPage = 0;

  int _selectedIndex = -1;

  TextEditingController qtyController = TextEditingController();

  List<UnitConvertionModel> unitList = [];
  UnitConvertionModel? selectedUnit;
  TextEditingController unitController = TextEditingController();
  TextEditingController searchProductID = TextEditingController();

  TextEditingController textController = TextEditingController(text: '-');
  TextEditingController tambahController = TextEditingController();
  TextEditingController judulPembelian = TextEditingController();
  TextEditingController tambahProdukCon = TextEditingController();
  TextEditingController judulPenyesuaian = TextEditingController();

  TextEditingController nameConController = TextEditingController();
  TextEditingController faktorCon = TextEditingController();

  String unitIdUbah = '';

  DateTime? _selectedDate, _selectedDate2;
  String tanggalAwal = '', tanggalAkhir = '';

  List<Map<String, dynamic>> dataPemakaian = [];
  final Map<String, Map<String, dynamic>> selectedDataPemakaian = {};

  List<Map<String, dynamic>> orderInventory = [];

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

  void fetchUnits() async {
    List<UnitConvertionModel> units =
        await getUnitConvertion(widget.token, '', '', '');
    setState(() {
      unitList = units;
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    checkConnection(context);
    getMasterDataTokoAndUpdateState();
    fetchUnits();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        List<String> value = [''];

        await getDataProduk(value);
        getUnit(value);
        log(datasProdukUnit.toString());

        setState(() {
          // log(datasProdukBOM.toString());
          // datasProdukBOM;
          // datasProdukPemesanan;
          datasProdukUnit;
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

  refreshController() {
    judulPembelian.clear();
    judulPenyesuaian.clear();
    setState(() {});
  }

  void fetchBOMSingle(id) async {
    final details = await getDetailBom(
      context,
      widget.token,
      // '',
      id,
    ).then(
      (value) {
        Future.delayed(Duration(seconds: 1)).then((value) {
          _pageController.jumpToPage(4);
          initState();
        });
      },
    );

    dataPemakaian = details.map((detail) {
      return {
        'id': detail['inventory_master_id'],
        'name_item': detail['item_name'],
        'unit_name': detail['unit_name'],
      };
    }).toList();

    // Jika ingin langsung checklist juga:
    for (var detail in details) {
      selectedDataPemakaian[detail['inventory_master_id']] = {
        "inventory_master_id": detail['inventory_master_id'],
        "unit": detail['unit_name'],
        "quantity_needed": detail['quantity_needed'] ?? 0,
        "unit_conversion_id": '',
      };
    }

    setState(() {}); // untuk render ulang jika di dalam StatefulWidget
  }

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
              Row(
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
                                    'Bill Of Material',
                                    style: heading1(
                                        FontWeight.w700, bnw900, 'Outfit'),
                                  ),
                                  Text(
                                    nameToko ?? '',
                                    style: heading3(
                                        FontWeight.w300, bnw900, 'Outfit'),
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
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: size12),
                                      isDense: true,
                                      filled: true,
                                      fillColor: bnw200,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(size8),
                                        borderSide: BorderSide(
                                          color: bnw300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(size8),
                                        borderSide: BorderSide(
                                          width: 2,
                                          color: primary500,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(size8),
                                        borderSide: BorderSide(
                                          color: bnw300,
                                        ),
                                      ),
                                      prefixIcon: Container(
                                        margin: EdgeInsets.only(
                                            left: size20, right: size12),
                                        child: Icon(
                                          PhosphorIcons.magnifying_glass,
                                          color: bnw900,
                                          size: size20,
                                        ),
                                      ),
                                      suffixIcon:
                                          searchController.text.isNotEmpty
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
                                      hintText: 'Cari nama BOM',
                                      hintStyle: heading3(
                                          FontWeight.w500, bnw400, 'Outfit'),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: size16),
                              GestureDetector(
                                onTap: () {
                                  refreshController();
                                  pagesOn == 0
                                      ? _pageController.jumpToPage(1)
                                      : _pageController.jumpToPage(2);
                                  // _pageController.jumpToPage(1);
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => TestPageAsoy(),));
                                },
                                child: buttonXL(
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.plus, color: bnw100),
                                      SizedBox(width: size16),
                                      Text(
                                        // 'Buat',
                                        pagesOn == 0 ? 'Produk' : 'Unit',
                                        style: heading3(
                                            FontWeight.w600, bnw100, 'Outfit'),
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
                                  labelStyle: heading2(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                  physics: NeverScrollableScrollPhysics(),
                                  onTap: (value) {
                                    pagesOn = value;
                                    setState(() {});
                                  },
                                  tabs: [
                                    Tab(
                                      text: 'Produk Material',
                                    ),
                                    Tab(
                                      text: 'Unit Conversion',
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
                                      // persediaan(context),
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
                  )
                ],
              ),
              tambahProdukMaterial(),
              tambahUnitConvertion(),
              ubahUnitConvertion(),
              ubahProdukMaterial(),
            ],
          ),
        ),
      ),
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
                                  'Nama Produk',
                                  style: heading4(
                                      FontWeight.w700, bnw100, 'Outfit'),
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
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                  ],
                                ),
                                bnw100,
                                bnw300,
                              ),
                            )
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
                              initState();
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
                                    .map((data) => data.productId!)
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
                                          datasProdukBOM![index].productName ??
                                              '',
                                          style: heading4(FontWeight.w600,
                                              bnw900, 'Outfit'),
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
                                                              datasProdukBOM![
                                                                          index]
                                                                      .title ??
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
                                                              datasProdukBOM![
                                                                          index]
                                                                      .productName ??
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
                                                    SizedBox(height: size24),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        groupIdInventoryPenyesuaianUbah =
                                                            datasProdukBOM![
                                                                    index]
                                                                .productId
                                                                .toString();

                                                        print(datasProdukBOM![
                                                                index]
                                                            .id
                                                            .toString());

                                                        productMaterialIdUbah =
                                                            datasProdukBOM![
                                                                    index]
                                                                .id
                                                                .toString();

                                                        fetchBOMSingle(
                                                          datasProdukBOM![index]
                                                              .id
                                                              .toString(),
                                                        );

                                                        // getSingleBOM(
                                                        //         widget.token,
                                                        //         '',
                                                        //         datasProdukBOM![
                                                        //                 index]
                                                        //             .id
                                                        //             .toString(),
                                                        //         context)
                                                        //     .then(
                                                        //   (value) {
                                                        //     Future.delayed(
                                                        //             Duration(
                                                        //                 seconds:
                                                        //                     1))
                                                        //         .then((value) {
                                                        //       _pageController
                                                        //           .jumpToPage(
                                                        //               4);
                                                        //       initState();
                                                        //     });
                                                        //   },
                                                        // );
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
                                                                            datasProdukBOM![index].id.toString()
                                                                          ];

                                                                          deleteUNIT(context, widget.token, dataBahan, '')
                                                                              .then(
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
                                  'Convertion Factor',
                                  style: heading4(
                                      FontWeight.w700, bnw100, 'Outfit'),
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
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                  ],
                                ),
                                bnw100,
                                bnw300,
                              ),
                            )
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
                                                setState(() {
                                                  onTap(
                                                    isSelected,
                                                    index,
                                                    dataProduk.id,
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
                                          double.tryParse(
                                                  datasProdukUnit![index]
                                                      .conversionFactor)
                                              .toString(),
                                          style: heading4(FontWeight.w600,
                                              bnw900, 'Outfit'),
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
                                                              datasProdukUnit![
                                                                      index]
                                                                  .name
                                                                  .toString(),
                                                              // dataProduk
                                                              //     .nameItem!,
                                                              style: heading2(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw900,
                                                                  'Outfit'),
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
                                                                  context),
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
                                                            datasProdukUnit![
                                                                    index]
                                                                .id
                                                                .toString();

                                                        print(datasProdukUnit![
                                                                index]
                                                            .id
                                                            .toString());

                                                        getSingleUnitConvertion(
                                                          widget.token,
                                                          '',
                                                          datasProdukUnit![
                                                                  index]
                                                              .id
                                                              .toString(),
                                                          context,
                                                        ).then(
                                                          (value) {
                                                            Future.delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            1))
                                                                .then((value) =>
                                                                    _pageController
                                                                        .jumpToPage(
                                                                            3));
                                                          },
                                                        );
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
                                                                        'Outfit'),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          size16),
                                                                  Text(
                                                                    'Data Unit yang sudah dihapus tidak dapat dikembalikan lagi.',
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
                                                                            datasProdukUnit![index].id.toString()
                                                                          ];

                                                                          log(dataBahan
                                                                              .toString());

                                                                          deleteUNIT(context, widget.token, dataBahan, '')
                                                                              .then(
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

  tambahProdukMaterial() {
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
                        'Tambah Bill Of Material',
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
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                print('hello');
                                showProductSelector(
                                    context, widget.token, [], searchProductID);
                              },
                              child: Container(
                                child: fieldTambahProductID(
                                  'Produk',
                                  tambahProdukCon,
                                  'Matcha',
                                ),
                              ),
                            )
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
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Qty',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Unit Convertion',
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
                                  '${listProduct.length}/${datasProdukBOM!.length} Produk Terpilih',
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
                                    data['quantity_needed'].toString(),
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
                                    data['unit'].toString(),
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
                                                          "unit":
                                                              item['name_item'],
                                                          "quantity_needed": 0,
                                                          "unit_conversion_id":
                                                              '',
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
                                                        "unit":
                                                            item['name_item'],
                                                        "unit_conversion_id":
                                                            '',
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
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Qty      : ',
                                                                style: heading4(
                                                                    FontWeight
                                                                        .w400,
                                                                    bnw900,
                                                                    'Outfit'),
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
                                                              width: size12),
                                                          SizedBox(
                                                            width: 120,
                                                            child: TextField(
                                                              // controller:
                                                              //     qtyController,
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
                                                                ),
                                                              ),
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {});
                                                                selectedDataPemakaian[
                                                                        item[
                                                                            'id']]![
                                                                    'quantity_needed'] = value;
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width: size12),
                                                          Text(
                                                            '|',
                                                            style: heading3(
                                                                FontWeight.w600,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          SizedBox(
                                                              width: size12),
                                                          Text(
                                                            qtyController.text,
                                                            // (double.tryParse(
                                                            //           datasProdukUnit![
                                                            //                   index]
                                                            //               .conversionFactor,
                                                            //         )!
                                                            //             .toInt() *
                                                            //         int.parse(
                                                            //             qtyController
                                                            //                 .text))
                                                            //     .toString(),
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit'),
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
                                                                    'Outfit'),
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
                                                              width: size12),
                                                          SizedBox(
                                                            width: 120,
                                                            child: TextField(
                                                              // enabled: false,
                                                              // controller:
                                                              //     textController,
                                                              readOnly: true,
                                                              decoration:
                                                                  InputDecoration(
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
                                                                          textController.text ??
                                                                              '',
                                                                      hintStyle:
                                                                          heading2(
                                                                        FontWeight
                                                                            .w600,
                                                                        bnw800,
                                                                        'Outfit',
                                                                      )),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width: size12),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              final selected =
                                                                  await showModalBottomSheet<
                                                                      UnitConvertionModel>(
                                                                context:
                                                                    context,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.vertical(
                                                                          top: Radius.circular(
                                                                              size16)),
                                                                ),
                                                                builder:
                                                                    (context) {
                                                                  return Column(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            ListView(
                                                                          padding:
                                                                              EdgeInsets.all(size16),
                                                                          children:
                                                                              unitList.map((unit) {
                                                                            return ListTile(
                                                                              title: Text(unit.name),
                                                                              leading: Icon(PhosphorIcons.radio_button),
                                                                              onTap: () {
                                                                                textController.text = unit.name;

                                                                                selectedDataPemakaian[item['id']]!['unit'] = unit.name;

                                                                                // selectedDataPemakaian[item['id']]!['category'] =
                                                                                //     unit.name;
                                                                                // selectedDataPemakaian[item['id']]!['unit_conversion_id'] =
                                                                                //     unit.id;

                                                                                Navigator.pop(context, unit);
                                                                                setState(() {});
                                                                              },
                                                                            );
                                                                          }).toList(),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        padding:
                                                                            EdgeInsets.all(size12),
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            textController.text =
                                                                                '-';

                                                                            selectedDataPemakaian[item['id']]!['unit'] =
                                                                                '';
                                                                            setState(() {});
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              buttonXL(
                                                                            Center(
                                                                              child: Text(
                                                                                'Hapus',
                                                                                style: heading3(FontWeight.w600, bnw100, 'Outfit'),
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
                                                                    .caret_down),
                                                          )
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
                                      print(
                                          "Saved Data: $selectedDataPemakaian");
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
                  createBOM(
                    context,
                    widget.token,
                    '',
                    judulPembelian.text,
                    searchProductID.text,
                    orderInventory,
                  ).then(
                    (value) {
                      if (value == '00') {
                        setState(() {});
                        initState();
                      }
                    },
                  );
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
                  createBOM(
                    context,
                    widget.token,
                    '',
                    judulPembelian.text,
                    searchProductID.text,
                    orderInventory,
                  ).then(
                    (value) {
                      if (value == '00') {
                        _pageController.jumpToPage(0);
                        orderInventory.clear();

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

  ubahProdukMaterial() {
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
                      orderBOMInventoryUbah.clear();
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
                        'Ubah Bill Of Material',
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
                              ubahJudulBOMController,
                              'Pembelian Matcha',
                            ),
                            SizedBox(height: size16),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                // print('hello');
                                showProductSelector(
                                    context, widget.token, [], searchProductID);
                              },
                              child: Container(
                                child: fieldTambahProductID(
                                  'Produk',
                                  ubahProdukBOM,
                                  'Matcha',
                                ),
                              ),
                            )
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
                                SizedBox(
                                  child: GestureDetector(
                                    onTap: () {
                                      // _selectAll(productIdCheckAll);
                                    },
                                    child: SizedBox(
                                      width: 50,
                                      // child: Icon(
                                      //   isSelectionMode
                                      //       ? PhosphorIcons.check
                                      //       : PhosphorIcons.square,
                                      //   color: bnw100,
                                      // ),
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
                                    'Nama',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Qty',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Unit Convertion',
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
                                  '${listProduct.length}/${datasProdukBOM!.length} Produk Terpilih',
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
                        itemCount: orderBOMInventoryUbah.length,
                        itemBuilder: (context, index) {
                          // Mendapatkan data dari dataPemakaian
                          final Map<String, dynamic> data =
                              orderBOMInventoryUbah[index];
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
                                    // child: _buildSelectIconInventori(
                                    //   isSelected!,
                                    //   data,
                                    // ),
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
                                    data['item_name'] ?? '',
                                    // 'hello',
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
                                    double.parse(
                                      data['quantity_needed'],
                                    ).toString(),
                                    // 'helo',
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
                                    data['unit_conversion_id'].toString(),
                                    // 'hello',
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
                                    orderBOMInventoryUbah.removeAt(index);
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
                                                      // print('loro $dataPemakaian');
                                                      if (value == true) {
                                                        selectedDataPemakaian[
                                                            item['id']] = {
                                                          "item_name":
                                                              item['name_item'],
                                                          "unit": item['name'],
                                                          "quantity_needed": 0,
                                                          "unit_conversion_id":
                                                              item[
                                                                  'unit_abbreviation'],
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
                                                        "unit":
                                                            item['unit_name'],
                                                        "unit_conversion_id":
                                                            '',
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
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Unit Convertion : ',
                                                                style: heading4(
                                                                    FontWeight
                                                                        .w400,
                                                                    bnw900,
                                                                    'Outfit'),
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
                                                              width: size12),
                                                          SizedBox(
                                                            width: 120,
                                                            child: TextField(
                                                              // enabled: false,
                                                              // controller:
                                                              //     textController,
                                                              readOnly: true,
                                                              decoration:
                                                                  InputDecoration(
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
                                                                          textController.text ??
                                                                              '',
                                                                      hintStyle:
                                                                          heading2(
                                                                        FontWeight
                                                                            .w600,
                                                                        bnw800,
                                                                        'Outfit',
                                                                      )),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width: size12),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              final selected =
                                                                  await showModalBottomSheet<
                                                                      UnitConvertionModel>(
                                                                context:
                                                                    context,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.vertical(
                                                                          top: Radius.circular(
                                                                              size16)),
                                                                ),
                                                                builder:
                                                                    (context) {
                                                                  return ListView(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            size16),
                                                                    children:
                                                                        unitList
                                                                            .map((unit) {
                                                                      return ListTile(
                                                                        title: Text(
                                                                            unit.name),
                                                                        leading:
                                                                            Icon(PhosphorIcons.radio_button),
                                                                        onTap:
                                                                            () {
                                                                          textController.text =
                                                                              unit.name;

                                                                          selectedDataPemakaian[item['id']]!['unit'] =
                                                                              unit.name;

                                                                          // selectedDataPemakaian[item['id']]!['category'] =
                                                                          //     unit.name;
                                                                          // selectedDataPemakaian[item['id']]!['unit_conversion_id'] =
                                                                          //     unit.id;

                                                                          Navigator.pop(
                                                                              context,
                                                                              unit);
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                      );
                                                                    }).toList(),
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
                                                                    .caret_down),
                                                          )
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
                                                                    'Outfit'),
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
                                                              width: size12),
                                                          SizedBox(
                                                            width: 120,
                                                            child: TextField(
                                                              decoration:
                                                                  InputDecoration(
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
                                                                      )),
                                                              onChanged:
                                                                  (value) {
                                                                selectedDataPemakaian[
                                                                        item[
                                                                            'id']]![
                                                                    'quantity_needed'] = value;
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width: size12),
                                                          Text(
                                                            '|',
                                                            style: heading3(
                                                                FontWeight.w600,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          SizedBox(
                                                              width: size12),
                                                          Text(
                                                            '1 qty = 1 kg',
                                                            style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                        ],
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
                                      orderBOMInventoryUbah =
                                          selectedDataPemakaian.values.toList();

                                      dataPemakaian = orderBOMInventoryUbah;
                                      print(
                                          "Saved Data: $orderBOMInventoryUbah");
                                      print(
                                          "Saved Data: $selectedDataPemakaian");
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
                  'Ubah',
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
            // Expanded(
            //   child: GestureDetector(
            //     onTap: () {
            //       print(orderBOMInventoryUbah);
            //       // setState(() {
            //       //   createPembelian(
            //       //     context,
            //       //     widget.token,
            //       //     tanggalAwal,
            //       //     judulPembelian.text,
            //       //     orderBOMInventoryUbah,
            //       //   );
            //       // });
            //     },
            //     child: buttonXLoutline(
            //       Center(
            //         child: Text(
            //           'Simpan & Tambah Baru',
            //           style: heading3(FontWeight.w600, primary500, 'Outfit'),
            //         ),
            //       ),
            //       double.infinity,
            //       primary500,
            //     ),
            //   ),
            // ),
            // SizedBox(width: size16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  updateBOM(
                    context,
                    widget.token,
                    productMaterialIdUbah,
                    ubahJudulBOMController.text,
                    '',
                    ubahProdukBOMid,
                    orderBOMInventoryUbah,
                  ).then(
                    (value) {
                      if (value == '00') {
                        _pageController.jumpToPage(0);

                        ubahJudulBOMController.clear();
                        ubahProdukBOM.clear();
                        ubahProdukBOMid = '';
                        orderBOMInventoryUbah = [];

                        setState(() {});
                        initState();
                      }
                    },
                  );
                  print(orderBOMInventoryUbah);
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

  tambahUnitConvertion() {
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
                  createUnitConvertion(
                    context,
                    widget.token,
                    '',
                    nameConController.text,
                    faktorCon.text,
                  ).then(
                    (value) {
                      if (value == '00') {
                        _pageController.jumpToPage(0);
                        orderInventory.clear();

                        nameConController.clear();
                        faktorCon.clear();

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

  ubahUnitConvertion() {
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
                  int hasil = double.parse(faktorConUnitUbah.text).toInt();

                  updateUnitConvertion(
                    context,
                    widget.token,
                    '',
                    unitIdUbah,
                    nameUnitConUbah.text,
                    '',
                    hasil.toString(),
                  ).then(
                    (value) {
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
                    },
                  );
               
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

  fieldTambahBahanNumber(title, mycontroller, hintText) {
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
              keyboardType: TextInputType.number,
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

  fieldTambahProductID(title, mycontroller, hintText) {
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
                  borderSide: BorderSide(
                    width: 2,
                    color: primary500,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: size12),
                isDense: true,
                suffixIconConstraints: BoxConstraints(
                  minHeight: 36,
                  minWidth: 36,
                ),
                suffixIcon: Icon(PhosphorIcons.caret_down),
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

  void showProductSelector(BuildContext context, String token,
      List<String> merchid, TextEditingController controller) async {
    final products = await getProduct(context, token, '', merchid, 'asc');

    if (products.isNotEmpty) {
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

                    ubahProdukBOM.text = product.name ?? '';
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Produk tidak ditemukan')));
    }
  }
}
