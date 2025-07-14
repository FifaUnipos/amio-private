import 'package:amio/main.dart';
import 'package:amio/models/inventoriModel/detailPembelianModel.dart';
import 'package:amio/services/apimethod.dart';
import 'package:amio/utils/component/component_button.dart';
import 'package:amio/utils/component/component_color.dart';
import 'package:amio/utils/component/component_showModalBottom.dart';
import 'package:amio/utils/component/component_size.dart';
import 'package:amio/utils/component/component_snackbar.dart';
import 'package:amio/utils/component/component_textHeading.dart';
import 'package:amio/utils/utilities.dart';
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
    final result =
        await getDetailPenyesuian(context, widget.token, widget.groupId);
    setState(() {
      detailListUbahFIX = result;
    });
  }

  void getdetailSelected() async {
    final result =
        await getSelectedDataPemakaian(context, widget.token, widget.groupId);
    setState(() {
      selectedDataPemakaianPenyesuaian = result;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isNotEmpty = true;
    getMasterDataTokoAndUpdateState();
    getDetailData();
    getdetailSelected();
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
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Harga Satuan',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Total Harga',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ),
                                SizedBox(width: size16),
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
                    Container(
                      // width: double.infinity,
                      decoration: BoxDecoration(
                        color: primary100,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(size12),
                          bottomRight: Radius.circular(size12),
                        ),
                      ),
                      child: orderInventoryPenyesuaian.isEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: detailListUbahFIX.length,
                              itemBuilder: (context, index) {
                                // Mendapatkan data dari dataPemakaian
                                final data = detailListUbahFIX[index];
                                final productId = data.groupId;
                                final isSelected =
                                    selectedDataPemakaianPenyesuaian
                                        .containsKey(productId);

                                return Container(
                                  margin:
                                      EdgeInsets.symmetric(vertical: size12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom:
                                          BorderSide(color: bnw300, width: 1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
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
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          data.nameItem,
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
                                          data.unitName,
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
                                          double.parse(data.qty)
                                              .toInt()
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
                                      SizedBox(width: size16),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          double.parse(data.price)
                                              .toInt()
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
                                      SizedBox(width: size16),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          FormatCurrency.convertToIdr(
                                              (double.parse(data.price)
                                                      .toInt() *
                                                  double.parse(data.qty)
                                                      .toInt())),
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
                                      GestureDetector(
                                        onTap: () {
                                          detailListUbahFIX.removeAt(index);
                                          setState(() {});
                                        },
                                        child: Icon(
                                          PhosphorIcons.x_fill,
                                          color: red500,
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                    ],
                                  ),
                                );
                              },
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: orderInventoryPenyesuaian.length,
                              itemBuilder: (context, index) {
                                // Mendapatkan data dari dataPemakaian
                                final Map<String, dynamic> data =
                                    orderInventoryPenyesuaian[index];
                                final productId = data['id'];
                                final isSelected =
                                    selectedDataPemakaianPenyesuaian
                                        .containsKey(productId);

                                return Container(
                                  margin:
                                      EdgeInsets.symmetric(vertical: size12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom:
                                          BorderSide(color: bnw300, width: 1),
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
                                          data['name_item'] ?? '',
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
                                          data['unit_name'] ?? '',
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
                                      SizedBox(width: size16),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          editHargaInventory[index]!
                                                  .text
                                                  .isNotEmpty
                                              ? editHargaInventory[index]!.text
                                              : data['price'].toString(),
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
                                          FormatCurrency.convertToIdr(
                                            parseFlexibleNumber(data['price']) *
                                                parseFlexibleNumber(
                                                    data['qty']),
                                          ).toString(),
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
                                      GestureDetector(
                                        onTap: () {
                                          orderInventoryPenyesuaian
                                              .removeAt(index);
                                          setState(() {});
                                        },
                                        child: Icon(
                                          PhosphorIcons.x_fill,
                                          color: red500,
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                    ],
                                  ),
                                );
                              },
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
            showModalBottom(
              context,
              double.infinity,
              StatefulBuilder(
                builder: (context, setState) => IntrinsicHeight(
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
                                    padding: EdgeInsets.zero,
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
                                                  value:
                                                      selectedDataPemakaianPenyesuaian
                                                          .containsKey(
                                                              item['id']),
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      if (value == true) {
                                                        selectedDataPemakaianPenyesuaian[
                                                            item['id']] = {
                                                          "inventory_master_id":
                                                              item['id'],
                                                          "name":
                                                              item['name_item'],
                                                          "category":
                                                              item['unit_name'],
                                                          "qty": 0,
                                                          "price": 0,
                                                        };
                                                      } else {
                                                        selectedDataPemakaianPenyesuaian
                                                            .remove(item['id']);
                                                      }
                                                    });
                                                  },
                                                ),
                                                title: Text(
                                                  item['name_item'] ?? '',
                                                  style: heading2(
                                                      FontWeight.w600,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                                subtitle: Text(
                                                  item['unit_name'] ?? '',
                                                  style: heading4(
                                                      FontWeight.w400,
                                                      bnw700,
                                                      'Outfit'),
                                                ),
                                                trailing: Icon(
                                                    selectedDataPemakaianPenyesuaian
                                                            .containsKey(
                                                                item['id'])
                                                        ? Icons.expand_less
                                                        : Icons.expand_more),
                                                onTap: () {
                                                  setState(() {
                                                    if (selectedDataPemakaianPenyesuaian
                                                        .containsKey(
                                                            item['id'])) {
                                                      selectedDataPemakaianPenyesuaian
                                                          .remove(item['id']);
                                                    } else {
                                                      selectedDataPemakaianPenyesuaian[
                                                          item['id']] = {
                                                        "inventory_master_id":
                                                            item['id'],
                                                        "name":
                                                            item['name_item'],
                                                        "category":
                                                            item['unit_name'],
                                                        "qty": 0,
                                                        "price": 0,
                                                      };
                                                    }
                                                  });
                                                },
                                              ),
                                              if (selectedDataPemakaianPenyesuaian
                                                  .containsKey(item['id']))
                                                Container(
                                                  padding:
                                                      EdgeInsets.all(size8),
                                                  decoration: BoxDecoration(
                                                    color: primary100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size8),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Jumlah Pesanan ',
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
                                                      TextField(
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
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw400,
                                                                  'Outfit',
                                                                )),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) {
                                                          selectedDataPemakaianPenyesuaian[
                                                                  item['id']]![
                                                              'qty'] = int
                                                                  .tryParse(
                                                                      value) ??
                                                              0;
                                                        },
                                                      ),
                                                      SizedBox(height: size12),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Harga Satuan ',
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
                                                      TextField(
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
                                                                    'Cth : Rp 10.000',
                                                                errorText:
                                                                    isNotEmpty
                                                                        ? null
                                                                        : 'masukkan nominal',
                                                                hintStyle:
                                                                    heading2(
                                                                  FontWeight
                                                                      .w600,
                                                                  bnw400,
                                                                  'Outfit',
                                                                )),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) {
                                                          if (value
                                                              .isNotEmpty) {
                                                            isNotEmpty = true;
                                                            selectedDataPemakaian[
                                                                        item[
                                                                            'id']]![
                                                                    'price'] =
                                                                parseFlexibleNumber(
                                                                    int.tryParse(
                                                                        value));
                                                          } else {
                                                            isNotEmpty = false;

                                                            // selectedDataPemakaian[
                                                            //             item[
                                                            //                 'id']]![
                                                            //         'qty'] =
                                                            //     parseFlexibleNumber(
                                                            //             value)
                                                            //         .toDouble();
                                                          }
                                                        },
                                                      ),
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
                                    // orderInventory =
                                    //     selectedDataPemakaian.values.toList();
                                    // print(selectedDataPemakaian);

                                    if (isNotEmpty == true) {
                                      selectedDataPemakaian
                                          .forEach((key, value) {
                                        value['unit_conversion_id'] = '';
                                      });

                                      orderInventory =
                                          selectedDataPemakaian.values.toList();

                                      // dataPemakaian = orderInventory;
                                      print(selectedDataPemakaian);
                                      // print(dataPemakaian);
                                      print("Saved Data: $orderInventory");

                                      Navigator.pop(context);
                                      isNotEmpty = true;
                                      // initState();
                                    }
                                    setState(() {});
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
                  updatePenyesuaian(
                    context,
                    widget.token,
                    groupIdInventoryPenyesuaianUbah,
                    tanggalAwalInventoryUbah,
                    judulPenyesuaian.text,
                    orderInventoryPenyesuaian,
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
                  print(dataPemakaian);
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
