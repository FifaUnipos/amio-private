import 'dart:convert';
import 'dart:developer';
import 'dart:io' as Io;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../main.dart';
import '../../../../models/tokomodel.dart';
import '../../../../services/apimethod.dart';
import '../../../../utils/component/component_color.dart';
import '../../../../services/checkConnection.dart';
import '../../../../../utils/component/component_button.dart';

class TambahAkunPage extends StatefulWidget {
  String token,
      merchid,
      namemerchant,
      address,
      province,
      regencies,
      district,
      village,
      zipcode,
      businesstype,
      logomerchant_url;
  PageController pageController;
  TambahAkunPage({
    Key? key,
    required this.merchid,
    required this.pageController,
    required this.token,
    required this.namemerchant,
    required this.address,
    required this.province,
    required this.regencies,
    required this.district,
    required this.village,
    required this.zipcode,
    required this.businesstype,
    required this.logomerchant_url,
  }) : super(key: key);

  @override
  State<TambahAkunPage> createState() => _TambahAkunPageState();
}

class _TambahAkunPageState extends State<TambahAkunPage> {
  TextEditingController conNameMerch = TextEditingController();
  TextEditingController conEmail = TextEditingController();
  TextEditingController conPhoneNumber = TextEditingController();

  // List<String> hakList = ['User', 'Admin'];
  String? hakValue;

  bool onswitchAktif = true;
  String switchAktif = "Aktif";

  bool onswitchAktifKasirTambah = false;
  String switchAktifKasirTambah = 'Pengguna';

  @override
  void initState() {
    checkConnection(context);
    super.initState();
  }

  File? myImage;
  Uint8List? bytes;
  String? img64;
  List<String> images = [];

  Future<void> getImage() async {
    var picker = ImagePicker();
    PickedFile? image;

    image = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 900,
      maxWidth: 900,
    );
    if (image!.path.isEmpty == false) {
      myImage = File(image.path);

      bytes = await Io.File(myImage!.path).readAsBytes();
      setState(() {
        img64 = base64Encode(bytes!);
        images.add(img64!);
      });
      // Clipboard.setData(ClipboardData(text: img64));
    } else {
      print('Error Image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => widget.pageController.previousPage(
                  duration: Duration(milliseconds: 10), curve: Curves.easeIn),
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
                  'Tambah Akun',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Isi data akun dengan lengkap',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size16),
              color: bnw100,
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Row(
                      //       children: [
                      //         Text(
                      //           'hakValue Akun',
                      //           style: body1(FontWeight.w500, bnw900, 'Outfit'),
                      //         ),
                      //         Text(
                      //           ' *',
                      //           style: body1(FontWeight.w700, red500, 'Outfit'),
                      //         ),
                      //       ],
                      //     ),
                      //     Container(
                      //       color: bnw300,
                      //       child: TextFormField(cursorColor:primary500,
                      //         enabled: false,
                      //         style:
                      //             heading2(FontWeight.w600, bnw500, 'Outfit'),
                      //         // controller: mycontroller,
                      //         onChanged: (value) {},

                      //         decoration: InputDecoration(
                      //           enabledBorder: UnderlineInputBorder(
                      //             borderSide: BorderSide(
                      //               width: 1.5,
                      //               color: bnw500,
                      //             ),
                      //           ),
                      //           hintText: 'Grup Toko',
                      //           hintStyle:
                      //               heading2(FontWeight.w600, bnw100, 'Outfit'),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // fieldhakValueUsaha(context),
                      SizedBox(height: size16),
                      Text(
                        'Logo Toko',
                        style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                      ),
                      SizedBox(height: size12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => tambahGambar(context),
                            child: Container(
                              child: myImage != null
                                  ? Image.file(myImage!, fit: BoxFit.cover)
                                  : Icon(PhosphorIcons.plus),
                              decoration: BoxDecoration(
                                border: Border.all(color: bnw900),
                                borderRadius: BorderRadius.circular(size8),
                              ),
                              height: 80,
                              width: 80,
                            ),
                          ),
                          SizedBox(width: size12),
                          Text(
                            'Masukkan logo atau foto yang menandakan identitas dari tokomu.',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                      Theme(
                        data: ThemeData(
                          disabledColor: bnw900,
                        ),
                        child: GestureDetector(
                          onTap: () => tambahGambar(context),
                          child: TextFormField(
                            cursorColor: primary500,
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: primary500,
                                ),
                              ),
                              enabled: false,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: bnw500,
                                ),
                              ),
                              suffixIcon: Icon(PhosphorIcons.plus),
                              hintText: 'Tambah Foto',
                              hintStyle:
                                  heading2(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size16),
                      fieldAddToko(
                        'Nama Lengkap ',
                        'Muhammad Nabil Musyaffa',
                        conNameMerch,
                        true,
                      ),
                      SizedBox(height: size16),
                      fieldAddTokoPhone(
                        'Nomor Telepon',
                        '0812346789',
                        conPhoneNumber,
                      ),
                      SizedBox(height: size16),
                      fieldAddToko('Email', 'nabil@gmail.com', conEmail, false),
                      SizedBox(height: size16),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          onswitchAktif = !onswitchAktif;
                          onswitchAktif
                              ? switchAktif = "Aktif"
                              : switchAktif = "Tidak Aktif";
                          setState(() {});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Akun Aktif',
                                  style: heading2(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                ),
                                Text(
                                  switchAktif,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ],
                            ),
                            FlutterSwitch(
                              width: 52.0,
                              height: 28.0,
                              value: onswitchAktif,
                              padding: 0,
                              activeIcon:
                                  Icon(PhosphorIcons.check, color: primary500),
                              inactiveIcon:
                                  Icon(PhosphorIcons.x, color: bnw100),
                              activeColor: primary500,
                              inactiveColor: bnw100,
                              borderRadius: 30.0,
                              inactiveToggleColor: bnw900,
                              activeToggleColor: primary200,
                              activeSwitchBorder: Border.all(color: primary500),
                              inactiveSwitchBorder:
                                  Border.all(color: bnw300, width: 2),
                              onToggle: (val) {
                                setState(
                                  () {
                                    onswitchAktif = val;
                                    onswitchAktif
                                        ? switchAktif = "Aktif"
                                        : switchAktif = "Tidak Aktif";
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size16),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          onswitchAktif = !onswitchAktif;
                          onswitchAktif
                              ? switchAktif = "Aktif"
                              : switchAktif = "Tidak Aktif";
                          setState(() {});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mode Kasir',
                                  style: heading2(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                ),
                                Text(
                                  switchAktifKasirTambah,
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ],
                            ),
                            FlutterSwitch(
                              width: 52.0,
                              height: 28.0,
                              value: onswitchAktifKasirTambah,
                              padding: 0,
                              activeIcon:
                                  Icon(PhosphorIcons.check, color: primary500),
                              inactiveIcon:
                                  Icon(PhosphorIcons.x, color: bnw100),
                              activeColor: primary500,
                              inactiveColor: bnw100,
                              borderRadius: 30.0,
                              inactiveToggleColor: bnw900,
                              activeToggleColor: primary200,
                              activeSwitchBorder: Border.all(color: primary500),
                              inactiveSwitchBorder:
                                  Border.all(color: bnw300, width: 2),
                              onToggle: (val) {
                                setState(
                                  () {
                                    onswitchAktifKasirTambah = val;
                                    onswitchAktifKasirTambah
                                        ? switchAktifKasirTambah = "Kasir"
                                        : switchAktifKasirTambah = "Pengguna";
                                  },
                                );
                              },
                            ),
                          ],
                        ),
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
                          getAllToko(context, widget.token, '', '');
                          createAkun(
                            context,
                            widget.token,
                            widget.merchid,
                            conNameMerch.text,
                            conPhoneNumber.text,
                            conEmail.text,
                            widget.namemerchant,
                            widget.address,
                            widget.province,
                            widget.regencies,
                            widget.district,
                            widget.village,
                            widget.zipcode,
                            img64.toString(),
                            onswitchAktif ? '1' : '0',
                            onswitchAktifKasirTambah ? 'cashier' : 'user',
                          );

                          conNameMerch.text = '';
                          conPhoneNumber.text = '';
                          conEmail.text = '';
                        },
                        child: buttonXLoutline(
                          Center(
                            child: Text(
                              'Simpan & Tambah Baru',
                              style:
                                  heading3(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                          ),
                          MediaQuery.of(context).size.width,
                          bnw900,
                        ),
                      ),
                    ),
                    SizedBox(width: size12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(
                            () {
                              getAllToko(context, widget.token, '', '');
                              createAkun(
                                context,
                                widget.token,
                                widget.merchid,
                                conNameMerch.text,
                                conPhoneNumber.text,
                                conEmail.text,
                                widget.namemerchant,
                                widget.address,
                                widget.province,
                                widget.regencies,
                                widget.district,
                                widget.village,
                                widget.zipcode,
                                img64.toString(),
                                onswitchAktif ? '1' : '0',
                                onswitchAktifKasirTambah ? 'cashier' : 'user',
                              ).then((value) {
                                if (value == '00') {
                                  widget.pageController.jumpToPage(1);
                                }
                              });
                            },
                          );
                        },
                        child: buttonXL(
                          Center(
                            child: Text(
                              'Tambah',
                              style:
                                  heading3(FontWeight.w600, bnw100, 'Outfit'),
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
        ),
      ],
    );
  }

  GestureDetector fieldhakValueUsaha(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(
        () {
          log(hakValue.toString());
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
                builder: (BuildContext context, setState) => Container(
                  height: MediaQuery.of(context).size.height / 1.8,
                  decoration: BoxDecoration(
                    color: bnw100,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size12),
                      topLeft: Radius.circular(size12),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: size12, right: size12),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(size8),
                          height: 4,
                          width: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(size8),
                            color: bnw300,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left: size16),
                          padding: EdgeInsets.only(right: size16, top: size16),
                          decoration: BoxDecoration(
                            color: bnw100,
                            border: Border(
                              bottom: BorderSide(
                                width: 1.5,
                                color: bnw500,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: size8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hak Akses *',
                                    style: heading4(
                                        FontWeight.w400, bnw900, 'Outfit'),
                                  ),
                                  Text(
                                    hakValue == null
                                        ? 'Pilih Hak Akses'
                                        : hakValue.toString().toLowerCase(),
                                    style: heading2(
                                        FontWeight.w600, bnw500, 'Outfit'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size12),
                        // Expanded(
                        //   child: ListView.separated(
                        //     itemBuilder: (context, index) {
                        //       return GestureDetector(
                        //         onTap: () {
                        //           setState(() {
                        //             hakValue = hakList[index];
                        //           });
                        //           log(hakList[index]);
                        //         },
                        //         child: Padding(
                        //           padding: EdgeInsets.all(size8),
                        //           child: Text(hakList[index]),
                        //         ),
                        //       );
                        //     },
                        //     separatorBuilder: (context, index) {
                        //       return Divider(
                        //         color: bnw300,
                        //       );
                        //     },
                        //     itemCount: hakList.length,
                        //   ),
                        // ),

                        GestureDetector(
                          onTap: () {
                            // _getRegenciesList(_myProvince);
                            setState() {
                              hakValue;
                            }

                            Navigator.pop(context);
                          },
                          child: buttonXXL(
                            Center(
                              child: Text(
                                'Selesai',
                                style:
                                    heading2(FontWeight.w600, bnw100, 'Outfit'),
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
              );
            },
          );
        },
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(right: size16, top: size16),
        decoration: BoxDecoration(
          color: bnw100,
          border: Border(
            bottom: BorderSide(
              width: 1.5,
              color: bnw500,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: size8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hak Akses *',
                  style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hakValue == null
                          ? 'Hak Akses'
                          : hakValue.toString().toLowerCase(),
                      style: heading2(FontWeight.w600, bnw500, 'Outfit'),
                    ),
                    Icon(
                      PhosphorIcons.caret_down,
                      color: bnw900,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  fieldAddToko(title, hint, mycontroller, email) {
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
                email ? ' *' : '',
                style: body1(FontWeight.w700, red500, 'Outfit'),
              ),
            ],
          ),
          IntrinsicHeight(
            child: TextFormField(
              cursorColor: primary500,
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
          ),
        ],
      ),
    );
  }

  fieldAddTokoPhone(title, hint, mycontroller) {
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
              style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              controller: mycontroller,
              onChanged: (value) {},
              keyboardType: TextInputType.number,
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
                hintText: 'Cth : $hint',
                hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  tambahGambar(BuildContext context) async {
    showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => IntrinsicHeight(
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(size8),
              topLeft: Radius.circular(size8),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                dividerShowdialog(),
                SizedBox(height: size16),
                myImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(120),
                        child: Container(
                            height: 200,
                            width: 200,
                            color: bnw400,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(size8),
                              child: Image.file(
                                myImage!,
                                fit: BoxFit.cover,
                              ),
                            )),
                      )
                    : Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(120),
                        ),
                        child: SvgPicture.asset('assets/logoProduct.svg',
                            fit: BoxFit.cover),
                      ),
                SizedBox(height: size16),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await getImage();
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        child: TextFormField(
                          cursorColor: primary500,
                          enabled: false,
                          style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                          decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: primary500,
                                ),
                              ),
                              focusColor: primary500,
                              prefixIcon: Icon(
                                PhosphorIcons.plus,
                                color: bnw900,
                              ),
                              hintText: 'Tambah Foto',
                              hintStyle:
                                  heading3(FontWeight.w400, bnw900, 'Outfit')),
                        ),
                      ),
                    ),
                    myImage != null
                        ? GestureDetector(
                            onTap: () async {
                              img64 = null;
                              myImage = null;
                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: SizedBox(
                              child: TextFormField(
                                cursorColor: primary500,
                                enabled: false,
                                style:
                                    heading3(FontWeight.w400, bnw900, 'Outfit'),
                                decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: primary500,
                                    ),
                                  ),
                                  focusColor: primary500,
                                  prefixIcon: Icon(
                                    PhosphorIcons.trash,
                                    color: bnw900,
                                  ),
                                  hintText: 'Hapus Foto',
                                  hintStyle: heading3(
                                    FontWeight.w400,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
