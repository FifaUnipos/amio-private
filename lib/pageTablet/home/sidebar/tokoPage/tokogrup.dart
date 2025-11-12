import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' as Io;
import 'dart:io';
import 'dart:typed_data';

import '../../../../pagehelper/loginregis/daftar_akun_toko.dart';
import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../utils/component/component_showModalBottom.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../../utils/component/component_orderBy.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../utils/component/component_loading.dart';
import '../../../../main.dart';
import '../../../../models/tokoModel/singletokomodel.dart';
import '../../../../models/tokomodel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../../utils/component/skeletons.dart';
import '../../../tokopage/sidebar/produkToko/produk.dart';
import 'tambahToko.dart';import '../../../../utils/component/component_color.dart';
import 'ubahToko.dart';import '../../../../utils/component/component_button.dart';

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

  Timer? _debounce;

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(seconds: 2), () async {
      datas = await getAllToko(context, widget.token, value, '');
      setState(() {});
    });
  }

  File? myImage;
  Uint8List? bytes;
  String? img64;
  List<String> images = [];

  Future<void> getImage() async {
    var picker = ImagePicker();
    PickedFile? image;

    image = await picker.getImage(source: ImageSource.gallery,maxHeight: 900,
      maxWidth: 900,);
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

  TextEditingController conNameMerch = TextEditingController();
  TextEditingController conCodeStore = TextEditingController();
  TextEditingController conAddress = TextEditingController();
  TextEditingController conCodePos = TextEditingController();

  TextEditingController searchController = TextEditingController();

  List<SingleDataToko>? singleDatas;

  late TextEditingController conNameMerchEdit = TextEditingController();
  late TextEditingController conAddressEdit = TextEditingController();
  late TextEditingController conCodePosEdit = TextEditingController();

  String? tipe = tipeUbah,
      prov = nameProvUbah,
      kab = nameregUbah,
      kec = nameDisUbah,
      desa = nameVillageUbah;

  // String? tipe = tipeUbah,
  //     provUbah = nameProvUbah,
  //     kabUbah = nameregUbah,
  //     disUbah = nameDisUbah,
  //     villageUbah = nameVillageUbah;

  String? idprov = kodeProvUbah,
      idkab = kodeRegUbah,
      idkec = kodeDisUbah,
      iddesa = kodeVillageUbah,
      idtipe = idtipeUbah,
      iditpe;

  void refreshTampilan() {
    myImage = null;
    conNameMerchEdit.text = '';
    conAddressEdit.text = '';
    conCodePosEdit.text = '';
    conNameMerch.text = '';
    conAddress.text = '';

    prov = '';
    kab = '';
    kec = '';
    desa = '';
    conCodePos.text = '';
    tipe = null;
    prov = '';
    kab = '';
    kec = '';
    desa = '';

    idprov = '';
    idkab = '';
    idkec = '';
    iddesa = '';
    idtipe = '';
    iditpe = '';

    setState(() {});
  }

  var bttnValidated = false;

  @override
  void initState() {
    checkConnection(context);
    _getProvinceList();
    _getTipeList();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        datas = await getAllToko(context, widget.token, '', textvalueOrderBy);

        setState(() {
          datas;
        });
      },
    );

    _pageController = PageController(
      initialPage: 0,
      keepPage: true,
      viewportFraction: 1,
    );
    super.initState();
  }

  @override
  void dispose() {
    _debounce!.cancel();
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
                  // CreateMerchant(
                  //   token: widget.token,
                  //   pageController: _pageController,
                  //   datas: datas ?? [],
                  // ),
                  createMerchant(),
                  changeMerchant(),
                  // ChangeMerchant(
                  //   token: widget.token,
                  //   pageController: _pageController,
                  //   merchantid: merchid,
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

//! page
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
                        refreshTampilan();
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
                                            ).then((value) async {
                                              await Future.delayed(
                                                  Duration(seconds: 1));
                                              if (value['rc'] == '00') {
                                                conNameMerchEdit.text =
                                                    nameMerchantUbah;
                                                conAddressEdit.text =
                                                    addressMerchantUbah;
                                                conCodePosEdit.text =
                                                    zipMerchantUbah;

                                                tipe = tipeUbah;
                                                prov = nameProvUbah;
                                                kab = nameregUbah;
                                                kec = nameDisUbah;
                                                desa = nameVillageUbah;

                                                idtipe = idtipeUbah;
                                                idprov = kodeProvUbah;
                                                idkab = kodeRegUbah;
                                                idkec = kodeDisUbah;
                                                iddesa = kodeVillageUbah;

                                                closeLoading(context);
                                                _pageController.jumpToPage(2);
                                                setState(() {});
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

  createMerchant() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size16),
        color: bnw100,
      ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _pageController.previousPage(
                    duration: Duration(milliseconds: 10),
                    curve: Curves.easeInBack,
                  ),
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
                      'Tambah Toko',
                      style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    Text(
                      'Isi data toko dengan lengkap',
                      style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: size16),
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
                                decoration: BoxDecoration(
                                  border: Border.all(color: bnw900),
                                  borderRadius: BorderRadius.circular(size8),
                                ),
                                height: 80,
                                width: 80,
                                child: myImage != null
                                    ? Image.file(myImage!, fit: BoxFit.cover)
                                    : Icon(PhosphorIcons.plus),
                              ),
                            ),
                            SizedBox(width: size12),
                            Text(
                              'Masukkan logo atau foto yang menandakan identitas dari tokomu.',
                              style:
                                  heading4(FontWeight.w400, bnw900, 'Outfit'),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => tambahGambar(context),
                          child: SizedBox(
                            child: TextFormField(
                              cursorColor: primary500,
                              style:
                                  heading3(FontWeight.w600, bnw900, 'Outfit'),
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2,
                                    color: primary500,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    width: width1,
                                    color: bnw500,
                                  ),
                                ),
                                enabled: false,
                                suffixIcon: Icon(
                                  PhosphorIcons.plus,
                                  color: bnw900,
                                ),
                                hintText: 'Tambah Gambar',
                                hintStyle:
                                    heading2(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size16),
                        fieldAddToko('Nama Toko ', 'King Dragon Roll Jakarta',
                            conNameMerch),
                        SizedBox(height: size16),
                        fieldAddToko(
                            'Alamat',
                            'Jl. Pramuka No.99, RT 001/RW 002, Marga Wisata',
                            conAddress),
                        SizedBox(height: size16),
                        fieldTipeUsaha(),
                        SizedBox(height: size16),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: provinceField(context),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2.6,
                                    child: regenciesField(context),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2.6,
                                    child: districtField(context),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2.6,
                                    child: villageField(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size16),
                        fieldAddTokoZip('Kode Pos', '1234', conCodePos),
                        SizedBox(height: size16),
                        // DropDown(token: widget.token),
                      ],
                    ),
                  ),
                  SizedBox(height: size16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            whenLoading(context);
                            createMerch(
                                    context,
                                    widget.token,
                                    conNameMerch.text,
                                    conAddress.text,
                                    idprov,
                                    idkab,
                                    idkec,
                                    iddesa,
                                    conCodePos.text,
                                    img64,
                                    _pageController,
                                    iditpe)
                                .then((value) {
                              if (value == '00') {
                                refreshTampilan();
                                setState(() {});
                                initState();
                              }
                            });
                            setState(() {});
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
                      SizedBox(width: size16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            whenLoading(context);
                            createMerch(
                                    context,
                                    widget.token,
                                    conNameMerch.text,
                                    conAddress.text,
                                    idprov,
                                    idkab,
                                    idkec,
                                    iddesa,
                                    conCodePos.text,
                                    img64,
                                    _pageController,
                                    iditpe)
                                .then((value) async {
                              if (value == '00') {
                                getAllToko(context, widget.token, '', '');
                                refreshTampilan();
                                await Future.delayed(Duration(seconds: 2));
                                _pageController.jumpToPage(0);
                                setState(() {});
                                initState();
                              }
                            });

                            // initState();
                            setState(() {});
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
      ),
    );
  }

  changeMerchant() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _pageController.jumpTo(0);
                refreshTampilan();
              },
              child: Icon(
                PhosphorIcons.arrow_left,
                size: size48,
                color: bnw900,
              ),
            ),
            SizedBox(width: size12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubah Toko',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Isi data toko dengan lengkap',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: bnw100,
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: BouncingScrollPhysics(),
                    children: [
                      Text(
                        'Foto Profil',
                        style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                      ),
                      SizedBox(height: size16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => tambahGambar(context),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: bnw900),
                                borderRadius: BorderRadius.circular(size8),
                              ),
                              height: 80,
                              width: 80,
                              child: myImage != null
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(size8),
                                      child: Image.file(
                                        myImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : imageEditToko.isEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(size8),
                                          child: Image.network(
                                            imageEditToko,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    SizedBox(
                                              child: SvgPicture.asset(
                                                  'assets/logoProduct.svg'),
                                            ),
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(size8),
                                          child: Image.network(
                                            imageEditToko,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    GestureDetector(
                                              onTap: () {
                                                tambahGambar(context);
                                              },
                                              child: SizedBox(
                                                child: Icon(
                                                  PhosphorIcons.plus,
                                                  color: bnw900,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                            ),
                          ),
                          SizedBox(width: size16),
                          Text(
                            'Masukkan logo atau foto yang menandakan identitas dari tokomu.',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => tambahGambar(context),
                        child: IntrinsicHeight(
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
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: bnw500,
                                ),
                              ),
                              enabled: false,
                              suffixIcon: Icon(
                                PhosphorIcons.plus,
                                color: bnw900,
                              ),
                              hintText: 'Tambah Gambar',
                              hintStyle:
                                  heading2(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size16),
                      fieldAddToko(
                          'Nama Toko ', conNameMerchEdit, conNameMerchEdit),
                      SizedBox(height: size16),
                      fieldAddToko('Alamat', conAddressEdit, conAddressEdit),
                      SizedBox(height: size16),
                      fieldTipeUsaha(),
                      SizedBox(height: size16),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: provinceField(context),
                              ),
                              SizedBox(width: size16),
                              Expanded(
                                child: regenciesField(context),
                              ),
                            ],
                          ),
                          SizedBox(height: size16),
                          Row(
                            children: [
                              Expanded(
                                child: districtField(context),
                              ),
                              SizedBox(width: size16),
                              Expanded(
                                child: villageField(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: size16),
                      fieldZipToko(
                          'Kode Pos', conCodePosEdit.text, conCodePosEdit),
                      SizedBox(height: size16),
                    ],
                  ),
                ),
                SizedBox(height: size16),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      whenLoading(context);
                      updateMerch(
                        context,
                        widget.token,
                        merchid,
                        conNameMerchEdit.text,
                        conAddressEdit.text,
                        idprov,
                        idkab,
                        idkec,
                        iddesa,
                        conCodePosEdit.text,
                        img64,
                        _pageController,
                        idtipe,
                      ).then((value) async {
                        if (value == '00') {
                          await Future.delayed(Duration(seconds: 1));
                          _pageController.jumpToPage(0);
                          initState();
                          setState(() {});
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
                      MediaQuery.of(context).size.width,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

// widget
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
                            ).then((value) async {
                              Navigator.of(context, rootNavigator: true).pop();
                              await Future.delayed(Duration(seconds: 2));
                              setState(() {});
                              initState();
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

  fieldAddTokoZip(title, hint, mycontroller) {
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
          IntrinsicHeight(
            child: Container(
              child: TextFormField(
                cursorColor: primary500,
                style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                controller: mycontroller,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (conNameMerch.text.isNotEmpty &&
                      conAddress.text.isNotEmpty &&
                      conCodePos.text.isNotEmpty) {
                    setState(() {
                      bttnValidated = true;
                    });
                  }
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
                      width: width1,
                      color: bnw500,
                    ),
                  ),
                  hintText: 'Cth : $hint',
                  hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  orderByTokoField() {
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

// widget edit
  fieldAddToko(title, hint, mycontroller) {
    return StatefulBuilder(
      builder: (context, setState) => Container(
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
                // onChanged: (value) {
                // mycontroller.text = value;
                //   setState(() {});
                // },
                onSaved: (value) {
                  setState(() {
                    mycontroller.text = value;
                  });
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
                      width: width1,
                      color: bnw500,
                    ),
                  ),
                  hintText: hint.toString(),
                  hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  fieldZipToko(title, hint, mycontroller) {
    return StatefulBuilder(
      builder: (context, setState) => Container(
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
                // onChanged: (value) {
                // mycontroller.text = value;
                //   setState(() {});
                // },
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  setState(() {
                    mycontroller.text = value;
                  });
                },
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
                  hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector fieldTipeUsaha() {
    bool isKeyboardActive = false;
    return GestureDetector(
      onTap: () => setState(
        () {
          showModalBottomSheet(
      constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) =>
                    FractionallySizedBox(
                  heightFactor: isKeyboardActive ? 0.9 : 0.80,
                  child: GestureDetector(
                    onTap: () => textFieldFocusNode.unfocus(),
                    child: Container(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      height: MediaQuery.of(context).size.height / 1.8,
                      decoration: BoxDecoration(
                        color: bnw100,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          topLeft: Radius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: size12),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8),
                              height: 4,
                              width: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: bnw300,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                              child: FocusScope(
                                child: Focus(
                                  onFocusChange: (value) {
                                    isKeyboardActive = value;
                                    setState(() {});
                                  },
                                  child: TextField(
                                    cursorColor: primary500,
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
                                          borderSide: BorderSide(
                                            color: bnw300,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 2,
                                            color: primary500,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
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
                                            idtipe = tipeUsaha['tipeusaha_id'];
                                            iditpe = tipeUsaha['tipeusaha_id'];
                                            tipe = tipeUsaha['nama_tipe'];

                                            selectedTipeUsaha =
                                                tipeUsaha.toString();
                                            _selectTipeUsaha(tipeUsaha);
                                            _getRegenciesList(_myProvince);
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
                            const SizedBox(height: 8)
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
                    'Tipe Usaha',
                    style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  Text(
                    ' *',
                    style: heading4(FontWeight.w400, danger500, 'Outfit'),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: size12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    tipe == null
                        ? Text(
                            'Tipe Usaha',
                            style: heading2(FontWeight.w600, bnw500, 'Outfit'),
                          )
                        : Text(
                            tipe == null
                                ? 'Tipe Usaha'
                                : toBeginningOfSentenceCase(tipe.toString()) ??
                                    '',
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                    Icon(
                      PhosphorIcons.caret_down,
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

  GestureDetector provinceField(BuildContext context) {
    bool isKeyboardActive = false;

    return GestureDetector(
      onTap: () {
        setState(
          () {
            // log(prov.toString());
            showModalBottomSheet(
      constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context, setState) =>
                      FractionallySizedBox(
                    heightFactor: isKeyboardActive ? 0.9 : 0.80,
                    child: GestureDetector(
                      onTap: () => textFieldFocusNode.unfocus(),
                      child: Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        height: MediaQuery.of(context).size.height / 1.8,
                        decoration: BoxDecoration(
                          color: bnw100,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            topLeft: Radius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                height: 4,
                                width: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: bnw300,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 16, 8, 16),
                                child: FocusScope(
                                  child: Focus(
                                    onFocusChange: (value) {
                                      isKeyboardActive = value;
                                      setState(() {});
                                    },
                                    child: TextField(
                                      cursorColor: primary500,
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
                              ),
                              Expanded(
                                child: ListView.builder(
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                                                    province['NAME'].toString())
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
                                              idprov = province['ID'];

                                              prov = province['NAME'];

                                              selectedProvince =
                                                  province.toString();
                                              _selectProvince(province);
                                              _getRegenciesList(_myProvince);
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
                              const SizedBox(height: 8)
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
      child: Container(
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
                    'Provinsi',
                    style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  Text(
                    ' *',
                    style: heading4(FontWeight.w400, danger500, 'Outfit'),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: size12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    prov!.isEmpty
                        ? Text(
                            'Provinsi',
                            style: heading2(FontWeight.w600, bnw500, 'Outfit'),
                          )
                        : Text(
                            capitalizeEachWord(prov.toString()),
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                    Icon(
                      PhosphorIcons.caret_down,
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

  GestureDetector regenciesField(BuildContext context) {
    bool isKeyboardActive = false;
    return GestureDetector(
      onTap: () {
        setState(
          () {
            log(kab.toString());
            showModalBottomSheet(
      constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context, setState) =>
                      FractionallySizedBox(
                    heightFactor: isKeyboardActive ? 0.9 : 0.80,
                    child: GestureDetector(
                      onTap: () => textFieldFocusNode.unfocus(),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 1.8,
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        decoration: BoxDecoration(
                          color: bnw100,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            topLeft: Radius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 12.0, right: 12.0),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(8),
                                height: 4,
                                width: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: bnw300,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 16, 8, 16),
                                child: FocusScope(
                                  child: Focus(
                                    onFocusChange: (value) {
                                      isKeyboardActive = value;
                                      setState(() {});
                                    },
                                    child: TextField(
                                      cursorColor: primary500,
                                      controller: searchController,
                                      focusNode: textFieldFocusNode,
                                      onChanged: ((value) {
                                        _runSearchRegencies(value);
                                        setState(() {});
                                      }),
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
                                        children: const [
                                          Text("Isi Provinsi terlebih dahulu"),
                                        ],
                                      )
                                    : ListView.builder(
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        itemCount:
                                            searchResultListRegencies?.length ??
                                                0,
                                        physics: BouncingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final regencies =
                                              searchResultListRegencies?[index];
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
                                                    idkab = regencies['ID'];
                                                    kab = regencies['NAME']
                                                        .toString();

                                                    selectedRegencies =
                                                        regencies.toString();
                                                    _selectRegencies(regencies);
                                                    _getDistrictList(
                                                        _myRegencies);
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
                              const SizedBox(height: 8)
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
      child: Container(
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
                    'Kabupaten/Kota',
                    style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  Text(
                    ' *',
                    style: heading4(FontWeight.w400, danger500, 'Outfit'),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: size12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    kab!.isEmpty
                        ? Text(
                            'Kabupaten',
                            style: heading2(FontWeight.w600, bnw500, 'Outfit'),
                          )
                        : Text(
                            capitalizeEachWord(kab.toString()),
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                    Icon(
                      PhosphorIcons.caret_down,
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

  GestureDetector districtField(BuildContext context) {
    bool isKeyboardActive = false;
    return GestureDetector(
      onTap: () {
        setState(
          () {
            // log(kec.toString());
            showModalBottomSheet(
      constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context, setState) =>
                      FractionallySizedBox(
                    heightFactor: isKeyboardActive ? 0.9 : 0.80,
                    child: GestureDetector(
                      onTap: () => textFieldFocusNode.unfocus(),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 1.8,
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        decoration: BoxDecoration(
                          color: bnw100,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            topLeft: Radius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 12.0, right: 12.0),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(8),
                                height: 4,
                                width: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: bnw300,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 16, 8, 16),
                                child: FocusScope(
                                  child: Focus(
                                    onFocusChange: (value) {
                                      isKeyboardActive = value;
                                      setState(() {});
                                    },
                                    child: TextField(
                                      cursorColor: primary500,
                                      controller: searchController,
                                      focusNode: textFieldFocusNode,
                                      onChanged: ((value) {
                                        _runSearchDistrict(value);
                                        setState(() {});
                                      }),
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
                                        children: const [
                                          Text(
                                              "Isi Kabupaten/Kota terlebih dahulu"),
                                        ],
                                      )
                                    : ListView.builder(
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        physics: BouncingScrollPhysics(),
                                        itemCount:
                                            searchResultListDistrict?.length ??
                                                0,
                                        itemBuilder: (context, index) {
                                          final district =
                                              searchResultListDistrict?[index];
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
                                                    idkec = district['ID'];

                                                    kec = district['NAME'];

                                                    selectedRegencies =
                                                        district.toString();
                                                    _selectDistrict(district);
                                                    _getVillageList(
                                                        _mydistrict);
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
                              const SizedBox(height: 8)
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
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
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
                    'Kecamatan',
                    style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  Text(
                    ' *',
                    style: heading4(FontWeight.w400, danger500, 'Outfit'),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: size12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    kec!.isEmpty
                        ? Text(
                            'Kecamatan',
                            style: heading2(FontWeight.w600, bnw500, 'Outfit'),
                          )
                        : Text(
                            capitalizeEachWord(kec.toString()),
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                            overflow: TextOverflow.ellipsis,
                          ),
                    Icon(
                      PhosphorIcons.caret_down,
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

  GestureDetector villageField() {
    bool isKeyboardActive = false;
    return GestureDetector(
      onTap: () {
        setState(
          () {
            // log(desa.toString());
            showModalBottomSheet(
      constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context, setState) =>
                      FractionallySizedBox(
                    heightFactor: isKeyboardActive ? 0.9 : 0.80,
                    child: GestureDetector(
                      onTap: () => textFieldFocusNode.unfocus(),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 1.8,
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        decoration: BoxDecoration(
                          color: bnw100,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            topLeft: Radius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 12.0, right: 12.0),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(8),
                                height: 4,
                                width: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: bnw300,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 16, 8, 16),
                                child: FocusScope(
                                  child: Focus(
                                    onFocusChange: (value) {
                                      isKeyboardActive = value;
                                      setState(() {});
                                    },
                                    child: TextField(
                                      cursorColor: primary500,
                                      controller: searchController,
                                      focusNode: textFieldFocusNode,
                                      onChanged: ((value) {
                                        _runSearchVillage(value);
                                        setState(() {});
                                      }),
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
                                        children: const [
                                          Text("Isi Kecamatan terlebih dahulu"),
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
                                                    _myvillage = village['ID'];
                                                    desa = village['NAME'];
                                                    iddesa = village['ID'];

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
                              const SizedBox(height: 8)
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
      child: Container(
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
                    'Kelurahan',
                    style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  Text(
                    ' *',
                    style: heading4(FontWeight.w400, danger500, 'Outfit'),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: size12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    desa!.isEmpty
                        ? Text(
                            'Kelurahan',
                            style: heading2(FontWeight.w600, bnw500, 'Outfit'),
                          )
                        : Text(
                            capitalizeEachWord(desa.toString()),
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                            overflow: TextOverflow.ellipsis,
                          ),
                    Icon(
                      PhosphorIcons.caret_down,
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
            // log(data['data'].toString());
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
                imageEditToko.isNotEmpty
                    ? Container(
                        height: 200,
                        width: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(120),
                          child: Image.network(
                            imageEditToko,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                SizedBox(
                              child: SvgPicture.asset('assets/logoProduct.svg'),
                            ),
                          ),
                        ),
                      )
                    : myImage != null
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
                            child: SvgPicture.asset(
                              'assets/logoProduct.svg',
                              fit: BoxFit.cover,
                            ),
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
                    (myImage != null || imageEditToko != '')
                        ? GestureDetector(
                            onTap: () async {
                              img64 = '';
                              myImage = null;
                              imageEditToko = '';
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
