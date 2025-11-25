import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/produkToko/produkVariantPage.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/produkToko/ubahProductVariantPage.dart';
import 'package:unipos_app_335/services/provider.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';

import '../../../../utils/component/component_showModalBottom.dart';
import 'dart:io' as Io;
import 'dart:io';
import 'dart:typed_data';

import 'lihatProdukPage/lihatUbahProdukPage.dart';
import '../../../../utils/component/providerModel/refreshTampilanModel.dart';
import '../../../../utils/component/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../../utils/component/component_orderBy.dart';
import '../../../../utils/component/component_loading.dart';
import '../../../../models/tokoModel/transaksiTokoModel.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';
import '../../../../utils/component/component_button.dart';
import '../../../../main.dart';
import '../../../../models/produkmodel.dart';
import '../../../../pagehelper/loginregis/daftar_akun_toko.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../../utils/component/component_orderBy.dart';

import '../../../tokopage/sidebar/produkToko/produk.dart';
import '../../../../utils/component/component_color.dart';

class LihatProdukPage extends StatefulWidget {
  String token, name, merchId;
  PageController pageController;
  LihatProdukPage({
    Key? key,
    required this.token,
    required this.name,
    required this.merchId,
    required this.pageController,
  }) : super(key: key);

  @override
  State<LihatProdukPage> createState() => _LihatProdukPageState();
}

class _LihatProdukPageState extends State<LihatProdukPage> {
  List<ModelDataProdukGrup>? datasProduk;

  PageController _pageController = PageController();

  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};
  List<String> listProduct = List.empty(growable: true);

  TextEditingController conNameProduk = TextEditingController();
  TextEditingController conHarga = TextEditingController();
  TextEditingController conHargaOnline = TextEditingController();

  TextEditingController searchController = TextEditingController();

  late String nameKategoriEdit;
  TextEditingController controllerName = TextEditingController();
  late TextEditingController controllerNameEdit = TextEditingController(
    text: nameKategoriEdit,
  );

  String textOrderBy = 'Nama Produk A ke Z';
  String textvalueOrderBy = 'upDownNama';

  List<String>? productIdCheckAll;
  String checkFill = 'kosong';

  void formatInputRp() {
    String text = conHarga.text.replaceAll('.', '');

    int value = int.tryParse(text)!; // Mengambil nilai angka dari teks

    String formattedAmount = formatCurrency(value);

    conHarga.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  void formatOnlineInputRp() {
    String text = conHargaOnline.text.replaceAll('.', '');

    int value = int.tryParse(text)!; // Mengambil nilai angka dari teks

    String formattedAmount = formatCurrency(value);

    conHargaOnline.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  void formatInputRpEdit() {
    String text = conHargaEdit.text.replaceAll('.', '');

    int value = int.tryParse(text)!; // Mengambil nilai angka dari teks

    String formattedAmount = formatCurrency(value);

    conHargaEdit.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  void formatOnlineInputRpEdit() {
    String text = conHargaOnlineEdit.text.replaceAll('.', '');

    int value = int.tryParse(text)!; // Mengambil nilai angka dari teks

    String formattedAmount = formatCurrency(value);

    conHargaOnlineEdit.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  // Edit page
  File? myImageEdit;
  Uint8List? bytesEdit;
  String? img64Edit;
  List<String> imagesEdit = [];

  Future<void> getImageEdit() async {
    var picker = ImagePicker();
    PickedFile? imageFile;

    imageFile = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 900,
      maxWidth: 900,
    );
    if (imageFile!.path.isEmpty == false) {
      myImageEdit = File(imageFile.path);

      bytesEdit = await Io.File(myImageEdit!.path).readAsBytes();
      setState(() {
        img64Edit = base64Encode(bytesEdit!);
        imagesEdit.add(img64Edit!);
        imageEdit = '';
      });
      // Clipboard.setData(ClipboardData(text: img64Edit));
    } else {
      print('Error Image');
    }
  }

  late TextEditingController conNameProdukEdit = TextEditingController();
  late TextEditingController conHargaEdit = TextEditingController();
  late TextEditingController conHargaOnlineEdit = TextEditingController();

  late bool onswitchppnEdit = ppnEdit == '0' ? false : true;
  late bool onswitchtampikanEdit = tampilEdit == '0' ? false : true;
  late String ppnAktifEdit = ppnEdit == '0' ? "Tidak Aktif" : 'Aktif';
  late String kasirAktifEdit = tampilEdit == '0' ? "Tidak Aktif" : 'Aktif';
  bool isLoading = false;
  Timer? _debounce;

  void _onChanged(String value) {
    List<String> val = [widget.merchId];
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(seconds: 2), () async {
      datasProduk = await getProductGrup(
        context,
        widget.token,
        value,
        val,
        textvalueOrderBy,
      );
      setState(() {});
    });
  }

  @override
  void initState() {
    checkConnection(context);
    conHarga.addListener(formatInputRp);
    conHargaOnline.addListener(formatOnlineInputRp);

    conHargaEdit.addListener(formatInputRpEdit);
    conHargaOnlineEdit.addListener(formatOnlineInputRpEdit);

    // getSingleProduct(context, widget.token, "", singleProductId, setState);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      List<String> value = [widget.merchId];

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
    });

    _getProductList();
    super.initState();
  }

  Future<dynamic> getDataProduk(List<String> value) async {
    List<String> val = [widget.merchId];
    return datasProduk = await getProductGrup(
      context,
      widget.token,
      '',
      val,
      textvalueOrderBy,
    );
  }

  refreshDataProduk() {
    datasProduk;
    idProduct = '';

    conNameProduk.text = '';
    conNameProdukEdit.text = '';
    conHarga.text = '';
    conHargaEdit.text = '';
    jenisProduct = '';
    jenisProductEdit = '';
    jenisProductEdit = '';
    conHargaOnline.text = '';
    conHargaOnlineEdit.text = '';

    onswitchppn = false;
    onswitchtampikan = true;

    isSelectionMode = false;
    myImage = null;
    listProduct = [];
    listProduct.clear();
    selectedFlag.clear();
    datasProduk;
    conHarga.text = '';
    idProduct = null;
    img64 = null;
    setState(() {});
  }

  autoReload() {
    setState(() {});
  }

  @override
  dispose() {
    _debounce!.cancel();
    productPrice;
    _pageController.dispose();
    conNameProduk.dispose();
    conNameProdukEdit.dispose();
    conHargaEdit.dispose();
    conHarga.dispose();
    super.dispose();
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
        imageEdit = '';
      });
      // Clipboard.setData(ClipboardData(text: img64));
    } else {
      print('Error Image');
    }
  }

  refreshTampilan() {
    conNameProdukEdit.text = '';
    nameEditProduk = '';
    hargaEditProduk = '';
    jenisProductEdit = '';
    kodejenisProductEdit = '';
    conHarga.text = '';
    conHargaOnline.text = '';
    conHargaEdit.text = '';
    conHargaOnlineEdit.text = '';
  }

  String? jenisProduct, idProduct;

  bool onswitchppn = false;
  bool onswitchtampikan = true;
  String ppnAktif = "Tidak Aktif";
  String kasirAktif = "Aktif";

  // String? imageEdit, nameEdit, kategoriEdit, hargaEdit;

  String singleProductId = '', singleImage = '';

  @override
  Widget build(BuildContext context) {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    bool light = true;

    return WillPopScope(
      onWillPop: () async {
        if (_pageController.page!.round() == 0) {
          widget.pageController.jumpToPage(0);
          return false;
        } else {
          _pageController.jumpToPage(0);
          return false;
        }
      },
      child: StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size16),
            color: bnw100,
          ),
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: [
              pageProdukToko(isFalseAvailable),
              tambahProdukToko(setState, context),
              editProdukToko(),
              ProductVariantPage(
                token: widget.token,
                pageController: _pageController,
                merchantId: widget.merchId,
              ),
              UbahProductVariantPage(
                token: widget.token,
                pageController: _pageController,
                merchantId: widget.merchId,
              ),
              // ubahProdukGrupToko(setState, context, singleProductId),
              // LihatProdukUbahPage(
              //   token: widget.token,
              //   productid: singleProductId ?? '',
              //   pageController: _pageController,
              //   merchId: widget.merchId,
              // )
            ],
          ),
        ),
      ),
    );
  }

  //! page
  tambahProdukToko(StateSetter setState, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 10),
                      curve: Curves.ease,
                    );
                    refreshTampilan();
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
                      'Tambah Produk',
                      style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    Text(
                      'Produk akan ditambahkan kedalam Toko yang telah dipilih',
                      style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: size16),
          Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                Text(
                  'Foto Produk',
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
                            : Icon(PhosphorIcons.plus, color: bnw900),
                        decoration: BoxDecoration(
                          border: Border.all(color: bnw900),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: 80,
                        width: 80,
                      ),
                    ),
                    SizedBox(width: 10),
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
                          borderSide: BorderSide(width: 2, color: primary500),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(width: 1.5, color: bnw500),
                        ),
                        enabled: false,
                        suffixIcon: Icon(PhosphorIcons.plus, color: bnw900),
                        hintText: 'Tambah Gambar',
                        hintStyle: heading2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size16),
                fieldAddProduk(
                  'Nama Produk',
                  'Matcha Latte Cappuchino',
                  conNameProduk,
                  TextInputType.text,
                ),
                SizedBox(height: size16),
                SizedBox(child: kategoriList(context)),
                SizedBox(height: size16),
                fieldAddProduk(
                  'Harga',
                  'Rp 12.000',
                  conHarga,
                  TextInputType.number,
                ),
                SizedBox(height: size16),
                fieldAddProduk(
                  'Harga Online Gojek/Grab',
                  'Rp 14.000',
                  conHargaOnline,
                  TextInputType.number,
                ),
                SizedBox(height: size16),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      onswitchppn = !onswitchppn;
                      onswitchppn
                          ? ppnAktif = "Aktif"
                          : ppnAktif = "Tidak Aktif";
                      // log(onswitchppn.toString());
                      log(ppnAktif);
                    });
                  },
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PPN',
                              style: heading2(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            Text(
                              ppnAktif,
                              style: heading4(
                                FontWeight.w400,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                          ],
                        ),
                        FlutterSwitch(
                          width: 52,
                          height: 28,
                          value: onswitchppn,
                          padding: 0,
                          activeIcon: Icon(
                            PhosphorIcons.check,
                            color: primary500,
                          ),
                          inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                          activeColor: primary500,
                          inactiveColor: bnw100,
                          borderRadius: 30,
                          inactiveToggleColor: bnw900,
                          activeToggleColor: primary200,
                          activeSwitchBorder: Border.all(color: primary500),
                          inactiveSwitchBorder: Border.all(
                            color: bnw300,
                            width: 2,
                          ),
                          onToggle: (val) {
                            setState(() {
                              onswitchppn = val;
                              onswitchppn
                                  ? ppnAktif = "Aktif"
                                  : ppnAktif = "Tidak Aktif";
                              log(onswitchppn.toString());
                              log(ppnAktif);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size16),
                Container(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // log(kasirAktif);
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
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tampilkan Di Kasir',
                                style: heading2(
                                  FontWeight.w600,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              Text(
                                kasirAktif,
                                style: heading4(
                                  FontWeight.w400,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ),
                        FlutterSwitch(
                          width: 52,
                          height: 28,
                          value: onswitchtampikan,
                          padding: 0,
                          activeIcon: Icon(
                            PhosphorIcons.check,
                            color: primary500,
                          ),
                          inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                          activeColor: primary500,
                          inactiveColor: bnw100,
                          borderRadius: 30,
                          inactiveToggleColor: bnw900,
                          activeToggleColor: primary200,
                          activeSwitchBorder: Border.all(color: primary500),
                          inactiveSwitchBorder: Border.all(
                            color: bnw300,
                            width: 2,
                          ),
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
                ),
                SizedBox(height: size16),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: GestureDetector(
                    onTap: () {
                      List<String> value = [widget.merchId];
                      // create hello world
                      createProduct(
                        context,
                        widget.token,
                        conNameProduk.text,
                        idProduct,
                        onswitchppn,
                        onswitchtampikan,
                        conHarga.text.replaceAll(RegExp(r'[^0-9]'), ''),
                        conHargaOnline.text.replaceAll(RegExp(r'[^0-9]'), ''),
                        img64.toString(),
                        value,
                        _pageController,
                      ).then((value) async {
                        if (value == '00') {
                          refreshDataProduk();
                          conNameProduk.text = '';
                          conHarga.text = '';
                          conHargaOnline.text = '';
                          idProduct = '';
                          await Future.delayed(Duration(seconds: 1));
                          _pageController.jumpToPage(3);
                          setState(() {});
                          initState();
                          getDataProduk(['']);
                        }
                      });
                      initState();
                      setState(() {});
                    },
                    child: buttonXLoutline(
                      Center(
                        child: Text(
                          'Tambah Variant',
                          style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                      ),
                      0,
                      bnw900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    List<String> value = [widget.merchId];
                    createProduct(
                      context,
                      widget.token,
                      conNameProduk.text,
                      idProduct,
                      onswitchppn,
                      onswitchtampikan,
                      conHarga.text.replaceAll(RegExp(r'[^0-9]'), ''),
                      conHargaOnline.text.replaceAll(RegExp(r'[^0-9]'), ''),
                      img64.toString(),
                      value,
                      _pageController,
                    ).then((value) {
                      if (value == '00') {
                        refreshDataProduk();
                        setState(() {});
                        initState();
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
                    print(idProduct);
                    List<String> value = [widget.merchId];

                    createProduct(
                      context,
                      widget.token,
                      conNameProduk.text,
                      idProduct,
                      onswitchppn,
                      onswitchtampikan,
                      conHarga.text.replaceAll(RegExp(r'[^0-9]'), ''),
                      conHargaOnline.text.replaceAll(RegExp(r'[^0-9]'), ''),
                      img64.toString(),
                      value,
                      _pageController,
                    ).then((value) async {
                      if (value == '00') {
                        refreshDataProduk();
                        await Future.delayed(Duration(seconds: 1));
                        conNameProduk.text = '';
                        conHarga.text = '';
                        conHargaOnline.text = '';
                        idProduct = null;
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
                    MediaQuery.of(context).size.width,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pageProdukToko(bool isFalseAvailable) {
    List<String> val = [widget.merchId];

    return FutureBuilder(
      future: getProductGrup(context, widget.token, '', val, textvalueOrderBy),
      builder: (context, snapshot) => Column(
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
                      refreshTampilan();
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
                        widget.name,
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        'Produk',
                        style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: size16),
                    Expanded(
                      child: TextField(
                        cursorColor: primary500,
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
                                    size: size24,
                                    color: bnw900,
                                  ),
                                )
                              : null,
                          hintText: 'Cari nama produk',
                          hintStyle: heading3(
                            FontWeight.w500,
                            bnw400,
                            'Outfit',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size16),
                    GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 10),
                          curve: Curves.ease,
                        );
                      },
                      child: buttonXL(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(PhosphorIcons.plus, color: bnw100),
                            SizedBox(width: size12),
                            Text(
                              'Produk',
                              style: heading3(
                                FontWeight.w600,
                                bnw100,
                                'Outfit',
                              ),
                            ),
                          ],
                        ),
                        130,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size16),
          orderBy(context),
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
                      topLeft: Radius.circular(size12),
                      topRight: Radius.circular(size12),
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
                                    FontWeight.w700,
                                    bnw100,
                                    'Outfit',
                                  ),
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
                                    FontWeight.w600,
                                    bnw100,
                                    'Outfit',
                                  ),
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
                                    FontWeight.w600,
                                    bnw100,
                                    'Outfit',
                                  ),
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
                                style: heading4(
                                  FontWeight.w600,
                                  bnw100,
                                  'Outfit',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: size16),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width / 12,
                                minWidth:
                                    MediaQuery.of(context).size.width / 12,
                              ),
                              child: Text(
                                'Tampil Kasir',
                                style: heading4(
                                  FontWeight.w600,
                                  bnw100,
                                  'Outfit',
                                ),
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
                              style: heading4(
                                FontWeight.w600,
                                bnw100,
                                'Outfit',
                              ),
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
                                            style: heading1(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                          SizedBox(height: size16),
                                          Text(
                                            'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
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
                                                deleteProduk(
                                                  context,
                                                  widget.token,
                                                  listProduct,
                                                  widget.merchId,
                                                ).then((value) async {
                                                  if (value == '00') {
                                                    refreshDataProduk();
                                                    await Future.delayed(
                                                      Duration(seconds: 1),
                                                    );
                                                    conNameProduk.text = '';
                                                    conHarga.text = '';
                                                    idProduct = null;
                                                    _pageController.jumpToPage(
                                                      0,
                                                    );
                                                    setState(() {});
                                                    initState();
                                                  }
                                                });
                                                refreshDataProduk();

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
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
                                                primary500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
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
                              child: buttonL(
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      PhosphorIcons.trash_fill,
                                      color: bnw900,
                                    ),
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
                            SizedBox(width: size8),
                            GestureDetector(
                              onTap: () {
                                listProduct.forEach((element) {
                                  datasProduk!.forEach((element2) {
                                    if (element == element2.productid) {
                                      element2.isPPN = 0;
                                    }
                                  });
                                });
                                changePpn(
                                  context,
                                  widget.token,
                                  'false',
                                  listProduct,
                                  widget.merchId,
                                ).then((value) {
                                  if (value == '00') {
                                    listProduct.forEach((element) {
                                      datasProduk!.forEach((element2) {
                                        if (element == element2.productid) {
                                          element2.isPPN = 0;
                                        }
                                      });
                                    });
                                  } else {
                                    listProduct.forEach((element) {
                                      datasProduk!.forEach((element2) {
                                        if (element == element2.productid) {
                                          element2.isPPN = 1;
                                        }
                                      });
                                    });
                                  }
                                  setState(() {});
                                  initState();
                                });

                                // log("ini adalah ${widget.merchId}");
                                refreshDataProduk();

                                setState(() {});
                                initState();
                              },
                              child: buttonL(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Nonaktifkan PPN',
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
                            SizedBox(width: size8),
                            GestureDetector(
                              onTap: () {
                                listProduct.forEach((element) {
                                  datasProduk!.forEach((element2) {
                                    if (element == element2.productid) {
                                      element2.isActive = 1;
                                    }
                                  });
                                });
                                changeActive(
                                  context,
                                  widget.token,
                                  'true',
                                  listProduct,
                                  widget.merchId,
                                ).then((value) {
                                  if (value == '00') {
                                    listProduct.forEach((element) {
                                      datasProduk!.forEach((element2) {
                                        if (element == element2.productid) {
                                          element2.isActive = 1;
                                        }
                                      });
                                    });
                                  } else {
                                    listProduct.forEach((element) {
                                      datasProduk!.forEach((element2) {
                                        if (element == element2.productid) {
                                          element2.isActive = 0;
                                        }
                                      });
                                    });
                                  }
                                  setState(() {});
                                  initState();
                                });
                                refreshDataProduk();
                                initState();
                                setState(() {});
                              },
                              child: buttonL(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Aktifkan Tampilkan dikasir',
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
                datasProduk == null
                    ? SkeletonCardLine()
                    : Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: primary100,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
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
                                ModelDataProdukGrup data = datasProduk![index];
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
                                                            size8,
                                                          ),
                                                      child:
                                                          datasProduk![index]
                                                                  .productImage !=
                                                              null
                                                          ? Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    size8,
                                                                  ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      size8,
                                                                    ),
                                                                child: Image.network(
                                                                  datasProduk![index]
                                                                      .productImage
                                                                      .toString(),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder:
                                                                      (
                                                                        context,
                                                                        error,
                                                                        stackTrace,
                                                                      ) => SizedBox(
                                                                        child: SvgPicture.asset(
                                                                          'assets/logoProduct.svg',
                                                                        ),
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
                                                            'Outfit',
                                                          ),
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
                                          SizedBox(width: size16),
                                          Expanded(
                                            flex: 2,
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
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  datasProduk![index]
                                                              .discount ==
                                                          0
                                                      ? Text(
                                                          FormatCurrency.convertToIdr(
                                                            datasProduk![index]
                                                                .price_after,
                                                          ).toString(),
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: heading4(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        )
                                                      : Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              FormatCurrency.convertToIdr(
                                                                datasProduk![index]
                                                                    .price_after,
                                                              ).toString(),
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: size4,
                                                            ),
                                                            Text(
                                                              FormatCurrency.convertToIdr(
                                                                datasProduk![index]
                                                                    .price,
                                                              ).toString(),
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  body3lineThrough(
                                                                    FontWeight
                                                                        .w400,
                                                                    bnw900,
                                                                    'Outfit',
                                                                  ),
                                                            ),
                                                            SizedBox(
                                                              height: size4,
                                                            ),
                                                            datasProduk![index]
                                                                        .discount_type ==
                                                                    'price'
                                                                ? Text(
                                                                    FormatCurrency.convertToIdr(
                                                                      datasProduk![index]
                                                                          .discount,
                                                                    ).toString(),
                                                                    maxLines: 3,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: body2(
                                                                      FontWeight
                                                                          .w700,
                                                                      danger500,
                                                                      'Outfit',
                                                                    ),
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
                                                                      'Outfit',
                                                                    ),
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
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  datasProduk![index]
                                                              .discount ==
                                                          0
                                                      ? Text(
                                                          FormatCurrency.convertToIdr(
                                                            datasProduk![index]
                                                                .price_online_shop_after,
                                                          ).toString(),
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: heading4(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        )
                                                      : Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              FormatCurrency.convertToIdr(
                                                                datasProduk![index]
                                                                    .price_online_shop_after,
                                                              ).toString(),
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: heading4(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: size4,
                                                            ),
                                                            Text(
                                                              FormatCurrency.convertToIdr(
                                                                datasProduk![index]
                                                                    .price_online_shop,
                                                              ).toString(),
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  body3lineThrough(
                                                                    FontWeight
                                                                        .w400,
                                                                    bnw900,
                                                                    'Outfit',
                                                                  ),
                                                            ),
                                                            SizedBox(
                                                              height: size4,
                                                            ),
                                                            datasProduk![index]
                                                                        .discount_type ==
                                                                    'price'
                                                                ? Text(
                                                                    FormatCurrency.convertToIdr(
                                                                      datasProduk![index]
                                                                          .discount,
                                                                    ).toString(),
                                                                    maxLines: 3,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: body2(
                                                                      FontWeight
                                                                          .w700,
                                                                      danger500,
                                                                      'Outfit',
                                                                    ),
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
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: size16),
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  18,
                                              minWidth:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  18,
                                            ),
                                            child: FlutterSwitch(
                                              padding: 1,
                                              value: dataProduk.isPPN == 1
                                                  ? true
                                                  : false,
                                              activeIcon: Icon(
                                                PhosphorIcons.check,
                                                color: primary500,
                                              ),
                                              inactiveIcon: Icon(
                                                PhosphorIcons.x,
                                                color: bnw100,
                                              ),
                                              activeColor: primary500,
                                              inactiveColor: bnw100,
                                              borderRadius: 30.0,
                                              width: 50.0,
                                              height: 27.0,
                                              inactiveToggleColor: bnw900,
                                              activeToggleColor: primary200,
                                              activeSwitchBorder: Border.all(
                                                color: primary500,
                                              ),
                                              inactiveSwitchBorder: Border.all(
                                                color: bnw300,
                                                width: 2,
                                              ),
                                              onToggle: (bool value) {
                                                dataProduk.isPPN = 1;
                                                // print('hello');
                                                List<String> listProduct = [
                                                  dataProduk.productid!,
                                                ];
                                                changePpn(
                                                  context,
                                                  widget.token,
                                                  value.toString(),
                                                  listProduct,
                                                  widget.merchId,
                                                ).then((value) {
                                                  if (value != '00') {
                                                    dataProduk.isPPN = 0;
                                                  } else {
                                                    dataProduk.isPPN = 1;
                                                  }
                                                  setState(() {});
                                                  initState();
                                                });
                                                initState();
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          SizedBox(width: size16),
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  12,
                                              minWidth:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  12,
                                            ),
                                            child: FlutterSwitch(
                                              value: dataProduk.isActive == 1
                                                  ? true
                                                  : false,
                                              padding: 1,
                                              width: 50.0,
                                              height: 27.0,
                                              activeIcon: Icon(
                                                PhosphorIcons.check,
                                                color: primary500,
                                              ),
                                              inactiveIcon: Icon(
                                                PhosphorIcons.x,
                                                color: bnw100,
                                              ),
                                              activeColor: primary500,
                                              inactiveColor: bnw100,
                                              borderRadius: 30.0,
                                              inactiveToggleColor: bnw900,
                                              activeToggleColor: primary200,
                                              activeSwitchBorder: Border.all(
                                                color: primary500,
                                              ),
                                              inactiveSwitchBorder: Border.all(
                                                color: bnw300,
                                                width: 2,
                                              ),
                                              onToggle: (bool value) {
                                                // print('hello');
                                                List<String> listProduct = [
                                                  dataProduk.productid!,
                                                ];
                                                changeActive(
                                                  context,
                                                  widget.token,
                                                  value.toString(),
                                                  listProduct,
                                                  widget.merchId,
                                                ).then((value) {
                                                  if (value != '00') {
                                                    dataProduk.isActive = 0;
                                                  } else {
                                                    dataProduk.isActive = 1;
                                                  }
                                                  setState(() {});
                                                  initState();
                                                });
                                                initState();
                                                setState(() {});
                                              },
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
                                                                      dataProduk
                                                                          .name!,
                                                                      style: heading2(
                                                                        FontWeight
                                                                            .w600,
                                                                        bnw900,
                                                                        'Outfit',
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      dataProduk
                                                                          .typeproducts!,
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
                                                                    color:
                                                                        bnw900,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            GestureDetector(
                                                              behavior:
                                                                  HitTestBehavior
                                                                      .translucent,
                                                              onTap: () async {
                                                                img64 = null;
                                                                myImage = null;
                                                                imageEdit = '';

                                                                getSingleProduct(
                                                                  context,
                                                                  widget.token,
                                                                  widget
                                                                      .merchId,
                                                                  dataProduk
                                                                      .productid,
                                                                  setState,
                                                                ).then((
                                                                  value,
                                                                ) async {
                                                                  if (value ==
                                                                      '00') {
                                                                    conNameProdukEdit
                                                                            .text =
                                                                        nameEditProduk!;

                                                                    conHargaEdit
                                                                            .text =
                                                                        hargaEditProduk!;

                                                                    conHargaOnlineEdit
                                                                            .text =
                                                                        hargaEditOnlineProduk!;

                                                                    singleProductId =
                                                                        dataProduk
                                                                            .productid!;

                                                                    onswitchppnEdit =
                                                                        ppnEdit ==
                                                                            '0'
                                                                        ? false
                                                                        : true;

                                                                    onswitchtampikanEdit =
                                                                        tampilEdit ==
                                                                            '0'
                                                                        ? false
                                                                        : true;

                                                                    ppnAktifEdit =
                                                                        ppnEdit ==
                                                                            '0'
                                                                        ? "Tidak Aktif"
                                                                        : 'Aktif';

                                                                    kasirAktifEdit =
                                                                        tampilEdit ==
                                                                            '0'
                                                                        ? "Tidak Aktif"
                                                                        : 'Aktif';

                                                                    conHargaEdit
                                                                        .text = dataProduk
                                                                        .price
                                                                        .toString();

                                                                    jenisProductEdit =
                                                                        dataProduk
                                                                            .typeproducts!;

                                                                    onswitchtampikan =
                                                                        dataProduk.isActive ==
                                                                            1
                                                                        ? true
                                                                        : false;

                                                                    onswitchppn =
                                                                        dataProduk.isPPN ==
                                                                            1
                                                                        ? true
                                                                        : false;

                                                                    idProduct =
                                                                        jenisProductEdit;
                                                                    await Future.delayed(
                                                                      Duration(
                                                                        seconds:
                                                                            1,
                                                                      ),
                                                                    );

                                                                    _pageController
                                                                        .jumpToPage(
                                                                          2,
                                                                        );
                                                                    Navigator.pop(
                                                                      context,
                                                                    );

                                                                    setState(
                                                                      () {},
                                                                    );
                                                                  }
                                                                });

                                                                // print(
                                                                //     singleProductId);
                                                              },
                                                              child: modalBottomValue(
                                                                'Ubah Produk',
                                                                PhosphorIcons
                                                                    .pencil_line,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: size12,
                                                            ),

                                                            GestureDetector(
                                                              behavior:
                                                                  HitTestBehavior
                                                                      .translucent,
                                                              onTap: () async {
                                                                whenLoading(
                                                                  context,
                                                                );
                                                                setState(
                                                                  () =>
                                                                      isLoading =
                                                                          true,
                                                                );
                                                                productIdVariant =
                                                                    dataProduk
                                                                        .productid!;
                                                                var response =
                                                                    await getProductVariant(
                                                                      context,
                                                                      widget
                                                                          .token,
                                                                      widget
                                                                          .merchId,
                                                                      dataProduk
                                                                          .productid!,
                                                                    );

                                                                print(
                                                                  '📦 ini response $response',
                                                                );

                                                                if (response !=
                                                                        null &&
                                                                    response['rc'] ==
                                                                        '00' &&
                                                                    response['data'] !=
                                                                        null) {
                                                                  Provider.of<
                                                                        ProductVariantProvider
                                                                      >(
                                                                        context,
                                                                        listen:
                                                                            false,
                                                                      )
                                                                      .setProductData(
                                                                        response['data'],
                                                                      );

                                                                  _pageController
                                                                      .jumpToPage(
                                                                        4,
                                                                      );
                                                                  closeLoading(
                                                                    context,
                                                                  );
                                                                } else {
                                                                  closeLoading(
                                                                    context,
                                                                  );
                                                                  showSnackbar(
                                                                    context,
                                                                    "Failed to fetch or no data available",
                                                                  );
                                                                }

                                                                setState(
                                                                  () =>
                                                                      isLoading =
                                                                          false,
                                                                );

                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },

                                                              child: modalBottomValue(
                                                                'Variant Produk',
                                                                PhosphorIcons
                                                                    .ruler,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: size12,
                                                            ),
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
                                                                            'Yakin Ingin Menghapus Produk?',
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
                                                                            'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
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
                                                                                listProduct = [
                                                                                  dataProduk.productid!,
                                                                                ];

                                                                                deleteProduk(
                                                                                  context,
                                                                                  widget.token,
                                                                                  listProduct,
                                                                                  widget.merchId,
                                                                                ).then(
                                                                                  (
                                                                                    value,
                                                                                  ) async {
                                                                                    if (value ==
                                                                                        '00') {
                                                                                      refreshDataProduk();
                                                                                      await Future.delayed(
                                                                                        Duration(
                                                                                          seconds: 1,
                                                                                        ),
                                                                                      );
                                                                                      conNameProduk.text = '';
                                                                                      conHarga.text = '';
                                                                                      idProduct = '';
                                                                                      _pageController.jumpToPage(
                                                                                        0,
                                                                                      );
                                                                                      setState(
                                                                                        () {},
                                                                                      );
                                                                                      initState();
                                                                                    }
                                                                                  },
                                                                                );
                                                                                ;
                                                                                refreshDataProduk();

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
                                                                                12,
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
                                                              child: modalBottomValue(
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
      ),
    );
  }

  editProdukToko() {
    return Consumer<RefreshTampilan>(
      builder: (context, provider, _) => Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _pageController.jumpToPage(0);
                  refreshDataProduk();
                  refreshTampilan();
                  getDataProduk(['']);
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
                    'Ubah Produk',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Produk akan ditambahkan kedalam Toko yang telah dipilih',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: ListView(
              // padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              children: [
                Text(
                  'Foto Produk',
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
                        child: myImageEdit != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(size8),
                                child: Image.file(
                                  myImageEdit!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : imageEdit!.isEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(size8),
                                child: Image.network(
                                  imageEdit!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      SizedBox(
                                        child: SvgPicture.asset(
                                          'assets/logoProduct.svg',
                                        ),
                                      ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(size8),
                                child: Image.network(
                                  imageEdit!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
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
                  onTap: () => tambahGambarEdit(context),
                  child: IntrinsicHeight(
                    child: TextFormField(
                      cursorColor: primary500,
                      style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(width: 2, color: primary500),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(width: 1.5, color: bnw500),
                        ),
                        enabled: false,
                        suffixIcon: Icon(PhosphorIcons.plus, color: bnw900),
                        hintText: 'Tambah Gambar',
                        hintStyle: heading2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size16),
                fieldEditProduk(
                  'Nama Produk',
                  conNameProdukEdit,
                  TextInputType.text,
                ),
                SizedBox(height: size16),
                kategoriList(context),
                SizedBox(height: size16),
                fieldEditProduk('Harga', conHargaEdit, TextInputType.number),
                SizedBox(height: size16),
                fieldEditProdukTanpaBintang(
                  'Harga Online',
                  conHargaOnlineEdit,
                  TextInputType.number,
                ),
                SizedBox(height: size16),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      onswitchppnEdit = !onswitchppnEdit;
                      onswitchppnEdit
                          ? ppnAktifEdit = "Aktif"
                          : ppnAktifEdit = "Tidak Aktif";
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PPN',
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          Text(
                            ppnAktifEdit,
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                      FlutterSwitch(
                        width: 52,
                        height: 28,
                        // value: snapshot.data['isActive'] == 1 ? true : false,
                        value: onswitchppnEdit,
                        padding: 0,
                        activeIcon: Icon(
                          PhosphorIcons.check,
                          color: primary500,
                        ),
                        inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                        activeColor: primary500,
                        inactiveColor: bnw100,
                        borderRadius: 30,
                        inactiveToggleColor: bnw900,
                        activeToggleColor: primary200,
                        activeSwitchBorder: Border.all(color: primary500),
                        inactiveSwitchBorder: Border.all(
                          color: bnw300,
                          width: 2,
                        ),
                        onToggle: (val) {
                          setState(() {
                            onswitchppnEdit = val;
                            onswitchppnEdit
                                ? ppnAktifEdit = "Aktif"
                                : ppnAktifEdit = "Tidak Aktif";
                            log(onswitchppnEdit.toString());
                            log(ppnAktifEdit);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size16),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      onswitchtampikanEdit = !onswitchtampikanEdit;
                      onswitchtampikanEdit
                          ? kasirAktifEdit = "Aktif"
                          : kasirAktifEdit = "Tidak Aktif";
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tampilkan Di Kasir',
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          Text(
                            kasirAktifEdit,
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                      FlutterSwitch(
                        width: 52,
                        height: 28,

                        // value: snapshot.data['isPPN'] == 1 ? true : false,
                        value: onswitchtampikanEdit,
                        padding: 0,
                        activeIcon: Icon(
                          PhosphorIcons.check,
                          color: primary500,
                        ),
                        inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                        activeColor: primary500,
                        inactiveColor: bnw100,
                        borderRadius: 30,
                        inactiveToggleColor: bnw900,
                        activeToggleColor: primary200,
                        activeSwitchBorder: Border.all(color: primary500),
                        inactiveSwitchBorder: Border.all(
                          color: bnw300,
                          width: 2,
                        ),
                        onToggle: (val) {
                          onswitchtampikanEdit = val;
                          onswitchtampikanEdit
                              ? kasirAktifEdit = "Aktif"
                              : kasirAktifEdit = "Tidak Aktif";
                          log(onswitchtampikanEdit.toString());
                          // log(kasirAktifEdit);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size16),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onTap: () async {
                // print(idProduct);
                // print(singleProductId);
                if (img64Edit == 'hapus') {
                  img64Edit = null;
                } else if (imageEdit!.isNotEmpty) {
                  img64Edit = '';
                } else {
                  img64Edit = img64Edit;
                }

                List<String> value = [""];
                updateProduk(
                  context,
                  widget.token,
                  conNameProdukEdit.text,
                  widget.merchId,
                  singleProductId,
                  idProduct,
                  conHargaEdit.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  conHargaOnlineEdit.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  _pageController,
                  onswitchtampikanEdit,
                  onswitchppnEdit,
                  img64Edit.toString(),
                ).then((value) async {
                  if (value == '00') {
                    refreshDataProduk();
                    await Future.delayed(Duration(seconds: 1));
                    refreshTampilan();
                    _pageController.jumpToPage(0);
                    getDataProduk(['']);
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
                MediaQuery.of(context).size.width,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //! widget
  modalBottomValue(String title, icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: size16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: bnw300, width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: bnw900),
              SizedBox(width: size16),
              Text(title, style: heading3(FontWeight.w400, bnw900, 'Outfit')),
            ],
          ),
        ),
        // Divider(color: bnw300)
      ],
    );
  }

  tambahGambarEdit(BuildContext context) async {
    showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                imageEdit!.isNotEmpty
                    ? Container(
                        height: 200,
                        width: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(120),
                          child: Image.network(
                            imageEdit!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                SizedBox(
                                  child: SvgPicture.asset(
                                    'assets/logoProduct.svg',
                                  ),
                                ),
                          ),
                        ),
                      )
                    : myImageEdit != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(120),
                        child: Container(
                          height: 200,
                          width: 200,
                          color: bnw400,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(size8),
                            child: Image.file(myImageEdit!, fit: BoxFit.cover),
                          ),
                        ),
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
                        await getImageEdit();
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
                            prefixIcon: Icon(PhosphorIcons.plus, color: bnw900),
                            hintText: 'Tambah Foto',
                            hintStyle: heading3(
                              FontWeight.w400,
                              bnw900,
                              'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ),
                    (myImageEdit != null || imageEdit != '')
                        ? GestureDetector(
                            onTap: () async {
                              img64Edit = 'hapus';
                              myImageEdit = null;
                              imageEdit = '';
                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: SizedBox(
                              child: TextFormField(
                                cursorColor: primary500,
                                enabled: false,
                                style: heading3(
                                  FontWeight.w400,
                                  bnw900,
                                  'Outfit',
                                ),
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

  fieldEditProdukTanpaBintang(title, mycontroller, TextInputType numberNo) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: heading4(FontWeight.w500, bnw900, 'Outfit')),
            ],
          ),
          IntrinsicHeight(
            child: TextFormField(
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
                  borderSide: BorderSide(width: 2, color: primary500),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: size12),
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1.5, color: bnw500),
                ),
                hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  fieldAddProduk(title, hint, mycontroller, TextInputType numberNo) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: body1(FontWeight.w500, bnw900, 'Outfit')),
              Text(' *', style: body1(FontWeight.w700, red500, 'Outfit')),
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
                borderSide: BorderSide(width: 2, color: primary500),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: size12),
              isDense: true,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(width: 1.5, color: bnw500),
              ),
              hintText: 'Cth : $hint',
              hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }

  fieldEditProduk(title, mycontroller, TextInputType numberNo) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: body1(FontWeight.w500, bnw900, 'Outfit')),
              Text(' *', style: body1(FontWeight.w700, red500, 'Outfit')),
            ],
          ),
          IntrinsicHeight(
            child: TextFormField(
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
                  borderSide: BorderSide(width: 2, color: primary500),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: size12),
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1.5, color: bnw500),
                ),
                hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
              ),
            ),
          ),
        ],
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

  Widget _buildSelectIcon(bool isSelected, ModelDataProdukGrup data) {
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
    log(productId.toString());
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

  kategoriList(BuildContext context) {
    bool isKeyboardActive = false;

    return GestureDetector(
      onTap: () {
        setState(() {
          // log(jenisProduct.toString());
          showModalBottomSheet(
            constraints: const BoxConstraints(maxWidth: double.infinity),
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) => FractionallySizedBox(
                  heightFactor: isKeyboardActive ? 0.9 : 0.6,
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
                          topRight: Radius.circular(12),
                          topLeft: Radius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          size32,
                          size16,
                          size32,
                          size32,
                        ),
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
                                child: TextField(
                                  cursorColor: primary500,
                                  controller: searchController,
                                  focusNode: textFieldFocusNode,
                                  onChanged: (value) {
                                    //   isKeyboardActive = value.isNotEmpty;
                                    _runSearchProduct(value);
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
                            ),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  initState();
                                },
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  children: [
                                    SizedBox(height: size16),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        tambahKategori(
                                          context,
                                          isKeyboardActive,
                                          setState,
                                        );
                                        _getProductList();
                                      },
                                      child: buttonXLoutline(
                                        Center(
                                          child: Text(
                                            'Tambah Kategori',
                                            style: heading2(
                                              FontWeight.w600,
                                              primary500,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                        double.infinity,
                                        primary500,
                                      ),
                                    ),
                                    SizedBox(height: size16),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      physics: BouncingScrollPhysics(),
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      itemCount:
                                          searchResultListProduct?.length,
                                      itemBuilder: (context, index) {
                                        final product =
                                            searchResultListProduct?[index];
                                        final isSelected =
                                            product == selectedProduct;

                                        return Column(
                                          children: [
                                            ListTile(
                                              title: Text(
                                                product['jenisproduct'] != null
                                                    ? capitalizeEachWord(
                                                        product['jenisproduct']
                                                            .toString(),
                                                      )
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
                                                  textFieldFocusNode.unfocus();
                                                  jenisProductEdit =
                                                      product['jenisproduct'];

                                                  jenisProduct =
                                                      product['jenisproduct'];

                                                  idProduct =
                                                      product['kodeproduct'];

                                                  _selectProduct(product);

                                                  print(
                                                    product['jenisproduct'],
                                                  );
                                                });
                                              },
                                              onLongPress: () {
                                                Navigator.pop(context);
                                                nameKategoriEdit =
                                                    product['jenisproduct'];
                                                ubahHapusKategori(
                                                  product,
                                                  setState,
                                                );
                                              },
                                            ),
                                            Divider(color: bnw300),
                                          ],
                                        );
                                      },
                                    ),
                                    SizedBox(height: size16),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {});
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
                      jenisProductEdit == ''
                          ? 'Pilih Kategori'
                          : capitalizeEachWord(jenisProductEdit.toString()),
                      style: heading2(
                        FontWeight.w600,
                        jenisProductEdit == '' ? bnw500 : bnw900,
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

  ubahHapusKategori(product, StateSetter setState) {
    showModalBottom(
      context,
      MediaQuery.of(context).size.height,
      IntrinsicHeight(
        child: Padding(
          padding: EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['jenisproduct'],
                        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(PhosphorIcons.x_fill, color: bnw900),
                  ),
                ],
              ),
              SizedBox(height: size24),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.pop(context);
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
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        // height: MediaQuery.of(context).size.height / 1,
                        decoration: BoxDecoration(
                          color: bnw100,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            topLeft: Radius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            size32,
                            size16,
                            size32,
                            size32,
                          ),
                          child: Column(
                            children: [
                              dividerShowdialog(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size16),
                                  Text(
                                    'Ubah Kategori',
                                    style: heading1(
                                      FontWeight.w700,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                  SizedBox(height: size16),
                                  Row(
                                    children: [
                                      Text(
                                        'Kategori ',
                                        style: heading4(
                                          FontWeight.w400,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      Text(
                                        '*',
                                        style: heading4(
                                          FontWeight.w400,
                                          danger500,
                                          'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                  FocusScope(
                                    child: TextFormField(
                                      cursorColor: primary500,
                                      style: heading2(
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
                                      controller: controllerNameEdit,
                                      decoration: InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 2,
                                            color: primary500,
                                          ),
                                        ),
                                        focusColor: primary500,
                                        hintText: 'Cth : Rental Mobil',
                                        hintStyle: heading2(
                                          FontWeight.w600,
                                          bnw400,
                                          'Outfit',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size32),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: buttonXLoutline(
                                        Center(
                                          child: Text(
                                            'Batal',
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
                                  SizedBox(width: size16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        whenLoading(context);
                                        ubahKategoriForm(
                                          context,
                                          widget.token,
                                          product['kodeproduct'],
                                          controllerNameEdit.text,
                                        ).then((value) {
                                          if (value == '00') {
                                            errorText = '';
                                            controllerNameEdit.text = '';
                                          }
                                        });
                                        _getProductList();
                                        refreshDataProduk();
                                        getDataProduk(['']);
                                        setState(() {});
                                        initState();
                                      },
                                      child: buttonXL(
                                        Center(
                                          child: Text(
                                            'Simpan',
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
                        ),
                      ),
                    ),
                  );
                },
                child: modalBottomValue(
                  'Ubah Kategori',
                  PhosphorIcons.pencil_line,
                ),
              ),
              SizedBox(height: size12),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.pop(context);
                  showBottomPilihan(
                    context,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Yakin Ingin Menghapus Kategori?',
                              style: heading1(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            SizedBox(height: size16),
                            Text(
                              'Data kategori yang sudah dihapus tidak dapat dikembalikan lagi.',
                              style: heading2(
                                FontWeight.w400,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            SizedBox(height: size16),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  hapusKategoriForm(
                                    context,
                                    widget.token,
                                    product['kodeproduct'],
                                  );

                                  initState();
                                  setState(() {});
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
                                  double.infinity,
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
                child: modalBottomValue('Hapus Kategori', PhosphorIcons.trash),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> tambahKategori(
    BuildContext context,
    bool isKeyboardActive,
    StateSetter setState,
  ) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          // height: MediaQuery.of(context).size.height / 1,
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
            child: Column(
              children: [
                dividerShowdialog(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size16),
                    Text(
                      'Tambah Kategori',
                      style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    SizedBox(height: size16),
                    Row(
                      children: [
                        Text(
                          'Kategori ',
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                        Text(
                          '*',
                          style: heading4(FontWeight.w400, danger500, 'Outfit'),
                        ),
                      ],
                    ),
                    FocusScope(
                      child: Focus(
                        onFocusChange: (value) {
                          isKeyboardActive = value;
                          setState(() {});
                        },
                        child: TextFormField(
                          cursorColor: primary500,
                          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          controller: controllerName,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: primary500,
                              ),
                            ),
                            focusColor: primary500,
                            hintText: 'Cth : Rental Mobil',
                            hintStyle: heading2(
                              FontWeight.w600,
                              bnw400,
                              'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: buttonXLoutline(
                          Center(
                            child: Text(
                              'Batal',
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
                    SizedBox(width: size16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          tambahKategoriForm(
                            context,
                            controllerName.text,
                            widget.token,
                          ).then((value) {
                            if (value == '00') {
                              showSnackBarComponent(
                                context,
                                'Berhasil tambah kategori',
                                '00',
                              );

                              errorText = '';
                              controllerName.text = '';
                            }
                          });

                          _getProductList();
                          refreshDataProduk();
                          getDataProduk(['']);

                          setState(() {});
                          initState();
                        },
                        child: buttonXL(
                          Center(
                            child: Text(
                              'Simpan',
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
          ),
        ),
      ),
    );
  }

  List? typeproductList;
  List<dynamic>? searchResultListProduct;

  dynamic selectedProduct;
  bool isItemSelected = false;

  String provinceInfoUrl = '$url/api/typeproduct';
  Future _getProductList() async {
    await Future.delayed(Duration(seconds: 2));
    await http
        .post(
          Uri.parse(provinceInfoUrl),
          body: {"deviceid": identifier},
          headers: {"token": widget.token},
        )
        .then((response) {
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
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
      selectedProduct = product;
      isItemSelected = true;
    });
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
                                SizedBox(height: 20),
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

  tambahGambar(BuildContext context) async {
    showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                            child: Image.file(myImage!, fit: BoxFit.cover),
                          ),
                        ),
                      )
                    : Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(120),
                          // border: Border.all(),
                        ),
                        child: Container(
                          height: 200,
                          width: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(120),
                            child: SvgPicture.asset('assets/logoProduct.svg'),
                          ),
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
                            prefixIcon: Icon(PhosphorIcons.plus, color: bnw900),
                            hintText: 'Tambah Foto',
                            hintStyle: heading3(
                              FontWeight.w400,
                              bnw900,
                              'Outfit',
                            ),
                          ),
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
                                style: heading3(
                                  FontWeight.w400,
                                  bnw900,
                                  'Outfit',
                                ),
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
