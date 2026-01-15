import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/main.dart'; // import identifier
import 'package:unipos_app_335/pageMobile/promoPageMobile/discount_model.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'addPromoPageMobile.dart'; // Same directory
import 'package:unipos_app_335/services/apimethod.dart'; // Assuming base URLs might be here, or I define local
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/currency_formatter.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

class PromoPageMobile extends StatefulWidget {
  final String token;
  final String merchantId;

  const PromoPageMobile({
    Key? key,
    required this.token,
    required this.merchantId,
  }) : super(key: key);

  @override
  State<PromoPageMobile> createState() => _PromoPageMobileState();
}

class _PromoPageMobileState extends State<PromoPageMobile> {
  // Constants
  final String _listUrl = diskonLink;
  final String _toggleUrl = aktifDiskonLink;

  List<DiscountModel> _discounts = [];
  List<DiscountModel> _filteredDiscounts = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String _sortOption =
      "name_asc"; // name_asc, name_desc, date_asc, date_desc, etc.
  String _sortLabel = "Urutkan toko";

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _sortOptions = [
    {'label': 'Nama (A-Z)', 'value': 'name_asc'},
    {'label': 'Nama (Z-A)', 'value': 'name_desc'},
    {'label': 'Diskon Terbesar', 'value': 'discount_desc'},
    {'label': 'Diskon Terkecil', 'value': 'discount_asc'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchDiscounts();
  }

  Future<void> _fetchDiscounts() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(_listUrl),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({"merchantid": widget.merchantId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00') {
          final List<dynamic> list = data['data'];
          setState(() {
            _discounts = list.map((e) => DiscountModel.fromJson(e)).toList();
            _applyFilterAndSort();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching discounts: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleActive(DiscountModel discount, bool newValue) async {
    // Optimistic update
    setState(() {
      // Create a new list with the updated item
      final int index = _discounts.indexWhere((d) => d.id == discount.id);
      if (index != -1) {
        // Since DiscountModel fields are final, we manually create a new instance with updated isActive
        DiscountModel updated = DiscountModel(
          id: discount.id,
          name: discount.name,
          discount: discount.discount,
          discountType: discount.discountType,
          isActive: newValue,
          type: discount.type,
          date: discount.date,
          startDate: discount.startDate,
          endDate: discount.endDate,
        );
        _discounts[index] = updated;
        _applyFilterAndSort(); // Re-apply filter to update the view
      }
    });

    try {
      final response = await http.post(
        Uri.parse(_toggleUrl),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": jsonEncode([discount.id]), // Send as stringified array
          "is_active": newValue ? "true" : "false",
        }),
      );

      print("Toggle response status: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Show message from API regardless of success/fail if it exists, or generic
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data['message'])));
        }

        if (data['rc'] != '00') {
          // If business logic fail, revert
          _fetchDiscounts();
        }
      } else {
        throw Exception("Failed to toggle");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengubah status: $e")));
      _fetchDiscounts(); // Revert by re-fetching
    }
  }

  Future<void> _deleteDiscount(String id) async {
    try {
      final response = await http.post(
        Uri.parse(deleteDiskonLink),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": jsonEncode([id]), // "[\"id\"]"
        }),
      );

      final data = jsonDecode(response.body);

      // Always show API message if available
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
      } else if (response.statusCode != 200 || data['rc'] != '00') {
        // Fallback if no message but error
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menghapus")));
      }

      if (response.statusCode == 200 && data['rc'] == '00') {
        _fetchDiscounts();
      }
    } catch (e) {
      debugPrint("Delete error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan")));
    }
  }

  void _showDeleteConfirmation(String id) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
              Text(
                "Hapus Promo",
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: 8),
              Text(
                "Apakah anda yakin ingin menghapus promo ini?",
                style: body1(FontWeight.w400, bnw900, 'Outfit'),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: bnw300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteDiscount(id);
                      },
                      child: Text(
                        "Iya, Hapus",
                        style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: primary500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          // side: BorderSide(color: primary500),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Gajadi",
                        style: heading3(FontWeight.w600, primary500, 'Outfit'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyFilterAndSort() {
    List<DiscountModel> temp = _discounts
        .where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Sort
    if (_sortOption == 'name_asc')
      temp.sort((a, b) => a.name.compareTo(b.name));
    if (_sortOption == 'name_desc')
      temp.sort((a, b) => b.name.compareTo(a.name));
    if (_sortOption == 'discount_desc')
      temp.sort((a, b) => b.discount.compareTo(a.discount));
    if (_sortOption == 'discount_asc')
      temp.sort((a, b) => a.discount.compareTo(b.discount));

    setState(() {
      _filteredDiscounts = temp;
    });
  }

  void _onSearch(String val) {
    _searchQuery = val;
    _applyFilterAndSort();
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String tempOrder = _sortOption;
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
                          _sortOption = tempOrder;
                        });
                        _applyFilterAndSort();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Promo",
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPromoPageMobile(
                      token: widget.token,
                      merchantId: widget.merchantId ?? "",
                    ),
                  ),
                );
                _fetchDiscounts();
              },
              icon: Icon(PhosphorIcons.plus, size: 16, color: bnw100),
              label: Text(
                "Promo",
                style: heading4(FontWeight.w600, bnw100, 'Outfit'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary500,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari nama atau alamat", // Text from image 2
                prefixIcon: Icon(PhosphorIcons.magnifying_glass, color: bnw500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: bnw200, // Light grey
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: _onSearch,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: _showSortBottomSheet,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ), // Increased padding matches image
                    decoration: BoxDecoration(
                      border: Border.all(color: bnw300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Urutkan toko",
                          style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          PhosphorIcons.caret_down_fill,
                          size: 16,
                          color: bnw900,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredDiscounts.length,
                    separatorBuilder: (ctx, i) =>
                        Divider(height: 24, thickness: 1, color: bnw200),
                    itemBuilder: (context, index) {
                      final item = _filteredDiscounts[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: heading3(
                                    FontWeight.w700,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                              ),
                              Text(
                                item.discountType == 'percentage'
                                    ? "${item.discount}%"
                                    : FormatCurrency.convertToIdr(
                                        item.discount,
                                      ),
                                style: heading3(
                                  FontWeight.w400,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            item.type == 'per_produk' ? "Per Produk" : "Umum",
                            style: body2(FontWeight.w400, primary500, 'Outfit'),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                "Aktif",
                                style: body2(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                              Spacer(),
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: item.isActive,
                                  activeColor: primary500,
                                  inactiveTrackColor: bnw300,
                                  onChanged: (val) => _toggleActive(item, val),
                                ),
                              ),
                              Container(
                                height: 20,
                                width: 1,
                                color: bnw300,
                                margin: EdgeInsets.symmetric(horizontal: 12),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        _showDeleteConfirmation(item.id),
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.red),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        PhosphorIcons.trash,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  InkWell(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddPromoPageMobile(
                                            token: widget.token,
                                            merchantId: widget.merchantId ?? "",
                                            editDiscount: item,
                                          ),
                                        ),
                                      );
                                      _fetchDiscounts();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: bnw900),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            PhosphorIcons.pencil_simple,
                                            size: 16,
                                            color: bnw900,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Atur",
                                            style: heading4(
                                              FontWeight.w600,
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
                            ],
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
