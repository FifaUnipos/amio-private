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
  bool get _isGroupMerchant =>
      merchantType?.toLowerCase() == 'group' ||
      merchantType?.toLowerCase() == 'grup';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _isGroupMerchant ? 1 : 5,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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

  Future<Map<String, dynamic>?> _deleteMaterial(String itemId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/inventory/master/delete'),
        headers: {
          'token': widget.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "inventory_master_id": [itemId],
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error _deleteMaterial: $e');
      return null;
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
                          SizedBox(width: 12),
                          IconButton(
                            icon: Icon(PhosphorIcons.pencil, color: primary500),
                            onPressed: () {
                              Navigator.pop(context); // Close detail modal
                              _navigateToAddEditMaterial(
                                material: {
                                  'id': detail['item_id'],
                                  'name_item': detail['item_name'],
                                  'unit_id': detail['unit_id'],
                                  'unit_name': detail['unit_name'],
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(PhosphorIcons.trash, color: Colors.red),
                            onPressed: () {
                              Navigator.pop(context); // Close detail modal
                              _confirmDelete(detail['item_id']);
                            },
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

  void _confirmDelete(String itemId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Icon(
                PhosphorIcons.warning_circle,
                size: 64,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              Text(
                'Konfirmasi Hapus',
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menghapus material ini?',
                textAlign: TextAlign.center,
                style: body1(FontWeight.w400, bnw600, 'Outfit'),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(modalContext),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: bnw300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: heading3(FontWeight.w600, bnw600, 'Outfit'),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(modalContext);
                        final result = await _deleteMaterial(itemId);
                        if (mounted) {
                          if (result != null && result['rc'] == '00') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Berhasil menghapus material'),
                              ),
                            );
                            _fetchMaterials();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result?['message'] ??
                                      'Gagal menghapus material',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Hapus',
                        style: heading3(
                          FontWeight.w600,
                          Colors.white,
                          'Outfit',
                        ),
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
          nameToko ?? 'Inventory Material',
          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
        ),
        bottom: _isGroupMerchant
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: primary500,
                unselectedLabelColor: bnw500,
                indicatorColor: primary500,
                labelStyle: heading4(FontWeight.w600, primary500, 'Outfit'),
                unselectedLabelStyle: heading4(
                  FontWeight.w400,
                  bnw500,
                  'Outfit',
                ),
                tabs: [
                  Tab(text: 'Material'),
                  Tab(text: 'Purchase'),
                  Tab(text: 'Adjustment'),
                  Tab(text: 'Product Material'),
                  Tab(text: 'Unit Conversi'),
                ],
              ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToAddEditMaterial(),
              backgroundColor: primary500,
              icon: Icon(PhosphorIcons.plus, color: Colors.white),
              label: Text(
                'Tambah Bahan',
                style: heading4(FontWeight.w600, Colors.white, 'Outfit'),
              ),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        physics: _isGroupMerchant ? NeverScrollableScrollPhysics() : null,
        children: _isGroupMerchant
            ? [_buildMaterialTab()]
            : [
                _buildMaterialTab(),
                PurchaseTab(token: widget.token, merchantId: widget.merchantId),
                AdjustmentTab(
                  token: widget.token,
                  merchantId: widget.merchantId,
                ),
                ProductMaterialTab(
                  token: widget.token,
                  merchantId: widget.merchantId,
                ),
                UnitConversionTab(
                  token: widget.token,
                  merchantId: widget.merchantId,
                ),
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
                'Urutkan Bahan',
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: 20),
              _buildSortOption('Nama A-Z', 'name_asc'),
              _buildSortOption('Nama Z-A', 'name_desc'),
              _buildSortOption('Stok Terbanyak', 'qty_desc'),
              _buildSortOption('Stok Terkecil', 'qty_asc'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value) {
    bool isSelected = _selectedSortValue == value;
    return ListTile(
      title: Text(
        label,
        style: heading4(
          isSelected ? FontWeight.w600 : FontWeight.w400,
          isSelected ? primary500 : bnw900,
          'Outfit',
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: primary500) : null,
      onTap: () {
        setState(() {
          _selectedSortValue = value;
          _selectedSortLabel = label;
        });
        Navigator.pop(context);
        _fetchMaterials();
      },
    );
  }

  void _navigateToAddEditMaterial({Map<String, dynamic>? material}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMaterialPage(
          token: widget.token,
          merchantId: widget.merchantId,
          material: material,
          onSuccess: _fetchMaterials,
        ),
      ),
    );
  }
}

class AddEditMaterialPage extends StatefulWidget {
  final String token;
  final String merchantId;
  final Map<String, dynamic>? material;
  final VoidCallback onSuccess;

  const AddEditMaterialPage({
    Key? key,
    required this.token,
    required this.merchantId,
    this.material,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _AddEditMaterialPageState createState() => _AddEditMaterialPageState();
}

class _AddEditMaterialPageState extends State<AddEditMaterialPage> {
  late TextEditingController _nameController;
  Map<String, dynamic>? _selectedUnit;
  bool _isLoading = false;

  bool get isEdit => widget.material != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: isEdit ? widget.material!['name_item'] : '',
    );
    if (isEdit) {
      _selectedUnit = {
        'id': widget.material!['unit_id'],
        'name': widget.material!['unit_name'],
      };
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showUnitPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder(
          future: http.post(
            Uri.parse(getUnitMasterDataLink),
            headers: {
              'token': widget.token,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({"deviceid": identifier}),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasData) {
              final response = snapshot.data as http.Response;
              final data = jsonDecode(response.body);
              final List units = data['data'] ?? [];

              return Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Pilih Unit/Satuan',
                            style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: units.length,
                        itemBuilder: (context, index) {
                          final unit = units[index];
                          return ListTile(
                            title: Text(
                              unit['name'],
                              style: heading4(
                                FontWeight.w500,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            subtitle: Text(
                              unit['abbreviation'] ?? '',
                              style: body2(FontWeight.w400, bnw500, 'Outfit'),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedUnit = {
                                  'id': unit['id'],
                                  'name': unit['name'],
                                };
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(child: Text('Gagal memuat data unit')),
            );
          },
        );
      },
    );
  }

  Future<void> _saveMaterial({bool addNew = false}) async {
    final name = _nameController.text;
    if (name.isEmpty || _selectedUnit == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nama dan Unit wajib diisi')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(isEdit ? updateMasterDataLink : createMasterDataLink),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "inventory_master_id": widget.material!['id'],
          "name_item": name,
          "unit": _selectedUnit!['id'],
          // "merchant_id": widget.merchantId,
          if (isEdit) "item_id": widget.material!['id'],
        }),
      );

      final data = jsonDecode(response.body);
      if (data['rc'] == '00') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Berhasil menyimpan material')));
        widget.onSuccess();

        if (addNew) {
          setState(() {
            _nameController.clear();
            _selectedUnit = null;
            _isLoading = false;
          });
        } else {
          Navigator.pop(context);
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Gagal')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghubungkan ke server')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Ubah Bahan' : 'Tambah Bahan',
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            text: 'Nama Barang',
                            style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                            children: [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Cth: Matcha',
                            hintStyle: body2(FontWeight.w400, bnw400, 'Outfit'),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: bnw300),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        RichText(
                          text: TextSpan(
                            text: 'Unit/Satuan',
                            style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                            children: [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: _showUnitPicker,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue[900]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedUnit?['name'] ?? 'Pilih Unit/Satuan',
                                  style: body1(
                                    FontWeight.w500,
                                    _selectedUnit == null ? bnw400 : bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Icon(
                                  PhosphorIcons.caret_down,
                                  size: 16,
                                  color: bnw500,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: Offset(0, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (!isEdit)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _saveMaterial(addNew: true),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primary500),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Save & Add New',
                              style: heading3(
                                FontWeight.w600,
                                primary500,
                                'Outfit',
                              ),
                            ),
                          ),
                        ),
                      if (!isEdit) SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _saveMaterial(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary500,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isEdit ? 'Save Changes' : 'Create',
                            style: heading3(
                              FontWeight.w600,
                              Colors.white,
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
    );
  }
}
