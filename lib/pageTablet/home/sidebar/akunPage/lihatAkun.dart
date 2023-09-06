import 'dart:developer';

import 'package:amio/pageTablet/home/sidebar/akunPage/akungrup.dart';
import 'package:amio/pageTablet/home/sidebar/akunPage/ubahAkun.dart';
import 'package:amio/utils/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../../../models/lihatakunmodel.dart';
import '../../../../models/tokomodel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../../utils/component.dart';
import '../inventorigrup.dart';

late String nameAkun;
late String phoneAkun;
late String emailAkun;

class lihatAkunPage extends StatefulWidget {
  String title, token, merchid;

  PageController pageController;
  // List<ModelDataAkun> datas;
  lihatAkunPage({
    Key? key,
    required this.title,
    required this.token,
    required this.merchid,
    required this.pageController,
  }) : super(key: key);

  @override
  State<lihatAkunPage> createState() => _lihatAkunPageState();
}

class _lihatAkunPageState extends State<lihatAkunPage> {
  List<ModelDataAkun>? datasAkun;
  String textOrderBy = 'Nama Akun A ke Z';
  String textvalueOrderBy = 'upDownNama';

  @override
  void initState() {
    checkConnection(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      datasAkun =
          await getUserAkun(widget.token, widget.merchid, textvalueOrderBy);

      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => widget.pageController.jumpTo(0),
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
                      widget.title,
                      style: heading1(FontWeight.w700, Colors.black, 'Outfit'),
                    ),
                    Text(
                      'Akun',
                      style: heading3(FontWeight.w300, Colors.black, 'Outfit'),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                // IntrinsicWidth(
                //   child: SizedBox(
                //     height: 48,
                //     child: TextField(
                //       textAlignVertical: TextAlignVertical.bottom,
                //       onChanged: (value) async {
                //         // datas =
                //         //     await getAllToko(context, widget.token, value, '');
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
                //         hintText: 'Cari nama atau alamat toko',
                //         hintStyle: heading3(FontWeight.w500, bnw500, 'Outfit'),
                //       ),
                //     ),
                //   ),
                // ),

                SizedBox(width: size16),
                GestureDetector(
                  onTap: () {
                    widget.pageController.animateToPage(
                      2,
                      duration: Duration(microseconds: 10),
                      curve: Curves.ease,
                    );
                  },
                  child: buttonXL(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(PhosphorIcons.plus, color: bnw100),
                        SizedBox(width: size16),
                        Text(
                          'Akun',
                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ],
                    ),
                    100,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size16),
        orderBy(context),
        SizedBox(height: size16),
        Expanded(
          child: CheckBoxLihatAkun(
            datas: datasAkun,
            token: widget.token,
            pageController: widget.pageController,
            // datas: widget.datas,
          ),
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
                                    orderByAkunText.length,
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
                                          label: Text(orderByAkunText[index],
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
                                    orderByAkunText[valueOrderByProduct];
                                textvalueOrderBy =
                                    orderByAkun[valueOrderByProduct];
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

class CheckBoxLihatAkun extends StatefulWidget {
  PageController pageController;
  List<ModelDataAkun>? datas;
  String token;
  CheckBoxLihatAkun({
    Key? key,
    required this.pageController,
    required this.datas,
    required this.token,
  }) : super(key: key);
  @override
  _CheckBoxLihatAkunState createState() => _CheckBoxLihatAkunState();
}

class _CheckBoxLihatAkunState extends State<CheckBoxLihatAkun> {
  bool isSelectionMode = false;

  List<ModelDataAkun>? staticData;
  Map<int, bool> selectedFlag = {};

  // Map<int, bool> selectedFlag = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      body: newnew(widget.datas),
      // floatingActionButton: _buildSelectAllButton(),
    );
  }

  Column newnew(List<ModelDataAkun>? datas) {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    bool light = true;

    double width = 90;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: primary500,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size12),
              topRight: Radius.circular(size12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                // width: 200,
                child: Row(
                  children: [
                    Opacity(
                      opacity: 0,
                      child: GestureDetector(
                        // onTap: _selectAll,
                        child: SizedBox(
                          width: 50,
                          child: Icon(
                            isFalseAvailable
                                ? PhosphorIcons.square
                                : PhosphorIcons.check_square_fill,
                            color: bnw100,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: Text(
                        'Foto Profil',
                        style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: size16),
              Expanded(
                child: Container(
                  child: Text(
                    'Nama Lengkap',
                    style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                  ),
                ),
              ),
              SizedBox(width: size16),
              Expanded(
                child: Container(
                  child: Text(
                    'Email',
                    style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                  ),
                ),
              ),
              SizedBox(width: size16),
              Expanded(
                child: Container(
                  child: Text(
                    'No Telepon',
                    style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                  ),
                ),
              ),
              SizedBox(width: size16),
              Container(
                width: width,
                child: Text(
                  'Tipe Akun',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(width: size16),
              SizedBox(
                width: width,
                child: Text(
                  'Aktif',
                  textAlign: TextAlign.center,
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(width: size16),
              Opacity(
                opacity: 0,
                child: buttonL(
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIcons.pencil_line),
                        SizedBox(width: 6),
                        Text(
                          'Atur',
                          style: body1(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                      ],
                    ),
                  ),
                  bnw100,
                  bnw900,
                ),
              ),
              SizedBox(width: size16),
            ],
          ),
        ),
        datas != null
            ? Expanded(
                child: Container(
                  padding: EdgeInsetsDirectional.only(top: 2, bottom: 2),
                  decoration: BoxDecoration(
                    color: primary100,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(size8),
                      bottomRight: Radius.circular(size8),
                    ),
                  ),
                  child: RefreshIndicator(
                    color: bnw100,
                    backgroundColor: primary500,
                    onRefresh: () async {
                      initState();
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemBuilder: (builder, index) {
                        ModelDataAkun data = datas[index];
                        selectedFlag[index] = selectedFlag[index] ?? false;
                        bool? isSelected = selectedFlag[index];

                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: bnw300, width: width1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    // onTap: () => onTap(isSelected, index),
                                    onTap: () {
                                      onTap(isSelected, index);
                                      log(data.fullname.toString());
                                      log(data.userid.toString());
                                      log(data.phonenumber.toString());
                                    },
                                    child: SizedBox(
                                      width: 50,
                                      child:
                                          _buildSelectIcon(isSelected!, data),
                                    ),
                                  ),
                                  SizedBox(
                                    width: width,
                                    child: SizedBox(
                                      height: 60,
                                      width: 60,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(1000),
                                          child:
                                              datas[index].account_image != null
                                                  ? Image.network(
                                                      datas[index]
                                                          .account_image
                                                          .toString(),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Icon(
                                                      PhosphorIcons
                                                          .user_circle_fill,
                                                      size: 60,
                                                    ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: size16),
                              Expanded(
                                child: Container(
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    datas[index].fullname ?? '',
                                    style: heading4(
                                        FontWeight.w600, bnw900, 'Outfit'),
                                  ),
                                ),
                              ),
                              SizedBox(width: size16),
                              Expanded(
                                child: Container(
                                  child: Text(
                                    datas[index].email == null
                                        ? '-'
                                        : '${datas[index].email}',
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
                                  child: Text(
                                    '${datas[index].phonenumber}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: heading4(
                                        FontWeight.w400, bnw900, 'Outfit'),
                                  ),
                                ),
                              ),
                              SizedBox(width: size16),
                              Container(
                                width: width,
                                child: Text(
                                  datas[index].usertype == 'Merchant'
                                      ? 'Toko'
                                      : 'Grup Toko',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(width: size16),
                              Container(
                                width: width,
                                height: 30,
                                child: FlutterSwitch(
                                  padding: 1,
                                  value: int.parse(
                                              datas[index].status.toString()) ==
                                          1
                                      ? true
                                      : false,
                                  activeIcon: Icon(PhosphorIcons.check,
                                      color: primary500),
                                  width: 50.0,
                                  height: 27.0,
                                  inactiveIcon:
                                      Icon(PhosphorIcons.x, color: bnw100),
                                  activeColor: primary500,
                                  inactiveColor: bnw100,
                                  borderRadius: 30.0,
                                  inactiveToggleColor: bnw900,
                                  activeToggleColor: primary200,
                                  activeSwitchBorder:
                                      Border.all(color: primary500),
                                  inactiveSwitchBorder:
                                      Border.all(color: bnw300, width: 2),
                                  onToggle: (bool value) {
                                    // print('hello');
                                    // List<String> listProduct = [
                                    //   dataProduk.productid!
                                    // ];
                                    // changePpn(
                                    //   context,
                                    //   widget.token,
                                    //   value.toString(),
                                    //   listProduct,
                                    //   widget.merchId,
                                    // );
                                    initState();
                                    setState(() {});
                                  },
                                ),
                              ),
                              SizedBox(width: size16),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      account_imageAkun =
                                          datas[index].account_image!;
                                    });
                                    log(datas[index].userid.toString());
                                    nameAkun = datas[index].fullname.toString();
                                    emailAkun = datas[index].email.toString();
                                    phoneAkun =
                                        datas[index].phonenumber.toString();

                                    widget.pageController.animateToPage(
                                      3,
                                      duration: Duration(milliseconds: 10),
                                      curve: Curves.easeIn,
                                    );
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
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
                                                            datas[index]
                                                                .fullname
                                                                .toString(),
                                                            style: heading2(
                                                                FontWeight.w600,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          Text(
                                                            datas[index].usertype ==
                                                                    'Merchant'
                                                                ? 'Toko'
                                                                : 'Grup Toko',
                                                            style: heading4(
                                                                FontWeight.w400,
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
                                                          PhosphorIcons.x_fill,
                                                          color: bnw900,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 20),
                                                  GestureDetector(
                                                    behavior: HitTestBehavior
                                                        .translucent,
                                                    onTap: () {
                                                      getSingleAkun(
                                                              context,
                                                              widget.token,
                                                              datas[index]
                                                                  .userid
                                                                  .toString())
                                                          .then((value) {
                                                        if (value == '200') {
                                                          widget.pageController
                                                              .jumpToPage(3);
                                                          print(datas[index]
                                                              .userid
                                                              .toString());
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      });
                                                    },
                                                    child: modalBottomValue(
                                                      'Ubah Akun',
                                                      PhosphorIcons.pencil_line,
                                                    ),
                                                  ),
                                                  SizedBox(height: size16),
                                                  GestureDetector(
                                                    behavior: HitTestBehavior
                                                        .translucent,
                                                    onTap: () {
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
                                                                  'Yakin Ingin Menghapus Akun',
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
                                                                  'Semua data akun akan hilang.',
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
                                                                    onTap: () {
                                                                      deleteAkun(
                                                                        context,
                                                                        widget
                                                                            .token,
                                                                        [
                                                                          datas[index]
                                                                              .userid
                                                                              .toString()
                                                                        ],
                                                                      ).then(
                                                                          (value) {
                                                                        if (value ==
                                                                            '00') {
                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                      });
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
                                                                          style: heading3(
                                                                              FontWeight.w600,
                                                                              primary500,
                                                                              'Outfit'),
                                                                        ),
                                                                      ),
                                                                      MediaQuery.of(
                                                                              context)
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
                                                                    onTap: () {
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
                                                                      MediaQuery.of(
                                                                              context)
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
                                                      'Hapus Akun',
                                                      PhosphorIcons.trash,
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
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(PhosphorIcons.pencil_line),
                                            SizedBox(width: 6),
                                            Text(
                                              'Atur',
                                              style: body1(FontWeight.w600,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      bnw100,
                                      bnw900,
                                    ),
                                  )),
                              SizedBox(width: size16),
                            ],
                          ),
                        );
                      },
                      // itemCount: staticData!.length,
                      itemCount: datas.length,
                    ),
                  ),
                ),
              )
            : SkeletonCardLine(),
      ],
    );
  }

  void onTap(bool isSelected, int index) {
    setState(() {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);
    });
    // if (isSelectionMode) {
    // } else {
    //   // Open Detail Page
    // }
  }

  void onLongPress(bool isSelected, int index) {
    setState(() {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }

  Widget _buildSelectIcon(bool isSelected, ModelDataAkun data) {
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

  void _selectAll() {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    // If false will be available then it will select all the checkbox
    // If there will be no false then it will de-select all
    selectedFlag.updateAll((key, value) => isFalseAvailable);
    setState(() {
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }

  modalBottomValue(String title, icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: bnw900),
            SizedBox(width: 10),
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
}
