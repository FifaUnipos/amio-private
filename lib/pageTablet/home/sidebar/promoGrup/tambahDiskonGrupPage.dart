import 'dart:convert';
import 'dart:developer';

import '../../../tokopage/sidebar/produkToko/produk.dart';
import '../../../../pagehelper/loginregis/daftar_akun_toko.dart';
import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:http/http.dart' as http;
import '../../../../main.dart';
import '../../../../services/apimethod.dart';

import '../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';
import '../../../../utils/component/component_loading.dart';

class TambahDiskonGrupPage extends StatefulWidget {
  String token, merchid;
  PageController pageController;
  TambahDiskonGrupPage({
    Key? key,
    required this.token,
    required this.merchid,
    required this.pageController,
  }) : super(key: key);

  @override
  State<TambahDiskonGrupPage> createState() => _TambahDiskonGrupPageState();
}

class _TambahDiskonGrupPageState extends State<TambahDiskonGrupPage> {
  List<String> productidDiskon = List.empty(growable: true);
  bool onswitchtampikan = true;
  int tipeUmumAktif = 0, tipeProdukAktif = 0;
  int hargaRupiahAktif = 0, hargaPersenAktif = 0;
  int masaSelamanya = 0, masaKustom = 0;
  int txtFieldAktif = 0;
  String kasirAktif = "Aktif";
  String? idProduct;

  String tanggalAwal = '', tanggalAkhir = '';

  bool isKeyboardActive = false;
  Map<int, bool> selectedFlag = {};
  bool isSelectionMode = false;

  late TextEditingController conNameDiskon = TextEditingController();
  late TextEditingController conHarga = TextEditingController();
  late TextEditingController conPointEdit = TextEditingController();

  TextEditingController searchController = TextEditingController();

  void formatInputRpHargaEdit() {
    String text = conHarga.text.replaceAll('.', '');
    int value = int.tryParse(text)!;
    String formattedAmount = formatCurrency(value);

    conHarga.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  void formatInputRpPoinEdit() {
    String text = conPointEdit.text.replaceAll('.', '');
    int value = int.tryParse(text)!;
    String formattedAmount = formatCurrency(value);

    conPointEdit.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  refreshTampilan() {
    setState(() {
      tanggalAwal = '';
      tanggalAkhir = '';
      conNameDiskon.text = '';
      conHarga.text = '';
      tipeUmumAktif = 0;
      tipeProdukAktif = 0;
      hargaRupiahAktif = 0;
      hargaPersenAktif = 0;
      masaSelamanya = 0;
      masaKustom = 0;
      txtFieldAktif = 0;
      kasirAktif = "Aktif";
      tanggalAwal = '';
      tanggalAkhir = '';
      productidDiskon.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _getProductList();
    conHarga.addListener(formatInputRpHargaEdit);
    conPointEdit.addListener(formatInputRpPoinEdit);
  }

  @override
  void dispose() {
    conNameDiskon.dispose();
    conHarga.dispose();
    conPointEdit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            SizedBox(width: size12),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Diskon',
                      style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    Text(
                      'Diskon akan ditambahkan kedalam Toko yang telah dipilih',
                      style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
        SizedBox(height: size16),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Tipe Diskon',
                          style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                        ),
                        Text(
                          ' *',
                          style: heading4(FontWeight.w700, red500, 'Outfit'),
                        ),
                      ],
                    ),
                    SizedBox(height: size12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              tipeProdukAktif = 0;
                              tipeUmumAktif = 1;
                              setState(() {});
                            },
                            child: buttonActive(
                                tipeUmumAktif,
                                'Umum',
                                Icon(PhosphorIcons.squares_four_fill,
                                    color: bnw900)),
                          ),
                        ),
                        SizedBox(width: size12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              tipeUmumAktif = 0;
                              tipeProdukAktif = 1;
                              setState(() {});
                            },
                            child: buttonActive(
                              tipeProdukAktif,
                              'Per Produk',
                              Icon(PhosphorIcons.shopping_bag_open_fill,
                                  color: bnw900),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size12),
                    tipeProdukAktif == 1
                        ? Container(
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
                                      showModalBottomSheet(
                                        constraints: const BoxConstraints(
                                          maxWidth: double.infinity,
                                        ),
                                        isScrollControlled: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (BuildContext context,
                                                    setState) =>
                                                FractionallySizedBox(
                                              heightFactor:
                                                  isKeyboardActive ? 0.9 : 0.80,
                                              child: GestureDetector(
                                                onTap: () => textFieldFocusNode
                                                    .unfocus(),
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                              .viewInsets
                                                              .bottom),
                                                  // height: MediaQuery.of(context).size.height / 1,
                                                  decoration: BoxDecoration(
                                                    color: bnw100,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(12),
                                                      topLeft:
                                                          Radius.circular(12),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            size32,
                                                            size16,
                                                            size32,
                                                            size32),
                                                    child: Column(
                                                      children: [
                                                        dividerShowdialog(),
                                                        SizedBox(
                                                            height: size16),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            'Pilih Produk',
                                                            style: heading1(
                                                                FontWeight.w700,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height: size16),
                                                        FocusScope(
                                                          child: Focus(
                                                            onFocusChange:
                                                                (value) {
                                                              isKeyboardActive =
                                                                  value;
                                                              setState(() {});
                                                            },
                                                            child: TextField(
                                                              cursorColor:
                                                                  primary500,
                                                              controller:
                                                                  searchController,
                                                              focusNode:
                                                                  textFieldFocusNode,
                                                              onChanged:
                                                                  (value) {
                                                                //   isKeyboardActive = value.isNotEmpty;
                                                                _runSearchProduct(
                                                                    value);
                                                                setState(() {});
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                      contentPadding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              size12),
                                                                      isDense:
                                                                          true,
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          bnw200,
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(size8),
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              bnw300,
                                                                        ),
                                                                      ),
                                                                      focusedBorder:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(size8),
                                                                        borderSide:
                                                                            BorderSide(
                                                                          width:
                                                                              2,
                                                                          color:
                                                                              primary500,
                                                                        ),
                                                                      ),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(size8),
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              bnw300,
                                                                        ),
                                                                      ),
                                                                      suffixIcon: searchController
                                                                              .text
                                                                              .isNotEmpty
                                                                          ? GestureDetector(
                                                                              onTap: () {
                                                                                searchController.text = '';
                                                                                _runSearchProduct('');
                                                                                setState(() {});
                                                                              },
                                                                              child: Icon(
                                                                                PhosphorIcons.x_fill,
                                                                                size: 20,
                                                                                color: bnw900,
                                                                              ),
                                                                            )
                                                                          : null,
                                                                      prefixIcon:
                                                                          Icon(
                                                                        PhosphorIcons
                                                                            .magnifying_glass,
                                                                        color:
                                                                            bnw500,
                                                                      ),
                                                                      hintText:
                                                                          'Cari',
                                                                      hintStyle: heading3(
                                                                          FontWeight
                                                                              .w500,
                                                                          bnw500,
                                                                          'Outfit')),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child:
                                                              RefreshIndicator(
                                                            onRefresh:
                                                                () async {
                                                              initState();
                                                            },
                                                            child: ListView(
                                                              children: [
                                                                SizedBox(
                                                                    height:
                                                                        size16),
                                                                SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  child: buttonL(
                                                                      Text(
                                                                        dataMap![
                                                                            'name'],
                                                                        style: heading2(
                                                                            FontWeight.w400,
                                                                            bnw100,
                                                                            'Outfit'),
                                                                      ),
                                                                      primary800,
                                                                      primary800),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        size12),
                                                                ListView
                                                                    .builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  physics:
                                                                      BouncingScrollPhysics(),
                                                                  keyboardDismissBehavior:
                                                                      ScrollViewKeyboardDismissBehavior
                                                                          .onDrag,
                                                                  itemCount:
                                                                      searchResultListProduct
                                                                              ?.length ??
                                                                          0,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    final product =
                                                                        searchResultListProduct?[
                                                                            index];
                                                                    if (product ==
                                                                        null) {
                                                                      return const SizedBox(); // atau Widget lain sesuai kebutuhan
                                                                    }

                                                                    final bool isMatchingSearch = product[
                                                                            'name']
                                                                        .toString()
                                                                        .toLowerCase()
                                                                        .contains(searchController
                                                                            .text
                                                                            .toLowerCase());

                                                                    final bool
                                                                        isSelected =
                                                                        productidDiskon
                                                                            .contains(product['productid']);

                                                                    if (isMatchingSearch) {
                                                                      return GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          // print('Selected product: ${product['name']}');
                                                                          textFieldFocusNode
                                                                              .unfocus();

                                                                          if (product['discount_status'] ==
                                                                              '') {
                                                                            if (isSelected) {
                                                                              productidDiskon.remove(product['productid']);
                                                                            } else {
                                                                              productidDiskon.add(product['productid']);
                                                                            }
                                                                          }
                                                                          print(
                                                                              productidDiskon);
                                                                          // Panggil fungsi _selectProduct dengan produk yang dipilih
                                                                          idProduct =
                                                                              product['productid'];
                                                                          _selectProduct(
                                                                              product);
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        child: Container(
                                                                            padding: EdgeInsets.all(size8),
                                                                            margin: EdgeInsets.only(bottom: size16),
                                                                            decoration: BoxDecoration(
                                                                              color: product['discount_status'] == ''
                                                                                  ? isSelected
                                                                                      ? primary100
                                                                                      : bnw100
                                                                                  : bnw200,
                                                                              border: Border.all(
                                                                                color: product['discount_status'] == ''
                                                                                    ? isSelected
                                                                                        ? primary500
                                                                                        : bnw300
                                                                                    : bnw200,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(size16),
                                                                            ),
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(size8),
                                                                                      child: Image.network(
                                                                                        product['product_image'],
                                                                                        fit: BoxFit.cover,
                                                                                        width: size48,
                                                                                        height: size48,
                                                                                        loadingBuilder: (context, child, loadingProgress) {
                                                                                          if (loadingProgress == null) {
                                                                                            return child;
                                                                                          }

                                                                                          return Center(child: loading());
                                                                                        },
                                                                                        errorBuilder: (context, error, stackTrace) => SizedBox(
                                                                                          // height: 227,
                                                                                          // width: 227,
                                                                                          child: SvgPicture.asset('assets/logoProduct.svg'),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(width: size16),
                                                                                    Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          product['name'],
                                                                                          style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                                                                                        ),
                                                                                        Text(
                                                                                          FormatCurrency.convertToIdr(product['price']),
                                                                                          style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Spacer(),
                                                                                    Icon(
                                                                                      product['discount_status'] == ''
                                                                                          ? isSelected
                                                                                              ? PhosphorIcons.check_square_fill
                                                                                              : PhosphorIcons.square
                                                                                          : PhosphorIcons.square,
                                                                                      color: product['discount_status'] == ''
                                                                                          ? isSelected
                                                                                              ? primary500
                                                                                              : bnw900
                                                                                          : bnw400,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(height: size8),
                                                                                product['discount_status'] != ''
                                                                                    ? Container(
                                                                                        padding: EdgeInsets.symmetric(vertical: size8, horizontal: size16),
                                                                                        height: size32,
                                                                                        decoration: BoxDecoration(
                                                                                          color: danger100,
                                                                                          borderRadius: BorderRadius.circular(size8),
                                                                                        ),
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: [
                                                                                            Text(
                                                                                              product['discount_status'],
                                                                                              style: body3(FontWeight.w400, danger500, 'Outfit'),
                                                                                            ),
                                                                                            Spacer(),
                                                                                            Icon(PhosphorIcons.clock, color: danger500, size: size16),
                                                                                          ],
                                                                                        ),
                                                                                      )
                                                                                    : SizedBox(),
                                                                              ],
                                                                            )),
                                                                      );
                                                                    } else {
                                                                      return const SizedBox();
                                                                    }
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        size16),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: buttonXXL(
                                                            Center(
                                                              child: Text(
                                                                'Selesai',
                                                                style: heading2(
                                                                    FontWeight
                                                                        .w600,
                                                                    bnw100,
                                                                    'Outfit'),
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
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            productidDiskon.isEmpty
                                                ? 'Pilih Produk'
                                                : '${productidDiskon.length} Produk Terpilih',
                                            style: heading2(
                                                FontWeight.w600,
                                                productidDiskon.isEmpty
                                                    ? bnw500
                                                    : bnw900,
                                                'Outfit'),
                                          ),
                                          Icon(
                                            PhosphorIcons.caret_down,
                                            color: bnw900,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(),
                    SizedBox(height: size12),
                  ],
                ),
              ),
              fieldEditProduk(
                'Nama Diskon',
                conNameDiskon,
                TextInputType.text,
                'Nama Diskon',
              ),
              SizedBox(height: size16),
              Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Harga Diskon',
                          style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                        ),
                        Text(
                          ' *',
                          style: heading4(FontWeight.w700, red500, 'Outfit'),
                        ),
                      ],
                    ),
                    SizedBox(height: size12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              txtFieldAktif = 1;
                              hargaPersenAktif = 0;
                              hargaRupiahAktif = 1;
                              setState(() {});
                            },
                            child: buttonActive(hargaRupiahAktif, 'Rupiah',
                                Icon(PhosphorIcons.money_fill, color: bnw900)),
                          ),
                        ),
                        SizedBox(width: size12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              txtFieldAktif = 1;
                              hargaRupiahAktif = 0;
                              hargaPersenAktif = 1;
                              setState(() {});
                            },
                            child: buttonActive(
                              hargaPersenAktif,
                              'Persen',
                              Icon(PhosphorIcons.percent, color: bnw900),
                            ),
                          ),
                        ),
                        SizedBox(width: size12),
                        txtFieldAktif == 1
                            ? Expanded(
                                flex: 4,
                                child: TextFormField(
                                  cursorColor: primary500,
                                  keyboardType: TextInputType.number,
                                  style: heading2(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                  controller: conHarga,
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: primary500,
                                      ),
                                    ),
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: size12),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 1.5,
                                        color: bnw500,
                                      ),
                                    ),
                                    hintText: hargaPersenAktif == 1
                                        ? '%'
                                        : 'Rp. 12.000',
                                    hintStyle: heading2(
                                        FontWeight.w600, bnw500, 'Outfit'),
                                  ),
                                ),
                              )
                            : SizedBox()
                      ],
                    ),
                    SizedBox(height: size12),
                  ],
                ),
              ),
              SizedBox(height: size16),
              Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Masa Aktif Diskon',
                          style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                        ),
                        Text(
                          ' *',
                          style: heading4(FontWeight.w700, red500, 'Outfit'),
                        ),
                      ],
                    ),
                    SizedBox(height: size12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              masaKustom = 0;
                              masaSelamanya = 1;
                              // tanggalAwal = 'null';
                              // tanggalAkhir = 'null';
                              setState(() {});
                            },
                            child: buttonActive(
                                masaSelamanya,
                                'Selamanya',
                                Icon(PhosphorIcons.hourglass_fill,
                                    color: bnw900)),
                          ),
                        ),
                        SizedBox(width: size12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              masaSelamanya = 0;
                              masaKustom = 1;
                              setState(() {});
                            },
                            child: buttonActive(
                              masaKustom,
                              'Kustom Waktu',
                              Icon(PhosphorIcons.hourglass_medium_fill,
                                  color: bnw900),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size12),
                    masaKustom == 1
                        ? Row(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Waktu Mulai',
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
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2022),
                                              lastDate: DateTime(2101),
                                            ).then((selectedDate) {
                                              DateTime selectedDateTime =
                                                  DateTime(
                                                selectedDate!.year,
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
                                                vertical: size12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  tanggalAwal == ''
                                                      ? 'Pilih Tanggal'
                                                      : tanggalAwal,
                                                  style: heading2(
                                                      FontWeight.w600,
                                                      tanggalAwal == ''
                                                          ? bnw500
                                                          : bnw900,
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
                              SizedBox(width: size12),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Waktu Berakhir',
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
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2022),
                                              lastDate: DateTime(2101),
                                            ).then((selectedDate) {
                                              DateTime selectedDateTime =
                                                  DateTime(
                                                selectedDate!.year,
                                                selectedDate.month,
                                                selectedDate.day,
                                              );

                                              tanggalAkhir =
                                                  "${selectedDateTime.year}-${selectedDateTime.month}-${selectedDateTime.day}";
                                              print(tanggalAkhir);
                                              setState(() {});
                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: size12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  tanggalAkhir == ''
                                                      ? 'Pilih Tanggal'
                                                      : tanggalAkhir,
                                                  style: heading2(
                                                      FontWeight.w600,
                                                      tanggalAkhir == ''
                                                          ? bnw500
                                                          : bnw900,
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
                          )
                        : SizedBox()
                  ],
                ),
              ),
              SizedBox(height: size16),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    onswitchtampikan = !onswitchtampikan;
                    onswitchtampikan
                        ? kasirAktif = "Aktif"
                        : kasirAktif = "Tidak Aktif";
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Diskon',
                          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        Text(
                          kasirAktif,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ],
                    ),
                    FlutterSwitch(
                      width: 52.0,
                      height: 28.0,
                      // value: snapshot.data['isPPN'] == 1 ? true : false,
                      value: onswitchtampikan,
                      padding: 0,
                      activeIcon: Icon(PhosphorIcons.check, color: primary500),
                      inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                      activeColor: primary500,
                      inactiveColor: bnw100,
                      borderRadius: 30.0,
                      inactiveToggleColor: bnw900,
                      activeToggleColor: primary200,
                      activeSwitchBorder: Border.all(color: primary500),
                      inactiveSwitchBorder: Border.all(color: bnw300, width: 2),
                      onToggle: (val) {
                        onswitchtampikan = val;
                        onswitchtampikan
                            ? kasirAktif = "Aktif"
                            : kasirAktif = "Tidak Aktif";
                        log(onswitchtampikan.toString());
                        // log(kasirAktif);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  List<String> merchid = [widget.merchid];
                  String tipeUmumAktifError = "";
                  if (tipeUmumAktif == 0 && tipeProdukAktif == 0) {
                    tipeUmumAktifError = '';
                  } else if (tipeUmumAktif == 1) {
                    tipeUmumAktifError = 'umum';
                    productidDiskon = [''];
                  } else if (tipeProdukAktif == 1) {
                    if (productidDiskon.isEmpty) {
                      tipeUmumAktifError = '';
                    } else {
                      tipeUmumAktifError = 'perproduk';
                      productidDiskon = productidDiskon;
                    }
                  }
                  bool statusDiskon = true;
                  kasirAktif == 'Aktif'
                      ? statusDiskon = true
                      : statusDiskon = false;
                  tambahDiskon(
                    context,
                    widget.token,
                    merchid,
                    tipeUmumAktifError == "" ? '' : productidDiskon,
                    conNameDiskon.text,
                    conHarga.text,
                    hargaRupiahAktif == 1 ? 'price' : 'percentage',
                    masaSelamanya == 1 ? '' : tanggalAwal,
                    masaSelamanya == 1 ? '' : tanggalAkhir,
                    statusDiskon.toString(),
                    masaSelamanya == 1 ? 'forever' : 'range',
                  ).then((value) {
                    if (value == '00') {
                      refreshTampilan();
                    }
                  });

                  setState(() {});
                },
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Simpan & Tambah Baru',
                      style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width,
                  bnw900,
                ),
              ),
            ),
            SizedBox(width: size16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  List<String> merchid = [widget.merchid];
                  bool statusDiskon = true;

                  String tipeUmumAktifError = "";
                  if (tipeUmumAktif == 0 && tipeProdukAktif == 0) {
                    tipeUmumAktifError = '';
                  } else if (tipeUmumAktif == 1) {
                    tipeUmumAktifError = 'umum';
                    productidDiskon = [''];
                  } else if (tipeProdukAktif == 1) {
                    if (productidDiskon.isEmpty) {
                      tipeUmumAktifError = '';
                    } else {
                      tipeUmumAktifError = 'perproduk';
                      productidDiskon = productidDiskon;
                    }
                  }

                  kasirAktif == 'Aktif'
                      ? statusDiskon = true
                      : statusDiskon = false;
                  tambahDiskon(
                    context,
                    widget.token,
                    merchid,
                    tipeUmumAktifError == "" ? '' : productidDiskon,
                    conNameDiskon.text,
                    conHarga.text.replaceAll(RegExp(r'[^0-9]'), ''),
                    hargaRupiahAktif == 1 ? 'price' : 'percentage',
                    masaSelamanya == 1 ? '' : tanggalAwal,
                    masaSelamanya == 1 ? '' : tanggalAkhir,
                    statusDiskon.toString(),
                    masaSelamanya == 1 ? 'forever' : 'range',
                  ).then((value) {
                    if (value == '00') {
                      refreshTampilan();
                      widget.pageController.jumpToPage(0);
                    }
                  });

                  setState(() {});
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Simpan',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width,
                  // primary500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IntrinsicWidth buttonActive(int active, String title, Icon icon) {
    return IntrinsicWidth(
      child: Container(
        height: size56,
        padding: EdgeInsets.symmetric(horizontal: size20),
        decoration: ShapeDecoration(
          color: active == 1 ? primary100 : bnw100,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: width2,
              color: active == 1 ? primary500 : bnw300,
            ),
            borderRadius: BorderRadius.circular(size8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: heading3(
                  FontWeight.w400, active == 1 ? primary500 : bnw900, 'Outfit'),
            ),
            icon,
          ],
        ),
      ),
    );
  }

  fieldEditProduk(title, mycontroller, TextInputType numberNo, hintText) {
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
            keyboardType: numberNo,
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

  List? typeproductList;
  List<dynamic>? searchResultListProduct;
  Map<String, dynamic>? dataMap;

  dynamic selectedProduct;
  bool isItemSelected = false;

  Future _getProductList() async {
    await http.post(Uri.parse(getProdukDiskonLink), body: {
      "deviceid": identifier,
      "merchantid": widget.merchid,
    }, headers: {
      "token": widget.token,
    }).then((response) {
      log(response.body.toString());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          setState(() {
            dataMap = data['data'];

            List<dynamic> typeproductList =
                List<dynamic>.from(dataMap!['products']);

            searchResultListProduct = typeproductList;
          });
        }
      }
    });
  }

  void _runSearchProduct(String searchText) {
    setState(() {
      if (typeproductList != null) {
        searchResultListProduct = typeproductList!
            .where((product) =>
                product != null &&
                product['name'] != null &&
                product['name']
                    .toString()
                    .toLowerCase()
                    .contains(searchText.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectProduct(dynamic product) {
    setState(() {
      selectedProduct = product;
      isItemSelected = true;
    });
  }
}
