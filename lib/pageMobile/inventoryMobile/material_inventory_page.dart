import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/pageMobile/dashboardMobile.dart';
import 'package:unipos_app_335/pageMobile/inventoryMobile/purchase_inventory_page.dart';
import 'package:unipos_app_335/pageMobile/inventoryMobile/adjustment_inventory_page.dart';
import 'package:unipos_app_335/pageMobile/inventoryMobile/product_material_page.dart';
import 'package:unipos_app_335/pageMobile/inventoryMobile/unit_conversion_page.dart';

class MaterialInventoryPage extends StatefulWidget {
  final String token;
  final String merchantId;

  MaterialInventoryPage({
    Key? key,
    required this.token,
    required this.merchantId,
  }) : super(key: key);

  @override
  _MaterialInventoryPageState createState() => _MaterialInventoryPageState();
}

class _MaterialInventoryPageState extends State<MaterialInventoryPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _materials = [];
  String _searchQuery = "";
  String _selectedSortValue = "";
  String _selectedSortLabel = "Urutkan Bahan";

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchMaterials();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // API Functions
  Future<Map<String, dynamic>?> getMaterialInventory(
    BuildContext context,
    String token,
    String merchantId,
    String name,
    String orderBy,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(getMasterDataLink),
        headers: {'token': token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "merchant_id": merchantId.isEmpty ? null : merchantId,
          "isMinimize": false,
          "name": name,
          "order_by": orderBy,
        }),
      );

      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return jsonResponse;
      } else {
        print(jsonResponse['message'].toString());
        return null;
      }
    } catch (e) {
      print('Error getMaterialInventory: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMaterialInventoryDetail(
    BuildContext context,
    String token,
    String itemId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(getMasterDataSingleDetailLink),
        headers: {'token': token, 'Content-Type': 'application/json'},
        body: jsonEncode({"deviceid": identifier, "item_id": itemId}),
      );

      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return jsonResponse;
      } else {
        print(jsonResponse['message'].toString());
        return null;
      }
    } catch (e) {
      print('Error getMaterialInventoryDetail: $e');
      return null;
    }
  }

  Future<void> _fetchMaterials() async {
    setState(() => _isLoading = true);
    try {
      final data = await getMaterialInventory(
        context,
        widget.token,
        widget.merchantId,
        _searchQuery,
        _selectedSortValue,
      );
      setState(() {
        _materials = data?['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showMaterialDetail(String itemId, String itemName) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final data = await getMaterialInventoryDetail(
        context,
        widget.token,
        itemId,
      );

      Navigator.pop(context); // Close loading dialog

      if (data != null && data['rc'] == '00') {
        _showDetailBottomSheet(data['data']);
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat detail')));
    }
  }

  void _showDetailBottomSheet(Map<String, dynamic> detail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: bnw200)),
                  ),
                  child: Column(
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
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: primary500.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              PhosphorIcons.package,
                              color: primary500,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail['item_name'] ?? '',
                                  style: heading2(
                                    FontWeight.w700,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Text(
                                  detail['unit_name'] ?? '',
                                  style: body2(
                                    FontWeight.w400,
                                    bnw500,
                                    'Outfit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Qty',
                                style: body2(FontWeight.w400, bnw500, 'Outfit'),
                              ),
                              Text(
                                _formatQty(detail['total_qty']),
                                style: heading2(
                                  FontWeight.w700,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: (detail['detail'] as List?)?.length ?? 0,
                    itemBuilder: (context, index) {
                      final activity = detail['detail'][index];
                      return _buildActivityCard(activity);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final activityType = activity['activity_type'] ?? '';
    Color badgeColor;
    String badgeLabel;

    switch (activityType.toLowerCase()) {
      case 'purchase':
        badgeColor = Colors.green;
        badgeLabel = 'purchase';
        break;
      case 'adjustment':
        badgeColor = Colors.orange;
        badgeLabel = 'adjustment';
        break;
      case 'sales':
        badgeColor = Colors.blue;
        badgeLabel = 'sales';
        break;
      case 'starting':
        badgeColor = Colors.purple;
        badgeLabel = 'starting';
        break;
      default:
        badgeColor = bnw500;
        badgeLabel = activityType;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bnw200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: body2(FontWeight.w600, Colors.white, 'Outfit'),
                ),
              ),
              Spacer(),
              Text(
                _formatDateTime(activity['activity_date']),
                style: body2(FontWeight.w400, bnw500, 'Outfit'),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildDetailRow('Jumlah', _formatQty(activity['qty'])),
          SizedBox(height: 8),
          _buildDetailRow('Harga Satuan', _formatCurrency(0)),
          SizedBox(height: 8),
          _buildDetailRow('Total', _formatCurrency(0)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: body2(FontWeight.w400, bnw600, 'Outfit')),
        Text(value, style: body2(FontWeight.w600, bnw900, 'Outfit')),
      ],
    );
  }

  String _formatQty(dynamic qty) {
    if (qty == null) return '0';
    final num = double.tryParse(qty.toString()) ?? 0;
    return num.toStringAsFixed(0);
  }

  String _formatCurrency(dynamic value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(
      value is num ? value : (num.tryParse(value.toString()) ?? 0),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
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
        title: Text(
          '$nameToko',
          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: primary500,
          unselectedLabelColor: bnw500,
          indicatorColor: primary500,
          labelStyle: heading4(FontWeight.w600, primary500, 'Outfit'),
          unselectedLabelStyle: heading4(FontWeight.w400, bnw500, 'Outfit'),
          tabs: [
            Tab(text: 'Material'),
            Tab(text: 'Purchase'),
            Tab(text: 'Adjustment'),
            Tab(text: 'Product Material'),
            Tab(text: 'Unit Conversi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMaterialTab(),
          PurchaseTab(token: widget.token, merchantId: widget.merchantId),
          AdjustmentTab(token: widget.token, merchantId: widget.merchantId),
          ProductMaterialTab(
            token: widget.token,
            merchantId: widget.merchantId,
          ),
          UnitConversionTab(token: widget.token, merchantId: widget.merchantId),
        ],
      ),
    );
  }

  Widget _buildMaterialTab() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari nama material',
                  prefixIcon: Icon(
                    PhosphorIcons.magnifying_glass,
                    color: bnw500,
                  ),
                  filled: true,
                  fillColor: bnw100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _fetchMaterials();
                },
              ),
              SizedBox(height: 12),
              InkWell(
                onTap: _showSortModal,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: bnw300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.funnel, color: bnw600, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedSortLabel,
                          style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: bnw900),
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
              : _materials.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada data material',
                    style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _materials.length,
                  itemBuilder: (context, index) {
                    final material = _materials[index];
                    return _buildMaterialCard(material);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    return InkWell(
      onTap: () => _showMaterialDetail(material['id'], material['name_item']),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bnw200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material['name_item'] ?? '',
                    style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: 4),
                  Text(
                    material['unit_name'] ?? '',
                    style: body2(FontWeight.w400, bnw500, 'Outfit'),
                  ),
                ],
              ),
            ),
            Text(
              _formatQty(material['qty']),
              style: heading2(FontWeight.w700, bnw900, 'Outfit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortModal() {
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
                'Urutkan',
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Nama A-Z',
                  style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                ),
                onTap: () {
                  setState(() {
                    _selectedSortValue = 'name_asc';
                    _selectedSortLabel = 'Nama A-Z';
                  });
                  _fetchMaterials();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  'Nama Z-A',
                  style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                ),
                onTap: () {
                  setState(() {
                    _selectedSortValue = 'name_desc';
                    _selectedSortLabel = 'Nama Z-A';
                  });
                  _fetchMaterials();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
