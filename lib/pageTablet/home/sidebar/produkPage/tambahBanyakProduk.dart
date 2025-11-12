import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';import '../../../../utils/component/component_showModalBottom.dart';
import 'dart:io';
import 'dart:io' as Io;
import 'dart:typed_data';

import '../../../../utils/component/skeletons.dart';
import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import 'package:unipos_app_335/utils/component/component_snackbar.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../main.dart';
import '../../../../utils/component/component_loading.dart';
import '../../../../models/tokomodel.dart';
import '../../../../pagehelper/loginregis/daftar_akun_toko.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';

import '../../../tokopage/sidebar/produkToko/produk.dart';
import '../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';

class TambahBanyakProdukPagPage extends StatefulWidget {
  PageController pageController;
  String token;
  TambahBanyakProdukPagPage({
    Key? key,
    required this.pageController,
    required this.token,
  }) : super(key: key);

  @override
  State<TambahBanyakProdukPagPage> createState() =>
      _TambahBanyakProdukPagPageState();
}

class _TambahBanyakProdukPagPageState extends State<TambahBanyakProdukPagPage> {
  PageController _pageController = PageController();
  List<ModelDataToko>? datas;
  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};
  List<String> listToko = List.empty(growable: true);

  TextEditingController conNameProduk = TextEditingController();
  TextEditingController conHarga = TextEditingController();
  TextEditingController conHargaOnline = TextEditingController();

  late String nameKategoriEdit;
  TextEditingController controllerName = TextEditingController();
  late TextEditingController controllerNameEdit =
      TextEditingController(text: nameKategoriEdit);

  TextEditingController searchController = TextEditingController();

  late String jenisProduct = jenisProductEdit!,
      idProduct = kodejenisProductEdit!;

  bool onswitchppn = false;
  bool onswitchtampikan = true;
  String ppnAktif = "Tidak Aktif";
  String kasirAktif = "Aktif";

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

  void formatInputRp() {
    String text = conHarga.text.replaceAll('.', '');

    int value = int.tryParse(text)!; // Mengambil nilai angka dari teks

    String formattedAmount = formatCurrency(value);

    conHarga.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  void formatInputOnlineRp() {
    String text = conHargaOnline.text.replaceAll('.', '');

    int value = int.tryParse(text)!; // Mengambil nilai angka dari teks

    String formattedAmount = formatCurrency(value);

    conHargaOnline.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  refreshDataProduk() {
    conNameProduk.text = '';
    idProduct = '';
    conHarga.text = '';
    img64 = null;
    listToko.clear();
  }

  @override
  void initState() {
    checkConnection(context);
    conHarga.addListener(formatInputRp);
    conHargaOnline.addListener(formatInputOnlineRp);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      datas = await getAllToko(context, widget.token, '', '');

      _pageController = PageController(
        initialPage: 0,
        keepPage: true,
        viewportFraction: 1,
      );
      _getProductList();

      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isFalseAvailable = selectedFlag.containsValue(false);
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
          mainPage(isFalseAvailable),
          addAllProduct(context),
        ],
      ),
    );
  }

  mainPage(bool isFalseAvailable) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                print('helo');
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
                  'Pilih Toko',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Penambah produk yang sama ke lebih dari 1 toko',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            )
          ],
        ),
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
                child: Row(
                  children: [
                    SizedBox(
                      // width: 200,
                      child: FutureBuilder(
                          future: getAllToko(context, widget.token, '', ''),
                          builder: (context, snapshot) {
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // _selectAll(listToko);
                                  },
                                  child: SizedBox(
                                    width: 50,
                                    // child: Icon(
                                    //   isFalseAvailable
                                    //       ? PhosphorIcons.square
                                    //       : PhosphorIcons.check_square_fill,
                                    //   color: bnw100,
                                    // ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    'Foto Toko',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    'Nama Toko',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    'Alamat',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              ),
              datas == null
                  ? SkeletonCardLine()
                  : Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary100,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(size12),
                            bottomRight: Radius.circular(size12),
                          ),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: datas!.length,
                          itemBuilder: (builder, index) {
                            ModelDataToko data = datas![index];
                            selectedFlag[index] = selectedFlag[index] ?? false;
                            bool? isSelected = selectedFlag[index];

                            return Column(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    // valueMerchid.add(data.merchantid);
                                    // log(data.name.toString());
                                    setState(() {
                                      onTap(isSelected, index, data.merchantid);
                                      print(listToko);
                                    });

                                    // print(dataProduk.productid);
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        child:
                                            _buildSelectIcon(isSelected!, data),
                                      ),
                                      SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(1000),
                                          child: datas![index]
                                                      .logomerchant_url !=
                                                  null
                                              ? Image.network(
                                                  datas![index]
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
                                                    ),
                                                  ),
                                                )
                                              : Icon(
                                                  PhosphorIcons.storefront_fill,
                                                  size: 60,
                                                ),
                                        ),
                                      ),
                                      SizedBox(width: size32),
                                      SizedBox(
                                        width: 140,
                                        child:
                                            Text(datas![index].name.toString()),
                                      ),
                                      SizedBox(
                                        width: 400,
                                        child: Text(
                                            datas![index].address.toString()),
                                      ),
                                      SizedBox(width: 25),
                                    ],
                                  ),
                                ),
                                Divider(thickness: 1.2)
                              ],
                            );
                          },
                          // itemCount: staticData!.length,
                        ),
                      ),
                    ),
              SizedBox(height: size16),
              GestureDetector(
                onTap: () {
                  isSelectionMode
                      ? _pageController.nextPage(
                          duration: Duration(milliseconds: 10),
                          curve: Curves.easeIn)
                      : null;
                },
                child: buttonXLonOff(
                  Center(
                      child: Text(
                    'Selanjutnya',
                    style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                  )),
                  double.infinity,
                  isSelectionMode == true ? primary500 : bnw300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  addAllProduct(BuildContext context) {
    return Column(
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
            SizedBox(width: size12),
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
            )
          ],
        ),
        Expanded(
          child: ListView(
            // padding: EdgeInsets.zero,
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                  height: 48,
                  width: double.infinity,
                  margin: EdgeInsets.only(top: size12, bottom: size12),
                  padding: EdgeInsets.fromLTRB(size12, size12, size12, size12),
                  decoration: BoxDecoration(
                    color: succes100,
                    borderRadius: BorderRadius.circular(size8),
                    border: Border.all(
                      color: succes600,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.storefront, color: succes600),
                      Text(
                        "  ${listToko.length} Toko Terpilih",
                        style: heading4(FontWeight.w600, succes600, 'Outfit'),
                      )
                    ],
                  )),
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
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(size8),
                              child: Image.file(
                                myImage!,
                                fit: BoxFit.cover,
                              ),
                            )
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
              fieldAddProduk(
                'Nama Produk',
                'Matcha Latte Cappuchino',
                // 'conNameProduk',
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
                  onswitchppn = !onswitchppn;
                  onswitchppn ? ppnAktif = "Aktif" : ppnAktif = "Tidak Aktif";
                  setState(() {});
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
                      value: onswitchppn,
                      padding: 0,
                      activeIcon: Icon(PhosphorIcons.check, color: primary500),
                      inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                      activeColor: primary500,
                      inactiveColor: bnw100,
                      borderRadius: 30,
                      inactiveToggleColor: bnw900,
                      activeToggleColor: primary200,
                      activeSwitchBorder: Border.all(color: primary500),
                      inactiveSwitchBorder: Border.all(color: bnw300, width: 2),
                      onToggle: (val) {
                        setState(
                          () {
                            onswitchppn = val;
                            onswitchppn
                                ? ppnAktif = "Aktif"
                                : ppnAktif = "Tidak Aktif";
                            print(onswitchppn.toString());
                            print(ppnAktif);
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
                  onswitchtampikan = !onswitchtampikan;
                  onswitchtampikan
                      ? kasirAktif = "Aktif"
                      : kasirAktif = "Tidak Aktif";

                  setState(() {});
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
                      value: onswitchtampikan,
                      padding: 0,
                      activeIcon: Icon(PhosphorIcons.check, color: primary500),
                      inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                      activeColor: primary500,
                      inactiveColor: bnw100,
                      borderRadius: 30,
                      inactiveToggleColor: bnw900,
                      activeToggleColor: primary200,
                      activeSwitchBorder: Border.all(color: primary500),
                      inactiveSwitchBorder: Border.all(color: bnw300, width: 2),
                      onToggle: (val) {
                        onswitchtampikan = val;
                        onswitchtampikan
                            ? kasirAktif = "Aktif"
                            : kasirAktif = "Tidak Aktif";
                        print(onswitchtampikan.toString());
                        print(kasirAktif);
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
                  createProduct(
                    context,
                    widget.token,
                    conNameProduk.text,
                    // '0001',
                    idProduct,
                    onswitchppn.toString(),
                    onswitchtampikan.toString(),
                    conHarga.text.replaceAll(RegExp(r'[^0-9]'), ''),
                    conHargaOnline.text.replaceAll(RegExp(r'[^0-9]'), ''),
                    img64.toString(),
                    listToko,
                    widget.pageController,
                  ).then((value) {
                    if (value == '00') {
                      // widget.pageController.jumpToPage(0);
                      refreshDataProduk();
                    }
                  });
                  // refreshDataProduk();
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
            SizedBox(width: size12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // print(idProduct);
                  // List<String> value = [widget.merchId];
                  createProduct(
                    context,
                    widget.token,
                    conNameProduk.text,
                    // '0001',
                    idProduct,
                    onswitchppn.toString(),
                    onswitchtampikan.toString(),
                    conHarga.text.replaceAll(RegExp(r'[^0-9]'), ''),
                    conHargaOnline.text.replaceAll(RegExp(r'[^0-9]'), ''),
                    img64.toString(),
                    listToko,
                    widget.pageController,
                  ).then((value) {
                    if (value == '00') {
                      widget.pageController.jumpToPage(0);
                      refreshDataProduk();
                    }
                  });
                  // initState();
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
        )
      ],
    );
  }

  void onTap(bool isSelected, int index, merchId) {
    if (index >= 0 && index < selectedFlag.length) {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);

      if (selectedFlag[index] == true) {
        // Periksa apakah productId sudah ada di dalam listProduct sebelum menambahkannya
        if (!listToko.contains(merchId)) {
          listToko.add(merchId);
        }
      } else {
        // Hapus productId dari listProduct jika sudah ada
        listToko.remove(merchId);
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

  Widget _buildSelectIcon(bool isSelected, ModelDataToko data) {
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

  void _selectAll(merchId) {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    // If false will be available then it will select all the checkbox
    // If there will be no false then it will de-select all
    selectedFlag.updateAll((key, value) => isFalseAvailable);
    setState(() {
      isSelectionMode = selectedFlag.containsValue(true);
      if (isFalseAvailable == true) {
        listToko.add(merchId);
      } else {
        listToko.remove(merchId);
      }
    });
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
          IntrinsicHeight(
            child: TextFormField(
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

  kategoriList(BuildContext context) {
    bool isKeyboardActive = false;

    return GestureDetector(
      onTap: () {
        setState(
          () {
            // log(jenisProduct.toString());
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
                                    initState();
                                  },
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    children: [
                                      SizedBox(height: size16),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          tambahKategori(context,
                                              isKeyboardActive, setState);
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
                                                  product['jenisproduct'] !=
                                                          null
                                                      ? capitalizeEachWord(
                                                          product['jenisproduct']
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
                                                    jenisProductEdit =
                                                        product['jenisproduct'];

                                                    jenisProduct =
                                                        product['jenisproduct'];

                                                    idProduct =
                                                        product['kodeproduct'];

                                                    _selectProduct(product);

                                                    print(product[
                                                        'jenisproduct']);
                                                  });
                                                },
                                                onLongPress: () {
                                                  Navigator.pop(context);
                                                  nameKategoriEdit =
                                                      product['jenisproduct'];
                                                  ubahHapusKategori(
                                                      product, setState);
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
                                          controllerNameEdit.text,
                                        ).then((value) {
                                          if (value == '00') {
                                            showSnackBarComponent(context,
                                                'Berhasil ubah kategori', '00');
                                            errorText = '';
                                            controllerNameEdit.text = '';
                                          }
                                        });
                                        _getProductList();
                                        refreshDataProduk();
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
                                      product['kodeproduct']);

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

  Future<dynamic> tambahKategori(
      BuildContext context, bool isKeyboardActive, StateSetter setState) {
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
                              // Navigator.pop(context);
                              showSnackBarComponent(
                                  context, 'Berhasil tambah kategori', '00');
                              errorText = '';
                              controllerName.text = '';
                            }
                          });
                          _getProductList();
                          refreshDataProduk();
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

  List? typeproductList;
  List<dynamic>? searchResultListProduct;

  dynamic selectedProduct;
  bool isItemSelected = false;

  String provinceInfoUrl = '$url/api/typeproduct';
  Future _getProductList() async {
    await http.post(Uri.parse(provinceInfoUrl), body: {
      "deviceid": identifier,
    }, headers: {
      "token": widget.token,
    }).then((response) {
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
          ?.where((product) => product
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void _selectProduct(dynamic product) {
    setState(() {
      selectedProduct = product;
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(120),
                          // border: Border.all(),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(120),
                            child: Icon(PhosphorIcons.plus_fill)),
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
