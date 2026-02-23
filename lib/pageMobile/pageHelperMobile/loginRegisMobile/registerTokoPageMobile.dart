import 'dart:convert';
import 'dart:developer';import '../../../../utils/component/component_showModalBottom.dart';
import 'dart:io';
import 'dart:io' as Io;
import 'dart:typed_data';

import '../../../models/dropdowntokomodel.dart';
import 'loginPageMobile.dart';
import 'otpPageMobile.dart';
import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import 'package:unipos_app_335/utils/component/component_snackbar.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../utils/component/component_color.dart';
import '../../../main.dart';
import '../../../pageTablet/tokopage/sidebar/produkToko/produk.dart';
import '../../../services/apimethod.dart';

import '../../../utils/component/component_appbar.dart';import '../../../../../utils/component/component_button.dart';

class DaftarAkunTokoPageMobile extends StatefulWidget {
  DaftarAkunTokoPageMobile({super.key});

  @override
  State<DaftarAkunTokoPageMobile> createState() =>
      _DaftarAkunTokoPageMobileState();
}

class _DaftarAkunTokoPageMobileState extends State<DaftarAkunTokoPageMobile> {
  TextEditingController conNameMerch = TextEditingController();
  TextEditingController conCodeStore = TextEditingController();
  TextEditingController conAddress = TextEditingController();
  TextEditingController conCodePos = TextEditingController();

  var phoneController = TextEditingController();
  var nameController = TextEditingController();
  // var passController = TextEditingController();
  var emailController = TextEditingController();
  Color onOffButton = bnw300;
  bool bttnValidated = false;
  bool bttnValidated2 = false;

  TextEditingController searchController = TextEditingController();

  File? myImage;
  Uint8List? bytes;
  String? img64;
  List<String> images = [];

  Future<void> getImage() async {
    var picker = ImagePicker();
    PickedFile? image;

    image = await picker.getImage(source: ImageSource.gallery);
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

  String? tipe, prov, kab, kec, desa;

  @override
  void initState() {
    conCodePos.addListener(() {
      setState(() {
        // bttnValidated = conNameMerch.text.isNotEmpty;
      });
    });
    _getProvinceList();
    _getTipeList();
    super.initState();
  }

  @override
  void dispose() {
    conNameMerch.dispose();
    super.dispose();
  }

  void autoReload() {
    setState(() {
      tipe;
      prov;
      kab;
      kec;
      desa;
    });
  }

  void refreshData() {
    if (conNameMerch.text.isNotEmpty &&
        conAddress.text.isNotEmpty &&
        conCodePos.text.isNotEmpty &&
        tipe != null &&
        prov != null &&
        kab != null &&
        kec != null &&
        desa != null) {
      setState(() {
        bttnValidated = true;
      });
    } else {
      bttnValidated = false;
    }
    if (phoneController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty) {
      setState(() {
        bttnValidated2 = true;
      });
    } else {
      bttnValidated2 = false;
    }
  }

  bool complete1 = true;
  bool complete2 = false;

  bool isSwitched = true;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: bnw100,

        body: isSwitched
            ? SafeArea(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(size32, 0, size32, size16),
                  child: Column(
                    children: [
                      appbar(context, false),
                      Expanded(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daftar Sebagai Pemilik Toko',
                                      style: heading1(
                                          FontWeight.w700, bnw900, 'Outfit'),
                                    ),
                                    Text(
                                      'Isikan data anda dengan lengkap',
                                      style: heading3(
                                          FontWeight.w500, bnw500, 'Outfit'),
                                    ),
                                    SizedBox(height: size12),
                                    imagefieldXL(
                                      myImage,
                                      // getImage,
                                      test,
                                      'Logo/Foto Toko',
                                      'Masukkan foto atau logo dari tokomu',
                                      myImage == null
                                          ? 'Tambah Gambar'
                                          : 'Ubah Gambar',
                                    ),
                                    SizedBox(height: size16),
                                    Column(
                                      children: [
                                        textfieldXLdaftar(
                                          'Nama Toko',
                                          'Cth: King Dragon Roll Jakarta',
                                          'Form harus diisi!',
                                          conNameMerch,
                                          false,
                                        ),
                                        SizedBox(height: size32),
                                        fieldTipeUsaha(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size16),
                              textfieldXLdaftar(
                                'Alamat',
                                'Jl. Pramuka No.99, RT01/RW02, Marga Wisata',
                                'Form harus diisi!',
                                conAddress,
                                false,
                              ),
                              SizedBox(height: size16),
                              provinceField(context),
                              SizedBox(height: size16),
                              regenciesField(context),
                              SizedBox(height: size16),
                              districtField(context),
                              SizedBox(height: size16),
                              villageField(),
                              SizedBox(height: size16),
                              SizedBox(
                                width: double.infinity,
                                child: textfieldXLdaftar(
                                  'Kode Pos',
                                  '1234',
                                  'Form harus diisi!',
                                  conCodePos,
                                  false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      bttnValidated
                          ? SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: size32),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(
                                          () {
                                            if (bttnValidated == true) {
                                              isSwitched = false;
                                            }
              
                                            print(
                                                '$prov $kab $kec $bttnValidated');
                                          },
                                        );
                                      },
                                      child: buttonXXLonOff(
                                        Center(
                                          child: Text(
                                            'Berikutnya',
                                            style: heading2(FontWeight.w600,
                                                bnw100, 'Outfit'),
                                          ),
                                        ),
                                        double.infinity,
                                        bttnValidated ? primary500 : bnw300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
            )
            : newRegis(context),
      ),
    );
  }

  test() {
    showModalBottom(
      context,
      MediaQuery.of(context).size.height / 2.8,
      Padding(
        padding: EdgeInsets.all(size32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Foto/Logo Toko',
                  style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    PhosphorIcons.x_fill,
                    color: bnw900,
                  ),
                ),
              ],
            ),
            SizedBox(height: size24),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                getImage();
                Navigator.pop(context);
                setState(() {});
              },
              child: modalBottomValue(
                myImage == null ? 'Tambah Gambar' : 'Ubah Gambar',
                myImage == null
                    ? PhosphorIcons.plus
                    : PhosphorIcons.pencil_fill,
              ),
            ),
            SizedBox(height: size12),
            myImage != null
                ? GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      myImage = null;
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: modalBottomValue(
                      'Hapus Gambar',
                      PhosphorIcons.trash,
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  fieldTipeUsaha() {
    bool isKeyboardActive = false;

    return GestureDetector(
      onTap: () => setState(
        () {
          autoReload();
          log(tipe.toString());
          showModalBottomSheet(
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size24),
            ),
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) =>
                    FractionallySizedBox(
                  heightFactor: isKeyboardActive ? 0.9 : 0.6,
                  child: GestureDetector(
                    onTap: () => textFieldFocusNode,
                    child: Container(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
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
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  size8, size16, size8, size16),
                              child: FocusScope(
                                child: Focus(
                                  onFocusChange: (value) {
                                    isKeyboardActive = value;
                                    setState(() {});
                                  },
                                  child: TextField(
                                    controller: searchController,
                                    focusNode: textFieldFocusNode,
                                    onChanged: (value) {
                                      _runSearchTipeUsaha(value);
                                      setState(() {});
                                    },
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
                                        suffixIcon: searchController
                                                .text.isNotEmpty
                                            ? GestureDetector(
                                                onTap: () {
                                                  searchController.text = '';
                                                  _runSearchTipeUsaha('');
                                                  setState(() {});
                                                },
                                                child: Icon(
                                                  PhosphorIcons.x_fill,
                                                  size: 20,
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
                                            FontWeight.w500, bnw500, 'Outfit')),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                physics: BouncingScrollPhysics(),
                                itemCount: searchResultListTipeUsaha?.length,
                                itemBuilder: (context, index) {
                                  final tipeUsaha =
                                      searchResultListTipeUsaha?[index];
                                  final isSelected =
                                      tipeUsaha == selectedTipeUsaha;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          tipeUsaha['nama_tipe'] != null
                                              ? capitalizeEachWord(
                                                  tipeUsaha['nama_tipe']
                                                      .toString())
                                              : '',
                                        ),
                                        trailing: Icon(
                                          isSelected
                                              ? PhosphorIcons.radio_button_fill
                                              : PhosphorIcons.radio_button,
                                          color:
                                              isSelected ? primary500 : bnw900,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            textFieldFocusNode.unfocus();
                                            _mytipe = tipeUsaha['tipeusaha_id'];
                                            // iditpe = tipeUsaha['tipeusaha_id'];
                                            tipe = tipeUsaha['nama_tipe'];

                                            selectedTipeUsaha =
                                                tipeUsaha.toString();
                                            _selectTipeUsaha(tipeUsaha);

                                            print(tipeUsaha['nama_tipe']);
                                          });
                                        },
                                      ),
                                      Divider(color: bnw300),
                                    ],
                                  );
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print(tipe);

                                autoReload();
                                // initState();
                                Navigator.pop(context);
                              },
                              child: buttonXXL(
                                Center(
                                  child: Text(
                                    'Selesai',
                                    style: heading2(
                                        FontWeight.w600, bnw100, 'Outfit'),
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
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bnw100,
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: bnw400,
            ),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //!depan
              Row(
                children: [
                  Text(
                    'Tipe Usaha',
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
                      tipe == null ? 'Tipe usaha' : tipe.toString(),
                      style: heading2(FontWeight.w600,
                          tipe == null ? bnw400 : bnw900, 'Outfit'),
                    ),
                    Icon(
                      PhosphorIcons.caret_down_fill,
                      color: bnw900,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  fieldAddToko(title, hint, mycontroller) {
    return Container(
      margin: EdgeInsets.only(top: size16),
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
          SizedBox(
            child: TextFormField(
              style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              controller: mycontroller,
              onChanged: (value) {
                refreshData();
              },
              decoration: InputDecoration(
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

  fieldZipToko(title, hint, mycontroller) {
    return Container(
      margin: EdgeInsets.only(top: size16),
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
          SizedBox(
            child: TextFormField(
              style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              controller: mycontroller,
              onChanged: (value) {
                refreshData();
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
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

  GestureDetector provinceField(BuildContext context) {
    bool isKeyboardActive = false;

    return GestureDetector(
        onTap: () {
          setState(
            () {
              autoReload();
              log(prov.toString());
              showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size24),
                ),
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, setState) =>
                        FractionallySizedBox(
                      heightFactor: isKeyboardActive ? 0.9 : 0.6,
                      child: GestureDetector(
                        onTap: () => textFieldFocusNode.unfocus(),
                        child: Container(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          height: MediaQuery.of(context).size.height / 1.8,
                          decoration: BoxDecoration(
                            color: bnw100,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size12),
                              topLeft: Radius.circular(size12),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                size32, size16, size32, size32),
                            child: Column(
                              children: [
                                dividerShowdialog(),
                                SizedBox(
                                  height: size16,
                                ),
                                FocusScope(
                                  child: Focus(
                                    onFocusChange: (value) {
                                      isKeyboardActive = value;
                                      setState(() {});
                                    },
                                    child: TextField(
                                      controller: searchController,
                                      focusNode: textFieldFocusNode,
                                      onChanged: (value) {
                                        //   isKeyboardActive = value.isNotEmpty;
                                        _runSearchProvince(value);
                                        setState(() {});
                                      },
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
                                          suffixIcon: searchController
                                                  .text.isNotEmpty
                                              ? GestureDetector(
                                                  onTap: () {
                                                    searchController.text = '';
                                                    _runSearchProvince('');
                                                    setState(() {});
                                                  },
                                                  child: Icon(
                                                    PhosphorIcons.x_fill,
                                                    size: 20,
                                                    color: bnw900,
                                                  ),
                                                )
                                              : null,
                                          prefixIcon: Icon(
                                            PhosphorIcons.magnifying_glass,
                                            color: bnw500,
                                          ),
                                          hintText: 'Cari',
                                          hintStyle: heading3(FontWeight.w500,
                                              bnw500, 'Outfit')),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    physics: BouncingScrollPhysics(),
                                    itemCount: searchResultList?.length,
                                    itemBuilder: (context, index) {
                                      final province = searchResultList?[index];
                                      final isSelected =
                                          province == selectedProvince;

                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Text(
                                              province['NAME'] != null
                                                  ? capitalizeEachWord(
                                                      province['NAME']
                                                          .toString())
                                                  : '',
                                            ),
                                            trailing: Icon(
                                              isSelected
                                                  ? PhosphorIcons
                                                      .radio_button_fill
                                                  : PhosphorIcons.radio_button,
                                              color: isSelected
                                                  ? primary500
                                                  : bnw900,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                textFieldFocusNode.unfocus();
                                                _myProvince = province['ID'];
                                                // idprov = province['ID'];

                                                prov = province['NAME'];

                                                selectedProvince =
                                                    province.toString();
                                                _selectProvince(province);

                                                print(province['NAME']);
                                              });
                                            },
                                          ),
                                          Divider(color: bnw300),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    autoReload();
                                    _getRegenciesList(_myProvince);
                                    Navigator.pop(context);
                                  },
                                  child: buttonXXL(
                                    Center(
                                      child: Text(
                                        'Selesai',
                                        style: heading2(
                                            FontWeight.w600, bnw100, 'Outfit'),
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
          );
        },
        child: dropdownfieldXL('Provinsi', prov, 'Pilih Provinsi'));
  }

  GestureDetector regenciesField(BuildContext context) {
    bool isKeyboardActive = false;
    return GestureDetector(
        onTap: () {
          setState(
            () {
              autoReload();
              log(kab.toString());
              showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size24),
                ),
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, setState) =>
                        FractionallySizedBox(
                      heightFactor: isKeyboardActive ? 0.9 : 0.6,
                      child: GestureDetector(
                        onTap: () => textFieldFocusNode.unfocus(),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 1.8,
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          decoration: BoxDecoration(
                            color: bnw100,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size12),
                              topLeft: Radius.circular(size12),
                            ),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: size12, right: size12),
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
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      size8, size16, size8, size16),
                                  child: FocusScope(
                                    child: Focus(
                                      onFocusChange: (value) {
                                        isKeyboardActive = value;
                                        setState(() {});
                                      },
                                      child: TextField(
                                        controller: searchController,
                                        focusNode: textFieldFocusNode,
                                        onChanged: ((value) {
                                          _runSearchRegencies(value);
                                          setState(() {});
                                        }),
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
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
                                            suffixIcon: searchController
                                                    .text.isNotEmpty
                                                ? GestureDetector(
                                                    onTap: () {
                                                      searchController.text =
                                                          '';
                                                      _runSearchRegencies('');
                                                      setState(() {});
                                                    },
                                                    child: Icon(
                                                      PhosphorIcons.x_fill,
                                                      size: 20,
                                                      color: bnw900,
                                                    ),
                                                  )
                                                : null,
                                            prefixIcon: Icon(
                                              PhosphorIcons.magnifying_glass,
                                              color: bnw500,
                                            ),
                                            hintText: 'Cari',
                                            hintStyle: heading3(FontWeight.w500,
                                                bnw500, 'Outfit')),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: searchResultListRegencies == null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                                "Isi Provinsi terlebih dahulu"),
                                          ],
                                        )
                                      : ListView.builder(
                                          keyboardDismissBehavior:
                                              ScrollViewKeyboardDismissBehavior
                                                  .onDrag,
                                          itemCount: searchResultListRegencies
                                                  ?.length ??
                                              0,
                                          physics: BouncingScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final regencies =
                                                searchResultListRegencies?[
                                                    index];
                                            final isSelected =
                                                regencies == selectedRegencies;

                                            return Column(
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                    regencies['NAME'] != null
                                                        ? capitalizeEachWord(
                                                            regencies['NAME']
                                                                .toString())
                                                        : '',
                                                  ),
                                                  trailing: Icon(
                                                    isSelected
                                                        ? PhosphorIcons
                                                            .radio_button_fill
                                                        : PhosphorIcons
                                                            .radio_button,
                                                    color: isSelected
                                                        ? primary500
                                                        : bnw900,
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      textFieldFocusNode
                                                          .unfocus();
                                                      _myRegencies =
                                                          regencies['ID'];
                                                      // idkab = regencies['ID'];
                                                      kab = regencies['NAME']
                                                          .toString();

                                                      selectedRegencies =
                                                          regencies.toString();
                                                      _selectRegencies(
                                                          regencies);

                                                      print(regencies['NAME']);
                                                    });
                                                  },
                                                ),
                                                Divider(color: bnw300),
                                              ],
                                            );
                                          },
                                        ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    autoReload();
                                    _getDistrictList(_myRegencies);
                                    Navigator.pop(context);
                                  },
                                  child: buttonXXL(
                                    Center(
                                      child: Text(
                                        'Selesai',
                                        style: heading2(
                                            FontWeight.w600, bnw100, 'Outfit'),
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
          );
        },
        child: dropdownfieldXL('Kota/Kabupaten', kab, 'Pilih Kota/Kabupaten'));
  }

  GestureDetector districtField(BuildContext context) {
    bool isKeyboardActive = false;
    return GestureDetector(
        onTap: () {
          setState(
            () {
              autoReload();
              log(kec.toString());
              showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size24),
                ),
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, setState) =>
                        FractionallySizedBox(
                      heightFactor: isKeyboardActive ? 0.9 : 0.6,
                      child: GestureDetector(
                        onTap: () => textFieldFocusNode.unfocus(),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 1.8,
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          decoration: BoxDecoration(
                            color: bnw100,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size12),
                              topLeft: Radius.circular(size12),
                            ),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: size12, right: size12),
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
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      size8, size16, size8, size16),
                                  child: FocusScope(
                                    child: Focus(
                                      onFocusChange: (value) {
                                        isKeyboardActive = value;
                                        setState(() {});
                                      },
                                      child: TextField(
                                        controller: searchController,
                                        focusNode: textFieldFocusNode,
                                        onChanged: ((value) {
                                          _runSearchDistrict(value);
                                          setState(() {});
                                        }),
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
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
                                            suffixIcon: searchController
                                                    .text.isNotEmpty
                                                ? GestureDetector(
                                                    onTap: () {
                                                      searchController.text =
                                                          '';
                                                      _runSearchDistrict('');
                                                      setState(() {});
                                                    },
                                                    child: Icon(
                                                      PhosphorIcons.x_fill,
                                                      size: 20,
                                                      color: bnw900,
                                                    ),
                                                  )
                                                : null,
                                            prefixIcon: Icon(
                                              PhosphorIcons.magnifying_glass,
                                              color: bnw500,
                                            ),
                                            hintText: 'Cari',
                                            hintStyle: heading3(FontWeight.w500,
                                                bnw500, 'Outfit')),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: searchResultListDistrict == null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                                "Isi Kabupaten/Kota terlebih dahulu"),
                                          ],
                                        )
                                      : ListView.builder(
                                          keyboardDismissBehavior:
                                              ScrollViewKeyboardDismissBehavior
                                                  .onDrag,
                                          physics: BouncingScrollPhysics(),
                                          itemCount: searchResultListDistrict
                                                  ?.length ??
                                              0,
                                          itemBuilder: (context, index) {
                                            final district =
                                                searchResultListDistrict?[
                                                    index];
                                            final isSelected =
                                                district == selectedDistrict;

                                            return Column(
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                    district['NAME'] != null
                                                        ? capitalizeEachWord(
                                                            district['NAME']
                                                                .toString())
                                                        : '',
                                                  ),
                                                  trailing: Icon(
                                                    isSelected
                                                        ? PhosphorIcons
                                                            .radio_button_fill
                                                        : PhosphorIcons
                                                            .radio_button,
                                                    color: isSelected
                                                        ? primary500
                                                        : bnw900,
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      textFieldFocusNode
                                                          .unfocus();
                                                      _mydistrict =
                                                          district['ID'];
                                                      // idkec = district['ID'];

                                                      kec = district['NAME'];

                                                      selectedRegencies =
                                                          district.toString();
                                                      _selectDistrict(district);

                                                      print(district['NAME']);
                                                    });
                                                  },
                                                ),
                                                Divider(color: bnw300),
                                              ],
                                            );
                                          },
                                        ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    autoReload();
                                    _getVillageList(_mydistrict);
                                    Navigator.pop(context);
                                  },
                                  child: buttonXXL(
                                    Center(
                                      child: Text(
                                        'Selesai',
                                        style: heading2(
                                            FontWeight.w600, bnw100, 'Outfit'),
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
          );
        },
        child: dropdownfieldXL('Kecamatan', kec, 'Pilih Kecamatan'));
  }

  GestureDetector villageField() {
    bool isKeyboardActive = false;
    return GestureDetector(
        onTap: () {
          setState(
            () {
              autoReload();
              log(desa.toString());
              showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size24),
                ),
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, setState) =>
                        FractionallySizedBox(
                      heightFactor: isKeyboardActive ? 0.9 : 0.6,
                      child: GestureDetector(
                        onTap: () => textFieldFocusNode.unfocus(),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 1.8,
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          decoration: BoxDecoration(
                            color: bnw100,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size12),
                              topLeft: Radius.circular(size12),
                            ),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: size12, right: size12),
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
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      size8, size16, size8, size16),
                                  child: FocusScope(
                                    child: Focus(
                                      onFocusChange: (value) {
                                        isKeyboardActive = value;
                                        setState(() {});
                                      },
                                      child: TextField(
                                        controller: searchController,
                                        focusNode: textFieldFocusNode,
                                        onChanged: ((value) {
                                          _runSearchVillage(value);
                                          setState(() {});
                                        }),
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
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
                                            suffixIcon: searchController
                                                    .text.isNotEmpty
                                                ? GestureDetector(
                                                    onTap: () {
                                                      searchController.text =
                                                          '';
                                                      _runSearchVillage('');
                                                      setState(() {});
                                                    },
                                                    child: Icon(
                                                      PhosphorIcons.x_fill,
                                                      size: 20,
                                                      color: bnw900,
                                                    ),
                                                  )
                                                : null,
                                            prefixIcon: Icon(
                                              PhosphorIcons.magnifying_glass,
                                              color: bnw500,
                                            ),
                                            hintText: 'Cari',
                                            hintStyle: heading3(FontWeight.w500,
                                                bnw500, 'Outfit')),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: searchResultListVillage == null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                                "Isi Kecamatan terlebih dahulu"),
                                          ],
                                        )
                                      : ListView.builder(
                                          keyboardDismissBehavior:
                                              ScrollViewKeyboardDismissBehavior
                                                  .onDrag,
                                          physics: BouncingScrollPhysics(),
                                          itemCount:
                                              searchResultListVillage?.length ??
                                                  0,
                                          itemBuilder: (context, index) {
                                            final village =
                                                searchResultListVillage?[index];
                                            final isSelected =
                                                village == selectedVillage;

                                            return Column(
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                    village['NAME'] != null
                                                        ? capitalizeEachWord(
                                                            village['NAME']
                                                                .toString())
                                                        : '',
                                                  ),
                                                  trailing: Icon(
                                                    isSelected
                                                        ? PhosphorIcons
                                                            .radio_button_fill
                                                        : PhosphorIcons
                                                            .radio_button,
                                                    color: isSelected
                                                        ? primary500
                                                        : bnw900,
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      textFieldFocusNode
                                                          .unfocus();
                                                      _myvillage =
                                                          village['ID'];
                                                      desa = village['NAME'];
                                                      // iddesa = village['ID'];

                                                      selectedVillage =
                                                          village.toString();
                                                      _selectVillage(village);

                                                      print(village['NAME']);
                                                    });
                                                  },
                                                ),
                                                Divider(color: bnw300),
                                              ],
                                            );
                                          },
                                        ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    autoReload();
                                    // _getVillageList(_);
                                    Navigator.pop(context);
                                  },
                                  child: buttonXXL(
                                    Center(
                                      child: Text(
                                        'Selesai',
                                        style: heading2(
                                            FontWeight.w600, bnw100, 'Outfit'),
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
          );
        },
        child: dropdownfieldXL('Kelurahan', desa, 'Pilih Kelurahan'));
  }

  List<dynamic>? provincesList;
  List<dynamic>? searchResultList;
  dynamic selectedProvince;
  bool isItemSelected = false;

  String? _myProvince;

  String provinceInfoUrl = '$url/api/province';
  Future _getProvinceList() async {
    await http.post(
      Uri.parse(provinceInfoUrl),
      headers: {},
      body: {
        "deviceid": identifier,
      },
    ).then((response) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          setState(() {
            provincesList = List<dynamic>.from(data['data']);
            searchResultList = provincesList;
          });
        }
      }
    });
  }

  void _runSearchProvince(String searchText) {
    setState(() {
      searchResultList = provincesList
          ?.where(
            (province) => province
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase()),
          )
          .toList();
    });
  }

  void _selectProvince(dynamic province) {
    setState(() {
      selectedProvince = province;
      isItemSelected = true;
    });
  }

  // Get Regencies information by API
  List<dynamic>? regenciesList;
  List<dynamic>? searchResultListRegencies;

  dynamic selectedRegencies;
  // bool isItemSelected = false;

  String? _myRegencies;

  String regenciesInfoUrl = '$url/api/regencies';
  Future _getRegenciesList(idregencies) async {
    await http.post(Uri.parse(regenciesInfoUrl), headers: {
      // 'token': widget.token,
    }, body: {
      "deviceid": identifier,
      "province": idregencies,
    }).then((response) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          setState(() {
            regenciesList = List<dynamic>.from(data['data']);
            searchResultListRegencies = regenciesList;
          });
        }
      }
    });
  }

  void _runSearchRegencies(String searchText) {
    setState(() {
      searchResultListRegencies = regenciesList
          ?.where((regencies) => regencies
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void _selectRegencies(dynamic regencies) {
    setState(() {
      selectedRegencies = regencies;
      isItemSelected = true;
    });
  }

  // Get District information by API
  List<dynamic>? districtList;
  List<dynamic>? searchResultListDistrict;

  dynamic selectedDistrict;
  String? _mydistrict;

  String districtInfoUrl = '$url/api/district';
  Future _getDistrictList(iddistrict) async {
    await http.post(Uri.parse(districtInfoUrl), headers: {
      // 'token': widget.token,
    }, body: {
      "deviceid": identifier,
      "regencies": iddistrict,
    }).then((response) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          setState(() {
            districtList = List<dynamic>.from(data['data']);
            searchResultListDistrict = districtList;
          });
        }
      }
    });
  }

  void _runSearchDistrict(String searchText) {
    setState(() {
      searchResultListDistrict = districtList
          ?.where((district) => district
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void _selectDistrict(dynamic district) {
    setState(() {
      selectedDistrict = district;
      isItemSelected = true;
    });
  }

  // Get District information by API
  List<dynamic>? villageList;
  List<dynamic>? searchResultListVillage;

  dynamic selectedVillage;
  String? _myvillage;

  String villageInfoUrl = '$url/api/village';
  Future _getVillageList(idvillage) async {
    await http.post(Uri.parse(villageInfoUrl), headers: {
      // 'token': widget.token
    }, body: {
      "deviceid": identifier,
      "district": idvillage,
    }).then((response) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          setState(() {
            villageList = List<dynamic>.from(data['data']);
            searchResultListVillage = villageList;
          });
        }
      }
    });
  }

  void _runSearchVillage(String searchText) {
    setState(() {
      searchResultListVillage = villageList
          ?.where((village) => village
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void _selectVillage(dynamic village) {
    setState(() {
      selectedVillage = village;
      isItemSelected = true;
    });
  }

  // Get District information by API
  List<dynamic>? tipeList;
  List<dynamic>? searchResultListTipeUsaha;

  dynamic selectedTipeUsaha;

  String? _mytipe;

  String tipeInfoUrl = '$url/api/tipeusaha';
  Future _getTipeList() async {
    await http.post(Uri.parse(tipeInfoUrl), headers: {
      // 'token': widget.token
    }, body: {
      "deviceid": identifier,
    }).then((response) {
      final data = json.decode(response.body);
      if (data != null && data['data'] != null) {
        setState(() {
          tipeList = List<dynamic>.from(data['data']);
          searchResultListTipeUsaha = tipeList;
        });
      }
    });
  }

  void _runSearchTipeUsaha(String searchText) {
    setState(() {
      searchResultListTipeUsaha = tipeList
          ?.where((tipeUsaha) => tipeUsaha
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void _selectTipeUsaha(dynamic tipeUsaha) {
    setState(() {
      selectedTipeUsaha = tipeUsaha;
      isItemSelected = true;
    });
  }

//! sampai sini
  newRegis(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(size32, 0, size32, size16),
      child: Column(
        children: [
          appbar(context, false),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(overscroll: false),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar',
                      style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    Text(
                      'Isikan data anda dengan lengkap',
                      style: heading3(FontWeight.w500, bnw500, 'Outfit'),
                    ),
                    SizedBox(height: size24),
                    Row(
                      children: [
                        Text(
                          'Nama Lengkap ',
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                        Text(
                          '*',
                          style: heading4(FontWeight.w700, red500, 'Outfit'),
                        ),
                      ],
                    ),
                    fieldMethod(
                        'Cth : Muhammad Nabil Musyaffa', nameController),
                    SizedBox(height: size12),
                    Row(
                      children: [
                        Text(
                          'Nomor Telepon ',
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                        Text(
                          '*',
                          style: heading4(FontWeight.w700, red500, 'Outfit'),
                        ),
                      ],
                    ),
                    fieldMethodPhone('08123456789', phoneController),
                    SizedBox(height: size12),
                    Row(
                      children: [
                        Text(
                          'Email ',
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                        Text(
                          '*',
                          style: heading4(FontWeight.w700, red500, 'Outfit'),
                        ),
                      ],
                    ),
                    fieldMethod('Cth: nabil@gmail.com', emailController),
                  ],
                ),
              ),
            ),
          ),
          bttnValidated2
              ? Column(
                  children: [
                    SizedBox(height: size48),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: GestureDetector(
                        onTap: () => register(
                          context,
                          OtpPageMobile(
                            phone: phoneController.text,
                            name: nameController.text,
                            email: emailController.text,
                            pageidentify: 'public_register_page',
                          ),
                        ),
                        child: buttonXXLonOff(
                          Center(
                            child: Text(
                              'Daftar',
                              style:
                                  heading2(FontWeight.w600, bnw100, 'Outfit'),
                            ),
                          ),
                          0,
                          onOffButton,
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }

  SizedBox fieldMethod(String text, mycontroller) {
    return SizedBox(
      child: TextFormField(
        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
        onChanged: (value) {
          refreshData();
          setState(() {
            if (value.contains('@') || value.endsWith('.com')) {
              onOffButton = primary500;
            } else if (value.startsWith('08') || value.length < 10) {
              onOffButton = primary500;
            }
          });
        },
        controller: mycontroller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: size12),
          hintText: text,
          hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
        ),
      ),
    );
  }

  SizedBox fieldMethodPhone(String text, mycontroller) {
    return SizedBox(
      child: TextFormField(
        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            refreshData();
            if (value.contains('@') || value.endsWith('.com')) {
              onOffButton = primary500;
            } else if (value.startsWith('0size8') || value.length < 10) {
              onOffButton = primary500;
            }
          });
        },
        controller: mycontroller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: size12),
          hintText: text,
          hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
        ),
      ),
    );
  }

  Container boxLoginRegister(Color color1, color2, String text, color3) {
    return Container(
      decoration: BoxDecoration(
          color: color1, borderRadius: BorderRadius.circular(size8)),
      height: 63,
      width: 62,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Icon(
          Icons.login_rounded,
          size: 18,
          color: color2,
        ),
        Text(
          text,
        ),
      ]),
    );
  }

  Future register(context, page) async {
    try {
      final response = await http.post(
        Uri.parse(registerGlobalMerchbyOtp),
        body: {
          "email": emailController.text,
          "fullname": nameController.text,
          "phonenumber": phoneController.text,
          "namemerchant": conNameMerch.text,
          "address": conAddress.text,
          "businesstype": tipe,
          "province": _myProvince.toString(),
          "regency": _myRegencies.toString(),
          "district": _mydistrict.toString(),
          "village": _myvillage.toString(),
          "zipcode": conCodePos.text,
          'deviceid': identifier.toString(),
          "reg_type": "single/multi",
          "image": "data:image/png;base64,$img64"
        },
      );
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        log(jsonResponse['data']);
        log("succes");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      } else {
        log(jsonResponse['message']);

        showSnackbar(context, jsonResponse);
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  textfieldXLdaftar(
    title,
    hintText,
    textError,
    TextEditingController controller,
    bool validate,
  ) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: heading4(FontWeight.w500, bnw900, 'Outfit'),
              ),
              Text(
                '*',
                style: heading4(FontWeight.w700, red500, 'Outfit'),
              ),
            ],
          ),
          IntrinsicHeight(
            child: Container(
              child: TextFormField(
                style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                onChanged: (value) {
                  setState(() {
                    refreshData();
                  });
                },
                cursorColor: primary500,
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                  hintText: hintText,
                  hintStyle: heading2(FontWeight.w600, bnw400, 'Outfit'),
                  errorText: validate ? textError : null,
                  errorStyle: body1(FontWeight.w500, red500, 'Outfit'),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: primary500,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: bnw400,
                    ),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: red500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String capitalizeEachWord(String input) {
  if (input.isEmpty) {
    return input;
  }

  List<String> words = input.split(' ');
  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] =
          words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
    }
  }

  return words.join(' ');
}
