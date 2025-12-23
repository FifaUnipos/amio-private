import 'dart:async'; // Added for Timer
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/models/produkmodel.dart';
import 'package:unipos_app_335/pageMobile/dashboardMobile.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/main.dart'; // For identifier and other globals if needed
import 'package:unipos_app_335/utils/currency_formatter.dart';

// -----------------------------------------------------------------------------
// UI Helpers & Global Style BottomSheets
// -----------------------------------------------------------------------------

void _showConfirmBottomSheet({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required String cancelText,
  required VoidCallback onConfirm,
}) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: heading2(FontWeight.w700, bnw900, 'Outfit'),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: heading4(FontWeight.w400, bnw500, 'Outfit'),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primary500),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  child: Text(
                    confirmText,
                    style: heading3(FontWeight.w600, primary500, 'Outfit'),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary500,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    cancelText,
                    style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    ),
  );
}

// -----------------------------------------------------------------------------
// API Helper Wrappers for Category CRUD
// -----------------------------------------------------------------------------

Future<String> storeKategori(
  BuildContext context,
  String token,
  String name,
) async {
  final body = {"name": name, "deviceid": identifier};
  final response = await http.post(
    Uri.parse("$url/api/typeproduct/store"),
    headers: {'token': token, 'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );
  return jsonDecode(response.body)['rc'];
}

Future<String> updateKategori(
  BuildContext context,
  String token,
  String id,
  String name,
) async {
  final body = {"id": id, "name": name};
  final response = await http.post(
    Uri.parse("$url/api/typeproduct/update"),
    headers: {'token': token, 'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );
  return jsonDecode(response.body)['rc'];
}

Future<String> deleteKategori(
  BuildContext context,
  String token,
  String id,
) async {
  final body = {"id": id};
  final response = await http.post(
    Uri.parse("$url/api/typeproduct/delete"),
    headers: {'token': token, 'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );
  return jsonDecode(response.body)['rc'];
}

class ProductMobilePage extends StatefulWidget {
  final String token;
  final String merchantId;
  ProductMobilePage({Key? key, required this.token, required this.merchantId})
    : super(key: key);

  @override
  State<ProductMobilePage> createState() => _ProductMobilePageState();
}

class _ProductMobilePageState extends State<ProductMobilePage> {
  List<ModelDataProduk> listProduk = [];
  bool isLoading = true;
  String search = '';
  String orderby = 'upDownNama';
  String orderLabel = 'Nama Produk (A ke Z)';
  Timer? _debounce;

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _sortOptions = [
    {'label': 'Nama Produk (A ke Z)', 'value': 'upDownNama'},
    {'label': 'Nama Produk (Z ke A)', 'value': 'downUpNama'},
    {'label': 'Produk Terbaru', 'value': 'downUpCreate'},
    {'label': 'Produk Terlama', 'value': 'upDownCreate'},
    {'label': 'Kategori (A ke Z)', 'value': 'upDownHarga'},
    {'label': 'Kategori (Z ke A)', 'value': 'downUpHarga'},
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final data = await getProduct(context, widget.token, search, [
      widget.merchantId,
    ], orderby);
    setState(() {
      listProduk = data ?? [];
      isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      if (search != query) {
        setState(() {
          search = query;
        });
        loadData();
      }
    });
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String tempOrder = orderby;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Urutkan",
                            style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          Text(
                            "Pilih urutan yang ingin ditampilkan",
                            style: heading4(FontWeight.w400, bnw500, 'Outfit'),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _sortOptions.map((option) {
                      bool isSelected = tempOrder == option['value'];
                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            tempOrder = option['value']!;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary500.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? primary500 : bnw300,
                            ),
                          ),
                          child: Text(
                            option['label']!,
                            style: TextStyle(
                              color: isSelected ? primary500 : bnw900,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          orderby = tempOrder;
                          orderLabel = _sortOptions.firstWhere(
                            (e) => e['value'] == tempOrder,
                          )['label']!;
                        });
                        loadData();
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Tampilkan",
                        style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteProduct(ModelDataProduk item) {
    _showConfirmBottomSheet(
      context: context,
      title: "Yakin Ingin Menghapus Produk?",
      message: "Produk yang telah dihapus tidak dapat dikembalikan.",
      confirmText: "Iya, Hapus",
      cancelText: "Batalkan",
      onConfirm: () async {
        final rc = await deleteProduk(context, widget.token, [
          item.productid,
        ], widget.merchantId);
        if (rc == "00") loadData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Daftar Produk",
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPageMobile(token: widget.token),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(PhosphorIcons.copy, color: primary500),
            style: IconButton.styleFrom(
              side: BorderSide(color: primary500.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(width: 8),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: primary500,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TambahProdukPageMobile(
                        token: widget.token,
                        merchantId: widget.merchantId,
                      ),
                    ),
                  ).then((value) {
                    if (value == true) loadData();
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search bar (STAYS MOUNTED)
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Produk',
                hintStyle: heading4(FontWeight.w400, bnw500, 'Outfit'),
                prefixIcon: Icon(
                  PhosphorIcons.magnifying_glass,
                  color: Colors.black54,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
            SizedBox(height: 12),

            // 🔘 Urutkan & total produk
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _showSortBottomSheet,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: bnw300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Urutkan",
                          style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_drop_down, color: Colors.black),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: bnw300),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    "Total Produk : ${listProduk.length}",
                    style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            Text(
              "Pilih Toko",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),

            // 🔹 Daftar produk
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : listProduk.isEmpty
                  ? Center(child: Text("Produk tidak ditemukan"))
                  : ListView.separated(
                      itemCount: listProduk.length,
                      separatorBuilder: (context, index) =>
                          Divider(thickness: 1, height: 32),
                      itemBuilder: (context, index) {
                        final item = listProduk[index];
                        final bool isPpn = item.isPPN == 1;
                        final bool isDisplayed = item.isActive == 1;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.productImage ?? '',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, _, __) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: SvgPicture.asset(
                                        'assets/logoProduct.svg',
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name ?? '',
                                        style: heading3(
                                          FontWeight.w700,
                                          bnw900,
                                          'Outfit',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id',
                                          symbol: 'Rp. ',
                                          decimalDigits: 0,
                                        ).format(item.price_after ?? 0),
                                        style: heading3(
                                          FontWeight.w600,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      item.discount_type == null
                                          ? SizedBox()
                                          : Text(
                                              NumberFormat.currency(
                                                locale: 'id',
                                                symbol: 'Rp. ',
                                                decimalDigits: 0,
                                              ).format(item.price ?? 0),
                                              style: TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontFamily: 'Outfit',
                                                color: bnw900,
                                                fontSize: sp18,
                                                height: 1.22,
                                              ),
                                            ),
                                      Text(
                                        (item.discount != null &&
                                                item.discount! > 0)
                                            ? (item.discount_type == 'price'
                                                  ? NumberFormat.currency(
                                                      locale: 'id',
                                                      symbol: 'Rp. ',
                                                      decimalDigits: 0,
                                                    ).format(item.discount ?? 0)
                                                  : item.discount_type ==
                                                        'percentage'
                                                  ? '${item.discount ?? 0} %'
                                                  : '')
                                            : '',
                                        style: heading4(
                                          FontWeight.w600,
                                          danger500,
                                          'Outfit',
                                        ),
                                      ),

                                      Text(
                                        item.typeproducts ?? '',
                                        style: heading4(
                                          FontWeight.w400,
                                          bnw500,
                                          'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _deleteProduct(item),
                                      icon: Icon(
                                        PhosphorIcons.trash,
                                        size: 22,
                                        color: Colors.red,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                UbahProdukPageMobile(
                                                  token: widget.token,
                                                  product: item,
                                                  merchantId: widget.merchantId,
                                                ),
                                          ),
                                        ).then((value) {
                                          if (value == true) loadData();
                                        });
                                      },
                                      icon: Icon(
                                        PhosphorIcons.pencil_line,
                                        size: 22,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        "PPN 11%",
                                        style: heading4(
                                          FontWeight.w500,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      Spacer(),
                                      FlutterSwitch(
                                        value: isPpn,
                                        width: 44.0,
                                        height: 24.0,
                                        toggleSize: 20.0,
                                        padding: 2.0,
                                        activeColor: primary500,
                                        inactiveColor: bnw300,
                                        onToggle: (val) async {
                                          String status = val
                                              ? "true"
                                              : "false";
                                          final rc = await changePpn(
                                            context,
                                            widget.token,
                                            status,
                                            [item.productid],
                                            widget.merchantId,
                                          );
                                          if (rc == "00") {
                                            setState(() {
                                              item.isPPN = val ? 1 : 0;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 1),
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(width: 1),
                                Expanded(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 8),
                                      Text(
                                        "Tampilkan dikasir",
                                        style: heading4(
                                          FontWeight.w500,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      Spacer(),
                                      FlutterSwitch(
                                        value: isDisplayed,
                                        width: 44.0,
                                        height: 24.0,
                                        toggleSize: 20.0,
                                        padding: 2.0,
                                        activeColor: primary500,
                                        inactiveColor: bnw300,
                                        onToggle: (val) async {
                                          String status = val
                                              ? "true"
                                              : "false";
                                          final rc = await changeActive(
                                            context,
                                            widget.token,
                                            status,
                                            [item.productid],
                                            widget.merchantId,
                                          );
                                          if (rc == "00") {
                                            setState(() {
                                              item.isActive = val ? 1 : 0;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Category Selection Modal (Gambar 2)
// -----------------------------------------------------------------------------
void _showCategoryBottomSheet(
  BuildContext context,
  String token,
  Function(String name, String code) onSelected,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      String searchCat = '';
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    text: 'Kategori ',
                    style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                    children: [
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari',
                    hintStyle: heading4(FontWeight.w400, bnw400, 'Outfit'),
                    prefixIcon: Icon(Icons.search, color: bnw400, size: 20),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: bnw300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: bnw300),
                    ),
                  ),
                  onChanged: (v) => setModalState(() => searchCat = v),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primary500),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showAddEditCategoryModal(
                      context,
                      token,
                      onRefresh: () => setModalState(() {}),
                    ),
                    child: Text(
                      "Tambah Kategori",
                      style: heading3(FontWeight.w600, primary500, 'Outfit'),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<dynamic>(
                    future: getTypeProduct(context, token),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || (snapshot.data as List).isEmpty)
                        return Center(child: Text("Kategori tidak tersedia"));
                      List categories = snapshot.data as List;
                      if (searchCat.isNotEmpty) {
                        categories = categories
                            .where(
                              (c) => c['jenisproduct']
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchCat.toLowerCase()),
                            )
                            .toList();
                      }
                      return ListView.separated(
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              cat['jenisproduct'],
                              style: heading4(
                                FontWeight.w400,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            trailing: Icon(
                              Icons.radio_button_off,
                              color: bnw400,
                            ),
                            onTap: () {
                              onSelected(
                                cat['jenisproduct'],
                                cat['kodeproduct'],
                              );
                              Navigator.pop(context);
                            },
                            onLongPress: () => _showCategoryActionMenu(
                              context,
                              token,
                              cat,
                              onRefresh: () => setModalState(() {}),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary500,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Selesai",
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showAddEditCategoryModal(
  BuildContext context,
  String token, {
  Map? category,
  required VoidCallback onRefresh,
}) {
  final nameController = TextEditingController(
    text: category != null ? category['jenisproduct'] : '',
  );
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            category == null ? "Tambah Kategori" : "Ubah Kategori",
            style: heading2(FontWeight.w700, bnw900, 'Outfit'),
          ),
          SizedBox(height: 16),
          RichText(
            text: TextSpan(
              text: 'Kategori ',
              style: heading4(FontWeight.w600, bnw900, 'Outfit'),
              children: [
                TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Cth : Makanan',
              hintStyle: heading3(FontWeight.w400, bnw300, 'Outfit'),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: bnw300),
              ),
            ),
          ),
          SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primary500),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Batal",
                    style: heading3(FontWeight.w600, primary500, 'Outfit'),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary500,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    String rc;
                    if (category == null) {
                      rc = await storeKategori(
                        context,
                        token,
                        nameController.text,
                      );
                    } else {
                      rc = await updateKategori(
                        context,
                        token,
                        category['kodeproduct'],
                        nameController.text,
                      );
                    }
                    if (rc == "00") {
                      onRefresh();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Simpan",
                    style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    ),
  );
}

void _showCategoryActionMenu(
  BuildContext context,
  String token,
  Map cat, {
  required VoidCallback onRefresh,
}) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cat['jenisproduct'],
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text(
              "Ubah Kategori",
              style: heading4(FontWeight.w400, bnw900, 'Outfit'),
            ),
            onTap: () {
              Navigator.pop(context);
              _showAddEditCategoryModal(
                context,
                token,
                category: cat,
                onRefresh: onRefresh,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text(
              "Hapus Kategori",
              style: heading4(FontWeight.w400, Colors.red, 'Outfit'),
            ),
            onTap: () {
              Navigator.pop(context);
              _showConfirmBottomSheet(
                context: context,
                title: "Yakin Ingin Menghapus Kategori?",
                message:
                    "Kategori yang telah dihapus tidak dapat dikembalikan.",
                confirmText: "Iya, Hapus",
                cancelText: "Batalkan",
                onConfirm: () async {
                  final rc = await deleteKategori(
                    context,
                    token,
                    cat['kodeproduct'],
                  );
                  if (rc == "00") onRefresh();
                },
              );
            },
          ),
          SizedBox(height: 16),
        ],
      ),
    ),
  );
}

// -----------------------------------------------------------------------------
// Tambah Produk Page (Gambar 1)
// -----------------------------------------------------------------------------
class TambahProdukPageMobile extends StatefulWidget {
  final String token;
  final String merchantId;
  TambahProdukPageMobile({
    Key? key,
    required this.token,
    required this.merchantId,
  }) : super(key: key);

  @override
  State<TambahProdukPageMobile> createState() => _TambahProdukPageMobileState();
}

class _TambahProdukPageMobileState extends State<TambahProdukPageMobile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final PageController _pageController = PageController();

  String selectedCategory = '';
  String selectedCategoryCode = '';
  File? _image;
  String? _base64Image;

  bool isPpn = false;
  bool isActive = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _image = File(image.path);
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _save({bool addAnother = false}) async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategory.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Pilih kategori terlebih dahulu")));
      return;
    }

    final rc = await createProduct(
      context,
      widget.token,
      _nameController.text,
      selectedCategoryCode,
      isPpn ? 1 : 0,
      isActive ? 1 : 0,
      _priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      '0',

      _base64Image ?? '',
      [widget.merchantId],
      _pageController,
    );

    if (rc == '00') {
      if (addAnother) {
        _nameController.clear();
        _priceController.clear();
        setState(() {
          selectedCategory = '';
          _image = null;
          _base64Image = null;
          isPpn = false;
          isActive = false;
        });
      } else {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Tambah Produk",
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Foto Produk",
                style: heading4(FontWeight.w600, bnw900, 'Outfit'),
              ),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: bnw300),
                      ),
                      child: _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_image!, fit: BoxFit.cover),
                            )
                          : Icon(PhosphorIcons.image, size: 32, color: bnw400),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Masukkan Foto Produk Terbaikmu. Foto Produk akan tampil pada menu Transaksi Kasir",
                      style: heading4(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: _pickImage,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        "Ganti Gambar",
                        style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      Spacer(),
                      Icon(Icons.add, color: bnw900),
                    ],
                  ),
                ),
              ),
              Divider(thickness: 1),
              SizedBox(height: 16),

              RichText(
                text: TextSpan(
                  text: 'Nama Produk ',
                  style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _nameController,
                style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                decoration: InputDecoration(
                  hintText: "Masukkan Nama Produk",
                  hintStyle: heading3(FontWeight.w400, bnw300, 'Outfit'),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: bnw300),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              SizedBox(height: 24),

              RichText(
                text: TextSpan(
                  text: 'Harga ',
                  style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                style: heading3(FontWeight.w600, bnw900, 'Outfit'),

                decoration: InputDecoration(
                  prefixText: "Rp. ",
                  prefixStyle: heading3(FontWeight.w600, bnw900, 'Outfit'),
                  hintText: "0",
                  hintStyle: heading3(FontWeight.w400, bnw300, 'Outfit'),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: bnw300),
                  ),
                ),
                validator: (v) =>
                    v!.isEmpty ? "Harga tidak boleh kosong" : null,
              ),
              SizedBox(height: 24),

              RichText(
                text: TextSpan(
                  text: 'Kategori ',
                  style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showCategoryBottomSheet(context, widget.token, (
                  name,
                  code,
                ) {
                  setState(() {
                    selectedCategory = name;
                    selectedCategoryCode = code;
                  });
                }),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: bnw300)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        selectedCategory.isEmpty
                            ? "Pilih Kategori"
                            : selectedCategory,
                        style: heading3(
                          FontWeight.w600,
                          selectedCategory.isEmpty ? bnw300 : bnw900,
                          'Outfit',
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_drop_down, color: bnw900),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PPN 11%",
                        style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      Text(
                        isPpn ? "Aktif" : "Tidak Aktif",
                        style: heading4(FontWeight.w400, bnw500, 'Outfit'),
                      ),
                    ],
                  ),
                  FlutterSwitch(
                    value: isPpn,
                    width: 50.0,
                    height: 28.0,
                    toggleSize: 22.0,
                    padding: 3.0,
                    activeColor: primary500,
                    inactiveColor: bnw300,
                    showOnOff: false,
                    onToggle: (v) => setState(() => isPpn = v),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tampilkan di Kasir",
                        style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      Text(
                        isActive ? "Aktif" : "Tidak Aktif",
                        style: heading4(FontWeight.w400, bnw500, 'Outfit'),
                      ),
                    ],
                  ),
                  FlutterSwitch(
                    value: isActive,
                    width: 50.0,
                    height: 28.0,
                    toggleSize: 22.0,
                    padding: 3.0,
                    activeColor: primary500,
                    inactiveColor: bnw300,
                    showOnOff: false,
                    onToggle: (v) => setState(() => isActive = v),
                  ),
                ],
              ),
              SizedBox(height: 48),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: primary500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _save(addAnother: true),
                      child: Text(
                        "Simpan & Tambah Baru",
                        style: heading3(FontWeight.w600, primary500, 'Outfit'),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _save(),
                      child: Text(
                        "Simpan",
                        style: heading3(FontWeight.w600, bnw100, 'Outfit'),
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
  }
}

// -----------------------------------------------------------------------------
// Ubah Produk Page (Gambar 1 style)
// -----------------------------------------------------------------------------
class UbahProdukPageMobile extends StatefulWidget {
  final String token;
  final ModelDataProduk product;
  final String merchantId;
  UbahProdukPageMobile({
    Key? key,
    required this.token,
    required this.product,
    required this.merchantId,
  }) : super(key: key);

  @override
  State<UbahProdukPageMobile> createState() => _UbahProdukPageMobileState();
}

class _UbahProdukPageMobileState extends State<UbahProdukPageMobile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  final PageController _pageController = PageController();

  String selectedCategory = '';
  String selectedCategoryCode = '';
  File? _image;
  String? _base64Image;

  late bool isPpn;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    selectedCategory = widget.product.typeproducts ?? '';
    isPpn = widget.product.isPPN == 1;
    isActive = widget.product.isActive == 1;

    _loadCategoryCode();
  }

  void _loadCategoryCode() async {
    if (selectedCategory.isEmpty) return;
    final categories = await getTypeProduct(context, widget.token);
    if (categories != null) {
      final match = (categories as List).firstWhere(
        (c) => c['jenisproduct'] == selectedCategory,
        orElse: () => null,
      );
      if (match != null) {
        setState(() {
          selectedCategoryCode = match['kodeproduct'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _image = File(image.path);
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategory.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Pilih kategori terlebih dahulu")));
      return;
    }

    final rc = await updateProduk(
      context,
      widget.token,
      _nameController.text,
      [widget.merchantId],
      widget.product.productid,
      selectedCategoryCode,
      _priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      '0',

      _pageController,
      isActive ? 1 : 0,
      isPpn ? 1 : 0,
      _base64Image ?? '',
    );

    if (rc == '00') {
      // Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Detail Produk",
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Foto Produk",
                style: heading4(FontWeight.w600, bnw900, 'Outfit'),
              ),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: bnw300),
                      ),
                      child: _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_image!, fit: BoxFit.cover),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.product.productImage ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Icon(
                                  PhosphorIcons.image,
                                  size: 32,
                                  color: bnw400,
                                ),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Masukkan Foto Produk Terbaikmu. Foto Produk akan tampil pada menu Transaksi Kasir",
                      style: heading4(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: _pickImage,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        "Ganti Gambar",
                        style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      Spacer(),
                      Icon(Icons.add, color: bnw900),
                    ],
                  ),
                ),
              ),
              Divider(thickness: 1),
              SizedBox(height: 16),

              RichText(
                text: TextSpan(
                  text: 'Nama Produk ',
                  style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _nameController,
                style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                decoration: InputDecoration(
                  hintText: "Masukkan Nama Produk",
                  hintStyle: heading3(FontWeight.w400, bnw300, 'Outfit'),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: bnw300),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              SizedBox(height: 24),

              RichText(
                text: TextSpan(
                  text: 'Harga ',
                  style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                style: heading3(FontWeight.w600, bnw900, 'Outfit'),

                decoration: InputDecoration(
                  prefixText: "Rp. ",
                  prefixStyle: heading3(FontWeight.w600, bnw900, 'Outfit'),
                  hintText: "0",
                  hintStyle: heading3(FontWeight.w400, bnw300, 'Outfit'),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: bnw300),
                  ),
                ),
                validator: (v) =>
                    v!.isEmpty ? "Harga tidak boleh kosong" : null,
              ),
              SizedBox(height: 24),

              RichText(
                text: TextSpan(
                  text: 'Kategori ',
                  style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showCategoryBottomSheet(context, widget.token, (
                  name,
                  code,
                ) {
                  setState(() {
                    selectedCategory = name;
                    selectedCategoryCode = code;
                  });
                }),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: bnw300)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        selectedCategory.isEmpty
                            ? "Pilih Kategori"
                            : selectedCategory,
                        style: heading3(
                          FontWeight.w600,
                          selectedCategory.isEmpty ? bnw300 : bnw900,
                          'Outfit',
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_drop_down, color: bnw900),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PPN 11%",
                        style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      Text(
                        isPpn ? "Aktif" : "Tidak Aktif",
                        style: heading4(FontWeight.w400, bnw500, 'Outfit'),
                      ),
                    ],
                  ),
                  FlutterSwitch(
                    value: isPpn,
                    width: 50.0,
                    height: 28.0,
                    toggleSize: 22.0,
                    padding: 3.0,
                    activeColor: primary500,
                    inactiveColor: bnw300,
                    showOnOff: false,
                    onToggle: (v) => setState(() => isPpn = v),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tampilkan di Kasir",
                        style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      Text(
                        isActive ? "Aktif" : "Tidak Aktif",
                        style: heading4(FontWeight.w400, bnw500, 'Outfit'),
                      ),
                    ],
                  ),
                  FlutterSwitch(
                    value: isActive,
                    width: 50.0,
                    height: 28.0,
                    toggleSize: 22.0,
                    padding: 3.0,
                    activeColor: primary500,
                    inactiveColor: bnw300,
                    showOnOff: false,
                    onToggle: (v) => setState(() => isActive = v),
                  ),
                ],
              ),
              SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary500,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _update(),
                  child: Text(
                    "Simpan",
                    style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
