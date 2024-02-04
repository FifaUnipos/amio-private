// ignore_for_file: unrelated_type_equality_checks, unnecessary_new
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' as Io;
import 'dart:io';
import 'dart:typed_data';

import 'package:amio/pageTablet/tokopage/sidebar/produkToko/produk.dart';
import 'package:amio/pagehelper/loginregis/daftar_akun_toko.dart';
import 'package:amio/utils/providerModel/refreshTampilanModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:amio/models/keranjangModel.dart';
import 'package:amio/models/tokoModel/transaksiTokoModel.dart';
import 'package:amio/pageTablet/tokopage/sidebar/transaksiToko/riwayatPageToko.dart';
import 'package:amio/utils/printer/printerPage.dart';
import 'package:amio/utils/skeletons.dart';
import 'package:provider/provider.dart';

import '../../../../main.dart';
import '../../../../models/tokoModel/riwayatTransaksiTokoModel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../../utils/component.dart';
import 'classKeypad.dart';
import 'classMetode.dart';
import 'pesananPage.dart';
import 'pilihPelangganFifaKoinPage.dart';
import 'pilihPelangganPage.dart';

List<CartTransaksi> cart = List.empty(growable: true);
List<Map<String, String>> cartMap = List.empty(growable: true);
List<num> total = List.empty(growable: true);
List<TextEditingController> conCatatan = List.empty(growable: true);
List<String> cartProductIds = [];

num sumTotal = 0;
String? logoStruk = '', logoStrukPrinter = '';
String? logoQris = '';

class TransactionPage extends StatefulWidget {
  String token;
  TransactionPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with TickerProviderStateMixin {
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

  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};
  List<String> listToko = List.empty(growable: true);

  TabController? _tabController;
  List<ProductModel>? datasTransaksi;
  List<CoinModel>? coinTransaksi;

  TextEditingController customProdukName = TextEditingController();
  TextEditingController customProdukPrice = TextEditingController();

  TextEditingController searchController = TextEditingController();

  PageController _pageController = PageController();
  PageController dompetDigitalPageCon = PageController();
  PageController _pageMetodeSwap = PageController();
  PageController pageControllerPayment = PageController();

  TextEditingController uangTunaiController =
      TextEditingController(text: 'Rp 0');

  TextEditingController pinController = TextEditingController();
  TextEditingController kreditpinController = TextEditingController();
  TextEditingController debitpinController = TextEditingController();

  TextEditingController conCatatanPreview = TextEditingController();
  TextEditingController conCounterPreview = TextEditingController();

  List<String> valueCoin = [''];
  List<String> inputValues = List.empty(growable: true);

  bool isItemAdded = false;
  // Set<String> cartProductIds = Set();
  num counterCart = 1;
  bool isExpand = false;
  int tapTrue = 0;

  String? discountId, discountIdFix;

  void formatInput() {
    String text = kreditpinController.text.replaceAll('-', '');
    String text2 = debitpinController.text.replaceAll('-', '');
    text = _addDashes(text);
    text2 = _addDashes(text2);
    kreditpinController.value = kreditpinController.value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    debitpinController.value = kreditpinController.value.copyWith(
      text: text2,
      selection: TextSelection.collapsed(offset: text2.length),
    );
  }

  String _addDashes(String value) {
    String separator = '-';
    final List<String> chunks = [];
    int i = 0;
    while (i < value.length) {
      if (i + 4 <= value.length) {
        chunks.add(value.substring(i, i + 4));
        i += 4;
      } else {
        chunks.add(value.substring(i));
        break;
      }
    }
    return chunks.join(separator);
  }

  void formatInputRp() {
    String text = uangTunaiController.text.replaceAll('.', '');

    int value = int.tryParse(text) ?? 0; // Mengambil nilai angka dari teks

    String formattedAmount = formatCurrency(value);

    uangTunaiController.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  void formatInputRpCustomProduk() {
    String text = customProdukPrice.text.replaceAll('.', '');

    int value = int.tryParse(text) ?? 0; // Mengambil nilai angka dari teks

    String formattedAmount = formatCurrency(value);

    customProdukPrice.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  String textOrderBy = 'Nama Produk A ke Z';
  String textvalueOrderBy = 'tanggalTerkini';

  @override
  void initState() {
    checkConnection(context);
    _getProductList();
    getQris(context, widget.token, '');
    getStruk(context, widget.token, '');

    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        List<String> value = [''];

        datasTransaksi = await getProductTransaksi(
          context,
          widget.token,
          '',
          value,
          textvalueOrderBy,
        );

        getDataCoin('');

        setState(() {
          print(datasTransaksi.toString());
          subTotal;
          ppnTransaksi;
          totalTransaksi;
          customerTransaksi;
          datasTransaksi;
          coinTransaksi;
          pelangganName;
          pelangganId;
          transactionidValue;
        });

        _pageController = PageController(
          // initialPage: 2,
          initialPage: 0,
          keepPage: true,
          viewportFraction: 1,
        );
        pageControllerPayment = PageController(
          initialPage: 0,
          keepPage: true,
          viewportFraction: 1,
        );
        dompetDigitalPageCon = PageController(
          initialPage: 0,
          keepPage: true,
          viewportFraction: 1,
        );
        _pageMetodeSwap = PageController(
          initialPage: 0,
          keepPage: true,
          viewportFraction: 1,
        );
      },
    );

    kreditpinController.addListener(formatInput);
    debitpinController.addListener(formatInput);
    uangTunaiController.addListener(formatInputRp);
    customProdukPrice.addListener(formatInputRpCustomProduk);

    super.initState();
  }

  Future<dynamic> getDataCoin(name) async {
    return coinTransaksi = await getCoinTransaksi(
      context,
      widget.token,
      name,
      [''],
    );
  }

  @override
  dispose() {
    sumTotal;
    productPrice;
    pinController.dispose();
    kreditpinController.dispose();
    debitpinController.dispose();
    _pageController.dispose();
    pageControllerPayment.dispose();
    _pageMetodeSwap.dispose();
    dompetDigitalPageCon.dispose();
    super.dispose();
  }

  Color hasItemColor = bnw300;
  List selectedIndexTransaksi = [];
  refreshColor() {
    cartMap.isEmpty ? hasItemColor = bnw300 : hasItemColor = primary500;
    cart.isEmpty ? hasItemColor = bnw300 : hasItemColor = primary500;
    setState(() {});
  }

  refreshTampilan() {
    final value = context.read<RefreshTampilan>();

    cart.clear();
    cartMap.clear();
    conCatatan.clear();
    _pageController.jumpTo(0);
    isItemAdded = false;
    total = [];
    subTotal = 0;
    sumTotal = 0;
    pelangganName = '';
    pelangganId = '';
    value.namaPelanggan = '';
    value.idPelanggan = '';
    namaCustomerCalculate = '';
    conCatatan.clear();
    conCounterPreview.clear();

    refreshColor();
    cartProductIds.clear();
  }

  Map<String, dynamic>? detailPesanan;

  Future createTransactionBayar(
    BuildContext context,
    token,
    value,
    List<Map<String, String>> details,
    PageController pageController,
    List<CartTransaksi> cart,
    setState,
    method,
    reference,
    transactionid,
    memberid,
    dialog,
    discount,
  ) async {
    showDialog(
      barrierDismissible: true,
      useRootNavigator: true,
      context: context,
      builder: (context) => Center(
        child: SizedBox(
          width: size48,
          height: size48,
          child: CircularProgressIndicator(),
        ),
      ),
    );

    final String detail = json.encode(details);

    final response = await http.post(
      Uri.parse(createTransaksiUrl),
      headers: {
        "token": "$token",
      },
      body: {
        "deviceid": identifier,
        "discount": discount ?? "",
        "memberid": memberid,
        "transactionid": transactionid,
        "value": value,
        "payment_method": method,
        "payment_reference": reference,
        "detail": detail,
      },
    );
    var jsonResponse = json.decode(response.body);

    // var data = jsonResponse;
    // var data = jsonResponse['data'];

    if (response.statusCode == 200) {
      var kembalian =
          int.parse(uangTunaiController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      var tunaiText = int.parse(pinController.text);

      setState(() {
        print(jsonResponse['data']['raw']);
        print(jsonResponse['data']);
        printext = jsonResponse['data']['raw'];

        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context, rootNavigator: true).pop();
          showDialog(
            // barrierDismissible: false,
            useRootNavigator: false,
            context: context,
            builder: (context) => WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.8,
                  height: MediaQuery.of(context).size.height,
                  margin: EdgeInsets.symmetric(vertical: size32),
                  padding: EdgeInsets.all(size16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size16),
                    color: bnw100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Transaksi Berhasil',
                          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(height: size16),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          physics: BouncingScrollPhysics(),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                pesananStruk(
                                    'Kasir', jsonResponse['data']['pic'] ?? ''),
                                SizedBox(height: size16),
                                dash(),
                                SizedBox(height: size16),
                                Text(
                                  'Informasi Transaksi',
                                  style: heading3(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                ),
                                SizedBox(height: size4),
                                pesananStruk('Nama Pembeli',
                                    jsonResponse['data']['customerName'] ?? ''),
                                SizedBox(height: size4),
                                pesananStruk('Waktu Transaksi',
                                    jsonResponse['data']['entrydate'] ?? ''),
                                SizedBox(height: size4),
                                pesananStruk(
                                    'Nomor Transaksi',
                                    jsonResponse['data']['transactionid'] ??
                                        ''),
                                SizedBox(height: size16),
                                dash(),
                              ],
                            ),
                            SizedBox(height: size16),
                            Text(
                              'Rincian Produk',
                              style:
                                  heading3(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                            SizedBox(height: size8),
                            SizedBox(
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: cart.length,
                                itemBuilder: (context, i) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: size8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cart[i].name.toString(),
                                          style: heading4(
                                            FontWeight.w400,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        SizedBox(height: size4),
                                        SizedBox(
                                          child: Row(
                                            children: [
                                              Text(
                                                '${cart[i].quantity}x',
                                                style: heading4(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              SizedBox(width: size24),
                                              Text(
                                                FormatCurrency.convertToIdr(
                                                        cart[i].price!)
                                                    .toString(),
                                                style: heading4(
                                                  FontWeight.w400,
                                                  bnw500,
                                                  'Outfit',
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                FormatCurrency.convertToIdr(
                                                  cart[i].price! *
                                                      cart[i].quantity,
                                                ),
                                                style: heading4(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: size8),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${cart[i].quantity}x',
                                              style: heading4(
                                                FontWeight.w400,
                                                Colors.transparent,
                                                'Outfit',
                                              ),
                                            ),
                                            SizedBox(width: size24),
                                            Text(
                                              'Catatan : ${cart[i].desc}',
                                              style: heading4(
                                                FontWeight.w400,
                                                bnw900,
                                                'Outfit',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: size16),
                            dash(),
                            SizedBox(height: size16),
                            Text(
                              'Rincian Pembayaran',
                              style:
                                  heading3(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                            SizedBox(height: size16),
                            pesananStruk(
                                'Sub Total',
                                FormatCurrency.convertToIdr(subTotal)
                                    .toString()),
                            SizedBox(height: size16),
                            pesananStruk(
                                'Diskon',
                                FormatCurrency.convertToIdr(
                                        jsonResponse['data']['discount'])
                                    .toString()),
                            SizedBox(height: size16),
                            pesananStruk(
                                'PPN',
                                FormatCurrency.convertToIdr(ppnTransaksi)
                                    .toString()),
                            SizedBox(height: size16),
                            dash(),
                            SizedBox(height: size16),
                            kembalianStruk(
                              'Total',
                              FormatCurrency.convertToIdr(
                                int.parse(
                                  jsonResponse['data']['amount'].toString(),
                                ),
                              ),
                            ),
                            SizedBox(height: size16),
                            pesananStruk(
                              jsonResponse['data']['payment_name'],
                              FormatCurrency.convertToIdr(
                                int.parse(
                                  jsonResponse['data']['money_paid'].toString(),
                                ),
                              ),
                            ),
                            SizedBox(height: size16),
                            jsonResponse['data']['payment_name'] == 'Cash'
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Kembalian',
                                        style: heading4(FontWeight.w400,
                                            primary500, 'Outfit'),
                                      ),
                                      Text(
                                        FormatCurrency.convertToIdr(int.parse(
                                                jsonResponse['data']
                                                    ['change_money']))
                                            .toString(),
                                        style: heading4(FontWeight.w400,
                                            primary500, 'Outfit'),
                                      ),
                                    ],
                                  )
                                : SizedBox()
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: size16),
                          SizedBox(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(size8),
                              child: Material(
                                child: ButtonPrint(
                                  bluetooth: bluetooth,
                                  printtext: printext,
                                  widgetku: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: size16),
                                      Text(
                                        'Cetak Struk',
                                        style: heading3(
                                            FontWeight.w600, bnw100, 'Outfit'),
                                      ),
                                      SizedBox(width: size12),
                                      Icon(PhosphorIcons.printer_fill,
                                          color: bnw100),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size16),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                log(printext.toString());
                                cart.clear();
                                cartMap.clear();
                                _pageController.jumpTo(0);

                                int newtotal = 0;
                                for (var element in cartMap) {
                                  var myelement = int.parse(element['amount']!);

                                  newtotal = newtotal + myelement;
                                }

                                sumTotal = newtotal;
                                total = [];
                                subTotal = 0;
                                sumTotal = 0;
                                transactionidValue = "";
                                printext = '';
                                pelangganName = '';
                                pelangganId = '';
                                namaCustomerCalculate = '';
                                uangTunaiController.text = '0';
                                isItemAdded = false;
                                isExpand = false;
                                conCatatan.clear();

                                selectedIndex = 0;
                                selectedIndexDompetDigital = 0;
                                refreshTampilan();
                                refreshColor();
                                Navigator.pop(context);
                                setState(() {});
                              },
                              child: buttonXLoutline(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Kembali Ke Kasir',
                                      style: heading3(FontWeight.w600,
                                          primary500, 'Outfit'),
                                    ),
                                    SizedBox(width: size12),
                                    Icon(PhosphorIcons.notebook_fill,
                                        color: primary500),
                                  ],
                                ),
                                double.infinity,
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
        });

        // cart.clear();
      });
    } else {
      log(jsonResponse.toString());
      Navigator.of(context, rootNavigator: true).pop();
      showSnackbar(context, jsonResponse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
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
            children: [
              getAllProduct(context, _pageController),
              pembayaranPage(context),
              RiwayatPage(
                token: widget.token,
                pageController: _pageController,
                tabController: _tabController!,
                bluetooth: bluetooth,
              ),
              pengaturanPage(context),
              SimpanPage(
                bluetooth: bluetooth,
                token: widget.token,
                pageController: _pageController,
              ),
              PilihPelangganToko(
                token: widget.token,
                pageController: _pageController,
                pageMetodeSwap: pageControllerPayment,
                selectedIndex: selectedIndex,
              ),
              PilihPelangganTokoFifaKoin(
                token: widget.token,
                pageController: _pageController,
                pageMetodeSwap: pageControllerPayment,
                selectedIndex: selectedIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding pengaturanPage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(size16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaksi',
            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
          ),
          Text(
            nameToko ?? '',
            style: heading3(FontWeight.w300, bnw900, 'Outfit'),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TabBar(
              controller: _tabController,
              automaticIndicatorColorAdjustment: false,
              indicatorColor: primary500,
              labelColor: primary500,
              labelStyle: heading2(FontWeight.w400, bnw900, 'Outfit'),
              unselectedLabelColor: bnw600,
              physics: NeverScrollableScrollPhysics(),
              onTap: (value) {
                if (value == 0) {
                  _pageController.animateToPage(
                    0,
                    duration: Duration(milliseconds: 10),
                    curve: Curves.ease,
                  );
                } else if (value == 1) {
                  _pageController.animateToPage(
                    2,
                    duration: Duration(milliseconds: 10),
                    curve: Curves.ease,
                  );
                } else if (value == 2) {
                  _pageController.animateToPage(
                    3,
                    duration: Duration(milliseconds: 10),
                    curve: Curves.ease,
                  );
                }
                setState(() {});
              },
              tabs: [
                Tab(
                  text: 'Kasir',
                ),
                Tab(
                  text: 'Riwayat',
                ),
                Tab(
                  text: 'Pengaturan',
                ),
              ],
            ),
          ),
          SizedBox(height: size16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(size16),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: bnw300),
                      borderRadius: BorderRadius.circular(size16),
                      color: bnw100,
                    ),
                    child: Column(children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(size12),
                          height: double.infinity,
                          width: double.infinity,
                          child: Image.asset(
                            'assets/qrislogo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pembayaran QRIS',
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          Text(
                            logoQris != '' ? 'Terhubung' : 'Belum Terhubung',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: size16),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                getQris(context, widget.token, '')
                                    .then((value) {
                                  showBottomPilihan(
                                    context,
                                    Center(
                                      // child: myImage != null
                                      child:
                                          // logoQris.isNotEmpty
                                          //     ? Image.network(
                                          //         logoQris,
                                          //         fit: BoxFit.fill,
                                          //       )
                                          //     :
                                          Column(
                                        children: [
                                          Text(
                                            'Pembayaran QRIS',
                                            style: heading1(FontWeight.w600,
                                                bnw900, 'Outfit'),
                                          ),
                                          SizedBox(height: size16),
                                          Container(
                                            height: 260,
                                            width: 260,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(size8),
                                              border: Border.all(color: bnw300),
                                            ),
                                            child: logoQris == ''
                                                ? Icon(PhosphorIcons.plus)
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size8),
                                                    child: Image.network(
                                                      logoQris ?? '',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              await getImage().then(
                                                (value) => uploadQris(
                                                  context,
                                                  widget.token,
                                                  img64,
                                                  '',
                                                ).then(
                                                  (value) {
                                                    // Navigator.pop(context);
                                                  },
                                                ),
                                              );
                                              setState(() {});
                                              // initState();
                                            },
                                            child: SizedBox(
                                              child: TextFormField(
                                                enabled: false,
                                                style: heading3(FontWeight.w400,
                                                    bnw900, 'Outfit'),
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: size16),
                                                    isDense: true,
                                                    focusColor: primary500,
                                                    prefixIcon: Icon(
                                                      size: size24,
                                                      logoQris != ''
                                                          ? PhosphorIcons
                                                              .pencil_line
                                                          : PhosphorIcons.plus,
                                                      color: bnw900,
                                                    ),
                                                    hintText: logoQris != ''
                                                        ? 'Ganti QRIS'
                                                        : 'Tambah QRIS',
                                                    hintStyle: heading3(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit')),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: size16),
                                          logoQris != ''
                                              ? GestureDetector(
                                                  onTap: () async {
                                                    deleteQris(
                                                      context,
                                                      widget.token,
                                                      '',
                                                    );
                                                    setState(() {});
                                                    // initState();
                                                  },
                                                  child: SizedBox(
                                                    child: TextFormField(
                                                      enabled: false,
                                                      style: heading3(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                      decoration:
                                                          InputDecoration(
                                                              focusColor:
                                                                  primary500,
                                                              prefixIcon: Icon(
                                                                PhosphorIcons
                                                                    .trash,
                                                                size: size24,
                                                                color: bnw900,
                                                              ),
                                                              hintText:
                                                                  'Hapus QRIS',
                                                              hintStyle:
                                                                  heading3(
                                                                      FontWeight
                                                                          .w400,
                                                                      bnw900,
                                                                      'Outfit')),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                });
                              },
                              child: logoQris == ''
                                  ? buttonXL(
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(PhosphorIcons.pencil_line,
                                              color: bnw100, size: size24),
                                          SizedBox(width: size12),
                                          Text(
                                            'Tambah QRIS',
                                            style: heading3(FontWeight.w600,
                                                bnw100, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      0,
                                    )
                                  : buttonXLoutline(
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(PhosphorIcons.pencil_line,
                                              color: primary500, size: size24),
                                          SizedBox(width: size12),
                                          Text(
                                            'Atur QRIS',
                                            style: heading3(FontWeight.w600,
                                                primary500, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      0,
                                      primary500,
                                    ),
                            ),
                          ),
                        ],
                      )
                    ]),
                  ),
                ),
                SizedBox(width: size12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(size16),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: bnw300),
                      borderRadius: BorderRadius.circular(size16),
                      color: bnw100,
                    ),
                    child: Column(children: [
                      Expanded(
                        child: Container(
                            padding: EdgeInsets.all(size12),
                            height: double.infinity,
                            width: double.infinity,
                            child: SvgPicture.asset('assets/logoStruk.svg')
                            // Image.asset(
                            //   'assets/fifapaylogolong.png',
                            //   fit: BoxFit.contain,
                            // ),
                            ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logo Pada Struk',
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          Text(
                            logoStruk == '' ? 'Belum Terhubung' : 'Terhubung',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: size16),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                getStruk(context, widget.token, '')
                                    .then((value) {
                                  value == '00'
                                      ? showBottomPilihan(
                                          context,
                                          Column(
                                            children: [
                                              Text(
                                                'Logo Struk',
                                                style: heading1(FontWeight.w600,
                                                    bnw900, 'Outfit'),
                                              ),
                                              SizedBox(height: size16),
                                              Container(
                                                height: 260,
                                                width: 260,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size8),
                                                  border:
                                                      Border.all(color: bnw300),
                                                ),
                                                child: logoStruk == ''
                                                    ? Icon(PhosphorIcons.plus)
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    size8),
                                                        child: Image.network(
                                                          logoStruk ?? '',
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                              ),
                                              SizedBox(height: size16),
                                              GestureDetector(
                                                onTap: () async {
                                                  await getImage().then(
                                                      (value) => uploadStruk(
                                                            context,
                                                            widget.token,
                                                            img64,
                                                            '',
                                                          ));
                                                  setState(() {});
                                                  // initState();
                                                },
                                                child: SizedBox(
                                                  child: TextFormField(
                                                    enabled: false,
                                                    style: heading3(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit'),
                                                    decoration: InputDecoration(
                                                        focusColor: primary500,
                                                        prefixIcon: Icon(
                                                          logoStruk != ''
                                                              ? PhosphorIcons
                                                                  .pencil
                                                              : PhosphorIcons
                                                                  .plus,
                                                          color: bnw900,
                                                        ),
                                                        hintText: logoStruk !=
                                                                ''
                                                            ? 'Ganti Struk'
                                                            : 'Tambah Struk',
                                                        hintStyle: heading3(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit')),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: size16),
                                              logoStruk != ''
                                                  ? GestureDetector(
                                                      onTap: () async {
                                                        deleteStruk(
                                                          context,
                                                          widget.token,
                                                          '',
                                                        );
                                                        setState(() {});
                                                        initState();
                                                      },
                                                      child: SizedBox(
                                                        child: TextFormField(
                                                          enabled: false,
                                                          style: heading3(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                          decoration:
                                                              InputDecoration(
                                                                  focusColor:
                                                                      primary500,
                                                                  prefixIcon:
                                                                      Icon(
                                                                    PhosphorIcons
                                                                        .trash,
                                                                    color:
                                                                        bnw900,
                                                                  ),
                                                                  hintText:
                                                                      'Hapus Struk',
                                                                  hintStyle: heading3(
                                                                      FontWeight
                                                                          .w400,
                                                                      bnw900,
                                                                      'Outfit')),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                            ],
                                          ),
                                        )
                                      : null;
                                });
                                setState(() {});
                              },
                              child: logoStruk == ''
                                  ? buttonXL(
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(PhosphorIcons.pencil_line,
                                              color: bnw100, size: size24),
                                          SizedBox(width: size12),
                                          Text(
                                            'Tambah Struk',
                                            style: heading3(FontWeight.w600,
                                                bnw100, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      0,
                                    )
                                  : buttonXLoutline(
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                              logoStruk == ''
                                                  ? PhosphorIcons.plus
                                                  : PhosphorIcons.pencil_line,
                                              color: primary500,
                                              size: size24),
                                          SizedBox(width: size12),
                                          Text(
                                            'Atur Struk',
                                            style: heading3(FontWeight.w600,
                                                primary500, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      0,
                                      primary500,
                                    ),
                            ),
                          ),
                        ],
                      )
                    ]),
                  ),
                ),

                // Container(
                //   padding:  EdgeInsets.all(size16),
                //   height: MediaQuery.of(context).size.height,
                //   width: MediaQuery.of(context).size.width / 2.6,
                //   decoration: BoxDecoration(
                //     border: Border.all(color: bnw300),
                //     borderRadius: BorderRadius.circular(size16),
                //     color: bnw100,
                //   ),
                //   child: Column(children: [
                //     Expanded(
                //       child: Container(
                //         padding:  EdgeInsets.all(size12),
                //         height: double.infinity,
                //         width: double.infinity,
                //         child: Image.asset(
                //           'assets/fifapaylogolong.png',
                //           fit: BoxFit.contain,
                //         ),
                //       ),
                //     ),
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(
                //           'Fifapay',
                //           style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                //         ),
                //         Text(
                //           'Belum Terhubung',
                //           style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                //         ),
                //          SizedBox(height: 18),
                //         buttonXLoutline(
                //             Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Icon(PhosphorIcons.plus, color: primary500),
                //                  SizedBox(width: size12),
                //                 Text(
                //                   'Hubungkan Fifapay',
                //                   style: heading3(
                //                       FontWeight.w600, primary500, 'Outfit'),
                //                 ),
                //               ],
                //             ),
                //             double.infinity,
                //             primary500)
                //       ],
                //     )
                //   ]),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<MyObject> objects = [
    MyObject('Tunai', 'Bayar dengan uang fisik', PhosphorIcons.wallet_fill),
    MyObject('Dompet Digital', 'Pindai kode batang (QR Code) untuk membayar',
        PhosphorIcons.qr_code_fill),
    MyObject('Kartu Kredit', 'Masukkan Kartu Kredit',
        PhosphorIcons.credit_card_fill),
    MyObject(
        'Kartu Debit', 'Masukkan Kartu Debit', PhosphorIcons.cardholder_fill),
    MyObject(
        'Fifapay Koin', 'Pilih daftar pelanggan', PhosphorIcons.coins_fill),
  ];

  int selectedIndex = 0;
  int selectedIndexDompetDigital = 0;
  pembayaranPage(BuildContext context) {
    bool? displayCode;

    return StatefulBuilder(
      builder: (context, setState) => Container(
        // padding: EdgeInsets.all(size16),
        child: Row(
          children: [
            Flexible(
              flex: 3,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(vertical: size16, horizontal: size16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (isTagihan == true) {
                              isTagihan = false;
                              cart.clear();
                              cartMap.clear();

                              isItemAdded = false;

                              total = [];
                              subTotal = 0;
                              sumTotal = 0;

                              refreshColor();
                              cartProductIds.clear();
                              conCatatan.clear();
                              conCounterPreview.clear();
                            }

                            _pageController.previousPage(
                                duration: Duration(microseconds: 1),
                                curve: Curves.ease);

                            selectedIndex = 0;
                            selectedIndexDompetDigital = 0;
                            uangTunaiController.text = '0';
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
                            Text('Pembayaran',
                                style: heading1(
                                    FontWeight.w700, bnw900, 'Outfit')),
                            Text('Papan Informasi Toko',
                                style: heading3(
                                    FontWeight.w300, bnw900, 'Outfit')),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: size8, bottom: size8),
                      child: Text(
                        'Rincian Pesanan',
                        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        // height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: BouncingScrollPhysics(),
                          itemCount: cart.length,
                          itemBuilder: (context, i) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: width1,
                                    color: bnw300,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(vertical: size8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        Text(
                                          'x${cart[i].quantity}',
                                          style: heading3(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        SizedBox(width: size8),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(size8),
                                          child: Image.network(
                                            cart[i].image.toString(),
                                            fit: BoxFit.cover,
                                            height: size48,
                                            width: size48,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }

                                              return Center(child: loading());
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    SizedBox(
                                              // height: 227,
                                              // width: 227,
                                              child: SvgPicture.asset(
                                                  'assets/logoProduct.svg'),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: size8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cart[i].name.toString(),
                                              style: heading3(
                                                FontWeight.w600,
                                                bnw900,
                                                'Outfit',
                                              ),
                                            ),
                                            Text(
                                              FormatCurrency.convertToIdr(
                                                  cart[i].price),
                                              style: heading3(
                                                FontWeight.w500,
                                                bnw900,
                                                'Outfit',
                                              ),
                                            ),
                                            Text(
                                              'Catatan : ${cart[i].desc}',
                                              style: heading3(
                                                FontWeight.w500,
                                                bnw900,
                                                'Outfit',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: size12),
                    Divider(
                      thickness: 1,
                      color: bnw900,
                    ),
                    SizedBox(height: size16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Diskon',
                          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        Text(
                          FormatCurrency.convertToIdr(discountProduct),
                          style: heading2(FontWeight.w600, succes600, 'Outfit'),
                        ),
                      ],
                    ),
                    SizedBox(height: size16),
                    GestureDetector(
                      onTap: () {
                        bool isKeyboardActive = false;
                        showModalBottomSheet(
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          context: context,
                          builder: (context) {
                            return FractionallySizedBox(
                              heightFactor: isKeyboardActive ? 0.9 : 0.80,
                              child: GestureDetector(
                                onTap: () => textFieldFocusNode.unfocus(),
                                child: Container(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
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
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Pilih Diskon',
                                            style: heading1(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
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
                                                      EdgeInsets.symmetric(
                                                          vertical: size12),
                                                  isDense: true,
                                                  filled: true,
                                                  fillColor: bnw200,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size8),
                                                    borderSide: BorderSide(
                                                      color: bnw300,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size8),
                                                    borderSide: BorderSide(
                                                      width: 2,
                                                      color: primary500,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size8),
                                                    borderSide: BorderSide(
                                                      color: bnw300,
                                                    ),
                                                  ),
                                                  suffixIcon: searchController
                                                          .text.isNotEmpty
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            searchController
                                                                .text = '';
                                                            _runSearchProduct(
                                                                '');
                                                            setState(() {});
                                                          },
                                                          child: Icon(
                                                            PhosphorIcons
                                                                .x_fill,
                                                            size: 20,
                                                            color: bnw900,
                                                          ),
                                                        )
                                                      : null,
                                                  prefixIcon: Icon(
                                                    PhosphorIcons
                                                        .magnifying_glass,
                                                    color: bnw500,
                                                  ),
                                                  hintText: 'Cari',
                                                  hintStyle: heading3(
                                                      FontWeight.w500,
                                                      bnw500,
                                                      'Outfit')),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: RefreshIndicator(
                                            onRefresh: () async {
                                              initState();
                                            },
                                            child: ListView(
                                              children: [
                                                SizedBox(height: size16),
                                                Text(
                                                  'Tersedia',
                                                  style: heading3(
                                                      FontWeight.w400,
                                                      bnw600,
                                                      'Outfit'),
                                                ),
                                                SizedBox(height: size16),
                                                StatefulBuilder(
                                                  builder:
                                                      (context, setState) =>
                                                          ListView.builder(
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    keyboardDismissBehavior:
                                                        ScrollViewKeyboardDismissBehavior
                                                            .onDrag,
                                                    itemCount:
                                                        searchResultListProduct
                                                            ?.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final product =
                                                          searchResultListProduct?[
                                                              index];
                                                      final isSelected =
                                                          product ==
                                                              selectedProduct;

                                                      return GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            textFieldFocusNode
                                                                .unfocus();

                                                            _selectProduct(
                                                                product);

                                                            print(
                                                                product['id']);

                                                            discountId =
                                                                product['id'];
                                                            setState(() {});
                                                          });
                                                        },
                                                        child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        size8),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    size16),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isSelected
                                                                  ? primary100
                                                                  : bnw100,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          size16),
                                                              border:
                                                                  Border.all(
                                                                color: isSelected
                                                                    ? primary500
                                                                    : bnw300,
                                                              ),
                                                            ),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      PhosphorIcons
                                                                          .tag_fill,
                                                                      color:
                                                                          primary500,
                                                                      size:
                                                                          size48,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          product['name'] != null
                                                                              ? capitalizeEachWord(product['name'].toString())
                                                                              : '',
                                                                          style: heading3(
                                                                              FontWeight.w400,
                                                                              bnw900,
                                                                              'Outfit'),
                                                                        ),
                                                                        Text(
                                                                          FormatCurrency.convertToIdr(product['discount'] ??
                                                                              0),
                                                                          style: heading4(
                                                                              FontWeight.w600,
                                                                              bnw900,
                                                                              'Outfit'),
                                                                        )
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        size16),
                                                                Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            size8,
                                                                        horizontal:
                                                                            size12),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color:
                                                                          bnw200,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              size16),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color:
                                                                            bnw300,
                                                                      ),
                                                                    ),
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Icon(
                                                                          PhosphorIcons
                                                                              .clock_fill,
                                                                          color:
                                                                              bnw600,
                                                                          size:
                                                                              size16,
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                size8),
                                                                        Text(
                                                                            product[
                                                                                'date'],
                                                                            style: body3(
                                                                                FontWeight.w400,
                                                                                bnw600,
                                                                                'Outfit')),
                                                                      ],
                                                                    ))
                                                              ],
                                                            )
                                                            // ListTile(
                                                            //   contentPadding:
                                                            //       EdgeInsets
                                                            //           .symmetric(
                                                            //               vertical:
                                                            //                   size16),
                                                            //   title: Text(
                                                            //     product['name'] !=
                                                            //             null
                                                            //         ? capitalizeEachWord(
                                                            //             product['name']
                                                            //                 .toString())
                                                            //         : '',
                                                            //   ),
                                                            //   trailing: Icon(
                                                            //     isSelected
                                                            //         ? PhosphorIcons
                                                            //             .radio_button_fill
                                                            //         : PhosphorIcons
                                                            //             .radio_button,
                                                            //     color: isSelected
                                                            //         ? primary500
                                                            //         : bnw900,
                                                            //   ),
                                                            //   onTap: () {
                                                            //     setState(() {
                                                            //       textFieldFocusNode
                                                            //           .unfocus();

                                                            //       _selectProduct(
                                                            //           product);

                                                            //       print(product[
                                                            //           'id']);

                                                            //       discountId =
                                                            //           product['id'];
                                                            //       setState(() {});
                                                            //     });
                                                            //   },
                                                            // ),

                                                            ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              print(discountId);
                                              discountIdFix = discountId;
                                              Navigator.pop(context);
                                              String typePrice = "price";
                                              if (tapTrue == 1) {
                                                typePrice = "price";
                                              } else if (typePrice == 2) {
                                                typePrice =
                                                    "price_online_shop    ";
                                              }

                                              calculateTransaction(
                                                  context,
                                                  widget.token,
                                                  cartMap,
                                                  setState,
                                                  pelangganId,
                                                  typePrice,
                                                  discountIdFix);
                                            });
                                          },
                                          child: buttonXXL(
                                            Center(
                                              child: Text(
                                                'Simpan',
                                                style: heading2(FontWeight.w600,
                                                    bnw100, 'Outfit'),
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
                            );
                          },
                        );
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: buttonXLoutline(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pilih Diskon',
                                style:
                                    heading3(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                              Icon(PhosphorIcons.tag_fill, color: bnw900)
                            ],
                          ),
                          double.infinity,
                          bnw300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 6,
              child: Container(
                  padding: EdgeInsets.all(size16),
                  decoration: ShapeDecoration(
                    color: bnw100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size16),
                    ),
                    shadows: [
                      BoxShadow(
                        color: shadowCard,
                        blurRadius: width2,
                        offset: Offset(0, 0),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Metode Pembayaran',
                                  style: heading2(
                                      FontWeight.w600, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(height: size16),
                              Expanded(
                                child: PageView(
                                  controller: _pageMetodeSwap,
                                  scrollDirection: Axis.vertical,
                                  pageSnapping: true,
                                  reverse: false,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: [
                                    ListView.builder(
                                        padding: EdgeInsets.zero,
                                        physics: BouncingScrollPhysics(),
                                        itemCount: objects.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              selectedIndex = index;

                                              log(index.toString());
                                              pageControllerPayment
                                                  .jumpToPage(index);

                                              setState(() {});
                                            },
                                            child: IntrinsicHeight(
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    size8,
                                                    size8,
                                                    size8,
                                                    size16),
                                                margin: EdgeInsets.only(
                                                  bottom: index ==
                                                          objects.length - 1
                                                      ? 0
                                                      : size16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: selectedIndex == index
                                                      ? primary200
                                                      : bnw100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size8),
                                                  border: Border.all(
                                                    color:
                                                        selectedIndex == index
                                                            ? primary500
                                                            : bnw300,
                                                    width: 1.6,
                                                  ),
                                                ),
                                                width: double.infinity,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      objects[index].icon,
                                                      color: bnw900,
                                                      size: 46,
                                                    ),
                                                    Text(
                                                      objects[index].title,
                                                      style: heading3(
                                                          FontWeight.w700,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                    Text(
                                                      objects[index]
                                                          .description,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: body1(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                    Material(
                                      color: bnw100,
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                size12, 0, size12, size12),
                                            decoration: BoxDecoration(
                                              color: primary100,
                                              borderRadius:
                                                  BorderRadius.circular(size8),
                                              border: Border.all(
                                                  color: primary500,
                                                  width: 1.6),
                                            ),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                3.6,
                                            width: double.infinity,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  PhosphorIcons.qr_code_fill,
                                                  color: bnw900,
                                                  size: 46,
                                                ),
                                                Text(
                                                  'Dompet Digital',
                                                  style: heading3(
                                                      FontWeight.w700,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                                Text(
                                                  'Pindai kode batang (QR Code) untuk membayar ',
                                                  textAlign: TextAlign.center,
                                                  style: body1(FontWeight.w400,
                                                      bnw900, 'Outfit'),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              dompetDigitalPageCon
                                                  .jumpToPage(0);
                                              _pageMetodeSwap.previousPage(
                                                duration:
                                                    Duration(milliseconds: 10),
                                                curve: Curves.easeIn,
                                              );
                                              uangTunaiController.text = '0';
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              margin: EdgeInsets.fromLTRB(
                                                  size12, 0, size12, size12),
                                              child: buttonXLoutline(
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Icon(
                                                        PhosphorIcons
                                                            .arrow_left,
                                                        size: size32,
                                                        color: bnw900,
                                                      ),
                                                      SizedBox(width: size16),
                                                      Text(
                                                        'Kembali',
                                                        style: heading2(
                                                            FontWeight.w600,
                                                            bnw900,
                                                            'Outfit'),
                                                      ),
                                                    ]),
                                                0,
                                                bnw300,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: size16),
                      Flexible(
                        flex: 5,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: double.infinity,
                          child: PageView(
                            controller: pageControllerPayment,
                            scrollDirection: Axis.vertical,
                            pageSnapping: true,
                            reverse: false,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              tunai(displayCode, setState, context),
                              dompetDigital(context),
                              kartuKredit(context),
                              kartuDedit(context),
                              fifaKoin(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  fifaKoin(BuildContext context) {
    pinController.text = totalTransaksi.toString();
    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Pembeli',
            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
          ),
          SizedBox(height: size16),
          Consumer<RefreshTampilan>(
            builder: (context, value, child) => SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  pilihPembeliShowBottom(context, 6);
                },
                child: buttonL(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                          value.namaPelanggan == ''
                              ? PhosphorIcons.users_three
                              : PhosphorIcons.users_three_fill,
                          color:
                              value.namaPelanggan == '' ? bnw900 : primary500,
                          size: size24),
                      SizedBox(width: size16),
                      value.namaPelanggan != ''
                          ? Expanded(
                              child: SizedBox(
                                child: Text(
                                  value.namaPelanggan == ''
                                      ? 'Pilih Pembeli'
                                      : value.namaPelanggan.toString(),
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: heading4(
                                    FontWeight.w400,
                                    value.namaPelanggan == ''
                                        ? bnw900
                                        : primary500,
                                    'Outfit',
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              child: Text(
                                'Pilih Pembeli',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: heading4(
                                  FontWeight.w400,
                                  value.namaPelanggan == ''
                                      ? bnw900
                                      : primary500,
                                  'Outfit',
                                ),
                              ),
                            ),

                      // SizedBox(width: size16),
                      value.namaPelanggan != ''
                          ? GestureDetector(
                              onTap: () {
                                pelangganId = '';
                                value.namaPelanggan = '';
                                value.idPelanggan = '';
                                value.notifyListeners();
                                setState(() {});
                              },
                              child: Icon(PhosphorIcons.x,
                                  color: primary500, size: size24),
                            )
                          : SizedBox(),
                    ],
                  ),
                  value.namaPelanggan == '' ? bnw100 : primary100,
                  value.namaPelanggan == '' ? bnw300 : primary500,
                ),
              ),
            ),
          ),
          Spacer(),
          rincianPembayaran(
            context,
            (uangTunaiController.text = totalTransaksi.toString()),
            '006',
            '',
          )
        ],
      ),
    );
  }

  kartuDedit(BuildContext context) {
    bool displayCode = false;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Masukkan Nomor Kartu Debit',
            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
          ),
          SizedBox(height: size16),
          Row(
            children: [
              Text(
                'Nomor Kartu',
                style: heading3(FontWeight.w400, bnw900, 'Outfit'),
              ),
              Text(
                ' *',
                style: heading3(FontWeight.w400, red500, 'Outfit'),
              ),
            ],
          ),
          IntrinsicHeight(
            child: Container(
              child: TextField(
                cursorColor: primary500,
                onTap: () {
                  displayCode = true;
                  print(displayCode);
                  setState(() {});
                },
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                controller: debitpinController,
                inputFormatters: [
                  NumericTextFormatter(),
                ],
                keyboardType: TextInputType.number,
                readOnly: true,
                onChanged: (value) {},
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: primary500,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: size8),
                  isDense: true,
                  focusColor: primary500,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 1.5,
                      color: bnw500,
                    ),
                  ),
                  hintText: 'Cth : 0000-0000-0000-0000',
                  hintStyle: heading2(FontWeight.w700, bnw500, 'Outfit'),
                ),
              ),
            ),
          ),
          Spacer(),
          displayCode != true
              ? rincianPembayaran(
                  context,
                  (uangTunaiController.text = totalTransaksi.toString()),
                  '005',
                  debitpinController.text,
                )
              : keypad(displayCode, debitpinController),
        ],
      ),
    );
  }

  kartuKredit(BuildContext context) {
    bool displayCode = false;
    // TextEditingController pinController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Masukkan Nomor Kartu Kredit',
            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
          ),
          SizedBox(height: size16),
          Row(
            children: [
              Text(
                'Nomor Kartu',
                style: heading3(FontWeight.w400, bnw900, 'Outfit'),
              ),
              Text(
                ' *',
                style: heading3(FontWeight.w400, red500, 'Outfit'),
              ),
            ],
          ),
          TextFormField(
            onTap: () {
              displayCode = true;
              print(displayCode);
              setState(() {});
            },
            style: heading2(FontWeight.w700, bnw900, 'Outfit'),
            keyboardType: TextInputType.number,
            controller: kreditpinController,
            readOnly: true,
            onChanged: (value) {},
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: size8),
              isDense: true,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: bnw500,
                ),
              ),
              hintText: 'Cth : 0000-0000-0000-0000',
              hintStyle: heading2(FontWeight.w700, bnw500, 'Outfit'),
            ),
          ),
          Spacer(),
          Divider(),
          displayCode != true
              ? rincianPembayaran(
                  context,
                  (uangTunaiController.text = totalTransaksi.toString()),
                  '004',
                  kreditpinController.text,
                )
              : keypad(displayCode, kreditpinController),
          // : NumPad(displayCode: displayCode, pinCon: kreditpinController,)
        ],
      ),
    );
  }

  dompetDigital(BuildContext context) {
    TextEditingController kodeManualPembayaran = TextEditingController();

    List<MetodePembayaranObject> metodePembayaranObjects = [
      // MetodePembayaranObject(
      //     'Gunakan pembayaran dengan kode batang (QR) FifaPay',
      //     'fifapaylogolong.png'),
      MetodePembayaranObject(
          'Pembayaran dengan dompet digital yang mendukung', 'qrislogo.png'),
    ];

    return StatefulBuilder(
      builder: (context, setState) => PageView(
        controller: dompetDigitalPageCon,
        scrollDirection: Axis.vertical,
        pageSnapping: true,
        reverse: false,
        physics: NeverScrollableScrollPhysics(),
        children: [
          SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Dompet Digital',
                  style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                ),
                SizedBox(height: size16),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: BouncingScrollPhysics(),
                    itemCount: metodePembayaranObjects.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        selectedIndexDompetDigital = index;
                        print(totalTransaksi);
                        // dompetDigitalPageCon.jumpToPage(index + 1);
                        // _pageMetodeSwap.animateToPage(
                        //   1,
                        //   duration:  Duration(milliseconds: 10),
                        //   curve: Curves.easeIn,
                        // );
                        setState(() {});
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: size16),
                        padding: EdgeInsets.all(size12),
                        width: double.infinity,
                        height: 98,
                        decoration: BoxDecoration(
                          color: selectedIndexDompetDigital == index
                              ? primary200
                              : bnw100,
                          borderRadius: BorderRadius.circular(size8),
                          border: Border.all(
                            color: selectedIndexDompetDigital == index
                                ? primary500
                                : bnw300,
                            width: 1.6,
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/${metodePembayaranObjects[index].image}",
                            ),
                            SizedBox(width: size12),
                            Flexible(
                              child: Text(
                                metodePembayaranObjects[index].title,
                                style:
                                    heading4(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(),
                rincianPembayaranSelanjutnya(context, dompetDigitalPageCon,
                    _pageMetodeSwap, selectedIndexDompetDigital)
              ],
            ),
          ),
          SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // padding: EdgeInsets.zero,
              // physics:  BouncingScrollPhysics(),
              children: [
                Text(
                  'Pindai Kode Batang QRIS',
                  style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                ),
                SizedBox(height: size8),
                GestureDetector(
                    onTap: () {
                      getQris(context, widget.token, '').then((value) {
                        value == '00'
                            ? showBottomPilihan(
                                context,
                                Column(
                                  children: [
                                    Text(
                                      'Kode Batang QRIS',
                                      style: heading1(
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                    SizedBox(height: size16),
                                    Container(
                                      height: 260,
                                      width: 260,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(size8),
                                        border: Border.all(color: bnw300),
                                      ),
                                      child: logoQris == ''
                                          ? Icon(PhosphorIcons.plus)
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(size8),
                                              child: Image.network(
                                                logoQris ?? '',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                    SizedBox(height: size16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: buttonXL(
                                            Center(
                                              child: Text(
                                                'Selesai',
                                                style: heading3(FontWeight.w600,
                                                    bnw100, 'Outfit'),
                                              ),
                                            ),
                                            double.infinity,
                                          )),
                                    ),
                                  ],
                                ),
                              )
                            : null;
                      });
                      setState(() {});
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: buttonXLoutline(
                          Center(
                              child: Text('Tunjukkan Kode Batang',
                                  style: heading3(
                                      FontWeight.w400, bnw900, 'Outfit'))),
                          double.infinity,
                          bnw300),
                    )),
                Spacer(),
                rincianPembayaran(context, totalTransaksi.toString(), '003', '')
              ],
            ),
          ),
        ],
      ),
    );
  }

  tunai(bool? displayCode, StateSetter setState, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Masukkan Uang Tunai',
            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
          ),
          SizedBox(height: size16),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Uang Tunai',
                      style: heading3(FontWeight.w500, bnw900, 'Outfit'),
                    ),
                    Text(
                      ' *',
                      style: heading3(FontWeight.w700, red500, 'Outfit'),
                    ),
                  ],
                ),
                IntrinsicHeight(
                  child: Container(
                    child: TextFormField(
                      onTap: () {
                        displayCode = true;
                        print(displayCode);
                        setState(() {});
                      },
                      style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      controller: uangTunaiController,
                      inputFormatters: [
                        NumericTextFormatter(),
                        LengthLimitingTextInputFormatter(20),
                      ],
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: size8),
                        isDense: true,
                        focusColor: primary500,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 1.5,
                            color: bnw500,
                          ),
                        ),
                        // hintText: cart[0].price.toString(),
                        hintText: 'Rp 0',
                        hintStyle: heading1(FontWeight.w700, bnw500, 'Outfit'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: size16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              uangTunaiController.text = '20000';
                            });
                          },
                          child: buttonLoutline(
                            Center(
                              child: Text(
                                'Rp 20,000',
                                style:
                                    heading3(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                            ),
                            bnw300,
                          ),
                        ),
                      ),
                      SizedBox(width: size16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              uangTunaiController.text = '50000';
                            });
                          },
                          child: buttonLoutline(
                            Center(
                              child: Text(
                                'Rp 50,000',
                                style:
                                    heading3(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                            ),
                            bnw300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size16),
                  GestureDetector(
                    onTap: () {
                      uangTunaiController.text = totalTransaksi.toString();
                      setState(() {});
                    },
                    child: buttonLoutline(
                      Center(
                        child: Text(
                          'Uang Pas',
                          style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                      ),
                      bnw300,
                    ),
                  ),
                  SizedBox(height: size16),
                ],
              ),
            ),
          ),
          // displayCode != true ? SizedBox() : Spacer(),
          displayCode != true
              ? rincianPembayaran(context, uangTunaiController.text, '001', '')
              : keypad(displayCode, uangTunaiController),
        ],
      ),
    );
  }

  keypad(bool? displayCode, TextEditingController pinCon) {
    return Container(
      // height: MediaQuery.of(context).size.he,
      // color: bnw300,

      child: Column(
        children: [
          dividerTransaksi(),
          SizedBox(height: size16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttonWidget('1', pinCon),
              SizedBox(width: size16),
              buttonWidget('2', pinCon),
              SizedBox(width: size16),
              buttonWidget('3', pinCon),
            ],
          ),
          SizedBox(height: size16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttonWidget('4', pinCon),
              SizedBox(width: size16),
              buttonWidget('5', pinCon),
              SizedBox(width: size16),
              buttonWidget('6', pinCon),
            ],
          ),
          SizedBox(height: size16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttonWidget('7', pinCon),
              SizedBox(width: size16),
              buttonWidget('8', pinCon),
              SizedBox(width: size16),
              buttonWidget('9', pinCon),
            ],
          ),
          SizedBox(height: size16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttonWidget('00', pinCon),
              SizedBox(width: size16),
              buttonWidget('0', pinCon),
              SizedBox(width: size16),
              iconButtonWidget(() {
                // setState(() {});
                if (pinCon.text.length > 0) {
                  pinCon.text =
                      pinCon.text.substring(0, pinCon.text.length - 1);
                }

                (String pin) {
                  pinCon.text = pin;
                  print('${pinCon.text}');

                  setState(() {});
                };
              }),
            ],
          ),
          SizedBox(height: size16),
          GestureDetector(
            onTap: () {
              // log(displayCode.toString());
              setState(() {
                displayCode != displayCode;
                selectedIndex = selectedIndex;
              });
            },
            child: buttonXXL(
              Center(
                child: Text(
                  'Selesai',
                  style: heading2(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Divider dividerTransaksi() {
    return Divider(
      height: width2,
      color: bnw900,
    );
  }

  rincianPembayaran(BuildContext context, pinValue, payMethod, payReference) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Text(
            'Rincian Pembayaran',
            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
          ),
          SizedBox(height: size8),
          rincianText('Nama Pembeli', namaCustomerCalculate.toString()),
          SizedBox(height: size8),
          rincianText(
            'Sub Total',
            FormatCurrency.convertToIdr(subTotal ?? 0),
          ),
          SizedBox(height: size8),
          rincianText('PPN', FormatCurrency.convertToIdr(ppnTransaksi ?? 0)),
          SizedBox(height: size8),
          rincianText(
              'Diskon', FormatCurrency.convertToIdr(discountProduct ?? 0)),
          SizedBox(height: size16),
          dash(),
          SizedBox(height: size16),
          uangTunaiController.text != '0'
              ? uangTunaiController.text != 'Rp 0'
                  ? Column(
                      children: [
                        rincianText(
                          'Tunai',
                          FormatCurrency.convertToIdr((int.parse(
                              uangTunaiController.text
                                  .replaceAll(RegExp(r'[^0-9]'), '')))),
                        ),
                        SizedBox(height: size16),
                        rincianBlueText(
                          'Kembalian',
                          FormatCurrency.convertToIdr((int.parse(
                                  uangTunaiController.text
                                      .replaceAll(RegExp(r'[^0-9]'), ''))) -
                              totalTransaksi),
                        ),
                        SizedBox(height: size16),
                        dash(),
                        SizedBox(height: size16),
                      ],
                    )
                  : SizedBox()
              : SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: heading1(FontWeight.w700, bnw900, 'Outfit'),
              ),
              Text(
                FormatCurrency.convertToIdr(totalTransaksi ?? 0),
                // FormatCurrency.convertToIdr(
                //     cart[0].price ?? 0),

                style: heading1(FontWeight.w700, bnw900, 'Outfit'),
              ),
            ],
          ),
          SizedBox(height: size16),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onTap: () {
                if (uangTunaiController.text != 'Rp 0') {
                  if (uangTunaiController.text != '0') {
                    createTransactionBayar(
                      context,
                      widget.token,
                      pinValue.replaceAll(RegExp(r'[^0-9]'), ''),
                      cartMap,
                      _pageController,
                      cart,
                      setState,
                      payMethod,
                      payReference,
                      transactionidValue ?? '',
                      pelangganId,
                      '',
                      discountId,
                    );
                  }
                }

                setState(() {});
              },
              child: buttonXXLonOff(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.wallet_fill,
                      color: bnw100,
                    ),
                    SizedBox(width: size16),
                    Text(
                      'Bayar',
                      style: heading2(FontWeight.w600, bnw100, 'Outfit'),
                    )
                  ],
                ),
                double.infinity,
                (uangTunaiController.text == 'Rp 0' ||
                        uangTunaiController.text == '0')
                    ? bnw300
                    : primary500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  rincianPembayaranSelanjutnya(
    BuildContext context,
    dompetDigitalPageCon,
    pageMetodeSwap,
    index,
  ) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Pembayaran',
            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
          ),
          SizedBox(height: size8),
          rincianText('Nama Pembeli', namaCustomerCalculate.toString()),
          SizedBox(height: size8),
          rincianText(
            'Sub Total',
            FormatCurrency.convertToIdr(subTotal ?? 0),
          ),
          SizedBox(height: size8),
          rincianText('PPN', FormatCurrency.convertToIdr(ppnTransaksi ?? 0)),
          SizedBox(height: size16),
          dash(),
          SizedBox(height: size16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: heading1(FontWeight.w700, bnw900, 'Outfit'),
              ),
              Text(
                FormatCurrency.convertToIdr(totalTransaksi ?? 0),
                // FormatCurrency.convertToIdr(
                //     cart[0].price ?? 0),

                style: heading1(FontWeight.w700, bnw900, 'Outfit'),
              ),
            ],
          ),
          SizedBox(height: size16),
          SizedBox(
            child: GestureDetector(
              onTap: () async {
                dompetDigitalPageCon.jumpToPage(index + 1);
                pageMetodeSwap.jumpToPage(1);

                uangTunaiController.text = totalTransaksi.toString();

                setState(() {});
              },
              child: buttonXXL(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Selanjutnya',
                      style: heading2(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                    SizedBox(width: size16),
                    Icon(
                      PhosphorIcons.arrow_right,
                      color: bnw100,
                      size: size32,
                    ),
                  ],
                ),
                double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pesananStruk(title, subTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
        ),
        Text(
          subTitle,
          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
        ),
      ],
    );
  }

  Row kembalianStruk(title, subTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        Text(
          subTitle,
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
      ],
    );
  }

  rincianText(String title, subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: heading4(FontWeight.w500, bnw900, 'Outfit'),
        ),
        Text(
          subtitle,
          style: heading4(FontWeight.w500, bnw900, 'Outfit'),
        ),
      ],
    );
  }

  rincianBlueText(String title, subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: heading4(FontWeight.w500, primary500, 'Outfit'),
        ),
        Text(
          subtitle,
          style: heading4(FontWeight.w500, primary500, 'Outfit'),
        ),
      ],
    );
  }

  getAllProduct(BuildContext context, PageController pageController) {
    int newquantity = 1;
    getStruk(context, widget.token, '');
    return Row(
      children: [
        !isExpand
            ? Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(size16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transaksi',
                                  style: heading1(
                                      FontWeight.w700, bnw900, 'Outfit'),
                                ),
                                Text(
                                  nameToko ?? '',
                                  style: heading3(
                                      FontWeight.w300, bnw900, 'Outfit'),
                                ),
                              ],
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              child: SizedBox(
                                child: TextField(
                                  cursorColor: primary500,
                                  style: heading2(
                                      FontWeight.w500, bnw900, 'Outfit'),
                                  controller: searchController,
                                  onChanged: (value) async {
                                    datasTransaksi = await getProductTransaksi(
                                      context,
                                      widget.token,
                                      value,
                                      [''],
                                      textvalueOrderBy,
                                    );
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: size16),
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
                                    prefixIconConstraints:
                                        BoxConstraints.loose(Size.infinite),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.fromLTRB(
                                          size20, 0, size16, 0),
                                      child: Icon(
                                        PhosphorIcons.magnifying_glass,
                                        color: bnw900,
                                        size: size32,
                                      ),
                                    ),
                                    suffixIconConstraints:
                                        BoxConstraints.loose(Size.infinite),
                                    suffixIcon: searchController.text.isNotEmpty
                                        ? Container(
                                            margin: EdgeInsets.fromLTRB(
                                                size16, 0, size20, 0),
                                            child: GestureDetector(
                                              onTap: () {
                                                searchController.text = '';
                                                initState();
                                              },
                                              child: Icon(
                                                PhosphorIcons.x_fill,
                                                size: size32,
                                                color: bnw900,
                                              ),
                                            ),
                                          )
                                        : null,
                                    hintText: 'Cari nama produk',
                                    hintStyle: heading2(
                                        FontWeight.w500, bnw400, 'Outfit'),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            GestureDetector(
                              onTap: () {
                                customProdukName.text = "";
                                customProdukPrice.text = "";
                                conCatatanPreview.text = '';
                                errorText = "";
                                showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  useRootNavigator: false,
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(size16),
                                  ),
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) => Container(
                                        margin: EdgeInsets.only(top: size16),
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        decoration: ShapeDecoration(
                                          color: bnw100,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(size16),
                                              topRight: Radius.circular(size16),
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              size32, size16, size32, size32),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                dividerShowdialog(),
                                                SizedBox(height: size16),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text('Kustom Produk',
                                                      style: heading1(
                                                          FontWeight.w700,
                                                          bnw900,
                                                          'Outfit')),
                                                ),
                                                SizedBox(width: size16),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Nama Produk',
                                                            style: body1(
                                                                FontWeight.w500,
                                                                bnw900,
                                                                'Outfit'),
                                                          ),
                                                          IntrinsicHeight(
                                                            child:
                                                                TextFormField(
                                                              // keyboardType: numberNo,
                                                              style: heading2(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw900,
                                                                  'Outfit'),
                                                              controller:
                                                                  customProdukName,

                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            size12),
                                                                enabledBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: 1.5,
                                                                    color:
                                                                        bnw500,
                                                                  ),
                                                                ),
                                                                hintText:
                                                                    'Cth : Lemon Tea',
                                                                hintStyle: heading2(
                                                                    FontWeight
                                                                        .w600,
                                                                    bnw500,
                                                                    'Outfit'),
                                                              ),
                                                            ),
                                                          ),
                                                          errorText.isNotEmpty
                                                              ? Column(
                                                                  children: [
                                                                    SizedBox(
                                                                        height:
                                                                            size16),
                                                                    Text(
                                                                      errorText,
                                                                      style: body1(
                                                                          FontWeight
                                                                              .w500,
                                                                          bnw100,
                                                                          'Outfit'),
                                                                    ),
                                                                  ],
                                                                )
                                                              : SizedBox(),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: size16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Harga',
                                                                style: body1(
                                                                    FontWeight
                                                                        .w500,
                                                                    bnw900,
                                                                    'Outfit'),
                                                              ),
                                                              Text(
                                                                '*',
                                                                style: body1(
                                                                    FontWeight
                                                                        .w500,
                                                                    danger500,
                                                                    'Outfit'),
                                                              ),
                                                            ],
                                                          ),
                                                          IntrinsicHeight(
                                                            child:
                                                                TextFormField(
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              style: heading2(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw900,
                                                                  'Outfit'),
                                                              controller:
                                                                  customProdukPrice,
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            size12),
                                                                enabledBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: 1.5,
                                                                    color: errorText
                                                                            .isEmpty
                                                                        ? bnw500
                                                                        : danger500,
                                                                  ),
                                                                ),
                                                                hintText:
                                                                    'Cth : 25.000',
                                                                hintStyle: heading2(
                                                                    FontWeight
                                                                        .w600,
                                                                    bnw500,
                                                                    'Outfit'),
                                                              ),
                                                            ),
                                                          ),
                                                          errorText.isNotEmpty
                                                              ? Column(
                                                                  children: [
                                                                    SizedBox(
                                                                        height:
                                                                            size16),
                                                                    Text(
                                                                      errorText,
                                                                      style: body1(
                                                                          FontWeight
                                                                              .w500,
                                                                          red500,
                                                                          'Outfit'),
                                                                    ),
                                                                  ],
                                                                )
                                                              : SizedBox(),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: size16),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text('Jumlah',
                                                            style: heading3(
                                                                FontWeight.w400,
                                                                bnw900,
                                                                'Outfit')),
                                                        SizedBox(height: size8),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (counterCart >
                                                                    1) {
                                                                  counterCart--;
                                                                  conCounterPreview
                                                                          .text =
                                                                      counterCart
                                                                          .toString();
                                                                }
                                                                setState(() {});
                                                              },
                                                              child:
                                                                  buttonMoutlineColor(
                                                                Icon(
                                                                  PhosphorIcons
                                                                      .minus,
                                                                  color:
                                                                      primary500,
                                                                  size: size24,
                                                                ),
                                                                primary500,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: size8),
                                                            SizedBox(
                                                              height: size48,
                                                              width: size56,
                                                              child:
                                                                  TextFormField(
                                                                enabled: true,
                                                                controller:
                                                                    conCounterPreview,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    int parsedValue =
                                                                        int.tryParse(value) ??
                                                                            0;
                                                                    counterCart =
                                                                        parsedValue;
                                                                    conCounterPreview
                                                                            .text =
                                                                        counterCart
                                                                            .toString();
                                                                  });
                                                                },
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                decoration:
                                                                    InputDecoration(
                                                                  // alignLabelWithHint: true,
                                                                  hintText:
                                                                      counterCart
                                                                          .toString(),

                                                                  // .toString(),
                                                                  // _itemCount.toString(),
                                                                  hintStyle: heading4(
                                                                      FontWeight
                                                                          .w600,
                                                                      bnw800,
                                                                      'Outfit'),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: size8),
                                                            GestureDetector(
                                                              onTap: () {
                                                                counterCart++;
                                                                conCounterPreview
                                                                        .text =
                                                                    counterCart
                                                                        .toString();
                                                                setState(() {});
                                                              },
                                                              child:
                                                                  buttonMoutlineColor(
                                                                Icon(
                                                                  PhosphorIcons
                                                                      .plus,
                                                                  color:
                                                                      primary500,
                                                                  size: size24,
                                                                ),
                                                                primary500,
                                                                // 50,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        errorText.isNotEmpty
                                                            ? Column(
                                                                children: [
                                                                  SizedBox(
                                                                      height:
                                                                          size16),
                                                                  Text(
                                                                    errorText,
                                                                    style: body1(
                                                                        FontWeight
                                                                            .w500,
                                                                        bnw100,
                                                                        'Outfit'),
                                                                  ),
                                                                ],
                                                              )
                                                            : SizedBox(),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: size16),
                                                Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Catatan',
                                                        style: body1(
                                                            FontWeight.w500,
                                                            bnw900,
                                                            'Outfit'),
                                                      ),
                                                      IntrinsicHeight(
                                                        child: TextFormField(
                                                          // keyboardType: numberNo,
                                                          style: heading2(
                                                              FontWeight.w600,
                                                              bnw900,
                                                              'Outfit'),
                                                          controller:
                                                              conCatatanPreview,
                                                          onChanged: (value) {
                                                            // String formattedValue = formatCurrency(value);
                                                            // conHarga.value = TextEditingValue(
                                                            //   text: formattedValue,
                                                            //   selection:
                                                            //       TextSelection.collapsed(offset: formattedValue.length),
                                                            // );
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    vertical:
                                                                        size12),
                                                            enabledBorder:
                                                                UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                width: 1.5,
                                                                color: bnw500,
                                                              ),
                                                            ),
                                                            hintText:
                                                                'Cth : Tambah ekstra topping Boba dan Gula 2 sendok',
                                                            hintStyle: heading2(
                                                                FontWeight.w600,
                                                                bnw500,
                                                                'Outfit'),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: size32),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {});
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: buttonXLoutline(
                                                            Center(
                                                              child: Text(
                                                                'Batalkan',
                                                                style: heading3(
                                                                    FontWeight
                                                                        .w600,
                                                                    primary500,
                                                                    'Outfit'),
                                                              ),
                                                            ),
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            primary500),
                                                      ),
                                                    ),
                                                    SizedBox(width: size16),
                                                    Expanded(
                                                        child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          if (customProdukPrice
                                                                  .text
                                                                  .isNotEmpty &&
                                                              customProdukPrice
                                                                      .text !=
                                                                  '0') {
                                                            if (!isItemAdded) {
                                                              Navigator.pop(
                                                                  context);
                                                              if (customProdukName
                                                                  .text
                                                                  .isEmpty) {
                                                                customProdukName
                                                                        .text =
                                                                    'Produk Kustom';
                                                              }
                                                              Map<String,
                                                                      String>
                                                                  map1 = {};
                                                              map1['name'] =
                                                                  customProdukName
                                                                      .text;
                                                              map1['productid'] =
                                                                  'custom';
                                                              // map1['quantity'] = '1';
                                                              map1['quantity'] =
                                                                  counterCart
                                                                      .toString();

                                                              map1['image'] =
                                                                  'https://cdn.icon-icons.com/icons2/2718/PNG/512/package_icon_174342.png';
                                                              map1['amount'] =
                                                                  customProdukPrice
                                                                      .text
                                                                      .replaceAll(
                                                                          RegExp(
                                                                              r'[^0-9]'),
                                                                          '');
                                                              map1['description'] =
                                                                  conCatatanPreview
                                                                      .text;

                                                              cartMap.add(map1);

                                                              // log(datasTransaksi![i].product_image.toString());

                                                              String name =
                                                                  customProdukName
                                                                      .text;
                                                              String productid =
                                                                  'custom';
                                                              String image =
                                                                  'https://cdn.icon-icons.com/icons2/2718/PNG/512/package_icon_174342.png';
                                                              // String desc = conCatatan[i]
                                                              //     .text
                                                              //     .toString()
                                                              //     .trim();

                                                              //int? price = ( datasTransaksi![i].price!);
                                                              int? price = int.parse(
                                                                  customProdukPrice
                                                                      .text
                                                                      .replaceAll(
                                                                          RegExp(
                                                                              r'[^0-9]'),
                                                                          ''));

                                                              int index = 0;
                                                              for (index;
                                                                  index <
                                                                      cart.length;
                                                                  index++) {}

                                                              // int? quantity = cart[i];

                                                              // log(name.toString());
                                                              // log(price.toString());
                                                              // log(productid.toString());
                                                              // log(image.toString());

                                                              sumTotal = sumTotal +
                                                                  (price *
                                                                      counterCart);
                                                              // subTotal =
                                                              //     subTotal + price.toInt();
                                                              total.add(price *
                                                                  counterCart);

                                                              cart.add(
                                                                CartTransaksi(
                                                                  name: name,
                                                                  productid:
                                                                      productid,
                                                                  image: image,
                                                                  price: price,
                                                                  quantity:
                                                                      counterCart,
                                                                  desc:
                                                                      conCatatanPreview
                                                                          .text,
                                                                  // quantity: cart[i]
                                                                  //     .quantity
                                                                  //     .toInt(),
                                                                ),
                                                              );
                                                              for (int i = 0;
                                                                  i <=
                                                                      cart.length;
                                                                  i++) {
                                                                conCatatan.add(
                                                                  TextEditingController(
                                                                    text: conCatatanPreview
                                                                        .text,
                                                                  ),
                                                                );
                                                                inputValues.add(
                                                                    conCatatanPreview
                                                                        .text);
                                                                setState(() {});
                                                                initState();
                                                              }

                                                              refreshColor();

                                                              num totalku = 0;
                                                              cartMap.forEach(
                                                                  (element) {
                                                                var myelement =
                                                                    int.parse(
                                                                        element[
                                                                            'amount']!);
                                                                totalku = totalku +
                                                                    (myelement *
                                                                        counterCart);
                                                              });

                                                              sumTotal =
                                                                  totalku;
                                                            }
                                                          } else {
                                                            errorText =
                                                                'Wajib diisi';
                                                          }
                                                        });
                                                      },
                                                      child: buttonXL(
                                                        Center(
                                                          child: Text(
                                                            'Tambah Ke Keranjang',
                                                            style: heading3(
                                                                FontWeight.w600,
                                                                bnw100,
                                                                'Outfit'),
                                                          ),
                                                        ),
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                      ),
                                                    )),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: buttonXLoutline(
                                Row(
                                  children: [
                                    Icon(
                                      PhosphorIcons.plus,
                                      size: size24,
                                      color: primary500,
                                    ),
                                    SizedBox(width: size12),
                                    Text(
                                      'Kustom Produk',
                                      style: heading2(FontWeight.w600,
                                          primary500, 'Outfit'),
                                    ),
                                  ],
                                ),
                                double.infinity,
                                primary500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: TabBar(
                                controller: _tabController,
                                automaticIndicatorColorAdjustment: false,
                                indicatorColor: primary500,
                                unselectedLabelColor: bnw600,
                                labelColor: primary500,
                                labelStyle:
                                    heading2(FontWeight.w400, bnw900, 'Outfit'),
                                physics: NeverScrollableScrollPhysics(),
                                onTap: (value) {
                                  if (value == 0) {
                                    _pageController.animateToPage(
                                      0,
                                      duration: Duration(milliseconds: 10),
                                      curve: Curves.ease,
                                    );
                                  } else if (value == 1) {
                                    _pageController.animateToPage(
                                      2,
                                      duration: Duration(milliseconds: 10),
                                      curve: Curves.ease,
                                    );
                                  } else if (value == 2) {
                                    _pageController.animateToPage(
                                      3,
                                      duration: Duration(milliseconds: 10),
                                      curve: Curves.ease,
                                    );
                                  }
                                  setState(() {});
                                },
                                tabs: [
                                  Tab(
                                    text: 'Kasir',
                                  ),
                                  Tab(
                                    text: 'Riwayat',
                                  ),
                                  Tab(
                                    text: 'Pengaturan',
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: TabBarView(
                                  physics: NeverScrollableScrollPhysics(),
                                  controller: _tabController,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: size16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              orderBy(context),
                                              buttonLoutlineColor(
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        PhosphorIcons.info_fill,
                                                        color: cart.isEmpty
                                                            ? bnw600
                                                            : succes600,
                                                        size: size24,
                                                      ),
                                                      SizedBox(width: size12),
                                                      Text(
                                                        '${cart.length} Produk Terpilih',
                                                        style: TextStyle(
                                                          color: cart.isEmpty
                                                              ? bnw600
                                                              : succes600,
                                                          fontFamily: 'Outfit',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  cart.isEmpty
                                                      ? bnw200
                                                      : succes100,
                                                  cart.isEmpty
                                                      ? bnw400
                                                      : succes600)
                                            ],
                                          ),
                                          SizedBox(height: size16),
                                          datasTransaksi == null
                                              ? SkeletonCardTransaksi()
                                              : Expanded(
                                                  child: RefreshIndicator(
                                                    onRefresh: () async {
                                                      setState(() {});
                                                      initState();
                                                    },
                                                    child:
                                                        SingleChildScrollView(
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            child: GridView.builder(
                                                                shrinkWrap: true,
                                                                padding: EdgeInsets.zero,
                                                                physics: BouncingScrollPhysics(),
                                                                itemCount: datasTransaksi!.length,
                                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                    // mainAxisExtent:
                                                                    //     null,
                                                                    crossAxisCount: 4,
                                                                    crossAxisSpacing: size16,
                                                                    mainAxisSpacing: size16,
                                                                    childAspectRatio: 0.60),
                                                                itemBuilder: (context, i) {
                                                                  // Create for consume api and get data
                                                                  String
                                                                      productSelect =
                                                                      datasTransaksi![
                                                                              i]
                                                                          .productid!;
                                                                  return GestureDetector(
                                                                    //!!edited
                                                                    onTap:
                                                                        () async {
                                                                      counterCart =
                                                                          1;

                                                                      String
                                                                          productId =
                                                                          datasTransaksi![i]
                                                                              .productid
                                                                              .toString();

                                                                      conCatatanPreview
                                                                          .text = '';

                                                                      int indexToRemove = cart.indexWhere((item) =>
                                                                          item.productid ==
                                                                          productId);

                                                                      if (indexToRemove !=
                                                                          -1) {
                                                                        // Produk sudah ada di dalam keranjang
                                                                        cart.removeAt(
                                                                            indexToRemove);
                                                                        cartMap.removeAt(
                                                                            indexToRemove);
                                                                        total.removeAt(
                                                                            indexToRemove);
                                                                        conCatatan
                                                                            .removeAt(indexToRemove);

                                                                        // Clear some variables
                                                                        conCounterPreview
                                                                            .clear();
                                                                        conCatatanPreview.text =
                                                                            '';

                                                                        // Remove the product ID
                                                                        cartProductIds
                                                                            .remove(productId);

                                                                        isItemAdded =
                                                                            true;

                                                                        if (cart
                                                                            .isEmpty) {
                                                                          sumTotal =
                                                                              0;
                                                                          isItemAdded =
                                                                              false;
                                                                        }
                                                                      } else {
                                                                        // Produk belum ada di dalam keranjang, tampilkan preview
                                                                        showPriviewCart(
                                                                            context,
                                                                            i);
                                                                      }

                                                                      setState(
                                                                          () {});
                                                                      initState();
                                                                    },

                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              size8),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: cartProductIds.contains(datasTransaksi![i].productid.toString())
                                                                            ? primary100
                                                                            : bnw100,
                                                                        borderRadius:
                                                                            BorderRadius.circular(size12),
                                                                        border:
                                                                            Border.all(
                                                                          // color: bnw900,
                                                                          color: cartProductIds.contains(datasTransaksi![i].productid.toString())
                                                                              ? primary500
                                                                              : bnw300,
                                                                          width:
                                                                              2,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(size8),
                                                                            child:
                                                                                AspectRatio(
                                                                              aspectRatio: 1,
                                                                              child: Container(
                                                                                child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(size8),
                                                                                  child: Image.network(
                                                                                    fit: BoxFit.cover,
                                                                                    datasTransaksi![i].product_image.toString(),
                                                                                    loadingBuilder: (context, child, loadingProgress) {
                                                                                      if (loadingProgress == null) {
                                                                                        return child;
                                                                                      }

                                                                                      return Center(child: loading());
                                                                                    },
                                                                                    errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                                                                                      'assets/logoProduct.svg',
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.only(top: size8),
                                                                              // color:
                                                                              //     bnw300,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  SizedBox(
                                                                                    // height: 34,
                                                                                    child: Text(
                                                                                      datasTransaksi![i].name ?? '',
                                                                                      style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                                                                                      maxLines: 2,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: size4),
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                          FormatCurrency.convertToIdr(
                                                                                            datasTransaksi![i].price_after,
                                                                                          ),
                                                                                          style: heading4(FontWeight.w400, bnw900, 'Outfit')),
                                                                                      datasTransaksi![i].discount == 0
                                                                                          ? SizedBox()
                                                                                          : Row(
                                                                                              children: [
                                                                                                Text(
                                                                                                  FormatCurrency.convertToIdr(
                                                                                                    datasTransaksi![i].price,
                                                                                                  ),
                                                                                                  style: body3lineThrough(
                                                                                                    FontWeight.w400,
                                                                                                    bnw900,
                                                                                                    'Outfit',
                                                                                                  ),
                                                                                                ),
                                                                                                SizedBox(width: size4),
                                                                                                datasTransaksi![i].discount_type == 'percentage'
                                                                                                    ? Text(
                                                                                                        '${datasTransaksi![i].discount}%',
                                                                                                        style: body3(
                                                                                                          FontWeight.w700,
                                                                                                          danger500,
                                                                                                          'Outfit',
                                                                                                        ),
                                                                                                      )
                                                                                                    : Text(
                                                                                                        FormatCurrency.convertToIdr(
                                                                                                          datasTransaksi![i].discount,
                                                                                                        ),
                                                                                                        style: body3(
                                                                                                          FontWeight.w700,
                                                                                                          danger500,
                                                                                                          'Outfit',
                                                                                                        ),
                                                                                                      ),
                                                                                              ],
                                                                                            ),
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(height: size4),
                                                                                  Text(
                                                                                    datasTransaksi![i].typeproducts.toString(),
                                                                                    style: body1(FontWeight.w400, bnw500, 'Outfit'),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                }),
                                                          ),
                                                          SizedBox(
                                                              height: size16),
                                                          SizedBox(
                                                            child:
                                                                FutureBuilder(
                                                              future:
                                                                  getCoinTransaksi(
                                                                context,
                                                                widget.token,
                                                                '',
                                                                [''],
                                                              ),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (snapshot
                                                                    .hasData) {
                                                                  return GridView
                                                                      .builder(
                                                                    shrinkWrap:
                                                                        true,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    physics:
                                                                        BouncingScrollPhysics(),
                                                                    itemCount:
                                                                        snapshot
                                                                            .data
                                                                            .length,
                                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                        // mainAxisExtent:
                                                                        //     null,
                                                                        crossAxisCount: 4,
                                                                        crossAxisSpacing: size16,
                                                                        mainAxisSpacing: size16,
                                                                        childAspectRatio: 0.60),
                                                                    itemBuilder:
                                                                        (context,
                                                                                i) =>
                                                                            GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        var coin =
                                                                            snapshot.data[i];

                                                                        counterCart =
                                                                            1;
                                                                        String
                                                                            productId =
                                                                            coin['voucherid'].toString();

                                                                        conCatatanPreview.text =
                                                                            '';

                                                                        if (cartProductIds
                                                                            .contains(productId)) {
                                                                          cartProductIds
                                                                              .remove(productId);

                                                                          for (int index = 0;
                                                                              index < cart.length;
                                                                              index++) {
                                                                            if (cart[index].productid ==
                                                                                productId) {
                                                                              cart.removeAt(index);
                                                                              cartMap.removeAt(index);
                                                                              total.removeAt(index);

                                                                              conCatatan.removeAt(index);
                                                                              conCounterPreview.clear();
                                                                              conCatatanPreview.text = '';

                                                                              if (cart.isEmpty) {
                                                                                sumTotal = 0;
                                                                              }
                                                                              break;
                                                                            }
                                                                          }

                                                                          isItemAdded =
                                                                              true;
                                                                        } else {
                                                                          showModalBottomSheet(
                                                                            useRootNavigator:
                                                                                false,
                                                                            isScrollControlled:
                                                                                true,
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(size16),
                                                                            ),
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return Container(
                                                                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                                                decoration: ShapeDecoration(
                                                                                  color: bnw100,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.only(
                                                                                      topLeft: Radius.circular(size16),
                                                                                      topRight: Radius.circular(size16),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
                                                                                  child: IntrinsicHeight(
                                                                                    child: Column(
                                                                                      children: [
                                                                                        dividerShowdialog(),
                                                                                        SingleChildScrollView(
                                                                                          child: Column(
                                                                                            children: [
                                                                                              SizedBox(height: size16),
                                                                                              Container(
                                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(size12), border: Border.all(color: bnw300)),
                                                                                                  child: Column(
                                                                                                    children: [
                                                                                                      Padding(
                                                                                                        padding: EdgeInsets.all(size8),
                                                                                                        child: Column(
                                                                                                          children: [
                                                                                                            Row(
                                                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                                                              children: [
                                                                                                                ClipRRect(
                                                                                                                  borderRadius: BorderRadius.circular(size8),
                                                                                                                  child: Container(
                                                                                                                    height: size120,
                                                                                                                    width: size120,
                                                                                                                    child: SvgPicture.asset(
                                                                                                                      'assets/logoProduct.svg',
                                                                                                                      fit: BoxFit.cover,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                                SizedBox(width: size12),
                                                                                                                Column(
                                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                  children: [
                                                                                                                    Text(coin['namavoucher'] ?? '', style: heading3(FontWeight.w600, bnw900, 'Outfit')),
                                                                                                                    Text(FormatCurrency.convertToIdr(coin['price']), style: heading3(FontWeight.w400, bnw900, 'Outfit')),
                                                                                                                    Text(coin['typeproducts'] ?? '', style: heading4(FontWeight.w400, bnw500, 'Outfit')),
                                                                                                                  ],
                                                                                                                ),
                                                                                                                Spacer(),
                                                                                                                Column(
                                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                  children: [
                                                                                                                    Text('Jumlah', style: heading3(FontWeight.w400, bnw900, 'Outfit')),
                                                                                                                    SizedBox(height: size8),
                                                                                                                    Row(
                                                                                                                      children: [
                                                                                                                        GestureDetector(
                                                                                                                          onTap: () {
                                                                                                                            if (counterCart > 1) {
                                                                                                                              counterCart--;
                                                                                                                              conCounterPreview.text = counterCart.toString();
                                                                                                                            }
                                                                                                                            setState(() {});
                                                                                                                          },
                                                                                                                          child: buttonMoutlineColor(
                                                                                                                            Icon(
                                                                                                                              PhosphorIcons.minus,
                                                                                                                              color: primary500,
                                                                                                                              size: size24,
                                                                                                                            ),
                                                                                                                            primary500,
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        SizedBox(width: size8),
                                                                                                                        SizedBox(
                                                                                                                          height: size48,
                                                                                                                          width: size56,
                                                                                                                          child: TextFormField(
                                                                                                                            enabled: true,
                                                                                                                            controller: conCounterPreview,
                                                                                                                            keyboardType: TextInputType.number,
                                                                                                                            onChanged: (value) {
                                                                                                                              setState(() {
                                                                                                                                int parsedValue = int.tryParse(value) ?? 0;
                                                                                                                                counterCart = parsedValue;
                                                                                                                                conCounterPreview.text = counterCart.toString();
                                                                                                                              });
                                                                                                                            },
                                                                                                                            textAlign: TextAlign.center,
                                                                                                                            decoration: InputDecoration(
                                                                                                                              // alignLabelWithHint: true,
                                                                                                                              hintText: counterCart.toString(),

                                                                                                                              // .toString(),
                                                                                                                              // _itemCount.toString(),
                                                                                                                              hintStyle: heading4(FontWeight.w600, bnw800, 'Outfit'),
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        SizedBox(width: size8),
                                                                                                                        GestureDetector(
                                                                                                                          onTap: () {
                                                                                                                            counterCart++;
                                                                                                                            conCounterPreview.text = counterCart.toString();
                                                                                                                            setState(() {});
                                                                                                                          },
                                                                                                                          child: buttonMoutlineColor(
                                                                                                                            Icon(
                                                                                                                              PhosphorIcons.plus,
                                                                                                                              color: primary500,
                                                                                                                              size: size24,
                                                                                                                            ),
                                                                                                                            primary500,
                                                                                                                            // 50,
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                  ],
                                                                                                                )
                                                                                                              ],
                                                                                                            ),
                                                                                                          ],
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  )),
                                                                                              SizedBox(height: size16),
                                                                                              Container(
                                                                                                child: Column(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      'Catatan',
                                                                                                      style: body1(FontWeight.w500, bnw900, 'Outfit'),
                                                                                                    ),
                                                                                                    IntrinsicHeight(
                                                                                                      child: TextFormField(
                                                                                                        // keyboardType: numberNo,
                                                                                                        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                                                                                                        controller: conCatatanPreview,
                                                                                                        onChanged: (value) {
                                                                                                          // String formattedValue = formatCurrency(value);
                                                                                                          // conHarga.value = TextEditingValue(
                                                                                                          //   text: formattedValue,
                                                                                                          //   selection:
                                                                                                          //       TextSelection.collapsed(offset: formattedValue.length),
                                                                                                          // );
                                                                                                        },
                                                                                                        decoration: InputDecoration(
                                                                                                          isDense: true,
                                                                                                          contentPadding: EdgeInsets.symmetric(vertical: size12),
                                                                                                          enabledBorder: UnderlineInputBorder(
                                                                                                            borderSide: BorderSide(
                                                                                                              width: 1.5,
                                                                                                              color: bnw500,
                                                                                                            ),
                                                                                                          ),
                                                                                                          hintText: 'Cth : Tambah ekstra topping Boba dan Gula 2 sendok',
                                                                                                          hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: size32),
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: GestureDetector(
                                                                                                onTap: () {
                                                                                                  setState(() {});
                                                                                                  Navigator.pop(context);
                                                                                                },
                                                                                                child: buttonXLoutline(
                                                                                                    Center(
                                                                                                      child: Text(
                                                                                                        'Batalkan',
                                                                                                        style: heading3(FontWeight.w600, primary500, 'Outfit'),
                                                                                                      ),
                                                                                                    ),
                                                                                                    MediaQuery.of(context).size.width,
                                                                                                    primary500),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(width: size16),
                                                                                            Expanded(
                                                                                                child: GestureDetector(
                                                                                              onTap: () {
                                                                                                setState(() {
                                                                                                  String productId = coin['voucherid'];

                                                                                                  if (cartProductIds.contains(productId)) {
                                                                                                    cartProductIds.remove(productId);

                                                                                                    for (int index = 0; index < cart.length; index++) {
                                                                                                      if (cart[index].productid == productId) {
                                                                                                        cart.removeAt(index);
                                                                                                        cartMap.removeAt(index);
                                                                                                        total.removeAt(index);
                                                                                                        if (cart.isEmpty) {
                                                                                                          sumTotal = 0;
                                                                                                        }
                                                                                                        break;
                                                                                                      }
                                                                                                    }

                                                                                                    isItemAdded = true;
                                                                                                  } else {
                                                                                                    cartProductIds.add(productId);
                                                                                                    isItemAdded = false;
                                                                                                  }

                                                                                                  if (!isItemAdded) {
                                                                                                    Navigator.pop(context);
                                                                                                    Map<String, String> map1 = {};
                                                                                                    map1['name'] = coin['namavoucher'];
                                                                                                    map1['productid'] = coin['voucherid'];
                                                                                                    // map1['quantity'] = '1';
                                                                                                    map1['quantity'] = counterCart.toString();

                                                                                                    map1['image'] = coin['product_image'];
                                                                                                    map1['amount'] = (coin['price'] * counterCart).toString();
                                                                                                    map1['description'] = conCatatanPreview.text;

                                                                                                    cartMap.add(map1);

                                                                                                    // log(datasTransaksi![i].product_image.toString());

                                                                                                    String name = coin['namavoucher'].trim();
                                                                                                    String productid = coin['voucherid'].toString().trim();
                                                                                                    String image = coin['product_image'].toString().trim();
                                                                                                    // String desc = conCatatan[i]
                                                                                                    //     .text
                                                                                                    //     .toString()
                                                                                                    //     .trim();

                                                                                                    int? price = (coin['price']);

                                                                                                    int index = 0;
                                                                                                    for (index; index < cart.length; index++) {}

                                                                                                    // int? quantity = cart[i];

                                                                                                    // log(name.toString());
                                                                                                    // log(price.toString());
                                                                                                    // log(productid.toString());
                                                                                                    // log(image.toString());

                                                                                                    sumTotal = sumTotal + (price! * counterCart);
                                                                                                    // subTotal =
                                                                                                    //     subTotal + price.toInt();
                                                                                                    total.add(price * counterCart);
                                                                                                    conCatatan.add(
                                                                                                      TextEditingController(
                                                                                                        text: conCatatanPreview.text,
                                                                                                      ),
                                                                                                    );
                                                                                                    cart.add(
                                                                                                      CartTransaksi(
                                                                                                        name: name,
                                                                                                        productid: productid,
                                                                                                        image: image,
                                                                                                        price: price,
                                                                                                        quantity: counterCart,
                                                                                                        desc: conCatatanPreview.text,
                                                                                                        // quantity: cart[i]
                                                                                                        //     .quantity
                                                                                                        //     .toInt(),
                                                                                                      ),
                                                                                                    );
                                                                                                    // for (int i = 0; i <= cart.length; i++) {
                                                                                                    //   conCatatan.add(
                                                                                                    //     TextEditingController(
                                                                                                    //       text: conCatatanPreview.text,
                                                                                                    //     ),
                                                                                                    //   );
                                                                                                    //   inputValues.add(conCatatanPreview.text);
                                                                                                    //   setState(() {});
                                                                                                    //   initState();
                                                                                                    // }

                                                                                                    refreshColor();

                                                                                                    num totalku = 0;
                                                                                                    cartMap.forEach((element) {
                                                                                                      var myelement = int.parse(element['amount']!);
                                                                                                      totalku = totalku + (myelement * counterCart);
                                                                                                    });

                                                                                                    sumTotal = totalku;

                                                                                                    selectedIndexTransaksi[i];
                                                                                                  } else {
                                                                                                    // isItemAdded = false;
                                                                                                    // cartProductIds.remove(productSelect);
                                                                                                  }
                                                                                                });

                                                                                                initState();
                                                                                              },
                                                                                              child: buttonXL(
                                                                                                Center(
                                                                                                  child: Text(
                                                                                                    'Tambah Ke Keranjang',
                                                                                                    style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                                                                                                  ),
                                                                                                ),
                                                                                                MediaQuery.of(context).size.width,
                                                                                              ),
                                                                                            )),
                                                                                          ],
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          );
                                                                        }

                                                                        setState(
                                                                            () {});
                                                                        initState();
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            EdgeInsets.all(size8),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: cartProductIds.contains(snapshot.data[i]['voucherid'].toString())
                                                                              ? primary100
                                                                              : bnw100,
                                                                          borderRadius:
                                                                              BorderRadius.circular(size12),
                                                                          border:
                                                                              Border.all(
                                                                            // color: bnw900,
                                                                            color: cartProductIds.contains(snapshot.data[i]['voucherid'].toString())
                                                                                ? primary500
                                                                                : bnw300,
                                                                            width:
                                                                                2,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 3,
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(size8),
                                                                                child: SizedBox(
                                                                                  height: double.infinity / 2,
                                                                                  width: double.infinity,
                                                                                  child: snapshot.data![i]['product_image'] != null
                                                                                      ? ClipRRect(
                                                                                          borderRadius: BorderRadius.circular(size8),
                                                                                          child: Image.network(
                                                                                            snapshot.data![i]['product_image'].toString(),
                                                                                            height: size48,
                                                                                            width: size48,
                                                                                            fit: BoxFit.cover,
                                                                                            loadingBuilder: (context, child, loadingProgress) {
                                                                                              if (loadingProgress == null) {
                                                                                                return child;
                                                                                              }

                                                                                              return Center(child: loading());
                                                                                            },
                                                                                            errorBuilder: (context, error, stackTrace) => Icon(
                                                                                              PhosphorIcons.tag_fill,
                                                                                              color: bnw900,
                                                                                              size: 100,
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                      : Icon(
                                                                                          PhosphorIcons.tag_fill,
                                                                                          color: bnw900,
                                                                                          size: 100,
                                                                                        ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: SizedBox(
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(snapshot.data![i]['namavoucher'] ?? '', style: heading4(FontWeight.w700, bnw900, 'Outfit')),
                                                                                    Text(snapshot.data![i]['point'].toString(), style: body1(FontWeight.w400, bnw900, 'Outfit')),
                                                                                    Text(
                                                                                        FormatCurrency.convertToIdr(
                                                                                          snapshot.data![i]['price'],
                                                                                        ),
                                                                                        style: body1(FontWeight.w400, bnw900, 'Outfit')),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                return SizedBox();
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Text('2'),
                                    Text('3'),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(size8, size16, size16, size16),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(color: bnw300),
              borderRadius: BorderRadius.circular(size16),
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: size16),
                  height: 80,
                  width: width4,
                  decoration: BoxDecoration(
                      color: bnw300,
                      borderRadius: BorderRadius.circular(size8)),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: size16, bottom: size16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Keranjang',
                              style:
                                  heading1(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                            SizedBox(
                              width: 70,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isExpand = !isExpand;
                                      });
                                    },
                                    child: Icon(
                                        PhosphorIcons.frame_corners_fill,
                                        color: bnw900,
                                        size: 26),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showBottomPilihan(
                                        context,
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                    'Yakin Ingin Menghapus Semua?',
                                                    style: heading1(
                                                        FontWeight.w600,
                                                        bnw900,
                                                        'Outfit')),
                                                SizedBox(height: size16),
                                                Text('semua data akan terhapus',
                                                    style: heading2(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit')),
                                                SizedBox(height: size16),
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
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    },
                                                    child: buttonXLoutline(
                                                        Center(
                                                          child: Text(
                                                            'Batal',
                                                            style: heading3(
                                                                FontWeight.w600,
                                                                primary500,
                                                                'Outfit'),
                                                          ),
                                                        ),
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                        primary500),
                                                  ),
                                                ),
                                                SizedBox(width: size16),
                                                Consumer<RefreshTampilan>(
                                                  builder:
                                                      (context, value, child) =>
                                                          Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        cart.clear();
                                                        cartMap.clear();
                                                        _pageController
                                                            .jumpTo(0);

                                                        isItemAdded = false;

                                                        // int newtotal = 0;
                                                        // for (var element in cartMap) {
                                                        //   // var myelement = int.parse(
                                                        //   //     element['amount']!);
                                                        //   var myelement = 0;

                                                        //   newtotal =
                                                        //       newtotal + myelement;
                                                        // }

                                                        total = [];
                                                        subTotal = 0;
                                                        sumTotal = 0;
                                                        pelangganName = '';
                                                        pelangganId = '';

                                                        value.namaPelanggan =
                                                            '';
                                                        value.idPelanggan = '';

                                                        namaCustomerCalculate =
                                                            // '';

                                                            refreshColor();
                                                        cartProductIds.clear();
                                                        conCatatan.clear();
                                                        conCounterPreview
                                                            .clear();
                                                        Navigator.pop(context);
                                                        setState(() {});
                                                      },
                                                      child: buttonXL(
                                                        Center(
                                                          child: Text(
                                                            'Iya, Hapus',
                                                            style: heading3(
                                                                FontWeight.w600,
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
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                      setState(() {});
                                    },
                                    child: Icon(PhosphorIcons.trash_fill,
                                        color: red500, size: 26),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<RefreshTampilan>(
                        builder: (context, value, child) => SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              pilihPembeliShowBottom(context, 5);
                            },
                            child: buttonL(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                      value.namaPelanggan == ''
                                          ? PhosphorIcons.users_three
                                          : PhosphorIcons.users_three_fill,
                                      color: value.namaPelanggan == ''
                                          ? bnw900
                                          : primary500,
                                      size: size24),
                                  SizedBox(width: size16),
                                  value.namaPelanggan != ''
                                      ? Expanded(
                                          child: SizedBox(
                                            child: Text(
                                              value.namaPelanggan == ''
                                                  ? 'Pilih Pembeli'
                                                  : value.namaPelanggan
                                                      .toString(),
                                              textAlign: TextAlign.start,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: heading4(
                                                FontWeight.w400,
                                                value.namaPelanggan == ''
                                                    ? bnw900
                                                    : primary500,
                                                'Outfit',
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          child: Text(
                                            'Pilih Pembeli',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: heading4(
                                              FontWeight.w400,
                                              value.namaPelanggan == ''
                                                  ? bnw900
                                                  : primary500,
                                              'Outfit',
                                            ),
                                          ),
                                        ),

                                  // SizedBox(width: size16),
                                  value.namaPelanggan != ''
                                      ? GestureDetector(
                                          onTap: () {
                                            pelangganId = '';
                                            value.namaPelanggan = '';
                                            value.idPelanggan = '';
                                            value.notifyListeners();
                                            setState(() {});
                                          },
                                          child: Icon(PhosphorIcons.x,
                                              color: primary500, size: size24),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                              value.namaPelanggan == '' ? bnw100 : primary100,
                              value.namaPelanggan == '' ? bnw300 : primary500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size16),
                      cart.isEmpty
                          ? Expanded(
                              child: Center(
                                child: Text(
                                  'Belum ada produk terpilih',
                                  style: heading4(
                                      FontWeight.w500, bnw900, 'Outfit'),
                                ),
                              ),
                            )
                          : Expanded(
                              child: Center(
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  // shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: cart.length,
                                  itemBuilder: (context, i) {
                                    var sum = total.reduce(
                                        (value, element) => value + element);
                                    sumTotal = sum;

                                    return GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: size8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              child: Row(
                                                children: [
                                                  cart[i].image != null
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      size8),
                                                          child: Image.network(
                                                            cart[i]
                                                                .image
                                                                .toString(),
                                                            height: size48,
                                                            width: size48,
                                                            fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null) {
                                                                return child;
                                                              }

                                                              return Center(
                                                                  child:
                                                                      loading());
                                                            },
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                SizedBox(
                                                              // height: 227,
                                                              // width: 227,
                                                              child: SvgPicture
                                                                  .asset(
                                                                      'assets/logoProduct.svg'),
                                                            ),
                                                          ),
                                                        )
                                                      : Icon(
                                                          PhosphorIcons.image),
                                                  SizedBox(width: size8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        cart[i].name!,
                                                        style: body1(
                                                          FontWeight.w600,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                      Text(
                                                        FormatCurrency
                                                            .convertToIdr(
                                                                cart[i].price),
                                                        style: body1(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Flexible(
                                                    flex: 4,
                                                    child: Container(
                                                      height: 38,
                                                      child: TextFormField(
                                                        controller:
                                                            conCatatan[i],
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            cart[i].desc =
                                                                newValue;
                                                            cartMap[i][
                                                                    'description'] =
                                                                newValue;
                                                          });
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: true,
                                                          hintText: 'Catatan',
                                                          hintStyle: heading4(
                                                              FontWeight.w400,
                                                              bnw500,
                                                              'Outfit'),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: size16),
                                                  GestureDetector(
                                                    child: buttonMoutlineColor(
                                                      Icon(
                                                        PhosphorIcons.minus,
                                                        color: primary500,
                                                        size: size24,
                                                      ),
                                                      primary500,
                                                    ),
                                                    onTap: () {
                                                      cart[i].quantity--;

                                                      num newquantity =
                                                          cart[i].quantity;
                                                      cartMap[i]['quantity'] =
                                                          newquantity
                                                              .toString();
                                                      cartMap[i]['amount'] =
                                                          (cart[i].price!)
                                                              .toString();

                                                      // Update the total list
                                                      total[i] = newquantity *
                                                          cart[i].price!;

                                                      // Recalculate sumTotal
                                                      sumTotal = total.reduce(
                                                          (a, b) => a + b);

                                                      if (cart[i].quantity <
                                                          1) {
                                                        // Remove the item from the lists
                                                        cart.removeAt(i);
                                                        cartMap.removeAt(i);
                                                        total.removeAt(i);
                                                        conCatatan.removeAt(i);

                                                        // Clear some variables
                                                        conCounterPreview
                                                            .clear();
                                                        conCatatanPreview.text =
                                                            '';

                                                        // Remove the product ID
                                                        cartProductIds
                                                            .removeAt(i);

                                                        // Reset flags or variables
                                                        isItemAdded = false;
                                                      }

                                                      refreshColor();

                                                      setState(() {});
                                                    },
                                                  ),
                                                  SizedBox(width: size8),
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 38,
                                                      child: TextFormField(
                                                        enabled: false,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            InputDecoration(
                                                          // alignLabelWithHint: true,
                                                          hintText: cart[i]
                                                              .quantity
                                                              .toString(),
                                                          // _itemCount.toString(),
                                                          hintStyle: heading4(
                                                              FontWeight.w600,
                                                              bnw800,
                                                              'Outfit'),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: size8),
                                                  GestureDetector(
                                                    onTap: () {
                                                      cart[i].quantity++;

                                                      num newquantity =
                                                          cart[i].quantity;
                                                      cartMap[i]['quantity'] =
                                                          newquantity
                                                              .toString();
                                                      cartMap[i]['amount'] =
                                                          (cart[i].price!)
                                                              .toString();

                                                      // Update the total list
                                                      total[i] = newquantity *
                                                          cart[i].price!;

                                                      // Recalculate sumTotal
                                                      sumTotal = total.reduce(
                                                          (a, b) => a + b);

                                                      // No need to check if the quantity is less than 1

                                                      refreshColor();

                                                      setState(() {});
                                                    },
                                                    child: buttonMoutlineColor(
                                                      Icon(
                                                        PhosphorIcons.plus,
                                                        color: primary500,
                                                        size: size24,
                                                      ),
                                                      primary500,
                                                      // 50,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                      cart.isEmpty ? Spacer() : SizedBox(),
                      Column(
                        children: [
                          cart.isEmpty && cartMap.isEmpty
                              ? Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 1,
                                      color: bnw900,
                                    ),
                                    SizedBox(height: size16),
                                  ],
                                )
                              : SizedBox(),

                          cart.isEmpty && cartMap.isEmpty
                              ? SizedBox()
                              : Column(
                                  children: [
                                    SizedBox(height: size16),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size16),
                                      decoration: BoxDecoration(
                                          border: Border(
                                        top:
                                            BorderSide(color: bnw900, width: 1),
                                      )),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Sub Total',
                                            style: heading3(FontWeight.w600,
                                                bnw900, 'Outfit'),
                                          ),
                                          Text(
                                            FormatCurrency.convertToIdr(
                                                sumTotal),
                                            style: heading3(FontWeight.w600,
                                                bnw900, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _pageController.jumpToPage(4);
                                    setState(() {});
                                  },
                                  child: buttonXLoutline(
                                    Center(
                                      child: Text(
                                        'Daftar Tagihan',
                                        style: heading3(
                                            FontWeight.w600, bnw900, 'Outfit'),
                                      ),
                                    ),
                                    MediaQuery.of(context).size.width,
                                    bnw300,
                                  ),
                                ),
                              ),
                              cart.isEmpty && cartMap.isEmpty
                                  ? SizedBox()
                                  : SizedBox(width: size16),
                              cart.isEmpty && cartMap.isEmpty
                                  ? SizedBox()
                                  : GestureDetector(
                                      onTap: () {
                                        createTransaction(
                                          context,
                                          widget.token,
                                          '',
                                          cartMap,
                                          _pageController,
                                          cart,
                                          setState,
                                          '',
                                          '',
                                          '',
                                          pelangganId,
                                        );

                                        cart.clear();
                                        cartMap.clear();
                                        sumTotal = 0;
                                        cartProductIds.clear();
                                        total = [];
                                        subTotal = 0;

                                        refreshColor();

                                        cartProductIds.clear();
                                        conCatatan.clear();
                                        conCounterPreview.clear();

                                        setState(() {});
                                      },
                                      child: buttonXLoutline(
                                        Center(
                                          child: Text(
                                            'Simpan',
                                            style: heading3(FontWeight.w600,
                                                bnw900, 'Outfit'),
                                          ),
                                        ),
                                        MediaQuery.of(context).size.width,
                                        bnw300,
                                      ),
                                    ),
                            ],
                          ),
                          cart.isNotEmpty && cartMap.isNotEmpty
                              ? SizedBox(height: size16)
                              : SizedBox(),

                          cart.isNotEmpty && cartMap.isNotEmpty
                              ? GestureDetector(
                                  onTap: () async {
                                    // log(conCatatan.toList().toString());
                                    String typePrice = "price";
                                    if (tapTrue == 1) {
                                      typePrice = "price";
                                    } else if (typePrice == 2) {
                                      typePrice = "price_online_shop    ";
                                    }
                                    print(tapTrue);
                                    print(cartMap.toString());

                                    await calculateTransaction(
                                            context,
                                            widget.token,
                                            cartMap,
                                            setState,
                                            pelangganId,
                                            typePrice,
                                            '')
                                        .then((value) {
                                      if (cartMap.isNotEmpty && value == '00') {
                                        _pageController.nextPage(
                                            duration:
                                                Duration(milliseconds: 10),
                                            curve: Curves.ease);
                                      }
                                    });

                                    setState(() {});
                                  },
                                  child: buttonXXL(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          PhosphorIcons.wallet_fill,
                                          color: bnw100,
                                          size: size32,
                                        ),
                                        SizedBox(width: size16),
                                        Text(
                                          'Pilih Pembayaran',
                                          style: heading2(FontWeight.w600,
                                              bnw100, 'Outfit'),
                                        )
                                      ],
                                    ),
                                    // cartMap.isEmpty ? bnw100 : primary500,
                                    double.infinity,
                                  ))
                              : SizedBox(),
                          //  SizedBox(height: size16),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<dynamic> showPriviewCart(BuildContext context, int i) {
    conCounterPreview.text = '1';
    conCatatanPreview.text = '';

    tapTrue = 1;

    return showModalBottomSheet(
      useRootNavigator: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size16),
      ),
      context: context,
      builder: (context) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: ShapeDecoration(
            color: bnw100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size16),
                topRight: Radius.circular(size16),
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  dividerShowdialog(),
                  SingleChildScrollView(
                    child: StatefulBuilder(
                      builder: (context, setState) => Column(
                        children: [
                          SizedBox(height: size16),
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(size12),
                                  border: Border.all(color: bnw300)),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(size8),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: size120,
                                              width: size120,
                                              child: Image.network(
                                                datasTransaksi![i]
                                                    .product_image
                                                    .toString(),
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }

                                                  return Center(
                                                      child: loading());
                                                },
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                  // height: size64,
                                                  // width: size64,
                                                  child: SvgPicture.asset(
                                                    'assets/logoProduct.svg',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: size12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    datasTransaksi![i].name ??
                                                        '',
                                                    style: heading3(
                                                        FontWeight.w600,
                                                        bnw900,
                                                        'Outfit')),
                                                Text(
                                                    FormatCurrency.convertToIdr(
                                                        tapTrue == 1
                                                            ? datasTransaksi![i]
                                                                .price_after
                                                            : datasTransaksi![i]
                                                                .price_online_shop_after),
                                                    style: heading3(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit')),
                                                Text(
                                                    datasTransaksi![i]
                                                            .typeproducts ??
                                                        '',
                                                    style: heading4(
                                                        FontWeight.w400,
                                                        bnw500,
                                                        'Outfit')),
                                              ],
                                            ),
                                            Spacer(),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('Jumlah',
                                                    style: body1(
                                                        FontWeight.w500,
                                                        bnw900,
                                                        'Outfit')),
                                                SizedBox(height: size8),
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (counterCart > 1) {
                                                          counterCart--;
                                                          conCounterPreview
                                                                  .text =
                                                              counterCart
                                                                  .toString();
                                                        }
                                                        setState(() {});
                                                      },
                                                      child:
                                                          buttonMoutlineColor(
                                                        Icon(
                                                          PhosphorIcons.minus,
                                                          color: primary500,
                                                          size: size24,
                                                        ),
                                                        primary500,
                                                      ),
                                                    ),
                                                    SizedBox(width: size8),
                                                    SizedBox(
                                                      height: size48,
                                                      width: size56,
                                                      child: TextFormField(
                                                        enabled: true,
                                                        controller:
                                                            conCounterPreview,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            int parsedValue =
                                                                int.tryParse(
                                                                        value) ??
                                                                    0;
                                                            counterCart =
                                                                parsedValue;
                                                            conCounterPreview
                                                                    .text =
                                                                counterCart
                                                                    .toString();
                                                          });
                                                        },
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            InputDecoration(
                                                          // alignLabelWithHint: true,
                                                          hintText: counterCart
                                                              .toString(),

                                                          // .toString(),
                                                          // _itemCount.toString(),
                                                          hintStyle: heading4(
                                                              FontWeight.w600,
                                                              bnw800,
                                                              'Outfit'),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: size8),
                                                    GestureDetector(
                                                      onTap: () {
                                                        counterCart++;
                                                        conCounterPreview.text =
                                                            counterCart
                                                                .toString();
                                                        setState(() {});
                                                      },
                                                      child:
                                                          buttonMoutlineColor(
                                                        Icon(
                                                          PhosphorIcons.plus,
                                                          color: primary500,
                                                          size: size24,
                                                        ),
                                                        primary500,
                                                        // 50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          SizedBox(height: size16),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Varian Harga',
                                  style:
                                      body1(FontWeight.w500, bnw900, 'Outfit'),
                                ),
                                SizedBox(height: size16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            tapTrue = 1;
                                          });
                                        },
                                        child: IntrinsicWidth(
                                          child: Container(
                                            height: size56,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: size20),
                                            decoration: ShapeDecoration(
                                              color: tapTrue == 1
                                                  ? primary100
                                                  : bnw100,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: width2,
                                                  color: tapTrue == 1
                                                      ? primary500
                                                      : bnw300,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size8),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('Normal',
                                                    style: heading3(
                                                        FontWeight.w400,
                                                        tapTrue == 1
                                                            ? primary500
                                                            : bnw900,
                                                        'Outfit')),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: size16),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            tapTrue = 2;
                                          });
                                        },
                                        child: IntrinsicWidth(
                                          child: Container(
                                            height: size56,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: size20),
                                            decoration: ShapeDecoration(
                                              color: tapTrue == 2
                                                  ? primary100
                                                  : bnw100,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: width2,
                                                  color: tapTrue == 2
                                                      ? primary500
                                                      : bnw300,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size8),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('Online',
                                                    style: heading3(
                                                        FontWeight.w400,
                                                        tapTrue == 2
                                                            ? primary500
                                                            : bnw900,
                                                        'Outfit')),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size16),
                                Text(
                                  'Catatan',
                                  style:
                                      body1(FontWeight.w500, bnw900, 'Outfit'),
                                ),
                                IntrinsicHeight(
                                  child: TextFormField(
                                    // keyboardType: numberNo,
                                    style: heading2(
                                        FontWeight.w600, bnw900, 'Outfit'),
                                    controller: conCatatanPreview,
                                    onChanged: (value) {
                                      // String formattedValue = formatCurrency(value);
                                      // conHarga.value = TextEditingValue(
                                      //   text: formattedValue,
                                      //   selection:
                                      //       TextSelection.collapsed(offset: formattedValue.length),
                                      // );
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: size12),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 1.5,
                                          color: bnw500,
                                        ),
                                      ),
                                      hintText:
                                          'Cth : Tambah ekstra topping Boba dan Gula 2 sendok',
                                      hintStyle: heading2(
                                          FontWeight.w600, bnw500, 'Outfit'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: buttonXLoutline(
                              Center(
                                child: Text(
                                  'Batalkan',
                                  style: heading3(
                                      FontWeight.w600, primary500, 'Outfit'),
                                ),
                              ),
                              MediaQuery.of(context).size.width,
                              primary500),
                        ),
                      ),
                      SizedBox(width: size16),
                      Expanded(
                          child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (tapTrue == 0) {
                              tapTrue = 1;
                            }
                            String productId =
                                datasTransaksi![i].productid.toString();

                            if (cartProductIds.contains(productId)) {
                              cartProductIds.remove(productId);

                              for (int index = 0;
                                  index < cart.length;
                                  index++) {
                                if (cart[index].productid == productId) {
                                  cart.removeAt(index);
                                  cartMap.removeAt(index);
                                  total.removeAt(index);
                                  if (cart.isEmpty) {
                                    sumTotal = 0;
                                  }
                                  break;
                                }
                              }

                              isItemAdded = true;
                            } else {
                              cartProductIds.add(productId);
                              isItemAdded = false;
                            }

                            if (!isItemAdded) {
                              Navigator.pop(context);
                              Map<String, String> map1 = {};
                              map1['name'] = datasTransaksi![i].name.toString();
                              map1['productid'] =
                                  datasTransaksi![i].productid.toString();
                              // map1['quantity'] = '1';
                              map1['quantity'] = counterCart.toString();

                              map1['image'] =
                                  datasTransaksi![i].product_image.toString();
                              map1['amount'] =
//                                  (datasTransaksi![i].price! * counterCart)
                                  (tapTrue == 2
                                          ? datasTransaksi![i]
                                              .price_online_shop_after
                                          : datasTransaksi![i].price_after!)
                                      .toString();
                              map1['description'] = conCatatanPreview.text;

                              cartMap.add(map1);

                              // log(datasTransaksi![i].product_image.toString());

                              String name =
                                  datasTransaksi![i].name.toString().trim();
                              String productid = datasTransaksi![i]
                                  .productid
                                  .toString()
                                  .trim();
                              String image = datasTransaksi![i]
                                  .product_image
                                  .toString()
                                  .trim();
                              // String desc = conCatatan[i]
                              //     .text
                              //     .toString()
                              //     .trim();

                              //int? price = ( datasTransaksi![i].price!);
                              num? price = (tapTrue == 2
                                  ? datasTransaksi![i].price_online_shop_after!
                                  : datasTransaksi![i].price_after!);

                              int index = 0;
                              for (index; index < cart.length; index++) {}

                              // int? quantity = cart[i];

                              // log(name.toString());
                              // log(price.toString());
                              // log(productid.toString());
                              // log(image.toString());

                              sumTotal = sumTotal + (price * counterCart);
                              // subTotal =
                              //     subTotal + price.toInt();
                              total.add(price * counterCart);

                              conCatatan.add(
                                TextEditingController(
                                  text: conCatatanPreview.text,
                                ),
                              );

                              cart.add(
                                CartTransaksi(
                                  name: name,
                                  productid: productid,
                                  image: image,
                                  price: price,
                                  quantity: counterCart,
                                  desc: conCatatanPreview.text,
                                  // quantity: cart[i]
                                  //     .quantity
                                  //     .toInt(),
                                ),
                              );

                              // for (int i = 0; i <= cart.length; i++) {
                              //   conCatatan.add(
                              //     TextEditingController(
                              //       text: conCatatanPreview.text,
                              //     ),
                              //   );
                              //   inputValues.add(conCatatanPreview.text);
                              //   setState(() {});
                              //   //initState();
                              // }

                              refreshColor();

                              // int totalku = 0;
                              // cartMap.forEach((element) {
                              //   var myelement = int.parse(element['amount']!);
                              //   totalku = totalku + (myelement * counterCart);
                              // });

                              // sumTotal = totalku;

                              selectedIndexTransaksi[i];
                            } else {
                              // isItemAdded = false;
                              // cartProductIds.remove(productSelect);
                            }
                          });

                          //initState();
                        },
                        child: buttonXL(
                          Center(
                            child: Text(
                              'Tambah Ke Keranjang',
                              style:
                                  heading3(FontWeight.w600, bnw100, 'Outfit'),
                            ),
                          ),
                          MediaQuery.of(context).size.width,
                        ),
                      )),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> pilihPembeliShowBottom(BuildContext context, index) {
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size24),
      ),
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 2,
          padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(size16),
              topLeft: Radius.circular(size16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              dividerShowdialog(),
              SizedBox(height: size16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pilih Tipe Pembeli',
                      style: heading2(
                        FontWeight.w600,
                        bnw900,
                        'Outfit',
                      )),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(PhosphorIcons.x, color: bnw900, size: size32),
                  )
                ],
              ),
              SizedBox(height: size16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _pageController.jumpToPage(index);
                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.all(size16),
                          decoration: BoxDecoration(
                            border: Border.all(color: bnw300),
                            borderRadius: BorderRadius.circular(size16),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: SvgPicture.asset(
                                  'assets/newIllustration/OnBoarding1.svg',
                                ),
                              ),
                              SizedBox(height: size8),
                              Text('Pelanggan',
                                  style: heading2(
                                    FontWeight.w700,
                                    bnw900,
                                    'Outfit',
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          controllerPelangganName.text = '';
                          pelangganId = '';
                          showModalBottomSheet(
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder: (context, setState) => IntrinsicHeight(
                                child: Container(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: size16),
                                            Text(
                                              'Pilih Pembeli',
                                              style: heading1(FontWeight.w700,
                                                  bnw900, 'Outfit'),
                                            ),
                                            SizedBox(height: size16),
                                            Row(
                                              children: [
                                                Text(
                                                  'Nama Pembeli ',
                                                  style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                                Text(
                                                  '*',
                                                  style: heading4(
                                                      FontWeight.w400,
                                                      danger500,
                                                      'Outfit'),
                                                ),
                                              ],
                                            ),
                                            TextFormField(
                                              style: heading2(
                                                FontWeight.w600,
                                                bnw900,
                                                'Outfit',
                                              ),
                                              controller:
                                                  controllerPelangganName,
                                              onChanged: (value) {
                                                setState(() {});
                                              },
                                              decoration: InputDecoration(
                                                  focusColor: primary500,
                                                  hintText:
                                                      'Cth : Muhammad Nabil Musyaffa',
                                                  hintStyle: heading2(
                                                    FontWeight.w600,
                                                    bnw400,
                                                    'Outfit',
                                                  )),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: controllerPelangganName
                                                    .text.isNotEmpty
                                                ? size32
                                                : 0),
                                        controllerPelangganName.text.isNotEmpty
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        pelangganId = '';
                                                        Navigator.pop(context);
                                                        pilihPembeliShowBottom(
                                                            context, index);
                                                      },
                                                      child: buttonXLoutline(
                                                        Center(
                                                          child: Text(
                                                            'Batal',
                                                            style: heading3(
                                                                FontWeight.w600,
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
                                                    child: Consumer<
                                                        RefreshTampilan>(
                                                      builder: (context, value,
                                                              child) =>
                                                          GestureDetector(
                                                        onTap: () {
                                                          pelangganId =
                                                              controllerPelangganName
                                                                  .text;
                                                          value.namaPelanggan =
                                                              controllerPelangganName
                                                                  .text;
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {});
                                                          initState();
                                                        },
                                                        child: buttonXL(
                                                          Center(
                                                            child: Text(
                                                              'Simpan',
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
                                                  ),
                                                ],
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(size16),
                          decoration: BoxDecoration(
                            border: Border.all(color: bnw300),
                            borderRadius: BorderRadius.circular(size16),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: SvgPicture.asset(
                                  'assets/newIllustration/OnBoarding3.svg',
                                ),
                              ),
                              SizedBox(height: size8),
                              Text('Bukan Pelanggan',
                                  style: heading2(
                                    FontWeight.w700,
                                    bnw900,
                                    'Outfit',
                                  )),
                            ],
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
      },
    );
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  buttonWidget(String buttonText, TextEditingController pinBttn) {
    return Expanded(
      child: IntrinsicHeight(
        child: GestureDetector(
          onTap: () {
            if (pinBttn.text.length <= 30) {
              pinBttn.text = pinBttn.text + buttonText;
              // onChange(widget.pinController.text);
              (String pin) {
                pinBttn.text = pin;
                print('${pinBttn.text}');
                setState(() {});
              };
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: size20, horizontal: size8),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size8),
                side: BorderSide(
                  color: bnw900,
                  width: width2,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: Center(
              child: Text(
                buttonText,
                style: heading1(FontWeight.w700, bnw900, 'Outfit'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  iconButtonWidget(VoidCallback function) {
    return Expanded(
      child: IntrinsicHeight(
        child: GestureDetector(
          onTap: function,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: size20, horizontal: size8),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size8),
                side: BorderSide(
                  color: danger500,
                  width: width2,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: Center(
              child: Icon(
                PhosphorIcons.backspace_fill,
                size: 30,
                color: red500,
              ),
            ),
          ),
        ),
      ),
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
                                    orderByProductText.length,
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
                                          label: Text(orderByProductText[index],
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
                                print(valueOrderByProduct);
                                print(orderByProductText[valueOrderByProduct]);

                                textOrderBy =
                                    orderByProductText[valueOrderByProduct];
                                textvalueOrderBy =
                                    orderByProduct[valueOrderByProduct];
                                orderByProduct[valueOrderByProduct];
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

  List? typeproductList;
  List<dynamic>? searchResultListProduct;

  dynamic selectedProduct;
  bool isItemSelected = false;

  Future _getProductList() async {
    await http.post(Uri.parse(diskonTransaksiLink), body: {
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
      if (selectedProduct == product) {
        selectedProduct = null;
        isItemSelected = false;
      } else {
        selectedProduct = product;
        isItemSelected = true;
      }
    });
  }

  void selectDiscount(bool isSelected, int index, discId) {
    if (index >= 0 && index < selectedFlag.length) {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);

      if (selectedFlag[index] == true) {
        // Periksa apakah productId sudah ada di dalam listProduct sebelum menambahkannya
        if (!listToko.contains(discId)) {
          listToko.add(discId);
        }
      } else {
        // Hapus productId dari listProduct jika sudah ada
        listToko.remove(discId);
      }

      setState(() {});
    }
  }
}
