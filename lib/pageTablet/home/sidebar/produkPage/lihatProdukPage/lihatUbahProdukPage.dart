import 'dart:convert';
import 'dart:developer';import '../../../../../utils/component/component_showModalBottom.dart';

import 'dart:io';
import 'dart:io' as Io;
import 'dart:typed_data';
import '../../../../../utils/component/component_loading.dart';
import '../../../../../utils/component/component_orderBy.dart';
import '../../../../../utils/component/skeletons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../main.dart';
import '../../../../../pagehelper/loginregis/daftar_akun_toko.dart';
import '../../../../../services/apimethod.dart';
import '../../../../../services/checkConnection.dart';

import '../../../../../utils/component/component_button.dart';
import '../../../../../utils/component/component_color.dart';
import '../../../../../utils/component/providerModel/refreshTampilanModel.dart';
import '../../../../tokopage/sidebar/produkToko/produk.dart';


class LihatProdukUbahPage extends StatefulWidget {
  String token, productid, merchId;
  PageController pageController;
  LihatProdukUbahPage({
    Key? key,
    required this.token,
    required this.productid,
    required this.merchId,
    required this.pageController,
  }) : super(key: key);

  @override
  State<LihatProdukUbahPage> createState() => _LihatProdukUbahPageState();
}

class _LihatProdukUbahPageState extends State<LihatProdukUbahPage> {
  late TextEditingController conNameProdukEdit =
      TextEditingController(text: nameEditProduk);
  late TextEditingController conHargaEdit =
      TextEditingController(text: hargaEditProduk);

  late TextEditingController conHargaOnlineEdit =
      TextEditingController(text: hargaEditOnlineProduk);

  late String nameKategoriEdit;
  TextEditingController controllerName = TextEditingController();
  late TextEditingController controllerNameEdit =
      TextEditingController(text: nameKategoriEdit);

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
        imageEdit = '';
      });
      // Clipboard.setData(ClipboardData(text: img64));
    } else {
      print('Error Image');
    }
  }

  TextEditingController searchController = TextEditingController();

  late String jenisProduct = jenisProductEdit!, idProduct = kodejenisProductEdit!;

  late bool onswitchppn = ppnEdit == '0' ? false : true;
  late bool onswitchtampikan = tampilEdit == '0' ? false : true;
  late String ppnAktif = ppnEdit == '0' ? "Tidak Aktif" : 'Aktif';
  late String kasirAktif = tampilEdit == '0' ? "Tidak Aktif" : 'Aktif';

  void formatInputRp() {
    String text = conHargaEdit.text.replaceAll('.', '');

    int value = int.tryParse(text)!; // Mengambil nilai angka dari teks

    String formattedAmount = formatCurrency(value);

    conHargaEdit.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  void formatInputOnlineRp() {
    String text = conHargaOnlineEdit.text.replaceAll('.', '');

    int value = int.tryParse(text)!; // Mengambil nilai angka dari teks

    String formattedAmount = formatCurrency(value);

    conHargaOnlineEdit.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  @override
  void initState() {
    checkConnection(context);
    getSingleProduct(context, widget.token, "", widget.productid, setState);
    _getProductList();
    conHargaEdit.addListener(formatInputRp);
    conHargaOnlineEdit.addListener(formatInputOnlineRp);
    super.initState();
  }

  void autoReload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefreshTampilan>(
      builder: (context, provider, _) => Column(
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
              )
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
                        child: myImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(size8),
                                child: Image.file(
                                  myImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : imageEdit!.isEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(size8),
                                    child: Image.network(
                                      imageEdit!,
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
                                    borderRadius: BorderRadius.circular(size8),
                                    child: Image.network(
                                      imageEdit!,
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
                fieldEditProduk(
                  'Harga',
                  conHargaEdit,
                  TextInputType.number,
                ),
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
                      onswitchppn = !onswitchppn;
                      onswitchppn
                          ? ppnAktif = "Aktif"
                          : ppnAktif = "Tidak Aktif";
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
                            ppnAktif,
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                      FlutterSwitch(
                        width: 52,
                        height: 28,
                        // value: snapshot.data['isActive'] == 1 ? true : false,
                        value: onswitchppn,
                        padding: 0,
                        activeIcon:
                            Icon(PhosphorIcons.check, color: primary500),
                        inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                        activeColor: primary500,
                        inactiveColor: bnw100,
                        borderRadius: 30,
                        inactiveToggleColor: bnw900,
                        activeToggleColor: primary200,
                        activeSwitchBorder: Border.all(color: primary500),
                        inactiveSwitchBorder:
                            Border.all(color: bnw300, width: 2),
                        onToggle: (val) {
                          setState(
                            () {
                              onswitchppn = val;
                              onswitchppn
                                  ? ppnAktif = "Aktif"
                                  : ppnAktif = "Tidak Aktif";
                              log(onswitchppn.toString());
                              log(ppnAktif);
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
                    setState(
                      () {
                        onswitchtampikan = !onswitchtampikan;
                        onswitchtampikan
                            ? kasirAktif = "Aktif"
                            : kasirAktif = "Tidak Aktif";
                      },
                    );
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
                            kasirAktif,
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                      FlutterSwitch(
                        width: 52,
                        height: 28,
                        // value: snapshot.data['isPPN'] == 1 ? true : false,

                        value: onswitchtampikan,
                        padding: 0,
                        activeIcon:
                            Icon(PhosphorIcons.check, color: primary500),
                        inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                        activeColor: primary500,
                        inactiveColor: bnw100,
                        borderRadius: 30,
                        inactiveToggleColor: bnw900,
                        activeToggleColor: primary200,
                        activeSwitchBorder: Border.all(color: primary500),
                        inactiveSwitchBorder:
                            Border.all(color: bnw300, width: 2),
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
          SizedBox(height: size16),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onTap: () {
                // print(idProduct);
                // print(singleProductId);
                if (img64 == 'hapus') {
                  img64 = null;
                } else if (imageEdit!.isNotEmpty) {
                  img64 = '';
                } else {
                  img64 = img64;
                }

                List<String> value = [""];
                updateProduk(
                  context,
                  widget.token,
                  conNameProdukEdit.text,
                  widget.merchId,
                  widget.productid,
                  idProduct,
                  conHargaEdit.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  conHargaOnlineEdit.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  widget.pageController,
                  onswitchtampikan.toString(),
                  onswitchppn.toString(),
                  img64.toString(),
                ).then((value) async {
                  if (value == '00') {
                    await getProductGrup(
                      context,
                      widget.token,
                      '',
                      widget.merchId,
                      textvalueOrderBy,
                    );
                    setState(() {});
                  }
                });
                // print(img64.toString());
                // Provider.of<RefreshTampilan>(context, listen: false)
                //     .getDataProduk(widget.datasProduk!, context, widget.token);
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
    );
  }

  fieldEditProduk(title, mycontroller, TextInputType numberNo) {
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
    );
  }

  fieldEditProdukTanpaBintang(title, mycontroller, TextInputType numberNo) {
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
    );
  }

  kategoriList(BuildContext context) {
    bool isKeyboardActive = false;

    return GestureDetector(
      onTap: () {
        setState(
          () {
            // log(jenisProduct.toString());
            kategoriListForm(context, isKeyboardActive);
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
                      style: heading2(FontWeight.w600,
                          jenisProductEdit == '' ? bnw500 : bnw900, 'Outfit'),
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

  Future<dynamic> kategoriListForm(
      BuildContext context, bool isKeyboardActive) {
    return showModalBottomSheet(
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
          builder: (BuildContext context, setState) => FractionallySizedBox(
            heightFactor: isKeyboardActive ? 0.9 : 0.80,
            child: GestureDetector(
              onTap: () => textFieldFocusNode.unfocus(),
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
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
                                    FontWeight.w500, bnw500, 'Outfit')),
                          ),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {});
                            initState();
                          },
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              SizedBox(height: size16),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  tambahKategori(context, isKeyboardActive);
                                  _getProductList();
                                },
                                child: buttonXLoutline(
                                    Center(
                                        child: Text(
                                      'Tambah Kategori',
                                      style: heading2(FontWeight.w600,
                                          primary500, 'Outfit'),
                                    )),
                                    double.infinity,
                                    primary500),
                              ),
                              SizedBox(height: size16),
                              ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: BouncingScrollPhysics(),
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount: searchResultListProduct?.length,
                                itemBuilder: (context, index) {
                                  final product =
                                      searchResultListProduct?[index];
                                  final isSelected = product == selectedProduct;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          product['jenisproduct'] != null
                                              ? capitalizeEachWord(
                                                  product['jenisproduct']
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
                                            jenisProductEdit =
                                                product['jenisproduct'];

                                            jenisProduct =
                                                product['jenisproduct'];

                                            idProduct = product['kodeproduct'];

                                            _selectTypeProduct(product);

                                            print(product['jenisproduct']);
                                          });
                                        },
                                        onLongPress: () {
                                          Navigator.pop(context);
                                          nameKategoriEdit =
                                              product['jenisproduct'];
                                          ubahHapusKategori(product, setState);
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
                          autoReload();
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
            ),
          ),
        );
      },
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
                            bottom: MediaQuery.of(context).viewInsets.bottom),
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
                              size32, size16, size32, size32),
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
                                        FontWeight.w700, bnw900, 'Outfit'),
                                  ),
                                  SizedBox(height: size16),
                                  Row(
                                    children: [
                                      Text(
                                        'Kategori ',
                                        style: heading4(
                                            FontWeight.w400, bnw900, 'Outfit'),
                                      ),
                                      Text(
                                        '*',
                                        style: heading4(FontWeight.w400,
                                            danger500, 'Outfit'),
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
                                          )),
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
                                        kategoriListForm(context, false);
                                      },
                                      child: buttonXLoutline(
                                        Center(
                                          child: Text(
                                            'Batal',
                                            style: heading3(FontWeight.w600,
                                                primary500, 'Outfit'),
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
                                          controllerName.text,
                                        ).then((value) {
                                          if (value == '00') {
                                            kategoriListForm(context, false);
                                            Navigator.pop(context);
                                            showSnackBarComponent(context,
                                                'Berhasil ubah kategori', '00');
                                            errorText = '';
                                            controllerName.text = '';
                                          }
                                        });
                                        _getProductList();
                                        setState(() {});
                                        initState();
                                      },
                                      child: buttonXL(
                                        Center(
                                          child: Text(
                                            'Simpan',
                                            style: heading3(FontWeight.w600,
                                                bnw100, 'Outfit'),
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
                              style:
                                  heading1(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                            SizedBox(height: size16),
                            Text(
                              'Data kategori yang sudah dihapus tidak dapat dikembalikan lagi.',
                              style:
                                  heading2(FontWeight.w400, bnw900, 'Outfit'),
                            ),
                            SizedBox(height: size16),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  hapusKategoriForm(context, widget.token,
                                          product['kodeproduct'])
                                      .then((value) {
                                    if (value == '00') {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      kategoriListForm(context, false);
                                      showSnackBarComponent(context,
                                          'Berhasil hapus kategori', '00');
                                    }
                                  });

                                  initState();
                                  setState(() {});
                                },
                                child: buttonXLoutline(
                                  Center(
                                    child: Text(
                                      'Iya, Hapus',
                                      style: heading3(FontWeight.w600,
                                          primary500, 'Outfit'),
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
                                  kategoriListForm(context, false);
                                },
                                child: buttonXL(
                                  Center(
                                    child: Text(
                                      'Batalkan',
                                      style: heading3(
                                          FontWeight.w600, bnw100, 'Outfit'),
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
                child: modalBottomValue(
                  'Hapus Kategori',
                  PhosphorIcons.trash,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> tambahKategori(BuildContext context, bool isKeyboardActive) {
    return showModalBottomSheet(
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
                          style: heading2(
                            FontWeight.w600,
                            bnw900,
                            'Outfit',
                          ),
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
                              )),
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
                          kategoriListForm(context, isKeyboardActive);
                        },
                        child: buttonXLoutline(
                          Center(
                            child: Text(
                              'Batal',
                              style: heading3(
                                  FontWeight.w600, primary500, 'Outfit'),
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
                          tambahKategoriForm(
                                  context, controllerName.text, widget.token)
                              .then((value) {
                            if (value == '00') {
                              kategoriListForm(context, isKeyboardActive);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              showSnackBarComponent(
                                  context, 'Berhasil tambah kategori', '00');
                              errorText = '';
                              controllerName.text = '';
                            }
                          });
                          _getProductList();
                          setState(() {});
                          initState();
                        },
                        child: buttonXL(
                          Center(
                            child: Text(
                              'Simpan',
                              style:
                                  heading3(FontWeight.w600, bnw100, 'Outfit'),
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
                    (myImage != null || imageEdit != '')
                        ? GestureDetector(
                            onTap: () async {
                              img64 = 'hapus';
                              myImage = null;
                              imageEdit = '';
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

  List<dynamic>? typeproductList;
  List<dynamic>? searchResultListProduct;
  bool isItemSelected = false;

  dynamic selectedProduct;

  String provinceInfoUrl = '$url/api/typeproduct';
  Future _getProductList() async {
    await http.post(Uri.parse(provinceInfoUrl), body: {
      "deviceid": identifier,
    }, headers: {
      "token": widget.token,
    }).then((response) {
      final data = json.decode(response.body);
      if (data != null && data['data'] != null) {
        setState(() {
          typeproductList = List<dynamic>.from(data['data']);
          searchResultListProduct = typeproductList;
        });
      }
    });
  }

  void _runSearchProduct(String searchText) {
    setState(() {
      searchResultListProduct = typeproductList
          ?.where((tipeUsaha) => tipeUsaha
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void _selectTypeProduct(dynamic tipeUsaha) {
    setState(() {
      selectedProduct = tipeUsaha;
      isItemSelected = true;
    });
  }
}
