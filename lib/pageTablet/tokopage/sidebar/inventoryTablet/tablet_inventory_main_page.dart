import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
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

// Tablet Inventory Module - Unified (replaces inventori.dart monolith)
import 'package:url_launcher/url_launcher.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoryTablet/tablet_purchase_inventory_page.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoryTablet/tablet_adjustment_inventory_page.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoryTablet/tablet_product_material_page.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoryTablet/tablet_unit_conversion_page.dart';

class MaterialInventoryPage extends StatefulWidget {
  final String token;
  final String merchantId;
  final String? merchantName;
  final String typeMerchant;
  final VoidCallback? onBackPressed;

  MaterialInventoryPage({
    Key? key,
    required this.token,
    required this.merchantId,
    this.merchantName,
    required this.typeMerchant,
    this.onBackPressed,
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

  final GlobalKey<PurchaseTabState> purchaseTabKey =
      GlobalKey<PurchaseTabState>();
  final GlobalKey<AdjustmentTabState> adjustmentTabKey =
      GlobalKey<AdjustmentTabState>();
  final GlobalKey<ProductMaterialTabState> productMaterialTabKey =
      GlobalKey<ProductMaterialTabState>();
  final GlobalKey<UnitConversionTabState> unitConversionTabKey =
      GlobalKey<UnitConversionTabState>();

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
      setState(() {});
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
        showSnackbar(context, {"message": 'Gagal memuat data material'});
        return;
      }

      if (res['rc'] != '00') {
        setState(() => _isLoading = false);
        showSnackbar(context, res);
        return;
      }

      final list = (res['data'] as List?) ?? [];

      setState(() {
        _materials = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showSnackbar(context, {"message": 'Terjadi kesalahan saat memuat data'});
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
    _showLoader();

    try {
      final data = await getMaterialInventoryDetail(
        context,
        widget.token,
        itemId,
      );

      if (!mounted) return;
      _hideLoader();

      if (data != null && data['rc'] == '00') {
        _showDetailBottomSheet(Map<String, dynamic>.from(data['data']));
      } else {
        showSnackbar(context, data ?? {"message": 'Gagal memuat detail'});
      }
    } catch (e) {
      if (!mounted) return;
      _hideLoader();
      showSnackbar(context, {"message": 'Gagal memuat detail'});
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
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: primary500),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.close, color: primary500, size: 20),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: bnw300)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: primary500,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            PhosphorIcons.archive_box,
                            color: bnw100,
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
                                style: heading3(
                                  FontWeight.w500,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              Text(
                                detail['unit_name'] ?? '',
                                style: body1(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                            ],
                          ),
                        ),
                        Container(height: 40, width: 2, color: primary500),
                        SizedBox(width: 16),
                        SizedBox(
                          width: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qty',
                                style: body1(FontWeight.w500, bnw900, 'Outfit'),
                              ),
                              Text(
                                _formatQty(detail['total_qty']),
                                style: body1(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.only(top: 16),
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
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Material'),
          content: Text('Apakah Anda yakin ingin menghapus material ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final response = await http.post(
                    Uri.parse(deleteMasterDataLink),
                    headers: {
                      'token': widget.token,
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode({"item_id": itemId}),
                  );
                  final data = jsonDecode(response.body);
                  if (data['rc'] == '00') {
                    showSnackbar(context, data);
                    _fetchMaterials();
                  } else {
                    showSnackbar(context, data);
                  }
                } catch (e) {
                  showSnackbar(context, {
                    "message": 'Gagal menghubungkan ke server',
                  });
                }
              },
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
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

    final unitName = (data['unit_name'] ?? '').toString();

    final detailList = (data['detail'] as List?) ?? [];
    final locked = detailList.isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (ctx) {
        Widget lockedTile({required IconData icon, required String title}) {
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            enabled: false,
            leading: Icon(icon, color: bnw500),
            title: Text(
              title,
              style: heading3(FontWeight.w400, bnw500, 'Outfit'),
            ),
            subtitle: Text(
              'Tidak bisa karena sudah ada riwayat',
              style: body2(FontWeight.w400, bnw500, 'Outfit'),
            ),
          );
        }

        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemName,
                              style: heading2(
                                FontWeight.w700,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            Text(
                              unitName,
                              style: heading3(
                                FontWeight.w400,
                                bnw500,
                                'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.x, color: bnw900),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: bnw300),
                if (locked)
                  lockedTile(
                    icon: PhosphorIcons.pencil_line,
                    title: 'Ubah Bahan',
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Icon(PhosphorIcons.pencil_line, color: bnw900),
                    title: Text(
                      'Ubah Bahan',
                      style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _navigateToAddEditMaterial(material: material);
                    },
                  ),
                Divider(height: 1, color: bnw300),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Icon(PhosphorIcons.download_simple, color: bnw900),
                  title: Text(
                    'Download Bahan',
                    style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  onTap: () {
                    // Action for download bahan
                  },
                ),
                Divider(height: 1, color: bnw300),
                if (locked)
                  lockedTile(icon: PhosphorIcons.trash, title: 'Hapus Bahan')
                else
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Icon(PhosphorIcons.trash, color: bnw900),
                    title: Text(
                      'Hapus Bahan',
                      style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmDeleteMaterial(
                        itemId: itemId,
                        itemName: itemName,
                      );
                    },
                  ),
              ],
            ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
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
                const SizedBox(height: 20),
                Text(
                  'Yakin Ingin Menghapus Bahan?',
                  textAlign: TextAlign.center,
                  style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bahan "$itemName" yang telah dihapus tidak dapat dikembalikan.',
                  textAlign: TextAlign.center,
                  style: body1(FontWeight.w400, bnw500, 'Outfit'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(modalCtx);
                          _showLoader();
                          final res = await deleteInventoryMaster(
                            context,
                            widget.token,
                            [itemId],
                          );
                          if (!mounted) return;
                          _hideLoader();
                          showSnackbar(
                            context,
                            res ?? {"message": "Gagal menghapus bahan"},
                          );
                          if (res != null && res['rc'] == '00') {
                            await _fetchMaterials();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: primary500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Iya, Hapus',
                          style: heading3(
                            FontWeight.w600,
                            primary500,
                            'Outfit',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(modalCtx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary500,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batalkan',
                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        badgeColor = Colors.greenAccent.shade700;
        badgeLabel = 'purchase';
        break;
      case 'adjustment':
        badgeColor = Colors.orange;
        badgeLabel = 'adjustment';
        break;
      case 'sales':
        badgeColor = primary500;
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
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bnw100,
        border: Border(bottom: BorderSide(color: bnw300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeLabel,
                  style: body1(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              Text(
                _formatDateTime(activity['activity_date']).split(' ').first,
                style: body1(FontWeight.w400, bnw900, 'Outfit'),
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildDetailRow('Jumlah', _formatQty(activity['qty'])),
          SizedBox(height: 2),
          _buildDetailRow(
            'Harga Satuan',
            _formatCurrency(activity['price'] ?? 0),
          ),
          SizedBox(height: 2),
          _buildDetailRow(
            'Total',
            _formatCurrency((activity['qty'] ?? 0) * (activity['price'] ?? 0)),
          ),
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
    double? v;
    if (qty is int) {
      v = qty.toDouble();
    } else if (qty is double) {
      v = qty;
    } else {
      v = double.tryParse(qty.toString());
    }
    if (v == null || v == 0) return '0';
    if (v == v.toInt()) return v.toInt().toString();
    return v
        .toString()
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
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
    return Container(
      margin: EdgeInsets.all(size16),
      padding: EdgeInsets.all(size16),
      decoration: BoxDecoration(
        color: bnw100,
        borderRadius: BorderRadius.circular(size16),
      ),
      child: Column(
        children: [
          // Custom Header Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: size16, vertical: size8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: bnw300)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
                  onPressed:
                      widget.onBackPressed ?? () => Navigator.pop(context),
                ),
                SizedBox(width: size8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.merchantName ?? nameToko ?? 'Inventori',
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Inventori',
                        style: body2(FontWeight.w400, bnw500, 'Outfit'),
                      ),
                    ],
                  ),
                ),
                if (!_isGroupMerchant)
                  if (_tabController.index == 3)
                    IconButton(
                      icon: Icon(PhosphorIcons.plus, color: bnw900),
                      onPressed: () {
                        productMaterialTabKey.currentState?.navigateToAdd();
                      },
                    )
                  else if (_tabController.index == 4)
                    IconButton(
                      icon: Icon(PhosphorIcons.plus, color: bnw900),
                      onPressed: () {
                        unitConversionTabKey.currentState?.navigateToAdd();
                      },
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.more_vert, color: bnw900),
                      onPressed: () {
                        _showMoreBottomSheet();
                      },
                    ),
              ],
            ),
          ),
          // TabBar Row
          if (!_isGroupMerchant)
            TabBar(
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
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMaterialTab(),
                PurchaseTab(
                  key: purchaseTabKey,
                  token: widget.token,
                  merchantId: widget.merchantId,
                  typeMerchant: typeAccount ?? '',
                ),
                AdjustmentTab(
                  key: adjustmentTabKey,
                  token: widget.token,
                  merchantId: widget.merchantId,
                  typeMerchant: typeAccount ?? '',
                ),
                ProductMaterialTab(
                  key: productMaterialTabKey,
                  token: widget.token,
                  merchantId: widget.merchantId,
                  typeMerchant: typeAccount ?? '',
                ),
                UnitConversionTab(
                  key: unitConversionTabKey,
                  token: widget.token,
                  merchantId: widget.merchantId,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreBottomSheet() {
    int index = _tabController.index;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
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
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(PhosphorIcons.plus, color: bnw900),
                  title: Text(
                    'Tambah',
                    style: heading3(FontWeight.w500, bnw900, 'Outfit'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (index == 0) {
                      _navigateToAddEditMaterial();
                    } else if (index == 1) {
                      purchaseTabKey.currentState?.navigateToAdd();
                    } else if (index == 2) {
                      adjustmentTabKey.currentState?.navigateToAdd();
                    } else if (index == 3) {
                      productMaterialTabKey.currentState?.navigateToAdd();
                    } else if (index == 4) {
                      unitConversionTabKey.currentState?.navigateToAdd();
                    }
                  },
                ),
                if (index == 0 || index == 1 || index == 2) ...[
                  ListTile(
                    leading: Icon(PhosphorIcons.download, color: bnw900),
                    title: Text(
                      'Download',
                      style: heading3(FontWeight.w500, bnw900, 'Outfit'),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await _downloadFile(index);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadFile(int index) async {
    whenLoading(context);
    String endpoint = '';
    Map<String, dynamic> reqBody = {};

    if (index == 0) {
      endpoint = getMasterDataLink; // api/inventory/master
      reqBody = {
        "deviceid": identifier,
        "merchant_id": widget.merchantId.isEmpty ? null : widget.merchantId,
        "isMinimize": false,
        "name": "",
        "order_by": "upDownCreated",
        "export": true,
      };
    } else if (index == 1) {
      endpoint = '$url/api/inventory/purchase/download';
      reqBody = {
        "group_id": "",
        "merchant_id": widget.merchantId,
        "type": "pdf",
      };
    } else if (index == 2) {
      endpoint = '$url/api/inventory/adjustment/download';
      reqBody = {
        "group_id": "",
        "merchant_id": widget.merchantId,
        "type": "pdf",
      };
    }

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode(reqBody),
      );

      if (!mounted) return;
      closeLoading(context);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['rc'] == '00') {
          String downloadUrl = jsonResponse['data']?.toString() ?? '';
          if (downloadUrl.isNotEmpty) {
            try {
              await launchUrl(
                Uri.parse(downloadUrl),
                mode: LaunchMode.externalApplication,
              );
            } catch (e) {
              showSnackbar(context, {"message": "Gagal membuka link url"});
            }
          } else {
            showSnackbar(context, {"message": "Link download kosong"});
          }
        } else {
          showSnackbar(context, jsonResponse);
        }
      } else {
        showSnackbar(context, {
          "message": 'Terjadi kesalahan, respon code ${response.statusCode}',
        });
      }
    } catch (e) {
      closeLoading(context);
      showSnackbar(context, {"message": 'Gagal menghubungkan ke server'});
    }
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sort filter
        Padding(
          padding: EdgeInsets.symmetric(vertical: size8),
          child: InkWell(
            onTap: _showSortModal,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size16,
                vertical: size12,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: bnw300),
                borderRadius: BorderRadius.circular(size8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIcons.funnel, color: bnw600, size: size20),
                  SizedBox(width: size8),
                  Text(
                    _selectedSortLabel,
                    style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                  ),
                  SizedBox(width: size8),
                  Icon(Icons.arrow_drop_down, color: bnw900),
                ],
              ),
            ),
          ),
        ),
        // Table Header (blue)
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: primary500,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size16),
              topRight: Radius.circular(size16),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.only(left: size16),
                  child: Text(
                    'Nama Bahan',
                    style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Satuan',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Qty',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(width: 90),
              SizedBox(width: size16),
            ],
          ),
        ),
        // Table Body
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primary500))
              : _materials.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada data material',
                    style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: primary100,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(size12),
                      bottomRight: Radius.circular(size12),
                    ),
                  ),
                  child: RefreshIndicator(
                    color: bnw100,
                    backgroundColor: primary500,
                    onRefresh: () => _fetchMaterials(),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _materials.length,
                      itemBuilder: (context, index) {
                        final material = Map<String, dynamic>.from(
                          _materials[index],
                        );
                        return _buildMaterialRow(material);
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMaterialRow(Map<String, dynamic> material) {
    return GestureDetector(
      onTap: () => _showMaterialDetail(
        (material['id'] ?? '').toString(),
        (material['name_item'] ?? '').toString(),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: size12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: bnw300, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.only(left: size16),
                child: Text(
                  (material['name_item'] ?? '').toString(),
                  style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                (material['unit_name'] ?? '').toString(),
                style: heading4(FontWeight.w400, bnw900, 'Outfit'),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatQty(material['qty']),
                style: heading4(FontWeight.w400, bnw900, 'Outfit'),
              ),
            ),
            SizedBox(
              width: 90,
              child: GestureDetector(
                onTap: () => _openAturMaterial(material),
                child: buttonL(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.pencil_line_fill,
                        color: bnw900,
                        size: size20,
                      ),
                      SizedBox(width: size4),
                      Text(
                        'Atur',
                        style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                  bnw100,
                  bnw300,
                ),
              ),
            ),
            SizedBox(width: size16),
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
            child: SafeArea(
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
                                suffixIcon:
                                    _searchUnitController.text.isNotEmpty
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
          ),
        );
      },
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
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
    String _searchQuery = '';

    final unitFuture = http.post(
      Uri.parse(getUnitMasterDataLink),
      headers: {'token': widget.token, 'Content-type': 'application/json'},
      body: jsonEncode({"deviceid": identifier}),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: bnw100,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: FutureBuilder<http.Response>(
                      future: unitFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return const Center(
                            child: Text('Gagal memuat data unit'),
                          );
                        }
                        final res = snapshot.data!;
                        Map<String, dynamic> decoded;
                        try {
                          decoded =
                              jsonDecode(res.body) as Map<String, dynamic>;
                        } catch (_) {
                          return const Center(
                            child: Text('Response unit tidak valid'),
                          );
                        }
                        final List allUnits =
                            (decoded['data'] ?? decoded['units'] ?? []) as List;
                        if (allUnits.isEmpty) {
                          return const Center(child: Text('Data unit kosong'));
                        }
                        final filtered = _searchQuery.isEmpty
                            ? allUnits
                            : allUnits.where((u) {
                                final name = (u['name'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                final abbr = (u['abbreviation'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                return name.contains(
                                      _searchQuery.toLowerCase(),
                                    ) ||
                                    abbr.contains(_searchQuery.toLowerCase());
                              }).toList();

                        return Column(
                          children: [
                            const SizedBox(height: 12),
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
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'Pilih Satuan/Unit',
                                style: heading2(
                                  FontWeight.w700,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText:
                                      'Cari satuan (contoh: kilogram, kg...)',
                                  hintStyle: body2(
                                    FontWeight.w400,
                                    bnw400,
                                    'Outfit',
                                  ),
                                  prefixIcon: Icon(Icons.search, color: bnw500),
                                  filled: true,
                                  fillColor: bnw200,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onChanged: (val) =>
                                    setModalState(() => _searchQuery = val),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: filtered.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Tidak ada satuan yang sesuai',
                                        style: body1(
                                          FontWeight.w400,
                                          bnw500,
                                          'Outfit',
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      controller: scrollController,
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final u =
                                            filtered[index]
                                                as Map<String, dynamic>;
                                        final unitId = u['id'] ?? u['unit_id'];
                                        final unitName =
                                            u['name'] ?? u['unit_name'] ?? '-';
                                        final abbr = u['abbreviation'] ?? '';
                                        final isSelected =
                                            _selectedUnit?['id'] == unitId;
                                        return ListTile(
                                          title: Text(
                                            '$unitName ($abbr)',
                                            style: heading4(
                                              FontWeight.w500,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                          trailing: isSelected
                                              ? Icon(
                                                  Icons.check,
                                                  color: primary500,
                                                  size: 18,
                                                )
                                              : null,
                                          onTap: () {
                                            setState(() {
                                              _selectedUnit = {
                                                'id': unitId,
                                                'name': unitName,
                                              };
                                            });
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
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
          if (isEdit) "inventory_master_id": widget.material!['id'],
          "name_item": name,
          "unit": _selectedUnit!['id'],
          if (widget.merchantId.isNotEmpty) "merchant_id": widget.merchantId,
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
      backgroundColor: bnw100,
      appBar: AppBar(
        backgroundColor: bnw100,
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
          : SafeArea(
              child: Column(
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
                              style: heading4(
                                FontWeight.w500,
                                bnw900,
                                'Outfit',
                              ),
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
                              hintStyle: body2(
                                FontWeight.w400,
                                bnw400,
                                'Outfit',
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: bnw300),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          RichText(
                            text: TextSpan(
                              text: 'Unit/Satuan',
                              style: heading4(
                                FontWeight.w500,
                                bnw900,
                                'Outfit',
                              ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedUnit?['name'] ??
                                        'Pilih Unit/Satuan',
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
                      color: bnw100,
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
                                'Simpan & Tambah Baru',
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
                              isEdit ? 'Simpan Perubahan' : 'Tambah Bahan',
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
                ],
              ),
            ),
    );
  }
}
