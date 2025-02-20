import 'dart:async';

import 'package:amio/models/inventoriModel/pembelianInventoriModel.dart';
import 'package:amio/models/produkmodel.dart';
import 'package:amio/pageTablet/tokopage/sidebar/inventoriToko/inventoriTokoPage.dart';
import 'package:amio/pageTablet/tokopage/sidebar/inventoriToko/pembelianTokoPage.dart';
import 'package:amio/pageTablet/tokopage/sidebar/produkToko/produk.dart';
import 'package:amio/services/apimethod.dart';
import 'package:amio/services/checkConnection.dart';
import 'package:amio/utils/component/component_button.dart';
import 'package:amio/utils/component/component_color.dart';
import 'package:amio/utils/component/component_orderBy.dart';
import 'package:amio/utils/component/component_showModalBottom.dart';
import 'package:amio/utils/component/component_size.dart';
import 'package:amio/utils/component/component_snackbar.dart';
import 'package:amio/utils/component/component_textHeading.dart';
import 'package:amio/utils/component/skeletons.dart';
import 'package:amio/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';

class InventoriPageTest extends StatefulWidget {
  String token;
  InventoriPageTest({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<InventoriPageTest> createState() => _InventoriPageTestState();
}

class _InventoriPageTestState extends State<InventoriPageTest>
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
  Map<int, bool> selectedFlag = {};
  List<String> cartProductIds = [];

  int pagesOn = 0;

  List<Map<String, String>> cartMap = [];

  double expandedPage = 0;

  int _selectedIndex = -1;

  TextEditingController tambahController = TextEditingController();

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
    _tabController = TabController(length: 2, vsync: this);
    checkConnection(context);
    getMasterDataTokoAndUpdateState();

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
              tambahPembelian(),
              tambahPemakaian(),
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
                        pagesOn == 0
                            ? _pageController.jumpToPage(2)
                            : _pageController.jumpToPage(3);
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => TestPageAsoy(),));
                      },
                      child: buttonXL(
                        Row(
                          children: [
                            Icon(PhosphorIcons.plus, color: bnw100),
                            SizedBox(width: size16),
                            Text(
                              pagesOn == 0 ? 'Persediaan' : 'Sesuaikan',
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
                            text: 'Persediaan',
                          ),
                          Tab(
                            text: 'Sesuaikan',
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
                            PemesananPage(token: widget.token),
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
                              child: Container(
                                child: Text(
                                  'Tanggal Persediaan',
                                  style: heading4(
                                      FontWeight.w700, bnw100, 'Outfit'),
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            SizedBox(width: size16),
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
                                  // padding: EdgeInsets.symmetric(
                                  //     horizontal: size16, vertical: size12),
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
                                              datasProduk![index]
                                                      .activityDate ??
                                                  '',
                                              style: heading4(FontWeight.w600,
                                                  bnw900, 'Outfit'),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: size120),
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
                'Persediaan yang akan dipesan',
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
                  setState(() {
                    createPembelian(
                      context,
                      widget.token,
                      tanggalAwal,
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
                      pagesOn = 1;
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
                        'Tambah Sesuaikan',
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
                  print(dataPemakaian);
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
}
