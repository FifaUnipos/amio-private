import 'dart:convert';
import 'dart:developer';
import 'dart:io' as Io;

import 'package:amio/utils/providerModel/refreshTampilanModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../models/pelangganDataModel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../../utils/component.dart';
import 'transaksi.dart';

String pelangganId = '', pelangganName = '';
TextEditingController controllerPelangganName = TextEditingController();

class PilihPelangganToko extends StatefulWidget {
  String token;
  PageController pageController;
  PageController pageMetodeSwap;
  int selectedIndex;
  PilihPelangganToko({
    Key? key,
    required this.token,
    required this.pageController,
    required this.pageMetodeSwap,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  State<PilihPelangganToko> createState() => _PilihPelangganTokoState();
}

class _PilihPelangganTokoState extends State<PilihPelangganToko> {
  List<PelangganModelData>? datasPelanggan;

  PageController _pageController = PageController();
  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};

  TextEditingController conName = TextEditingController();
  TextEditingController conPhone = TextEditingController();
  TextEditingController conEmail = TextEditingController();
  TextEditingController conInstagram = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    checkConnection(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        List<String> value = [''];

        await getDataPelanggan(value);

        setState(() {
          // log(datasPelanggan.toString());
          datasPelanggan;
          pelangganName;
          pelangganId;
        });

        _pageController = PageController(
          initialPage: 0,
          keepPage: true,
          viewportFraction: 1,
        );
      },
    );

    refreshDataProduk();

    super.initState();
  }

  Future<dynamic> getDataPelanggan(List<String> value) async {
    return datasPelanggan = await getPelanggan(
      context,
      widget.token,
      ''
    );
  }

  refreshDataProduk() {
    pelangganName;
    pelangganId;
    datasPelanggan;
    setState(() {});
  }

  @override
  dispose() {
    productPrice;
    _pageController.dispose();
    conName.dispose();
    conPhone.dispose();
    conEmail.dispose();
    conInstagram.dispose();
    super.dispose();
  }

  String? jenisProduct, idProduct;

  bool onswitchppn = false;
  bool onswitchtampikan = false;
  String ppnAktif = "Tidak Aktif";
  String kasirAktif = "Tidak Aktif";

  String? imageEdit, nameEdit, kategoriEdit, hargaEdit;

  String? memberId;

  @override
  Widget build(BuildContext context) {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    bool light = true;

    return StatefulBuilder(
      builder: (context, setState) => Container(
        padding: EdgeInsets.all(size16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size16),
          color: bnw100,
        ),
        child: datasPelanggan == null
            ? Center(child: loading())
            : PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [
                  pageProdukPelanggan(isFalseAvailable),
                  tambahProdukpelanggan(setState, context),
                  ubahPilihPelangganToko(setState, context, memberId),
                ],
              ),
      ),
    );
  }

  ubahPilihPelangganToko(StateSetter setState, BuildContext context, memberid) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
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
                  'Ubah Pelanggan',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  '',
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
              fieldEditProduk(
                'Nama Pelanggan',
                'Muhammad Nabil Musyaffa',
                conName,
                TextInputType.text,
              ),
              fieldEditProduk(
                'Nomor Telepon',
                '0812346789',
                conPhone,
                TextInputType.number,
              ),
              fieldEditProduk(
                'Email',
                'nabil@gmail.com',
                conEmail,
                TextInputType.emailAddress,
              ),
              fieldEditProduk(
                'Instagram',
                '@nabil742',
                conInstagram,
                TextInputType.text,
              ),
            ],
          ),
        ),
        SizedBox(height: size16),
        GestureDetector(
          onTap: () {
            editPelanggan(context, widget.token, memberid, conName.text, '',
                    conPhone.text, conEmail.text, conInstagram.text)
                .then((value) {
              value == '00' ? _pageController.jumpToPage(0) : null;
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
            MediaQuery.of(context).size.width,
          ),
        )
      ],
    );
  }

  tambahProdukpelanggan(StateSetter setState, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _pageController.previousPage(
                      duration: Duration(milliseconds: 10), curve: Curves.ease);
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
                    'Tambah Pelanggan',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Produk akan ditambahkan kedalam pelanggan yang telah dipilih',
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
                fieldAddProduk(
                  'Nama Pelanggan',
                  'Muhammad Nabil Musyaffa',
                  conName,
                  TextInputType.text,
                ),
                SizedBox(height: size16),
                fieldAddProduk(
                  'Nomor Telepon',
                  '0812346789',
                  conPhone,
                  TextInputType.number,
                ),
                SizedBox(height: size16),
                fieldAddProduk(
                  'Email',
                  'nabil@gmail.com',
                  conEmail,
                  TextInputType.emailAddress,
                ),
                SizedBox(height: size16),
                fieldAddProduk(
                    'Instagram', '@nabil123', conInstagram, TextInputType.text),
                SizedBox(height: size16),
              ],
            ),
          ),
          SizedBox(height: size16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      createPelanggan(
                        context,
                        widget.token,
                        conName.text,
                        "address",
                        conPhone.text,
                        conEmail.text,
                        conInstagram.text,
                      );
                    },
                    child: buttonXLoutline(
                      Center(
                        child: Text(
                          'Simpan & Tambah Baru',
                          style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                      ),
                      double.infinity,
                      bnw900,
                    ),
                  ),
                ),
              ),
              SizedBox(width: size16),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      createPelanggan(
                        context,
                        widget.token,
                        conName.text,
                        "address",
                        conPhone.text,
                        conEmail.text,
                        conInstagram.text,
                      ).then((value) {
                        value == '00' ? _pageController.jumpToPage(0) : null;
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
                      MediaQuery.of(context).size.width / 2.55,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  pageProdukPelanggan(bool isFalseAvailable) {
    double width = 100;
    List<String> value = [''];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                widget.pageController.jumpToPage(0);
              },
              child:
                  Icon(PhosphorIcons.arrow_left, color: bnw900, size: size48),
            ),
            SizedBox(width: size16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pelanggan',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Produk',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: size16),
                  Expanded(
                    child: SizedBox(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) async {
                          // datasTransaksi = await getProductTransaksi(
                          //   context,
                          //   widget.token,
                          //   value,
                          //   [''],
                          //   textvalueOrderBy,
                          // );
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
                          prefixIcon: Container(
                            margin: EdgeInsets.only(left: 20, right: size12),
                            child: Icon(
                              PhosphorIcons.magnifying_glass,
                              color: bnw900,
                              size: 20,
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
                                    size: 20,
                                    color: bnw900,
                                  ),
                                )
                              : null,
                          hintText: 'Cari nama produk',
                          hintStyle:
                              heading3(FontWeight.w500, bnw400, 'Outfit'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: size16),
                  GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                          duration: Duration(milliseconds: 10),
                          curve: Curves.ease);
                    },
                    child: buttonXL(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(PhosphorIcons.plus, color: bnw100),
                          SizedBox(width: size16),
                          Text(
                            'Pelanggan',
                            style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ],
                      ),
                      130,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: size16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buttonLoutline(
              GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Urutkan',
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          Text(
                            ' dari Nama A ke Z',
                            style: heading3(FontWeight.w400, bnw600, 'Outfit'),
                          ),
                        ],
                      ),
                      Icon(PhosphorIcons.caret_down),
                    ],
                  )),
              bnw300,
            ),
            Text(datasPelanggan!.length.toString()),
          ],
        ),
        SizedBox(height: size16),
        Expanded(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: size16),
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
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          'Nama Lengkap',
                          style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          'Email',
                          style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          'No Telepon',
                          style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          'Instagram',
                          style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          'Koin',
                          style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        child: buttonXLoutline(
                          Center(
                            child: Text(
                              'Pilih',
                              style:
                                  body1(FontWeight.w600, primary500, 'Outfit'),
                            ),
                          ),
                          0,
                          primary500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<RefreshTampilan>(
                  builder: (context, value, child) => Container(
                    decoration: BoxDecoration(
                      color: primary100,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(size16),
                        bottomRight: Radius.circular(size16),
                      ),
                    ),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        initState();
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: datasPelanggan!.length,
                        itemBuilder: (builder, index) {
                          final dataPelanggan = datasPelanggan![index];
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              setState(() {
                                value.refreshPelanggan(
                                  datasPelanggan![index].namaMember!,
                                  datasPelanggan![index].memberid!,
                                );

                                pelangganName =
                                    datasPelanggan![index].namaMember!;
                                pelangganId = datasPelanggan![index].memberid!;

                                if (pelangganName != '') {
                                  setState(() {
                                    refreshDataProduk();
                                    widget.pageController.jumpToPage(0);
                                    widget.pageMetodeSwap.jumpToPage(4);
                                    widget.selectedIndex = 2;
                                  });
                                } else {
                                  refreshDataProduk();
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: size12, horizontal: size16),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(color: bnw300, width: width1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                    child: Text(
                                      datasPelanggan![index].namaMember ?? '',
                                      style: heading4(
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                  )),
                                  SizedBox(width: size16),
                                  Expanded(
                                    child: SizedBox(
                                      width: width + 40,
                                      child: Text(
                                        datasPelanggan![index].email ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: heading4(
                                            FontWeight.w400, bnw900, 'Outfit'),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Expanded(
                                    child: SizedBox(
                                      width: width,
                                      child: Text(
                                        datasPelanggan![index].phonenumber ??
                                            '',
                                        // '${datasPelanggan![index].price}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: heading4(
                                            FontWeight.w400, bnw900, 'Outfit'),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Expanded(
                                    child: SizedBox(
                                      width: width - size16,
                                      child: Text(
                                        datasPelanggan![index]
                                                    .instagramAccount !=
                                                null
                                            ? datasPelanggan![index]
                                                    .instagramAccount!
                                                    .contains('@')
                                                ? '${datasPelanggan![index].instagramAccount}'
                                                : '@${datasPelanggan![index].instagramAccount}'
                                            : '',
                                        // '${datasPelanggan![index].price}',

                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: heading4(
                                            FontWeight.w400, bnw900, 'Outfit'),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Expanded(
                                    child: SizedBox(
                                      width: width,
                                      child: Text(
                                        FormatCurrency.convertToIdr(
                                                datasPelanggan![index].saldo)
                                            .toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: heading4(
                                            FontWeight.w400, bnw900, 'Outfit'),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  SizedBox(
                                    child: buttonXLoutline(
                                      Center(
                                        child: Text(
                                          'Pilih',
                                          style: body1(FontWeight.w600,
                                              primary500, 'Outfit'),
                                        ),
                                      ),
                                      0,
                                      primary500,
                                    ),
                                  ),
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  modalBottomValue(String title, icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: bnw900),
            SizedBox(width: size16),
            Text(
              title,
              style: heading3(FontWeight.w400, bnw900, 'Outfit'),
            )
          ],
        ),
        Divider(color: bnw300)
      ],
    );
  }

  fieldAddProduk(title, hint, mycontroller, TextInputType numberNo) {
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
          TextFormField(
            keyboardType: numberNo,
            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
            controller: mycontroller,
            onChanged: (value) {},
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: size12),
              isDense: true,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: bnw500,
                ),
              ),
              hintText: 'Cth : $hint',
              hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }

  fieldEditProduk(title, hint, mycontroller, TextInputType numberNo) {
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
          TextFormField(
            keyboardType: numberNo,
            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
            controller: mycontroller,
            onChanged: (value) {},
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: size12),
              isDense: true,
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
}
