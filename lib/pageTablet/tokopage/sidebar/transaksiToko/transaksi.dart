// ignore_for_file: unrelated_type_equality_checks, unnecessary_new
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' as Io;
import 'dart:io';
import 'dart:typed_data';

import 'package:unipos_app_335/models/coaModel.dart';
import 'package:unipos_app_335/models/productVariantModel.dart';
import 'package:unipos_app_335/pageTablet/test/dashboardnew.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/produkToko/produk.dart';
import 'package:unipos_app_335/pagehelper/loginregis/daftar_akun_toko.dart';
import 'package:unipos_app_335/utils/component/providerModel/refreshTampilanModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../utils/component/component_loading.dart';
import 'package:unipos_app_335/models/keranjangModel.dart';
import 'package:unipos_app_335/models/tokoModel/transaksiTokoModel.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/transaksiToko/riwayatPageToko.dart';
import 'package:unipos_app_335/utils/printer/printerPage.dart';
import 'package:unipos_app_335/utils/component/skeletons.dart';
import 'package:provider/provider.dart';
import '../../../../utils/component/component_button.dart';

import '../../../../main.dart';
import '../../../../models/tokoModel/riwayatTransaksiTokoModel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';

import '../../../../utils/component/component_color.dart';
import '../../../../utils/component/component_orderBy.dart';
import '../../../../utils/component/component_showModalBottom.dart';
import '../../../../utils/component/component_size.dart';
import 'classKeypad.dart';
import 'classMetode.dart';
import 'pesananPage.dart';
import 'pilihPelangganFifaKoinPage.dart';
import 'pilihPelangganPage.dart';

List<CartTransaksi> cart = List.empty(growable: true);
List<Map<String, String>> cartMap = List.empty(growable: true);
List<Map<String, String>> cartMapBayar = List.empty(growable: true);

List<num> total = List.empty(growable: true);
List<TextEditingController> conCatatan = List.empty(growable: true);
List<String> cartProductIds = [];

num sumTotal = 0;
String? logoStruk = '', logoStrukPrinter = '';
String? logoQris = '';

class TransactionPage extends StatefulWidget {
  String token;
  TransactionPage({Key? key, required this.token}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with TickerProviderStateMixin {
  File? myImage;
  Uint8List? bytes;
  String? img64;
  List<String> images = [];
  late WebViewController webController;

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

  TextEditingController uangTunaiController = TextEditingController(
    text: 'Rp 0',
  );

  TextEditingController pinController = TextEditingController();
  TextEditingController kreditpinController = TextEditingController();
  TextEditingController debitpinController = TextEditingController();

  TextEditingController conCatatanPreview = TextEditingController();
  TextEditingController conCounterPreview = TextEditingController();

  String _selectedOption = "Grid";

  List<String> valueCoin = [''];
  List<String> inputValues = List.empty(growable: true);

  bool isItemAdded = false;
  // Set<String> cartProductIds = Set();
  num counterCart = 1;
  bool isExpand = false;
  int tapTrue = 0;

  String? discountId, discountIdFix, discountName = '', discountNameFix = '';

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

  late Future<List<PaymentMethod>> futurePaymentMethodsDebit;
  late Future<List<PaymentMethod>> futurePaymentMethodsKredit;
  late Future<List<PaymentMethod>> futurePaymentMethodsEWallet;
  String idpaymentmethode = '';

  @override
  void initState() {
    checkConnection(context);
    _getProductList();
    getQris(context, widget.token, '');
    getStruk(context, widget.token, '');
    getKulasedaya(context, widget.token, '');
    futurePaymentMethodsDebit = fetchPaymentMethods(widget.token, 'Debit');
    futurePaymentMethodsKredit = fetchPaymentMethods(widget.token, 'Kredit');
    futurePaymentMethodsEWallet = fetchPaymentMethods(widget.token, 'EWallet');

    if (isTagihan == true) {
      isTagihan = false;
      cart.clear();
      cartMap.clear();
      cartMapBayar.clear();

      isItemAdded = false;
      transactionidValue = "";
      total = [];
      subTotal = 0;
      sumTotal = 0;

      refreshColor();
      cartProductIds.clear();
      conCatatan.clear();
      conCounterPreview.clear();
    }

    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      List<String> value = [''];

      datasTransaksi = await getProductTransaksi(
        context,
        widget.token,
        searchController.text,
        value,
        textvalueOrderBy,
      );

      //getDataCoin('');

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
    });

    kreditpinController.addListener(formatInput);
    debitpinController.addListener(formatInput);
    uangTunaiController.addListener(formatInputRp);
    customProdukPrice.addListener(formatInputRpCustomProduk);

    super.initState();
  }

  Future<dynamic> getDataCoin(name) async {
    return coinTransaksi = await getCoinTransaksi(context, widget.token, name, [
      '',
    ]);
  }

  Timer? _debounce;

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(seconds: 2), () async {
      datasTransaksi = await getProductTransaksi(context, widget.token, value, [
        '',
      ], textvalueOrderBy);
      setState(() {});
    });
  }

  @override
  dispose() {
    _debounce?.cancel();
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
    cartMapBayar.clear();
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
    discountName = "";
    discountId = "";
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
    whenLoading(context);

    // 🧩 Langkah 1: buat map dasar (String-String) seperti biasa
    List<Map<String, String>> mapCalculate = List.empty(growable: true);

    for (var detail in details) {
      Map<String, String> map1 = {};
      map1['name'] = detail['name'] ?? '';
      map1['product_id'] = detail['product_id'] ?? '';
      map1['quantity'] = detail['quantity'] ?? '';
      map1['image'] = detail['image'] ?? '';
      map1['amount'] = detail['amount_display'] ?? detail['amount'] ?? '0';
      map1['description'] = detail['description'] ?? '';
      map1['id_request'] = detail['id_request'] ?? '';
      map1['is_online'] = (tapTrue == 2).toString(); // sementara string
      map1['variants'] = detail['variants'] ?? '[]'; // string JSON
      mapCalculate.add(map1);
    }

    // 🧩 Langkah 2: konversi ke format final (Map<String, dynamic>)
    // agar is_online jadi bool dan variants jadi array JSON
    List<Map<String, dynamic>> mapCalculateFinal = [];

    for (var item in mapCalculate) {
      mapCalculateFinal.add({
        "name": item['name'],
        "product_id": item['product_id'],
        "quantity": item['quantity'],
        "image": item['image'],
        "amount": item['amount'],
        "description": item['description'],
        "id_request": item['id_request'],
        "is_online": item['is_online'] == 'true', // ✅ ubah string ke bool
        "variants": jsonDecode(
          item['variants'] ?? '[]',
        ), // ✅ ubah string ke array JSON
      });
    }

    // 🧩 Kirim ke server
    final bodyJson = {
      "deviceid": identifier,
      "discount_id": discount ?? "",
      "member_id": memberid,
      "transaction_id": transactionid,
      "value": value,
      "payment_method": method,
      "payment_reference": reference,
      "detail": mapCalculateFinal,
    };

    log("Payload ke server: ${json.encode(bodyJson)}");
    log("Payload Detail $mapCalculateFinal");

    final response = await http.post(
      Uri.parse(createTransaksiUrl),
      headers: {"token": token, "Content-Type": "application/json"},
      body: json.encode(bodyJson),
    );

    var jsonResponse = json.decode(response.body);
    log("Response server: $jsonResponse");

    if (response.statusCode == 200) {
      closeLoading(context);
      print('✅ Transaksi berhasil');

      setState(() {
        printext = jsonResponse['data']['raw'];

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
                                'Kasir',
                                jsonResponse['data']['pic_name'] ?? '',
                              ),
                              SizedBox(height: size16),
                              dash(),
                              SizedBox(height: size16),
                              Text(
                                'Informasi Transaksi',
                                style: heading3(
                                  FontWeight.w600,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              SizedBox(height: size4),
                              pesananStruk(
                                'Nama Pembeli',
                                jsonResponse['data']['customer_name'] ?? '',
                              ),
                              SizedBox(height: size4),
                              pesananStruk(
                                'Waktu Transaksi',
                                jsonResponse['data']['entrydate'] ?? '',
                              ),
                              SizedBox(height: size4),
                              pesananStruk(
                                'Nomor Transaksi',
                                jsonResponse['data']['transactionid'] ?? '',
                              ),
                              SizedBox(height: size16),
                              dash(),
                            ],
                          ),
                          SizedBox(height: size16),
                          Text(
                            'Rincian Produk',
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
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
                                                cart[i].price!,
                                              ).toString(),
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
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: size16),
                          pesananStruk(
                            'Sub Total',
                            FormatCurrency.convertToIdr(subTotal).toString(),
                          ),
                          SizedBox(height: size16),
                          pesananStruk(
                            'Diskon',
                            FormatCurrency.convertToIdr(
                              jsonResponse['data']['discount'],
                            ).toString(),
                          ),
                          SizedBox(height: size16),
                          pesananStruk(
                            'PPN',
                            FormatCurrency.convertToIdr(
                              ppnTransaksi,
                            ).toString(),
                          ),
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
                                      style: heading4(
                                        FontWeight.w400,
                                        primary500,
                                        'Outfit',
                                      ),
                                    ),
                                    Text(
                                      FormatCurrency.convertToIdr(
                                        (jsonResponse['data']['change_money']
                                                is String)
                                            ? int.tryParse(
                                                    jsonResponse['data']['change_money'],
                                                  ) ??
                                                  0
                                            : (jsonResponse['data']['change_money'] ??
                                                  0),
                                      ).toString(),
                                      style: heading4(
                                        FontWeight.w400,
                                        primary500,
                                        'Outfit',
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(),
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
                                        FontWeight.w600,
                                        bnw100,
                                        'Outfit',
                                      ),
                                    ),
                                    SizedBox(width: size12),
                                    Icon(
                                      PhosphorIcons.printer_fill,
                                      color: bnw100,
                                    ),
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
                              cartMapBayar.clear();
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
                              debitpinController.clear();
                              kreditpinController.clear();

                              selectedIndex = 0;
                              selectedIndexDompetDigital = 0;
                              sessCode = generateSessCode(16);
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
                                    style: heading3(
                                      FontWeight.w600,
                                      primary500,
                                      'Outfit',
                                    ),
                                  ),
                                  SizedBox(width: size12),
                                  Icon(
                                    PhosphorIcons.notebook_fill,
                                    color: primary500,
                                  ),
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

      return jsonResponse['rc'];
    } else {
      closeLoading(context);
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageController.page!.round() == 0) {
          showModalBottomExit(context);
          return false;
        } else {
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

          _pageController.jumpToPage(0);
          _tabController!.animateTo(0);
          selectedIndex = 0;
          selectedIndexDompetDigital = 0;
          uangTunaiController.text = '0';
          return Future.value(false);
        }
      },
      child: Scaffold(
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
      ),
    );
  }

  Padding pengaturanPage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(size16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transaksi', style: heading1(FontWeight.w700, bnw900, 'Outfit')),
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
              indicatorSize: TabBarIndicatorSize.tab,
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
                Tab(text: 'Kasir'),
                Tab(text: 'Riwayat'),
                Tab(text: 'Pengaturan'),
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
                    child: Column(
                      children: [
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
                              style: heading2(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            Text(
                              logoQris != '' ? 'Terhubung' : 'Belum Terhubung',
                              style: heading4(
                                FontWeight.w400,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            SizedBox(height: size16),
                            SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () {
                                  getQris(context, widget.token, '').then((
                                    value,
                                  ) {
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
                                                  style: heading1(
                                                    FontWeight.w600,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                                SizedBox(height: size16),
                                                Container(
                                                  height: 200,
                                                  width: 200,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          size8,
                                                        ),
                                                    border: Border.all(
                                                      color: bnw300,
                                                    ),
                                                  ),
                                                  child: logoQris == ''
                                                      ? Icon(PhosphorIcons.plus)
                                                      : ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                size8,
                                                              ),
                                                          child: Image.network(
                                                            logoQris ?? '',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    await getImage().then(
                                                      (value) =>
                                                          uploadQris(
                                                            context,
                                                            widget.token,
                                                            img64,
                                                            '',
                                                          ).then((value) {
                                                            // Navigator.pop(context);
                                                          }),
                                                    );
                                                    setState(() {});
                                                    // initState();
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
                                                        focusedBorder:
                                                            UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    width: 2,
                                                                    color:
                                                                        primary500,
                                                                  ),
                                                            ),
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                              vertical: size16,
                                                            ),
                                                        isDense: true,
                                                        focusColor: primary500,
                                                        prefixIcon: Icon(
                                                          size: size24,
                                                          logoQris != ''
                                                              ? PhosphorIcons
                                                                    .pencil_line
                                                              : PhosphorIcons
                                                                    .plus,
                                                          color: bnw900,
                                                        ),
                                                        hintText: logoQris != ''
                                                            ? 'Ganti QRIS'
                                                            : 'Tambah QRIS',
                                                        hintStyle: heading3(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
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
                                                            cursorColor:
                                                                primary500,
                                                            enabled: false,
                                                            style: heading3(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit',
                                                            ),
                                                            decoration: InputDecoration(
                                                              focusedBorder:
                                                                  UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                          width:
                                                                              2,
                                                                          color:
                                                                              primary500,
                                                                        ),
                                                                  ),
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
                                                                    'Outfit',
                                                                  ),
                                                            ),
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
                                            Icon(
                                              PhosphorIcons.pencil_line,
                                              color: bnw100,
                                              size: size24,
                                            ),
                                            SizedBox(width: size12),
                                            Text(
                                              'Tambah QRIS',
                                              style: heading3(
                                                FontWeight.w600,
                                                bnw100,
                                                'Outfit',
                                              ),
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
                                              PhosphorIcons.pencil_line,
                                              color: primary500,
                                              size: size24,
                                            ),
                                            SizedBox(width: size12),
                                            Text(
                                              'Atur QRIS',
                                              style: heading3(
                                                FontWeight.w600,
                                                primary500,
                                                'Outfit',
                                              ),
                                            ),
                                          ],
                                        ),
                                        0,
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
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(size12),
                            height: double.infinity,
                            width: double.infinity,
                            child: SvgPicture.asset('assets/logoStruk.svg'),
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
                              style: heading2(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            Text(
                              logoStruk == '' ? 'Belum Terhubung' : 'Terhubung',
                              style: heading4(
                                FontWeight.w400,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            SizedBox(height: size16),
                            SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () {
                                  getStruk(context, widget.token, '').then((
                                    value,
                                  ) {
                                    value == '00'
                                        ? showBottomPilihan(
                                            context,
                                            Column(
                                              children: [
                                                Text(
                                                  'Logo Struk',
                                                  style: heading1(
                                                    FontWeight.w600,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                                SizedBox(height: size16),
                                                Container(
                                                  height: 200,
                                                  width: 200,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          size8,
                                                        ),
                                                    border: Border.all(
                                                      color: bnw300,
                                                    ),
                                                  ),
                                                  child: logoStruk == ''
                                                      ? Icon(PhosphorIcons.plus)
                                                      : ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                size8,
                                                              ),
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
                                                      ),
                                                    );
                                                    setState(() {});
                                                    // initState();
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
                                                        focusedBorder:
                                                            UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    width: 2,
                                                                    color:
                                                                        primary500,
                                                                  ),
                                                            ),
                                                        focusColor: primary500,
                                                        prefixIcon: Icon(
                                                          logoStruk != ''
                                                              ? PhosphorIcons
                                                                    .pencil
                                                              : PhosphorIcons
                                                                    .plus,
                                                          color: bnw900,
                                                        ),
                                                        hintText:
                                                            logoStruk != ''
                                                            ? 'Ganti Struk'
                                                            : 'Tambah Struk',
                                                        hintStyle: heading3(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit',
                                                        ),
                                                      ),
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
                                                            cursorColor:
                                                                primary500,
                                                            enabled: false,
                                                            style: heading3(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit',
                                                            ),
                                                            decoration: InputDecoration(
                                                              focusedBorder:
                                                                  UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                          width:
                                                                              2,
                                                                          color:
                                                                              primary500,
                                                                        ),
                                                                  ),
                                                              focusColor:
                                                                  primary500,
                                                              prefixIcon: Icon(
                                                                PhosphorIcons
                                                                    .trash,
                                                                color: bnw900,
                                                              ),
                                                              hintText:
                                                                  'Hapus Struk',
                                                              hintStyle:
                                                                  heading3(
                                                                    FontWeight
                                                                        .w400,
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
                                            Icon(
                                              PhosphorIcons.pencil_line,
                                              color: bnw100,
                                              size: size24,
                                            ),
                                            SizedBox(width: size12),
                                            Text(
                                              'Tambah Struk',
                                              style: heading3(
                                                FontWeight.w600,
                                                bnw100,
                                                'Outfit',
                                              ),
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
                                              size: size24,
                                            ),
                                            SizedBox(width: size12),
                                            Text(
                                              'Atur Struk',
                                              style: heading3(
                                                FontWeight.w600,
                                                primary500,
                                                'Outfit',
                                              ),
                                            ),
                                          ],
                                        ),
                                        0,
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
    MyObject(
      'Dompet Digital',
      'Pindai kode batang (QR Code) untuk membayar',
      PhosphorIcons.qr_code_fill,
    ),
    MyObject(
      'Kartu Kredit',
      'Masukkan Kartu Kredit',
      PhosphorIcons.credit_card_fill,
    ),
    MyObject(
      'Kartu Debit',
      'Masukkan Kartu Debit',
      PhosphorIcons.cardholder_fill,
    ),
    MyObject(
      'Fifapay Koin',
      'Pilih daftar pelanggan',
      PhosphorIcons.coins_fill,
    ),
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
                padding: EdgeInsets.symmetric(
                  vertical: size16,
                  horizontal: size16,
                ),
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

                              cartProductIds.clear();
                              conCatatan.clear();
                              conCounterPreview.clear();
                              refreshTampilan();
                              transactionidValue = "";

                              refreshColor();
                              setState(() {});
                            }

                            selectedIndex = 0;
                            selectedIndexDompetDigital = 0;
                            uangTunaiController.text = '0';

                            _pageController.previousPage(
                              duration: Duration(microseconds: 1),
                              curve: Curves.ease,
                            );

                            setState(() {});
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
                              'Pembayaran',
                              style: heading1(
                                FontWeight.w700,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            Text(
                              'Papan Informasi Toko',
                              style: heading3(
                                FontWeight.w300,
                                bnw900,
                                'Outfit',
                              ),
                            ),
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
                            List<dynamic> variants = cart[i].variants != null
                                ? jsonDecode(cart[i].variants!)
                                : [];
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
                                          borderRadius: BorderRadius.circular(
                                            size8,
                                          ),
                                          child: Image.network(
                                            cart[i].image.toString(),
                                            fit: BoxFit.cover,
                                            height: size48,
                                            width: size48,
                                            loadingBuilder:
                                                (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }

                                                  return Center(
                                                    child: loading(),
                                                  );
                                                },
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => SizedBox(
                                                  // height: 227,
                                                  // width: 227,
                                                  child: SvgPicture.asset(
                                                    'assets/logoProduct.svg',
                                                  ),
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
                                                cart[i].price,
                                              ),
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
                                            if (variants.isNotEmpty)
                                              ...variants.map<Widget>((
                                                variant,
                                              ) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Text(
                                                    //   'Kategori: ${variant['variant_category_title']}',
                                                    //   style: heading3(
                                                    //     FontWeight.w500,
                                                    //     bnw900,
                                                    //     'Outfit',
                                                    //   ),
                                                    // ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          '+ Variant: ${variant['variant_detail'].map((detail) => detail['variant_name']).join(', ')}',
                                                          style: heading3(
                                                            FontWeight.w500,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),

                                                        // Text(
                                                        //   "${FormatCurrency.convertToIdr(variant['variant_detail'].fold(0, (sum, detail) => sum + (detail['variant_price'] ?? 0)))}",
                                                        //   // '${variant['variant_detail'].map((detail) => detail['variant_price']).join(', ')}',
                                                        //   style: heading3(
                                                        //     FontWeight.w500,
                                                        //     bnw900,
                                                        //     'Outfit',
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
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
                    Divider(thickness: 1, color: bnw900),
                    SizedBox(height: size16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Diskon',
                          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        Text(
                          FormatCurrency.convertToIdr(discountProductUmum),
                          style: heading2(FontWeight.w600, succes600, 'Outfit'),
                        ),
                      ],
                    ),
                    SizedBox(height: size16),
                    GestureDetector(
                      onTap: () {
                        bool isKeyboardActive = false;
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
                            return FractionallySizedBox(
                              heightFactor: isKeyboardActive ? 0.9 : 0.80,
                              child: GestureDetector(
                                onTap: () => textFieldFocusNode.unfocus(),
                                child: Container(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
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
                                                      vertical: size12,
                                                    ),
                                                isDense: true,
                                                filled: true,
                                                fillColor: bnw200,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        size8,
                                                      ),
                                                  borderSide: BorderSide(
                                                    color: bnw300,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            size8,
                                                          ),
                                                      borderSide: BorderSide(
                                                        width: 2,
                                                        color: primary500,
                                                      ),
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            size8,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: bnw300,
                                                      ),
                                                    ),
                                                suffixIcon:
                                                    searchController
                                                        .text
                                                        .isNotEmpty
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          searchController
                                                                  .text =
                                                              '';
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
                                                  PhosphorIcons
                                                      .magnifying_glass,
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
                                            color: bnw100,
                                            backgroundColor: primary500,
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
                                                    'Outfit',
                                                  ),
                                                ),
                                                SizedBox(height: size16),
                                                StatefulBuilder(
                                                  builder: (context, setState) => ListView.builder(
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
                                                    itemBuilder: (context, index) {
                                                      final product =
                                                          searchResultListProduct?[index];
                                                      final isSelected =
                                                          product ==
                                                          selectedProduct;

                                                      return GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            textFieldFocusNode
                                                                .unfocus();

                                                            if (product['date'] !=
                                                                'Kedaluwarsa') {
                                                              _selectProduct(
                                                                product,
                                                              );
                                                            }
                                                            print(
                                                              product['id'],
                                                            );
                                                            setState(() {});
                                                          });
                                                        },
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.symmetric(
                                                                vertical: size8,
                                                              ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                size16,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                product['date'] ==
                                                                    'Kedaluwarsa'
                                                                ? bnw300
                                                                : isSelected
                                                                ? primary100
                                                                : bnw100,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  size16,
                                                                ),
                                                            border: Border.all(
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
                                                                        product['date'] ==
                                                                            'Kedaluwarsa'
                                                                        ? bnw100
                                                                        : primary500,
                                                                    size:
                                                                        size48,
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                        size16,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        product['name'] !=
                                                                                null
                                                                            ? capitalizeEachWord(
                                                                                product['name'].toString(),
                                                                              )
                                                                            : '',
                                                                        style: heading3(
                                                                          FontWeight
                                                                              .w400,
                                                                          product['date'] ==
                                                                                  'Kedaluwarsa'
                                                                              ? bnw100
                                                                              : bnw900,
                                                                          'Outfit',
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        product['discount_type'] ==
                                                                                'percentage'
                                                                            ? '${product['discount']}%'
                                                                            : FormatCurrency.convertToIdr(
                                                                                product['discount'] ??
                                                                                    0,
                                                                              ),
                                                                        style: heading4(
                                                                          FontWeight
                                                                              .w600,
                                                                          product['date'] ==
                                                                                  'Kedaluwarsa'
                                                                              ? bnw100
                                                                              : bnw900,
                                                                          'Outfit',
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: size16,
                                                              ),
                                                              Container(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      vertical:
                                                                          size8,
                                                                      horizontal:
                                                                          size12,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      product['date'] ==
                                                                          'Kedaluwarsa'
                                                                      ? danger100
                                                                      : bnw200,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        size16,
                                                                      ),
                                                                  border: Border.all(
                                                                    color:
                                                                        product['date'] ==
                                                                            'Kedaluwarsa'
                                                                        ? danger100
                                                                        : bnw300,
                                                                  ),
                                                                ),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      product['date'],
                                                                      style: body3(
                                                                        FontWeight
                                                                            .w400,
                                                                        product['date'] ==
                                                                                'Kedaluwarsa'
                                                                            ? danger500
                                                                            : bnw600,
                                                                        'Outfit',
                                                                      ),
                                                                    ),
                                                                    Icon(
                                                                      PhosphorIcons
                                                                          .clock,
                                                                      color:
                                                                          product['date'] ==
                                                                              'Kedaluwarsa'
                                                                          ? danger500
                                                                          : bnw600,
                                                                      size:
                                                                          size16,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),

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
                                              discountNameFix = discountName;
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
                                                discountIdFix,
                                                '',
                                              );
                                            });
                                          },
                                          child: buttonXXL(
                                            Center(
                                              child: Text(
                                                'Simpan',
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
                            );
                          },
                        );
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: buttonXLactive(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                discountName == ''
                                    ? 'Pilih Diskon'
                                    : discountName.toString(),
                                style: heading3(
                                  FontWeight.w400,
                                  discountName == '' ? bnw900 : primary500,
                                  'Outfit',
                                ),
                              ),
                              Icon(
                                PhosphorIcons.tag_fill,
                                color: discountName == '' ? bnw900 : primary500,
                              ),
                            ],
                          ),
                          double.infinity,
                          discountName == '' ? bnw300 : primary500,
                          discountName == '' ? bnw100 : primary100,
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
                    ),
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
                                  FontWeight.w600,
                                  bnw900,
                                  'Outfit',
                                ),
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
                                          pageControllerPayment.jumpToPage(
                                            index,
                                          );

                                          setState(() {});
                                        },
                                        child: IntrinsicHeight(
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                              size8,
                                              size8,
                                              size8,
                                              size16,
                                            ),
                                            margin: EdgeInsets.only(
                                              bottom:
                                                  index == objects.length - 1
                                                  ? 0
                                                  : size16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: selectedIndex == index
                                                  ? primary200
                                                  : bnw100,
                                              borderRadius:
                                                  BorderRadius.circular(size8),
                                              border: Border.all(
                                                color: selectedIndex == index
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
                                                    'Outfit',
                                                  ),
                                                ),
                                                Text(
                                                  objects[index].description,
                                                  textAlign: TextAlign.center,
                                                  style: body1(
                                                    FontWeight.w400,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Material(
                                    color: bnw100,
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                            size12,
                                            0,
                                            size12,
                                            size12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primary100,
                                            borderRadius: BorderRadius.circular(
                                              size8,
                                            ),
                                            border: Border.all(
                                              color: primary500,
                                              width: 1.6,
                                            ),
                                          ),
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height /
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
                                                  'Outfit',
                                                ),
                                              ),
                                              Text(
                                                'Pindai kode batang (QR Code) untuk membayar ',
                                                textAlign: TextAlign.center,
                                                style: body1(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            dompetDigitalPageCon.jumpToPage(0);
                                            _pageMetodeSwap.previousPage(
                                              duration: Duration(
                                                milliseconds: 10,
                                              ),
                                              curve: Curves.easeIn,
                                            );
                                            uangTunaiController.text = '0';
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.fromLTRB(
                                              size12,
                                              0,
                                              size12,
                                              size12,
                                            ),
                                            child: buttonXLoutline(
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Icon(
                                                    PhosphorIcons.arrow_left,
                                                    size: size32,
                                                    color: bnw900,
                                                  ),
                                                  SizedBox(width: size16),
                                                  Text(
                                                    'Kembali',
                                                    style: heading2(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              0,
                                              bnw300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Material(
                                    color: bnw100,
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                            size12,
                                            0,
                                            size12,
                                            size12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primary100,
                                            borderRadius: BorderRadius.circular(
                                              size8,
                                            ),
                                            border: Border.all(
                                              color: primary500,
                                              width: 1.6,
                                            ),
                                          ),
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height /
                                              3.6,
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                PhosphorIcons.credit_card_fill,
                                                color: bnw900,
                                                size: 46,
                                              ),
                                              Text(
                                                'Kartu Kredit',
                                                style: heading3(
                                                  FontWeight.w700,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              Text(
                                                'Masukkan nomor kartu Kredit untuk membayar.',
                                                textAlign: TextAlign.center,
                                                style: body1(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            dompetDigitalPageCon.jumpToPage(0);
                                            _pageMetodeSwap.jumpToPage(0);
                                            uangTunaiController.text = '0';
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.fromLTRB(
                                              size12,
                                              0,
                                              size12,
                                              size12,
                                            ),
                                            child: buttonXLoutline(
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Icon(
                                                    PhosphorIcons.arrow_left,
                                                    size: size32,
                                                    color: bnw900,
                                                  ),
                                                  SizedBox(width: size16),
                                                  Text(
                                                    'Kembali',
                                                    style: heading2(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              0,
                                              bnw300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Material(
                                    color: bnw100,
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                            size12,
                                            0,
                                            size12,
                                            size12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primary100,
                                            borderRadius: BorderRadius.circular(
                                              size8,
                                            ),
                                            border: Border.all(
                                              color: primary500,
                                              width: 1.6,
                                            ),
                                          ),
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height /
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
                                                'Kartu Debit',
                                                style: heading3(
                                                  FontWeight.w700,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              Text(
                                                'Masukkan nomor kartu Debit untuk membayar.',
                                                textAlign: TextAlign.center,
                                                style: body1(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            dompetDigitalPageCon.jumpToPage(0);
                                            _pageMetodeSwap.jumpToPage(0);
                                            uangTunaiController.text = '0';
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.fromLTRB(
                                              size12,
                                              0,
                                              size12,
                                              size12,
                                            ),
                                            child: buttonXLoutline(
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Icon(
                                                    PhosphorIcons.arrow_left,
                                                    size: size32,
                                                    color: bnw900,
                                                  ),
                                                  SizedBox(width: size16),
                                                  Text(
                                                    'Kembali',
                                                    style: heading2(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                ),
              ),
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
                        color: value.namaPelanggan == '' ? bnw900 : primary500,
                        size: size24,
                      ),
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
                              child: Icon(
                                PhosphorIcons.x,
                                color: primary500,
                                size: size24,
                              ),
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
          ),
        ],
      ),
    );
  }

  kartuDedit(BuildContext context) {
    bool displayCode = false;

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
                  'Pilih Kartu Debit',
                  style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                ),
                SizedBox(height: size16),
                Expanded(
                  child: FutureBuilder<List<PaymentMethod>>(
                    future: futurePaymentMethodsDebit,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Payment tidak ditemukan.\n Buat Terlebih dahulu.',
                          ),
                        );
                      }

                      final paymentMethods = snapshot.data!;

                      return ListView.builder(
                        itemCount: paymentMethods.length,
                        itemBuilder: (context, index) {
                          final payment = paymentMethods[index];
                          return GestureDetector(
                            onTap: () {
                              selectedIndexDompetDigital = index;
                              print(totalTransaksi);
                              idpaymentmethode = payment.idpaymentmethode!;
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
                                  Icon(PhosphorIcons.wallet_fill, size: size64),
                                  // Image.asset(
                                  //   "assets/${metodePembayaranObjects[index].image}",
                                  // ),
                                  SizedBox(width: size16),
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payment.paymentMethod ?? '',
                                          style: heading3(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        Text(
                                          payment.accountNumber ?? '-',
                                          style: heading4(
                                            FontWeight.w400,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                          // ListTile(
                          //   title: Text(payment.paymentMethod ?? '-'),
                          //   subtitle:
                          //       Text('Account Number: ${payment.accountNumber}'),
                          // );
                        },
                      );
                    },
                  ),
                ),
                Divider(),
                rincianPembayaranDebitKredit(
                  context,
                  (uangTunaiController.text = totalTransaksi.toString()),
                  idpaymentmethode,
                  debitpinController.text,
                ),
                // rincianPembayaranSelanjutnya(
                //   context,
                //   dompetDigitalPageCon,
                //   _pageMetodeSwap,
                //   selectedIndexDompetDigital,
                //   3,
                //   coaValueDebit == '' ? true : false,
                // )
              ],
            ),
          ),
          Column(
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
                      LengthLimitingTextInputFormatter(20),
                      NumericTextFormatter(),
                    ],
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 2, color: primary500),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: size8),
                      isDense: true,
                      focusColor: primary500,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1.5, color: bnw500),
                      ),
                      hintText: 'Cth : 0000-0000-0000-0000',
                      hintStyle: heading2(FontWeight.w700, bnw500, 'Outfit'),
                    ),
                  ),
                ),
              ),
              Spacer(),
              Divider(),
              displayCode != true
                  ? rincianPembayaranDebitKredit(
                      context,
                      (uangTunaiController.text = totalTransaksi.toString()),
                      idpaymentmethode,
                      debitpinController.text,
                    )
                  : keypad(displayCode, debitpinController),
            ],
          ),
        ],
      ),
    );
  }

  kartuKredit(BuildContext context) {
    bool displayCode = false;
    // TextEditingController pinController = TextEditingController();

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
                  'Pilih Kartu Kredit',
                  style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                ),
                SizedBox(height: size16),
                Expanded(
                  child: FutureBuilder<List<PaymentMethod>>(
                    future: futurePaymentMethodsKredit,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Payment tidak ditemukan.\n Buat Terlebih dahulu.',
                          ),
                        );
                      }

                      final paymentMethods = snapshot.data!;

                      return ListView.builder(
                        itemCount: paymentMethods.length,
                        itemBuilder: (context, index) {
                          final payment = paymentMethods[index];
                          return GestureDetector(
                            onTap: () {
                              selectedIndexDompetDigital = index;
                              print(totalTransaksi);
                              idpaymentmethode = payment.idpaymentmethode!;
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
                                  Icon(PhosphorIcons.wallet_fill, size: size64),
                                  // Image.asset(
                                  //   "assets/${metodePembayaranObjects[index].image}",
                                  // ),
                                  SizedBox(width: size16),
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payment.paymentMethod ?? '',
                                          style: heading3(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        Text(
                                          payment.accountNumber ?? '-',
                                          style: heading4(
                                            FontWeight.w400,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                          // ListTile(
                          //   title: Text(payment.paymentMethod ?? '-'),
                          //   subtitle:
                          //       Text('Account Number: ${payment.accountNumber}'),
                          // );
                        },
                      );
                    },
                  ),
                ),
                Divider(),
                rincianPembayaranDebitKredit(
                  context,
                  (uangTunaiController.text = totalTransaksi.toString()),
                  idpaymentmethode,
                  debitpinController.text,
                ),
                // rincianPembayaranSelanjutnya(
                //     context,
                //     dompetDigitalPageCon,
                //     _pageMetodeSwap,
                //     selectedIndexDompetDigital,
                //     2,
                //     coaValueKredit == '' ? true : false)
              ],
            ),
          ),
          Column(
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
                cursorColor: primary500,
                onTap: () {
                  displayCode = true;
                  print(displayCode);
                  setState(() {});
                },
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                keyboardType: TextInputType.number,
                controller: kreditpinController,
                readOnly: true,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                  NumericTextFormatter(),
                ],
                onChanged: (value) {},
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: size8),
                  isDense: true,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 1.5, color: bnw500),
                  ),
                  hintText: 'Cth : 0000-0000-0000-0000',
                  hintStyle: heading2(FontWeight.w700, bnw500, 'Outfit'),
                ),
              ),
              Spacer(),
              Divider(),
              displayCode != true
                  ? rincianPembayaranDebitKredit(
                      context,
                      (uangTunaiController.text = totalTransaksi.toString()),
                      idpaymentmethode,
                      kreditpinController.text,
                    )
                  : keypad(displayCode, kreditpinController),
              // : NumPad(displayCode: displayCode, pinCon: kreditpinController,)
            ],
          ),
        ],
      ),
    );
  }

  dompetDigital(BuildContext context) {
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
                  child: FutureBuilder<List<PaymentMethod>>(
                    future: futurePaymentMethodsEWallet,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Payment tidak ditemukan.\n Buat Terlebih dahulu.',
                          ),
                        );
                      }

                      final paymentMethods = snapshot.data!;

                      return ListView.builder(
                        itemCount: paymentMethods.length,
                        itemBuilder: (context, index) {
                          final payment = paymentMethods[index];
                          return GestureDetector(
                            onTap: () {
                              selectedIndexDompetDigital = index;
                              // print(totalTransaksi);
                              idpaymentmethode = payment.idpaymentmethode!;
                              // log(idpaymentmethode.toString());
                              // log(payment.idpaymentmethode.toString());
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
                                  Icon(PhosphorIcons.wallet_fill, size: size64),
                                  // Image.asset(
                                  //   "assets/${metodePembayaranObjects[index].image}",
                                  // ),
                                  SizedBox(width: size16),
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payment.paymentMethod ?? '',
                                          style: heading3(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        Text(
                                          payment.accountNumber ?? '-',
                                          style: heading4(
                                            FontWeight.w400,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                          // ListTile(
                          //   title: Text(payment.paymentMethod ?? '-'),
                          //   subtitle:
                          //       Text('Account Number: ${payment.accountNumber}'),
                          // );
                        },
                      );
                    },
                  ),
                ),
                Divider(),
                rincianPembayaranDebitKredit(
                  context,
                  (uangTunaiController.text = totalTransaksi.toString()),
                  idpaymentmethode,
                  debitpinController.text,
                ),
                // rincianPembayaranSelanjutnya(
                //     context,
                //     dompetDigitalPageCon,
                //     _pageMetodeSwap,
                //     selectedIndexDompetDigital,
                //     1,
                //     coaValueEWallet == '' ? true : false)
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
                                      FontWeight.w600,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                  SizedBox(height: size16),
                                  Container(
                                    height: 260,
                                    width: 260,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        size8,
                                      ),
                                      border: Border.all(color: bnw300),
                                    ),
                                    child: logoQris == ''
                                        ? Icon(PhosphorIcons.plus)
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              size8,
                                            ),
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
                                            style: heading3(
                                              FontWeight.w600,
                                              bnw100,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                        double.infinity,
                                      ),
                                    ),
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
                        child: Text(
                          'Tunjukkan Kode Batang',
                          style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                      double.infinity,
                      bnw300,
                    ),
                  ),
                ),
                Spacer(),
                Divider(),
                rincianPembayaranDebitKredit(
                  context,
                  totalTransaksi.toString(),
                  idpaymentmethode,
                  '',
                ),
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
                      cursorColor: primary500,
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
                          borderSide: BorderSide(width: 1.5, color: bnw500),
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

          SingleChildScrollView(
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
                              style: heading3(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
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
                              style: heading3(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
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
          // displayCode != true ? SizedBox() : Spacer(),
          // Text('hello'),
          Spacer(),
          displayCode != true
              ? rincianPembayaran(
                  context,
                  uangTunaiController.text,
                  '001',
                  'false',
                )
              : keypad(displayCode, uangTunaiController),
        ],
      ),
    );
  }

  keypad(bool? displayCode, TextEditingController pinCon) {
    return Expanded(
      // height: MediaQuery.of(context).size.he,
      // color: bnw300,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
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
                  pinCon.text = pinCon.text.substring(
                    0,
                    pinCon.text.length - 1,
                  );
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
    return Divider(height: width2, color: bnw900);
  }

  rincianPembayaran(BuildContext context, pinValue, payMethod, payReference) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Expanded(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: BouncingScrollPhysics(),
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
              'Diskon',
              FormatCurrency.convertToIdr(discountProduct ?? 0),
            ),
            SizedBox(height: size16),
            dash(),
            SizedBox(height: size16),
            uangTunaiController.text != '0'
                ? uangTunaiController.text != 'Rp 0'
                      ? Column(
                          children: [
                            rincianText(
                              'Tunai',
                              FormatCurrency.convertToIdr(
                                (int.parse(
                                  uangTunaiController.text.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  ),
                                )),
                              ),
                            ),
                            SizedBox(height: size16),
                            rincianBlueText(
                              (int.parse(
                                            uangTunaiController.text.replaceAll(
                                              RegExp(r'[^0-9]'),
                                              '',
                                            ),
                                          ) -
                                          totalTransaksi) <
                                      0
                                  ? 'Kurang'
                                  : 'Kembalian',
                              FormatCurrency.convertToIdr(
                                (int.parse(
                                      uangTunaiController.text.replaceAll(
                                        RegExp(r'[^0-9]'),
                                        '',
                                      ),
                                    )) -
                                    totalTransaksi,
                              ),
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
              child: totalTransaksi < 0
                  ? buttonXXLonOff(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.wallet_fill, color: bnw100),
                          SizedBox(width: size16),
                          Text(
                            'Bayar',
                            style: heading2(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        ],
                      ),
                      double.infinity,
                      bnw300,
                    )
                  : GestureDetector(
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
                            Icon(PhosphorIcons.wallet_fill, color: bnw100),
                            SizedBox(width: size16),
                            Text(
                              'Bayar',
                              style: heading2(
                                FontWeight.w600,
                                bnw100,
                                'Outfit',
                              ),
                            ),
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
      ),
    );
  }

  rincianPembayaranSelanjutnya(
    BuildContext context,
    dompetDigitalPageCon,
    pageMetodeSwap,
    index,
    pagePembayaran,
    onoff,
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
          rincianText('Sub Total', FormatCurrency.convertToIdr(subTotal ?? 0)),
          SizedBox(height: size8),
          rincianText('PPN', FormatCurrency.convertToIdr(ppnTransaksi ?? 0)),
          SizedBox(height: size16),
          dash(),
          SizedBox(height: size16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: heading1(FontWeight.w700, bnw900, 'Outfit')),
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
                onoff == true
                    ? setState(() {
                        dompetDigitalPageCon.jumpToPage(index + 1);
                        pageMetodeSwap.jumpToPage(pagePembayaran);

                        uangTunaiController.text = totalTransaksi.toString();
                      })
                    : setState(() {});
              },
              child: onoff == true
                  ? buttonXXL(
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
                    )
                  : SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  rincianPembayaranDebitKredit(
    BuildContext context,
    pinValue,
    payMethod,
    payReference,
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
          rincianText('Sub Total', FormatCurrency.convertToIdr(subTotal ?? 0)),
          SizedBox(height: size8),
          rincianText('PPN', FormatCurrency.convertToIdr(ppnTransaksi ?? 0)),
          SizedBox(height: size16),
          dash(),
          SizedBox(height: size16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: heading1(FontWeight.w700, bnw900, 'Outfit')),
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
            child: totalTransaksi < 0
                ? buttonXXLonOff(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIcons.wallet_fill, color: bnw100),
                        SizedBox(width: size16),
                        Text(
                          'Bayar',
                          style: heading2(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ],
                    ),
                    double.infinity,
                    bnw300,
                  )
                : GestureDetector(
                    onTap: () {
                      log(payMethod.toString());
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
                          Icon(PhosphorIcons.wallet_fill, color: bnw100),
                          SizedBox(width: size16),
                          Text(
                            'Bayar',
                            style: heading2(FontWeight.w600, bnw100, 'Outfit'),
                          ),
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

  pesananStruk(title, subTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: heading4(FontWeight.w400, bnw900, 'Outfit')),
        Text(subTitle, style: heading4(FontWeight.w400, bnw900, 'Outfit')),
      ],
    );
  }

  Row kembalianStruk(title, subTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: heading2(FontWeight.w700, bnw900, 'Outfit')),
        Text(subTitle, style: heading2(FontWeight.w700, bnw900, 'Outfit')),
      ],
    );
  }

  rincianText(String title, subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: heading4(FontWeight.w500, bnw900, 'Outfit')),
        Text(subtitle, style: heading4(FontWeight.w500, bnw900, 'Outfit')),
      ],
    );
  }

  rincianBlueText(String title, subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: heading4(FontWeight.w500, primary500, 'Outfit')),
        Text(subtitle, style: heading4(FontWeight.w500, primary500, 'Outfit')),
      ],
    );
  }

  getAllProduct(BuildContext context, PageController pageController) {
    int newquantity = 1;
    getStruk(context, widget.token, '');
    var edgeInsets = EdgeInsets;
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
                                    FontWeight.w700,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Text(
                                  nameToko ?? '',
                                  style: heading3(
                                    FontWeight.w300,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              child: SizedBox(
                                child: TextField(
                                  cursorColor: primary500,
                                  style: heading2(
                                    FontWeight.w500,
                                    bnw900,
                                    'Outfit',
                                  ),
                                  controller: searchController,
                                  onChanged: _onChanged,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: size16,
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
                                    prefixIconConstraints: BoxConstraints.loose(
                                      Size.infinite,
                                    ),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.fromLTRB(
                                        size20,
                                        0,
                                        size16,
                                        0,
                                      ),
                                      child: Icon(
                                        PhosphorIcons.magnifying_glass,
                                        color: bnw900,
                                        size: size32,
                                      ),
                                    ),
                                    suffixIconConstraints: BoxConstraints.loose(
                                      Size.infinite,
                                    ),
                                    suffixIcon: searchController.text.isNotEmpty
                                        ? Container(
                                            margin: EdgeInsets.fromLTRB(
                                              size16,
                                              0,
                                              size20,
                                              0,
                                            ),
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
                                print(widget.token);
                                customProdukName.text = "";
                                customProdukPrice.text = "";
                                conCatatanPreview.text = '';
                                errorText = "";

                                final String fullUrl =
                                    '$bindingUrl&sess_code=$sessCode';

                                print("my code $bindingUrl");
                                try {
                                  webController = WebViewController()
                                    ..setJavaScriptMode(
                                      JavaScriptMode.unrestricted,
                                    )
                                    ..loadRequest(Uri.parse(fullUrl));
                                  print(
                                    "WebController initialized successfully",
                                  );
                                } catch (e) {
                                  print("Error initializing WebController: $e");
                                }

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
                                        bottom: MediaQuery.of(
                                          context,
                                        ).viewInsets.bottom,
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
                                            SizedBox(height: size12),
                                            dividerShowdialog(),
                                            SizedBox(height: size12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      // Navigator.of(context)
                                                      //     .popUntil((route) =>
                                                      //         route.isFirst);
                                                      // errorText = '';

                                                      showModalBottomSheet(
                                                        constraints:
                                                            const BoxConstraints(
                                                              maxWidth: double
                                                                  .infinity,
                                                            ),
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        useRootNavigator: false,
                                                        isScrollControlled:
                                                            true,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                size16,
                                                              ),
                                                        ),
                                                        context: context,
                                                        builder: (context) {
                                                          return StatefulBuilder(
                                                            builder: (context, setState) => Container(
                                                              margin:
                                                                  EdgeInsets.only(
                                                                    top: size16,
                                                                  ),
                                                              padding: EdgeInsets.only(
                                                                bottom:
                                                                    MediaQuery.of(
                                                                          context,
                                                                        )
                                                                        .viewInsets
                                                                        .bottom,
                                                              ),
                                                              decoration: ShapeDecoration(
                                                                color: bnw100,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.only(
                                                                    topLeft:
                                                                        Radius.circular(
                                                                          size16,
                                                                        ),
                                                                    topRight:
                                                                        Radius.circular(
                                                                          size16,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets.fromLTRB(
                                                                      size32,
                                                                      size16,
                                                                      size32,
                                                                      size32,
                                                                    ),
                                                                child: SingleChildScrollView(
                                                                  child: Column(
                                                                    children: [
                                                                      dividerShowdialog(),
                                                                      SizedBox(
                                                                        height:
                                                                            size16,
                                                                      ),
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child: Text(
                                                                          'Kustom Produk',
                                                                          style: heading1(
                                                                            FontWeight.w700,
                                                                            bnw900,
                                                                            'Outfit',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            size16,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  'Nama Produk',
                                                                                  style: body1(
                                                                                    FontWeight.w500,
                                                                                    bnw900,
                                                                                    'Outfit',
                                                                                  ),
                                                                                ),
                                                                                IntrinsicHeight(
                                                                                  child: TextFormField(
                                                                                    // keyboardType: numberNo,
                                                                                    cursorColor: primary500,
                                                                                    style: heading2(
                                                                                      FontWeight.w600,
                                                                                      bnw900,
                                                                                      'Outfit',
                                                                                    ),
                                                                                    controller: customProdukName,

                                                                                    decoration: InputDecoration(
                                                                                      isDense: true,
                                                                                      focusedBorder: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          width: 2,
                                                                                          color: primary500,
                                                                                        ),
                                                                                      ),
                                                                                      contentPadding: EdgeInsets.symmetric(
                                                                                        vertical: size12,
                                                                                      ),
                                                                                      enabledBorder: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          width: 1.5,
                                                                                          color: bnw500,
                                                                                        ),
                                                                                      ),
                                                                                      hintText: 'Cth : Lemon Tea',
                                                                                      hintStyle: heading2(
                                                                                        FontWeight.w600,
                                                                                        bnw500,
                                                                                        'Outfit',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                errorText.isNotEmpty
                                                                                    ? Column(
                                                                                        children: [
                                                                                          SizedBox(
                                                                                            height: size16,
                                                                                          ),
                                                                                          Text(
                                                                                            errorText,
                                                                                            style: body1(
                                                                                              FontWeight.w500,
                                                                                              bnw100,
                                                                                              'Outfit',
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : SizedBox(),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                size16,
                                                                          ),
                                                                          Expanded(
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      'Harga',
                                                                                      style: body1(
                                                                                        FontWeight.w500,
                                                                                        bnw900,
                                                                                        'Outfit',
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      '*',
                                                                                      style: body1(
                                                                                        FontWeight.w500,
                                                                                        danger500,
                                                                                        'Outfit',
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                IntrinsicHeight(
                                                                                  child: TextFormField(
                                                                                    cursorColor: primary500,
                                                                                    keyboardType: TextInputType.number,
                                                                                    style: heading2(
                                                                                      FontWeight.w600,
                                                                                      bnw900,
                                                                                      'Outfit',
                                                                                    ),
                                                                                    controller: customProdukPrice,
                                                                                    decoration: InputDecoration(
                                                                                      isDense: true,
                                                                                      focusedBorder: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          width: 2,
                                                                                          color: primary500,
                                                                                        ),
                                                                                      ),
                                                                                      contentPadding: EdgeInsets.symmetric(
                                                                                        vertical: size12,
                                                                                      ),
                                                                                      enabledBorder: UnderlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          width: 1.5,
                                                                                          color: errorText.isEmpty
                                                                                              ? bnw500
                                                                                              : danger500,
                                                                                        ),
                                                                                      ),
                                                                                      hintText: 'Cth : 25.000',
                                                                                      hintStyle: heading2(
                                                                                        FontWeight.w600,
                                                                                        bnw500,
                                                                                        'Outfit',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                errorText.isNotEmpty
                                                                                    ? Column(
                                                                                        children: [
                                                                                          SizedBox(
                                                                                            height: size16,
                                                                                          ),
                                                                                          Text(
                                                                                            errorText,
                                                                                            style: body1(
                                                                                              FontWeight.w500,
                                                                                              red500,
                                                                                              'Outfit',
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : SizedBox(),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                size16,
                                                                          ),
                                                                          Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Text(
                                                                                'Jumlah',
                                                                                style: heading3(
                                                                                  FontWeight.w400,
                                                                                  bnw900,
                                                                                  'Outfit',
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: size8,
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  GestureDetector(
                                                                                    onTap: () {
                                                                                      if (counterCart >
                                                                                          1) {
                                                                                        counterCart--;
                                                                                        conCounterPreview.text = counterCart.toString();
                                                                                      }
                                                                                      setState(
                                                                                        () {},
                                                                                      );
                                                                                      // initState();
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
                                                                                  SizedBox(
                                                                                    width: size8,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: size48,
                                                                                    width: size56,
                                                                                    child: TextFormField(
                                                                                      cursorColor: primary500,
                                                                                      enabled: true,
                                                                                      controller: conCounterPreview,
                                                                                      keyboardType: TextInputType.number,
                                                                                      onChanged:
                                                                                          (
                                                                                            value,
                                                                                          ) {
                                                                                            setState(
                                                                                              () {
                                                                                                int parsedValue =
                                                                                                    int.tryParse(
                                                                                                      value,
                                                                                                    ) ??
                                                                                                    0;
                                                                                                counterCart = parsedValue;
                                                                                                conCounterPreview.text = counterCart.toString();
                                                                                              },
                                                                                            );
                                                                                          },
                                                                                      textAlign: TextAlign.center,
                                                                                      decoration: InputDecoration(
                                                                                        focusedBorder: UnderlineInputBorder(
                                                                                          borderSide: BorderSide(
                                                                                            width: 2,
                                                                                            color: primary500,
                                                                                          ),
                                                                                        ),
                                                                                        // alignLabelWithHint: true,
                                                                                        hintText: counterCart.toString(),

                                                                                        // .toString(),
                                                                                        // _itemCount.toString(),
                                                                                        hintStyle: heading4(
                                                                                          FontWeight.w600,
                                                                                          bnw800,
                                                                                          'Outfit',
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: size8,
                                                                                  ),
                                                                                  GestureDetector(
                                                                                    onTap: () {
                                                                                      counterCart++;
                                                                                      conCounterPreview.text = counterCart.toString();
                                                                                      setState(
                                                                                        () {},
                                                                                      );
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
                                                                              errorText.isNotEmpty
                                                                                  ? Column(
                                                                                      children: [
                                                                                        SizedBox(
                                                                                          height: size16,
                                                                                        ),
                                                                                        Text(
                                                                                          errorText,
                                                                                          style: body1(
                                                                                            FontWeight.w500,
                                                                                            bnw100,
                                                                                            'Outfit',
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : SizedBox(),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            size16,
                                                                      ),
                                                                      Container(
                                                                        child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'Catatan',
                                                                              style: body1(
                                                                                FontWeight.w500,
                                                                                bnw900,
                                                                                'Outfit',
                                                                              ),
                                                                            ),
                                                                            IntrinsicHeight(
                                                                              child: TextFormField(
                                                                                // keyboardType: numberNo,
                                                                                cursorColor: primary500,
                                                                                style: heading2(
                                                                                  FontWeight.w600,
                                                                                  bnw900,
                                                                                  'Outfit',
                                                                                ),
                                                                                controller: conCatatanPreview,
                                                                                onChanged:
                                                                                    (
                                                                                      value,
                                                                                    ) {
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
                                                                                    vertical: size12,
                                                                                  ),
                                                                                  enabledBorder: UnderlineInputBorder(
                                                                                    borderSide: BorderSide(
                                                                                      width: 1.5,
                                                                                      color: bnw500,
                                                                                    ),
                                                                                  ),
                                                                                  focusedBorder: UnderlineInputBorder(
                                                                                    borderSide: BorderSide(
                                                                                      width: 2,
                                                                                      color: primary500,
                                                                                    ),
                                                                                  ),
                                                                                  hintText: 'Cth : Tambah ekstra topping Boba dan Gula 2 sendok',
                                                                                  hintStyle: heading2(
                                                                                    FontWeight.w600,
                                                                                    bnw500,
                                                                                    'Outfit',
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            size32,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child: GestureDetector(
                                                                              onTap: () {
                                                                                setState(
                                                                                  () {},
                                                                                );
                                                                                Navigator.pop(
                                                                                  context,
                                                                                );
                                                                              },
                                                                              child: buttonXLoutline(
                                                                                Center(
                                                                                  child: Text(
                                                                                    'Batalkan',
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
                                                                                size16,
                                                                          ),
                                                                          Expanded(
                                                                            child: GestureDetector(
                                                                              onTap: () {
                                                                                setState(
                                                                                  () {
                                                                                    if (customProdukPrice.text.isNotEmpty &&
                                                                                        customProdukPrice.text !=
                                                                                            '0') {
                                                                                      if (!isItemAdded) {
                                                                                        Navigator.pop(
                                                                                          context,
                                                                                        );
                                                                                        if (customProdukName.text.isEmpty) {
                                                                                          customProdukName.text = 'Produk Kustom';
                                                                                        }
                                                                                        Map<
                                                                                          String,
                                                                                          String
                                                                                        >
                                                                                        map1 = {};
                                                                                        map1['name'] = customProdukName.text;
                                                                                        map1['product_id'] = 'custom';
                                                                                        // map1['quantity'] = '1';
                                                                                        map1['quantity'] = counterCart.toString();

                                                                                        map1['image'] = 'https://cdn.icon-icons.com/icons2/2718/PNG/512/package_icon_174342.png';
                                                                                        map1['amount'] = customProdukPrice.text.replaceAll(
                                                                                          RegExp(
                                                                                            r'[^0-9]',
                                                                                          ),
                                                                                          '',
                                                                                        );
                                                                                        map1['amount_display'] = customProdukPrice.text.replaceAll(
                                                                                          RegExp(
                                                                                            r'[^0-9]',
                                                                                          ),
                                                                                          '',
                                                                                        );
                                                                                        map1['description'] = conCatatanPreview.text;
                                                                                        map1['id_request'] = '';

                                                                                        cartMap.add(
                                                                                          map1,
                                                                                        );

                                                                                        // log(datasTransaksi![i].product_image.toString());

                                                                                        String name = customProdukName.text;
                                                                                        String productid = 'custom';
                                                                                        String image = 'https://cdn.icon-icons.com/icons2/2718/PNG/512/package_icon_174342.png';
                                                                                        // String desc = conCatatan[i]
                                                                                        //     .text
                                                                                        //     .toString()
                                                                                        //     .trim();

                                                                                        //int? price = ( datasTransaksi![i].price!);
                                                                                        cartProductIds.add(
                                                                                          'custom',
                                                                                        );
                                                                                        int? price = int.parse(
                                                                                          customProdukPrice.text.replaceAll(
                                                                                            RegExp(
                                                                                              r'[^0-9]',
                                                                                            ),
                                                                                            '',
                                                                                          ),
                                                                                        );

                                                                                        int index = 0;
                                                                                        for (
                                                                                          index;
                                                                                          index <
                                                                                              cart.length;
                                                                                          index++
                                                                                        ) {}

                                                                                        // int? quantity = cart[i];

                                                                                        // log(name.toString());
                                                                                        // log(price.toString());
                                                                                        // log(productid.toString());
                                                                                        // log(image.toString());

                                                                                        sumTotal =
                                                                                            sumTotal +
                                                                                            (price *
                                                                                                counterCart);
                                                                                        // subTotal =
                                                                                        //     subTotal + price.toInt();
                                                                                        total.add(
                                                                                          price *
                                                                                              counterCart,
                                                                                        );

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
                                                                                            idRequest: "",
                                                                                            // quantity: cart[i]
                                                                                            //     .quantity
                                                                                            //     .toInt(),
                                                                                          ),
                                                                                        );
                                                                                        // for (int i = 0;
                                                                                        //     i <=
                                                                                        //         cart.length;
                                                                                        //     i++) {
                                                                                        //   conCatatan.add(
                                                                                        //     TextEditingController(
                                                                                        //       text: conCatatanPreview
                                                                                        //           .text,
                                                                                        //     ),
                                                                                        //   );
                                                                                        //   inputValues.add(
                                                                                        //       conCatatanPreview
                                                                                        //           .text);
                                                                                        // }

                                                                                        setState(
                                                                                          () {},
                                                                                        );

                                                                                        num totalku = 0;
                                                                                        cartMap.forEach(
                                                                                          (
                                                                                            element,
                                                                                          ) {
                                                                                            var myelement = int.parse(
                                                                                              element['amount']!,
                                                                                            );
                                                                                            totalku =
                                                                                                totalku +
                                                                                                (myelement *
                                                                                                    counterCart);
                                                                                          },
                                                                                        );

                                                                                        sumTotal = totalku;
                                                                                        initState();
                                                                                        refreshColor();
                                                                                      }
                                                                                    } else {
                                                                                      errorText = 'Wajib diisi';
                                                                                    }
                                                                                  },
                                                                                );
                                                                              },
                                                                              child: buttonXL(
                                                                                Center(
                                                                                  child: Text(
                                                                                    'Tambah Ke Keranjang',
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
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: buttonXLoutline(
                                                      Center(
                                                        child: Text(
                                                          'Produk Kustom',
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
                                                SizedBox(width: size16),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Future.delayed(
                                                        Duration(seconds: 1),
                                                      ).then(
                                                        (
                                                          value,
                                                        ) => Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => Scaffold(
                                                              appBar: AppBar(
                                                                title: Text(
                                                                  'Produk Digital',
                                                                  style: heading2(
                                                                    FontWeight
                                                                        .w600,
                                                                    bnw900,
                                                                    'Outfit',
                                                                  ),
                                                                ),
                                                              ),
                                                              body: WebViewWidget(
                                                                controller: webController
                                                                  ..setJavaScriptMode(
                                                                    JavaScriptMode
                                                                        .unrestricted,
                                                                  ) // Aktifkan JavaScript
                                                                  ..addJavaScriptChannel(
                                                                    'flutterCallback', // Nama channel yang digunakan
                                                                    onMessageReceived:
                                                                        (
                                                                          JavaScriptMessage
                                                                          message,
                                                                        ) {
                                                                          print(
                                                                            "Message from web: ${message.message}",
                                                                          );

                                                                          int
                                                                          indexToRemove = cart.indexWhere(
                                                                            (
                                                                              item,
                                                                            ) =>
                                                                                item.productid ==
                                                                                'digitalProduct',
                                                                          );

                                                                          if (indexToRemove !=
                                                                              -1) {
                                                                            // Produk sudah ada di dalam keranjang
                                                                            cart.removeAt(
                                                                              indexToRemove,
                                                                            );
                                                                            cartMap.removeAt(
                                                                              indexToRemove,
                                                                            );
                                                                            total.removeAt(
                                                                              indexToRemove,
                                                                            );
                                                                            conCatatan.removeAt(
                                                                              indexToRemove,
                                                                            );

                                                                            // Clear some variables
                                                                            conCounterPreview.clear();
                                                                            conCatatanPreview.text =
                                                                                '';

                                                                            isItemAdded =
                                                                                true;

                                                                            if (cart.isEmpty) {
                                                                              sumTotal = 0;
                                                                              isItemAdded = false;
                                                                            }
                                                                          }

                                                                          cartMap.removeWhere(
                                                                            (
                                                                              map,
                                                                            ) =>
                                                                                map['productid'] ==
                                                                                'digitalProduct',
                                                                          );
                                                                          cart.removeWhere(
                                                                            (
                                                                              cartItem,
                                                                            ) =>
                                                                                cartItem.productid !=
                                                                                    null &&
                                                                                cartItem.productid!.trim() ==
                                                                                    'digitalProduct',
                                                                          );
                                                                          conCatatan.removeWhere(
                                                                            (
                                                                              controller,
                                                                            ) => controller.text.contains(
                                                                              'digitalProduct',
                                                                            ),
                                                                          );

                                                                          final jsonResponse =
                                                                              message.message;
                                                                          try {
                                                                            // Parse JSON
                                                                            final List<
                                                                              dynamic
                                                                            >
                                                                            jsonData = jsonDecode(
                                                                              jsonResponse,
                                                                            );

                                                                            for (var item
                                                                                in jsonData) {
                                                                              cart.add(
                                                                                CartTransaksi(
                                                                                  name: item['nama_produk'].toString(),
                                                                                  productid: 'digitalProduct',
                                                                                  image: 'https://cdn.icon-icons.com/icons2/2718/PNG/512/package_icon_174342.png',
                                                                                  price: int.parse(
                                                                                    item['total'],
                                                                                  ),
                                                                                  quantity: 1,
                                                                                  desc:
                                                                                      (item['id_request'] +
                                                                                              "-" +
                                                                                              item['jenis'] +
                                                                                              "-" +
                                                                                              item['nama_produk'])
                                                                                          .toString(),
                                                                                  idRequest: item['id_request'].toString(),
                                                                                ),
                                                                              );

                                                                              Map<
                                                                                String,
                                                                                String
                                                                              >
                                                                              map = {
                                                                                'name': item['nama_produk'].toString(),
                                                                                'productid': 'digitalProduct',
                                                                                'image': 'https://cdn.icon-icons.com/icons2/2718/PNG/512/package_icon_174342.png',
                                                                                'amount':
                                                                                    item['total'] ??
                                                                                    '0',
                                                                                'amount_display':
                                                                                    item['total'] ??
                                                                                    '0',
                                                                                'quantity': '1',
                                                                                'description':
                                                                                    (item['id_request'] +
                                                                                            "-" +
                                                                                            item['jenis'] +
                                                                                            "-" +
                                                                                            item['nama_produk'])
                                                                                        .toString(),
                                                                                // 'description': item['pesan'].toString(),
                                                                                'id_request': item['id_request'].toString(),
                                                                              };
                                                                              cartMap.add(
                                                                                map,
                                                                              );

                                                                              sumTotal =
                                                                                  sumTotal +
                                                                                  (int.parse(
                                                                                        item['total'],
                                                                                      ) *
                                                                                      1);
                                                                              // subTotal =
                                                                              //     subTotal + price.toInt();
                                                                              total.add(
                                                                                int.parse(
                                                                                      item['total'],
                                                                                    ) *
                                                                                    1,
                                                                              );

                                                                              conCatatan.add(
                                                                                TextEditingController(
                                                                                  // text: (item['id_request'] + "-" + item['jenis'] + "-" + item['nama_produk']).toString(),
                                                                                  text:
                                                                                      (item['id_request'] +
                                                                                              "-" +
                                                                                              item['jenis'] +
                                                                                              "-" +
                                                                                              item['nama_produk'])
                                                                                          .toString(),
                                                                                ),
                                                                              );

                                                                              setState(
                                                                                () {
                                                                                  // log(cart.toString());
                                                                                },
                                                                              );
                                                                            }

                                                                            // Update UI
                                                                          } catch (
                                                                            e
                                                                          ) {
                                                                            print(
                                                                              "Error parsing JSON: $e",
                                                                            );
                                                                          }
                                                                          setState(
                                                                            () {},
                                                                          );
                                                                          Navigator.of(
                                                                            context,
                                                                          ).popUntil(
                                                                            (
                                                                              route,
                                                                            ) =>
                                                                                route.isFirst,
                                                                          );
                                                                        },
                                                                  )
                                                                  ..setNavigationDelegate(
                                                                    NavigationDelegate(
                                                                      onPageFinished:
                                                                          (
                                                                            String
                                                                            url,
                                                                          ) {
                                                                            // Pastikan halaman sudah selesai dimuat sebelum menjalankan kode JavaScript
                                                                            webController.runJavaScript(
                                                                              """
                                              console.log('flutterCallback tersedia:', typeof flutterCallback !== 'undefined');
                                              console.log('Menguji pengiriman pesan');
                                              FlutterCallback.postMessage('Halo dari Web!');
                                            """,
                                                                            );
                                                                          },
                                                                    ),
                                                                  )
                                                                  ..loadRequest(
                                                                    Uri.parse(
                                                                      bindingUrl,
                                                                    ),
                                                                  ), // Ganti dengan URL halaman web
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: buttonXL(
                                                      Center(
                                                        child: Text(
                                                          'Produk Digital',
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
                                      ),
                                    ),
                                  ),
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
                                      'Kustom',
                                      style: heading2(
                                        FontWeight.w600,
                                        primary500,
                                        'Outfit',
                                      ),
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
                                indicatorSize: TabBarIndicatorSize.tab,
                                unselectedLabelColor: bnw600,
                                labelColor: primary500,
                                labelStyle: heading2(
                                  FontWeight.w400,
                                  bnw900,
                                  'Outfit',
                                ),
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
                                  Tab(text: 'Kasir'),
                                  Tab(text: 'Riwayat'),
                                  Tab(text: 'Pengaturan'),
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
                                      height: MediaQuery.of(
                                        context,
                                      ).size.height,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: size16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  orderBy(context),
                                                  SizedBox(width: size12),
                                                  buttonL(
                                                    Row(
                                                      children: [
                                                        DropdownButtonHideUnderline(
                                                          child: DropdownButton<String>(
                                                            isDense: true,
                                                            dropdownColor:
                                                                bnw100,
                                                            elevation: 1,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  size8,
                                                                ),
                                                            value:
                                                                _selectedOption,
                                                            items:
                                                                <String>[
                                                                  'Grid',
                                                                  'Tabel',
                                                                ].map((
                                                                  String value,
                                                                ) {
                                                                  return DropdownMenuItem<
                                                                    String
                                                                  >(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                      value,
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                            onChanged:
                                                                (
                                                                  String?
                                                                  newValue,
                                                                ) {
                                                                  setState(() {
                                                                    _selectedOption =
                                                                        newValue!;
                                                                  });
                                                                },
                                                            style: heading2(
                                                              FontWeight.w600,
                                                              primary500,
                                                              'Outfit',
                                                            ),
                                                            iconEnabledColor:
                                                                Colors
                                                                    .transparent,
                                                            iconSize: 0,
                                                          ),
                                                        ),
                                                        _selectedOption ==
                                                                'Grid'
                                                            ? Icon(
                                                                PhosphorIcons
                                                                    .squares_four_fill,
                                                                size: size24,
                                                                color:
                                                                    primary500,
                                                              )
                                                            : Icon(
                                                                PhosphorIcons
                                                                    .rows,
                                                                size: size24,
                                                                color:
                                                                    primary500,
                                                              ),
                                                      ],
                                                    ),
                                                    bnw100,
                                                    primary500,
                                                  ),
                                                ],
                                              ),
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
                                                    : succes600,
                                              ),
                                            ],
                                          ),
                                          //! table produk
                                          SizedBox(height: size16),
                                          datasTransaksi == null
                                              ? SkeletonCardLine()
                                              : _selectedOption == 'Tabel'
                                              ? Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      // color: primary100,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                  size12,
                                                                ),
                                                            bottomRight:
                                                                Radius.circular(
                                                                  size12,
                                                                ),
                                                          ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal:
                                                                    size16,
                                                              ),
                                                          width:
                                                              double.infinity,
                                                          height: 50,
                                                          decoration: BoxDecoration(
                                                            color: primary500,
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                  topLeft:
                                                                      Radius.circular(
                                                                        size16,
                                                                      ),
                                                                  topRight:
                                                                      Radius.circular(
                                                                        size16,
                                                                      ),
                                                                ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              Expanded(
                                                                flex: 3,
                                                                child: Container(
                                                                  child: Text(
                                                                    'Info Produk',
                                                                    style: heading4(
                                                                      FontWeight
                                                                          .w700,
                                                                      bnw100,
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    size64 +
                                                                    size16,
                                                              ),
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
                                                                  child: Text(
                                                                    'Harga Normal',
                                                                    style: heading4(
                                                                      FontWeight
                                                                          .w600,
                                                                      bnw100,
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: size16,
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child: Container(
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
                                                                  child: Text(
                                                                    'Harga Online',
                                                                    style: heading4(
                                                                      FontWeight
                                                                          .w600,
                                                                      bnw100,
                                                                      'Outfit',
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: size16,
                                                              ),
                                                              // const SizedBox(
                                                              //   width: 96,
                                                              // ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: RefreshIndicator(
                                                            color: bnw100,
                                                            backgroundColor:
                                                                primary500,
                                                            onRefresh:
                                                                () async {
                                                                  setState(
                                                                    () {},
                                                                  );
                                                                  initState();
                                                                },
                                                            child: ListView.builder(
                                                              // physics: BouncingScrollPhysics(),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              itemCount:
                                                                  datasTransaksi!
                                                                      .length,
                                                              itemBuilder: (builder, index) {
                                                                return Column(
                                                                  children: [
                                                                    Container(
                                                                      // padding: EdgeInsets.symmetric(
                                                                      //     horizontal: size16, vertical: size12),
                                                                      decoration: BoxDecoration(
                                                                        color:
                                                                            cartProductIds.contains(
                                                                              datasTransaksi![index].productid.toString(),
                                                                            )
                                                                            ? primary100
                                                                            : bnw100,
                                                                        border: Border(
                                                                          bottom: BorderSide(
                                                                            color:
                                                                                bnw300,
                                                                            width:
                                                                                width1,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceAround,
                                                                        children: [
                                                                          Expanded(
                                                                            flex:
                                                                                4,
                                                                            child: Container(
                                                                              child: Row(
                                                                                children: [
                                                                                  SizedBox(
                                                                                    width: 60,
                                                                                    height: 60,
                                                                                    child: ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(
                                                                                        size8,
                                                                                      ),
                                                                                      child:
                                                                                          datasTransaksi![index].product_image !=
                                                                                              null
                                                                                          ? Padding(
                                                                                              padding: EdgeInsets.all(
                                                                                                size8,
                                                                                              ),
                                                                                              child: ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(
                                                                                                  size8,
                                                                                                ),
                                                                                                child: Image.network(
                                                                                                  datasTransaksi![index].product_image.toString(),
                                                                                                  fit: BoxFit.cover,
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
                                                                                  SizedBox(
                                                                                    width: size16,
                                                                                  ),
                                                                                  Flexible(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          datasTransaksi![index].name ??
                                                                                              '',
                                                                                          style: heading4(
                                                                                            FontWeight.w600,
                                                                                            bnw900,
                                                                                            'Outfit',
                                                                                          ),
                                                                                          maxLines: 3,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        Text(
                                                                                          datasTransaksi![index].typeproducts ??
                                                                                              '',
                                                                                          style: heading4(
                                                                                            FontWeight.w400,
                                                                                            bnw900,
                                                                                            'Outfit',
                                                                                          ),
                                                                                          maxLines: 3,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                size16,
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                2,
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
                                                                              child: GestureDetector(
                                                                                onTap: () async {
                                                                                  String productId = datasTransaksi![index].productid.toString();

                                                                                  if (cartProductIds.contains(
                                                                                    productId,
                                                                                  )) {
                                                                                    cartProductIds.remove(
                                                                                      productId,
                                                                                    );

                                                                                    for (
                                                                                      int index = 0;
                                                                                      index <
                                                                                          cart.length;
                                                                                      index++
                                                                                    ) {
                                                                                      if (cart[index].productid ==
                                                                                          productId) {
                                                                                        total.removeAt(
                                                                                          index,
                                                                                        );
                                                                                        cart.removeAt(
                                                                                          index,
                                                                                        );
                                                                                        cartMap.removeAt(
                                                                                          index,
                                                                                        );

                                                                                        if (cart.isEmpty) {
                                                                                          sumTotal = 0;
                                                                                        }
                                                                                        break;
                                                                                      }
                                                                                    }

                                                                                    isItemAdded = true;
                                                                                  } else {
                                                                                    cartProductIds.add(
                                                                                      productId,
                                                                                    );
                                                                                    isItemAdded = false;
                                                                                  }

                                                                                  if (!isItemAdded) {
                                                                                    // Navigator.pop(context);
                                                                                    Map<
                                                                                      String,
                                                                                      String
                                                                                    >
                                                                                    map1 = {};
                                                                                    map1['name'] = datasTransaksi![index].name.toString();
                                                                                    map1['product_id'] = datasTransaksi![index].productid.toString();
                                                                                    // map1['quantity'] = '1';
                                                                                    map1['quantity'] = counterCart.toString();

                                                                                    map1['image'] = datasTransaksi![index].product_image.toString();

                                                                                    // log("${datasTransaksi![i]
                                                                                    //             .price_online_shop_after} ${datasTransaksi![i].price_after} asade ${datasTransaksi![i].price}");
                                                                                    map1['amount_display'] = datasTransaksi![index].price!.toString();
                                                                                    //                                  (datasTransaksi![i].price! * counterCart)
                                                                                    // (tapTrue == 2 ? datasTransaksi![index].price_online_shop : datasTransaksi![index].price!).toString();

                                                                                    //ubah transaksi
                                                                                    // datasTransaksi![i].price.toString();
                                                                                    map1['amount'] = datasTransaksi![index].price_after!.toString();
                                                                                    // datasTransaksi![i].price.toString();

                                                                                    // (tapTrue == 2 ? datasTransaksi![index].price_online_shop_after : datasTransaksi![index].price_after!).toString();

                                                                                    // log('hello ${datasTransaksi![i].price_online_shop} ${datasTransaksi![i].price!}');

                                                                                    map1['description'] = conCatatanPreview.text;
                                                                                    map1['id_request'] = '';
                                                                                    cartMap.add(
                                                                                      map1,
                                                                                    );

                                                                                    // log(datasTransaksi![i].product_image.toString());

                                                                                    String name = datasTransaksi![index].name.toString().trim();
                                                                                    String productid = datasTransaksi![index].productid.toString().trim();
                                                                                    String image = datasTransaksi![index].product_image.toString().trim();
                                                                                    // String desc = conCatatan[i]
                                                                                    //     .text
                                                                                    //     .toString()
                                                                                    //     .trim();

                                                                                    //int? price = ( datasTransaksi![i].price!);
                                                                                    num? price = datasTransaksi![index].price_after!;
                                                                                    // num? price = (tapTrue == 2 ? datasTransaksi![index].price_online_shop_after! : datasTransaksi![index].price_after!);

                                                                                    int i = 0;
                                                                                    for (
                                                                                      i;
                                                                                      i <
                                                                                          cart.length;
                                                                                      i++
                                                                                    ) {}

                                                                                    // int? quantity = cart[i];

                                                                                    // log(name.toString());
                                                                                    // log(price.toString());
                                                                                    // log(productid.toString());
                                                                                    // log(image.toString());

                                                                                    sumTotal =
                                                                                        sumTotal +
                                                                                        (price *
                                                                                            counterCart);
                                                                                    // subTotal =
                                                                                    //     subTotal + price.toInt();
                                                                                    total.add(
                                                                                      price *
                                                                                          counterCart,
                                                                                    );

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
                                                                                        idRequest: "",
                                                                                        // quantity: cart[i]
                                                                                        //     .quantity
                                                                                        //     .toInt(),
                                                                                      ),
                                                                                    );

                                                                                    // selectedIndexTransaksi[index];
                                                                                  }
                                                                                  // refreshColor();
                                                                                  setState(
                                                                                    () {},
                                                                                  );
                                                                                  initState();
                                                                                },
                                                                                child: buttonL(
                                                                                  Center(
                                                                                    child:
                                                                                        cartProductIds.contains(
                                                                                          datasTransaksi![index].productid.toString(),
                                                                                        )
                                                                                        ? Text(
                                                                                            'Hapus',
                                                                                            style: heading3(
                                                                                              FontWeight.w600,
                                                                                              bnw900,
                                                                                              'Outfit',
                                                                                            ),
                                                                                          )
                                                                                        : Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              datasTransaksi![index].discount ==
                                                                                                      0
                                                                                                  ? Text(
                                                                                                      FormatCurrency.convertToIdr(
                                                                                                        datasTransaksi![index].price_after,
                                                                                                      ).toString(),
                                                                                                      maxLines: 3,
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                      style: heading4(
                                                                                                        FontWeight.w400,
                                                                                                        bnw900,
                                                                                                        'Outfit',
                                                                                                      ),
                                                                                                    )
                                                                                                  : Text(
                                                                                                      FormatCurrency.convertToIdr(
                                                                                                        datasTransaksi![index].price_after,
                                                                                                      ).toString(),
                                                                                                      maxLines: 3,
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                      style: heading4(
                                                                                                        FontWeight.w400,
                                                                                                        danger500,
                                                                                                        'Outfit',
                                                                                                      ),
                                                                                                    ),
                                                                                            ],
                                                                                          ),
                                                                                  ),
                                                                                  bnw100,
                                                                                  bnw900,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Spacer(),
                                                                          Expanded(
                                                                            flex:
                                                                                2,
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
                                                                              child: GestureDetector(
                                                                                onTap: () async {
                                                                                  String productId = datasTransaksi![index].productid.toString();

                                                                                  if (cartProductIds.contains(
                                                                                    productId,
                                                                                  )) {
                                                                                    cartProductIds.remove(
                                                                                      productId,
                                                                                    );

                                                                                    for (
                                                                                      int index = 0;
                                                                                      index <
                                                                                          cart.length;
                                                                                      index++
                                                                                    ) {
                                                                                      if (cart[index].productid ==
                                                                                          productId) {
                                                                                        total.removeAt(
                                                                                          index,
                                                                                        );
                                                                                        cart.removeAt(
                                                                                          index,
                                                                                        );
                                                                                        cartMap.removeAt(
                                                                                          index,
                                                                                        );

                                                                                        if (cart.isEmpty) {
                                                                                          sumTotal = 0;
                                                                                        }
                                                                                        break;
                                                                                      }
                                                                                    }

                                                                                    isItemAdded = true;
                                                                                  } else {
                                                                                    cartProductIds.add(
                                                                                      productId,
                                                                                    );
                                                                                    isItemAdded = false;
                                                                                  }

                                                                                  if (!isItemAdded) {
                                                                                    // Navigator.pop(context);
                                                                                    Map<
                                                                                      String,
                                                                                      String
                                                                                    >
                                                                                    map1 = {};
                                                                                    map1['name'] = datasTransaksi![index].name.toString();
                                                                                    map1['productid'] = datasTransaksi![index].productid.toString();
                                                                                    // map1['quantity'] = '1';
                                                                                    map1['quantity'] = counterCart.toString();

                                                                                    map1['image'] = datasTransaksi![index].product_image.toString();

                                                                                    // log("${datasTransaksi![i]
                                                                                    //             .price_online_shop_after} ${datasTransaksi![i].price_after} asade ${datasTransaksi![i].price}");
                                                                                    map1['amount_display'] = datasTransaksi![index].price_online_shop.toString();
                                                                                    //                                  (datasTransaksi![i].price! * counterCart)
                                                                                    // (tapTrue == 2 ? datasTransaksi![index].price_online_shop : datasTransaksi![index].price!).toString();

                                                                                    //ubah transaksi
                                                                                    // datasTransaksi![i].price.toString();
                                                                                    map1['amount'] = datasTransaksi![index].price_online_shop.toString();
                                                                                    // datasTransaksi![i].price.toString();

                                                                                    // (tapTrue == 2 ? datasTransaksi![index].price_online_shop_after : datasTransaksi![index].price_after!).toString();

                                                                                    // log('hello ${datasTransaksi![i].price_online_shop} ${datasTransaksi![i].price!}');

                                                                                    map1['description'] = conCatatanPreview.text;
                                                                                    map1['id_request'] = '';
                                                                                    cartMap.add(
                                                                                      map1,
                                                                                    );

                                                                                    // log(datasTransaksi![i].product_image.toString());

                                                                                    String name = datasTransaksi![index].name.toString().trim();
                                                                                    String productid = datasTransaksi![index].productid.toString().trim();
                                                                                    String image = datasTransaksi![index].product_image.toString().trim();
                                                                                    // String desc = conCatatan[i]
                                                                                    //     .text
                                                                                    //     .toString()
                                                                                    //     .trim();

                                                                                    //int? price = ( datasTransaksi![i].price!);
                                                                                    num? price = datasTransaksi![index].price_online_shop_after!;
                                                                                    // num? price = (tapTrue == 2 ? datasTransaksi![index].price_online_shop_after! : datasTransaksi![index].price_after!);

                                                                                    int i = 0;
                                                                                    for (
                                                                                      i;
                                                                                      i <
                                                                                          cart.length;
                                                                                      i++
                                                                                    ) {}

                                                                                    // int? quantity = cart[i];

                                                                                    // log(name.toString());
                                                                                    // log(price.toString());
                                                                                    // log(productid.toString());
                                                                                    // log(image.toString());

                                                                                    sumTotal =
                                                                                        sumTotal +
                                                                                        (price *
                                                                                            counterCart);
                                                                                    // subTotal =
                                                                                    //     subTotal + price.toInt();
                                                                                    total.add(
                                                                                      price *
                                                                                          counterCart,
                                                                                    );

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
                                                                                        idRequest: "",
                                                                                        // quantity: cart[i]
                                                                                        //     .quantity
                                                                                        //     .toInt(),
                                                                                      ),
                                                                                    );

                                                                                    // selectedIndexTransaksi[index];
                                                                                  }
                                                                                  // refreshColor();
                                                                                  setState(
                                                                                    () {},
                                                                                  );
                                                                                  initState();
                                                                                },
                                                                                child:
                                                                                    cartProductIds.contains(
                                                                                      datasTransaksi![index].productid.toString(),
                                                                                    )
                                                                                    ? SizedBox()
                                                                                    : buttonL(
                                                                                        Center(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              datasTransaksi![index].discount ==
                                                                                                      0
                                                                                                  ? Text(
                                                                                                      FormatCurrency.convertToIdr(
                                                                                                        datasTransaksi![index].price_online_shop_after,
                                                                                                      ).toString(),
                                                                                                      maxLines: 3,
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                      style: heading4(
                                                                                                        FontWeight.w400,
                                                                                                        bnw900,
                                                                                                        'Outfit',
                                                                                                      ),
                                                                                                    )
                                                                                                  : Text(
                                                                                                      FormatCurrency.convertToIdr(
                                                                                                        datasTransaksi![index].price_online_shop_after,
                                                                                                      ).toString(),
                                                                                                      maxLines: 3,
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                      style: heading4(
                                                                                                        FontWeight.w400,
                                                                                                        danger500,
                                                                                                        'Outfit',
                                                                                                      ),
                                                                                                    ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        bnw100,
                                                                                        bnw900,
                                                                                      ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                size16,
                                                                          ),
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
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              :
                                                // ! grid produk
                                                Expanded(
                                                  child: RefreshIndicator(
                                                    color: bnw100,
                                                    backgroundColor: primary500,
                                                    onRefresh: () async {
                                                      setState(() {});
                                                      initState();
                                                    },
                                                    child: SingleChildScrollView(
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            child: GridView.builder(
                                                              shrinkWrap: true,
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              physics:
                                                                  BouncingScrollPhysics(),
                                                              itemCount:
                                                                  datasTransaksi!
                                                                      .length,
                                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                // mainAxisExtent:
                                                                //     null,
                                                                crossAxisCount:
                                                                    4,
                                                                crossAxisSpacing:
                                                                    size16,
                                                                mainAxisSpacing:
                                                                    size16,
                                                                childAspectRatio:
                                                                    0.60,
                                                              ),
                                                              itemBuilder: (context, i) {
                                                                // Create for consume api and get data
                                                                String
                                                                productSelect =
                                                                    datasTransaksi![i]
                                                                        .productid!;

                                                                String
                                                                productId =
                                                                    datasTransaksi![i]
                                                                        .productid
                                                                        .toString();
                                                                return // 🔹 Ambil productId di luar GestureDetector
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    String
                                                                    productId = datasTransaksi![i]
                                                                        .productid
                                                                        .toString();

                                                                    // ✅ Selalu tampilkan preview, walaupun produk sudah ada di cart
                                                                    showPriviewCart(
                                                                      context,
                                                                      i,
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                          size8,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          cart.any(
                                                                            (
                                                                              e,
                                                                            ) =>
                                                                                e.productid ==
                                                                                datasTransaksi![i].productid.toString(),
                                                                          )
                                                                          ? primary100
                                                                          : bnw100,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            size12,
                                                                          ),
                                                                      border: Border.all(
                                                                        color:
                                                                            cart.any(
                                                                              (
                                                                                e,
                                                                              ) =>
                                                                                  e.productid ==
                                                                                  datasTransaksi![i].productid.toString(),
                                                                            )
                                                                            ? primary500
                                                                            : bnw300,
                                                                        width:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                    child: Stack(
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(
                                                                                size8,
                                                                              ),
                                                                              child: AspectRatio(
                                                                                aspectRatio: 1,
                                                                                child: Image.network(
                                                                                  datasTransaksi![i].product_image.toString(),
                                                                                  fit: BoxFit.cover,
                                                                                  loadingBuilder:
                                                                                      (
                                                                                        context,
                                                                                        child,
                                                                                        loadingProgress,
                                                                                      ) {
                                                                                        if (loadingProgress ==
                                                                                            null)
                                                                                          return child;
                                                                                        return Center(
                                                                                          child: loading(),
                                                                                        );
                                                                                      },
                                                                                  errorBuilder:
                                                                                      (
                                                                                        context,
                                                                                        error,
                                                                                        stackTrace,
                                                                                      ) => SvgPicture.asset(
                                                                                        'assets/logoProduct.svg',
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height: size8,
                                                                            ),
                                                                            Text(
                                                                              datasTransaksi![i].name ??
                                                                                  '',
                                                                              style: heading4(
                                                                                FontWeight.w600,
                                                                                bnw900,
                                                                                'Outfit',
                                                                              ),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                            SizedBox(
                                                                              height: size4,
                                                                            ),
                                                                            Text(
                                                                              FormatCurrency.convertToIdr(
                                                                                datasTransaksi![i].price_after,
                                                                              ),
                                                                              style: heading4(
                                                                                FontWeight.w400,
                                                                                bnw900,
                                                                                'Outfit',
                                                                              ),
                                                                            ),
                                                                            datasTransaksi![i].discount ==
                                                                                    0
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
                                                                                      SizedBox(
                                                                                        width: size4,
                                                                                      ),
                                                                                      datasTransaksi![i].discount_type ==
                                                                                              'percentage'
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
                                                                            SizedBox(
                                                                              height: size4,
                                                                            ),
                                                                            Text(
                                                                              datasTransaksi![i].typeproducts.toString(),
                                                                              style: body1(
                                                                                FontWeight.w400,
                                                                                bnw500,
                                                                                'Outfit',
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),

                                                                        // 🛒 Badge merah jumlah produk
                                                                        if (cart.any(
                                                                          (e) =>
                                                                              e.productid ==
                                                                              datasTransaksi![i].productid.toString(),
                                                                        ))
                                                                          Positioned(
                                                                            right:
                                                                                4,
                                                                            top:
                                                                                4,
                                                                            child: Container(
                                                                              padding: EdgeInsets.all(
                                                                                6,
                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                color: danger500,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: Text(
                                                                                // ✅ Konversi quantity ke int agar tipe fold cocok
                                                                                '${cart.where((e) => e.productid == datasTransaksi![i].productid.toString()).fold<int>(0, (sum, item) => sum + (item.quantity as int))}',
                                                                                style: heading3(
                                                                                  FontWeight.w600,
                                                                                  bnw100,
                                                                                  'Outfit',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: size16,
                                                          ),
                                                          SizedBox(
                                                            child: FutureBuilder(
                                                              future:
                                                                  getCoinTransaksi(
                                                                    context,
                                                                    widget
                                                                        .token,
                                                                    '',
                                                                    [''],
                                                                  ),
                                                              builder: (context, snapshot) {
                                                                if (snapshot
                                                                    .hasData) {
                                                                  return GridView.builder(
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
                                                                      crossAxisCount:
                                                                          4,
                                                                      crossAxisSpacing:
                                                                          size16,
                                                                      mainAxisSpacing:
                                                                          size16,
                                                                      childAspectRatio:
                                                                          0.60,
                                                                    ),
                                                                    itemBuilder: (context, i) => GestureDetector(
                                                                      onTap: () async {
                                                                        var coin =
                                                                            snapshot.data[i];

                                                                        counterCart =
                                                                            1;
                                                                        String
                                                                        productId =
                                                                            coin['voucherid'].toString();

                                                                        conCatatanPreview.text =
                                                                            '';

                                                                        if (cartProductIds.contains(
                                                                          productId,
                                                                        )) {
                                                                          cartProductIds.remove(
                                                                            productId,
                                                                          );

                                                                          for (
                                                                            int
                                                                            index =
                                                                                0;
                                                                            index <
                                                                                cart.length;
                                                                            index++
                                                                          ) {
                                                                            if (cart[index].productid ==
                                                                                productId) {
                                                                              cart.removeAt(
                                                                                index,
                                                                              );
                                                                              cartMap.removeAt(
                                                                                index,
                                                                              );
                                                                              total.removeAt(
                                                                                index,
                                                                              );

                                                                              conCatatan.removeAt(
                                                                                index,
                                                                              );
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
                                                                            constraints: const BoxConstraints(
                                                                              maxWidth: double.infinity,
                                                                            ),
                                                                            useRootNavigator:
                                                                                false,
                                                                            isScrollControlled:
                                                                                true,
                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(
                                                                                size16,
                                                                              ),
                                                                            ),
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (
                                                                                  context,
                                                                                ) {
                                                                                  return Container(
                                                                                    padding: EdgeInsets.only(
                                                                                      bottom: MediaQuery.of(
                                                                                        context,
                                                                                      ).viewInsets.bottom,
                                                                                    ),
                                                                                    decoration: ShapeDecoration(
                                                                                      color: bnw100,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.only(
                                                                                          topLeft: Radius.circular(
                                                                                            size16,
                                                                                          ),
                                                                                          topRight: Radius.circular(
                                                                                            size16,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.fromLTRB(
                                                                                        size32,
                                                                                        size16,
                                                                                        size32,
                                                                                        size32,
                                                                                      ),
                                                                                      child: IntrinsicHeight(
                                                                                        child: Column(
                                                                                          children: [
                                                                                            dividerShowdialog(),
                                                                                            SingleChildScrollView(
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  SizedBox(
                                                                                                    height: size16,
                                                                                                  ),
                                                                                                  Container(
                                                                                                    decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.circular(
                                                                                                        size12,
                                                                                                      ),
                                                                                                      border: Border.all(
                                                                                                        color: bnw300,
                                                                                                      ),
                                                                                                    ),
                                                                                                    child: Column(
                                                                                                      children: [
                                                                                                        Padding(
                                                                                                          padding: EdgeInsets.all(
                                                                                                            size8,
                                                                                                          ),
                                                                                                          child: Column(
                                                                                                            children: [
                                                                                                              Row(
                                                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                                children: [
                                                                                                                  ClipRRect(
                                                                                                                    borderRadius: BorderRadius.circular(
                                                                                                                      size8,
                                                                                                                    ),
                                                                                                                    child: Container(
                                                                                                                      height: size120,
                                                                                                                      width: size120,
                                                                                                                      child: SvgPicture.asset(
                                                                                                                        'assets/logoProduct.svg',
                                                                                                                        fit: BoxFit.cover,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  SizedBox(
                                                                                                                    width: size12,
                                                                                                                  ),
                                                                                                                  Column(
                                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                    children: [
                                                                                                                      Text(
                                                                                                                        coin['namavoucher'] ??
                                                                                                                            '',
                                                                                                                        style: heading3(
                                                                                                                          FontWeight.w600,
                                                                                                                          bnw900,
                                                                                                                          'Outfit',
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      Text(
                                                                                                                        FormatCurrency.convertToIdr(
                                                                                                                          coin['price'],
                                                                                                                        ),
                                                                                                                        style: heading3(
                                                                                                                          FontWeight.w400,
                                                                                                                          bnw900,
                                                                                                                          'Outfit',
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      Text(
                                                                                                                        coin['typeproducts'] ??
                                                                                                                            '',
                                                                                                                        style: heading4(
                                                                                                                          FontWeight.w400,
                                                                                                                          bnw500,
                                                                                                                          'Outfit',
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                  Spacer(),
                                                                                                                  Column(
                                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                    children: [
                                                                                                                      Text(
                                                                                                                        'Jumlah',
                                                                                                                        style: heading3(
                                                                                                                          FontWeight.w400,
                                                                                                                          bnw900,
                                                                                                                          'Outfit',
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      SizedBox(
                                                                                                                        height: size8,
                                                                                                                      ),
                                                                                                                      Row(
                                                                                                                        children: [
                                                                                                                          GestureDetector(
                                                                                                                            onTap: () {
                                                                                                                              if (counterCart >
                                                                                                                                  1) {
                                                                                                                                counterCart--;
                                                                                                                                conCounterPreview.text = counterCart.toString();
                                                                                                                              }
                                                                                                                              setState(
                                                                                                                                () {},
                                                                                                                              );
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
                                                                                                                          SizedBox(
                                                                                                                            width: size8,
                                                                                                                          ),
                                                                                                                          SizedBox(
                                                                                                                            height: size48,
                                                                                                                            width: size56,
                                                                                                                            child: TextFormField(
                                                                                                                              cursorColor: primary500,
                                                                                                                              enabled: true,
                                                                                                                              controller: conCounterPreview,
                                                                                                                              keyboardType: TextInputType.number,
                                                                                                                              onChanged:
                                                                                                                                  (
                                                                                                                                    value,
                                                                                                                                  ) {
                                                                                                                                    setState(
                                                                                                                                      () {
                                                                                                                                        int parsedValue =
                                                                                                                                            int.tryParse(
                                                                                                                                              value,
                                                                                                                                            ) ??
                                                                                                                                            0;
                                                                                                                                        counterCart = parsedValue;
                                                                                                                                        conCounterPreview.text = counterCart.toString();
                                                                                                                                      },
                                                                                                                                    );
                                                                                                                                  },
                                                                                                                              textAlign: TextAlign.center,
                                                                                                                              decoration: InputDecoration(
                                                                                                                                // alignLabelWithHint: true,
                                                                                                                                hintText: counterCart.toString(),

                                                                                                                                // .toString(),
                                                                                                                                // _itemCount.toString(),
                                                                                                                                hintStyle: heading4(
                                                                                                                                  FontWeight.w600,
                                                                                                                                  bnw800,
                                                                                                                                  'Outfit',
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                          SizedBox(
                                                                                                                            width: size8,
                                                                                                                          ),
                                                                                                                          GestureDetector(
                                                                                                                            onTap: () {
                                                                                                                              counterCart++;
                                                                                                                              conCounterPreview.text = counterCart.toString();
                                                                                                                              setState(
                                                                                                                                () {},
                                                                                                                              );
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
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    height: size16,
                                                                                                  ),
                                                                                                  Container(
                                                                                                    child: Column(
                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                      children: [
                                                                                                        Text(
                                                                                                          'Catatan',
                                                                                                          style: body1(
                                                                                                            FontWeight.w500,
                                                                                                            bnw900,
                                                                                                            'Outfit',
                                                                                                          ),
                                                                                                        ),
                                                                                                        IntrinsicHeight(
                                                                                                          child: TextFormField(
                                                                                                            cursorColor: primary500,
                                                                                                            // keyboardType: numberNo,
                                                                                                            style: heading2(
                                                                                                              FontWeight.w600,
                                                                                                              bnw900,
                                                                                                              'Outfit',
                                                                                                            ),
                                                                                                            controller: conCatatanPreview,
                                                                                                            onChanged:
                                                                                                                (
                                                                                                                  value,
                                                                                                                ) {
                                                                                                                  // String formattedValue = formatCurrency(value);
                                                                                                                  // conHarga.value = TextEditingValue(
                                                                                                                  //   text: formattedValue,
                                                                                                                  //   selection:
                                                                                                                  //       TextSelection.collapsed(offset: formattedValue.length),
                                                                                                                  // );
                                                                                                                },
                                                                                                            decoration: InputDecoration(
                                                                                                              focusedBorder: UnderlineInputBorder(
                                                                                                                borderSide: BorderSide(
                                                                                                                  width: 2,
                                                                                                                  color: primary500,
                                                                                                                ),
                                                                                                              ),
                                                                                                              isDense: true,
                                                                                                              contentPadding: EdgeInsets.symmetric(
                                                                                                                vertical: size12,
                                                                                                              ),
                                                                                                              enabledBorder: UnderlineInputBorder(
                                                                                                                borderSide: BorderSide(
                                                                                                                  width: 1.5,
                                                                                                                  color: bnw500,
                                                                                                                ),
                                                                                                              ),
                                                                                                              hintText: 'Cth : Tambah ekstra topping Boba dan Gula 2 sendok',
                                                                                                              hintStyle: heading2(
                                                                                                                FontWeight.w600,
                                                                                                                bnw500,
                                                                                                                'Outfit',
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: size32,
                                                                                            ),
                                                                                            Row(
                                                                                              children: [
                                                                                                Expanded(
                                                                                                  child: GestureDetector(
                                                                                                    onTap: () {
                                                                                                      setState(
                                                                                                        () {},
                                                                                                      );
                                                                                                      Navigator.pop(
                                                                                                        context,
                                                                                                      );
                                                                                                    },
                                                                                                    child: buttonXLoutline(
                                                                                                      Center(
                                                                                                        child: Text(
                                                                                                          'Batalkan',
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
                                                                                                  width: size16,
                                                                                                ),
                                                                                                Expanded(
                                                                                                  child: GestureDetector(
                                                                                                    onTap: () {
                                                                                                      setState(
                                                                                                        () {
                                                                                                          String productId = coin['voucherid'];

                                                                                                          if (cartProductIds.contains(
                                                                                                            productId,
                                                                                                          )) {
                                                                                                            cartProductIds.remove(
                                                                                                              productId,
                                                                                                            );

                                                                                                            for (
                                                                                                              int index = 0;
                                                                                                              index <
                                                                                                                  cart.length;
                                                                                                              index++
                                                                                                            ) {
                                                                                                              if (cart[index].productid ==
                                                                                                                  productId) {
                                                                                                                cart.removeAt(
                                                                                                                  index,
                                                                                                                );
                                                                                                                cartMap.removeAt(
                                                                                                                  index,
                                                                                                                );
                                                                                                                total.removeAt(
                                                                                                                  index,
                                                                                                                );
                                                                                                                if (cart.isEmpty) {
                                                                                                                  sumTotal = 0;
                                                                                                                }
                                                                                                                break;
                                                                                                              }
                                                                                                            }

                                                                                                            isItemAdded = true;
                                                                                                          } else {
                                                                                                            cartProductIds.add(
                                                                                                              productId,
                                                                                                            );
                                                                                                            isItemAdded = false;
                                                                                                          }

                                                                                                          if (!isItemAdded) {
                                                                                                            Navigator.pop(
                                                                                                              context,
                                                                                                            );
                                                                                                            Map<
                                                                                                              String,
                                                                                                              String
                                                                                                            >
                                                                                                            map1 = {};
                                                                                                            map1['name'] = coin['namavoucher'];
                                                                                                            map1['productid'] = coin['voucherid'];
                                                                                                            // map1['quantity'] = '1';
                                                                                                            map1['quantity'] = counterCart.toString();

                                                                                                            map1['image'] = coin['product_image'];
                                                                                                            map1['amount'] =
                                                                                                                (coin['price'] *
                                                                                                                        counterCart)
                                                                                                                    .toString();
                                                                                                            map1['description'] = conCatatanPreview.text;
                                                                                                            map1['id_request'] = '';
                                                                                                            cartMap.add(
                                                                                                              map1,
                                                                                                            );

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
                                                                                                            for (
                                                                                                              index;
                                                                                                              index <
                                                                                                                  cart.length;
                                                                                                              index++
                                                                                                            ) {}

                                                                                                            // int? quantity = cart[i];

                                                                                                            // log(name.toString());
                                                                                                            // log(price.toString());
                                                                                                            // log(productid.toString());
                                                                                                            // log(image.toString());

                                                                                                            sumTotal =
                                                                                                                sumTotal +
                                                                                                                (price! *
                                                                                                                    counterCart);
                                                                                                            // subTotal =
                                                                                                            //     subTotal + price.toInt();
                                                                                                            total.add(
                                                                                                              price *
                                                                                                                  counterCart,
                                                                                                            );
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
                                                                                                                idRequest: "",
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
                                                                                                            cartMap.forEach(
                                                                                                              (
                                                                                                                element,
                                                                                                              ) {
                                                                                                                var myelement = int.parse(
                                                                                                                  element['amount']!,
                                                                                                                );
                                                                                                                totalku =
                                                                                                                    totalku +
                                                                                                                    (myelement *
                                                                                                                        counterCart);
                                                                                                              },
                                                                                                            );

                                                                                                            sumTotal = totalku;

                                                                                                            selectedIndexTransaksi[i];
                                                                                                          } else {
                                                                                                            // isItemAdded = false;
                                                                                                            // cartProductIds.remove(productSelect);
                                                                                                          }
                                                                                                        },
                                                                                                      );

                                                                                                      initState();
                                                                                                    },
                                                                                                    child: buttonXL(
                                                                                                      Center(
                                                                                                        child: Text(
                                                                                                          'Tambah Ke Keranjang',
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
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                          );
                                                                        }

                                                                        setState(
                                                                          () {},
                                                                        );
                                                                        initState();
                                                                      },
                                                                      child: Container(
                                                                        padding:
                                                                            EdgeInsets.all(
                                                                              size8,
                                                                            ),
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              cartProductIds.contains(
                                                                                snapshot.data[i]['voucherid'].toString(),
                                                                              )
                                                                              ? primary100
                                                                              : bnw100,
                                                                          borderRadius: BorderRadius.circular(
                                                                            size12,
                                                                          ),
                                                                          border: Border.all(
                                                                            // color: bnw900,
                                                                            color:
                                                                                cartProductIds.contains(
                                                                                  snapshot.data[i]['voucherid'].toString(),
                                                                                )
                                                                                ? primary500
                                                                                : bnw300,
                                                                            width:
                                                                                2,
                                                                          ),
                                                                        ),
                                                                        child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 3,
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  size8,
                                                                                ),
                                                                                child: SizedBox(
                                                                                  height:
                                                                                      double.infinity /
                                                                                      2,
                                                                                  width: double.infinity,
                                                                                  child:
                                                                                      snapshot.data![i]['product_image'] !=
                                                                                          null
                                                                                      ? ClipRRect(
                                                                                          borderRadius: BorderRadius.circular(
                                                                                            size8,
                                                                                          ),
                                                                                          child: Image.network(
                                                                                            snapshot.data![i]['product_image'].toString(),
                                                                                            height: size48,
                                                                                            width: size48,
                                                                                            fit: BoxFit.cover,
                                                                                            loadingBuilder:
                                                                                                (
                                                                                                  context,
                                                                                                  child,
                                                                                                  loadingProgress,
                                                                                                ) {
                                                                                                  if (loadingProgress ==
                                                                                                      null) {
                                                                                                    return child;
                                                                                                  }

                                                                                                  return Center(
                                                                                                    child: loading(),
                                                                                                  );
                                                                                                },
                                                                                            errorBuilder:
                                                                                                (
                                                                                                  context,
                                                                                                  error,
                                                                                                  stackTrace,
                                                                                                ) => Icon(
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
                                                                                    Text(
                                                                                      snapshot.data![i]['namavoucher'] ??
                                                                                          '',
                                                                                      style: heading4(
                                                                                        FontWeight.w700,
                                                                                        bnw900,
                                                                                        'Outfit',
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      snapshot.data![i]['point'].toString(),
                                                                                      style: body1(
                                                                                        FontWeight.w400,
                                                                                        bnw900,
                                                                                        'Outfit',
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      FormatCurrency.convertToIdr(
                                                                                        snapshot.data![i]['price'],
                                                                                      ),
                                                                                      style: body1(
                                                                                        FontWeight.w400,
                                                                                        bnw900,
                                                                                        'Outfit',
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
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
                            ),
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
                    borderRadius: BorderRadius.circular(size8),
                  ),
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
                              style: heading1(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
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
                                      size: 26,
                                    ),
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
                                                    'Outfit',
                                                  ),
                                                ),
                                                SizedBox(height: size16),
                                                Text(
                                                  'semua data akan terhapus',
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
                                                SizedBox(width: size16),
                                                Consumer<RefreshTampilan>(
                                                  builder: (context, value, child) => Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        List<String>
                                                        idRequests = [];

                                                        for (var item
                                                            in cartMap) {
                                                          idRequests.add(
                                                            item['id_request'] ??
                                                                'No ID Request',
                                                          );
                                                        }

                                                        print(
                                                          "id rikues $idRequests",
                                                        );

                                                        deleteTagihanKulasedaya(
                                                          context,
                                                          widget.token,
                                                          idRequests,
                                                        );
                                                        cart.clear();
                                                        cartMap.clear();
                                                        _pageController.jumpTo(
                                                          0,
                                                        );

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
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                      setState(() {});
                                    },
                                    child: Icon(
                                      PhosphorIcons.trash_fill,
                                      color: red500,
                                      size: 26,
                                    ),
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
                                    size: size24,
                                  ),
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
                                          child: Icon(
                                            PhosphorIcons.x,
                                            color: primary500,
                                            size: size24,
                                          ),
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
                                    FontWeight.w500,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                              ),
                            )
                          : Expanded(
                              child: Center(
                                child: ListView.builder(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
                                  ),
                                  // shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: cart.length,
                                  itemBuilder: (context, i) {
                                    var sum = total.reduce(
                                      (value, element) => value + element,
                                    );
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
                                                              BorderRadius.circular(
                                                                size8,
                                                              ),
                                                          child: Image.network(
                                                            cart[i].image
                                                                .toString(),
                                                            height: size48,
                                                            width: size48,
                                                            fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (
                                                                  context,
                                                                  child,
                                                                  loadingProgress,
                                                                ) {
                                                                  if (loadingProgress ==
                                                                      null) {
                                                                    return child;
                                                                  }

                                                                  return Center(
                                                                    child:
                                                                        loading(),
                                                                  );
                                                                },
                                                            errorBuilder:
                                                                (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) => SizedBox(
                                                                  // height: 227,
                                                                  // width: 227,
                                                                  child: SvgPicture.asset(
                                                                    'assets/logoProduct.svg',
                                                                  ),
                                                                ),
                                                          ),
                                                        )
                                                      : Icon(
                                                          PhosphorIcons.image,
                                                        ),
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
                                                        FormatCurrency.convertToIdr(
                                                          cart[i].price,
                                                        ),
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
                                                        enabled:
                                                            (cartMap[i]['productid'] ==
                                                                'digitalProduct')
                                                            ? false
                                                            : true,
                                                        cursorColor: primary500,
                                                        controller:
                                                            conCatatan[i],
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            cart[i].desc =
                                                                newValue;
                                                            cartMap[i]['description'] =
                                                                newValue;
                                                          });
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                              isDense: true,
                                                              hintText:
                                                                  'Catatan',
                                                              hintStyle:
                                                                  heading4(
                                                                    FontWeight
                                                                        .w400,
                                                                    bnw500,
                                                                    'Outfit',
                                                                  ),
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
                                                      if ((cartMap[i]['productid'] ==
                                                          'digitalProduct')) {
                                                        print(
                                                          "button Plus Dissable",
                                                        );
                                                        showModalBottomSheet(
                                                          constraints:
                                                              const BoxConstraints(
                                                                maxWidth: double
                                                                    .infinity,
                                                              ),
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          useRootNavigator:
                                                              false,
                                                          isScrollControlled:
                                                              true,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  size16,
                                                                ),
                                                          ),
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return Container(
                                                              width: double
                                                                  .infinity,
                                                              padding: EdgeInsets.only(
                                                                bottom:
                                                                    MediaQuery.of(
                                                                          context,
                                                                        )
                                                                        .viewInsets
                                                                        .bottom,
                                                              ),
                                                              decoration: ShapeDecoration(
                                                                color: bnw100,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.only(
                                                                    topLeft:
                                                                        Radius.circular(
                                                                          size16,
                                                                        ),
                                                                    topRight:
                                                                        Radius.circular(
                                                                          size16,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets.fromLTRB(
                                                                      size32,
                                                                      size16,
                                                                      size32,
                                                                      size32,
                                                                    ),
                                                                child: IntrinsicHeight(
                                                                  child: Column(
                                                                    children: [
                                                                      SvgPicture.asset(
                                                                        'assets/newIllustration/Help.svg',
                                                                        height:
                                                                            200,
                                                                        width:
                                                                            200,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            size12,
                                                                      ),
                                                                      Text(
                                                                        'Silahkan buka menu Produk Digital pada "Kuston", didalam keranjang untuk menghapus Item ini',
                                                                        style: heading2(
                                                                          FontWeight
                                                                              .w600,
                                                                          bnw900,
                                                                          'Outfit',
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            size12,
                                                                      ),
                                                                      SizedBox(
                                                                        width: double
                                                                            .infinity,
                                                                        child: GestureDetector(
                                                                          onTap: () {
                                                                            setState(
                                                                              () {},
                                                                            );
                                                                            Navigator.pop(
                                                                              context,
                                                                            );
                                                                          },
                                                                          child: buttonXLoutline(
                                                                            Center(
                                                                              child: Text(
                                                                                'Batalkan',
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
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        cart[i].quantity--;

                                                        num newQuantity =
                                                            cart[i].quantity;
                                                        cartMap[i]['quantity'] =
                                                            newQuantity
                                                                .toString();
                                                        cartMap[i]['amount'] =
                                                            (cart[i].price!)
                                                                .toString();

                                                        // Update the total list
                                                        total[i] =
                                                            newQuantity *
                                                            cart[i].price!;

                                                        // Recalculate sumTotal
                                                        sumTotal = total.reduce(
                                                          (a, b) => a + b,
                                                        );

                                                        // Jika quantity kurang dari 1, hapus item dari semua list terkait
                                                        // Jika quantity kurang dari 1, hapus item dari semua list terkait
                                                        if (cart[i].quantity <
                                                            1) {
                                                          // Hapus elemen dari semua daftar secara sinkron
                                                          String? productId =
                                                              cart[i].productid;

                                                          // Hapus dari cartProductIds berdasarkan productId
                                                          int indexToRemove =
                                                              cartProductIds
                                                                  .indexWhere(
                                                                    (id) =>
                                                                        id ==
                                                                        productId,
                                                                  );
                                                          if (indexToRemove !=
                                                              -1) {
                                                            cartProductIds
                                                                .removeAt(
                                                                  indexToRemove,
                                                                );
                                                          }

                                                          // Hapus elemen dari semua daftar berdasarkan indeks i
                                                          cart.removeAt(i);
                                                          if (i <
                                                              cartMap.length) {
                                                            cartMap.removeAt(i);
                                                          }
                                                          if (i <
                                                              total.length) {
                                                            total.removeAt(i);
                                                          }
                                                          if (i <
                                                              conCatatan
                                                                  .length) {
                                                            conCatatan.removeAt(
                                                              i,
                                                            );
                                                          }

                                                          // Reset variabel tampilan
                                                          conCounterPreview
                                                              .clear();
                                                          conCatatanPreview
                                                                  .text =
                                                              '';
                                                          isItemAdded = false;

                                                          // Refresh tampilan setelah data diperbarui
                                                          setState(() {});
                                                        }

                                                        refreshColor();

                                                        setState(() {});
                                                        // initState();j
                                                      }
                                                    },
                                                  ),
                                                  SizedBox(width: size8),
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 38,
                                                      child: TextFormField(
                                                        cursorColor: primary500,
                                                        enabled: false,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration: InputDecoration(
                                                          // alignLabelWithHint: true,
                                                          hintText: cart[i]
                                                              .quantity
                                                              .toString(),
                                                          // _itemCount.toString(),
                                                          hintStyle: heading4(
                                                            FontWeight.w600,
                                                            bnw800,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: size8),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if ((cartMap[i]['productid'] ==
                                                          'digitalProduct')) {
                                                        print(
                                                          "button Plus Dissable",
                                                        );
                                                      } else {
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
                                                        total[i] =
                                                            newquantity *
                                                            cart[i].price!;

                                                        // Recalculate sumTotal
                                                        sumTotal = total.reduce(
                                                          (a, b) => a + b,
                                                        );

                                                        // No need to check if the quantity is less than 1

                                                        refreshColor();

                                                        setState(() {});
                                                      }
                                                    },
                                                    child: buttonMoutlineColor(
                                                      Icon(
                                                        PhosphorIcons.plus,
                                                        color:
                                                            (cartMap[i]['productid'] ==
                                                                'digitalProduct')
                                                            ? bnw300
                                                            : primary500,
                                                        size: size24,
                                                      ),
                                                      (cartMap[i]['productid'] ==
                                                              'digitalProduct')
                                                          ? bnw300
                                                          : primary500,
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
                                        vertical: size16,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: bnw900,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Sub Total',
                                            style: heading3(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                          Text(
                                            FormatCurrency.convertToIdr(
                                              sumTotal,
                                            ),
                                            style: heading3(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
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
                                          FontWeight.w600,
                                          bnw900,
                                          'Outfit',
                                        ),
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
                                        String typePrice = "price";
                                        if (tapTrue == 1) {
                                          typePrice = "price";
                                        } else if (typePrice == 2) {
                                          typePrice = "price_online_shop    ";
                                        }
                                        print(tapTrue);
                                        print("aku adalah data $cartMap");

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
                                            style: heading3(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
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
                                    // log(cartMap.toString());

                                    // String typePrice = "price";
                                    // if (tapTrue == 1) {
                                    //   typePrice = "price";
                                    // } else if (typePrice == 2) {
                                    //   typePrice = "price_online_shop    ";
                                    // }
                                    // print(tapTrue);
                                    print("test log $cartMap");

                                    await calculateTransaction(
                                      context,
                                      widget.token,
                                      cartMap,
                                      setState,
                                      pelangganId,
                                      '',
                                      '',
                                      '',
                                    ).then((value) {
                                      if (cartMap.isNotEmpty && value == '00') {
                                        discountName = "";
                                        discountId = "";
                                        _pageController.nextPage(
                                          duration: Duration(milliseconds: 10),
                                          curve: Curves.ease,
                                        );
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
                                          style: heading2(
                                            FontWeight.w600,
                                            bnw100,
                                            'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                    // cartMap.isEmpty ? bnw100 : primary500,
                                    double.infinity,
                                  ),
                                )
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
        ),
      ],
    );
  }

  Map<String, List<Map<String, dynamic>>> selectedVariantsByProduct = {};

  Future<dynamic> showPriviewCart(BuildContext context, int i) {
    setState(() {
      selectedVariantsByProduct.clear();
    });
    conCounterPreview.text = '1';
    conCatatanPreview.text = '';

    tapTrue = 1;

    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      useRootNavigator: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size16),
      ),
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
            child: Expanded(
              child: Column(
                children: [
                  dividerShowdialog(),
                  StatefulBuilder(
                    builder: (context, setState) => Expanded(
                      child: ListView(
                        children: [
                          SizedBox(height: size16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(size12),
                              border: Border.all(color: bnw300),
                            ),
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
                                              datasTransaksi![i].product_image
                                                  .toString(),
                                              fit: BoxFit.cover,
                                              loadingBuilder:
                                                  (
                                                    context,
                                                    child,
                                                    loadingProgress,
                                                  ) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }

                                                    return Center(
                                                      child: loading(),
                                                    );
                                                  },
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
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
                                                datasTransaksi![i].name ?? '',
                                                style: heading3(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              Text(
                                                FormatCurrency.convertToIdr(
                                                  tapTrue == 1
                                                      ? datasTransaksi![i]
                                                            .price_after
                                                      : datasTransaksi![i]
                                                            .price_online_shop_after,
                                                ),
                                                style: heading3(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              Text(
                                                datasTransaksi![i]
                                                        .typeproducts ??
                                                    '',
                                                style: heading4(
                                                  FontWeight.w400,
                                                  bnw500,
                                                  'Outfit',
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Jumlah',
                                                style: body1(
                                                  FontWeight.w500,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              SizedBox(height: size8),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (counterCart > 1) {
                                                        counterCart--;
                                                        conCounterPreview.text =
                                                            counterCart
                                                                .toString();
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
                                                      cursorColor: primary500,
                                                      enabled: true,
                                                      controller:
                                                          conCounterPreview,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          int parsedValue =
                                                              int.tryParse(
                                                                value,
                                                              ) ??
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
                                                      decoration: InputDecoration(
                                                        // alignLabelWithHint: true,
                                                        hintText: counterCart
                                                            .toString(),

                                                        // .toString(),
                                                        // _itemCount.toString(),
                                                        hintStyle: heading4(
                                                          FontWeight.w600,
                                                          bnw800,
                                                          'Outfit',
                                                        ),
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size16),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Varian Harga',
                                  style: body1(
                                    FontWeight.w500,
                                    bnw900,
                                    'Outfit',
                                  ),
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
                                              horizontal: size20,
                                            ),
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
                                                      size8,
                                                    ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Normal',
                                                  style: heading3(
                                                    FontWeight.w400,
                                                    tapTrue == 1
                                                        ? primary500
                                                        : bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
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
                                              horizontal: size20,
                                            ),
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
                                                      size8,
                                                    ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Online',
                                                  style: heading3(
                                                    FontWeight.w400,
                                                    tapTrue == 2
                                                        ? primary500
                                                        : bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size16),

                                //tulis disiini
                                FutureBuilder<List<ProductVariantCategory>?>(
                                  future: getProductVariantTransaksi(
                                    context,
                                    widget.token,
                                    '',
                                    datasTransaksi![i].productid.toString(),
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(child: loading());
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        "Terjadi kesalahan: ${snapshot.error}",
                                      );
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Text(
                                        "Tidak ada varian untuk produk ini",
                                        style: heading3(
                                          FontWeight.w400,
                                          bnw500,
                                          'Outfit',
                                        ),
                                      );
                                    }

                                    final data = snapshot.data!;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: data.map((variantCategory) {
                                        // state lokal tiap kategori
                                        List<bool> selected = List.generate(
                                          variantCategory
                                              .productVariants
                                              .length,
                                          (_) => false,
                                        );
                                        int selectedCount = 0;

                                        return StatefulBuilder(
                                          builder: (context, setStateVariant) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  variantCategory.title,
                                                  style: body1(
                                                    FontWeight.w600,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                                SizedBox(height: size4),
                                                Text(
                                                  variantCategory.isRequired ==
                                                          1
                                                      ? "Wajib dipilih - Maks pilih ${variantCategory.maximumSelected}"
                                                      : "Opsional dipilih - Maks pilih ${variantCategory.maximumSelected}",
                                                  style: body2(
                                                    FontWeight.w400,
                                                    Colors.red,
                                                    'Outfit',
                                                  ),
                                                ),
                                                SizedBox(height: size12),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          size8,
                                                        ),
                                                    border: Border.all(
                                                      color: bnw300,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: List.generate(
                                                      variantCategory
                                                          .productVariants
                                                          .length,
                                                      (index) {
                                                        final opt = variantCategory
                                                            .productVariants[index];
                                                        return CheckboxListTile(
                                                          value:
                                                              selected[index],
                                                          onChanged: (value) {
                                                            setStateVariant(() {
                                                              // Handle maksimum pilihan
                                                              if (variantCategory
                                                                      .maximumSelected ==
                                                                  1) {
                                                                for (
                                                                  int j = 0;
                                                                  j <
                                                                      selected
                                                                          .length;
                                                                  j++
                                                                ) {
                                                                  selected[j] =
                                                                      false;
                                                                }
                                                              } else {
                                                                final totalSelected =
                                                                    selected
                                                                        .where(
                                                                          (e) =>
                                                                              e,
                                                                        )
                                                                        .length;
                                                                if (value ==
                                                                        true &&
                                                                    totalSelected >=
                                                                        variantCategory
                                                                            .maximumSelected) {
                                                                  showSnackbar(
                                                                    context,
                                                                    "Maksimum ${variantCategory.maximumSelected} varian dipilih",
                                                                  );
                                                                  return;
                                                                }
                                                              }

                                                              selected[index] =
                                                                  value ??
                                                                  false;
                                                              selectedCount =
                                                                  selected
                                                                      .where(
                                                                        (e) =>
                                                                            e,
                                                                      )
                                                                      .length;

                                                              String productId =
                                                                  datasTransaksi![i]
                                                                      .productid
                                                                      .toString();

                                                              // 🔹 Ambil list varian untuk produk ini (kalau belum ada, buat baru)
                                                              selectedVariantsByProduct[productId] ??=
                                                                  [];

                                                              // Hapus dulu varian dari kategori ini (biar gak dobel)
                                                              selectedVariantsByProduct[productId]!
                                                                  .removeWhere(
                                                                    (e) =>
                                                                        e['variant_category_id'] ==
                                                                        variantCategory
                                                                            .id
                                                                            .toString(),
                                                                  );

                                                              // 🔹 Buat list variant_id yang dipilih di kategori ini
                                                              List<String>
                                                              selectedIds = [];
                                                              List<
                                                                Map<
                                                                  String,
                                                                  dynamic
                                                                >
                                                              >
                                                              variantDetails =
                                                                  [];

                                                              for (
                                                                int j = 0;
                                                                j <
                                                                    selected
                                                                        .length;
                                                                j++
                                                              ) {
                                                                if (selected[j]) {
                                                                  final v =
                                                                      variantCategory
                                                                          .productVariants[j];
                                                                  selectedIds
                                                                      .add(
                                                                        v.id,
                                                                      );
                                                                  variantDetails.add({
                                                                    "variant_id":
                                                                        v.id,
                                                                    "variant_name":
                                                                        v.name,
                                                                    "variant_price":
                                                                        num.tryParse(
                                                                          v.price,
                                                                        ) ??
                                                                        0,
                                                                    "is_online":
                                                                        false,
                                                                  });

                                                                  print(
                                                                    '🧩 Varian dipilih: ${v.name} (${v.price})',
                                                                  );
                                                                }
                                                              }

                                                              if (selectedIds
                                                                  .isNotEmpty) {
                                                                selectedVariantsByProduct[productId]!.add({
                                                                  "variant_category_id":
                                                                      variantCategory
                                                                          .id
                                                                          .toString(),
                                                                  "variant_id":
                                                                      selectedIds,
                                                                  "variant_detail":
                                                                      variantDetails, // 🆕 simpan detail langsung di sini
                                                                });
                                                              } else {
                                                                // Kalau kosong, hapus kategori dari map
                                                                selectedVariantsByProduct[productId]!.removeWhere(
                                                                  (e) =>
                                                                      e['variant_category_id'] ==
                                                                      variantCategory
                                                                          .id
                                                                          .toString(),
                                                                );
                                                              }

                                                              print(
                                                                '✅ Selected variants for $productId: '
                                                                '${jsonEncode(selectedVariantsByProduct[productId])}',
                                                              );
                                                            });
                                                          },
                                                          activeColor:
                                                              primary500,
                                                          title: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  opt.name,
                                                                  style: heading3(
                                                                    FontWeight
                                                                        .w400,
                                                                    bnw900,
                                                                    'Outfit',
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${FormatCurrency.convertToIdr(double.tryParse(opt.price) ?? 0)}',
                                                                style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          controlAffinity:
                                                              ListTileControlAffinity
                                                                  .trailing,
                                                          contentPadding:
                                                              EdgeInsets.symmetric(
                                                                horizontal:
                                                                    size8,
                                                              ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: size8),
                                                Text(
                                                  "$selectedCount dari ${variantCategory.productVariants.length}",
                                                  style: heading4(
                                                    FontWeight.w400,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                                SizedBox(height: size24),
                                              ],
                                            );
                                          },
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),

                                SizedBox(height: size16),
                                Text(
                                  'Catatan',
                                  style: body1(
                                    FontWeight.w500,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                IntrinsicHeight(
                                  child: TextFormField(
                                    cursorColor: primary500,
                                    // keyboardType: numberNo,
                                    style: heading2(
                                      FontWeight.w600,
                                      bnw900,
                                      'Outfit',
                                    ),
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
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 2,
                                          color: primary500,
                                        ),
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: size12,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 1.5,
                                          color: bnw500,
                                        ),
                                      ),
                                      hintText:
                                          'Cth : Tambah ekstra topping Boba dan Gula 2 sendok',
                                      hintStyle: heading2(
                                        FontWeight.w600,
                                        bnw500,
                                        'Outfit',
                                      ),
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
                            for (var product in datasTransaksi!) {
                              print('Produk: ${product.name}');
                              for (var cat in product.variants) {
                                print(
                                  '  Kategori: ${cat.variantCategoryTitle}',
                                );
                                for (var opt in cat.variants) {
                                  print(
                                    '    - ${opt.variantProductName} (Rp${opt.variantProductPrice})',
                                  );
                                }
                              }
                            }

                            Navigator.pop(context);
                          },
                          child: buttonXLoutline(
                            Center(
                              child: Text(
                                'Batalkan',
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
                            setState(() {
                              if (tapTrue == 0) tapTrue = 1;

                              String productId = datasTransaksi![i].productid
                                  .toString();
                              String name = datasTransaksi![i].name
                                  .toString()
                                  .trim();
                              String image = datasTransaksi![i].product_image
                                  .toString()
                                  .trim();

                              num basePrice = (tapTrue == 2
                                  ? datasTransaksi![i].price_online_shop_after!
                                  : datasTransaksi![i].price_after!);

                              num totalVariantPrice = 0;
                              List<Map<String, dynamic>>? selectedVariantList =
                                  selectedVariantsByProduct[productId];

                              if (selectedVariantList != null &&
                                  selectedVariantList.isNotEmpty) {
                                for (var variantCat in selectedVariantList) {
                                  List<dynamic>? details =
                                      variantCat['variant_detail'];
                                  if (details != null && details.isNotEmpty) {
                                    for (var detail in details) {
                                      final hargaVarian =
                                          num.tryParse(
                                            detail['variant_price'].toString(),
                                          ) ??
                                          0;
                                      totalVariantPrice += hargaVarian;
                                    }
                                  }
                                }
                              }

                              num finalPrice = basePrice + totalVariantPrice;

                              // 🆕 Buat "signature" unik dari kombinasi
                              String variantSignature = jsonEncode(
                                selectedVariantList ?? [],
                              );
                              String catatan = conCatatanPreview.text.trim();
                              String signature =
                                  "$productId|$variantSignature|$catatan|$tapTrue";

                              // 🧾 Cek apakah item dengan kombinasi ini sudah ada
                              int existingIndex = cart.indexWhere(
                                (e) =>
                                    e.productid == productId &&
                                    (cartMap[cart.indexOf(e)]['variants'] ??
                                            '[]') ==
                                        variantSignature &&
                                    e.desc == catatan &&
                                    (cartMap[cart.indexOf(e)]['is_online'] ??
                                            'false') ==
                                        (tapTrue == 2 ? 'true' : 'false'),
                              );

                              if (existingIndex != -1) {
                                // ✅ Item dengan varian & catatan yang sama → tambah qty
                                cart[existingIndex].quantity += counterCart;
                                total[existingIndex] =
                                    cart[existingIndex].price! *
                                    cart[existingIndex].quantity;
                                sumTotal = total.fold(0, (a, b) => a + b);

                                cartMap[existingIndex]['quantity'] =
                                    cart[existingIndex].quantity.toString();
                              } else {
                                // 🆕 Item baru → tambahkan baris baru
                                sumTotal += (finalPrice * counterCart);
                                total.add(finalPrice * counterCart);

                                conCatatan.add(
                                  TextEditingController(text: catatan),
                                );

                                cart.add(
                                  CartTransaksi(
                                    name: name,
                                    productid: productId,
                                    image: image,
                                    price: finalPrice,
                                    quantity: counterCart,
                                    desc: catatan,
                                    idRequest: "",
                                    variants:
                                        selectedVariantList != null &&
                                            selectedVariantList.isNotEmpty
                                        ? jsonEncode(
                                            selectedVariantList,
                                          ) // Encode list of variants to JSON string
                                        : null, // Jika tidak ada variants, set ke null
                                  ),
                                );

                                // for (var cartItem in cart) {
                                //   print(
                                //     'Cart Item: ${cartItem.name}, Variants: ${cartItem.variants}',
                                //   );
                                // }

                                // print('ini adalah cart baru ${cart}');

                                cartProductIds.add(productId);

                                Map<String, String> map1 = {};
                                map1['name'] = name;
                                map1['product_id'] = productId;
                                map1['quantity'] = counterCart.toString();
                                map1['image'] = image;
                                map1['amount_display'] = finalPrice.toString();
                                map1['amount'] = finalPrice.toString();
                                map1['description'] = catatan;
                                map1['id_request'] = '';
                                map1['is_online'] = tapTrue == 2
                                    ? 'true'
                                    : 'false';

                                // Menambahkan variants jika ada
                                map1['variants'] =
                                    selectedVariantList != null &&
                                        selectedVariantList!.isNotEmpty
                                    ? jsonEncode(selectedVariantList)
                                    : '[]';
                                cartMap.add(map1);
                                print('🆕 Produk baru ditambahkan: ${cartMap}');
                              }

                              Navigator.pop(context);
                            });
                          },
                          child: buttonXL(
                            Center(
                              child: Text(
                                'Tambah Ke Keranjang',
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
        );
      },
    );
  }

  Future<dynamic> pilihPembeliShowBottom(BuildContext context, index) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
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
                  Text(
                    'Pilih Tipe Pembeli',
                    style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(PhosphorIcons.x, color: bnw900, size: size32),
                  ),
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
                              Text(
                                'Pelanggan',
                                style: heading2(
                                  FontWeight.w700,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
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
                            constraints: const BoxConstraints(
                              maxWidth: double.infinity,
                            ),
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder: (context, setState) => IntrinsicHeight(
                                child: Container(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: size16),
                                            Text(
                                              'Pilih Pembeli',
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
                                                  'Nama Pembeli ',
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
                                              cursorColor: primary500,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      vertical: size12,
                                                    ),
                                                isDense: true,
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            size8,
                                                          ),
                                                      borderSide: BorderSide(
                                                        width: 2,
                                                        color: primary500,
                                                      ),
                                                    ),
                                                focusColor: primary500,
                                                hintText:
                                                    'Cth : Muhammad Nabil Musyaffa',
                                                hintStyle: heading2(
                                                  FontWeight.w600,
                                                  bnw400,
                                                  'Outfit',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height:
                                              controllerPelangganName
                                                  .text
                                                  .isNotEmpty
                                              ? size32
                                              : 0,
                                        ),
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
                                                          context,
                                                          index,
                                                        );
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
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width,
                                                        primary500,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: size16),
                                                  Expanded(
                                                    child: Consumer<RefreshTampilan>(
                                                      builder:
                                                          (
                                                            context,
                                                            value,
                                                            child,
                                                          ) => GestureDetector(
                                                            onTap: () {
                                                              pelangganId =
                                                                  controllerPelangganName
                                                                      .text;
                                                              value.namaPelanggan =
                                                                  controllerPelangganName
                                                                      .text;
                                                              Navigator.pop(
                                                                context,
                                                              );
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
                              Text(
                                'Bukan Pelanggan',
                                style: heading2(
                                  FontWeight.w700,
                                  bnw900,
                                  'Outfit',
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

  List? typeproductList;
  List<dynamic>? searchResultListProduct;

  dynamic selectedProduct;
  bool isItemSelected = false;

  Future _getProductList() async {
    await Future.delayed(Duration(seconds: 2));
    await http
        .post(
          Uri.parse(diskonTransaksiLink),
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
      if (selectedProduct == product) {
        selectedProduct = null;
        isItemSelected = false;
        discountId = '';
        discountName = '';
      } else {
        selectedProduct = product;
        isItemSelected = true;
        discountId = product['id'];
        discountName = product['name'];
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
