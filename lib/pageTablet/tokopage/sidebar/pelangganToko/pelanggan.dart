import 'dart:convert';
import 'dart:developer';
import '../../../../utils/component/component_showModalBottom.dart';
import 'dart:io' as Io;
import 'dart:io';
import 'ubahPelanggan.dart';
import '../../../../utils/component/skeletons.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../utils/component/component_orderBy.dart';
import '../../../../main.dart';
import '../../../../models/pelangganDataModel.dart';
import '../../../../models/produkmodel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';

class PelangganToko extends StatefulWidget {
  String token;
  PelangganToko({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<PelangganToko> createState() => _PelangganTokoState();
}

class _PelangganTokoState extends State<PelangganToko> {
  List<PelangganModelData>? datasPelanggan;

  PageController _pageController = PageController();
  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};

  TextEditingController conName = TextEditingController();
  TextEditingController conPhone = TextEditingController();
  TextEditingController conEmail = TextEditingController();
  TextEditingController conInstagram = TextEditingController();

  TextEditingController conNameEdit = TextEditingController();
  TextEditingController conPhoneEdit = TextEditingController();
  TextEditingController conEmailEdit = TextEditingController();
  TextEditingController conInstagramEdit = TextEditingController();

  String textOrderBy = 'Nama Pelanggan A ke Z';
  String textvalueOrderBy = 'upDownNama';
  @override
  void initState() {
    checkConnection(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        List<String> value = [''];

        await getDataPelanggan(value);

        setState(() {
          datasPelanggan;
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
    return datasPelanggan = await getPelanggan(context, widget.token, textvalueOrderBy);
  }

  refreshDataProduk() {
    datasPelanggan;
    conName.text = '';
    conPhone.text = '';
    conEmail.text = '';
    conInstagram.text = '';
    setState(() {});
  }

  @override
  dispose() {
    _pageController.dispose();
    productPrice;
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

  String? memberId, nameEdit, nomorEdit, emailEdit, instagramEdit;

  @override
  Widget build(BuildContext context) {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    bool light = true;

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
      child: StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Container(
            margin: EdgeInsets.all(size16),
            padding: EdgeInsets.all(size16),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.circular(size16),
            ),
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                pageProdukPelanggan(isFalseAvailable),
                tambahProdukpelanggan(setState, context),
                // ubahPelangganToko(setState, context, memberId),
                UbahPelangganPage(
                  token: widget.token,
                  memberid: memberId ?? '',
                  pageController: _pageController,
                  nameEdit: nameEdit ?? '',
                  nomorEdit: nomorEdit ?? '',
                  emailEdit: emailEdit ?? '',
                  instagramEdit: instagramEdit ?? '',
                )
              ],
            ),
          ),
        ),
      ),
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
                  _pageController.jumpToPage(0);
                  refreshDataProduk();
                },
                child: Icon(
                  PhosphorIcons.arrow_left,
                  size: size48,
                  color: bnw900,
                ),
              ),
              SizedBox(width: size12),
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
          SizedBox(height: size16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              children: [
                fieldAddProduk(
                  'Nama Pelanggan',
                  'Muhammad Nabil Musyaffa',
                  conName,
                  TextInputType.text,
                  false,
                ),
                SizedBox(height: size16),
                fieldAddProduk(
                  'Nomor Telepon',
                  '0812346789',
                  conPhone,
                  TextInputType.number,
                  false,
                ),
                SizedBox(height: size16),
                fieldAddProduk(
                  'Email',
                  'nabil@gmail.com',
                  conEmail,
                  TextInputType.emailAddress,
                  true,
                ),
                SizedBox(height: size16),
                fieldAddProduk(
                  'Instagram',
                  '@nabil123',
                  conInstagram,
                  TextInputType.text,
                  true,
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
                    createPelanggan(
                      context,
                      widget.token,
                      conName.text,
                      "address",
                      conPhone.text,
                      conEmail.text,
                      conInstagram.text,
                    ).then((value) {
                      if (value == '00') {
                        refreshDataProduk();
                        setState(() {});
                      }
                    });
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
                    createPelanggan(
                      context,
                      widget.token,
                      conName.text,
                      "address",
                      conPhone.text,
                      conEmail.text,
                      conInstagram.text,
                    ).then((value) {
                      if (value == '00') {
                        _pageController.jumpToPage(0);

                        refreshDataProduk();
                        setState(() {});
                        initState();
                      }
                    });
                  },
                  child: buttonXL(
                    Center(
                      child: Text(
                        'Tambah',
                        style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                      ),
                    ),
                    MediaQuery.of(context).size.width,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pelanggan',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  nameToko ?? '',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
            Row(
              children: [
                // Expanded(
                //   child: SizedBox(
                //     height: 48,
                //     child: TextField(
                //       textAlignVertical: TextAlignVertical.bottom,
                //       onChanged: (value) async {
                //         datasPelanggan = await getPelanggan(
                //           context,
                //           widget.token,
                //         );
                //         setState(() {});
                //       },
                //       decoration: InputDecoration(
                //         filled: true,
                //         fillColor: bnw200,
                //         border: OutlineInputBorder(
                //           borderSide: BorderSide(
                //             color: bnw300,
                //           ),
                //         ),
                //         focusedBorder: OutlineInputBorder(
                //           borderSide: BorderSide(
                //             color: bnw200,
                //           ),
                //         ),
                //         enabledBorder: OutlineInputBorder(
                //           borderSide: BorderSide(
                //             color: bnw300,
                //           ),
                //         ),
                //         prefixIcon: Icon(
                //           PhosphorIcons.magnifying_glass,
                //           color: bnw500,
                //         ),
                //         hintText: 'Cari nama produk',
                //         hintStyle:
                //             heading3(FontWeight.w500, bnw500, 'Outfit'),
                //       ),
                //     ),
                //   ),
                // ),

                SizedBox(width: size16),
                GestureDetector(
                  onTap: () {
                    _pageController.jumpToPage(1);
                  },
                  child: buttonXL(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(PhosphorIcons.plus, color: bnw100),
                        SizedBox(width: size12),
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
          ],
        ),
        SizedBox(height: size16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            orderBy(context),
            buttonLoutlineColor(
              Row(
                children: [
                  Icon(
                    PhosphorIcons.info_fill,
                    color: succes600,
                    size: size24,
                  ),
                  SizedBox(width: size12),
                  Row(
                    children: [
                      Text(
                        'Total Pelanggan : ',
                        style: TextStyle(
                          color: succes600,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        datasPelanggan?.length == null
                            ? '0'
                            : datasPelanggan!.length.toString(),
                        style: TextStyle(
                          color: succes600,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              succes100,
              succes600,
            )
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
                    SizedBox(width: size16),
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          'No Telepon',
                          style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                    ),
                    SizedBox(width: size16),
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          'Email',
                          style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                    ),
                    SizedBox(width: size16),
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          'Instagram',
                          style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                    ),
                    SizedBox(width: size16),
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          'Koin',
                          style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                    ),
                    SizedBox(width: size16),
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        child: buttonXLoutline(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(PhosphorIcons.pencil_line,
                                  color: bnw900, size: size20),
                              SizedBox(width: size12),
                              Text(
                                'Atur',
                                style: body1(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                            ],
                          ),
                          0,
                          bnw300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              datasPelanggan == null
                  ? SkeletonCardLine()
                  : Expanded(
                      child: RefreshIndicator(
                        color: bnw100,
                        backgroundColor: primary500,
                        onRefresh: () async {
                          initState();
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: primary100,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(size16),
                              bottomRight: Radius.circular(size16),
                            ),
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: datasPelanggan!.length,
                            itemBuilder: (builder, index) {
                              final dataPelanggan = datasPelanggan![index];
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size12, horizontal: size16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: bnw300, width: width1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        datasPelanggan![index].namaMember ??
                                            '-',
                                        style: heading4(
                                            FontWeight.w600, bnw900, 'Outfit'),
                                      ),
                                    ),
                                    SizedBox(width: size16),
                                    Expanded(
                                      child: Text(
                                        datasPelanggan![index].phonenumber ??
                                            '-',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: heading4(
                                            FontWeight.w400, bnw900, 'Outfit'),
                                      ),
                                    ),
                                    SizedBox(width: size16),
                                    Expanded(
                                      child: Text(
                                        datasPelanggan![index].email ?? '-',
                                        // '${datasPelanggan![index].price}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: heading4(
                                            FontWeight.w400, bnw900, 'Outfit'),
                                      ),
                                    ),
                                    SizedBox(width: size16),
                                    Expanded(
                                      child: Text(
                                        datasPelanggan![index]
                                                    .instagramAccount !=
                                                null
                                            ? datasPelanggan![index]
                                                    .instagramAccount!
                                                    .contains('@')
                                                ? '${datasPelanggan![index].instagramAccount}'
                                                : '@${datasPelanggan![index].instagramAccount}'
                                            : '-',
                                        // '${datasPelanggan![index].price}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: heading4(
                                            FontWeight.w400, bnw900, 'Outfit'),
                                      ),
                                    ),
                                    SizedBox(width: size16),
                                    Expanded(
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
                                    SizedBox(width: size16),
                                    SizedBox(
                                      child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showModalBottom(
                                                context,
                                                MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                Padding(
                                                  padding: EdgeInsets.all(28.0),
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
                                                                'Ubah Pelanggan',
                                                                // datasPelanggan![
                                                                //             index]
                                                                //         .namaMember ??
                                                                //     '',
                                                                style: heading2(
                                                                    FontWeight
                                                                        .w600,
                                                                    bnw900,
                                                                    'Outfit'),
                                                              ),
                                                              Text(
                                                                datasPelanggan![
                                                                            index]
                                                                        .namaMember ??
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
                                                      SizedBox(height: size20),
                                                      GestureDetector(
                                                        behavior:
                                                            HitTestBehavior
                                                                .translucent,
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          memberId =
                                                              datasPelanggan![
                                                                      index]
                                                                  .memberid;
                                                          nameEdit =
                                                              datasPelanggan![
                                                                      index]
                                                                  .namaMember;
                                                          nomorEdit =
                                                              datasPelanggan![
                                                                      index]
                                                                  .phonenumber;
                                                          emailEdit =
                                                              datasPelanggan![
                                                                      index]
                                                                  .email;
                                                          instagramEdit =
                                                              datasPelanggan![
                                                                      index]
                                                                  .instagramAccount;

                                                          _pageController
                                                              .jumpToPage(2);
                                                          setState(() {});
                                                        },
                                                        child: modalBottomValue(
                                                          'Ubah Pelanggan',
                                                          PhosphorIcons
                                                              .pencil_line,
                                                        ),
                                                      ),
                                                      SizedBox(height: size12),
                                                      GestureDetector(
                                                        behavior:
                                                            HitTestBehavior
                                                                .translucent,
                                                        onTap: () {
                                                          String memberid =
                                                              datasPelanggan![
                                                                      index]
                                                                  .memberid
                                                                  .toString();

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
                                                                      'Yakin Ingin Menghapus Pelanggan',
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
                                                                      'Semua data pelanggan dan koin pelanggan akan hilang.',
                                                                      style: heading2(
                                                                          FontWeight
                                                                              .w400,
                                                                          bnw900,
                                                                          'Outfit'),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        size16),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          List<String>
                                                                              listPelanggan =
                                                                              [
                                                                            memberid
                                                                          ];

                                                                          deletePelanggan(
                                                                            context,
                                                                            widget.token,
                                                                            listPelanggan,
                                                                          );
                                                                          Navigator.pop(
                                                                              context);

                                                                          initState();
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        child:
                                                                            buttonXLoutline(
                                                                          Center(
                                                                            child:
                                                                                Text(
                                                                              'Iya, Hapus',
                                                                              style: heading3(FontWeight.w600, primary500, 'Outfit'),
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
                                                                            size12),
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
                                                                              style: heading3(FontWeight.w600, bnw100, 'Outfit'),
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
                                                          'Hapus Pelanggan',
                                                          PhosphorIcons.trash,
                                                        ),
                                                      ),
                                                    ],
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
                                                Icon(PhosphorIcons.pencil_line,
                                                    color: bnw900,
                                                    size: size20),
                                                SizedBox(width: size12),
                                                Text(
                                                  'Atur',
                                                  style: body1(FontWeight.w600,
                                                      bnw900, 'Outfit'),
                                                ),
                                              ],
                                            ),
                                            bnw100,
                                            bnw300,
                                          )),
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
    );
  }

  modalBottomValue(String title, icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: bnw900),
            SizedBox(width: size12),
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

  fieldAddProduk(title, hint, mycontroller, TextInputType numberNo, bintang) {
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
                bintang ? '' : ' *',
                style: heading4(FontWeight.w700, red500, 'Outfit'),
              ),
            ],
          ),
          TextFormField(
            cursorColor: primary500,
            keyboardType: numberNo,
            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
            controller: mycontroller,
            onChanged: (value) {},
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
              hintText: 'Cth : $hint',
              hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }

  fieldEditProduk(title, hint, mycontroller, TextInputType numberNo, bintang) {
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
                bintang ? '' : ' *',
                style: heading4(FontWeight.w700, red500, 'Outfit'),
              ),
            ],
          ),
          TextFormField(
            cursorColor: primary500,
            keyboardType: numberNo,
            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
            controller: mycontroller,
            onChanged: (value) {},
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
              hintText: 'Cth : $hint',
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
                                    orderByPelangganText.length,
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
                                          label: Text(
                                              orderByPelangganText[index],
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
                                textOrderBy =
                                    orderByPelangganText[valueOrderByProduct];
                                textvalueOrderBy =
                                    orderByPelanggan[valueOrderByProduct];
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
}
