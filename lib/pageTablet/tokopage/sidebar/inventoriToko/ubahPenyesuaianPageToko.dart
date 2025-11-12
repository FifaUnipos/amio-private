import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/models/inventoriModel/detailPembelianModel.dart';
import 'package:unipos_app_335/models/inventoriModel/unitConvertionModel.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_showModalBottom.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

class UbahPenyesuaianToko extends StatefulWidget {
  String token, groupId;
  PageController pageController;
  UbahPenyesuaianToko({
    Key? key,
    required this.token,
    required this.groupId,
    required this.pageController,
  }) : super(key: key);

  @override
  State<UbahPenyesuaianToko> createState() => _UbahPenyesuaianTokoState();
}

class _UbahPenyesuaianTokoState extends State<UbahPenyesuaianToko> {
  String selectedValue = 'Urutkan';
  String checkFill = 'kosong';
  bool isSelectionMode = false;
  List<String>? productIdCheckAll;
  List<String> listProduct = List.empty(growable: true);
  Map<int, bool> selectedFlag = {};
  List<String> cartProductIds = [];

  Map<String, TextEditingController> qtyControllerMap = {};
  Map<String, TextEditingController> hargaControllerMap = {};
  Map<String, TextEditingController> unitControllerMap = {};

  List<TextEditingController> qtyController = [];
  List<TextEditingController> hargaSatuanControllers = [];
  List<TextEditingController> textController = [];

  List<UnitConvertionModel> unitList = [];
  UnitConvertionModel? selectedUnit;
  TextEditingController unitController = TextEditingController();

  bool isNotEmpty = false;
  List<Map<String, dynamic>> dataPemakaian = [];
  // List<Map<String, dynamic>> orderInventoryPenyesuaian = [];
  // Map<String, Map<String, dynamic>> selectedDataPemakaianPenyesuaian = {};

  List<DetailItem> detailListUbahFIX = [];

  TextEditingController judulPenyesuaian =
      TextEditingController(text: titlePenyesuaianUbah);

  void getMasterDataTokoAndUpdateState() async {
    try {
      final result = await getMasterDataToko(
        context,
        widget.token,
        "",
        "",
        "",
      );

      setState(() {
        // Gunakan Set untuk menghapus duplikat berdasarkan 'id' atau 'inventory_master_id'
        final Set<String> seenIds = {};
        final List<Map<String, dynamic>> uniqueData = result.where((item) {
          final id = item['id'];
          if (seenIds.contains(id)) {
            return false;
          } else {
            seenIds.add(id);
            return true;
          }
        }).toList();

        // Perbarui dataPemakaian dengan data yang sudah difilter
        dataPemakaian = uniqueData;
      });
    } catch (e) {
      print("Error fetching data: $e");
      showSnackbar(context, {"message": e.toString()});
    }
  }

  void getDetailData() async {
    // print('getDetailData called');
    final detailList =
        await getDetailPenyesuian(context, widget.token, widget.groupId);

    // Clear previous
    qtyControllerMap.clear();
    hargaControllerMap.clear();
    unitControllerMap.clear();
    selectedDataPemakaian.clear();

    for (var item in detailList) {
      print('item.qty = ${item.qty}, item.price = ${item.price}');

      final id = item.itemId;

      qtyControllerMap[id] = TextEditingController(
        text: double.tryParse(item.qty)?.toStringAsFixed(0) ?? '',
      );
      hargaControllerMap[id] = TextEditingController(
        text: double.tryParse(item.price)?.toStringAsFixed(0) ?? '',
      );
      unitControllerMap[id] = TextEditingController(
        text: item.unit_conversion_name ?? '-',
      );

      selectedDataPemakaian[id] = {
        "inventory_master_id": id,
        "unit": item.nameItem,
        "name": item.nameItem,
        "category": item.unit_conversion_name ?? '',
        "qty": item.qty,
        "unit_conversion_id": item.unit_conversion_id ?? '',
        "unit_name": item.unitName ?? '',
        "price": item.price,
        "unit_factor": item.conversion_factor,
        "unit_id": item.unitId,
      };
    }

    print('selectedDataPemakaian: $selectedDataPemakaian');
    // print('dataPemakaian: $dataPemakaian');

    setState(() {
      detailListUbahFIX = detailList;
    });
  }

  void fetchUnits() async {
    List<UnitConvertionModel> units =
        await getUnitConvertion(widget.token, '', '', '');
    setState(() {
      unitList = units;
    });
  }

  void initializeControllers() {
    for (int i = 0; i < dataPemakaian.length; i++) {
      qtyController[i].text = dataPemakaian[i]['qty']?.toString() ?? '0';
      hargaSatuanControllers[i].text =
          dataPemakaian[i]['price']?.toString() ?? '0';
      textController[i].text = dataPemakaian[i]['unit'] ?? '-';
    }
  }

  void addNewItem() {
    setState(() {
      hargaSatuanControllers.add(TextEditingController());
      qtyController.add(TextEditingController());
      textController.add(TextEditingController(text: '-'));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    isNotEmpty = true;
    getMasterDataTokoAndUpdateState();
    getDetailData();
    fetchUnits();

    qtyController =
        List.generate(dataPemakaian.length, (index) => TextEditingController());
    hargaSatuanControllers =
        List.generate(dataPemakaian.length, (index) => TextEditingController());
    textController = List.generate(
        dataPemakaian.length, (index) => TextEditingController(text: '-'));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // getDataProduk(['']);
                      // orderInventoryPenyesuaian.clear();
                      // pagesOn = 1;
                      widget.pageController.jumpToPage(0);
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
                        'Ubah Penyesuaian',
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        'Penyesuaian',
                        style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                ],
              ),
              fieldUbahPenyesuaian(
                'Judul',
                judulPenyesuaian,
                'Penyesuaian Matcha',
              ),
              SizedBox(height: size16),
              Container(
                height: 200,
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
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Opacity(
                                  opacity: 0,
                                  child: SizedBox(
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
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Nama Produk',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Satuan',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Jumlah',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                // Expanded(
                                //   flex: 4,
                                //   child: Text(
                                //     'Harga Satuan',
                                //     style: heading4(
                                //         FontWeight.w700, bnw100, 'Outfit'),
                                //   ),
                                // ),
                                // SizedBox(width: size16),
                                // Expanded(
                                //   flex: 4,
                                //   child: Text(
                                //     'Total Harga',
                                //     style: heading4(
                                //         FontWeight.w700, bnw100, 'Outfit'),
                                //   ),
                                // ),
                                // SizedBox(width: size16),
                                Icon(
                                  PhosphorIcons.x_fill,
                                  color: primary500,
                                ),
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
                                                ? PhosphorIcons
                                                    .minus_circle_fill
                                                : PhosphorIcons.square,
                                        color: bnw100,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  // '${listProduct.length}/${datasProduk!.length} Produk Terpilih',
                                  'produk terpilih',
                                  style: heading4(
                                      FontWeight.w600, bnw100, 'Outfit'),
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
                                                style: heading1(FontWeight.w600,
                                                    bnw900, 'Outfit'),
                                              ),
                                              SizedBox(height: size16),
                                              Text(
                                                'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                                style: heading2(FontWeight.w400,
                                                    bnw900, 'Outfit'),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // deleteProduk(
                                                    //   context,
                                                    //   widget.token,
                                                    //   listProduct,
                                                    //   "",
                                                    // ).then(
                                                    //   (value) async {
                                                    //     if (value == '00') {
                                                    //       refreshDataProduk();
                                                    //       await Future.delayed(Duration(seconds: 1));
                                                    //       conNameProduk.text = '';
                                                    //       conHarga.text = '';
                                                    //       idProduct = '';
                                                    //       _pageController.jumpToPage(0);
                                                    //       setState(() {});
                                                    //       initState();
                                                    //     }
                                                    //   },
                                                    // );
                                                    // refreshDataProduk();

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
                                  child: buttonL(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(PhosphorIcons.trash_fill,
                                            color: bnw900),
                                        Text(
                                          'Hapus Semua',
                                          style: heading3(FontWeight.w600,
                                              bnw900, 'Outfit'),
                                        ),
                                      ],
                                    ),
                                    bnw100,
                                    bnw300,
                                  ),
                                ),
                                SizedBox(width: size8),
                              ],
                            ),
                    ),
                    Expanded(
                      child: Container(
                        // width: double.infinity,
                        decoration: BoxDecoration(
                          color: primary100,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(size12),
                            bottomRight: Radius.circular(size12),
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          // physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: orderInventory.length,
                          itemBuilder: (context, index) {
                            // Mendapatkan data dari dataPemakaian
                            final Map<String, dynamic> data =
                                orderInventory[index];
                            final productId = data['id'];
                            final isSelected =
                                selectedDataPemakaian.containsKey(productId);

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: size12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: bnw300, width: 1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Opacity(
                                    opacity: 0,
                                    child: InkWell(
                                      // onTap: () => onTap(isSelected, index),
                                      onTap: () {
                                        onTap(
                                          isSelected,
                                          index,
                                          productId,
                                        );
                                        // log(data.name.toString());
                                        // print(dataProduk.isActive);

                                        print(listProduct);
                                      },
                                      child: SizedBox(
                                        width: 50,
                                        child: _buildSelectIconInventori(
                                          isSelected!,
                                          data,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      data['name'] ?? '',
                                      style: heading4(
                                        FontWeight.w400,
                                        bnw900,
                                        'Outfit',
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      data['category'] ?? '',
                                      style: heading4(
                                        FontWeight.w400,
                                        bnw900,
                                        'Outfit',
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      parseFlexibleNumber(data['qty'])
                                          .toString(),
                                      style: heading4(
                                        FontWeight.w400,
                                        bnw900,
                                        'Outfit',
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // SizedBox(width: size16),
                                  // Expanded(
                                  //   flex: 4,
                                  //   child: Text(
                                  //     FormatCurrency.convertToIdr(
                                  //       parseFlexibleNumber(data['price']),
                                  //     ).toString(),
                                  //     style: heading4(
                                  //       FontWeight.w400,
                                  //       bnw900,
                                  //       'Outfit',
                                  //     ),
                                  //     maxLines: 3,
                                  //     overflow: TextOverflow.ellipsis,
                                  //   ),
                                  // ),
                                  // SizedBox(width: size16),
                                  // Expanded(
                                  //   flex: 4,
                                  //   child: Text(
                                  //     FormatCurrency.convertToIdr(
                                  //       parseFlexibleNumber(data['price']) *
                                  //           parseFlexibleNumber(data['qty']),
                                  //     ).toString(),
                                  //     style: heading4(
                                  //       FontWeight.w400,
                                  //       bnw900,
                                  //       'Outfit',
                                  //     ),
                                  //     maxLines: 3,
                                  //     overflow: TextOverflow.ellipsis,
                                  //   ),
                                  // ),
                                  // SizedBox(width: size16),
                                  GestureDetector(
                                    onTap: () {
                                      var removedItem = orderInventory[index];
                                      var itemId =
                                          removedItem['inventory_master_id'];

                                      selectedDataPemakaian.remove(itemId);
                                      orderInventory.removeAt(index);

                                      // Optional: hapus dari dataPemakaian kalau kamu ingin menghilangkan total
                                      // dataPemakaian.removeWhere((item) => item['inventory_master_id'] == itemId);

                                      setState(() {});
                                    },
                                    child: Icon(
                                      PhosphorIcons.x_fill,
                                      color: red500,
                                    ),
                                  ),
                                  SizedBox(width: size16),
                                  SizedBox(width: size16),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size16),
            ],
          ),
        ),
        SizedBox(height: size16),
        GestureDetector(
          onTap: () {
            if (selectedDataPemakaian.isEmpty) {
              selectedDataPemakaian.clear();
            }
            qtyController = List.generate(
                dataPemakaian.length, (index) => TextEditingController());
            hargaSatuanControllers = List.generate(
                dataPemakaian.length, (index) => TextEditingController());
            textController = List.generate(dataPemakaian.length,
                (index) => TextEditingController(text: '-'));

            showModalBottom(
              context,
              double.infinity,
              IntrinsicHeight(
                child: Container(
                    margin: EdgeInsets.all(size16),
                    padding: EdgeInsets.all(size12),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tambah Pemakaian',
                          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                        ),
                        Text(
                          'Pilih bahan yang sudah terpakai.',
                          style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                        ),
                        SizedBox(height: size16),
                        Container(
                          height: MediaQuery.sizeOf(context).height / 1.8,
                          child: dataPemakaian.isEmpty
                              ? Center(
                                  child: Text(
                                    'Bahan tidak ditemukan.',
                                    style: heading3(
                                        FontWeight.w400, bnw500, 'Outfit'),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  itemCount: dataPemakaian.length,
                                  itemBuilder: (context, index) {
                                    final item = dataPemakaian[index];
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return Column(
                                          children: [
                                            ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Checkbox(
                                                activeColor: primary500,
                                                value: selectedDataPemakaian
                                                    .containsKey(item['id']),
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    final id = item['id'];

                                                    if (value == true) {
                                                      // Tambahkan item ke selectedDataPemakaian dengan data lengkap
                                                      selectedDataPemakaian[
                                                          id] = {
                                                        "inventory_master_id":
                                                            id,
                                                        "name":
                                                            item['name_item'],
                                                        "category":
                                                            item['category'],
                                                        "unit":
                                                            item['name_item'],
                                                        "qty": 0,
                                                        "unit_conversion_id": item[
                                                            'unit_conversion_id'],
                                                        "unit_name":
                                                            item['unit_name'],
                                                        "price": item['price'],
                                                      };
                                                    } else {
                                                      // Hapus dari selected dan order
                                                      selectedDataPemakaian
                                                          .remove(id);
                                                      orderInventory
                                                          .removeWhere((inv) =>
                                                              inv['inventory_master_id'] ==
                                                              id);
                                                    }

                                                    this.setState(() {});
                                                  });
                                                },
                                              ),
                                              title: Text(
                                                item['name_item'] ?? '',
                                                style: heading2(FontWeight.w600,
                                                    bnw900, 'Outfit'),
                                              ),
                                              subtitle: Text(
                                                item['unit_name'] ?? '',
                                                style: heading4(FontWeight.w400,
                                                    bnw700, 'Outfit'),
                                              ),
                                              trailing: Icon(
                                                selectedDataPemakaian
                                                        .containsKey(item['id'])
                                                    ? Icons.expand_less
                                                    : Icons.expand_more,
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  addNewItem();
                                                  final id = item['id'];

                                                  if (selectedDataPemakaian
                                                      .containsKey(id)) {
                                                    selectedDataPemakaian
                                                        .remove(id);
                                                    orderInventory.removeWhere(
                                                        (inv) =>
                                                            inv['inventory_master_id'] ==
                                                            id);
                                                  } else {
                                                    selectedDataPemakaian[id] =
                                                        {
                                                      "inventory_master_id": id,
                                                      "name": item['name_item'],
                                                      "category":
                                                          item['category'],
                                                      "unit": item['name_item'],
                                                      "qty": 0,
                                                      "unit_conversion_id": item[
                                                          'unit_conversion_id'],
                                                      "unit_name":
                                                          item['unit_name'],
                                                      "price": item['price'],
                                                    };
                                                  }

                                                  this.setState(() {});
                                                });
                                              },
                                            ),
                                            if (selectedDataPemakaian
                                                .containsKey(item['id']))
                                              Container(
                                                padding: EdgeInsets.all(size8),
                                                decoration: BoxDecoration(
                                                  color: primary100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size8),
                                                ),

                                                //ubah cu
                                                child: Column(
                                                  children: [
                                                    // Row(
                                                    //   children: [
                                                    //     Row(
                                                    //       children: [
                                                    //         Text(
                                                    //           'Harga Satuan      : ',
                                                    //           style: heading4(
                                                    //               FontWeight
                                                    //                   .w400,
                                                    //               bnw900,
                                                    //               'Outfit'),
                                                    //         ),
                                                    //         // Text(
                                                    //         //   '*',
                                                    //         //   style: heading4(
                                                    //         //       FontWeight.w400,
                                                    //         //       danger500,
                                                    //         //       'Outfit'),
                                                    //         // ),
                                                    //       ],
                                                    //     ),
                                                    //     SizedBox(width: size12),
                                                    //     SizedBox(
                                                    //       key: ValueKey(index),
                                                    //       width: 120,
                                                    //       child: TextField(
                                                    //         controller:
                                                    //             hargaControllerMap[
                                                    //                 item['id']],
                                                    //         // onTap: () {
                                                    //         //   FocusScope.of(
                                                    //         //           context)
                                                    //         //       .requestFocus(
                                                    //         //           focusNodeHarga);
                                                    //         // },
                                                    //         decoration:
                                                    //             InputDecoration(
                                                    //           focusedBorder:
                                                    //               UnderlineInputBorder(
                                                    //             borderSide:
                                                    //                 BorderSide(
                                                    //               width: 2,
                                                    //               color:
                                                    //                   primary500,
                                                    //             ),
                                                    //           ),
                                                    //           focusColor:
                                                    //               primary500,
                                                    //           hintText:
                                                    //               'Cth : 10.000',
                                                    //           hintStyle:
                                                    //               heading2(
                                                    //             FontWeight.w600,
                                                    //             bnw400,
                                                    //             'Outfit',
                                                    //           ),
                                                    //         ),
                                                    //         onChanged: (value) {
                                                    //           setState(() {});
                                                    //           selectedDataPemakaian[
                                                    //                   item[
                                                    //                       'id']]![
                                                    //               'price'] = value;
                                                    //         },
                                                    //         keyboardType:
                                                    //             TextInputType
                                                    //                 .number,
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    // SizedBox(height: size12),

                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Qty      : ',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            // Text(
                                                            //   '*',
                                                            //   style: heading4(
                                                            //       FontWeight.w400,
                                                            //       danger500,
                                                            //       'Outfit'),
                                                            // ),
                                                          ],
                                                        ),
                                                        SizedBox(width: size12),
                                                        SizedBox(
                                                          width: 120,
                                                          child: TextField(
                                                            controller:
                                                                qtyControllerMap[
                                                                    item['id']],
                                                            decoration:
                                                                InputDecoration(
                                                              focusedBorder:
                                                                  UnderlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 2,
                                                                  color:
                                                                      primary500,
                                                                ),
                                                              ),
                                                              focusColor:
                                                                  primary500,
                                                              hintText:
                                                                  'Cth : 10',
                                                              hintStyle:
                                                                  heading2(
                                                                FontWeight.w600,
                                                                bnw400,
                                                                'Outfit',
                                                              ),
                                                            ),
                                                            onChanged: (value) {
                                                              selectedDataPemakaian[
                                                                      item[
                                                                          'id']]![
                                                                  'qty'] = value;
                                                              setState(() {});
                                                            },
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                          ),
                                                        ),
                                                        SizedBox(width: size12),
                                                        Text(
                                                          '|',
                                                          style: heading3(
                                                              FontWeight.w600,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        SizedBox(width: size12),
                                                        Text(
                                                          // 'Qty Total : ${qtyControllerMap.length}',
                                                          // qtyControllerMap.text,
                                                          // (selectedDataPemakaian[dataPemakaian[index]['id']]!['updated_at']) ?? "0",
                                                          // '${selectedDataPemakaian[dataPemakaian[index]['id']]?['unit_factor']}',
                                                          '1 qty = ${(double.tryParse(qtyControllerMap[item['id']]?.text ?? '0')) ?? 0 * (double.tryParse(selectedDataPemakaian[dataPemakaian[index]['id']]?['unit_factor']?.toString() ?? '0.0') ?? 0.0)} ${item['unit_name'] ?? '-'}',

                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size12),
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Unit Convertion : ',
                                                              style: heading4(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                            ),
                                                            // Text(
                                                            //   '*',
                                                            //   style: heading4(
                                                            //       FontWeight
                                                            //           .w400,
                                                            //       danger500,
                                                            //       'Outfit'),
                                                            // ),
                                                          ],
                                                        ),
                                                        SizedBox(width: size12),
                                                        SizedBox(
                                                          width: 120,
                                                          child: TextField(
                                                            // enabled: false,
                                                            controller:
                                                                unitControllerMap[
                                                                    item['id']],
                                                            readOnly: true,
                                                            decoration:
                                                                InputDecoration(
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
                                                                    hintText:
                                                                        unitControllerMap[index]?.text ??
                                                                            '',
                                                                    hintStyle:
                                                                        heading2(
                                                                      FontWeight
                                                                          .w600,
                                                                      bnw800,
                                                                      'Outfit',
                                                                    )),
                                                          ),
                                                        ),
                                                        SizedBox(width: size12),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            // print(selectedDataPemakaian[
                                                            //     dataPemakaian[
                                                            //             index]
                                                            //         [
                                                            //         'id']]!['unit']);
                                                            final selected =
                                                                await showModalBottomSheet<
                                                                    UnitConvertionModel>(
                                                              context: context,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .vertical(
                                                                            top:
                                                                                Radius.circular(size16)),
                                                              ),
                                                              builder:
                                                                  (context) {
                                                                return Column(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          ListView(
                                                                        padding:
                                                                            EdgeInsets.all(size16),
                                                                        children:
                                                                            unitList.map((unit) {
                                                                          return ListTile(
                                                                              title: Text(unit.name),
                                                                              leading: Icon(PhosphorIcons.radio_button),
                                                                              onTap: () {
                                                                                final id = item['id'];
                                                                                final unitName = unit.name;
                                                                                final unitFactor = unit.conversionFactor; // pastikan ini num/double
                                                                                final unitId = unit.id;

                                                                                setState(() {
                                                                                  unitControllerMap[id] ??= TextEditingController();
                                                                                  unitControllerMap[id]!.text = unitName;

                                                                                  selectedDataPemakaian[id] ??= {};
                                                                                  selectedDataPemakaian[id]!['unit'] = item['name_item'];
                                                                                  selectedDataPemakaian[id]!['name'] = item['name_item'];
                                                                                  selectedDataPemakaian[id]!['category'] = unitName;
                                                                                  selectedDataPemakaian[id]!['unit_name'] = unitName;
                                                                                  selectedDataPemakaian[id]!['unit_factor'] = unitFactor; // tipe num/double
                                                                                  selectedDataPemakaian[id]!['unit_id'] = unitId;
                                                                                  selectedDataPemakaian[id]!['unit_conversion_id'] = unitId;
                                                                                });

                                                                                Navigator.pop(context, unit);
                                                                              });
                                                                        }).toList(),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              size12),
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          unitControllerMap[index]?.text =
                                                                              '-';
                                                                          // selectedDataPemakaian[dataPemakaian[index]['id']]!['unit'] = '';
                                                                          // selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_name'] = '';
                                                                          selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_factor'] =
                                                                              '';
                                                                          selectedDataPemakaian[dataPemakaian[index]['id']]!['unit_id'] =
                                                                              '';

                                                                          setState(
                                                                              () {});
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            buttonXL(
                                                                          Center(
                                                                            child:
                                                                                Text(
                                                                              'Hapus',
                                                                              style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                                                                            ),
                                                                          ),
                                                                          double
                                                                              .infinity,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );

                                                            if (selected !=
                                                                null) {
                                                              unitController
                                                                      .text =
                                                                  selected.name;
                                                              selectedUnit =
                                                                  selected;

                                                              setState(() {});
                                                            }
                                                          },
                                                          child: Icon(
                                                              PhosphorIcons
                                                                  .caret_down),
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(height: size12),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                        SizedBox(height: size16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: buttonXLoutline(
                                  Center(
                                    child: Text(
                                      'Batal',
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
                                  // 1. Simpan semua item yang dicentang ke orderInventory
                                  for (var entry
                                      in selectedDataPemakaian.entries) {
                                    final newItem = entry.value;
                                    final itemId =
                                        newItem['inventory_master_id'];

                                    final existingIndex =
                                        orderInventory.indexWhere(
                                      (item) =>
                                          item['inventory_master_id'] == itemId,
                                    );

                                    if (existingIndex != -1) {
                                      orderInventory[existingIndex] =
                                          Map<String, dynamic>.from(newItem);
                                    } else {
                                      orderInventory.add(
                                          Map<String, dynamic>.from(newItem));
                                    }
                                  }

                                  for (var updatedItem in orderInventory) {
                                    final id =
                                        updatedItem['inventory_master_id'];

                                    final index = dataPemakaian.indexWhere(
                                      (item) =>
                                          item['inventory_master_id'] == id,
                                    );

                                    final fromSelected =
                                        selectedDataPemakaian[id] ?? {};
                                    final fromExisting =
                                        index != -1 ? dataPemakaian[index] : {};

                                    final mergedItem = {
                                      ...fromExisting,
                                      ...fromSelected,
                                      ...updatedItem,
                                    };

                                    if (index != -1) {
                                      dataPemakaian[index] =
                                          Map<String, dynamic>.from(mergedItem);
                                    } else {
                                      dataPemakaian.add(
                                          Map<String, dynamic>.from(
                                              mergedItem));
                                    }
                                  }

                                  // 3. Trigger UI refresh dan cek hasil
                                  setState(() {
                                    dataPemakaian = List.from(dataPemakaian);
                                    print("✅ Final dataPemakaian:");
                                    for (var d in dataPemakaian) {
                                      print(d);
                                    }
                                  });

                                  // 4. Tutup modal atau form
                                  Navigator.pop(context);
                                },
                                child: buttonXL(
                                  Center(
                                    child: Text(
                                      'Simpan',
                                      style: heading3(
                                          FontWeight.w600, bnw100, 'Outfit'),
                                    ),
                                  ),
                                  double.infinity,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ),
            );
          },
          child: SizedBox(
            width: double.infinity,
            child: buttonXLoutline(
              Center(
                child: Text(
                  'Sesuaikan',
                  style: heading3(FontWeight.w600, primary500, 'Outfit'),
                ),
              ),
              double.infinity,
              primary500,
            ),
          ),
        ),
        SizedBox(height: size16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  print(selectedDataPemakaian);
                  List<Map<String, dynamic>> convertedOrderInventory =
                      selectedDataPemakaian.values.map((e) {
                    return {
                      ...e,
                      // 'unit_conversion_id': '',
                      'qty':
                          (double.tryParse(e['qty'].toString())?.toInt() ?? 0),
                      'price':
                          (double.tryParse(e['price'].toString())?.toInt() ??
                              0),
                    };
                  }).toList();

                  print("Converted Order Inventory: $convertedOrderInventory");

                  updatePenyesuaian(
                    context,
                    widget.token,
                    groupIdInventoryUbah,
                    tanggalAwalInventoryUbah,
                    judulPenyesuaian.text,
                    convertedOrderInventory,
                  ).then(
                    (value) {
                      if (value == '00') {
                        widget.pageController.jumpToPage(0);
                        orderInventoryPenyesuaian.clear();
                        tanggalAwalInventoryUbah = '';
                        setState(() {});
                        initState();
                      }
                    },
                  );

                  print(orderInventoryPenyesuaian);
                  // print(dataPemakaian);
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Simpan',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  double.infinity,
                ),
              ),
            ),
          ],
        )
      ],
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

  Widget _buildSelectIcon(bool isSelected, DetailItem data) {
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

  Widget _buildSelectIconInventori(bool isSelected, data) {
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

  fieldUbahPenyesuaian(title, mycontroller, hintText) {
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
              // keyboardType: numberNo,
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
                hintText: 'Cth : $hintText',
                hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
