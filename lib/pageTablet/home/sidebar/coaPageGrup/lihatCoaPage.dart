import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/models/coaModel.dart';
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
import 'package:http/http.dart' as http;
import 'package:flutter_switch/flutter_switch.dart';

class LihatCOAPageGrup extends StatefulWidget {
  String token, nameMerch, merchID;
  PageController pageController;
  LihatCOAPageGrup({
    Key? key,
    required this.token,
    required this.nameMerch,
    required this.merchID,
    required this.pageController,
  }) : super(key: key);

  @override
  State<LihatCOAPageGrup> createState() => _LihatCOAPageGrupState();
}

class _LihatCOAPageGrupState extends State<LihatCOAPageGrup> {
  List<PaymentMethod>? datasCOA;
  PageController _pageController = PageController();
  TextEditingController conNumberCOA = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String _selectedOptionCategory = "Semua";
  String jenisProduct = "Pilih Kategori", kodeProduct = '';

  List<String> dropdownItems = [
    "Semua",
    "Debit",
    "EWallet",
    "Credit",
  ].toSet().toList();

  List<String>? productIdCheckAll;
  String checkFill = 'kosong';

  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};
  List<String> listProduct = List.empty(growable: true);

  late String idCOAUpdate, accountNumberCOAUpdate;
  TextEditingController conNumberCOAUpdate = TextEditingController();

  Timer? _debounce;

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(seconds: 2), () async {
      datasCOA = await getCOAPayment(context, widget.token, textOrderByCOA, '');
      setState(() {});
    });
  }

  @override
  void initState() {
    checkConnection(context);
    _getProductList(_selectedOptionCategory);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      List<String> value = [''];

      await getDataCOA(value);

      setState(() {
        // log(datasCOA.toString());
        datasCOA;
      });

      _pageController = PageController(
        initialPage: 0,
        keepPage: true,
        viewportFraction: 1,
      );
    });
    // TODO: implement initState

    super.initState();
  }

  Future<dynamic> getDataCOA(List<String> value) async {
    return datasCOA = await getCOAPayment(
      context,
      widget.token,
      textOrderByCOA,
      '',
    );
  }

  @override
  void dispose() {
    conNumberCOA.dispose();
    searchController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFalseAvailable = selectedFlag.containsValue(false);

    return WillPopScope(
      onWillPop: () async {
        if (_pageController.page!.round() == 0) {
          showModalBottomExit(context);
          return false;
        } else {
          _pageController.jumpToPage(0);
          return false;
        }
      },
      child: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [pageCOA(isFalseAvailable), tambahCOAToko(), updateCOAToko()],
      ),
    );
  }

  pageCOA(bool isFalseAvailable) {
    List<String> value = [''];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    size: size48,
                    color: bnw900,
                  ),
                ),
                SizedBox(width: size16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COA',
                      style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    Text(
                      widget.nameMerch,
                      style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: size12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: TextField(
                        cursorColor: primary500,
                        textAlignVertical: TextAlignVertical.center,
                        controller: searchController,
                        onChanged: _onChanged,
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
                            borderSide: BorderSide(width: 2, color: primary500),
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
                          hintText: 'Cari nama payment',
                          hintStyle: heading3(
                            FontWeight.w500,
                            bnw400,
                            'Outfit',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: size16),
                  GestureDetector(
                    onTap: () {
                      // refreshDataProduk();
                      idCOAUpdate = "";
                      accountNumberCOAUpdate = "";
                      _pageController.jumpToPage(1);
                    },
                    child: buttonXL(
                      Row(
                        children: [
                          Icon(PhosphorIcons.plus, color: bnw100),
                          SizedBox(width: size16),
                          Text(
                            'COA',
                            style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ],
                      ),
                      0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: size16),
        Row(
          children: [
            // orderBy(context),
            // SizedBox(width: size16),
            orderByCOA(context),
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
                            flex: 2,
                            child: Container(
                              child: Text(
                                'Info COA',
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
                            flex: 4,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width / size8,
                                minWidth:
                                    MediaQuery.of(context).size.width / size8,
                              ),
                              child: Text(
                                'Nomor Akun',
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
                            '${listProduct.length}/${datasCOA!.length} Produk Terpilih',
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
                                          'Yakin Ingin Menghapus Pembayaran?',
                                          style: heading1(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        SizedBox(height: size16),
                                        Text(
                                          'Data COA yang sudah dihapus tidak dapat dikembalikan lagi.',
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
                                              // List<String> listProduct = [
                                              //   dataProduk.productid!
                                              // ];

                                              deleteCOA(
                                                context,
                                                widget.token,
                                                datasCOA,
                                              );
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
                        ],
                      ),
              ),
              datasCOA == null
                  ? Center(
                      child: Text(
                        'Tidak ada data COA',
                        style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                      ),
                    )
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
                            itemCount: datasCOA!.length,
                            itemBuilder: (builder, index) {
                              PaymentMethod data = datasCOA![index];
                              selectedFlag[index] =
                                  selectedFlag[index] ?? false;
                              bool? isSelected = selectedFlag[index];
                              final dataCOAPayment = datasCOA![index];
                              productIdCheckAll = datasCOA!
                                  .map((data) => data.idpaymentmethode!)
                                  .toList();

                              return Column(
                                children: [
                                  Container(
                                    // padding: EdgeInsets.symmetric(
                                    //     horizontal: size16, vertical: size12),
                                    decoration: BoxDecoration(
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
                                        InkWell(
                                          // onTap: () => onTap(isSelected, index),
                                          onTap: () {
                                            onTap(
                                              isSelected!,
                                              index,
                                              dataCOAPayment.idpaymentmethode,
                                            );
                                            // log(data.paymentMethod.toString());
                                            // print(dataCOAPayment.isActive);

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
                                                SizedBox(
                                                  width: 60,
                                                  height: 60,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          size8,
                                                        ),
                                                    child:
                                                        // datasCOA![index]
                                                        //             .productImage !=
                                                        //         null
                                                        //     ? Padding(
                                                        //         padding:
                                                        //             EdgeInsets.all(
                                                        //                 size8),
                                                        //         child: ClipRRect(
                                                        //           borderRadius:
                                                        //               BorderRadius
                                                        //                   .circular(
                                                        //                       size8),
                                                        //           child:
                                                        //               Image.network(
                                                        //             datasCOA![
                                                        //                     index]
                                                        //                 .productImage
                                                        //                 .toString(),
                                                        //             fit: BoxFit
                                                        //                 .cover,
                                                        //             errorBuilder: (context,
                                                        //                     error,
                                                        //                     stackTrace) =>
                                                        //                 SizedBox(
                                                        //               child: SvgPicture
                                                        //                   .asset(
                                                        //                       'assets/logoProduct.svg'),
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       )
                                                        Icon(
                                                          Icons.wallet,
                                                          color: bnw900,
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
                                                        datasCOA![index]
                                                                .paymentMethod ??
                                                            '',
                                                        style: heading4(
                                                          FontWeight.w600,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        datasCOA![index]
                                                                .category ??
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
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            constraints: BoxConstraints(
                                              maxWidth:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  size8,
                                              minWidth:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  size8,
                                            ),
                                            child: Text(
                                              datasCOA![index].accountNumber ??
                                                  '-',
                                              maxLines: 3,
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              style: heading4(
                                                FontWeight.w400,
                                                bnw900,
                                                'Outfit',
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: size16),
                                        SizedBox(
                                          width: 96,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                showModalBottom(
                                                  context,
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height,
                                                  IntrinsicHeight(
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        28.0,
                                                      ),
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
                                                                    dataCOAPayment
                                                                        .paymentMethod!,
                                                                    style: heading2(
                                                                      FontWeight
                                                                          .w600,
                                                                      bnw900,
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    dataCOAPayment
                                                                        .accountNumber!,
                                                                    style: heading4(
                                                                      FontWeight
                                                                          .w400,
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
                                                          SizedBox(
                                                            height: size20,
                                                          ),
                                                          GestureDetector(
                                                            behavior:
                                                                HitTestBehavior
                                                                    .translucent,
                                                            onTap: () async {
                                                              setState(() {
                                                                idCOAUpdate =
                                                                    dataCOAPayment
                                                                        .idpaymentmethode!;

                                                                accountNumberCOAUpdate =
                                                                    dataCOAPayment
                                                                        .accountNumber!;

                                                                conNumberCOAUpdate
                                                                        .text =
                                                                    accountNumberCOAUpdate;

                                                                jenisProduct =
                                                                    dataCOAPayment
                                                                        .paymentMethod!;
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                                whenLoading(
                                                                  context,
                                                                );

                                                                Future.delayed(
                                                                  Duration(
                                                                    seconds: 2,
                                                                  ),
                                                                ).then((value) {
                                                                  _pageController
                                                                      .jumpToPage(
                                                                        2,
                                                                      );
                                                                  closeLoading(
                                                                    context,
                                                                  );
                                                                });
                                                              });
                                                            },
                                                            child: modalBottomValue(
                                                              'Ubah COA',
                                                              PhosphorIcons
                                                                  .pencil_line,
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          GestureDetector(
                                                            behavior:
                                                                HitTestBehavior
                                                                    .translucent,
                                                            onTap: () {
                                                              Navigator.pop(
                                                                context,
                                                              );
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
                                                                          'Yakin Ingin Menghapus Pembayaran?',
                                                                          style: heading1(
                                                                            FontWeight.w600,
                                                                            bnw900,
                                                                            'Outfit',
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              size16,
                                                                        ),
                                                                        Text(
                                                                          'Data COA yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                                          style: heading2(
                                                                            FontWeight.w400,
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
                                                                              List<
                                                                                String
                                                                              >
                                                                              listCOA = [
                                                                                dataCOAPayment.idpaymentmethode!,
                                                                              ];

                                                                              // log(dataCOAPayment.idpaymentmethode!);

                                                                              deleteCOA(
                                                                                context,
                                                                                widget.token,
                                                                                listCOA,
                                                                              );
                                                                              Navigator.of(
                                                                                context,
                                                                              ).pop();

                                                                              initState();
                                                                              setState(
                                                                                () {},
                                                                              );
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
                                                                          width:
                                                                              size12,
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
                                                            child:
                                                                modalBottomValue(
                                                                  'Hapus COA',
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
                                                  Icon(
                                                    PhosphorIcons.pencil_line,
                                                  ),
                                                  SizedBox(width: 6),
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
    );
  }

  tambahCOAToko() {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                // refreshDataProduk();

                // getDataProduk(['']);

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
                  'Tambah COA',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Chart of Accounts akan ditambahkan kedalam Toko yang telah dipilih',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size16),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              kategoriList(context),
              SizedBox(height: size16),
              fieldAddProduk(
                'Nomor Akun',
                '0000-0000-0000-0000',
                conNumberCOA,
                TextInputType.text,
                false,
              ),
              SizedBox(height: size16),
            ],
          ),
        ),
        SizedBox(height: size16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  createCOA(
                    context,
                    widget.token,
                    kodeProduct,
                    conNumberCOA.text,
                  ).then((value) async {
                    if (value == '00') {
                      conNumberCOA.clear();
                      // kodeProduct = "";
                      setState(() {});
                      initState();
                    }
                  });

                  initState();
                  setState(() {});
                },
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Simpan & Tambah Baru',
                      style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ),
                  0,
                  bnw900,
                ),
              ),
            ),
            SizedBox(width: size16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // print(idProduct);
                  createCOA(
                    context,
                    widget.token,
                    kodeProduct,
                    conNumberCOA.text,
                  ).then((value) async {
                    if (value == '00') {
                      await Future.delayed(Duration(seconds: 1));
                      _pageController.jumpToPage(0);
                      setState(() {});
                      initState();
                    }
                  });

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
                  0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  updateCOAToko() {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                // refreshDataProduk();

                // getDataProduk(['']);

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
                  'Ubah COA',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Chart of Accounts akan diperbarui kedalam Toko yang telah dipilih',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size16),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              kategoriList(context),
              SizedBox(height: size16),
              fieldAddProduk(
                'Nomor Akun',
                '0000-0000-0000-0000',
                conNumberCOAUpdate,
                TextInputType.text,
                false,
              ),
              SizedBox(height: size16),
            ],
          ),
        ),
        SizedBox(height: size16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // print(idCOAUpdate);
                  // print(kodeProduct);
                  // print(conNumberCOAUpdate.text);

                  updateCOA(
                    context,
                    widget.token,
                    idCOAUpdate,
                    kodeProduct,
                    conNumberCOAUpdate.text,
                  ).then((value) async {
                    if (value == '00') {
                      await Future.delayed(Duration(seconds: 1));
                      _pageController.jumpToPage(0);
                      setState(() {});
                      initState();
                    }
                  });

                  initState();
                  setState(() {});
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Simpan',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  fieldAddProduk(
    title,
    hint,
    mycontroller,
    TextInputType numberNo,
    bool urgent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: body1(FontWeight.w500, bnw900, 'Outfit')),
            urgent == true
                ? Text(' *', style: body1(FontWeight.w700, red500, 'Outfit'))
                : SizedBox(),
          ],
        ),
        IntrinsicHeight(
          child: TextFormField(
            cursorColor: primary500,
            keyboardType: numberNo,
            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
            controller: mycontroller,
            onChanged: (value) {
              // String formattedValue = formatCurrency(value);
              // conHarga.value = TextEditingValue(
              //   text: formattedValue,
              //   selection:
              //       TextSelection.collapsed(offset: formattedValue.length),
              // );
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
              hintText: 'Cth : $hint',
              hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
            ),
          ),
        ),
      ],
    );
  }

  kategoriList(BuildContext context) {
    bool isKeyboardActive = false;

    return GestureDetector(
      onTap: () {
        setState(() {
          // log(jenisProduct.toString());
          kategoriListForm(context, isKeyboardActive);
        });
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bnw100,
          border: Border(bottom: BorderSide(width: 1.5, color: bnw500)),
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
                      style: heading2(
                        FontWeight.w600,
                        jenisProduct == '' ? bnw500 : bnw900,
                        'Outfit',
                      ),
                    ),
                    Icon(PhosphorIcons.caret_down, color: bnw900),
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
    BuildContext context,
    bool isKeyboardActive,
  ) {
    setState(() {});
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) => FractionallySizedBox(
            heightFactor: isKeyboardActive ? 0.9 : 0.80,
            child: GestureDetector(
              onTap: () => textFieldFocusNode.unfocus(),
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  cursorColor: primary500,
                                  controller: searchController,
                                  focusNode: textFieldFocusNode,
                                  onChanged: (value) {
                                    //   isKeyboardActive = value.isNotEmpty;
                                    // _runSearchProduct(value);
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
                                      borderRadius: BorderRadius.circular(
                                        size8,
                                      ),
                                      borderSide: BorderSide(color: bnw300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        size8,
                                      ),
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: primary500,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        size8,
                                      ),
                                      borderSide: BorderSide(color: bnw300),
                                    ),
                                    suffixIcon: searchController.text.isNotEmpty
                                        ? GestureDetector(
                                            onTap: () {
                                              searchController.text = '';
                                              // _runSearchProduct('');
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
                                      FontWeight.w500,
                                      bnw500,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: size16),
                              buttonXL(
                                Row(
                                  children: [
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isDense: true,
                                        dropdownColor: primary500,
                                        elevation: 1,
                                        borderRadius: BorderRadius.circular(
                                          size8,
                                        ),
                                        value: _selectedOptionCategory,
                                        items: dropdownItems.map((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedOptionCategory = newValue!;
                                          });
                                          initState();
                                        },
                                        style: heading2(
                                          FontWeight.w600,
                                          bnw100,
                                          'Outfit',
                                        ),
                                        iconEnabledColor: Colors.transparent,
                                        iconSize: 0,
                                      ),
                                    ),
                                    Icon(
                                      PhosphorIcons.caret_down,
                                      size: size24,
                                      color: bnw100,
                                    ),
                                  ],
                                ),
                                double.infinity,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            // _getProductList();
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
                                          color: bnw300,
                                          width: width1,
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: size16,
                                      ),
                                      title: Text(
                                        product['paymentReferenceName'] != null
                                            ? capitalizeEachWord(
                                                product['paymentReferenceName']
                                                    .toString(),
                                              )
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
                                          jenisProduct =
                                              product['paymentReferenceName'];

                                          kodeProduct =
                                              product['paymentReferenceId'];

                                          _selectProduct(product);

                                          print(
                                            product['paymentReferenceName'],
                                          );
                                        });
                                      },
                                      onLongPress: () {
                                        // Navigator.pop(context);
                                        // nameKategoriEdit =
                                        //     product['paymentReferenceName'];
                                        // controllerNameEdit.text =
                                        //     product['paymentReferenceName'];
                                        // ubahHapusKategori(product);
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
                          // autoReload();
                          Navigator.pop(context);
                        },
                        child: buttonXXL(
                          Center(
                            child: Text(
                              'Selesai',
                              style: heading2(
                                FontWeight.w600,
                                bnw100,
                                'Outfit',
                              ),
                            ),
                          ),
                          double.infinity,
                        ),
                      ),
                      SizedBox(height: size8),
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

  List? typeproductList;
  List<dynamic>? searchResultListProduct;

  dynamic selectedProduct;
  bool isItemSelected = false;

  // String provinceInfoUrl = '$url/api/typeproduct';
  Future _getProductList(category) async {
    await http
        .post(
          Uri.parse(getCoaRefLink),
          body: {
            "deviceid": identifier,
            "category": category == 'Semua' ? '' : category,
          },
          headers: {"token": widget.token},
        )
        .then((response) {
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
          ?.where(
            (product) => product.toString().toLowerCase().contains(
              searchText.toLowerCase(),
            ),
          )
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

  Widget _buildSelectIcon(bool isSelected, PaymentMethod data) {
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
                                SizedBox(height: size20),
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
                                textvalueOrderBy =
                                    orderByProduct[valueOrderByProduct];
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

  orderByCOA(BuildContext context) {
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
                                SizedBox(height: size20),
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
                                    orderByCOAText.length,
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
                                            orderByCOAText[index] == ''
                                                ? 'Semua'
                                                : orderByCOAText[index],
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
                                print(orderByCOAText[valueOrderByProduct]);

                                textOrderByCOA =
                                    orderByCOAText[valueOrderByProduct] ==
                                        'Semua'
                                    ? ''
                                    : orderByCOAText[valueOrderByProduct];
                                // textOrderByCOA =
                                //     orderByCOAText[valueOrderByProduct];

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
                ' dari ${textOrderByCOA == '' ? 'Semua' : textOrderByCOA}',
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
}
