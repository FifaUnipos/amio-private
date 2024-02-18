import 'dart:convert';
import 'dart:developer';
import 'dart:io' as Io;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:amio/utils/component.dart';
import 'package:provider/provider.dart';

import '../../../../main.dart';
import '../../../../models/tokoModel/singletokomodel.dart';
import '../../../../models/tokomodel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../../utils/skeletons.dart';
import '../../../tokopage/sidebar/produkToko/produk.dart';
import 'tambahToko.dart';
import 'ubahToko.dart';

Color maainColor = Color(0xFF1363DF);

class TokoSidePage extends StatefulWidget {
  String token;
  TokoSidePage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<TokoSidePage> createState() => _TokoSidePageState();
}

class _TokoSidePageState extends State<TokoSidePage> {
  PageController _pageController = PageController();

  TextEditingController hapusController = TextEditingController();
  bool _validate = false;

  List<ModelDataToko>? datas;

  String image = "",
      name = "",
      type = "",
      address = "",
      provinsi = "",
      kabupaten = "",
      kecamatan = "",
      kelurahan = "",
      kode = "",
      merchid = "";

  @override
  void initState() {
    checkConnection(context);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        datas = await getAllToko(context, widget.token, '', textvalueOrderBy);

        setState(() {
          datas;
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

  @override
  void dispose() {
    _pageController.dispose();
    hapusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      child: Consumer(
        builder: (context, value, child) => Scaffold(
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.all(size16),
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
                onPageChanged: (index) {
                  print('$index');
                },
                children: [
                  mainPage(context),
                  CreateMerchant(
                    token: widget.token,
                    pageController: _pageController,
                    datas: datas ?? [],
                  ),
                  ChangeMerchant(
                    token: widget.token,
                    pageController: _pageController,
                    merchantid: merchid,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  mainPage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toko',
                      style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    Text(
                      'Tempat usaha yang dimiliki',
                      style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                // width: 420,
                child: Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        cursorColor: primary500,
                        onChanged: (value) async {
                          datas = await getAllToko(
                              context, widget.token, value, '');
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
                          prefixIcon: Icon(
                            PhosphorIcons.magnifying_glass,
                            color: bnw500,
                          ),
                          hintText: 'Cari nama toko',
                          hintStyle:
                              heading3(FontWeight.w500, bnw500, 'Outfit'),
                        ),
                      ),
                    ),
                    SizedBox(width: size16),
                    GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeIn,
                        );
                      },
                      child: buttonXL(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIcons.plus, color: bnw100),
                            SizedBox(width: size16),
                            Text(
                              'Toko',
                              style:
                                  heading3(FontWeight.w600, bnw100, 'Outfit'),
                            ),
                          ],
                        ),
                        137,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size16),
        orderByTokoField(),
        SizedBox(height: size16),
        Text(
          'Pilih Toko',
          style: heading2(FontWeight.w400, bnw900, 'Outfit'),
        ),
        SizedBox(height: size16),
        datas == null
            ? SkeletonCard()
            : Expanded(
                child: RefreshIndicator(
                  color: bnw100,
                  backgroundColor: primary500,
                  onRefresh: () async {
                    initState();
                    setState(() {});
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisExtent: 130,
                            // childAspectRatio: 2.977,
                            crossAxisCount: 2,
                            crossAxisSpacing: size16,
                            mainAxisSpacing: size16,
                          ),
                          itemCount: datas!.length,
                          itemBuilder: (context, i) {
                            return Container(
                              padding: EdgeInsets.all(size16),
                              // margin:  EdgeInsets.only(right: size16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(size16),
                                border: Border.all(color: bnw300),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(1000),
                                        child: SizedBox(
                                          height: 60,
                                          width: 60,
                                          child: datas![i].logomerchant_url !=
                                                  null
                                              ? Image.network(
                                                  datas![i]
                                                      .logomerchant_url
                                                      .toString(),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      SizedBox(
                                                          child: Icon(
                                                    PhosphorIcons
                                                        .storefront_fill,
                                                    size: 60,
                                                    color: bnw900,
                                                  )),
                                                )
                                              : Icon(
                                                  PhosphorIcons.storefront_fill,
                                                  size: 60,
                                                ),
                                        ),
                                      ),
                                      SizedBox(width: size20),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              datas![i].name ?? '',
                                              style: heading2(FontWeight.w700,
                                                  bnw900, 'Outfit'),
                                            ),
                                            Text(
                                              '${datas![i].address}',
                                              style: body1(FontWeight.w400,
                                                  bnw800, 'Outfit'),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            whenLoading(context);
                                            merchid =
                                                datas![i].merchantid.toString();

                                            getSingleMerch(
                                              context,
                                              widget.token,
                                              merchid,
                                            ).then((value) {
                                              if (value['rc'] == '00') {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                                _pageController.jumpToPage(2);
                                              } else {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                              }
                                            });

                                            setState(() {});
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 300,
                                            decoration: BoxDecoration(
                                              color: bnw100,
                                              border: Border.all(color: bnw300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(PhosphorIcons.pencil_line),
                                                SizedBox(width: size16),
                                                Text(
                                                  'Ubah',
                                                  style: heading4(
                                                    FontWeight.w600,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size12),
                                      GestureDetector(
                                        onTap: () {
                                          _validate = false;
                                          hapusController.text = '';
                                          showBottomPilihan(
                                            context,
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                        'Yakin Ingin Menghapus Toko?',
                                                        style: heading1(
                                                            FontWeight.w600,
                                                            bnw900,
                                                            'Outfit')),
                                                    SizedBox(height: size4),
                                                    Text(
                                                        'Data-data transaksi pada toko ini akan dihapus semua. Toko yang dihapus tidak dapat dikembalikan lagi.',
                                                        style: heading2(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit')),
                                                    SizedBox(height: size32),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          print(merchid);
                                                          Navigator.pop(
                                                              context);
                                                          showBotomHapusToko(
                                                              context, i);
                                                          setState(() {});
                                                        },
                                                        child: buttonXLoutline(
                                                          Center(
                                                            child: Text(
                                                              'Iya, Hapus',
                                                              style: heading3(
                                                                  FontWeight
                                                                      .w600,
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
                                                    SizedBox(width: size16),
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {});
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: buttonXL(
                                                          Center(
                                                            child: Text(
                                                              'Batal',
                                                              style: heading3(
                                                                  FontWeight
                                                                      .w600,
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
                                        child: Container(
                                          height: 40,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            color: bnw100,
                                            border: Border.all(color: red500),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            PhosphorIcons.trash_fill,
                                            color: red500,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
      ],
    );
  }

  Future<dynamic> showBotomHapusToko(BuildContext context, int i) {
    return showBottomPilihan(
      context,
      StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hapus Toko",
                  style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                ),
                Text(
                  "Silahkan tulis nama toko yang ingin dihapus.",
                  style: heading2(FontWeight.w400, bnw500, 'Outfit'),
                ),
              ],
            ),
            SizedBox(height: size32),
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Tuliskan Konfirmasi",
                      style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                    ),
                    Text(
                      "*",
                      style: heading4(FontWeight.w400, red500, 'Outfit'),
                    ),
                  ],
                ),
                TextField(
                  cursorColor: primary500,
                  style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                  controller: hapusController,
                  onChanged: (value) {
                    value.isEmpty ? _validate = false : null;
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: primary500,
                      ),
                    ),
                    errorText: _validate
                        ? 'Silahkan tuliskan konfirmasi dengan menuliskan nama toko.'
                        : null,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: size12),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: width1,
                        color: bnw500,
                      ),
                    ),
                    hintText: 'Cth : King Dragon Roll Jakarta',
                    hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
                  ),
                ),
              ],
            ),
            SizedBox(height: size32),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      hapusToko() {}
                      List<String> value = [
                        datas![i].merchantid.toString(),
                      ];

                      setState(() {
                        hapusController.text != datas![i].name.toString()
                            ? _validate = true
                            : _validate = false;
                      });

                      _validate != true
                          ? deleteMerchant(
                              context,
                              widget.token,
                              value,
                            ).then((value) {
                              Navigator.of(context, rootNavigator: true).pop();
                            })
                          : null;

                      initState();

                      setState(() {});

                      // log(datas![i].name.toString());
                    },
                    child: buttonXLoutline(
                      Center(
                        child: Text(
                          'Iya, Hapus',
                          style:
                              heading3(FontWeight.w600, primary500, "Outfit"),
                        ),
                      ),
                      MediaQuery.of(context).size.width,
                      primary500,
                    ),
                  ),
                ),
                SizedBox(width: size16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: buttonXL(
                      Center(
                        child: Text(
                          "Batal",
                          style: heading3(FontWeight.w600, bnw100, "Outfit"),
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
      ),
    );
  }

  orderByTokoField() {
    return IntrinsicWidth(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showModalBottomSheet(
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
                                    orderByTokoText.length,
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
                                          label: Text(orderByTokoText[index],
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
                                    orderByTokoText[valueOrderByProduct];
                                textvalueOrderBy =
                                    orderByToko[valueOrderByProduct];

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
