import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_loading.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
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
  final String? merchantName;
  final String typeMerchant;

  MaterialInventoryPage({
    Key? key,
    required this.token,
    required this.merchantId,
    this.merchantName,
    required this.typeMerchant,
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
  String _normalizeType(String t) =>
      t.trim().toLowerCase().replaceAll(' ', '_');

  bool get _canInventory =>
      _normalizeType(widget.typeMerchant) == 'group_merchant';

  late TabController _tabController;
  bool get _isGroupMerchant =>
      merchantType?.toLowerCase() == 'group' ||
      merchantType?.toLowerCase() == 'grup';

  // PageView
  late final PageController _pageController;

  // form tambah material
  final TextEditingController namaBarangController = TextEditingController();

  // Unit Master
  List<dynamic> _unitList = [];
  List<dynamic> _filteredUnitList = [];
  String _selectedUnitId = "";
  String _selectedUnitLabel = "";

  final TextEditingController _searchUnitController = TextEditingController();
  final FocusNode _unitSearchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    debugPrint(
      'PurchaseTab typeMerchant="${widget.typeMerchant}"'
      'normalized="${_normalizeType(widget.typeMerchant)}"'
      'canPurchase=$_canInventory',
    );
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index == 0) {
        _fetchMaterials();
      }
    });
    _pageController = PageController(initialPage: 0);

    _fetchMaterials();
    _fetchUnitMaster();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();

    namaBarangController.dispose();
    _searchUnitController.dispose();
    _unitSearchFocusNode.dispose();

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
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final res = await getMaterialInventory(
        context,
        widget.token,
        widget.merchantId,
        _searchQuery,
        _selectedSortValue,
      );

      if (!mounted) return;

      if (res == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data material')),
        );
        return;
      }

      if (res['rc'] != '00') {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'Gagal memuat data'),
          ),
        );
        return;
      }

      final list = (res['data'] as List?) ?? [];

      setState(() {
        _materials = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat memuat data')),
      );
    }
  }

  // Unit Master

  Future<void> _fetchUnitMaster() async {
    try {
      final response = await http.post(
        Uri.parse(getUnitMasterDataLink),
        headers: {'token': widget.token},
        body: {"deviceid": identifier},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['rc'] == '00') {
          final list = (jsonResponse['data'] as List?) ?? [];
          if (!mounted) return;
          setState(() {
            _unitList = list;
            _filteredUnitList = List.from(_unitList);
          });
        }
      }
    } catch (e) {
      debugPrint('Error _fetchUnitMaster: $e');
    }
  }

  void _runSearchUnit(String value) {
    final q = value.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filteredUnitList = List.from(_unitList);
      } else {
        _filteredUnitList = _unitList.where((u) {
          final name = (u['name'] ?? '').toString().toLowerCase();
          final abbr = (u['abbreviation'] ?? '').toString().toLowerCase();
          final type = (u['type'] ?? '').toString().toLowerCase();
          return name.contains(q) || abbr.contains(q) || type.contains(q);
        }).toList();
      }
    });
  }

  Future<void> _saveMaterial({required bool keepAdding}) async {
    final name = namaBarangController.text.trim();

    if (name.isEmpty) {
      showSnackbar(context, {"message": "Nama barang wajib diisi"});
      return;
    }
    if (_selectedUnitId.isEmpty) {
      showSnackbar(context, {"message": "Unit/Satuan wajib dipilih"});
      return;
    }

    whenLoading(context);
    final rc = await createMasterData(
      context,
      widget.token,
      widget.merchantId,
      name,
      _selectedUnitId,
    );

    if (!mounted) return;

    if (rc == "00") {
      if (keepAdding) {
        setState(() {
          namaBarangController.clear();
        });
      } else {
        namaBarangController.clear();
        await _fetchMaterials();
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      }
    }
  }

  Future<Map<String, dynamic>?> _deleteMaterial(String itemId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/inventory/master/delete'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
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

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (data != null && data['rc'] == '00') {
        _showDetailBottomSheet(Map<String, dynamic>.from(data['data']));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal memuat detail')));
      }
    } catch (e) {
      if (!mounted) return;
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
                              color: primary500.withValues(alpha: 0.1),
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
                              _confirmDeleteMaterial(
                                itemId: detail['item_id'].toString(),
                                itemName:
                                    (detail['name_item'] ??
                                            detail['item_name'] ??
                                            '-')
                                        .toString(),
                              );
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
                      return _buildActivityCard(
                        Map<String, dynamic>.from(activity),
                      );
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

  Future<Map<String, dynamic>?> updateInventoryMaster(
    BuildContext context,
    String token,
    String inventoryMasterId,
    String nameItem,
    int unitId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(updateMasterDataLink),
        headers: {'token': token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "inventory_master_id": inventoryMasterId,
          "name_item": nameItem,
          "unit": unitId,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error updateInventoryMaster: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> deleteInventoryMaster(
    BuildContext context,
    String token,
    List<String> inventoryMasterIds,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(deleteMasterDataLink),
        headers: {'token': token, 'Content-Type': 'application/json'},
        body: jsonEncode({"inventory_master_id": inventoryMasterIds}),
      );
    } catch (e) {
      debugPrint('Error deleteInventoryMaster: $e');
      return null;
    }
  }

  void _showLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoader() {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  Future<void> _openAturMaterial(Map<String, dynamic> material) async {
    final itemId = (material['id'] ?? '').toString();

    _showLoader();
    final res = await getMaterialInventoryDetail(context, widget.token, itemId);
    if (!mounted) return;
    _hideLoader();

    if (res == null || res['rc'] != '00') {
      showSnackbar(context, {
        "message": res?['message']?.toString() ?? "Gagal memuat detail",
      });
      return;
    }

    final data = Map<String, dynamic>.from(res['data'] ?? {});
    final itemName = (data['item_name'] ?? '').toString();
    final unitIdStr = (data['unit_id'] ?? '').toString();
    final unitId = int.tryParse(unitIdStr) ?? 0;

    final detailList = (data['detail'] as List?) ?? [];
    final locked = detailList.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        Widget lockedTile({required IconData icon, required String title}) {
          return ListTile(
            enabled: false,
            leading: Icon(icon, color: bnw500),
            title: Text(title, style: body2(FontWeight.w500, bnw500, 'Outfit')),
            subtitle: Text(
              'Tidak bisa karena sudah ada riwayat',
              style: body2(FontWeight.w400, bnw500, 'Outfit'),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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

              const SizedBox(height: 16),
              Text(
                itemName,
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              const SizedBox(height: 12),

              if (locked)
                lockedTile(
                  icon: PhosphorIcons.pencil_line,
                  title: 'Ubah nama bahan',
                )
              else
                ListTile(
                  leading: Icon(PhosphorIcons.pencil_line, color: bnw900),
                  title: const Text('Ubah Nama Bahan'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showRenameDialog(
                      itemId: itemId,
                      currentName: itemName,
                      unitId: unitId,
                    );
                  },
                ),

              if (locked)
                lockedTile(icon: PhosphorIcons.trash, title: 'Hapus Bahan')
              else
                ListTile(
                  leading: Icon(PhosphorIcons.trash, color: red500),
                  title: const Text('Hapus Bahan'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDeleteMaterial(itemId: itemId, itemName: itemName);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog({
    required String itemId,
    required String currentName,
    required int unitId,
  }) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Nama Bahan'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Masukkan nama bahan'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) {
                  showSnackbar(context, {"message": "Nama bahan wajib diisi"});
                }
                Navigator.pop(context);

                _showLoader();
                final res = await updateInventoryMaster(
                  context,
                  widget.token,
                  itemId,
                  newName,
                  unitId,
                );
                if (!mounted) return;
                _hideLoader();

                if (res != null && res['rc'] == '00') {
                  await _fetchMaterials();
                  showSnackbar(context, {
                    "message": "Nama bahan berhasil diubah",
                  });
                } else {
                  showSnackbar(context, {
                    "message": (res?['message'] ?? "Gagal mengubah nama")
                        .toString(),
                  });
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteMaterial({
    required String itemId,
    required String itemName,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Bahan?'),
          content: Text('Yakin ingin menghapus "$itemName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                _showLoader();

                final res = await deleteInventoryMaster(context, widget.token, [
                  itemId,
                ]);
                if (!mounted) return;
                _hideLoader();

                if (res != null && res['rc'] == '00') {
                  await _fetchMaterials();
                  showSnackbar(context, {"message": "Bahan berhasil dihapus"});
                } else {
                  showSnackbar(context, {
                    "message": (res?['message'] ?? "Gagal menghapus bahan")
                        .toString(),
                  });
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final activityType = (activity['activity_type'] ?? '').toString();
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
          // SizedBox(height: 8),
          // _buildDetailRow('Harga Satuan', _formatCurrency(0)),
          // SizedBox(height: 8),
          // _buildDetailRow('Total', _formatCurrency(0)),
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
    final n = double.tryParse(qty?.toString() ?? '') ?? 0;
    if (n == 0) return '0';
    if (n < 1) return n.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
    if (n % 1 == 0) return n.toStringAsFixed(0);
    return n.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  late final NumberFormat _idr = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;

    var s = value.toString().trim();
    if (s.isEmpty) return 0;

    s = s
        .replaceAll('Rp', '')
        .replaceAll('rp', '')
        .replaceAll('IDR', '')
        .replaceAll(RegExp(r'\s+'), '');

    bool isNegative = false;
    if (s.startsWith('(') && s.endsWith(')')) {
      isNegative = true;
      s = s.substring(1, s.length - 1);
    }

    s = s.replaceAll(RegExp(r'[^0-9,.\-]'), '');

    if (s.contains('-')) {
      isNegative = isNegative || s.startsWith('-');
      s = s.replaceAll('-', '');
    }

    final lastComma = s.lastIndexOf(',');
    final lastDot = s.lastIndexOf('.');

    if (lastComma != -1 && lastDot != -1) {
      if (lastComma > lastDot) {
        s = s.replaceAll('.', '').replaceAll(',', '');
      } else {
        s = s.replaceAll(',', '');
      }
    } else if (lastComma != -1) {
      final digitsAfter = s.length - lastComma - 1;
      if (digitsAfter <= 2) {
        s = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        s = s.replaceAll(',', '');
      }
    } else {
      final dotCount = '.'.allMatches(s).length;
      if (dotCount > 1) s = s.replaceAll('.', '');
    }
    final n = double.tryParse(s) ?? 0;
    return isNegative ? -n : n;
  }

  String _formatCurrency(dynamic value) {
    final n = _toNum(value);
    return _idr.format(n);
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

  Widget fieldTambahBahan(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: heading4(FontWeight.w400, bnw900, 'Outfit')),
          ],
        ),
        SizedBox(height: size8),
        TextField(
          controller: controller,
          cursorColor: primary500,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: heading3(FontWeight.w400, bnw500, 'Outfit'),
            filled: true,
            fillColor: bnw100,
            contentPadding: EdgeInsets.symmetric(
              horizontal: size16,
              vertical: size16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size12),
              borderSide: BorderSide(color: bnw300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size12),
              borderSide: BorderSide(width: 2, color: primary500),
            ),
          ),
        ),
      ],
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.merchantName ?? nameToko ?? 'Inventori',
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
        children: [
          _buildMaterialTab(),
          PurchaseTab(
            token: widget.token,
            merchantId: widget.merchantId,
            typeMerchant: typeAccount ?? '',
          ),
          AdjustmentTab(
            token: widget.token,
            merchantId: widget.merchantId,
            typeMerchant: typeAccount ?? '',
          ),
          ProductMaterialTab(
            token: widget.token,
            merchantId: widget.merchantId,
            typeMerchant: typeAccount ?? '',
          ),
          UnitConversionTab(token: widget.token, merchantId: widget.merchantId),
        ],
      ),
    );
  }

  Widget _buildMaterialTab() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [_materialListPage(), _tambahMaterialPage()],
    );
  }

  Widget _materialListPage() {
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

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: _canInventory
              ? GestureDetector(
                  onTap: () async {
                    namaBarangController.clear();
                    setState(() {
                      _selectedUnitId = "";
                      _selectedUnitLabel = "";
                    });

                    if (_unitList.isEmpty) {
                      await _fetchUnitMaster();
                    }

                    if (_pageController.hasClients) {
                      _pageController.jumpToPage(1);
                    }
                  },
                  child: buttonXL(
                    Row(
                      children: [
                        Icon(PhosphorIcons.plus, color: bnw100),
                        SizedBox(width: size16),
                        Text(
                          'Bahan',
                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ],
                    ),
                    0,
                  ),
                )
              : null,
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

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatQty(material['qty']),
                  style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                ),
                const SizedBox(height: 8),

                if (_canInventory)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openAturMaterial(material),
                    child: buttonL(
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.pencil_line_fill,
                            color: bnw900,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Atur',
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                      bnw100,
                      bnw300,
                    ),
                  ),
              ],
            ),
            // Text(
            //   _formatQty(material['qty']),
            //   style: heading2(FontWeight.w700, bnw900, 'Outfit'),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _tambahMaterialPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await _fetchMaterials();
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(0);
                  }
                },
                child: Icon(
                  PhosphorIcons.arrow_left,
                  size: size48,
                  color: bnw900,
                ),
              ),
              SizedBox(width: size16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Bahan',
                      style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    Text(
                      'Penambahan bahan/material',
                      style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size16),
          Expanded(
            child: Column(
              children: [
                fieldTambahBahan('Nama Barang', namaBarangController, 'Matcha'),
                SizedBox(height: size16),
                _unitPickerField(),
              ],
            ),
          ),
          SizedBox(height: size16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _saveMaterial(keepAdding: true),
                  child: buttonXLoutline(
                    Center(
                      child: Text(
                        'Simpan & Tambah Baru',
                        style: heading3(FontWeight.w600, primary500, 'Outfit'),
                      ),
                    ),
                    double.infinity,
                    primary500,
                  ),
                ),
              ),
              SizedBox(width: size12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _saveMaterial(keepAdding: false),
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
          ),
        ],
      ),
    );
  }

  Widget _unitPickerField() {
    return GestureDetector(
      onTap: () async {
        if (_unitList.isEmpty) {
          await _fetchUnitMaster();
        }
        _showUnitBottomSheet();
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
                    'Unit/Satuan',
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
                    Expanded(
                      child: Text(
                        _selectedUnitId.isEmpty
                            ? 'Pilih Unit/Satuan'
                            : _selectedUnitLabel,
                        overflow: TextOverflow.ellipsis,
                        style: heading2(
                          FontWeight.w600,
                          _selectedUnitId.isEmpty ? bnw500 : bnw900,
                          'Outfit',
                        ),
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

  Future<dynamic> _showUnitBottomSheet() {
    bool isKeyboardActive = false;

    _searchUnitController.text = '';
    _runSearchUnit('');

    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setModalState) => FractionallySizedBox(
            heightFactor: isKeyboardActive ? 0.9 : 0.80,
            child: GestureDetector(
              onTap: () => _unitSearchFocusNode.unfocus(),
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
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
                            setModalState(() {});
                          },
                          child: TextField(
                            cursorColor: primary500,
                            controller: _searchUnitController,
                            focusNode: _unitSearchFocusNode,
                            onChanged: (value) {
                              _runSearchUnit(value);
                              setModalState(() {});
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
                                borderSide: BorderSide(color: bnw300),
                              ),
                              suffixIcon: _searchUnitController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchUnitController.text = '';
                                        _runSearchUnit('');
                                        setModalState(() {});
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
                              hintText: 'Cari unit / singkatan / tipe',
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
                            await _fetchUnitMaster();
                            setModalState(() {});
                          },
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: _filteredUnitList.length,
                            itemBuilder: (context, index) {
                              final unit = Map<String, dynamic>.from(
                                _filteredUnitList[index],
                              );
                              final unitId = unit['id'].toString();
                              final isSelected = unitId == _selectedUnitId;

                              final label =
                                  '${unit['name']}(${unit['abbreviation']})';

                              return Container(
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
                                  title: Text(label),
                                  subtitle: Text(
                                    (unit['type'] ?? '').toString(),
                                    style: body2(
                                      FontWeight.w400,
                                      bnw500,
                                      'Outfit',
                                    ),
                                  ),
                                  trailing: Icon(
                                    isSelected
                                        ? PhosphorIcons.radio_button_fill
                                        : PhosphorIcons.radio_button,
                                    color: isSelected ? primary500 : bnw900,
                                  ),
                                  onTap: () {
                                    _unitSearchFocusNode.unfocus();
                                    this.setState(() {
                                      _selectedUnitId = unitId;
                                      _selectedUnitLabel = label;
                                    });
                                    setModalState(() {});
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: FutureBuilder<http.Response>(
                future: http.post(
                  Uri.parse(getUnitMasterDataLink),
                  headers: {
                    'token': widget.token,
                    'Content-type': 'application/json',
                  },
                  body: jsonEncode({"deviceid": identifier}),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text('Gagal memuat data unit'));
                  }

                  final res = snapshot.data!;
                  Map<String, dynamic> decoded;

                  try {
                    decoded = jsonDecode(res.body) as Map<String, dynamic>;
                  } catch (_) {
                    return const Center(
                      child: Text('Response unit tidak valid'),
                    );
                  }

                  final List units =
                      (decoded['data'] ?? decoded['units'] ?? []) as List;

                  if (units.isEmpty) {
                    return const Center(child: Text('Data unit kosong'));
                  }

                  return ListView.separated(
                    controller: scrollController,
                    itemCount: units.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final u = units[index] as Map<String, dynamic>;

                      final unitId = u['id'] ?? u['unit_id'];
                      final unitName = u['name'] ?? u['unit_name'] ?? '-';
                      final isSelected = _selectedUnit?['id'] == unitId;

                      return ListTile(
                        title: Text(
                          unitName.toString(),
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: primary500, size: 18)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedUnit = {'id': unitId, 'name': unitName};
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
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
