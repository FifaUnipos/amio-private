import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/produkToko/produkVariantPage.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/produkToko/ubahProductVariantPage.dart';
import 'package:unipos_app_335/services/provider.dart';

import '../../../../utils/component/component_showModalBottom.dart';
import 'dart:io' as Io;
import 'dart:io';
import '../../../../pagehelper/loginregis/daftar_akun_toko.dart';
import '../../../../utils/component/skeletons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../utils/component/component_orderBy.dart';
import '../../../../models/tokoModel/transaksiTokoModel.dart';
import 'package:provider/provider.dart';

import '../../../../main.dart';
import '../../../../models/produkmodel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../../services/modelBloc.dart';

import '../../../../utils/component/providerModel/refreshTampilanModel.dart';
import '../../../../utils/component/component_button.dart';
import 'ubahProdukToko.dart';
import '../../../../utils/component/component_color.dart';
import '../../../../utils/component/component_loading.dart';
import 'package:file_picker/file_picker.dart';

FocusNode textFieldFocusNode = FocusNode();

class ProdukToko extends StatefulWidget {
  String token;
  ProdukToko({Key? key, required this.token}) : super(key: key);

  @override
  State<ProdukToko> createState() => _ProdukTokoState();
}

class _ProdukTokoState extends State<ProdukToko> {
  List<ModelDataProduk>? datasProduk;

  PageController _pageController = PageController();
  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};
  List<String> listProduct = List.empty(growable: true);

  List<String>? productIdCheckAll;
  String checkFill = 'kosong';

  String textOrderBy = 'Nama Produk A ke Z';
  String textvalueOrderBy = 'upDownNama';

  TextEditingController conNameProduk = TextEditingController();
  TextEditingController conHarga = TextEditingController();
  TextEditingController conHargaOnline = TextEditingController();
  TextEditingController searchController = TextEditingController();

  late String nameKategoriEdit;
  TextEditingController controllerName = TextEditingController();
  late TextEditingController controllerNameEdit = TextEditingController();

  void formatInputRp() {
    String text = conHarga.text.replaceAll('.', '');

    int value = int.tryParse(text)!;

    String formattedAmount = formatCurrency(value);

    conHarga.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  void formatInputOnlineRp() {
    String text = conHargaOnline.text.replaceAll('.', '');

    int value = int.tryParse(text)!;

    String formattedAmount = formatCurrency(value);

    conHargaOnline.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  //edit page
  late TextEditingController conNameProdukEdit = TextEditingController(
    text: nameEditProduk,
  );
  late TextEditingController conHargaEdit = TextEditingController(
    text: hargaEditProduk,
  );
  late TextEditingController conHargaOnlineEdit = TextEditingController(
    text: hargaEditOnlineProduk,
  );

  late bool onswitchppnEdit = ppnEdit == '0' ? false : true;
  late bool onswitchtampikanEdit = tampilEdit == '0' ? false : true;
  late String ppnAktifEdit = ppnEdit == '0' ? "Tidak Aktif" : 'Aktif';
  late String kasirAktifEdit = tampilEdit == '0' ? "Tidak Aktif" : 'Aktif';

  bool isLoading = false;

  // late String nameKategoriEdit;
  // TextEditingController controllerName = TextEditingController();

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

  TextEditingController searchControllerEdit = TextEditingController();

  // late String jenisProduct = jenisProductEdit, idProduct = kodejenisProductEdit;

  void formatInputRpEdit() {
    String text = conHargaEdit.text.replaceAll('.', '');

    int value = int.tryParse(text)!; // Mengambil nilai angka dari teks

    String formattedAmount = formatCurrency(value);

    conHargaEdit.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  void formatInputOnlineRpEdit() {
    String text = conHargaOnlineEdit.text.replaceAll('.', '');

    int value = int.tryParse(text)!; // Mengambil nilai angka dari teks

    String formattedAmount = formatCurrency(value);

    conHargaOnlineEdit.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  String? fileName;
  String? filePath;
  bool isUploading = false;

  /// Fungsi untuk memilih file (tanpa upload)
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx', 'csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        fileName = file.name;
        filePath = file.path;

        // Update UI (pastikan widget kamu pakai setState)
        // Contoh:
        // setState(() {});
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> uploadFile(BuildContext context) async {
    if (filePath == null) {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      showSnackBarComponent(rootContext, '⚠️ Pilih file terlebih dahulu', '99');
      return;
    }

    try {
      if (!mounted) return;
      setState(() => isUploading = true);

      final uri = Uri.parse(uploadProdukUrl);
      final request = http.MultipartRequest('POST', uri);
      request.headers['token'] = widget.token;
      request.files.add(await http.MultipartFile.fromPath('file', filePath!));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);

      debugPrint("📥 Response JSON: $jsonData");

      if (!mounted) return;

      // ✅ Tutup modal sebelum tampilkan snackbar
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        showSnackbar(context, jsonData);
      }

      if (response.statusCode == 200 && jsonData['rc'] == '00') {
        if (mounted) {
          setState(() {
            fileName = null;
            filePath = null;
          });
        }
      }
    } catch (e) {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      showSnackBarComponent(rootContext, '❌ Error: $e', '99');
    } finally {
      if (!mounted) return;
      setState(() => isUploading = false);
    }
  }

  @override
  void initState() {
    checkConnection(context);
    _getProductList();
    img64 = null;
    // getSingleProduct(context, widget.token, "", singleProductId, setState);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      List<String> value = [''];

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

    conHarga.addListener(formatInputRp);
    conHargaOnline.addListener(formatInputOnlineRp);
    conHargaEdit.addListener(formatInputRpEdit);
    conHargaOnlineEdit.addListener(formatInputOnlineRpEdit);
    super.initState();
  }

  Future<dynamic> getDataProduk(List<String> value) async {
    return datasProduk = await getProduct(
      context,
      widget.token,
      '',
      value,
      textvalueOrderBy,
    );
  }

  getData() async {
    datasProduk = await getProduct(context, widget.token, '', [
      '',
    ], textvalueOrderBy);
  }

  refreshDataProduk() {
    setState(() {
      datasProduk;
      conHarga.text;
      idProduct = '';
      conNameProduk.text = '';
      conNameProdukEdit.text = '';

      onswitchppn = false;
      onswitchtampikan = true;

      conHarga.text = '';
      conHargaEdit.text = '';
      conHargaOnline.text = '';
      conHargaOnlineEdit.text = '';
      jenisProduct = '';
      jenisProductEdit = '';
      isSelectionMode = false;
      myImage = null;
      myImageEdit = null;
      listProduct = [];
      listProduct.clear();
      selectedFlag.clear();
      getData();
    });
  }

  autoReload() {
    setState(() {});
  }

  void getSingle(productid) {
    getSingleProduct(context, widget.token, "", productid, setState);
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
      // imageQuality: 50,
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

  Timer? _debounce;

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(seconds: 2), () async {
      datasProduk = await getProduct(context, widget.token, value, [
        '',
      ], textvalueOrderBy);
      setState(() {});
    });
  }

  @override
  dispose() {
    _debounce?.cancel();
    productPrice;
    _pageController.dispose();
    conNameProduk.dispose();
    conHarga.dispose();
    searchController.dispose();
    super.dispose();
  }

  late String jenisProduct = jenisProductEdit!,
      idProduct = kodejenisProductEdit!;

  bool onswitchppn = false;
  bool onswitchtampikan = true;
  String ppnAktif = "Tidak Aktif";
  String kasirAktif = "Aktif";

  // String? imageEdit, nameEdit, kategoriEdit, hargaEdit;

  String? singleProductId = '', singleImage = '';

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
      child: Scaffold(
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(size16),
            margin: EdgeInsets.all(size16),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.circular(size16),
            ),
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                pageProdukToko(isFalseAvailable),
                tambahProdukToko(),
                editProdukToko(),
                // tambahVariantToko(),
                ProductVariantPage(
                  token: widget.token,
                  pageController: _pageController,
                ),
                UbahProductVariantPage(
                  token: widget.token,
                  pageController: _pageController,
                ),
                // ubahProdukToko(setState, context, singleProductId),
                // UbahProdukToko(
                //   token: widget.token,
                //   productid: singleProductId!,
                //   image: singleImage!,
                //   pageController: _pageController,
                //   datasProduk: datasProduk,
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //! pembatas page
  tambahProdukToko() {
    return Consumer<RefreshTampilan>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    refreshDataProduk();

                    getDataProduk(['']);

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
            SizedBox(height: size16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Text(
                    'Logo Produk',
                    style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: 10),
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
                      SizedBox(width: 10),
                      Text(
                        'Masukkan logo atau foto yang menandakan identitas dari tokomu.',
                        style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                  GestureDetector(
                    // onTap: () => getImage(),
                    onTap: () {
                      tambahGambar(context);
                    },
                    child: SizedBox(
                      child: TextFormField(
                        cursorColor: primary500,
                        style: heading3(FontWeight.w600, bnw900, 'Outfit'),
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
                          hintStyle: heading2(
                            FontWeight.w600,
                            bnw900,
                            'Outfit',
                          ),
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
                  kategoriList(context),
                  SizedBox(height: size16),
                  fieldAddProduk(
                    'Harga',
                    'Rp. 12.000',
                    conHarga,
                    TextInputType.number,
                  ),
                  SizedBox(height: size16),
                  fieldAddProdukTanpaBintang(
                    'Harga Online',
                    'Rp. 14.000',
                    conHargaOnline,
                    TextInputType.number,
                  ),
                  SizedBox(height: size16),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      onswitchppn = !onswitchppn;
                      onswitchppn
                          ? ppnAktif = "Aktif"
                          : ppnAktif = "Tidak Aktif";
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
                          width: 52.0,
                          height: 28.0,
                          value: onswitchppn,
                          padding: 0,
                          activeIcon: Icon(
                            PhosphorIcons.check,
                            color: primary500,
                          ),
                          inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                          activeColor: primary500,
                          inactiveColor: bnw100,
                          borderRadius: 30.0,
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
                        FlutterSwitch(
                          width: 52.0,
                          height: 28.0,
                          value: onswitchtampikan,
                          padding: 0,
                          activeIcon: Icon(
                            PhosphorIcons.check,
                            color: primary500,
                          ),
                          inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                          activeColor: primary500,
                          inactiveColor: bnw100,
                          borderRadius: 30.0,
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
                  SizedBox(height: size16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: GestureDetector(
                      onTap: () {
                        List<String> value = [""];
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
                      List<String> value = [""];
                      // create hello world
                      createProduct(
                        context,
                        widget.token,
                        conNameProduk.text,
                        idProduct.toString(),
                        onswitchppn,
                        onswitchtampikan,
                        conHarga.text.replaceAll(RegExp(r'[^0-9]'), ''),
                        conHargaOnline.text.replaceAll(RegExp(r'[^0-9]'), ''),
                        img64.toString(),
                        value,
                        _pageController,
                      ).then((value) {
                        if (value == '00') {
                          // img64 = null;
                          refreshDataProduk();
                          setState(() {});
                          initState();
                        }
                      });
                      getDataProduk(['']);
                    },
                    child: buttonXLoutline(
                      Center(
                        child: Text(
                          'Simpan & Tambah Baru',
                          style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                      ),
                      0,
                      bnw900,
                    ),
                  ),
                ),
                SizedBox(width: size16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // print(idProduct);
                      List<String> value = [""];
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
                          _pageController.jumpToPage(0);
                          setState(() {});
                          initState();
                          getDataProduk(['']);
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
                      0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  editProdukToko() {
    // late bool onswitchppnEdit = ppnEdit == '0' ? false : true;
    // late bool onswitchtampikanEdit = tampilEdit == '0' ? false : true;
    // late String ppnAktifEdit = ppnEdit == '0' ? "Tidak Aktif" : 'Aktif';
    // late String kasirAktifEdit = tampilEdit == '0' ? "Tidak Aktif" : 'Aktif';

    // conNameProdukEdit.text = nameEditProduk ?? '';
    // conHargaEdit.text = hargaEditProduk ?? '';
    // conHargaOnlineEdit.text = hargaEditOnlineProduk ?? '';

    return Consumer<RefreshTampilan>(
      builder: (context, provider, _) => Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _pageController.jumpToPage(0);
                  refreshDataProduk();

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
                      onTap: () => tambahGambarEdit(context),
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
                        hintText: 'Ubah Gambar',
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
                SizedBox(height: size16),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: GestureDetector(
                    onTap: () async {
                      setState(() => isLoading = true);

                      var response = await getProductVariant(
                        context,
                        widget.token,
                        "", // order_by (if needed)
                        singleProductId!,
                      );

                      print('📦 ini response $response');

                      if (response != null &&
                          response['rc'] == '00' &&
                          response['data'] != null) {
                        Provider.of<ProductVariantProvider>(
                          context,
                          listen: false,
                        ).setProductData(response['data']);

                        _pageController.jumpToPage(4);
                      } else {
                        showSnackbar(
                          context,
                          "Failed to fetch or no data available",
                        );
                      }

                      setState(() => isLoading = false);
                    },
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : buttonXLoutline(
                            Center(
                              child: Text(
                                'Ubah Variant',
                                style: heading3(
                                  FontWeight.w600,
                                  bnw900,
                                  'Outfit',
                                ),
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

                // print(
                //     'harga online ${conHargaOnlineEdit.text}, harga ${conHargaEdit.text}');

                // print("test $jenisProductEdit $jenisProduct  $idProduct");

                updateProduk(
                  context,
                  widget.token,
                  conNameProdukEdit.text,
                  "",
                  singleProductId,
                  kodejenisProductEdit,
                  conHargaEdit.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  conHargaOnlineEdit.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  _pageController,
                  onswitchtampikanEdit.toString(),
                  onswitchppnEdit.toString(),
                  img64Edit.toString(),
                ).then((value) async {
                  if (value == '00') {
                    refreshDataProduk();
                    getDataProduk(['']);
                    conNameProdukEdit.text = '';
                    conHargaEdit.text = '';
                    conHargaOnlineEdit.text = '';
                    idProduct = '';
                    await Future.delayed(Duration(seconds: 1));
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

  pageProdukToko(bool isFalseAvailable) {
    List<String> value = [''];
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
                  'Produk',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  nameToko ?? '',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
            SizedBox(width: size12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: TextField(
                        cursorColor: primary500,
                        textAlignVertical: TextAlignVertical.center,
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
                            margin: EdgeInsets.only(
                              left: size20,
                              right: size12,
                            ),
                            child: Icon(
                              PhosphorIcons.magnifying_glass,
                              color: bnw900,
                              size: size20,
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
                                    size: size20,
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
                  ),
                  SizedBox(width: size16),
                  GestureDetector(
                    onTap: () {
                      showModalBottom(
                        context,
                        MediaQuery.of(context).size.height,
                        IntrinsicHeight(
                          child: StatefulBuilder(
                            builder: (context, setState) => Padding(
                              padding: EdgeInsets.all(size16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.file, color: bnw900),
                                      SizedBox(width: size12),
                                      Text(
                                        'Unggah Data Produk',
                                        style: heading2(
                                          FontWeight.w600,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size16),
                                  Text(
                                    'Unggah data produk Anda menggunakan format Excel (.xls, .xlsx) atau CSV. Ukuran file maksimum adalah 5MB.',
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                  SizedBox(height: size16),
                                  Text('Pilih file dari perangkat Anda:'),
                                  SizedBox(height: size12),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await pickFile();
                                          setState(
                                            () {},
                                          ); // supaya nama file muncul setelah dipilih
                                        },
                                        child: buttonL(
                                          Center(
                                            child: Text(
                                              'Pilih file',
                                              style: heading3(
                                                FontWeight.w600,
                                                bnw100,
                                                'Outfit',
                                              ),
                                            ),
                                          ),
                                          primary500,
                                          primary500,
                                        ),
                                      ),
                                      SizedBox(width: size12),
                                      Flexible(
                                        child: Text(
                                          fileName ??
                                              'Tidak ada file yang dipilih',
                                          overflow: TextOverflow.ellipsis,
                                          style: heading4(
                                            FontWeight.w400,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  SizedBox(width: size12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: buttonLoutline(
                                            Center(
                                              child: Text(
                                                'Batal',
                                                style: heading3(
                                                  FontWeight.w500,
                                                  primary500,
                                                  'Outfit',
                                                ),
                                              ),
                                            ),
                                            primary500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: isUploading
                                              ? null
                                              : () async {
                                                  await uploadFile(context);
                                                  setState(() {
                                                    print(
                                                      'isUploading: $isUploading',
                                                    );
                                                  }); // refresh tampilan
                                                },
                                          child: buttonL(
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  PhosphorIcons.file_arrow_up,
                                                  color: bnw100,
                                                ),
                                                SizedBox(width: size8),
                                                Text(
                                                  isUploading
                                                      ? 'Mengunggah...'
                                                      : 'Upload',
                                                  style: heading3(
                                                    FontWeight.w500,
                                                    bnw100,
                                                    'Outfit',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            primary500,
                                            primary500,
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
                    child: buttonXL(
                      Row(
                        children: [
                          Icon(PhosphorIcons.file_arrow_up, color: bnw100),
                        ],
                      ),
                      0,
                    ),
                  ),
                  SizedBox(width: size16),
                  GestureDetector(
                    onTap: () {
                      refreshDataProduk();
                      _pageController.jumpToPage(1);
                    },
                    child: buttonXL(
                      Row(
                        children: [
                          Icon(PhosphorIcons.plus, color: bnw100),
                          SizedBox(width: size16),
                          Text(
                            'Produk',
                            style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ],
                      ),
                      0,
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
                    topLeft: Radius.circular(size16),
                    topRight: Radius.circular(size16),
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
                              maxWidth: MediaQuery.of(context).size.width / 18,
                              minWidth: MediaQuery.of(context).size.width / 18,
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
                                  MediaQuery.of(context).size.width / size12,
                              minWidth:
                                  MediaQuery.of(context).size.width / size12,
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
                            style: heading4(FontWeight.w600, bnw100, 'Outfit'),
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
                                                "",
                                              ).then((value) async {
                                                if (value == '00') {
                                                  refreshDataProduk();
                                                  await Future.delayed(
                                                    Duration(seconds: 1),
                                                  );
                                                  conNameProduk.text = '';
                                                  conHarga.text = '';
                                                  idProduct = '';
                                                  _pageController.jumpToPage(0);
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
                                              MediaQuery.of(context).size.width,
                                              primary500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: size12),
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
                            child: buttonL(
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(PhosphorIcons.trash_fill, color: bnw900),
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
                                "",
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
                              ;
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
                                "",
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
                              ;
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
                            bottomLeft: Radius.circular(size12),
                            bottomRight: Radius.circular(size12),
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
                              ModelDataProduk data = datasProduk![index];
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
                                                datasProduk![index].discount ==
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
                                                datasProduk![index].discount ==
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
                                              // print('hello');
                                              List<String> listProduct = [
                                                dataProduk.productid!,
                                              ];
                                              changePpn(
                                                context,
                                                widget.token,
                                                value.toString(),
                                                listProduct,
                                                '',
                                              ).then((value) {
                                                if (value != '00') {
                                                  dataProduk.isPPN = 0;
                                                } else {
                                                  dataProduk.isPPN = 1;
                                                }
                                                setState(() {});
                                                initState();
                                              });
                                              ;
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
                                                size12,
                                            minWidth:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width /
                                                size12,
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
                                                '',
                                              ).then((value) {
                                                if (value != '00') {
                                                  dataProduk.isActive = 0;
                                                } else {
                                                  dataProduk.isActive = 1;
                                                }
                                                setState(() {});
                                                initState();
                                              });
                                              ;
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
                                                                  color: bnw900,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: size20,
                                                          ),
                                                          GestureDetector(
                                                            behavior:
                                                                HitTestBehavior
                                                                    .translucent,
                                                            onTap: () async {
                                                              singleProductId =
                                                                  dataProduk
                                                                      .productid;

                                                              productIdVariant =
                                                                  dataProduk
                                                                      .productid!;
                                                              singleImage =
                                                                  dataProduk
                                                                      .productImage;

                                                              print(
                                                                singleProductId,
                                                              );
                                                              // getSingle(dataProduk
                                                              //     .productid);
                                                              getSingleProduct(
                                                                context,
                                                                widget.token,
                                                                '',
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
                                                                      nameEditProduk ??
                                                                      '';
                                                                  conHargaEdit
                                                                          .text =
                                                                      hargaEditProduk ??
                                                                      '';
                                                                  conHargaOnlineEdit
                                                                          .text =
                                                                      hargaEditOnlineProduk ??
                                                                      '';

                                                                  dynamic
                                                                  selectableProduct = {
                                                                    'kodeproduct':
                                                                        kodejenisProductEdit,
                                                                    'jenisproduct':
                                                                        jenisProductEdit,
                                                                    'created_by':
                                                                        'null',
                                                                    'created_at':
                                                                        'null',
                                                                    'updated_at':
                                                                        'null',
                                                                    'deleted_at':
                                                                        'null',
                                                                  };

                                                                  _selectProduct(
                                                                    selectableProduct,
                                                                  );

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

                                                                  onswitchtampikan =
                                                                      dataProduk
                                                                              .isActive ==
                                                                          1
                                                                      ? true
                                                                      : false;

                                                                  onswitchppn =
                                                                      dataProduk
                                                                              .isPPN ==
                                                                          1
                                                                      ? true
                                                                      : false;

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
                                                                    "", // order_by (if needed)
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
                                                                                "",
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
                                                                              size12,
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
                                                            child:
                                                                modalBottomValue(
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
    );
  }

  //! pembatas widget

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
                            hintText: 'Ubah Foto',
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
          IntrinsicHeight(
            child: TextFormField(
              cursorColor: primary500,
              keyboardType: numberNo,
              style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              controller: mycontroller,
              onChanged: (value) {
                // String formattedValue = formatCurrency(value);
                // conHarga.value = TextEditingValue(
                //   text: formattedValue,
                //   selection:
                //       TextSelection.collapsed(offset: formattedValue.length),
                // );
              },
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color: primary500),
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: size12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1.5, color: bnw500),
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

  fieldAddProdukTanpaBintang(
    title,
    hint,
    mycontroller,
    TextInputType numberNo,
  ) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: body1(FontWeight.w500, bnw900, 'Outfit')),
            ],
          ),
          IntrinsicHeight(
            child: TextFormField(
              cursorColor: primary500,
              keyboardType: numberNo,
              style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              controller: mycontroller,
              onChanged: (value) {
                // String formattedValue = formatCurrency(value);
                // conHarga.value = TextEditingValue(
                //   text: formattedValue,
                //   selection:
                //       TextSelection.collapsed(offset: formattedValue.length),
                // );
              },
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color: primary500),
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: size12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1.5, color: bnw500),
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

  fieldEditProduk(title, mycontroller, TextInputType numberNo) {
    return Container(
      margin: EdgeInsets.only(top: 10),
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

  Widget _buildSelectIcon(bool isSelected, ModelDataProduk data) {
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
          kategoriListForm(context, isKeyboardActive);
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

  Future<dynamic> kategoriListForm(
    BuildContext context,
    bool isKeyboardActive,
  ) {
    setState(() {});
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) => FractionallySizedBox(
            heightFactor: isKeyboardActive ? 0.9 : 0.80,
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
                    topRight: Radius.circular(size12),
                    topLeft: Radius.circular(size12),
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
                                borderSide: BorderSide(
                                  width: 2,
                                  color: primary500,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(size8),
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
                                        size: size20,
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
                            _getProductList();
                            setState(() {});
                            initState();
                          },
                          child: ListView(
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
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount: searchResultListProduct?.length,
                                itemBuilder: (context, index) {
                                  final product =
                                      searchResultListProduct?[index];
                                  final isSelected = product == selectedProduct;

                                  return Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: bnw300,
                                              width: width1,
                                            ),
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: size16,
                                          ),
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
                                                : PhosphorIcons.radio_button,
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

                                              kodejenisProductEdit =
                                                  product['kodeproduct'];

                                              _selectProduct(product);

                                              print(product['jenisproduct']);
                                            });
                                          },
                                          onLongPress: () {
                                            Navigator.pop(context);
                                            nameKategoriEdit =
                                                product['jenisproduct'];
                                            controllerNameEdit.text =
                                                product['jenisproduct'];
                                            ubahHapusKategori(product);
                                          },
                                        ),
                                      ),
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
  }

  ubahHapusKategori(product) {
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
                            topRight: Radius.circular(size12),
                            topLeft: Radius.circular(size12),
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
                                        kategoriListForm(context, false);
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
                                            Navigator.pop(context);
                                            kategoriListForm(context, false);
                                            showSnackBarComponent(
                                              context,
                                              'Berhasil ubah kategori',
                                              '00',
                                            );
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
                                  whenLoading(context);
                                  setState(() {
                                    hapusKategoriForm(
                                      context,
                                      widget.token,
                                      product['kodeproduct'],
                                    ).then((value) {
                                      if (value == '00') {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        kategoriListForm(context, false);
                                        showSnackBarComponent(
                                          context,
                                          'Berhasil hapus kategori',
                                          '00',
                                        );
                                      }
                                    });
                                  });
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

  Future<dynamic> tambahKategori(BuildContext context, bool isKeyboardActive) {
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
              topRight: Radius.circular(size12),
              topLeft: Radius.circular(size12),
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
                          kategoriListForm(context, isKeyboardActive);
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
                          Navigator.pop(context);
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

                              // Future.delayed(Duration(seconds: 1))
                              //     .then((value) {
                              //   autoReload();
                              //   kategoriListForm(context, isKeyboardActive);
                              // });

                              errorText = '';
                              controllerName.text = '';
                            }
                          });
                          // _getProductList();
                          // refreshDataProduk();
                          // getDataProduk(['']);
                          // setState(() {});
                          // initState();
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
    await http
        .post(
          Uri.parse(provinceInfoUrl),
          body: {"deviceid": identifier},
          headers: {"token": widget.token},
        )
        .then((response) {
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            // log("data product $data");
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
      log("ini product $product");
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
                                SizedBox(height: size20),
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
}

modalBottomValue(String title, icon) {
  return Column(
    children: [
      Row(
        children: [
          Icon(icon, color: bnw900),
          SizedBox(width: 10),
          Text(title, style: heading3(FontWeight.w400, bnw900, 'Outfit')),
        ],
      ),
      Divider(color: bnw300),
    ],
  );
}
