import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
// (Multiple imports removed)
import 'package:unipos_app_335/models/produkmodel.dart';

// --- Local Models ---
class PMVariant {
  final String productvariantid;
  final String namevariant;

  PMVariant({required this.productvariantid, required this.namevariant});

  factory PMVariant.fromJson(Map<String, dynamic> json) {
    return PMVariant(
      productvariantid:
          json['id']?.toString() ??
          json['product_variant_id']?.toString() ??
          '',
      namevariant: json['name'] ?? json['product_variant_name'] ?? '',
    );
  }
}

class PMVariantCategory {
  final String id;
  final String title;
  final List<PMVariant> variants;

  PMVariantCategory({
    required this.id,
    required this.title,
    required this.variants,
  });

  factory PMVariantCategory.fromJson(Map<String, dynamic> json) {
    var list =
        json['product_variants'] as List? ?? json['variants'] as List? ?? [];
    return PMVariantCategory(
      id: json['id']?.toString() ?? '',
      title: json['name'] ?? json['title'] ?? '',
      variants: list.map((v) => PMVariant.fromJson(v)).toList(),
    );
  }
}

class PMProduct {
  final String productid;
  final String name;
  final String? productImage;
  final List<PMVariantCategory> variantCategories;

  PMProduct({
    required this.productid,
    required this.name,
    this.productImage,
    required this.variantCategories,
  });
}

// --- Main Tab Page ---
class ProductMaterialTab extends StatefulWidget {
  final String token;
  final String merchantId;
  final String typeMerchant;

  const ProductMaterialTab({
    super.key,
    required this.token,
    required this.merchantId,
    required this.typeMerchant,
  });

  @override
  ProductMaterialTabState createState() => ProductMaterialTabState();
}

class ProductMaterialTabState extends State<ProductMaterialTab> {
  bool _isLoading = true;
  List<dynamic> _productMaterials = [];
  String _searchQuery = "";
  String _normalizeType(String t) =>
      t.trim().toLowerCase().replaceAll(' ', '_');

  bool get _canMaterial {
    final t = _normalizeType(widget.typeMerchant);
    return t == 'merchant' || t == 'group_merchant';
  }

  void search(String query) {
    setState(() {
      _searchQuery = query;
    });
    _fetchProductMaterials();
  }

  @override
  void initState() {
    super.initState();
    _fetchProductMaterials();
  }

  Future<void> _fetchProductMaterials() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$url/api/product-material'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "merchant_id": widget.merchantId,
          "name": _searchQuery,
          "order_by": "name_asc",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _productMaterials = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error _fetchProductMaterials: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _deleteProductMaterial(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/product-material/delete'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_material_id": id,
          "merchant_id": widget.merchantId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }

  void _showOptionsModal(String id, String title, String productName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                            Text(
                              productName,
                              style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.x, color: bnw900),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: bnw300),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(PhosphorIcons.pencil_line, color: bnw900),
                  title: Text(
                    'Ubah Produk',
                    style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    navigateToAdd(productMaterialId: id);
                  },
                ),
                Divider(height: 1, color: bnw300),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(PhosphorIcons.trash, color: bnw900),
                  title: Text(
                    'Hapus Produk',
                    style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Yakin Ingin Menghapus Produk?',
                  textAlign: TextAlign.center,
                  style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Produk yang telah dihapus tidak dapat dikembalikan.',
                  textAlign: TextAlign.center,
                  style: body1(FontWeight.w400, bnw500, 'Outfit'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(modalContext);
                          final result = await _deleteProductMaterial(id);
                          if (mounted) {
                            showSnackbar(context, result ?? {"message": "Gagal menghapus data"});
                            if (result != null && result['rc'] == '00') {
                              _fetchProductMaterials();
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: primary500),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Iya, Hapus', style: heading3(FontWeight.w600, primary500, 'Outfit')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(modalContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary500,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Batalkan', style: heading3(FontWeight.w600, bnw100, 'Outfit')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Column(
        children: [
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
                    child: Text('Judul', style: heading4(FontWeight.w700, bnw100, 'Outfit')),
                  ),
                ),
                Expanded(flex: 4, child: Text('Nama Produk', style: heading4(FontWeight.w600, bnw100, 'Outfit'))),
                SizedBox(width: 90, child: Text('Aksi', style: heading4(FontWeight.w600, bnw100, 'Outfit'))),
                SizedBox(width: size16),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _productMaterials.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada data Product Material',
                      style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _productMaterials.length,
                    itemBuilder: (context, index) {
                      final item = _productMaterials[index];
                      return _buildProductMaterialRow(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductMaterialRow(Map<String, dynamic> item) {
    return Container(
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
                item['title'] ?? '',
                style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              item['product_name'] ?? '',
              style: heading4(FontWeight.w400, bnw900, 'Outfit'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 90,
            child: _canMaterial ? GestureDetector(
              onTap: () => _showOptionsModal(item['id'], item['title'] ?? '', item['product_name'] ?? ''),
              child: buttonL(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.pencil_line_fill, color: bnw900, size: size20),
                    SizedBox(width: size4),
                    Text('Atur', style: heading4(FontWeight.w600, bnw900, 'Outfit')),
                  ],
                ),
                bnw100,
                bnw300,
              ),
            ) : SizedBox(),
          ),
          SizedBox(width: size16),
        ],
      ),
    );
  }

  void navigateToAdd({String? productMaterialId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductMaterialPage(
          token: widget.token,
          merchantId: widget.merchantId,
          typeMerchant: typeAccount ?? '',
          productMaterialId: productMaterialId,
          onSuccess: _fetchProductMaterials,
        ),
      ),
    );
  }
}

// --- Add/Edit Page ---
class AddProductMaterialPage extends StatefulWidget {
  final String token;
  final String merchantId;
  final String typeMerchant;
  final String? productMaterialId;
  final VoidCallback onSuccess;

  const AddProductMaterialPage({
    super.key,
    required this.token,
    required this.merchantId,
    required this.typeMerchant,
    this.productMaterialId,
    required this.onSuccess,
  });

  @override
  _AddProductMaterialPageState createState() => _AddProductMaterialPageState();
}

class _AddProductMaterialPageState extends State<AddProductMaterialPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  PMProduct? _selectedProduct;
  bool _isLoading = false;
  late TabController _tabController;
  String _normalizeType(String t) =>
      t.trim().toLowerCase().replaceAll(' ', '_');

  bool get _canMaterial => _normalizeType(widget.typeMerchant) == 'merchant';

  // Storage for materials
  List<Map<String, dynamic>> _baseMaterials = [];
  Map<String, List<Map<String, dynamic>>> _variantMaterials = {};

  List<dynamic> _allMaterials = []; // Cache for picker
  bool _isMaterialsLoaded = false;

  // Current view state
  String?
  _selectedVariantId; // null means base product, else it's the product_variant_id

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.productMaterialId != null) {
      _fetchSingleProductMaterial();
    }
    _loadAllMaterials();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadAllMaterials() async {
    final data = await _getMaterialInventory();
    if (data != null) {
      setState(() {
        _allMaterials = data['data'] ?? [];
        _isMaterialsLoaded = true;
      });
    }
  }

  Future<Map<String, dynamic>?> _getMaterialInventory() async {
    try {
      final response = await http.post(
        Uri.parse(getMasterDataLink),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "merchant_id": widget.merchantId.isEmpty ? null : widget.merchantId,
          "isMinimize": false,
          "name": "",
          "order_by": "",
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }

  Future<void> _fetchSingleProductMaterial() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$url/api/product-material/single'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "product_material_id": widget.productMaterialId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _titleController.text = data['title'] ?? '';

          _selectedProduct = PMProduct(
            productid: data['product_id'],
            name: data['product_name'],
            variantCategories: [], // Will fetch below
          );

          _baseMaterials.clear();
          _variantMaterials.clear();

          // Populate materials
          final details = (data['detail'] as List?) ?? [];
          for (var detail in details) {
            final mat = {
              'inventory_master_id': detail['inventory_master_id'],
              'item_name': detail['item_name'],
              'unit_name': detail['unit_name'],
              'unit_abbreviation': detail['unit_abbreviation'],
              'quantity_needed': detail['quantity_needed'],
              'unit_conversion_id': detail['unit_conversion_id'],
              'unit_conversion_name': detail['unit_conversion_name'],
              'product_variant_id': detail['product_variant_id'],
            };

            if (detail['product_variant_id'] == null) {
              _baseMaterials.add(mat);
            } else {
              final vid = detail['product_variant_id'];
              if (!_variantMaterials.containsKey(vid)) {
                _variantMaterials[vid] = [];
              }
              _variantMaterials[vid]!.add(mat);
            }
          }
        });

        // Fetch variants to show in the "Variant" tab
        final cats = await getProductVariantTransaksi(
          context,
          widget.token,
          widget.merchantId,
          _selectedProduct!.productid,
        );
        setState(() {
          if (cats != null) {
            _selectedProduct = PMProduct(
              productid: _selectedProduct!.productid,
              name: _selectedProduct!.name,
              variantCategories: (cats as List).map((c) {
                // Map incoming ProductVariantCategory object to local PMVariantCategory
                // Assuming 'c' is the object returned by getProductVariantTransaksi
                return PMVariantCategory(
                  id: c.id,
                  title: c.title,
                  variants: (c.productVariants as List)
                      .map(
                        (v) => PMVariant(
                          productvariantid: v.id,
                          namevariant: v.name,
                        ),
                      )
                      .toList(),
                );
              }).toList(),
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error _fetchSingleProductMaterial: $e');
      setState(() => _isLoading = false);
    }
  }

  void _addMaterialToList(Map<String, dynamic> mat) {
    setState(() {
      if (_selectedVariantId == null) {
        _baseMaterials.add(mat);
      } else {
        if (!_variantMaterials.containsKey(_selectedVariantId)) {
          _variantMaterials[_selectedVariantId!] = [];
        }
        _variantMaterials[_selectedVariantId!]!.add(mat);
      }
    });
  }

  void _showUnitConversionPicker(
    Map<String, dynamic> material,
    Function(String?, String, double) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final conversions = (material['unit_conversion'] as List?) ?? [];
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  'Pilih Unit Konversi',
                  style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                ),
                SizedBox(height: 20),
                // Default unit
                ListTile(
                  title: Text(
                    material['unit_name'] ?? material['unit_abbreviation'] ?? '-',
                    style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  onTap: () {
                    onSelected(null, material['unit_abbreviation'] ?? "-", 1.0);
                    Navigator.pop(context);
                  },
                ),
                if (conversions.isNotEmpty) Divider(),
                // Unit conversions
                ...conversions.map((conversion) {
                  return ListTile(
                    title: Text(
                      conversion['unit_conversion_name'] ?? '',
                      style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                    subtitle: Text(
                      'Factor: ${conversion['conversion_factor']}',
                      style: body2(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                    onTap: () {
                      onSelected(
                        conversion['unit_conversion_id'],
                        conversion['unit_conversion_name'] ?? '',
                        double.tryParse(
                              conversion['conversion_factor'].toString(),
                            ) ??
                            1.0,
                      );
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMaterialDetailInput(
    Map<String, dynamic> material,
    Function setParentModalState,
  ) {
    final qtyController = TextEditingController();
    String? selectedConversionId;
    String selectedConversionName = material['unit_abbreviation'] ?? '';
    double conversionFactor = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDetailState) {
          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
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
                      'Tambah Pemakaian',
                      style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    Text(
                      'Pilih bahan yang sudah terpakai',
                      style: body2(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.check_circle,
                          color: primary500,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material['name_item'] ?? '',
                                style: heading3(
                                  FontWeight.w600,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              Text(
                                material['unit_name'] ?? '',
                                style: body2(FontWeight.w400, bnw500, 'Outfit'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primary500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Qty',
                                  style: body2(FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: TextField(
                                  controller: qtyController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    border: InputBorder.none,
                                  ),
                                  style: heading3(
                                    FontWeight.w600,
                                    bnw900,
                                    'Outfit',
                                  ),
                                  onChanged: (v) => setDetailState(() {}),
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Unit Konversi',
                                  style: body2(FontWeight.w400, bnw900, 'Outfit'),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _showUnitConversionPicker(material, (
                                    id,
                                    name,
                                    factor,
                                  ) {
                                    setDetailState(() {
                                      selectedConversionId = id;
                                      selectedConversionName = name;
                                      conversionFactor = factor;
                                    });
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: primary500),
                                    borderRadius: BorderRadius.circular(8),
                                    color: bnw100,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        selectedConversionName,
                                        style: body2(
                                          FontWeight.w400,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      Icon(
                                        Icons.unfold_more,
                                        size: 16,
                                        color: bnw500,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final qty = qtyController.text;
                          if (qty.isNotEmpty) {
                            _addMaterialToList({
                              'inventory_master_id': material['id'],
                              'item_name': material['name_item'],
                              'unit_name': material['unit_name'],
                              'unit_abbreviation': material['unit_abbreviation'],
                              'quantity_needed': qty,
                              'unit_conversion_id': selectedConversionId,
                              'unit_conversion_name': selectedConversionName,
                            });
                            Navigator.pop(context); // Close detail input
                            setParentModalState(
                              () {},
                            ); // update checkbox state in parent
                          }
                        },
                        child: Text(
                          'Simpan',
                          style: heading3(
                            FontWeight.w600,
                            bnw100,
                            'Outfit',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary500,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMaterialPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: StatefulBuilder(
          builder: (context, setModalState) {
            if (!_isMaterialsLoaded && _allMaterials.isEmpty) {
              return Container(
                height: 300,
                decoration: BoxDecoration(
                  color: bnw100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
        
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  SizedBox(height: 20),
                  Text(
                    'Tambah Pemakaian',
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Pilih bahan yang sudah terpakai',
                    style: body2(FontWeight.w400, bnw500, 'Outfit'),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _allMaterials.length,
                      itemBuilder: (context, index) {
                        final material = _allMaterials[index];
                        // check isSelected
                        bool isSelected = false;
                        if (_selectedVariantId == null) {
                          isSelected = _baseMaterials.any(
                            (m) => m['inventory_master_id'] == material['id'],
                          );
                        } else {
                          isSelected =
                              (_variantMaterials[_selectedVariantId!] ?? []).any(
                                (m) => m['inventory_master_id'] == material['id'],
                              );
                        }
        
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (checked) {
                            if (checked == true) {
                              _showMaterialDetailInput(material, setModalState);
                            } else {
                              setState(() {
                                if (_selectedVariantId == null) {
                                  _baseMaterials.removeWhere(
                                    (m) =>
                                        m['inventory_master_id'] ==
                                        material['id'],
                                  );
                                } else {
                                  _variantMaterials[_selectedVariantId!]
                                      ?.removeWhere(
                                        (m) =>
                                            m['inventory_master_id'] ==
                                            material['id'],
                                      );
                                }
                              });
                              setModalState(() {});
                            }
                          },
                          title: Text(
                            material['name_item'] ?? '',
                            style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          subtitle: Text(
                            material['unit_name'] ?? '',
                            style: body2(FontWeight.w400, bnw500, 'Outfit'),
                          ),
                          activeColor: primary500,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: primary500),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: heading3(
                              FontWeight.w600,
                              primary500,
                              'Outfit',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary500,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Simpan',
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
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
                    Text(
                      'Pilih Produk',
                      style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ProductPickerList(
                  token: widget.token,
                  merchantId: widget.merchantId,
                  onSelected: (product) async {
                    setState(() => _isLoading = true);
                    // Fetch variants when product is selected
                    final cats = await getProductVariantTransaksi(
                      context,
                      widget.token,
                      widget.merchantId,
                      product.productid,
                    );
                    setState(() {
                      if (cats != null) {
                        _selectedProduct = PMProduct(
                          productid: product.productid,
                          name: product.name,
                          productImage: product.productImage,
                          variantCategories: (cats as List).map((c) {
                            return PMVariantCategory(
                              id: c.id,
                              title: c.title,
                              variants: (c.productVariants as List)
                                  .map(
                                    (v) => PMVariant(
                                      productvariantid: v.id,
                                      namevariant: v.name,
                                    ),
                                  )
                                  .toList(),
                            );
                          }).toList(),
                        );
                      } else {
                        _selectedProduct = PMProduct(
                          productid: product.productid,
                          name: product.name,
                          productImage: product.productImage,
                          variantCategories: [],
                        );
                      }
                      _variantMaterials.clear();
                      _baseMaterials.clear();
                      _isLoading = false;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave({bool stayOnPage = false}) async {
    if (_titleController.text.isEmpty || _selectedProduct == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Judul dan Produk harus diisi')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final isUpdate = widget.productMaterialId != null;
      final endpoint = isUpdate
          ? 'api/product-material/update'
          : 'api/product-material/create';

      List<Map<String, dynamic>> allDetails = [];

      // Base materials
      for (var m in _baseMaterials) {
        allDetails.add({
          "inventory_master_id": m['inventory_master_id'],
          "quantity_needed": m['quantity_needed'],
          "unit_conversion_id": m['unit_conversion_id'],
          "product_variant_id": null,
        });
      }

      // Variant materials
      _variantMaterials.forEach((vid, list) {
        for (var m in list) {
          allDetails.add({
            "inventory_master_id": m['inventory_master_id'],
            "quantity_needed": m['quantity_needed'],
            "unit_conversion_id": m['unit_conversion_id'],
            "product_variant_id": vid,
          });
        }
      });

      final body = {
        if (isUpdate) "product_material_id": widget.productMaterialId,
        "title": _titleController.text,
        "merchant_id": widget.merchantId,
        "product_id": _selectedProduct!.productid,
        "detail": allDetails,
      };

      final response = await http.post(
        Uri.parse('$url/$endpoint'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('API STATUS: ${response.statusCode}');
      debugPrint('API BODY: ${response.body}');

      final result = jsonDecode(response.body);
      debugPrint('PRODUCT MATERIAL SAVE RESPONSE: ${jsonEncode(result)}');

      if (result['rc'] == '00') {
        if (!mounted) return;
        showSnackbar(context, result);
        widget.onSuccess();
        if (stayOnPage) {
          setState(() {
            _titleController.clear();
            _selectedProduct = null;
            _baseMaterials.clear();
            _variantMaterials.clear();
            _selectedVariantId = null;
          });
          showSnackbar(context, result);
        } else {
          Navigator.pop(context);
          showSnackbar(context, result);
        }
      } else {
        showSnackbar(context, result);
      }
    } catch (e) {
      print('Error _handleSave: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$url/api/product-material/delete'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_material_id": widget.productMaterialId,
          "merchant_id": widget.merchantId,
        }),
      );

      final result = jsonDecode(response.body);
      print('PRODUCT MATERIAL DELETE STATUS: ${response.statusCode}');
      print('PRODUCT MATERIAL DELETE RESPONSE: ${jsonEncode(result)}');

      if (result['rc'] == '00') {
        widget.onSuccess();
        Navigator.pop(context);
        showSnackbar(context, result);
      } else {
        showSnackbar(context, result);
      }
    } catch (e) {
      print('Error _handleDelete: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildMaterialItemCard(Map<String, dynamic> m, VoidCallback onDelete) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bnw100,
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
                  m['item_name'] ?? '',
                  style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                ),
                Text(
                  '${formatQty(m['quantity_needed'])} ${m['unit_name'] ?? ''}',
                  style: body2(FontWeight.w400, bnw500, 'Outfit'),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(PhosphorIcons.trash, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildBaseProductTab() {
    return Column(
      children: [
        if (_baseMaterials.isEmpty)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.package, size: 64, color: bnw300),
                SizedBox(height: 12),
                Text(
                  'Masukan data bill of material',
                  style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16),
              itemCount: _baseMaterials.length,
              itemBuilder: (context, index) {
                final m = _baseMaterials[index];
                return _buildMaterialItemCard(m, () {
                  setState(() => _baseMaterials.removeAt(index));
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildVariantTab() {
    if (_selectedProduct == null) {
      return Center(
        child: Text(
          'Pilih produk dulu',
          style: body2(FontWeight.w400, bnw500, 'Outfit'),
        ),
      );
    }

    if (_selectedProduct!.variantCategories.isEmpty) {
      return Center(
        child: Text(
          'belum memiliki variant',
          style: body2(FontWeight.w400, bnw500, 'Outfit'),
        ),
      );
    }

    if (_selectedVariantId != null) {
      String? variantName;
      for (var cat in _selectedProduct!.variantCategories) {
        for (var v in cat.variants) {
          if (v.productvariantid == _selectedVariantId) {
            variantName = v.namevariant;
            break;
          }
        }
      }

      final list = _variantMaterials[_selectedVariantId!] ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => setState(() => _selectedVariantId = null),
            icon: Icon(PhosphorIcons.arrow_left, size: 16, color: bnw900),
            label: Text(
              'Kembali - ${variantName ?? ''}',
              style: heading4(FontWeight.w600, bnw900, 'Outfit'),
            ),
            style: TextButton.styleFrom(foregroundColor: bnw900),
          ),
          if (list.isEmpty)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Icon(PhosphorIcons.package, size: 64, color: bnw300),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Masukan data bill of material',
                    style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final m = list[index];
                  return _buildMaterialItemCard(m, () {
                    setState(() => list.removeAt(index));
                  });
                },
              ),
            ),
        ],
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 16),
      itemCount: _selectedProduct!.variantCategories.length,
      itemBuilder: (context, index) {
        final cat = _selectedProduct!.variantCategories[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: bnw200),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                cat.title,
                style: heading3(FontWeight.w600, bnw900, 'Outfit'),
              ),
              children: cat.variants.map((v) {
                final count =
                    (_variantMaterials[v.productvariantid]?.length ?? 0);
                return Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: bnw200)),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      v.namevariant,
                      style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                    subtitle: Text(
                      '$count Bahan Terpilih',
                      style: body2(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => setState(
                        () => _selectedVariantId = v.productvariantid,
                      ),
                      child: Text(
                        'Pilih',
                        style: body2(FontWeight.w600, bnw100, 'Outfit'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                        foregroundColor: bnw100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showBottomActions = true;
    if (_tabController.index == 1 && _selectedVariantId == null) {
      showBottomActions = false;
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: bnw100,
        appBar: AppBar(
          title: Text(
            widget.productMaterialId == null
                ? 'Tambah Bill Of Material'
                : 'Edit Bill Of Material',
            style: heading2(FontWeight.w700, bnw900, 'Outfit'),
          ),
          leading: IconButton(
            icon: Icon(PhosphorIcons.arrow_left, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: bnw100,
          actions: [
            if (widget.productMaterialId != null)
              IconButton(
                icon: Icon(PhosphorIcons.trash, color: Colors.red),
                onPressed: _handleDelete,
              ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Judul ',
                              style: body1(FontWeight.w400, bnw900, 'Outfit'),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Cth: Pembelian Matcha',
                              border: UnderlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: bnw300),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary500),
                              ),
                            ),
                            style: body1(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: 24),
                          RichText(
                            text: TextSpan(
                              text: 'Produk ',
                              style: body1(FontWeight.w400, bnw900, 'Outfit'),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: _showProductPicker,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: primary500),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedProduct?.name ?? '-',
                                    style: heading4(
                                      FontWeight.w500,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.unfold_more, color: bnw500),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          TabBar(
                            controller: _tabController,
                            labelColor: primary500,
                            unselectedLabelColor: bnw500,
                            indicatorColor: primary500,
                            labelStyle: heading4(
                              FontWeight.w600,
                              primary500,
                              'Outfit',
                            ),
                            unselectedLabelStyle: heading4(
                              FontWeight.w400,
                              bnw500,
                              'Outfit',
                            ),
                            tabs: [
                              Tab(text: 'Base Produk'),
                              Tab(text: 'Variant'),
                            ],
                            onTap: (index) {
                              setState(
                                () {},
                              ); // Trigger rebuild to check bottom action visibility
                            },
                          ),
                          SizedBox(
                            height: 500,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildBaseProductTab(),
                                _buildVariantTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: showBottomActions
            ? Container(
                decoration: BoxDecoration(
                  color: bnw100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                                  if (_selectedProduct == null) {
                                    showSnackbar(context, {"message": 'Pilih produk dulu'});
                                    return;
                                  }
                                  _showMaterialPicker();
                                },
                          child: Text(
                            _selectedVariantId == null
                                ? 'Tambah untuk base produk'
                                : 'Tambah untuk variant',
                            style: heading3(
                              FontWeight.w600,
                              primary500,
                              'Outfit',
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: primary500),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          child: Text(
                            widget.productMaterialId == null
                                ? 'Simpan'
                                : 'Update',
                            style: heading3(
                              FontWeight.w600,
                              bnw100,
                              'Outfit',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary500,
                            foregroundColor: bnw100,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

// --- Pickers ---
class ProductPickerList extends StatefulWidget {
  final String token;
  final String merchantId;
  final Function(PMProduct) onSelected;

  ProductPickerList({
    required this.token,
    required this.merchantId,
    required this.onSelected,
  });

  @override
  _ProductPickerListState createState() => _ProductPickerListState();
}

class _ProductPickerListState extends State<ProductPickerList> {
  List<ModelDataProduk> _products = [];
  bool _isLoading = true;
  String _search = "";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final data = await getProduct(context, widget.token, _search, [
      widget.merchantId,
    ], 'upDownNama');
    setState(() {
      _products = data ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari Produk',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) {
              setState(() => _search = v);
              _loadProducts();
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: bnw100,
                        ),
                        child:
                            p.productImage != null && p.productImage!.isNotEmpty
                            ? Image.network(p.productImage!)
                            : Icon(Icons.image),
                      ),
                      title: Text(p.name ?? ''),
                      onTap: () => widget.onSelected(
                        PMProduct(
                          productid: p.productid ?? '',
                          name: p.name ?? '',
                          productImage: p.productImage,
                          variantCategories: [],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}


