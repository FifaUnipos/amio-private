import 'dart:convert';
import 'dart:developer';import '../../../../utils/component/component_showModalBottom.dart';
import 'dart:io' as Io;
import 'dart:io';
import 'diskonToko.dart';
import 'tambahDiskonToko.dart';
import 'ubahDiskon.dart';
import 'ubahPromosi.dart';
import '../../../../utils/component/skeletons.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../../../utils/component/component_orderBy.dart';
import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../models/tokoModel/transaksiTokoModel.dart';

import '../../../../main.dart';
import '../../../../models/produkmodel.dart';
import '../../../../models/promosiModel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';

import '../../../home/sidebar/tokoPage/ubahToko.dart';import '../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';
class PromosiToko extends StatefulWidget {
  String token;
  PromosiToko({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<PromosiToko> createState() => _PromosiTokoState();
}

class _PromosiTokoState extends State<PromosiToko>
    with TickerProviderStateMixin {
  List<ModelDataPromosi>? datasProduk;

  PageController _pageController = PageController();
  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};
  List<String> listProduct = List.empty(growable: true);

  TabController? _tabController;

  String textOrderBy = 'Nama Voucher A ke Z';
  String textvalueOrderBy = 'upDownNama';

  TextEditingController conNameProduk = TextEditingController();
  TextEditingController conHarga = TextEditingController();
  TextEditingController conPoint = TextEditingController();

  void formatInputRpHarga() {
    String text = conHarga.text.replaceAll('.', '');
    int value = int.tryParse(text)!;
    String formattedAmount = formatCurrency(value);

    conHarga.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  void formatInputRpPoin() {
    String text = conPoint.text.replaceAll('.', '');
    int value = int.tryParse(text)!;
    String formattedAmount = formatCurrency(value);

    conPoint.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  List<String>? productIdCheckAll;
  String checkFill = 'kosong';

  @override
  void initState() {
    checkConnection(context);
    img64 = null;
    nameEditPromosi = '';
    poinEditPromosi = '';
    hargaProductPromosi = '';

    _tabController = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        List<String> value = [''];

        await getDataProduk();

        setState(() {
          // log(datasProduk.toString());
          datasProduk;
        });

        _pageController = PageController(
          initialPage: 0,
          keepPage: true,
          viewportFraction: 1,
        );
      },
    );
    _getProvinceList();

    conHarga.addListener(formatInputRpHarga);
    conPoint.addListener(formatInputRpPoin);
    super.initState();
  }

  Future<dynamic> getDataProduk() async {
    return datasProduk = await getVoucher(
      context,
      widget.token,
      textvalueOrderBy,
      '',
    );
  }

  refreshDataProduk() {
    datasProduk;
    conNameProduk.text = '';
    conHarga.text = '';
    conPoint.text = '';
    isSelectionMode = false;
    listProduct = [];
    listProduct.clear();
    selectedFlag.clear();
    setState(() {});
  }

  @override
  dispose() {
    productPrice;
    _pageController.dispose();
    conNameProduk.dispose();
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

  String? jenisProduct, idProduct;

  bool onswitchtampikan = true;
  String kasirAktif = "Aktif";

  String? imageEdit, nameEdit, kategoriEdit, hargaEdit;
  String? singleProductId;

  double width = 100;

  @override
  Widget build(BuildContext context) {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    bool light = true;

    return WillPopScope(
      onWillPop: () async {
        if (_tabController!.index.round() == 0 &&
            _pageController.page!.round() == 0) {
          showModalBottomExit(context);
          return false;
        } else {
          _pageController.jumpToPage(0);
          // _tabController!.animateTo(0);
          // if(_tabController!.index.round() == 1){
          //   _tabController!.animateTo(0);
          // }
          return false;
        }
      },
      child: StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Container(
            margin: EdgeInsets.all(size16),
            padding: EdgeInsets.all(size16),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.circular(size16),
            ),
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                pageProdukToko(isFalseAvailable),
                tambahProdukToko(setState, context),
                UbahPromosiPage(
                  token: widget.token,
                  pageController: _pageController,
                  productid: singleProductId ?? '',
                ),
                TambahDiskonPage(
                  token: widget.token,
                  pageController: _pageController,
                ),
                UbahDiskonPage(
                  token: widget.token,
                  pageController: _pageController,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  tambahProdukToko(StateSetter setState, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _pageController.previousPage(
                      duration: Duration(milliseconds: 10), curve: Curves.ease);
                  refreshDataProduk();
                  initState();
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
                    'Tambah Voucher',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Voucher akan ditambahkan kedalam Toko yang telah dipilih',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: size16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                fieldAddProduk(
                  'Nama Voucher',
                  'Matcha Latte Cappuchino',
                  conNameProduk,
                  TextInputType.text,
                ),
                SizedBox(height: size16),
                fieldAddProduk(
                  'Poin Voucher',
                  'Rp. 12.000',
                  conPoint,
                  TextInputType.number,
                ),
                SizedBox(height: size16),
                fieldAddProduk(
                  'Harga Jual',
                  'Rp. 12.000',
                  conHarga,
                  TextInputType.number,
                ),
                SizedBox(height: size16),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
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
                        width: 52.0,
                        height: 28.0,
                        value: onswitchtampikan,
                        padding: 0,
                        activeIcon:
                            Icon(PhosphorIcons.check, color: primary500),
                        inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                        activeColor: primary500,
                        inactiveColor: bnw100,
                        borderRadius: 30.0,
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
                          // log(onswitchtampikan.toString());
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
          SizedBox(height: size12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    createVoucher(
                      context,
                      widget.token,
                      conNameProduk.text,
                      onswitchtampikan.toString(),
                      conHarga.text,
                      conPoint.text,
                      '',
                      _pageController,
                    );
                    refreshDataProduk();
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
                    List<String> value = [""];
                    print('himak');
                    createVoucher(
                      context,
                      widget.token,
                      conNameProduk.text,
                      onswitchtampikan.toString(),
                      conHarga.text.replaceAll(RegExp(r'[^0-9]'), ''),
                      conPoint.text.replaceAll(RegExp(r'[^0-9]'), ''),
                      '',
                      _pageController,
                    ).then((value) {
                      if (value == '00') {
                        refreshDataProduk();
                        _pageController.jumpToPage(0);
                      }
                    });
                    setState(() {});
                    initState();
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
                  'Promo',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  nameToko ?? '',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // _tabController!.index == 0
                    //     ? _pageController.nextPage(
                    //         duration: Duration(milliseconds: 10),
                    //         curve: Curves.ease)
                    //     : _pageController.jumpToPage(3);
                    _pageController.jumpToPage(3);
                  },
                  child: buttonXL(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(PhosphorIcons.plus, color: bnw100),
                        SizedBox(width: size12),
                        Text(
                          // _tabController!.index == 0 ? 'Voucher' : 'Diskon',
                          'Diskon',
                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ],
                    ),
                    130,
                  ),
                )
              ],
            ),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: _tabController,
                  automaticIndicatorColorAdjustment: false,
                  indicatorColor: primary500,
                  unselectedLabelColor: bnw600,
                  labelColor: primary500,
                  labelStyle: heading2(FontWeight.w400, bnw900, 'Outfit'),
                  physics: NeverScrollableScrollPhysics(),
                  onTap: (value) {
                    if (value == 0) {
                      // _pageController.animateToPage(
                      //   0,
                      //   duration: Duration(milliseconds: 10),
                      //   curve: Curves.ease,
                      // );
                    } else if (value == 1) {
                      // _pageController.animateToPage(
                      //   2,
                      //   duration: Duration(milliseconds: 10),
                      //   curve: Curves.ease,
                      // );
                    }
                    setState(() {});
                  },
                  tabs: [
                    // Tab(
                    //   text: 'Voucher',
                    // ),
                    Tab(
                      text: 'Diskon',
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
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.height,
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       SizedBox(height: size16),
                      //       orderBy(context),
                      //       SizedBox(height: size16),
                      //       VoucherPage(isFalseAvailable)
                      //     ],
                      //   ),
                      // ),
                      DiskonToko(
                        token: widget.token,
                        pageController: _pageController,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Expanded VoucherPage(bool isFalseAvailable) {
    return Expanded(
      child: Column(
        children: [
          Container(
            // width: double.infinity,
            // height: 50,
            padding: EdgeInsets.symmetric(vertical: size12),
            decoration: BoxDecoration(
              color: primary500,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size12),
                topRight: Radius.circular(size12),
              ),
            ),
            child: isSelectionMode == false
                ? Row(
                    children: [
                      SizedBox(
                        child: GestureDetector(
                          onTap: () {
                            selectAll(productIdCheckAll);
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
                        child: Text(
                          'Info Voucher',
                          style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                        ),
                      ),
                      SizedBox(width: size16),
                      Expanded(
                        child: Text(
                          'Harga Jual',
                          style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                      SizedBox(width: size16),
                      Expanded(
                        child: Text(
                          'Coin',
                          style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                      SizedBox(width: size16),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 8,
                          minWidth: MediaQuery.of(context).size.width / 8,
                        ),
                        child: Text(
                          'Tampil Kasir',
                          textAlign: TextAlign.center,
                          style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                      SizedBox(width: size16),
                      Opacity(
                        opacity: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: size12),
                          decoration: BoxDecoration(
                            color: bnw300,
                            border: Border.all(color: bnw300, width: width1),
                            borderRadius: BorderRadius.circular(size8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(PhosphorIcons.pencil_line),
                              SizedBox(width: size12),
                              Text(
                                'Atur',
                                style: body1(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                : Row(
                    children: [
                      SizedBox(
                        child: GestureDetector(
                          onTap: () {
                            selectAll(productIdCheckAll);
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
                        '${listProduct.length}/${datasProduk!.length} Voucher Terpilih',
                        style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                      ),
                      SizedBox(width: size16),
                      GestureDetector(
                        onTap: () {
                          showBottomPilihan(
                            context,
                            Column(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Yakin Ingin Menghapus Voucher?',
                                      style: heading1(
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                    SizedBox(height: size16),
                                    Text(
                                      'Data voucher yang sudah dihapus tidak dapat dikembalikan lagi.',
                                      style: heading2(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          // Navigator.pop(context);
                                          deleteProduk(
                                            context,
                                            widget.token,
                                            listProduct,
                                            "",
                                          );
                                          refreshDataProduk();

                                          setState(() {});
                                          initState();
                                        },
                                        child: buttonXLoutline(
                                          Center(
                                            child: Text(
                                              'Iya, Hapus',
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
                                          Navigator.pop(context);
                                        },
                                        child: buttonXL(
                                          Center(
                                            child: Text(
                                              'Batalkan',
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
                          );
                        },
                        child: buttonL(
                          Row(
                            children: [
                              Icon(
                                PhosphorIcons.trash_fill,
                                color: bnw900,
                                size: size24,
                              ),
                              SizedBox(width: size12),
                              Text(
                                'Hapus Semua',
                                style:
                                    heading3(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                            ],
                          ),
                          bnw100,
                          bnw300,
                        ),
                      ),
                      SizedBox(width: size16),
                      GestureDetector(
                        onTap: () {
                          changeActive(
                            context,
                            widget.token,
                            'true',
                            listProduct,
                            "",
                          );
                          refreshDataProduk();
                          setState(() {});
                          initState();
                        },
                        child: buttonL(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Aktifkan Tampilkan dikasir',
                                style:
                                    heading3(FontWeight.w600, bnw900, 'Outfit'),
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
                  child: RefreshIndicator(
                    color: bnw100,
                    backgroundColor: primary500,
                    onRefresh: () async {
                      initState();
                      setState(() {});
                    },
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
                        itemCount: datasProduk!.length,
                        itemBuilder: (builder, index) {
                          ModelDataPromosi data = datasProduk![index];
                          selectedFlag[index] = selectedFlag[index] ?? false;
                          bool? isSelected = selectedFlag[index];
                          final dataProduk = datasProduk![index];
                          productIdCheckAll = datasProduk!
                              .map((data) => data.productid!)
                              .toList();

                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size16, vertical: size12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom:
                                    BorderSide(color: bnw300, width: width1),
                              ),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  // onTap: () => onTap(isSeleced, index),
                                  onTap: () {
                                    onTap(
                                      isSelected,
                                      index,
                                      dataProduk.productid,
                                    );
                                    // log(data.name.toString());
                                    // print(dataProduk.isActive);
                                    // print(dataProduk.productid);
                                  },
                                  child: SizedBox(
                                    // width: 50,
                                    child: _buildSelectIcon(isSelected!, data),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  child: Text(
                                    datasProduk![index].name ?? '',
                                    style: heading4(
                                        FontWeight.w600, bnw900, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  child: Text(
                                    FormatCurrency.convertToIdr(
                                        datasProduk![index].price ?? 0),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: heading4(
                                        FontWeight.w400, bnw900, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  child: Text(
                                    FormatCurrency.convertToIdr(
                                            datasProduk![index].point ?? 0)
                                        .toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: heading4(
                                        FontWeight.w400, bnw900, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width / 9,
                                    minWidth:
                                        MediaQuery.of(context).size.width / 9,
                                  ),
                                  child: FlutterSwitch(
                                    value:
                                        dataProduk.isActive == 1 ? true : false,
                                    padding: 1,
                                    activeIcon: Icon(PhosphorIcons.check,
                                        color: primary500),
                                    inactiveIcon:
                                        Icon(PhosphorIcons.x, color: bnw100),
                                    activeColor: primary500,
                                    inactiveColor: bnw100,
                                    borderRadius: 30.0,
                                    width: 50.0,
                                    height: 27.0,
                                    inactiveToggleColor: bnw900,
                                    activeToggleColor: primary200,
                                    activeSwitchBorder:
                                        Border.all(color: primary500),
                                    inactiveSwitchBorder:
                                        Border.all(color: bnw300, width: 2),
                                    onToggle: (bool value) {
                                      // print('hello');
                                      List<String> listProduct = [
                                        dataProduk.productid!
                                      ];
                                      changeActive(
                                        context,
                                        widget.token,
                                        value.toString(),
                                        listProduct,
                                        "",
                                      );
                                      setState(() {});
                                      initState();
                                    },
                                  ),
                                ),
                                SizedBox(width: size16),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showModalBottom(
                                        context,
                                        MediaQuery.of(context).size.height /
                                            2.8,
                                        Padding(
                                          padding: EdgeInsets.all(28.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                                        dataProduk.name!,
                                                        style: heading2(
                                                            FontWeight.w600,
                                                            bnw900,
                                                            'Outfit'),
                                                      ),
                                                      Text(
                                                        dataProduk
                                                            .typeproducts!,
                                                        style: heading4(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit'),
                                                      ),
                                                    ],
                                                  ),
                                                  GestureDetector(
                                                    onTap: () =>
                                                        Navigator.pop(context),
                                                    child: Icon(
                                                      PhosphorIcons.x_fill,
                                                      color: bnw900,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: size24),
                                              GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                onTap: () {
                                                  // whenLoading(context);
                                                  singleProductId =
                                                      dataProduk.productid;
                                                  getSinglePromosi(
                                                          context,
                                                          widget.token,
                                                          "",
                                                          singleProductId,
                                                          setState)
                                                      .then((value) {
                                                    if (value == '00') {
                                                      _pageController
                                                          .jumpToPage(2);
                                                      print(singleProductId);
                                                      Navigator.pop(context);
                                                    }
                                                  });
                                                  setState(() {});
                                                },
                                                child: modalBottomValue(
                                                  'Ubah Voucher',
                                                  PhosphorIcons.pencil_line,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                onTap: () {
                                                  List<String> listProduct = [
                                                    dataProduk.productid!
                                                  ];
                                                  List<String> value = [''];
                                                  Navigator.pop(context);
                                                  showBottomPilihan(
                                                    context,
                                                    Column(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Text(
                                                              'Yakin Ingin Menghapus Voucher?',
                                                              style: heading1(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            SizedBox(
                                                                height: size16),
                                                            Text(
                                                              'Data voucher yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                              style: heading2(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                            height: size16),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  // Navigator.pop(context);
                                                                  deleteProduk(
                                                                    context,
                                                                    widget
                                                                        .token,
                                                                    listProduct,
                                                                    "",
                                                                  );
                                                                  refreshDataProduk();

                                                                  setState(
                                                                      () {});
                                                                  initState();
                                                                },
                                                                child:
                                                                    buttonXLoutline(
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
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  primary500,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: size16),
                                                            Expanded(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: buttonXL(
                                                                  Center(
                                                                    child: Text(
                                                                      'Batalkan',
                                                                      style: heading3(
                                                                          FontWeight
                                                                              .w600,
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
                                                  'Hapus Voucher',
                                                  PhosphorIcons.trash,
                                                ),
                                              ),
                                            ],
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
                                        Icon(PhosphorIcons.pencil_line),
                                        SizedBox(width: size12),
                                        Text(
                                          'Atur',
                                          style: body1(FontWeight.w600, bnw900,
                                              'Outfit'),
                                        ),
                                      ],
                                    ),
                                    bnw100,
                                    bnw900,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        // itemCount: staticData!.length,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  modalBottomValue(String title, icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: bnw900),
            SizedBox(width: size12),
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

  fieldAddProduk(title, hint, mycontroller, TextInputType numberNo) {
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
          TextFormField(
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
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: size12),
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
        ],
      ),
    );
  }

  void onTap(bool isSelected, int index, productId) {
    if (index >= 0 && index < selectedFlag.length) {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);

      if (selectedFlag[index] == true) {
        if (!listProduct.contains(productId)) {
          listProduct.add(productId);
          print(listProduct);
        }
      } else {
        listProduct.remove(productId);
      }

      setState(() {});
    }
  }

  Widget _buildSelectIcon(bool isSelected, ModelDataPromosi data) {
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

  void selectAll(productId) {
    bool isFalseAvailable = selectedFlag.containsValue(false);

    selectedFlag.updateAll((key, value) => isFalseAvailable);
    setState(
      () {
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
      },
    );
  }

  List? typeproductList;
  String? _myProvince;

  String provinceInfoUrl = '$url/api/typeproduct';
  Future _getProvinceList() async {
    await http.post(Uri.parse(provinceInfoUrl), body: {
      "deviceid": identifier,
    }).then((response) {
      var data = json.decode(response.body);

      setState(() {
        typeproductList = data['data'];
      });
    });
  }

  orderBy(BuildContext context) {
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
                                SizedBox(height: size24),
                                Text(
                                  'Pilih Urutan',
                                  style: heading3(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                                Wrap(
                                  children: List<Widget>.generate(
                                    orderByVoucherText.length,
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
                                          label: Text(orderByVoucherText[index],
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
                                    orderByVoucherText[valueOrderByProduct];
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
