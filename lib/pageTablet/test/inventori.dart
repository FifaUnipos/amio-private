import 'dart:async';

import 'package:amio/models/produkmodel.dart';
import 'package:amio/pageTablet/tokopage/sidebar/produkToko/produk.dart';
import 'package:amio/services/apimethod.dart';
import 'package:amio/services/checkConnection.dart';
import 'package:amio/utils/component/component_button.dart';
import 'package:amio/utils/component/component_color.dart';
import 'package:amio/utils/component/component_orderBy.dart';
import 'package:amio/utils/component/component_showModalBottom.dart';
import 'package:amio/utils/component/component_size.dart';
import 'package:amio/utils/component/component_textHeading.dart';
import 'package:amio/utils/component/skeletons.dart';
import 'package:amio/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';

class InventoriPage extends StatefulWidget {
  String token;
  InventoriPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<InventoriPage> createState() => _InventoriPageState();
}

class _InventoriPageState extends State<InventoriPage>
    with TickerProviderStateMixin {
  PageController _pageController = new PageController();
  TextEditingController searchController = TextEditingController();
  String selectedValue = 'Urutkan';
  TabController? _tabController;
  String checkFill = 'kosong';
  bool isSelectionMode = false;
  List<String>? productIdCheckAll;
  List<String> listProduct = List.empty(growable: true);
  List<ModelDataProduk>? datasProduk;
  Map<int, bool> selectedFlag = {};

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    checkConnection(context);

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
    return datasProduk =
        await getProduct(context, widget.token, '', value, textvalueOrderBy);
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
          child: Padding(
            padding: EdgeInsets.all(size16),
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
                            'Transaksi',
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
                                margin: EdgeInsets.only(
                                    left: size20, right: size12),
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
                          // _pageController.jumpToPage(1);
                        },
                        child: buttonXL(
                          Row(
                            children: [
                              Icon(PhosphorIcons.plus, color: bnw100),
                              SizedBox(width: size16),
                              Text(
                                'Persediaan',
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
                          labelStyle:
                              heading2(FontWeight.w400, bnw900, 'Outfit'),
                          physics: NeverScrollableScrollPhysics(),
                          onTap: (value) {
                            if (value == 0) {
                              _pageController.animateToPage(
                                0,
                                duration: Duration(milliseconds: 10),
                                curve: Curves.ease,
                              );
                            } else if (value == 1) {
                              _pageController.animateToPage(
                                2,
                                duration: Duration(milliseconds: 10),
                                curve: Curves.ease,
                              );
                            }
                            setState(() {});
                          },
                          tabs: [
                            Tab(
                              text: 'Persediaan',
                            ),
                            Tab(
                              text: 'Pemesanan',
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
              buttonLoutlineColor(
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.archive_box_fill,
                        color: orange500,
                        size: size24,
                      ),
                      SizedBox(width: size12),
                      Text(
                        'Persediaan Habis : 1',
                        style: TextStyle(
                          color: orange500,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  orange100,
                  orange500),
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
                                  'Info Produk',
                                  style: heading4(
                                      FontWeight.w700, bnw100, 'Outfit'),
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
                                      FontWeight.w600, bnw100, 'Outfit'),
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
                                      FontWeight.w600, bnw100, 'Outfit'),
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width / 18,
                                minWidth:
                                    MediaQuery.of(context).size.width / 18,
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
                                ModelDataProduk data = datasProduk![index];
                                selectedFlag[index] =
                                    selectedFlag[index] ?? false;
                                bool? isSelected = selectedFlag[index];
                                final dataProduk = datasProduk![index];
                                productIdCheckAll = datasProduk!
                                    .map((data) => data.productid!)
                                    .toList();

                                return Column(
                                  children: [
                                    Container(
                                      // padding: EdgeInsets.symmetric(
                                      //     horizontal: size16, vertical: size12),
                                      decoration: BoxDecoration(
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
                                                dataProduk.productid,
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
                                          Expanded(
                                            flex: 4,
                                            child: Container(
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 60,
                                                    height: 60,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size8),
                                                      child: datasProduk![index]
                                                                  .productImage !=
                                                              null
                                                          ? Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                      size8),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            size8),
                                                                child: Image
                                                                    .network(
                                                                  datasProduk![
                                                                          index]
                                                                      .productImage
                                                                      .toString(),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      SizedBox(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                            'assets/logoProduct.svg'),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : Icon(
                                                              Icons.person,
                                                              size: 60,
                                                            ),
                                                    ),
                                                  ),
                                                  SizedBox(width: size16),
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          datasProduk![index]
                                                                  .name ??
                                                              '',
                                                          style: heading4(
                                                              FontWeight.w600,
                                                              bnw900,
                                                              'Outfit'),
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          datasProduk![index]
                                                                  .typeproducts ??
                                                              '',
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
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
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    size8,
                                                minWidth: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    size8,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  datasProduk![index]
                                                              .discount ==
                                                          0
                                                      ? Text(
                                                          FormatCurrency.convertToIdr(
                                                                  datasProduk![
                                                                          index]
                                                                      .price_after)
                                                              .toString(),
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        )
                                                      : Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              FormatCurrency.convertToIdr(
                                                                      datasProduk![
                                                                              index]
                                                                          .price_after)
                                                                  .toString(),
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size4),
                                                            Text(
                                                              FormatCurrency.convertToIdr(
                                                                      datasProduk![
                                                                              index]
                                                                          .price)
                                                                  .toString(),
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  body3lineThrough(
                                                                      FontWeight
                                                                          .w400,
                                                                      bnw900,
                                                                      'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size4),
                                                            datasProduk![index]
                                                                        .discount_type ==
                                                                    'price'
                                                                ? Text(
                                                                    FormatCurrency.convertToIdr(
                                                                            datasProduk![index].discount)
                                                                        .toString(),
                                                                    maxLines: 3,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: body2(
                                                                        FontWeight
                                                                            .w700,
                                                                        danger500,
                                                                        'Outfit'),
                                                                  )
                                                                : Text(
                                                                    '${datasProduk![index].discount}%',
                                                                    maxLines: 3,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: body2(
                                                                        FontWeight
                                                                            .w700,
                                                                        danger500,
                                                                        'Outfit'),
                                                                  ),
                                                          ],
                                                        ),
                                                  // datasProduk![index]
                                                  //             .discount_type ==
                                                  //         'percentage'
                                                  //     ? Text(
                                                  //         '${datasProduk![index].discount}%',
                                                  //         style: body3(
                                                  //           FontWeight.w700,
                                                  //           danger500,
                                                  //           'Outfit',
                                                  //         ),
                                                  //       )
                                                  //     : Text(
                                                  //         FormatCurrency
                                                  //             .convertToIdr(
                                                  //           datasProduk![index]
                                                  //               .discount,
                                                  //         ),
                                                  //         style: body3(
                                                  //           FontWeight.w700,
                                                  //           danger500,
                                                  //           'Outfit',
                                                  //         ),
                                                  //       ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: size16),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    size8,
                                                minWidth: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    size8,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  datasProduk![index]
                                                              .discount ==
                                                          0
                                                      ? Text(
                                                          FormatCurrency.convertToIdr(
                                                                  datasProduk![
                                                                          index]
                                                                      .price_online_shop_after)
                                                              .toString(),
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        )
                                                      : Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              FormatCurrency.convertToIdr(
                                                                      datasProduk![
                                                                              index]
                                                                          .price_online_shop_after)
                                                                  .toString(),
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size4),
                                                            Text(
                                                              FormatCurrency.convertToIdr(
                                                                      datasProduk![
                                                                              index]
                                                                          .price_online_shop)
                                                                  .toString(),
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  body3lineThrough(
                                                                      FontWeight
                                                                          .w400,
                                                                      bnw900,
                                                                      'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size4),
                                                            datasProduk![index]
                                                                        .discount_type ==
                                                                    'price'
                                                                ? Text(
                                                                    FormatCurrency.convertToIdr(
                                                                            datasProduk![index].discount)
                                                                        .toString(),
                                                                    maxLines: 3,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: body2(
                                                                        FontWeight
                                                                            .w700,
                                                                        danger500,
                                                                        'Outfit'),
                                                                  )
                                                                : Text(
                                                                    '${datasProduk![index].discount}%',
                                                                    maxLines: 3,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: body2(
                                                                        FontWeight
                                                                            .w700,
                                                                        danger500,
                                                                        'Outfit'),
                                                                  ),
                                                          ],
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: size16),
                                          SizedBox(width: size16),
                                          SizedBox(
                                            width: 96,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
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
                                                                          .name!,
                                                                      style: heading2(
                                                                          FontWeight
                                                                              .w600,
                                                                          bnw900,
                                                                          'Outfit'),
                                                                    ),
                                                                    Text(
                                                                      dataProduk
                                                                          .typeproducts!,
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
                                                                height: size20),
                                                            GestureDetector(
                                                              behavior:
                                                                  HitTestBehavior
                                                                      .translucent,
                                                              onTap: () async {
                                                                // singleProductId = dataProduk.productid;
                                                                // singleImage = dataProduk.productImage;

                                                                // print(singleProductId);
                                                                // // getSingle(dataProduk
                                                                // //     .productid);
                                                                // getSingleProduct(context, widget.token, '', dataProduk.productid, setState).then(
                                                                //   (value) async {
                                                                //     if (value == '00') {
                                                                //       conNameProdukEdit.text = nameEditProduk ?? '';
                                                                //       conHargaEdit.text = hargaEditProduk ?? '';
                                                                //       conHargaOnlineEdit.text = hargaEditOnlineProduk ?? '';

                                                                //       dynamic selectableProduct = {
                                                                //         'kodeproduct': kodejenisProductEdit,
                                                                //         'jenisproduct': jenisProductEdit,
                                                                //         'created_by': 'null',
                                                                //         'created_at': 'null',
                                                                //         'updated_at': 'null',
                                                                //         'deleted_at': 'null',
                                                                //       };

                                                                //       _selectProduct(selectableProduct);

                                                                //       onswitchppnEdit = ppnEdit == '0' ? false : true;

                                                                //       onswitchtampikanEdit = tampilEdit == '0' ? false : true;

                                                                //       ppnAktifEdit = ppnEdit == '0' ? "Tidak Aktif" : 'Aktif';

                                                                //       kasirAktifEdit = tampilEdit == '0' ? "Tidak Aktif" : 'Aktif';

                                                                //       onswitchtampikan = dataProduk.isActive == 1 ? true : false;

                                                                //       onswitchppn = dataProduk.isPPN == 1 ? true : false;

                                                                //       await Future.delayed(Duration(seconds: 1));

                                                                //       _pageController.jumpToPage(2);
                                                                //       Navigator.pop(context);

                                                                //       setState(() {});
                                                                //     }
                                                                //   },
                                                                // );
                                                              },
                                                              child:
                                                                  modalBottomValue(
                                                                'Ubah Produk',
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
                                                                            'Yakin Ingin Menghapus Produk?',
                                                                            style: heading1(
                                                                                FontWeight.w600,
                                                                                bnw900,
                                                                                'Outfit'),
                                                                          ),
                                                                          SizedBox(
                                                                              height: size16),
                                                                          Text(
                                                                            'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
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
                                                                                List<String> listProduct = [
                                                                                  dataProduk.productid!
                                                                                ];

                                                                                initState();
                                                                                setState(() {});
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
                                                                              width: size12),
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
                                                                'Hapus Produk',
                                                                PhosphorIcons
                                                                    .trash,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                });
                                              },
                                              child: buttonL(
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(PhosphorIcons
                                                        .pencil_line),
                                                    SizedBox(width: 6),
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
                                                bnw900,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: size16),
                                        ],
                                      ),
                                    ),
                                  ],
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

  Widget _buildSelectIcon(bool isSelected, ModelDataProduk data) {
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
