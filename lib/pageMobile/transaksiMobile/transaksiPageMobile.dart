import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter/widgets.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/pageMobile/dashboardMobile.dart';
import 'package:unipos_app_335/pageMobile/promoPageMobile/discount_model.dart';
import 'package:unipos_app_335/pageMobile/transaksiMobile/settings_tab.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/pageMobile/memberPageMobile.dart';
import 'dart:convert';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_orderBy.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/currency_formatter.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'history/riwayat_page.dart';
import 'bill_page.dart';

enum DetailMode { calculate, create }

int _toIntSafe(dynamic v, {int def = 0}) {
  if (v == null) return def;
  if (v is int) return v;

  if (v is num) return v.round();

  final s = v.toString().trim();
  final normalized = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
  if (normalized.isEmpty) return def;

  final i = int.tryParse(normalized);
  if (i != null) return i;

  final d = double.tryParse(normalized);
  return d?.round() ?? def;
}

bool _toBoolSafe(dynamic v) {
  if (v == null) return false;
  if (v == true) return true;
  if (v is bool) return v;
  if (v is int) return v == 1;

  final s = v.toString().trim().toLowerCase();
  return s == '1' || s == 'true' || s == 'yes';
}

int _variantTotalFromApi(List<dynamic> variants) {
  int total = 0;
  for (final cat in variants) {
    if (cat is! Map) continue;
    final list = (cat['variant'] as List?) ?? [];
    for (final v in list) {
      if (v is! Map) continue;
      total += _toIntSafe(v['variant_price']);
    }
  }
  return total;
}

int cartSubTotal(List<Map<String, dynamic>> cart) {
  int sum = 0;

  for (final item in cart) {
    final int qty = _toIntSafe(item['quantity'], def: 0);

    final num? totalAmount = item['total_amount'] as num?;
    if (totalAmount != null) {
      sum += totalAmount.round();
      continue;
    }

    final Product p = item['product'] as Product;
    final bool isOnline = item['is_online'] == true;
    final bool isCustomize = _toBoolSafe(item['is_customize']);
    final int? customAmount = item['custom_amount'] as int?;

    final int baseDefault = isOnline
        ? p.onlinePrice
        : (p.priceAfter ?? p.price);
    final int baseUsed = (isCustomize && customAmount != null)
        ? customAmount
        : baseDefault;

    final List<dynamic> rawVariants = (item['variants'] ?? []) as List;
    final int variantTotal = _toIntSafe(
      item['variant_total'],
      def: _variantTotalFromApi(rawVariants),
    );

    final num? unitNum = item['unit_amount'] as num?;
    final int unitAmount = unitNum?.round() ?? (baseUsed + variantTotal);

    sum += unitAmount * qty;
  }
  return sum;
}

List<Map<String, dynamic>> buildTransactionDetails(
  List<Map<String, dynamic>> cart, {
  required DetailMode mode,
  bool quantityAsString = false,
}) {
  return cart.map((item) {
    final Product p = item['product'] as Product;
    // print(object)
    final int qty = _toIntSafe(item['quantity'], def: 0);
    final bool isOnline = item['is_online'] == true;
    final bool isCustomize = _toBoolSafe(item['is_customize']);
    final int? customAmount = item['custom_amount'] as int?;
    final String notes = item['notes']?.toString() ?? "";
    // print("custom amount: $customAmount");
    final int baseDefault = isOnline
        ? p.onlinePrice
        : (p.priceAfter ?? p.price);
    final int baseUsed = (isCustomize && customAmount != null)
        ? customAmount
        : baseDefault;

    final List<dynamic> rawVariants = (item['variants'] ?? []) as List;

    final int varianTotal = _toIntSafe(
      item['variant_total'],
      def: _variantTotalFromApi(rawVariants),
    );

    final num? unitNum = item['unit_amount'] as num?;
    // final int unitAmount = unitNum?.round() ?? (baseUsed + varianTotal);
    final int amountToSend = baseUsed;
    final List<Map<String, dynamic>> variants = rawVariants
        .map((cat) {
          if (cat is! Map) return <String, dynamic>{};

          final String catId = cat['variant_category_id']?.toString() ?? '';

          List<dynamic> rawVarList = [];
          if (cat['variant'] is List) {
            rawVarList = cat['variant'] as List;
          } else if (cat['variant_id'] is List) {
            rawVarList = (cat['variant_id'] as List)
                .map((id) => {"variant_id": id})
                .toList();
          } else if (cat['variant_id'] != null) {
            rawVarList = [
              {"variant_id": cat['variant_id']},
            ];
          }

          final mappedVarList = rawVarList.map((v) {
            if (v is Map) {
              return {
                "variant_id": v['variant_id']?.toString() ?? '',
                "variant_price": _toIntSafe(v['variant_price'] ?? v['price']),
                "is_variant_customize": _toBoolSafe(v['is_variant_customize'])
                    ? 1
                    : 0,
              };
            }
            return {
              "variant_id": v.toString(),
              "variant_price": 0,
              "is_variant_customize": 0,
            };
          }).toList();

          return {"variant_category_id": catId, "variant": mappedVarList};
        })
        .where((e) => e.isNotEmpty)
        .toList();

    if (mode == DetailMode.calculate) {
      return {
        "product_id": p.id,
        "name": p.name,
        "amount": "${amountToSend}.00",
        "quantity": qty,
        "description": notes,
        "is_online": isOnline,
        "is_customize": isCustomize,
        "variants": variants,
      };
    }

    print(
      "data: ${jsonEncode({"product_id": p.id.toString(), "request_id": "", "is_online": isOnline, "is_customize": isCustomize, "amount": amountToSend, "name": p.name, "quantity": quantityAsString ? qty.toString() : qty, "description": notes, "variants": variants})}",
    );

    return {
      "product_id": p.id.toString(),
      "request_id": "",
      "is_online": isOnline,
      "is_customize": isCustomize,
      "amount": amountToSend,
      "name": p.name,
      "quantity": quantityAsString ? qty.toString() : qty,
      "description": notes,
      "variants": variants,
    };
  }).toList();
}

class Product {
  final String id;
  final String name;
  final int price;
  final int onlinePrice;
  final int? priceAfter;
  final double? discount;
  final String? discountType;
  final String category;
  final String? imageUrl;
  final bool? isCustomize;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.onlinePrice,
    this.priceAfter,
    this.discount,
    this.discountType,
    required this.category,
    this.imageUrl,
    this.isCustomize,
  });

  static int _toInt(dynamic v, {int def = 0}) {
    if (v == null) return def;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? def;
  }

  static int? _toNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      price: _toInt(json['price']),
      onlinePrice: _toInt(json['price_online_shop']),
      priceAfter: _toNullableInt(json['price_after']),
      discount: (json['discount'] as num?)?.toDouble(),
      discountType: json['discount_type'],
      category: json['typeproducts'] ?? '',
      imageUrl: json['product_image'],
      isCustomize: json['is_customize'],
    );
  }
}

class ProductVariant {
  final String id;
  final String name;
  final String price;
  final String isActive;

  ProductVariant({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      isActive: json['is_active']?.toString() ?? '0',
    );
  }
}

class ProductVariantCategory {
  final String id;
  final String title;
  final int isRequired;
  final int maximumSelected;
  final List<ProductVariant> productVariants;

  ProductVariantCategory({
    required this.id,
    required this.title,
    required this.isRequired,
    required this.maximumSelected,
    required this.productVariants,
  });

  factory ProductVariantCategory.fromJson(Map<String, dynamic> json) {
    var list = json['product_variants'] as List? ?? [];
    List<ProductVariant> variantList = list
        .map((i) => ProductVariant.fromJson(i))
        .toList();

    return ProductVariantCategory(
      id: json['id']?.toString() ?? '',
      title: json['name'] ?? '',
      isRequired: int.tryParse(json['is_required'].toString()) ?? 0,
      maximumSelected: int.tryParse(json['maximum_selected'].toString()) ?? 0,
      productVariants: variantList,
    );
  }
}

class TransaksiMobilePage extends StatefulWidget {
  final String token;
  final String merchantId;
  final bool isEmbedded;

  TransaksiMobilePage({
    Key? key,
    required this.token,
    required this.merchantId,
    this.isEmbedded = false,
  }) : super(key: key);

  @override
  State<TransaksiMobilePage> createState() => _TransaksiMobilePageState();
}

class _TransaksiMobilePageState extends State<TransaksiMobilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _cart = [];
  final String _getVariantLink = getVariantLink;

  // Variant State
  Map<String, List<Map<String, dynamic>>> selectedVariantsByProduct = {};
  Map<String, String> variantErrorByCategory = {};
  List<ProductVariantCategory> lastVariantData = [];
  Map<String, GlobalKey> variantCategoryKeys = {};
  int tapTrue = 1; // 1 = Offline, 2 = Online

  // Sort State
  String textOrderBy = 'Nama Produk (A ke Z)';
  String textvalueOrderBy = 'upDownNama';

  final List<Map<String, String>> _sortOptions = [
    {'label': 'Nama Produk (A ke Z)', 'value': 'upDownNama'},
    {'label': 'Nama Produk (Z ke A)', 'value': 'downUpNama'},
    {'label': 'Produk Terbaru', 'value': 'downUpCreate'},
    {'label': 'Produk Terlama', 'value': 'upDownCreate'},
    {
      'label': 'Kategori (A ke Z)',
      'value': 'upDownHarga',
    }, // As per user mapping
    {'label': 'Kategori (Z ke A)', 'value': 'downUpHarga'},
  ];

  Map<String, dynamic>? _calculationData;
  String? _currentTransactionId;

  // Selected Customer State
  String? _selectedMemberName;
  String? _selectedMemberId;
  DiscountModel? _selectedDiscount;
  int _currentTabIndex = 0;

  // groupmerchant
  late final bool _isGroupMerchant;

  int _counterCart = 1;
  final TextEditingController _customProductNameController = TextEditingController();
  final TextEditingController _customProductPriceController = TextEditingController();
  final TextEditingController _conCatatanPreview = TextEditingController();
  late final WebViewController _webController;

  @override
  void initState() {
    super.initState();

    _isGroupMerchant = (typeAccount == 'Group_Merchant');

    _tabController = TabController(
      length: _isGroupMerchant ? 2 : 3,
      vsync: this,
    );

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));

    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    if (!_isGroupMerchant) {
      _searchController.addListener(_onSearchChanged);
      _fetchProducts();
    } else {
      _isLoading = false;
    }
  }

  bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == '1' || s == 'true' || s == 'yes';
    }
    return false;
  }

  // int _toIntSafe(dynamic v) {
  //   if (v == null) return 0;
  //   if (v is int) return v;
  //   return int.tryParse(v.toString()) ?? 0;
  // }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _fetchProducts() async {
    try {
      final apiUrl = Uri.parse(getProductUrl);
      final response = await http.post(
        apiUrl,
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "merchant_id": [widget.merchantId],
          "name": "",
          "is_active": true,
          "search": "",
          "order_by": textvalueOrderBy,
        }),
      );

      // print('Response status: ${response.statusCode}');
      print('Response body cuy: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00' && data['data'] != null) {
          final List<dynamic> productList = data['data'];
          setState(() {
            _products = productList.map((e) => Product.fromJson(e)).toList();
            _filteredProducts = _products;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<List<ProductVariantCategory>?> _fetchProductVariants(
    String productId,
  ) async {
    try {
      final body = {
        "deviceid": identifier,
        "order_by": "",
        "merchant_id": widget.merchantId,
        "product_id": productId,
      };

      final response = await http.post(
        Uri.parse(_getVariantLink),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['rc'] == '00') {
          List<ProductVariantCategory> variants = (jsonResponse['data'] as List)
              .map((e) => ProductVariantCategory.fromJson(e))
              .toList();
          return variants;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching variants: $e");
      return null;
    }
  }

  void _showPreviewCart(Product product) {
    // Reset state
    selectedVariantsByProduct.clear();
    variantErrorByCategory.clear();
    lastVariantData = [];
    variantCategoryKeys.clear();
    tapTrue = 1;

    int qty = 1;
    TextEditingController notesController = TextEditingController();

    bool showCustomPrice = false;

    final TextEditingController customPriceContoller = TextEditingController();
    int? customAmount;
    String? customPriceError;
    bool customEdited = false;

    final Map<String, int> variantCustomCache = {};

    void _setVariantCache(String vid, int price, int defPrice) {
      if (price == defPrice) {
        variantCustomCache.remove(vid);
      } else {
        variantCustomCache[vid] = price;
      }
    }

    int _baseAmount() {
      return (tapTrue == 2)
          ? product.onlinePrice
          : (product.priceAfter ?? product.price);
    }

    Map<String, dynamic>? _findSelectedDetail({
      required String pid,
      required String catId,
      required String vid,
    }) {
      final sels = selectedVariantsByProduct[pid];
      if (sels == null) return null;

      final catIndex = sels.indexWhere(
        (e) => e['variant_category_id'].toString() == catId,
      );
      if (catIndex == -1) return null;

      final details = List<Map<String, dynamic>>.from(
        (sels[catIndex]['variant_detail'] ?? []) as List,
      );

      final dIndex = details.indexWhere(
        (d) => d['variant_id'].toString() == vid,
      );
      if (dIndex == -1) return null;

      return details[dIndex];
    }

    void _syncCustomWithBaseIfNeeded() {
      // if (!isCustomize) return;
      if (!showCustomPrice) return;

      if (customEdited) return;

      final base = _baseAmount();
      customAmount = base;
      customPriceContoller.text = NumberFormat.decimalPattern(
        'id',
      ).format(base);
    }

    bool _isCustomizeNow() {
      final base = _baseAmount();
      return customEdited && customAmount != null && customAmount != base;
    }

    // Create Future ONCE
    final Future<List<ProductVariantCategory>?> variantFuture =
        _fetchProductVariants(product.id);
    final ScrollController scrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final int baseAmt = _baseAmount();
            final bool isCustomize = _isCustomizeNow();
            final int shownAmt = isCustomize
                ? (customAmount ?? baseAmt)
                : baseAmt;

            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: size8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(16),
                      children: [
                        // Product Info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: bnw200,
                                borderRadius: BorderRadius.circular(size8),
                              ),
                              child: Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    SvgPicture.asset('assets/logoProduct.svg'),
                              ),
                            ),
                            SizedBox(width: size12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: heading2(
                                      FontWeight.w600,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id',
                                          symbol: 'Rp ',
                                          decimalDigits: 0,
                                        ).format(shownAmt),
                                        style: heading3(
                                          FontWeight.w600,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      if (isCustomize) ...[
                                        SizedBox(width: size8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primary100,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            'Custom',
                                            style: heading4(
                                              FontWeight.w400,
                                              primary500,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  if (tapTrue == 1 &&
                                      product.discountType != null &&
                                      !isCustomize)
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'id',
                                        symbol: 'Rp ',
                                        decimalDigits: 0,
                                      ).format(product.price),
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        fontFamily: 'Outfit',
                                        color: bnw500,
                                        fontSize: sp14,
                                        height: 1.22,
                                      ),
                                    ),
                                  if (tapTrue == 1 &&
                                      product.discount != null &&
                                      product.discount! > 0)
                                    Text(
                                      product.discountType == 'price'
                                          ? NumberFormat.currency(
                                              locale: 'id',
                                              symbol: 'Rp. ',
                                              decimalDigits: 0,
                                            ).format(product.discount ?? 0)
                                          : '${product.discount ?? 0} %',
                                      style: heading4(
                                        FontWeight.w600,
                                        danger500,
                                        'Outfit',
                                      ),
                                    ),
                                  Text(
                                    product.category,
                                    style: heading3(
                                      FontWeight.w400,
                                      bnw500,
                                      'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline),
                                      color: primary500,
                                      onPressed: () {
                                        if (qty > 1) {
                                          setStateModal(() => qty--);
                                        }
                                      },
                                    ),
                                    Text(
                                      '$qty',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline),
                                      color: primary500,
                                      onPressed: () {
                                        setStateModal(() => qty++);
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                OutlinedButton(
                                  onPressed: () {
                                    setStateModal(() {
                                      showCustomPrice = !showCustomPrice;
                                      customPriceError = null;

                                      _syncCustomWithBaseIfNeeded();
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    side: BorderSide(color: primary500),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        size8,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    showCustomPrice ? 'Tutup' : 'Ubah Harga',
                                    style: heading4(
                                      FontWeight.w600,
                                      primary500,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 16),
                        Divider(),

                        // Price Type Toggle (Offline vs Online)
                        Text(
                          'Jenis Harga',
                          style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        SizedBox(height: size8),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setStateModal(() {
                                  tapTrue = 1;
                                  customPriceError = null;
                                  _syncCustomWithBaseIfNeeded();
                                }),
                                child: Container(
                                  padding: EdgeInsets.all(size12),
                                  decoration: BoxDecoration(
                                    color: tapTrue == 1 ? primary100 : bnw100,
                                    border: Border.all(
                                      color: tapTrue == 1 ? primary500 : bnw300,
                                    ),
                                    borderRadius: BorderRadius.circular(size8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Harga Offline',
                                      style: heading3(
                                        FontWeight.w600,
                                        tapTrue == 1 ? primary500 : bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            product.onlinePrice == 0
                                ? SizedBox()
                                : SizedBox(width: size12),
                            product.onlinePrice == 0
                                ? SizedBox()
                                : Expanded(
                                    child: InkWell(
                                      onTap: () => setStateModal(() {
                                        tapTrue = 2;
                                        customPriceError = null;
                                        _syncCustomWithBaseIfNeeded();
                                      }),
                                      child: Container(
                                        padding: EdgeInsets.all(size12),
                                        decoration: BoxDecoration(
                                          color: tapTrue == 2
                                              ? primary100
                                              : bnw100,
                                          border: Border.all(
                                            color: tapTrue == 2
                                                ? primary500
                                                : bnw300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            size8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Harga Online',
                                            style: TextStyle(
                                              color: tapTrue == 2
                                                  ? primary500
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),

                        if (showCustomPrice) ...[
                          SizedBox(height: 16),
                          Text(
                            'Harga',
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: customPriceContoller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              services.FilteringTextInputFormatter.digitsOnly,
                              RupiahInputFormatter(),
                            ],
                            decoration: InputDecoration(
                              prefixText: 'Rp. ',
                              hintText: 'Masukkan Harga',
                              errorText: customPriceError,
                              border: UnderlineInputBorder(),
                            ),
                            onChanged: (v) {
                              final digits = v.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              );
                              setStateModal(() {
                                customEdited = true;
                                customPriceError = null;
                                customAmount = digits.isEmpty
                                    ? null
                                    : int.tryParse(digits);
                              });
                            },
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setStateModal(() {
                                  customEdited = false;
                                  customPriceError = null;
                                  // customAmount = null;
                                  _syncCustomWithBaseIfNeeded();
                                });
                              },
                              child: Text(
                                'Reset ke harga normal',
                                style: heading4(
                                  FontWeight.w400,
                                  primary500,
                                  'Outfit',
                                ),
                              ),
                            ),
                          ),
                        ],

                        SizedBox(height: 16),

                        // Variants FutureBuilder
                        FutureBuilder<List<ProductVariantCategory>?>(
                          future: variantFuture,
                          // _fetchProductVariants(product.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(size8),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return SizedBox();
                            }

                            final categories = snapshot.data!;
                            lastVariantData = categories;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: categories.map((category) {
                                final String catId = category.id;

                                variantCategoryKeys[catId] ??= GlobalKey();

                                // Validation error if any
                                final error = variantErrorByCategory[catId];

                                return Column(
                                  key: variantCategoryKeys[catId],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: size12),
                                    Text(
                                      category.title,
                                      style: heading4(
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                    Text(
                                      category.isRequired == 1
                                          ? "Wajib dipilih - Maks pilih ${category.maximumSelected}"
                                          : "Opsional - Maks pilih ${category.maximumSelected}",
                                      style: body2(
                                        FontWeight.w600,
                                        category.isRequired == 1
                                            ? danger500
                                            : bnw400,
                                        'Outfit',
                                      ),
                                    ),

                                    if (error != null)
                                      Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Text(
                                          error,
                                          style: TextStyle(
                                            color: danger500,
                                            fontSize: size12,
                                          ),
                                        ),
                                      ),

                                    SizedBox(height: size8),

                                    ...category.productVariants.map((variant) {
                                      final productId = product.id.toString();
                                      final currentSelected =
                                          selectedVariantsByProduct[productId] ??
                                          [];

                                      // Check if this variant is selected
                                      final isSelected = currentSelected.any((
                                        e,
                                      ) {
                                        final ids = (e['variant_id'] as List)
                                            .map((id) => id.toString())
                                            .toList();
                                        return ids.contains(
                                          variant.id.toString(),
                                        );
                                      });

                                      final pid = product.id.toString();
                                      final catIdStr = catId.toString();
                                      final vid = variant.id.toString();

                                      final detail = _findSelectedDetail(
                                        pid: pid,
                                        catId: catIdStr,
                                        vid: vid,
                                      );

                                      final int defaultVPrice =
                                          (double.tryParse(variant.price) ?? 0)
                                              .toInt();

                                      final int cachedPrice =
                                          variantCustomCache[vid] ??
                                          defaultVPrice;

                                      final int shownVPrice = detail != null
                                          ? _toIntSafe(detail['variant_price'])
                                          : cachedPrice;

                                      final bool isVCustomize = detail != null
                                          ? _toBoolSafe(
                                              detail['is_variant_customize'],
                                            )
                                          : variantCustomCache.containsKey(vid);

                                      return CheckboxListTile(
                                        activeColor: primary500,
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                variant.name,
                                                style: heading3(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  FormatCurrency.convertToIdr(
                                                    shownVPrice.toDouble(),
                                                  ),
                                                  style: heading4(
                                                    FontWeight.w400,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                                if (isVCustomize) ...[
                                                  SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: primary100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Custom',
                                                      style: heading4(
                                                        FontWeight.w400,
                                                        primary500,
                                                        'Outfit',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                SizedBox(width: 8),
                                                OutlinedButton(
                                                  onPressed: () {
                                                    if (!isSelected) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Pilih variannya dulu',
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    final pid = product.id
                                                        .toString();
                                                    final catIdStr = catId
                                                        .toString();

                                                    final sels =
                                                        selectedVariantsByProduct[pid] ??
                                                        [];
                                                    final catIndex = sels
                                                        .indexWhere(
                                                          (e) =>
                                                              e['variant_category_id']
                                                                  .toString() ==
                                                              catIdStr,
                                                        );
                                                    if (catIndex == -1) return;

                                                    final details =
                                                        List<
                                                          Map<String, dynamic>
                                                        >.from(
                                                          sels[catIndex]['variant_detail']
                                                              as List,
                                                        );
                                                    final dIndex = details
                                                        .indexWhere(
                                                          (d) =>
                                                              d['variant_id']
                                                                  .toString() ==
                                                              variant.id
                                                                  .toString(),
                                                        );
                                                    if (dIndex == -1) return;

                                                    final int
                                                    defPrice = _toIntSafe(
                                                      details[dIndex]['variant_price_default'],
                                                    );
                                                    int
                                                    currentPrice = _toIntSafe(
                                                      details[dIndex]['variant_price'],
                                                    );

                                                    final ctrl =
                                                        TextEditingController(
                                                          text:
                                                              NumberFormat.decimalPattern(
                                                                'id',
                                                              ).format(
                                                                currentPrice,
                                                              ),
                                                        );

                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      builder: (context) {
                                                        return StatefulBuilder(
                                                          builder: (context, setM) {
                                                            return Container(
                                                              padding: EdgeInsets.only(
                                                                left: 16,
                                                                right: 16,
                                                                top: 16,
                                                                bottom:
                                                                    MediaQuery.of(
                                                                          context,
                                                                        )
                                                                        .viewInsets
                                                                        .bottom +
                                                                    16,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: bnw100,
                                                                borderRadius:
                                                                    BorderRadius.vertical(
                                                                      top:
                                                                          Radius.circular(
                                                                            16,
                                                                          ),
                                                                    ),
                                                              ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    'Ubah Harga Varian',
                                                                    style: heading2(
                                                                      FontWeight
                                                                          .w700,
                                                                      bnw900,
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 8,
                                                                  ),
                                                                  Text(
                                                                    variant
                                                                        .name,
                                                                    style: heading3(
                                                                      FontWeight
                                                                          .w400,
                                                                      bnw600,
                                                                      'Outfit',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 12,
                                                                  ),
                                                                  TextField(
                                                                    controller:
                                                                        ctrl,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    inputFormatters: [
                                                                      services
                                                                          .FilteringTextInputFormatter
                                                                          .digitsOnly,
                                                                      RupiahInputFormatter(),
                                                                    ],
                                                                    decoration: InputDecoration(
                                                                      prefixText:
                                                                          'Rp. ',
                                                                      border:
                                                                          UnderlineInputBorder(),
                                                                    ),
                                                                    onChanged: (value) {
                                                                      final digits = value.replaceAll(
                                                                        RegExp(
                                                                          r'[^0-9]',
                                                                        ),
                                                                        '',
                                                                      );
                                                                      setM(() {
                                                                        currentPrice =
                                                                            digits.isEmpty
                                                                            ? 0
                                                                            : (int.tryParse(
                                                                                    digits,
                                                                                  ) ??
                                                                                  0);
                                                                      });
                                                                    },
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerRight,
                                                                    child: TextButton(
                                                                      onPressed: () {
                                                                        setM(() {
                                                                          currentPrice =
                                                                              defPrice;
                                                                          _setVariantCache(
                                                                            variant.id.toString(),
                                                                            defPrice,
                                                                            defPrice,
                                                                          );
                                                                          ctrl.text =
                                                                              NumberFormat.decimalPattern(
                                                                                'id',
                                                                              ).format(
                                                                                defPrice,
                                                                              );
                                                                        });
                                                                      },
                                                                      child: Text(
                                                                        'Reset ke harga normal',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 12,
                                                                  ),
                                                                  SizedBox(
                                                                    width: double
                                                                        .infinity,
                                                                    child: ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            primary500,
                                                                      ),
                                                                      onPressed: () {
                                                                        details[dIndex]['variant_price'] =
                                                                            currentPrice;
                                                                        details[dIndex]['is_variant_customize'] =
                                                                            (currentPrice !=
                                                                            defPrice);

                                                                        _setVariantCache(
                                                                          variant
                                                                              .id
                                                                              .toString(),
                                                                          currentPrice,
                                                                          defPrice,
                                                                        );

                                                                        setStateModal(() {
                                                                          sels[catIndex]['variant_detail'] =
                                                                              details;
                                                                          selectedVariantsByProduct[pid] =
                                                                              sels;
                                                                        });
                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                      },
                                                                      child: Text(
                                                                        'Simpan',
                                                                        style: heading3(
                                                                          FontWeight
                                                                              .w600,
                                                                          bnw100,
                                                                          'Outfit',
                                                                        ),
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
                                                  },
                                                  child: Text('Ubah Harga'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        value: isSelected,
                                        contentPadding: EdgeInsets.zero,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        onChanged: (bool? val) {
                                          setStateModal(() {
                                            selectedVariantsByProduct[productId] ??=
                                                [];
                                            List<Map<String, dynamic>>
                                            productVariants =
                                                selectedVariantsByProduct[productId]!;

                                            // Find entry for this category
                                            int catIndex = productVariants
                                                .indexWhere(
                                                  (e) =>
                                                      e['variant_category_id'] ==
                                                      catId,
                                                );

                                            List<String> currentIds = [];
                                            List<Map<String, dynamic>>
                                            currentDetails = [];

                                            if (catIndex != -1) {
                                              currentIds = List<String>.from(
                                                productVariants[catIndex]['variant_id'],
                                              );
                                              currentDetails =
                                                  List<
                                                    Map<String, dynamic>
                                                  >.from(
                                                    productVariants[catIndex]['variant_detail'],
                                                  );
                                            }

                                            if (val == true) {
                                              // Logic for selection

                                              // Radio logic (max 1)
                                              if (category.maximumSelected ==
                                                  1) {
                                                currentIds.clear();
                                                currentDetails.clear();
                                              }
                                              // Limit logic
                                              else if (category
                                                          .maximumSelected >
                                                      1 &&
                                                  currentIds.length >=
                                                      category
                                                          .maximumSelected) {
                                                currentIds.removeAt(
                                                  0,
                                                ); // Remove oldest
                                                currentDetails.removeAt(0);
                                              }

                                              final int defaultVPrice =
                                                  (double.tryParse(
                                                            variant.price,
                                                          ) ??
                                                          0)
                                                      .toInt();
                                              final String vid = variant.id
                                                  .toString();
                                              final int usedPrice =
                                                  variantCustomCache[vid] ??
                                                  defaultVPrice;

                                              // Add new
                                              currentIds.add(variant.id);
                                              currentDetails.add({
                                                "variant_id": variant.id,
                                                "variant_name": variant.name,
                                                "variant_price_default":
                                                    defaultVPrice,
                                                "variant_price": usedPrice,
                                                "is_variant_customize":
                                                    usedPrice != defaultVPrice,
                                                "is_online": tapTrue == 2,
                                              });
                                            } else {
                                              // Uncheck
                                              int removeIdx = currentIds
                                                  .indexOf(variant.id);
                                              if (removeIdx != -1) {
                                                currentIds.removeAt(removeIdx);
                                                currentDetails.removeAt(
                                                  removeIdx,
                                                );
                                              }
                                            }

                                            // Update Map
                                            if (catIndex != -1) {
                                              if (currentIds.isEmpty) {
                                                productVariants.removeAt(
                                                  catIndex,
                                                );
                                              } else {
                                                productVariants[catIndex]['variant_id'] =
                                                    currentIds;
                                                productVariants[catIndex]['variant_detail'] =
                                                    currentDetails;
                                              }
                                            } else if (currentIds.isNotEmpty) {
                                              productVariants.add({
                                                "variant_category_id": catId,
                                                "variant_id": currentIds,
                                                "variant_detail":
                                                    currentDetails,
                                              });
                                            }

                                            // Remove error if any selection exists
                                            if (currentIds.isNotEmpty) {
                                              variantErrorByCategory.remove(
                                                catId,
                                              );
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ],
                                );
                              }).toList(),
                            );
                          },
                        ),

                        SizedBox(height: 16),
                        Text(
                          "Catatan :",
                          style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                        TextField(
                          controller: notesController,
                          decoration: InputDecoration(
                            hintText: 'Contoh: Kurangi es, cabe dipisah',
                            border: UnderlineInputBorder(),
                            hintStyle: heading3(
                              FontWeight.w600,
                              bnw400,
                              'Outfit',
                            ),
                          ),
                        ),
                        SizedBox(height: 100), // Spacing for button
                      ],
                    ),
                  ),

                  // Buttons
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: primary500),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(size8),
                              ),
                            ),
                            child: Text(
                              'Batalkan',
                              style: heading3(
                                FontWeight.w600,
                                primary500,
                                'Outfit',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Validation
                              bool valid = true;
                              for (var cat in lastVariantData) {
                                if (cat.isRequired == 1) {
                                  final pid = product.id.toString();
                                  final sels =
                                      selectedVariantsByProduct[pid] ?? [];
                                  final catSel = sels.firstWhere(
                                    (e) => e['variant_category_id'] == cat.id,
                                    orElse: () => {},
                                  );

                                  if (catSel.isEmpty ||
                                      (catSel['variant_id'] as List).isEmpty) {
                                    setStateModal(() {
                                      variantErrorByCategory[cat.id] =
                                          'Wajib dipilih';
                                    });

                                    // Auto Scroll to error
                                    // final key = variantCategoryKeys[cat.id];
                                    // if (key?.currentContext != null) {
                                    //   Scrollable.ensureVisible(
                                    //     key!.currentContext!,
                                    //     duration: Duration(milliseconds: 300),
                                    //     curve: Curves.easeOut,
                                    //   );
                                    // }

                                    valid = false;

                                    // Break to focus on first error? or show all.
                                    // If we want scroll to *first*, we should track it.
                                    // Current loop marks all. Scroll to the last one encountered or logic needs adjustment.
                                    // Better to find FIRST invalid and scroll, but mark ALL.
                                  }
                                }
                              }

                              if (!valid) {
                                // Find first error key
                                for (var cat in lastVariantData) {
                                  if (variantErrorByCategory.containsKey(
                                    cat.id,
                                  )) {
                                    final key = variantCategoryKeys[cat.id];
                                    if (key?.currentContext != null) {
                                      Scrollable.ensureVisible(
                                        key!.currentContext!,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                      break; // Scroll to first
                                    }
                                  }
                                }
                                return;
                              }

                              final bool isCustomizeFinal = _isCustomizeNow();

                              if (isCustomizeFinal) {
                                final amt = customAmount ?? 0;
                                if (amt <= 0) {
                                  setStateModal(() {
                                    customPriceError = 'Harga wajib diisi';
                                  });
                                  return;
                                }
                              }
                              // if (isCustomize) {
                              //   final amt = customAmount ?? 0;
                              //   if (amt <= 0) {
                              //     setStateModal(() {
                              //       customPriceError =
                              //           'Harga custom wajib diisi';
                              //     });
                              //     return;
                              //   }
                              // }

                              // Add to Cart
                              _addToCartWithVariants(
                                product,
                                qty,
                                notesController.text,
                                tapTrue == 2,
                                customAmount: isCustomizeFinal
                                    ? customAmount
                                    : null,
                                isCustomize: isCustomizeFinal,
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary500,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(size8),
                              ),
                            ),
                            child: Text(
                              'Tambah Ke Keranjang',
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
                  SizedBox(height: size12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addToCartWithVariants(
    Product product,
    int quantity,
    String notes,
    bool isOnline, {
    int? customAmount,
    bool isCustomize = false,
  }) {
    final productId = product.id.toString();
    final variantList = selectedVariantsByProduct[productId] ?? [];
    void _showPreviewCart(Product product) {
      // Reset state
      selectedVariantsByProduct.clear();
      variantErrorByCategory.clear();
      lastVariantData = [];
      variantCategoryKeys.clear();
      tapTrue = 1;

      int qty = 1;
      TextEditingController notesController = TextEditingController();

      bool showCustomPrice = false;

      final TextEditingController customPriceContoller =
          TextEditingController();
      int? customAmount;
      String? customPriceError;
      bool customEdited = false;

      int _baseAmount() {
        return (tapTrue == 2)
            ? product.onlinePrice
            : (product.priceAfter ?? product.price);
      }

      Map<String, dynamic>? _findSelectedDetail({
        required String pid,
        required String catId,
        required String vid,
      }) {
        final sels = selectedVariantsByProduct[pid];
        if (sels == null) return null;

        final catIndex = sels.indexWhere(
          (e) => e['variant_category_id'].toString() == catId,
        );
        if (catIndex == -1) return null;

        final details = List<Map<String, dynamic>>.from(
          (sels[catIndex]['variant_detail'] ?? []) as List,
        );

        final dIndex = details.indexWhere(
          (d) => d['variant_id'].toString() == vid,
        );
        if (dIndex == -1) return null;

        return details[dIndex];
      }

      void _syncCustomWithBaseIfNeeded() {
        // if (!isCustomize) return;
        if (!showCustomPrice) return;

        if (customEdited) return;

        final base = _baseAmount();
        customAmount = base;
        customPriceContoller.text = NumberFormat.decimalPattern(
          'id',
        ).format(base);
      }

      bool _isCustomizeNow() {
        final base = _baseAmount();
        return customEdited && customAmount != null && customAmount != base;
      }

      // Create Future ONCE
      final Future<List<ProductVariantCategory>?> variantFuture =
          _fetchProductVariants(product.id);
      final ScrollController scrollController = ScrollController();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setStateModal) {
              final int baseAmt = _baseAmount();
              final bool isCustomize = _isCustomizeNow();
              final int shownAmt = isCustomize
                  ? (customAmount ?? baseAmt)
                  : baseAmt;

              return Container(
                height: MediaQuery.of(context).size.height * 0.9,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: bnw100,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: size8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.all(16),
                        children: [
                          // Product Info
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: bnw200,
                                  borderRadius: BorderRadius.circular(size8),
                                ),
                                child: Image.network(
                                  product.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      SvgPicture.asset(
                                        'assets/logoProduct.svg',
                                      ),
                                ),
                              ),
                              SizedBox(width: size12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: heading2(
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),

                                    Row(
                                      children: [
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp ',
                                            decimalDigits: 0,
                                          ).format(shownAmt),
                                          style: heading3(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        if (isCustomize) ...[
                                          SizedBox(width: size8),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primary100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Custom',
                                              style: heading4(
                                                FontWeight.w400,
                                                primary500,
                                                'Outfit',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),

                                    if (tapTrue == 1 &&
                                        product.discountType != null &&
                                        !isCustomize)
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id',
                                          symbol: 'Rp ',
                                          decimalDigits: 0,
                                        ).format(product.price),
                                        style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontFamily: 'Outfit',
                                          color: bnw500,
                                          fontSize: sp14,
                                          height: 1.22,
                                        ),
                                      ),
                                    if (tapTrue == 1 &&
                                        product.discount != null &&
                                        product.discount! > 0)
                                      Text(
                                        product.discountType == 'price'
                                            ? NumberFormat.currency(
                                                locale: 'id',
                                                symbol: 'Rp. ',
                                                decimalDigits: 0,
                                              ).format(product.discount ?? 0)
                                            : '${product.discount ?? 0} %',
                                        style: heading4(
                                          FontWeight.w600,
                                          danger500,
                                          'Outfit',
                                        ),
                                      ),
                                    Text(
                                      product.category,
                                      style: heading3(
                                        FontWeight.w400,
                                        bnw500,
                                        'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline),
                                        color: primary500,
                                        onPressed: () {
                                          if (qty > 1) {
                                            setStateModal(() => qty--);
                                          }
                                        },
                                      ),
                                      Text(
                                        '$qty',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline),
                                        color: primary500,
                                        onPressed: () {
                                          setStateModal(() => qty++);
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  OutlinedButton(
                                    onPressed: () {
                                      setStateModal(() {
                                        showCustomPrice = !showCustomPrice;
                                        customPriceError = null;

                                        _syncCustomWithBaseIfNeeded();
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      side: BorderSide(color: primary500),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          size8,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      showCustomPrice ? 'Tutup' : 'Ubah Harga',
                                      style: heading4(
                                        FontWeight.w600,
                                        primary500,
                                        'Outfit',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 16),
                          Divider(),

                          // Price Type Toggle (Offline vs Online)
                          Text(
                            'Jenis Harga',
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: size8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setStateModal(() {
                                    tapTrue = 1;
                                    customPriceError = null;
                                    _syncCustomWithBaseIfNeeded();
                                  }),
                                  child: Container(
                                    padding: EdgeInsets.all(size12),
                                    decoration: BoxDecoration(
                                      color: tapTrue == 1 ? primary100 : bnw100,
                                      border: Border.all(
                                        color: tapTrue == 1
                                            ? primary500
                                            : bnw300,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        size8,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Harga Offline',
                                        style: heading3(
                                          FontWeight.w600,
                                          tapTrue == 1 ? primary500 : bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              product.onlinePrice == 0
                                  ? SizedBox()
                                  : SizedBox(width: size12),
                              product.onlinePrice == 0
                                  ? SizedBox()
                                  : Expanded(
                                      child: InkWell(
                                        onTap: () => setStateModal(() {
                                          tapTrue = 2;
                                          customPriceError = null;
                                          _syncCustomWithBaseIfNeeded();
                                        }),
                                        child: Container(
                                          padding: EdgeInsets.all(size12),
                                          decoration: BoxDecoration(
                                            color: tapTrue == 2
                                                ? primary100
                                                : bnw100,
                                            border: Border.all(
                                              color: tapTrue == 2
                                                  ? primary500
                                                  : bnw300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              size8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Harga Online',
                                              style: TextStyle(
                                                color: tapTrue == 2
                                                    ? primary500
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),

                          if (showCustomPrice) ...[
                            SizedBox(height: 16),
                            Text(
                              'Harga',
                              style: heading3(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: customPriceContoller,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                services.FilteringTextInputFormatter.digitsOnly,
                                RupiahInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                prefixText: 'Rp. ',
                                hintText: 'Masukkan Harga',
                                errorText: customPriceError,
                                border: UnderlineInputBorder(),
                              ),
                              onChanged: (v) {
                                final digits = v.replaceAll(
                                  RegExp(r'[^0-9]'),
                                  '',
                                );
                                setStateModal(() {
                                  customEdited = true;
                                  customPriceError = null;
                                  customAmount = digits.isEmpty
                                      ? null
                                      : int.tryParse(digits);
                                });
                              },
                            ),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  setStateModal(() {
                                    customEdited = false;
                                    customPriceError = null;
                                    // customAmount = null;
                                    _syncCustomWithBaseIfNeeded();
                                  });
                                },
                                child: Text(
                                  'Reset ke harga normal',
                                  style: heading4(
                                    FontWeight.w400,
                                    primary500,
                                    'Outfit',
                                  ),
                                ),
                              ),
                            ),
                          ],

                          SizedBox(height: 16),

                          // Variants FutureBuilder
                          FutureBuilder<List<ProductVariantCategory>?>(
                            future: variantFuture,
                            // _fetchProductVariants(product.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(size8),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return SizedBox();
                              }

                              final categories = snapshot.data!;
                              lastVariantData = categories;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: categories.map((category) {
                                  final String catId = category.id;

                                  variantCategoryKeys[catId] ??= GlobalKey();

                                  // Validation error if any
                                  final error = variantErrorByCategory[catId];

                                  return Column(
                                    key: variantCategoryKeys[catId],
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: size12),
                                      Text(
                                        category.title,
                                        style: heading4(
                                          FontWeight.w600,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      Text(
                                        category.isRequired == 1
                                            ? "Wajib dipilih - Maks pilih ${category.maximumSelected}"
                                            : "Opsional - Maks pilih ${category.maximumSelected}",
                                        style: body2(
                                          FontWeight.w600,
                                          category.isRequired == 1
                                              ? danger500
                                              : bnw400,
                                          'Outfit',
                                        ),
                                      ),

                                      if (error != null)
                                        Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Text(
                                            error,
                                            style: TextStyle(
                                              color: danger500,
                                              fontSize: size12,
                                            ),
                                          ),
                                        ),

                                      SizedBox(height: size8),

                                      ...category.productVariants.map((
                                        variant,
                                      ) {
                                        final productId = product.id.toString();
                                        final currentSelected =
                                            selectedVariantsByProduct[productId] ??
                                            [];

                                        // Check if this variant is selected
                                        final isSelected = currentSelected.any((
                                          e,
                                        ) {
                                          final ids = (e['variant_id'] as List)
                                              .map((id) => id.toString())
                                              .toList();
                                          return ids.contains(
                                            variant.id.toString(),
                                          );
                                        });

                                        final pid = product.id.toString();
                                        final catIdStr = catId.toString();
                                        final vid = variant.id.toString();

                                        final detail = _findSelectedDetail(
                                          pid: pid,
                                          catId: catIdStr,
                                          vid: vid,
                                        );

                                        final int defaultVPrice =
                                            (double.tryParse(variant.price) ??
                                                    0)
                                                .toInt();
                                        final int shownVPrice = detail == null
                                            ? defaultVPrice
                                            : _toIntSafe(
                                                detail['variant_price'],
                                                def: defaultVPrice,
                                              );

                                        final bool isVCustomize =
                                            detail != null &&
                                            _toBoolSafe(
                                              detail['is_variant_customize'],
                                            );

                                        return CheckboxListTile(
                                          activeColor: primary500,
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  variant.name,
                                                  style: heading3(
                                                    FontWeight.w400,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    FormatCurrency.convertToIdr(
                                                      shownVPrice.toDouble(),
                                                    ),
                                                    style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit',
                                                    ),
                                                  ),
                                                  if (isVCustomize) ...[
                                                    SizedBox(width: 6),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: primary100,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        'Custom',
                                                        style: heading4(
                                                          FontWeight.w400,
                                                          primary500,
                                                          'Outfit',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  SizedBox(width: 8),
                                                  OutlinedButton(
                                                    onPressed: () {
                                                      if (!isSelected) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Pilih variannya dulu',
                                                            ),
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      final pid = product.id
                                                          .toString();
                                                      final catIdStr = catId
                                                          .toString();

                                                      final sels =
                                                          selectedVariantsByProduct[pid] ??
                                                          [];
                                                      final catIndex = sels
                                                          .indexWhere(
                                                            (e) =>
                                                                e['variant_category_id']
                                                                    .toString() ==
                                                                catIdStr,
                                                          );
                                                      if (catIndex == -1)
                                                        return;

                                                      final details =
                                                          List<
                                                            Map<String, dynamic>
                                                          >.from(
                                                            sels[catIndex]['variant_detail']
                                                                as List,
                                                          );
                                                      final dIndex = details
                                                          .indexWhere(
                                                            (d) =>
                                                                d['variant_id']
                                                                    .toString() ==
                                                                variant.id
                                                                    .toString(),
                                                          );
                                                      if (dIndex == -1) return;

                                                      final int
                                                      defPrice = _toIntSafe(
                                                        details[dIndex]['variant_price_default'],
                                                      );
                                                      int
                                                      currentPrice = _toIntSafe(
                                                        details[dIndex]['variant_price'],
                                                      );

                                                      final ctrl =
                                                          TextEditingController(
                                                            text:
                                                                NumberFormat.decimalPattern(
                                                                  'id',
                                                                ).format(
                                                                  currentPrice,
                                                                ),
                                                          );

                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        builder: (context) {
                                                          return StatefulBuilder(
                                                            builder: (context, setM) {
                                                              return Container(
                                                                padding: EdgeInsets.only(
                                                                  left: 16,
                                                                  right: 16,
                                                                  top: 16,
                                                                  bottom:
                                                                      MediaQuery.of(
                                                                        context,
                                                                      ).viewInsets.bottom +
                                                                      16,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  color: bnw100,
                                                                  borderRadius:
                                                                      BorderRadius.vertical(
                                                                        top: Radius.circular(
                                                                          16,
                                                                        ),
                                                                      ),
                                                                ),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Ubah Harga Varian',
                                                                      style: heading2(
                                                                        FontWeight
                                                                            .w700,
                                                                        bnw900,
                                                                        'Outfit',
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Text(
                                                                      variant
                                                                          .name,
                                                                      style: heading3(
                                                                        FontWeight
                                                                            .w400,
                                                                        bnw600,
                                                                        'Outfit',
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          12,
                                                                    ),
                                                                    TextField(
                                                                      controller:
                                                                          ctrl,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      inputFormatters: [
                                                                        services
                                                                            .FilteringTextInputFormatter
                                                                            .digitsOnly,
                                                                        RupiahInputFormatter(),
                                                                      ],
                                                                      decoration: InputDecoration(
                                                                        prefixText:
                                                                            'Rp. ',
                                                                        border:
                                                                            UnderlineInputBorder(),
                                                                      ),
                                                                      onChanged: (value) {
                                                                        final digits = value.replaceAll(
                                                                          RegExp(
                                                                            r'[^0-9]',
                                                                          ),
                                                                          '',
                                                                        );
                                                                        setM(() {
                                                                          currentPrice =
                                                                              digits.isEmpty
                                                                              ? 0
                                                                              : (int.tryParse(
                                                                                      digits,
                                                                                    ) ??
                                                                                    0);
                                                                        });
                                                                      },
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child: TextButton(
                                                                        onPressed: () {
                                                                          setM(() {
                                                                            currentPrice =
                                                                                defPrice;

                                                                            ctrl.text =
                                                                                NumberFormat.decimalPattern(
                                                                                  'id',
                                                                                ).format(
                                                                                  defPrice,
                                                                                );
                                                                          });
                                                                        },
                                                                        child: Text(
                                                                          'Reset ke harga normal',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          12,
                                                                    ),
                                                                    SizedBox(
                                                                      width: double
                                                                          .infinity,
                                                                      child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor:
                                                                              primary500,
                                                                        ),
                                                                        onPressed: () {
                                                                          details[dIndex]['variant_price'] =
                                                                              currentPrice;
                                                                          details[dIndex]['is_variant_customize'] =
                                                                              (currentPrice !=
                                                                              defPrice);

                                                                          setStateModal(() {
                                                                            sels[catIndex]['variant_detail'] =
                                                                                details;
                                                                            selectedVariantsByProduct[pid] =
                                                                                sels;
                                                                          });
                                                                          Navigator.pop(
                                                                            context,
                                                                          );
                                                                        },
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
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text('Ubah Harga'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          value: isSelected,
                                          contentPadding: EdgeInsets.zero,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          onChanged: (bool? val) {
                                            setStateModal(() {
                                              selectedVariantsByProduct[productId] ??=
                                                  [];
                                              List<Map<String, dynamic>>
                                              productVariants =
                                                  selectedVariantsByProduct[productId]!;

                                              // Find entry for this category
                                              int catIndex = productVariants
                                                  .indexWhere(
                                                    (e) =>
                                                        e['variant_category_id'] ==
                                                        catId,
                                                  );

                                              List<String> currentIds = [];
                                              List<Map<String, dynamic>>
                                              currentDetails = [];

                                              if (catIndex != -1) {
                                                currentIds = List<String>.from(
                                                  productVariants[catIndex]['variant_id'],
                                                );
                                                currentDetails =
                                                    List<
                                                      Map<String, dynamic>
                                                    >.from(
                                                      productVariants[catIndex]['variant_detail'],
                                                    );
                                              }

                                              if (val == true) {
                                                // Logic for selection

                                                // Radio logic (max 1)
                                                if (category.maximumSelected ==
                                                    1) {
                                                  currentIds.clear();
                                                  currentDetails.clear();
                                                }
                                                // Limit logic
                                                else if (category
                                                            .maximumSelected >
                                                        1 &&
                                                    currentIds.length >=
                                                        category
                                                            .maximumSelected) {
                                                  currentIds.removeAt(
                                                    0,
                                                  ); // Remove oldest
                                                  currentDetails.removeAt(0);
                                                }

                                                final int defaultVPrice =
                                                    (double.tryParse(
                                                              variant.price,
                                                            ) ??
                                                            0)
                                                        .toInt();

                                                // Add new
                                                currentIds.add(variant.id);
                                                currentDetails.add({
                                                  "variant_id": variant.id,
                                                  "variant_name": variant.name,
                                                  "variant_price_default":
                                                      defaultVPrice,
                                                  "variant_price":
                                                      defaultVPrice,
                                                  "is_variant_customize": false,
                                                  "is_online": tapTrue == 2,
                                                });
                                              } else {
                                                // Uncheck
                                                int removeIdx = currentIds
                                                    .indexOf(variant.id);
                                                if (removeIdx != -1) {
                                                  currentIds.removeAt(
                                                    removeIdx,
                                                  );
                                                  currentDetails.removeAt(
                                                    removeIdx,
                                                  );
                                                }
                                              }

                                              // Update Map
                                              if (catIndex != -1) {
                                                if (currentIds.isEmpty) {
                                                  productVariants.removeAt(
                                                    catIndex,
                                                  );
                                                } else {
                                                  productVariants[catIndex]['variant_id'] =
                                                      currentIds;
                                                  productVariants[catIndex]['variant_detail'] =
                                                      currentDetails;
                                                }
                                              } else if (currentIds
                                                  .isNotEmpty) {
                                                productVariants.add({
                                                  "variant_category_id": catId,
                                                  "variant_id": currentIds,
                                                  "variant_detail":
                                                      currentDetails,
                                                });
                                              }

                                              // Remove error if any selection exists
                                              if (currentIds.isNotEmpty) {
                                                variantErrorByCategory.remove(
                                                  catId,
                                                );
                                              }
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          SizedBox(height: 16),
                          Text(
                            "Catatan :",
                            style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          TextField(
                            controller: notesController,
                            decoration: InputDecoration(
                              hintText: 'Contoh: Kurangi es, cabe dipisah',
                              border: UnderlineInputBorder(),
                              hintStyle: heading3(
                                FontWeight.w600,
                                bnw400,
                                'Outfit',
                              ),
                            ),
                          ),
                          SizedBox(height: 100), // Spacing for button
                        ],
                      ),
                    ),

                    // Buttons
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: primary500),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(size8),
                                ),
                              ),
                              child: Text(
                                'Batalkan',
                                style: heading3(
                                  FontWeight.w600,
                                  primary500,
                                  'Outfit',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: size12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Validation
                                bool valid = true;
                                for (var cat in lastVariantData) {
                                  if (cat.isRequired == 1) {
                                    final pid = product.id.toString();
                                    final sels =
                                        selectedVariantsByProduct[pid] ?? [];
                                    final catSel = sels.firstWhere(
                                      (e) => e['variant_category_id'] == cat.id,
                                      orElse: () => {},
                                    );

                                    if (catSel.isEmpty ||
                                        (catSel['variant_id'] as List)
                                            .isEmpty) {
                                      setStateModal(() {
                                        variantErrorByCategory[cat.id] =
                                            'Wajib dipilih';
                                      });

                                      // Auto Scroll to error
                                      // final key = variantCategoryKeys[cat.id];
                                      // if (key?.currentContext != null) {
                                      //   Scrollable.ensureVisible(
                                      //     key!.currentContext!,
                                      //     duration: Duration(milliseconds: 300),
                                      //     curve: Curves.easeOut,
                                      //   );
                                      // }

                                      valid = false;

                                      // Break to focus on first error? or show all.
                                      // If we want scroll to *first*, we should track it.
                                      // Current loop marks all. Scroll to the last one encountered or logic needs adjustment.
                                      // Better to find FIRST invalid and scroll, but mark ALL.
                                    }
                                  }
                                }

                                if (!valid) {
                                  // Find first error key
                                  for (var cat in lastVariantData) {
                                    if (variantErrorByCategory.containsKey(
                                      cat.id,
                                    )) {
                                      final key = variantCategoryKeys[cat.id];
                                      if (key?.currentContext != null) {
                                        Scrollable.ensureVisible(
                                          key!.currentContext!,
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeOut,
                                        );
                                        break; // Scroll to first
                                      }
                                    }
                                  }
                                  return;
                                }

                                final bool isCustomizeFinal = _isCustomizeNow();

                                if (isCustomizeFinal) {
                                  final amt = customAmount ?? 0;
                                  if (amt <= 0) {
                                    setStateModal(() {
                                      customPriceError = 'Harga wajib diisi';
                                    });
                                    return;
                                  }
                                }
                                // if (isCustomize) {
                                //   final amt = customAmount ?? 0;
                                //   if (amt <= 0) {
                                //     setStateModal(() {
                                //       customPriceError =
                                //           'Harga custom wajib diisi';
                                //     });
                                //     return;
                                //   }
                                // }

                                // Add to Cart
                                _addToCartWithVariants(
                                  product,
                                  qty,
                                  notesController.text,
                                  tapTrue == 2,
                                  customAmount: isCustomizeFinal
                                      ? customAmount
                                      : null,
                                  isCustomize: isCustomizeFinal,
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary500,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(size8),
                                ),
                              ),
                              child: Text(
                                'Tambah Ke Keranjang',
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
                    SizedBox(height: size12),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    // Calculate extra price
    double variantTotal = 0;
    List<Map<String, dynamic>> flattenedVariants = [];
    List<Map<String, dynamic>> apiVariants = [];

    for (var cat in variantList) {
      final catId = cat['variant_category_id'];
      // API Structure
      // List<String> ids = (cat['variant_id'] as List)
      //     .map((e) => e.toString())
      //     .toList();
      // apiVariants.add({
      //   "variant_category_id": cat['variant_category_id'],
      //   "variant_id": ids,
      // });

      // // UI Structure
      // for (var v in (cat['variant_detail'] as List)) {
      //   variantTotal += (v['variant_price'] as int).toDouble();
      //   flattenedVariants.add({
      //     "variant_id": v['variant_id'],
      //     "name": v['variant_name'],
      //     "price": v['variant_price'],
      //   });
      // }

      final List<Map<String, dynamic>> details =
          List<Map<String, dynamic>>.from(cat['variant_detail'] as List);

      for (var v in details) {
        final int vprice = _toIntSafe(v['variant_price']);
        variantTotal += vprice.toDouble();

        flattenedVariants.add({
          "variant_id": v['variant_id'],
          "name": v['variant_name'],
          "price": vprice,
        });
      }

      final variantItems = details.map((v) {
        final int vprice = _toIntSafe(v['variant_price']);
        final bool vCustom = v['is_variant_customize'] == true;

        return {
          "variant_id": v['variant_id'].toString(),
          "variant_price": vprice,
          "is_variant_customize": vCustom,
        };
      }).toList();

      apiVariants.add({
        "variant_category_id": catId.toString(),
        "variant": variantItems,
      });
    }

    final int baseDefault = isOnline
        ? product.onlinePrice
        : (product.priceAfter ?? product.price);

    final double baseUsed = (isCustomize && customAmount != null)
        ? customAmount.toDouble()
        : baseDefault.toDouble();

    final double unitAmount = baseUsed + variantTotal;
    final double totalAmount = unitAmount * quantity;
    final Map<String, int> variantCustomCache = {};

    setState(() {
      _cart.add({
        'product': product,
        'quantity': quantity,
        'notes': notes,
        'variants': apiVariants, // API Structure
        'variants_ui': flattenedVariants, // UI Structure
        'variant_total': variantTotal,
        'variant_custom_cache': variantCustomCache,
        'is_online': isOnline,

        'is_customize': isCustomize,
        'custom_amount': isCustomize ? customAmount : null,

        'base_amount': baseUsed,
        'unit_amount': unitAmount,
        'total_amount': totalAmount,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Produk berhasil ditambahkan')));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(Product product, int quantity, String notes) {
    setState(() {
      _cart.add({'product': product, 'quantity': quantity, 'notes': notes});
    });
    Navigator.pop(context);
  }

  void _updateCartQty(int index, int newQty) {
    setState(() {
      if (newQty < 1) return;
      _cart[index]['quantity'] = newQty;
      final num unit = _cart[index]['unit_amount'] as num? ?? 0;
      _cart[index]['total_amount'] = unit * newQty;
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  int get _totalItems =>
      _cart.fold(0, (sum, item) => sum + (item['quantity'] as int));
  int get _subTotal => cartSubTotal(_cart);

  void _showProductDetail(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailModal(
        product: product,
        onAddToCart: (qty, notes) => _addToCart(product, qty, notes),
      ),
    );
  }

  Future<void> _openBillList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillListPage(
          token: widget.token,
          merchantId: widget.merchantId,
          baseUrl: url,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      if (result['action'] == 'edit' || result['action'] == 'pay') {
        _restoreCart(result['data']);

        if (result['action'] == 'pay') {
          // Wait for cart to be restored
          await Future.delayed(Duration(milliseconds: 100));

          // Get final amount from bill detail
          final billAmount =
              double.tryParse(result['data']['amount']?.toString() ?? '0') ?? 0;

          // Call calculating API before payment
          await _calculateBeforePayment(
            result['data']['transactionid']?.toString(),
            billAmount,
            result['data'], // Pass complete bill data
          );
        }
      }
    }
  }

  Future<void> _calculateBeforePayment(
    String? transactionId,
    double billAmount,
    Map<String, dynamic> billData,
  ) async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Keranjang kosong')));
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      final details = buildTransactionDetails(
        _cart,
        mode: DetailMode.calculate,
      );
      print('cart: $_cart');
      print('=== CALCULATING API DEBUG 1===');
      print('Transaction ID: $transactionId');
      print('Merchant ID: ${widget.merchantId}');
      print('Cart items count: ${_cart.length}');
      for (var i = 0; i < _cart.length; i++) {
        print('Cart item $i:');
        print('  Product: ${_cart[i]['product'].name}');
        print('  Variants (API): ${_cart[i]['variants']}');
        print('  Variants (UI): ${_cart[i]['variants_ui']}');
      }
      print('Details being sent: $details');
      print('===========================');

      final response = await http.post(
        Uri.parse(calculateTransaksiUrl),
        headers: {
          'token': widget.token,
          'DEVICE-ID': identifier!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "merchantid": widget.merchantId,
          "discount_id": _selectedDiscount?.id ?? "",
          "member_id": _selectedMemberId ?? "",
          "transaction_id": transactionId ?? "",
          "detail": details,
        }),
      );

      print('Calculating response: ${response.body}');

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00') {
          // Calculating successful, proceed to payment
          if (!mounted) return;

          // Autoritative data from calculation
          final calculationResult =
              data['data'] ?? data as Map<String, dynamic>;
          final calcAmount =
              double.tryParse(calculationResult['amount'].toString()) ?? 0;

          // Merge with original bill data so we don't lose fields like total_before_dsc_tax
          final Map<String, dynamic> mergedData = Map<String, dynamic>.from(
            billData,
          );
          if (calculationResult is Map<String, dynamic>) {
            mergedData.addAll(calculationResult);
          }

          print('=== PAYMENT PAGE DATA ===');
          print('Calculation Result: $calculationResult');
          print('Merged Data: $mergedData');
          print('Bill Amount: $billAmount');
          print('========================');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(
                cart: _cart,
                token: widget.token,
                merchantId: widget.merchantId,
                transactionId: transactionId,
                memberId: _selectedMemberId, // Pass memberId
                finalAmount: calcAmount,
                billData: billData,
                onSuccess: () {
                  setState(() {
                    _cart.clear();
                    _calculationData = null;
                    _currentTransactionId = null;
                  });
                },
              ),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Gagal menghitung total'),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _restoreCart(Map<String, dynamic> data) {
    List<Map<String, dynamic>> newCart = [];
    if (data['detail'] != null) {
      for (var item in (data['detail'] as List)) {
        // Try to find product in loaded products, else create temp Product
        Product product;
        try {
          final isCustomize = _toBool(item['is_customize']);

          product = Product(
            id:
                item['productid']?.toString() ??
                item['product_id']?.toString() ??
                '',
            name: item['name'] ?? '',
            price: (double.tryParse(item['price']?.toString() ?? '0') ?? 0)
                .toInt(),
            onlinePrice:
                (double.tryParse(item['online_price']?.toString() ?? '0') ?? 0)
                    .toInt(),
            category: item['typeproducts'],
            imageUrl: item['product_image'],
            isCustomize: isCustomize,
          );
        } catch (e) {
          continue;
        }

        // Reruct variants from bill detail structure
        List<Map<String, dynamic>> apiVariants = [];
        List<Map<String, dynamic>> uiVariants = [];
        double variantTotal = 0;

        if (item['variants'] != null) {
          for (var variant in (item['variants'] as List)) {
            // API structure
            if (variant['variant_category_id'] != null) {
              final List<dynamic> vpList =
                  (variant['variant_products'] as List?) ?? [];

              apiVariants.add({
                'variant_category_id': variant['variant_category_id']
                    .toString(),
                'variant': vpList.map((vp) {
                  final id =
                      (vp['variant_product_id'] ?? vp['variant_id'] ?? vp['id'])
                          .toString();
                  final price = _toIntSafe(vp['price'] ?? vp['variant_price']);
                  final isCust = _toBool(vp['is_variant_customize']);

                  return {
                    "variant_id": id,
                    "variant_price": price,
                    "is_variant_customize": isCust,
                  };
                }).toList(),
              });
            }

            // UI structure - extract from variant_products
            if (variant['variant_products'] != null) {
              for (var vp in (variant['variant_products'] as List)) {
                print('Variant product data: $vp');
                final price =
                    double.tryParse(vp['price']?.toString() ?? '0') ?? 0;
                variantTotal += price;
                uiVariants.add({
                  'variant_id':
                      vp['variant_product_id'] ?? vp['variant_id'] ?? vp['id'],
                  'name':
                      vp['variant_product_name'] ?? vp['variant_name'] ?? '',
                  'price': price.toInt(),
                });
              }
            }
          }
        }

        final bool isCustomize = _toBoolSafe(item['is_customize']);
        final bool isOnline = _toBoolSafe(item['is_online']);
        final int restoredAmount =
            (double.tryParse(item['price']?.toString() ?? '0') ?? 0).round();

        newCart.add({
          'product': product,
          'quantity': int.tryParse(item['quantity'].toString()) ?? 1,
          'notes': item['note'] ?? item['description'] ?? '',
          'variants': apiVariants,
          'variants_ui': uiVariants,
          'variant_total': variantTotal,
          'is_online': isOnline,
          'is_customize': isCustomize,
          'custom_amount': restoredAmount,
        });

        print('Restored cart item for ${product.name}:');
        print('  - API Variants: $apiVariants');
        print('  - UI Variants: $uiVariants');
        print('  - Variant Total: $variantTotal');
      }
    }

    setState(() {
      _cart.clear();
      _cart.addAll(newCart);
    });

    print('Total cart items restored: ${newCart.length}');
  }

  Future<void> _processSaveBill({bool closeOnSuccess = false}) async {
    if (_cart.isEmpty) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final url = Uri.parse(createTransaksiUrl);

      // List<Map<String, dynamic>> details = _cart.map((item) {
      //   Product p = item['product'];

      //   final int qty = (item['quantity'] as int?) ?? 0;
      //   final bool isOnline = item['is_online'] == true;
      //   final bool isCustomize = item['is_customize'] == true;
      //   final int? customAmount = item['custom_amount'] as int?;
      //   final int variantTotal = (item['variant_total'] as num? ?? 0).toInt();

      //   final int baseDefault = isOnline
      //       ? (p.onlinePrice)
      //       : (p.priceAfter ?? p.price);

      //   final int baseUsed = (isCustomize && customAmount != null)
      //       ? customAmount
      //       : baseDefault;

      //   final int unitAmount =
      //       (item['unit_amount'] as num?)?.round() ?? (baseUsed + variantTotal);

      //   final int totalAmount =
      //       (item['total_amount'] as num?)?.round() ?? (unitAmount * qty);

      //   final List<dynamic> rawVariants = (item['variants'] ?? []) as List;

      //   final List<Map<String, dynamic>> variants = rawVariants.map((cat) {
      //     final String catId = cat['variant_category_id']?.toString() ?? '';

      //     final List<dynamic> rawVarList = (cat['variant'] ?? []) as List;

      //     final mappedVarList = rawVarList.map((v) {
      //       final Map<String, dynamic> mapped = {
      //         "variant_id": v['variant_id']?.toString() ?? '',
      //       };

      //       if (isCustomize) {
      //         final dynamic priceVal = v['variant_price'] ?? v['price'] ?? 0;

      //         mapped["variant_price"] = priceVal;
      //         mapped["is_variant_customize"] = true;
      //       }

      //       return mapped;
      //     }).toList();

      //     return {"variant_category_id": catId, "variant": mappedVarList};
      //   }).toList();

      //   return {
      //     "product_id": p.id.toString(),
      //     "request_id": "",
      //     "is_online": isOnline,
      //     "is_customize": isCustomize,
      //     "amount": unitAmount,
      //     "name": p.name,
      //     "quantity": qty,
      //     "description": item['notes'] ?? "",
      //     "variants": variants,
      //   };
      // }).toList();
      final details = buildTransactionDetails(
        _cart,
        mode: DetailMode.create,
        quantityAsString: false,
      );

      final body = {
        "deviceid": identifier,
        "device_id": identifier,
        "discount_id": _selectedDiscount?.id ?? null,
        "member_id": _selectedMemberId ?? null,
        "transaction_id": null,
        "value": null,
        "payment_method": null,
        "payment_reference": null, // Default empty as requested
        "detail": details,
      };

      debugPrint("Sending save bill: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      Navigator.pop(context);
      debugPrint("Save bill response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00') {
          if (closeOnSuccess) Navigator.pop(context);
          showSnackbar(context, jsonDecode(response.body));
          setState(() {
            _cart.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Gagal menyimpan tagihan'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _openFullCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(
        cart: _cart,
        onUpdateQty: (index, qty) {
          _updateCartQty(index, qty);
        },
        onUpdateItem: (index, qty, notes) {
          setState(() {
            _cart[index]['quantity'] = qty;
            _cart[index]['notes'] = notes;
          });
        },
        onUpdateVariants: (index, apiVariants, uiVariants, total) {
          setState(() {
            _cart[index]['variants'] = apiVariants;
            _cart[index]['variants_ui'] = uiVariants;
            _cart[index]['variant_total'] = total;

            final Product p = _cart[index]['product'];
            final bool isOnline = _cart[index]['is_online'] == true;
            final bool isCustomize = _cart[index]['is_customize'] == true;
            final int? customAmount = _cart[index]['custom_amount'] as int?;
            final int qty = _cart[index]['quantity'] as int;

            final int baseDefault = isOnline
                ? p.onlinePrice
                : (p.priceAfter ?? p.price);

            final double baseUsed = (isCustomize && customAmount != null)
                ? customAmount.toDouble()
                : baseDefault.toDouble();

            final double unitAmount = baseUsed + total;
            _cart[index]['unit_amount'] = unitAmount;
            _cart[index]['total_amount'] = unitAmount * qty;
          });
        },
        fetchVariants: _fetchProductVariants,
        onRemove: (index) {
          _removeFromCart(index);
        },
        onClearAll: () {
          setState(() {
            _cart.clear();
          });
        },
        onPay: () {
          Navigator.pop(context); // Close cart
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(
                cart: _cart,
                token: widget.token,
                merchantId: widget.merchantId,
                transactionId: _currentTransactionId,
                memberId: _selectedMemberId, // Pass memberId
                selectedDiscount: _selectedDiscount,
                onSuccess: () {
                  setState(() {
                    _cart.clear();
                    _calculationData = null;
                    _currentTransactionId = null;
                  });
                },
              ),
            ),
          );
        },
        onSaveBill: () => _processSaveBill(closeOnSuccess: true),
        selectedDiscount: _selectedDiscount,
        onSelectDiscount: () {
          Navigator.pop(context);
          _showSelectDiscountModal();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _isGroupMerchant
        ? const [Tab(text: "Riwayat"), Tab(text: "Pengaturan")]
        : const [
            Tab(text: "Kasir"),
            Tab(text: "Riwayat"),
            Tab(text: "Pengaturan"),
          ];

    final views = _isGroupMerchant
        ? [
            HistoryTab(
              token: widget.token,
              merchantId: widget.merchantId,
              baseUrl: url,
            ),
            SettingsTab(token: widget.token, merchantId: widget.merchantId),
          ]
        : [
            _buildKasirView(),
            HistoryTab(
              token: widget.token,
              merchantId: widget.merchantId,
              baseUrl: url,
            ),
            SettingsTab(token: widget.token, merchantId: widget.merchantId),
          ];
    return Scaffold(
      backgroundColor: bnw100,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: bnw100,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: bnw900),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DashboardPageMobile(token: widget.token),
                  ),
                ),
              ),
              title: Text(
                'Transaksi',
                style: TextStyle(
                  color: bnw900,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    labelColor: primary500,
                    unselectedLabelColor: bnw500,
                    indicatorColor: primary500,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Outfit',
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      fontFamily: 'Outfit',
                    ),
                    tabs: tabs,
                  ),
                ),
              ),
            ),
      body: widget.isEmbedded
          ? _buildKasirView()
          : TabBarView(
              controller: _tabController,
              children: views,
              // [
              //   _buildKasirView(),

              //   // Tab 2: Riwayat
              //   HistoryTab(
              //     token: widget.token,
              //     merchantId: widget.merchantId,
              //     baseUrl: url,
              //   ),

              //   // Tab 3: Pengaturan
              //   SettingsTab(token: widget.token, merchantId: widget.merchantId),
              // ],
            ),
      bottomNavigationBar: (_isGroupMerchant || widget.isEmbedded)
          ? null
          // _buildBottomBar()
          : (_currentTabIndex == 0
                ? _buildBottomBar()
                : null), // Only show on Kasir tab
    );
  }

  Widget _buildKasirView() {
    return Column(
      children: [
        Divider(height: 1, color: bnw300),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: size12),
                decoration: BoxDecoration(
                  color: bnw200,
                  borderRadius: BorderRadius.circular(size8),
                  border: Border.all(color: bnw300),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelStyle: heading2(FontWeight.w400, bnw500, 'Outfit'),
                    hintText: 'Cari',
                    icon: Icon(PhosphorIcons.magnifying_glass, color: bnw900),
                  ),
                ),
              ),
              SizedBox(height: size12),
              Row(
                children: [
                  GestureDetector(
                    onTap: _showSortModal,
                    child: _buildDropdown(textOrderBy),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: _buildProductList()),
      ],
    );
  }

  // Helper to check if product is selected to highlight it
  bool _isInCart(Product p) {
    return _cart.any((element) => (element['product'] as Product).id == p.id);
  }

  Widget _buildProductList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_filteredProducts.isEmpty) {
      return Center(child: Text("Tidak ada produk tersedia/ditemukan"));
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return GestureDetector(
          onTap: () => _showPreviewCart(product),
          child: Container(
            margin: EdgeInsets.only(bottom: size12),
            decoration: BoxDecoration(
              color: _isInCart(product) ? primary100 : bnw100,
              borderRadius: BorderRadius.circular(size12),
              border: Border.all(
                width: size4,
                color: _isInCart(product) ? primary500 : bnw300,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(size12),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(size8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              SvgPicture.asset('assets/logoProduct.svg'),
                        )
                      : Icon(Icons.coffee, size: 40, color: Colors.brown),
                ),
                SizedBox(width: size12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      SizedBox(height: size8),
                      Text(
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp. ',
                          decimalDigits: 0,
                        ).format(product.priceAfter ?? product.price),
                        style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      if (product.discountType != null)
                        Text(
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp. ',
                            decimalDigits: 0,
                          ).format(product.price),
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontFamily: 'Outfit',
                            color: bnw500,
                            fontSize: sp12,
                          ),
                        ),
                      if (product.discount != null && product.discount! > 0)
                        Text(
                          product.discountType == 'price'
                              ? NumberFormat.currency(
                                  locale: 'id',
                                  symbol: 'Rp. ',
                                  decimalDigits: 0,
                                ).format(product.discount ?? 0)
                              : '${product.discount ?? 0} %',
                          style: heading4(FontWeight.w600, danger500, 'Outfit'),
                        ),

                      SizedBox(height: size8),
                      Text(
                        product.category,
                        style: heading4(FontWeight.w400, bnw500, 'Outfit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Track tab index to hide bottom bar

  Widget _buildDropdown(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size12, vertical: size8),
      decoration: BoxDecoration(
        border: Border.all(color: bnw300),
        borderRadius: BorderRadius.circular(size8),
        color: bnw100,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: heading3(FontWeight.w400, bnw900, 'Outfit')),
          SizedBox(width: size4),
          Icon(Icons.arrow_drop_down, size: size32),
        ],
      ),
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Urutkan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pilih urutan yang ingin ditampilkan',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _sortOptions.map((option) {
                  bool isSelected = textvalueOrderBy == option['value'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        textvalueOrderBy = option['value']!;
                        textOrderBy = option['label']!;
                      });
                      Navigator.pop(context); // Close modal
                      _fetchProducts(); // Refresh data
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primary500.withOpacity(0.1)
                            : bnw100,
                        border: Border.all(
                          color: isSelected ? primary500 : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(size8),
                      ),
                      child: Text(
                        option['label']!,
                        style: TextStyle(
                          color: isSelected ? primary500 : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    bool hasItems = _cart.isNotEmpty;

    return Container(
      color: bnw100,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(thickness: 4, indent: 150, endIndent: 150, color: bnw300),
          SizedBox(height: size8),

          if (_selectedMemberName == null)
            OutlinedButton(
              onPressed: _showCustomerSelectionSheet,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                side: BorderSide(color: bnw300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, color: bnw900),
                  SizedBox(width: size8),
                  Text('Pilih Pembeli', style: TextStyle(color: bnw900)),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: _showCustomerSelectionSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary500,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, color: bnw100),
                  SizedBox(width: size8),
                  Text(
                    _selectedMemberName!,
                    style: TextStyle(
                      color: bnw100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: size12),
          Row(
            children: [
              if (hasItems) ...[
                // Active State: Icon Only Button + Simpan Tagihan
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size8),
                    border: Border.all(color: primary500),
                  ),
                  child: IconButton(
                    icon: Icon(PhosphorIcons.notebook_fill, color: primary500),
                    onPressed: _openBillList,
                    tooltip: 'Daftar Tagihan',
                  ),
                ),
                SizedBox(width: size8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _processSaveBill(closeOnSuccess: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bnw100,
                      side: BorderSide(color: primary500),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Simpan Tagihan',
                      style: heading3(FontWeight.w600, primary500, 'Outfit'),
                    ),
                  ),
                ),
                SizedBox(width: size8),
              ] else ...[
                // Empty State: Daftar Tagihan (Full button)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openBillList,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bnw100,
                      side: BorderSide(color: primary500),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size8),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(PhosphorIcons.notebook_fill, color: primary500),
                    label: Text(
                      'Daftar Tagihan',
                      style: heading3(FontWeight.w600, primary500, 'Outfit'),
                    ),
                  ),
                ),
                SizedBox(width: size8),
              ],

              // Keranjang Button (Common to both, styling adjusts if items present)
              Expanded(
                child: ElevatedButton(
                  onPressed: hasItems ? _openFullCart : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary500,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size8),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Icon(Icons.shopping_bag_outlined, color: bnw100),
                      if (hasItems) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: danger500,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$_totalItems',
                            style: TextStyle(fontSize: 10, color: bnw100),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCustomerSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
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
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pilih Pembeli",
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context); // Close sheet
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemberPageMobile(),
                          ),
                        );
                        if (result != null && result is MemberModel) {
                          setState(() {
                            // Set ID locally first
                            _selectedMemberId = result.memberid;
                            // Fallback name while loading
                            _selectedMemberName = result.namaMember;
                          });

                          // Trigger calculation to get authoritative name
                          _calculateAndSetMember();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: bnw300),
                          borderRadius: BorderRadius.circular(12),
                          color: bnw100, // Or light blue if matches image
                        ),
                        child: Column(
                          children: [
                            // Using standard icons or asset if available.
                            // Image 2 shows specific illustrations.
                            // I will use Icon for now as I don't have the assets ready.
                            Icon(Icons.person, size: 48, color: primary500),
                            SizedBox(height: 12),
                            Text(
                              "Pelanggan",
                              style: heading3(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showNonMemberInputSheet();
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: bnw300),
                          borderRadius: BorderRadius.circular(12),
                          color: bnw100,
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person_outline, size: 48, color: bnw900),
                            SizedBox(height: 12),
                            Text(
                              "Bukan Pelanggan",
                              style: heading3(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showNonMemberInputSheet() {
    final TextEditingController _nameController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // For keyboard
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pilih Pembeli",
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                "Nama Pembeli *",
                style: heading4(FontWeight.w600, bnw900, 'Outfit'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Cth : Bayu Setiawan",
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primary500, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 32),
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
                        "Kembali",
                        style: heading3(FontWeight.w600, primary500, 'Outfit'),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.trim().isNotEmpty) {
                          setState(() {
                            _selectedMemberId = _nameController.text.trim();
                            // Fallback name
                            _selectedMemberName = _nameController.text.trim();
                          });
                          Navigator.pop(context);

                          _calculateAndSetMember();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Nama wajib diisi")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
        );
      },
    );
  }

  Future<void> _calculateAndSetMember() async {
    // If cart is empty, we can't calculate, so we rely on the local name set previously.
    if (_cart.isEmpty) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
      print('=== CALCULATING API DEBUG 2===');
      final url = Uri.parse(calculateTransaksiUrl);

      List<Map<String, dynamic>> details = _cart.map((item) {
        Product p = item['product'];
        final bool isOnlineItem = item['is_online'] ?? false;
        final int priceUsed = (item['custom_amount'] is int)
            ? item['custom_amount'] as int
            : ((isOnlineItem ? (p.onlinePrice) : (p.priceAfter ?? p.price))
                      as num)
                  .toInt();

        final bool isCustomize = item['is_customize'] == true;
        final List<dynamic> rawVariants = (item['variants'] ?? []) as List;

        final List<Map<String, dynamic>> variants = rawVariants.map((cat) {
          final String catId = cat['variant_category_id']?.toString() ?? '';

          final List<dynamic> rawVarList = (cat['variant'] ?? []) as List;

          final mappedVarList = rawVarList.map((v) {
            final Map<String, dynamic> mapped = {
              "variant_id": v['variant_id']?.toString() ?? '',
            };

            if (isCustomize) {
              final dynamic priceVal = v['variant_price'] ?? v['price'] ?? 0;

              mapped["variant_price"] = priceVal;
              mapped["is_variant_customize"] = true;
            }

            return mapped;
          }).toList();

          return {"variant_category_id": catId, "variant": mappedVarList};
        }).toList();
        return {
          "product_id": p.id,
          "name": p.name,
          "price": priceUsed,
          "quantity": item['quantity'],
          "description": item['notes'] ?? "",
          "is_online": isOnlineItem,
          "is_customize": item['is_customize'] ?? false,
          "variants": variants,
        };
      }).toList();

      final response = await http.post(
        url,
        headers: {
          'token': widget.token,
          'DEVICE-ID': identifier!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "merchantid": widget.merchantId,
          "discount_id": _selectedDiscount?.id ?? "",
          "member_id": _selectedMemberId ?? "",
          "transaction_id": "",
          "detail": details,
        }),
      );

      Navigator.pop(context); // Close loading

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00') {
          final calcData = data['data'] ?? data;

          // NOTE: We do NOT update _selectedMemberName from API response here
          // because the API might return the ID in the 'customer' field,
          // which overwrites the human-readable name we already have.
          // We trust the name set during selection.

          _calculationData = data; // Store calculation data if needed
        }
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      debugPrint("Error calculating for member: $e");
    }
  }

  void _showSelectDiscountModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
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
                  SizedBox(height: 20),
                  Text(
                    "Pilih Diskon Umum",
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<DiscountModel>>(
                      future: _fetchDiscountsModal(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text("Tidak ada diskon tersedia"),
                          );
                        }

                        final discounts = snapshot.data!;
                        return ListView.separated(
                          controller: scrollController,
                          itemCount: discounts.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final discount = discounts[index];
                            final isSelected =
                                _selectedDiscount?.id == discount.id;

                            // Formatted Value
                            String valueText = "";
                            if (discount.discountType == 'price') {
                              valueText = NumberFormat.currency(
                                locale: 'id',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(discount.discount);
                            } else {
                              valueText = "${discount.discount}%";
                            }

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_selectedDiscount?.id == discount.id) {
                                    _selectedDiscount = null;
                                  } else {
                                    _selectedDiscount = discount;
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: bnw100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? primary500 : bnw300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      PhosphorIcons.tag_fill,
                                      color: primary500,
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            discount.name,
                                            style: heading3(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                          Text(
                                            valueText,
                                            style: heading4(
                                              FontWeight.w400,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          discount.date,
                                          style: body2(
                                            FontWeight.w400,
                                            bnw500,
                                            'Outfit',
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle,
                                            color: primary500,
                                            size: 20,
                                          )
                                        else
                                          Icon(
                                            Icons.circle_outlined,
                                            color: bnw300,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
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

  Future<List<DiscountModel>> _fetchDiscountsModal() async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://unipos-dev-unipos-api-dev.yi8k7d.easypanel.host/api/discount",
        ),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({"order_by": "upDownNama"}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00' && data['data'] != null) {
          return (data['data'] as List)
              .map((e) => DiscountModel.fromJson(e))
              .where((d) => d.isActive)
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching discounts: $e");
    }
    return [];
  }
}

// ---------------------------
// Screen 1: Expanded Cart
// ---------------------------
class CartBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Function(int index, int qty) onUpdateQty;
  final Function(int index, int qty, String notes) onUpdateItem;
  final Function(
    int index,
    List<Map<String, dynamic>> apiVariants,
    List<Map<String, dynamic>> uiVariants,
    double variantTotal,
  )
  onUpdateVariants;
  final Function(int index) onRemove;
  final VoidCallback onClearAll;
  final VoidCallback onPay;
  final VoidCallback onSaveBill;
  final DiscountModel? selectedDiscount;
  final VoidCallback? onSelectDiscount;
  final Future<List<ProductVariantCategory>?> Function(String) fetchVariants;

  CartBottomSheet({
    Key? key,
    required this.cart,
    required this.onUpdateQty,
    required this.onUpdateItem,
    required this.onUpdateVariants,
    required this.onRemove,
    required this.onClearAll,
    required this.onPay,
    required this.onSaveBill,
    this.selectedDiscount,
    this.onSelectDiscount,
    required this.fetchVariants,
  }) : super(key: key);

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  // Local state to managing instant updates in UI, but parent state is source of truth

  void _showClearCartDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bnw100,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
            SizedBox(height: 24),
            Text(
              'Kamu yakin ingin menghapus seluruh produk di keranjang?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size8),
            Text(
              'Semua catatan dan jumlah produk yang tersimpan di keranjang tidak dapat dikembalikan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: primary500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size8),
                      ),
                    ),
                    child: Text(
                      'Batalkan',
                      style: TextStyle(
                        color: primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onClearAll();
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary500,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size8),
                      ),
                    ),
                    child: Text(
                      'Ya, Hapus',
                      style: TextStyle(
                        color: bnw100,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemModal(int index) {
    final item = widget.cart[index];
    final Product product = item['product'];
    final int quantity = item['quantity'];
    final String notes = item['notes'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailModal(
        product: product,
        initialQty: quantity,
        initialNotes: notes,
        onAddToCart: (newQty, newNotes) {
          widget.onUpdateItem(index, newQty, newNotes);
          setState(() {});
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = widget.cart.fold(
      0,
      (sum, item) => sum + (item['quantity'] as int),
    );
    final int subTotal = cartSubTotal(widget.cart);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              SizedBox(height: size8),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: size12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Keranjang',
                      style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                    Row(
                      children: [
                        // Icon(Icons.qr_code_scanner, color: bnw900),
                        // SizedBox(width: 16),
                        GestureDetector(
                          onTap: _showClearCartDialog,
                          child: Icon(Icons.delete, color: danger500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: EdgeInsets.all(16),
                  itemCount: widget.cart.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    final item = widget.cart[index];
                    final Product product = item['product'];
                    final int quantity = item['quantity'];
                    final String notes = item['notes'];

                    return CartItemWidget(
                      item: item,
                      index: index,
                      onUpdateQty: (index, qty) {
                        widget.onUpdateQty(index, qty);
                        setState(() {});
                      },
                      onRemove: (index) {
                        widget.onRemove(index);
                        setState(() {});
                      },
                      onUpdateVariants:
                          (index, apiVariants, uiVariants, total) {
                            widget.onUpdateVariants(
                              index,
                              apiVariants,
                              uiVariants,
                              total,
                            );
                            setState(() {});
                          },
                      onUpdateNotes: (index, notes) {
                        widget.onUpdateItem(
                          index,
                          quantity,
                          notes,
                        ); // Assuming onUpdateItem handles generic updates
                        // But wait, onUpdateItem signature is (index, qty, notes).
                        // So we need to pass current qty.
                        setState(() {});
                      },
                      fetchVariants: widget.fetchVariants,
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bnw100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Item',
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                        Text(
                          '$totalItems',
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ],
                    ),
                    SizedBox(height: size8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sub Total',
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp. ',
                            decimalDigits: 0,
                          ).format(subTotal),
                          style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    SizedBox(height: size12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onSaveBill,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bnw100,
                              side: BorderSide(color: primary500),
                              minimumSize: Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(size8),
                              ),
                            ),
                            child: Text(
                              'Simpan Tagihan',
                              style: heading3(
                                FontWeight.w600,
                                primary500,
                                'Outfit',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onPay,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary500,
                              minimumSize: Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(size8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  PhosphorIcons.wallet_fill,
                                  color: bnw100,
                                  size: 20,
                                ),
                                SizedBox(width: size8),
                                Text(
                                  'Bayar',
                                  style: heading3(
                                    FontWeight.w600,
                                    bnw100,
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _qtyBtn(bool isPlus, int currentQty, VoidCallback onTap) {
    // Minus color logic: Grey if 1, Blue if > 1. Plus is always Blue/Primary
    Color btnColor = isPlus
        ? primary500
        : (currentQty > 1 ? primary500 : Colors.grey[300]!);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(isPlus ? Icons.add : Icons.remove, size: 16, color: bnw100),
      ),
    );
  }
}

// ---------------------------
// Cart Item Widget
// ---------------------------
class CartItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  final Function(int) onRemove;
  final Function(int, int) onUpdateQty;
  final Function(int, String) onUpdateNotes;
  final Function(
    int,
    List<Map<String, dynamic>>,
    List<Map<String, dynamic>>,
    double,
  )
  onUpdateVariants;
  final Future<List<ProductVariantCategory>?> Function(String) fetchVariants;

  CartItemWidget({
    Key? key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.onUpdateQty,
    required this.onUpdateVariants,
    required this.onUpdateNotes,
    required this.fetchVariants,
  }) : super(key: key);

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  bool _isExpanded = false;
  Future<List<ProductVariantCategory>?>? _variantFuture;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.item['notes'] ?? '');
    _seedCustomCacheFromCurrentVariants();
  }

  @override
  void didUpdateWidget(CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item['variants'] != widget.item['variants']) {
      _seedCustomCacheFromCurrentVariants();
    }
    if (oldWidget.item['notes'] != widget.item['notes']) {
      if (_notesController.text != widget.item['notes']) {
        _notesController.text = widget.item['notes'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _findVariantEntry(
    List<dynamic> currentVariants,
    String catId,
    String variantId,
  ) {
    for (final cat in currentVariants) {
      if (cat is! Map) continue;
      if (cat['variant_category_id']?.toString() != catId) continue;

      final list =
          (cat['variant'] as List?) ?? (cat['variant_detail'] as List?) ?? [];

      for (final v in list) {
        if (v is! Map) continue;
        if (v['variant_id']?.toString() == variantId) {
          return Map<String, dynamic>.from(v);
        }
      }
    }
    return null;
  }

  List<String> _selectedIdsFromApi(dynamic apiVar) {
    if (apiVar is! Map) return [];

    if (apiVar['variant'] is List) {
      return (apiVar['variant'] as List)
          .map((e) => (e as Map)['variant_id'].toString())
          .toList();
    }

    if (apiVar['variant_id'] is List) {
      return (apiVar['variant_id'] as List).map((e) => e.toString()).toList();
    }
    if (apiVar['variant_id'] != null) return [apiVar['variant_id'].toString()];

    return [];
  }

  Map<String, int> _customCache() {
    final raw = widget.item['variant_custom_cache'];

    if (raw is Map<String, int>) return raw;

    final Map<String, int> m = {};
    if (raw is Map) {
      raw.forEach((key, value) => m[key.toString()] = _toIntSafe(value));
    }

    widget.item['variant_custom_cache'] = m;
    return m;
  }

  void _setCache(String variantId, int price, int defPrice) {
    final cache = _customCache();
    if (price == defPrice) {
      cache.remove(variantId);
    } else {
      cache[variantId] = price;
    }
  }

  void _seedCustomCacheFromCurrentVariants() {
    final rawVars = widget.item['variants'];
    if (rawVars is! List) return;

    final cache = _customCache();

    for (final cat in rawVars) {
      if (cat is! Map) continue;

      final list =
          (cat['variant'] as List?) ?? (cat['variant_detail'] as List?) ?? [];

      for (final v in list) {
        if (v is! Map) continue;

        final String vid = v['variant_id']?.toString() ?? '';
        if (vid.isEmpty) continue;

        final bool isCust = _toBoolSafe(v['is_variant_customize']);
        if (!isCust) continue;

        final int price = _toIntSafe(v['variant_price'] ?? v['price']);
        cache[vid] = price;
      }
    }

    widget.item['variant_custom_cache'] = cache;
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.item['product'];
    final int quantity = widget.item['quantity'];
    final String notes = widget.item['notes'] ?? '';
    final List<dynamic> currentVariants = widget.item['variants'] ?? [];

    final bool isOnline = widget.item['is_online'] == true;
    final bool isCustomize = widget.item['is_customize'] == true;
    final int? customAmount = widget.item['custom_amount'] as int?;
    final int variantTotal = (widget.item['variant_total'] as num? ?? 0)
        .toInt();

    final int baseDefault = isOnline
        ? product.onlinePrice
        : (product.priceAfter ?? product.price);

    final int baseUsed = (isCustomize && customAmount != null)
        ? customAmount
        : baseDefault;

    final int unitPrice = baseUsed + variantTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: size8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: bnw200,
                  borderRadius: BorderRadius.circular(size8),
                ),
                child: Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      SvgPicture.asset('assets/logoProduct.svg'),
                ),
              ),
              SizedBox(width: size12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                    Row(
                      children: [
                        Text(
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp. ',
                            decimalDigits: 0,
                          ).format(baseUsed),
                          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        if (isCustomize) ...[
                          SizedBox(width: size8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primary100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Custom',
                              style: heading4(
                                FontWeight.w600,
                                primary500,
                                'Outfit',
                              ),
                            ),
                          ),
                        ],
                        if (!isCustomize &&
                            widget.item['is_online'] != true &&
                            product.discountType != null) ...[
                          SizedBox(width: size8),
                          Text(
                            NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp. ',
                              decimalDigits: 0,
                            ).format(unitPrice),
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontFamily: 'Outfit',
                              color: bnw500,
                              fontSize: sp12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Varian Expansion Header
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
              if (_isExpanded && _variantFuture == null) {
                _variantFuture = widget.fetchVariants(product.id);
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: size8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Varian",
                  style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Expanded Area
        if (_isExpanded)
          FutureBuilder<List<ProductVariantCategory>?>(
            future: _variantFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text(
                  "Tidak ada varian",
                  style: body1(FontWeight.w600, bnw900, 'Outfit'),
                );
              }

              final categories = snapshot.data!;

              return Column(
                children: categories.map((cat) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size8),
                      Text(
                        cat.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        cat.isRequired == 1
                            ? "Harus dipilih - Maks pilih ${cat.maximumSelected}"
                            : "Opsional dipilih - Maks pilih ${cat.maximumSelected}",
                        style: body2(
                          FontWeight.w600,
                          cat.isRequired == 1 ? danger500 : bnw400,
                          'Outfit',
                        ),
                      ),
                      SizedBox(height: 4),
                      ...cat.productVariants.map((v) {
                        // Check if selected
                        bool isSelected = false;
                        for (var apiVar in currentVariants) {
                          // apiVar is {variant_category_id: ..., variant_id: [id, id]}
                          if (apiVar is! Map) continue;
                          if (apiVar['variant_category_id']?.toString() !=
                              cat.id.toString())
                            continue;

                          final ids = _selectedIdsFromApi(apiVar);
                          if (ids.contains(v.id.toString())) {
                            isSelected = true;
                            break;
                          }
                        }

                        final String catId = cat.id.toString();
                        final String vid = v.id.toString();

                        final entry = _findVariantEntry(
                          currentVariants,
                          catId,
                          vid,
                        );

                        final int defaultVPrice =
                            (double.tryParse(v.price) ?? 0).toInt();

                        final cache = _customCache();
                        final int cachedPrice = cache[vid] ?? defaultVPrice;

                        final int shownVPrice = entry != null
                            ? _toIntSafe(entry['variant_price'])
                            : cachedPrice;

                        final bool isVCustomize = entry != null
                            ? _toBoolSafe(entry['is_variant_customize'])
                            : cache.containsKey(vid);

                        return CheckboxListTile(
                          activeColor: primary500,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(v.name)),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    FormatCurrency.convertToIdr(
                                      shownVPrice.toDouble(),
                                    ),
                                    style: heading4(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                  if (isVCustomize) ...[
                                    SizedBox(width: 6),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primary100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Custom',
                                        style: heading4(
                                          FontWeight.w400,
                                          primary500,
                                          'Outfit',
                                        ),
                                      ),
                                    ),
                                  ],
                                  SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: isSelected
                                        ? () {
                                            _showEditVariantPriceDialog(
                                              cat: cat,
                                              variant: v,
                                              allCategories: categories,
                                              currentVariants: currentVariants,
                                            );
                                          }
                                        : null,
                                    child: Text('Ubah Harga'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          value: isSelected,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          onChanged: (val) {
                            _handleVariantChange(
                              val,
                              v,
                              cat,
                              categories,
                              currentVariants,
                            );
                          },
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              );
            },
          ),

        // Catatan
        SizedBox(height: size8),
        Text("Catatan :", style: heading3(FontWeight.w600, bnw900, 'Outfit')),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: size8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          child: TextField(
            controller: _notesController,
            decoration: InputDecoration.collapsed(
              hintText: "Tambah catatan...",
              hintStyle: heading4(FontWeight.w600, bnw500, 'Outfit'),
            ),
            style: heading4(FontWeight.w600, bnw900, 'Outfit'),
            maxLines: null,
            onChanged: (val) {
              widget.onUpdateNotes(widget.index, val);
            },
          ),
        ),

        // Footer (Delete and Qty)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => widget.onRemove(widget.index),
              icon: Icon(Icons.delete, color: danger500),
            ),
            _qtyBtn(false, quantity, () {
              if (quantity > 1) widget.onUpdateQty(widget.index, quantity - 1);
            }),
            // Restore Container width 32 layout
            Container(
              width: 32,
              alignment: Alignment.center,
              child: Text(
                '$quantity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _qtyBtn(
              true,
              quantity,
              () => widget.onUpdateQty(widget.index, quantity + 1),
            ),
          ],
        ),
      ],
    );
  }

  void _handleVariantChange(
    bool? val,
    ProductVariant variant,
    ProductVariantCategory cat,
    List<ProductVariantCategory> allCategories,
    List<dynamic> currentVariants,
  ) {
    final bool isCustomize = widget.item['is_customize'] == true;
    // 1. Deep copy currentVariants (API structure)
    // It is List<Map<String, dynamic>>, but values inside map might be lists too.
    List<Map<String, dynamic>> newApiVariants = [];
    for (var m in currentVariants) {
      if (m is! Map) continue;

      final String catId = m['variant_category_id']?.toString() ?? '';

      final List<Map<String, dynamic>> items = [];
      if (m['variant'] is List) {
        for (var it in (m['variant'] as List)) {
          if (it is Map) {
            items.add({
              "variant_id": it['variant_id']?.toString() ?? '',
              "variant_price": _toIntSafe(it['variant_price'] ?? it['price']),
              "is_variant_customize": _toBoolSafe(it['is_variant_customize']),
            });
          }
        }
      } else if (m['variant_id'] is List) {
        for (var id in (m['variant_id'] as List)) {
          items.add({
            "variant_id": id.toString(),
            "variant_price": 0,
            "is_variant_customize": false,
          });
        }
      } else if (m['variant_id'] != null) {
        items.add({
          "variant_id": m['variant_id'].toString(),
          "variant_price": 0,
          "is_variant_customize": false,
        });
      }

      if (items.isNotEmpty) {
        newApiVariants.add({"variant_category_id": catId, "variant": items});
      }
    }

    final String catIdStr = cat.id.toString();
    final String varIdStr = variant.id.toString();

    // Find or create category entry
    int catIndex = newApiVariants.indexWhere(
      (e) => e['variant_category_id'].toString() == catIdStr,
    );

    List<Map<String, dynamic>> pickedItems = [];
    if (catIndex != -1) {
      pickedItems = List<Map<String, dynamic>>.from(
        (newApiVariants[catIndex]['variant'] as List? ?? []),
      );
    }

    List<String> currentIds = pickedItems
        .map((e) => e['variant_id'].toString())
        .toList();

    if (val == true) {
      // Selection Logic matching _showPreviewCart
      if (cat.maximumSelected == 1) {
        pickedItems.clear();
        currentIds.clear();
      } else if (cat.maximumSelected > 1 &&
          currentIds.length >= cat.maximumSelected) {
        // Reached limit
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Maksimal pilih ${cat.maximumSelected}")),
        );
        return;
      }
      if (!currentIds.contains(varIdStr)) {
        final cache = _customCache();
        final int defPrice = (double.tryParse(variant.price) ?? 0).toInt();
        final int usedPrice = cache[varIdStr] ?? defPrice;
        pickedItems.add({
          "variant_id": varIdStr,
          "variant_price": usedPrice,
          "is_variant_customize": usedPrice != defPrice,
        });
        currentIds.add(varIdStr);
      }
    } else {
      // Deselection
      // Guard: If Required and this is the last item, prevent deselection?
      if (cat.isRequired == 1 && currentIds.length <= 1) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Varian ini wajib dipilih")));
        return;
      }
      pickedItems.removeWhere(
        (element) => element['variant_id'].toString() == varIdStr,
      );
      currentIds.remove(varIdStr);
    }

    // final rebuiltVariantList = currentIds.map((id) {
    //   String? priceStr;
    //   if (isCustomize) {
    //     final pv = cat.productVariants.firstWhere(
    //       (x) => x.id.toString() == id,
    //       orElse: () =>
    //           ProductVariant(id: '', name: '', price: '0', isActive: '0'),
    //     );
    //     final double p = double.tryParse(pv.price) ?? 0;
    //     priceStr = p.toInt().toString();
    //   }
    //   return {
    //     "variant_id": id,
    //     "variant_price": _toIntSafe(priceStr),
    //     "is_variant_customize": false,
    //   };
    // }).toList();

    // Update newApiVariants
    if (catIndex != -1) {
      if (pickedItems.isEmpty) {
        newApiVariants.removeAt(catIndex);
      } else {
        newApiVariants[catIndex]['variant'] = pickedItems;
      }
    } else {
      if (pickedItems.isNotEmpty) {
        newApiVariants.add({
          "variant_category_id": catIdStr,
          "variant": pickedItems,
        });
      }
    }

    // 2. Recalculate UI Variants and Total

    final Map<String, int> customPriceById = {};
    for (final c in newApiVariants) {
      final List<dynamic> vars = (c['variant'] as List? ?? []);
      for (final v in vars) {
        if (v is! Map) continue;
        final id = v['variant_id']?.toString() ?? '';
        final bool isCust = v['is_variant_customize'] == true;
        final int vp = _toIntSafe(v['variant_price']);
        if (isCust) customPriceById[id] = vp;
      }
    }

    List<Map<String, dynamic>> newUiVariants = [];
    double newTotal = 0;

    for (var c in allCategories) {
      // Find selection for this category in newApiVariants
      final sel = newApiVariants.firstWhere(
        (e) => e['variant_category_id'].toString() == c.id.toString(),
        orElse: () => {},
      );
      if (sel.isEmpty) continue;

      final picked = (sel['variant'] as List? ?? []);
      final ids = picked
          .whereType<Map>()
          .map((e) => e['variant_id']?.toString() ?? '')
          .toList();

      // List<String> ids = (sel['variant_id'] as List).cast<String>();
      for (var v in c.productVariants) {
        final vid = v.id.toString();
        if (!ids.contains(vid)) continue;

        final int def = (double.tryParse(v.price) ?? 0).toInt();
        final int used = customPriceById[vid] ?? def;

        newTotal += used.toDouble();
        newUiVariants.add({"variant_id": v.id, "name": v.name, "price": used});
      }
    }

    // 3. Call callback
    widget.onUpdateVariants(
      widget.index,
      newApiVariants,
      newUiVariants,
      newTotal,
    );
  }

  void _showEditVariantPriceDialog({
    required ProductVariantCategory cat,
    required ProductVariant variant,
    required List<ProductVariantCategory> allCategories,
    required List<dynamic> currentVariants,
  }) {
    final String catIdStr = cat.id.toString();
    final String varIdStr = variant.id.toString();

    List<Map<String, dynamic>> newApiVariants = [];
    for (var m in currentVariants) {
      if (m is! Map) continue;
      final String cid = m['variant_category_id']?.toString() ?? '';
      final List<Map<String, dynamic>> items = [];

      if (m['variant'] is List) {
        for (var it in (m['variant'] as List)) {
          if (it is Map) {
            items.add({
              "variant_id": it['variant_id']?.toString() ?? '',
              "variant_price": _toIntSafe(it['variant_price'] ?? it['price']),
              "is_variant_customize": _toBoolSafe(it['is_variant_customize']),
            });
          }
        }
      } else if (m['variant_id'] is List) {
        for (var id in (m['variant_id'] as List)) {
          items.add({
            "variant_id": id.toString(),
            "variant_price": 0,
            "is_variant_customize": false,
          });
        }
      }
      if (items.isNotEmpty) {
        newApiVariants.add({"variant_category_id": cid, "variant": items});
      }
    }

    final int defPrice = (double.tryParse(variant.price) ?? 0).toInt();

    int catIndex = newApiVariants.indexWhere(
      (element) => element['variant_category_id'].toString() == catIdStr,
    );
    if (catIndex == -1) return;

    final items = List<Map<String, dynamic>>.from(
      (newApiVariants[catIndex]['variant'] as List? ?? []),
    );
    final int vIndex = items.indexWhere(
      (element) => element['variant_id'].toString() == varIdStr,
    );
    if (vIndex == -1) return;

    int currentPrice = _toIntSafe(items[vIndex]['variant_price']);
    final ctrl = TextEditingController(
      text: NumberFormat.decimalPattern('id').format(currentPrice),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setM) {
            return Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubah Harga Varian',
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    variant.name,
                    style: heading3(FontWeight.w400, bnw600, 'Outfit'),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      services.FilteringTextInputFormatter.digitsOnly,
                      RupiahInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      prefixText: 'Rp. ',
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                      setM(() {
                        currentPrice = digits.isEmpty
                            ? 0
                            : (int.tryParse(digits) ?? 0);
                      });
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setM(() {
                          currentPrice = defPrice;

                          ctrl.text = NumberFormat.decimalPattern(
                            'id',
                          ).format(defPrice);
                        });
                      },
                      child: Text('Reset ke harga normal'),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                      ),
                      onPressed: () {
                        items[vIndex]['variant_price'] = currentPrice;
                        items[vIndex]['is_variant_customize'] =
                            (currentPrice != defPrice);
                        _setCache(varIdStr, currentPrice, defPrice);

                        newApiVariants[catIndex]['variant'] = items;

                        final Map<String, int> customPriceById = {};
                        for (final c in newApiVariants) {
                          final vars = (c['variant'] as List? ?? []);
                          for (final vv in vars) {
                            if (vv is! Map) continue;
                            final id = vv['variant_id']?.toString() ?? '';
                            if (vv['is_variant_customize'] == true) {
                              customPriceById[id] = _toIntSafe(
                                vv['variant_price'],
                              );
                            }
                          }
                        }

                        List<Map<String, dynamic>> newUiVariants = [];
                        double newTotal = 0;

                        for (var c in allCategories) {
                          final sel = newApiVariants.firstWhere(
                            (element) =>
                                element['variant_category_id'].toString() ==
                                c.id.toString(),
                            orElse: () => {},
                          );
                          if (sel.isEmpty) continue;

                          final picked = (sel['variant'] as List? ?? []);
                          final ids = picked
                              .whereType<Map>()
                              .map((e) => e['variant_id']?.toString() ?? '')
                              .toList();

                          for (var pv in c.productVariants) {
                            final vid = pv.id.toString();
                            if (!ids.contains(vid)) continue;
                            final int def = (double.tryParse(pv.price) ?? 0)
                                .toInt();
                            final int used = customPriceById[vid] ?? def;

                            newTotal += used.toDouble();
                            newUiVariants.add({
                              "variant_id": pv.id,
                              "name": pv.name,
                              "price": used,
                            });
                          }
                        }

                        widget.onUpdateVariants(
                          widget.index,
                          newApiVariants,
                          newUiVariants,
                          newTotal,
                        );

                        Navigator.pop(context);
                      },
                      child: Text(
                        'Simpan',
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

  Widget _qtyBtn(bool isPlus, int currentQty, VoidCallback onTap) {
    Color btnColor = isPlus
        ? primary500
        : (currentQty > 1 ? primary500 : Colors.grey[300]!);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(isPlus ? Icons.add : Icons.remove, size: 16, color: bnw100),
      ),
    );
  }
}

// ---------------------------
// Screen 2, 3, 4: Payment Page
// ---------------------------
class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final String token;
  final String merchantId;
  final String? transactionId;
  final String? memberId; // Add memberId
  final double? finalAmount; // Amount from bill/calculating API
  final Map<String, dynamic>?
  billData; // Complete bill data for PPN, subtotal, etc.
  final VoidCallback? onSuccess;
  final DiscountModel? selectedDiscount;

  PaymentPage({
    Key? key,
    required this.cart,
    required this.token,
    required this.merchantId,
    this.transactionId,
    this.memberId,
    this.finalAmount,
    this.billData,
    this.onSuccess,
    this.selectedDiscount,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedMethod; // Initially null
  int _cashGiven = 0;
  final TextEditingController _cashController = TextEditingController();
  bool _isLoadingCalculation = true;
  bool _isProcessing = false;
  Map<String, dynamic>? _calculationData;
  DiscountModel? _selectedDiscount;

  List<dynamic> _paymentSubMethods = [];
  Map<String, dynamic>? _selectedSubMethod;
  bool _isLoadingSubMethods = false;

  final List<Map<String, dynamic>> _methods = [
    {
      'icon': PhosphorIcons.wallet_fill,
      'label': 'Uang Tunai',
      'desc': 'Bayar dengan uang fisik',
    },
    {
      'icon': PhosphorIcons.qr_code_fill,
      'label': 'Dompet Digital',
      'desc': 'Pindai kode batang (QR Code) untuk membayar',
    },
    {
      'icon': PhosphorIcons.credit_card_fill,
      'label': 'Kartu Kredit',
      'desc': 'Masukkan nomor kartu kredit',
    },
    {
      'icon': PhosphorIcons.cardholder_fill,
      'label': 'Kartu Debit',
      'desc': 'Masukkan nomor kartu debit',
    },
  ];

  @override
  void initState() {
    super.initState();

    print('=== PAYMENT PAGE INIT ===');
    print('Final Amount: ${widget.finalAmount}');
    print('Bill Data: ${widget.billData}');
    print('Transaction ID: ${widget.transactionId}');
    print('========================');

    _selectedDiscount = widget.selectedDiscount;

    // Skip calculating if finalAmount is already provided (from bill)
    if (widget.finalAmount != null &&
        !_hasCustomInCart &&
        _hasBreakdownEnough) {
      setState(() {
        _isLoadingCalculation = false;
      });
    } else {
      _fetchCalculation();
    }

    _cashController.addListener(() {
      String text = _cashController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isEmpty) text = '0';

      int val = int.parse(text);
      if (_cashGiven != val) {
        setState(() {
          _cashGiven = val;
        });
      }
    });
  }

  bool get _hasCustomInCart =>
      widget.cart.any((e) => e['is_customize'] == true);

  int _baseUsedFromItem(Map<String, dynamic> item) {
    final Product p = item['product'];
    final bool isOnline = item['is_online'] == true;
    final bool isCustomize = item['is_customize'] == true;
    final int? customAmount = item['custom_amount'] as int?;

    final int baseDefault = isOnline
        ? (p.onlinePrice)
        : (p.priceAfter ?? p.price);

    return (isCustomize && customAmount != null) ? customAmount : baseDefault;
  }

  int _variantTotalFromItem(Map<String, dynamic> item) {
    return (item['variant_total'] as num? ?? 0).toInt();
  }

  int _unitAmountFromItem(Map<String, dynamic> item) {
    final num? unit = item['unit_amount'] as num?;
    if (unit != null) return unit.round();
    return _baseUsedFromItem(item) + _variantTotalFromItem(item);
  }

  int _totalAmountFromItem(Map<String, dynamic> item) {
    final int qty = (item['quantity'] as int?) ?? 0;
    final num? total = item['total_amount'] as num?;
    if (total != null) return total.round();
    return _unitAmountFromItem(item) * qty;
  }

  Future<void> _fetchSubMethods(String categoryLabel) async {
    String category = '';
    if (categoryLabel == 'Dompet Digital')
      category = 'EWallet';
    else if (categoryLabel == 'Kartu Kredit')
      category = 'Credit';
    else if (categoryLabel == 'Kartu Debit')
      category = 'Debit';

    if (category.isEmpty) {
      setState(() {
        _paymentSubMethods = [];
        _selectedSubMethod = null;
      });
      return;
    }

    setState(() => _isLoadingSubMethods = true);

    try {
      final url = Uri.parse(getCoaMethodLink);
      final body = {"category": category};

      final response = await http.post(
        url,
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00') {
          setState(() {
            _paymentSubMethods = data['data'] ?? [];
            if (_paymentSubMethods.isNotEmpty) {
              _selectedSubMethod = _paymentSubMethods[0];
            } else {
              _selectedSubMethod = null;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching sub-methods: $e");
    } finally {
      setState(() => _isLoadingSubMethods = false);
    }
  }

  String? _calcError;
  Future<void> _fetchCalculation() async {
    setState(() {
      _isLoadingCalculation = true;
      _calcError = null;
      _calculationData = null;
    });
    try {
      final url = Uri.parse(calculateTransaksiUrl);
      print('=== CALCULATING API DEBUG 3===');

      // List<Map<String, dynamic>> details = widget.cart.map((item) {
      //   Product p = item['product'];

      //   final int baseUsed = _baseUsedFromItem(item);
      //   final bool isOnline = item['is_online'] == true;

      //   final bool isCustomize = item['is_customize'] == true;
      //   final List<dynamic> rawVariants = (item['variants'] ?? []) as List;

      //   final List<Map<String, dynamic>> variants = rawVariants.map((cat) {
      //     final String catId = cat['variant_category_id']?.toString() ?? '';

      //     final List<dynamic> rawVarList = (cat['variant'] ?? []) as List;

      //     final mappedVarList = rawVarList.map((v) {
      //       final Map<String, dynamic> mapped = {
      //         "variant_id": v['variant_id']?.toString() ?? '',
      //       };

      //       if (isCustomize) {
      //         final dynamic priceVal = v['variant_price'] ?? v['price'] ?? 0;

      //         mapped["variant_price"] = priceVal;
      //         mapped["is_variant_customize"] = true;
      //       }

      //       return mapped;
      //     }).toList();

      //     return {"variant_category_id": catId, "variant": mappedVarList};
      //   }).toList();

      //   return {
      //     "product_id": p.id,
      //     "name": p.name,
      //     "price": baseUsed,
      //     "quantity": item['quantity'],
      //     "description": item['notes'] ?? "",
      //     "is_online": isOnline,
      //     "variants": variants,
      //   };
      // }).toList();

      final details = buildTransactionDetails(
        widget.cart,
        mode: DetailMode.calculate,
      );

      final response = await http.post(
        url,
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "merchantid": widget.merchantId,
          "deviceid": identifier,
          "discount_id": _selectedDiscount?.id ?? "",
          "member_id": widget.memberId ?? "", // Use widget.memberId
          "transaction_id": "",
          "detail": details,
        }),
      );

      debugPrint('CALC status: ${response.statusCode}');
      debugPrint('CALC body: ${response.body}');

      if (response.statusCode != 200) {
        setState(() => _calcError = 'HTTP ${response.statusCode}');
        return;
      }

      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   setState(() {
      //     _calculationData = data;
      //     _isLoadingCalculation = false;
      //   });
      // } else {
      //   setState(() => _isLoadingCalculation = false);
      // }

      final json = jsonDecode(response.body);
      if (json['rc'] != '00' || json['data'] == null || json['data'] is! Map) {
        setState(() => _calcError = json['message'] ?? 'Gagal hitung total');
        return;
      }

      setState(() {
        _calculationData =
            (json['data'] as Map<String, dynamic>); // simpan hanya data-nya
      });
    } catch (e) {
      debugPrint("Error calculating: $e");
      setState(() => _calcError = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingCalculation = false);
    }
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final url = Uri.parse(createTransaksiUrl);
      final details = buildTransactionDetails(
        widget.cart,
        mode: DetailMode.create,
        quantityAsString: true,
      );

      final body = {
        "deviceid": identifier,
        "discount_id": _selectedDiscount?.id ?? "",
        "member_id": widget.memberId, // Use widget.memberId
        "transaction_id": widget.transactionId ?? "",
        "value": _selectedMethod == 'Uang Tunai' ? _cashGiven : _totalPay,
        "payment_method": _selectedMethod == 'Uang Tunai'
            ? "001"
            : (_selectedSubMethod?['idpaymentmethode'] ?? ""),
        "detail": details,
      };

      debugPrint("PAYMENT request: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('PAYMent status: ${response.statusCode}');
      debugPrint('PAYMEent body: ${response.body}');
      debugPrint('breakdown: $_breakdown');
      debugPrint('billdata raw: ${widget.billData}');
      debugPrint('ppn raw: ${_breakdown?['ppn']}');

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${response.statusCode}: ${response.body}'),
          ),
        );
        return;
      }

      final data = jsonDecode(response.body);
      if (data['rc'] == '00') {
        widget.onSuccess?.call();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionSuccessPage(
              data: data['data'],
              localCart: widget.cart,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal memproses transaksi'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  int get _subTotal {
    final b = _breakdown;
    final st = _toIntSafe(b?['total_before_dsc_tax']);
    if (st > 0) return st;

    return cartSubTotal(widget.cart);
  }

  int get _ppn {
    final b = _breakdown;
    return _toIntSafe(b?['ppn']);
  }

  int get _discount {
    if (widget.billData != null && widget.billData!['discount'] != null) {
      return (double.tryParse(widget.billData!['discount'].toString()) ?? 0)
          .toInt();
    }
    if (_calculationData != null && _calculationData!['data'] != null) {
      final data = _calculationData!['data'];
      if (data is Map<String, dynamic> && data['discount'] != null) {
        return (double.tryParse(data['discount'].toString()) ?? 0).toInt();
      }
    }
    return 0;
  }

  int get _totalPay {
    final b = _breakdown;

    final amt = _toIntSafe(b?['amount']);
    if (amt > 0) return amt;

    if (widget.finalAmount != null &&
        widget.finalAmount! > 0 &&
        !_hasCustomInCart) {
      return widget.finalAmount!.toInt();
    }
    return _subTotal + _ppn;
  }

  Map<String, dynamic>? get _breakdown {
    final bd = widget.billData;
    if (bd is Map<String, dynamic>) {
      final d = bd['data'];
      if (d is Map<String, dynamic>) return d;
      return bd;
    }

    if (_calculationData is Map<String, dynamic>) return _calculationData;
    return null;
  }

  bool get _hasBreakdownEnough {
    final b = _breakdown;
    if (b == null) return false;
    return b['amount'] != null &&
        b['ppn'] != null &&
        b['total_before_dsc_tax'] != null;
  }

  String get _customerName {
    final raw = widget.billData ?? _calculationData?['data'];
    if (raw != null) {
      final name =
          raw['customer_name'] ?? raw['customer'] ?? raw['name_customer'];
      if (name != null) return name.toString();
    }
    return 'Walking Customer';
  }

  void _showOrderDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bnw100,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rincian Pesanan',
                  style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(PhosphorIcons.x),
                ),
              ],
            ),
            Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.cart.length,
                itemBuilder: (context, index) {
                  final item = widget.cart[index];
                  final Product p = item['product'];
                  final int unitPrice = _unitAmountFromItem(item);
                  final bool isCustomize = item['is_customize'] == true;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: size8),
                    child: Row(
                      children: [
                        Text(
                          'x${item['quantity']}',
                          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        SizedBox(width: size12),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(size8),
                          ),
                          child: p.imageUrl != null
                              ? Image.network(p.imageUrl!, fit: BoxFit.cover)
                              : SvgPicture.asset('assets/logoProduct.svg'),
                        ),
                        SizedBox(width: size12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: heading2(
                                  FontWeight.w600,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                  locale: 'id',
                                  symbol: 'Rp. ',
                                  decimalDigits: 0,
                                ).format(unitPrice),
                                style: heading2(
                                  FontWeight.w600,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              if (isCustomize) ...[
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primary100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Custom',
                                    style: heading4(
                                      FontWeight.w600,
                                      primary500,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                              ],
                              if (p.discountType != null)
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp. ',
                                    decimalDigits: 0,
                                  ).format(p.price),
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontFamily: 'Outfit',
                                    color: bnw500,
                                    fontSize: sp12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary500,
                  padding: EdgeInsets.all(16),
                ),
                child: Text(
                  'Tutup',
                  style: TextStyle(color: bnw100, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      appBar: AppBar(
        title: Text(
          'Pembayaran',
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        backgroundColor: bnw100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rincian Pesanan',
                        style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      TextButton(
                        onPressed: _showOrderDetails,
                        child: Text(
                          'Lihat Rincian',
                          style: heading1(
                            FontWeight.w600,
                            primary500,
                            'Outfit',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size12),
                  // Discount Section
                  Text(
                    'Diskon',
                    style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: size8),
                  GestureDetector(
                    onTap: _showSelectDiscountModal,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedDiscount != null ? primary100 : bnw100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedDiscount != null
                              ? primary500
                              : bnw200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.tag_fill, color: bnw900, size: 40),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Voucher & Diskon',
                                  style: heading2(
                                    FontWeight.w600,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Text(
                                  _selectedDiscount != null
                                      ? _selectedDiscount!.name
                                      : 'Gunakan diskon untuk harga lebih murah',
                                  style: heading4(
                                    FontWeight.w400,
                                    bnw600,
                                    'Outfit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedDiscount != null)
                            Icon(
                              PhosphorIcons.check_circle_fill,
                              color: primary500,
                              size: 24,
                            )
                          else
                            Icon(Icons.chevron_right, color: bnw500),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size24),

                  Text(
                    'Metode Pembayaran',
                    style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: size12),
                  ...(_selectedMethod == null
                          ? _methods
                          : _methods.where(
                              (m) => m['label'] == _selectedMethod,
                            ))
                      .map((m) => _buildMethodCard(m))
                      .toList(),

                  if (_selectedMethod != null &&
                      _selectedMethod != 'Uang Tunai') ...[
                    SizedBox(height: 24),
                    Text(
                      'Pilih $_selectedMethod',
                      style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                    SizedBox(height: size12),
                    if (_isLoadingSubMethods)
                      Center(child: CircularProgressIndicator())
                    else if (_paymentSubMethods.isEmpty)
                      Text(
                        'Tidak ada metode tersedia',
                        style: heading3(FontWeight.w400, bnw600, 'Outfit'),
                      )
                    else
                      ..._paymentSubMethods
                          .map((sub) => _buildSubMethodCard(sub))
                          .toList(),
                  ],

                  if (_selectedMethod == 'Uang Tunai') ...[
                    SizedBox(height: 24),
                    Text(
                      'Uang Tunai',
                      style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                    ),
                    TextField(
                      controller: _cashController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                      decoration: InputDecoration(
                        hintText: 'Rp. 0',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primary500),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _quickMoneyBtn(50000)),
                        SizedBox(width: size8),
                        Expanded(child: _quickMoneyBtn(100000)),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _cashController.text =
                            CurrencyInputFormatter.format(_totalPay.toString()),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.all(size16),
                        ),
                        child: Text(
                          'Uang Pas',
                          style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
          if (_selectedMethod != null)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bnw100,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: _isLoadingCalculation
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rincian Pembayaran',
                          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                        ),
                        SizedBox(height: size16),
                        _rowSummary('Nama Pembeli', _customerName),
                        _rowSummary(
                          'Sub Total',
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp. ',
                            decimalDigits: 0,
                          ).format(_subTotal),
                        ),
                        if (_discount > 0)
                          _rowSummary(
                            'Diskon',
                            "- ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(_discount)}",
                            color: succes500,
                          ),
                        _rowSummary(
                          'PPN',
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp. ',
                            decimalDigits: 0,
                          ).format(_ppn),
                        ),
                        if (_cashGiven > _totalPay &&
                            _selectedMethod == 'Uang Tunai')
                          _rowSummary(
                            'Kembalian',
                            NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp. ',
                              decimalDigits: 0,
                            ).format(_cashGiven - _totalPay),
                            color: primary500,
                          ),
                        Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Bayar',
                                  style: heading3(
                                    FontWeight.w400,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp. ',
                                    decimalDigits: 0,
                                  ).format(_totalPay),
                                  style: heading1(
                                    FontWeight.w600,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed:
                                  (_isProcessing ||
                                      (_selectedMethod == 'Uang Tunai' &&
                                          _cashGiven < _totalPay) ||
                                      (_selectedMethod != 'Uang Tunai' &&
                                          _selectedSubMethod == null))
                                  ? null
                                  : _processPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary500,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                              ),
                              child: _isProcessing
                                  ? CircularProgressIndicator(color: bnw100)
                                  : Text(
                                      'Bayar',
                                      style: heading2(
                                        FontWeight.w600,
                                        bnw100,
                                        'Outfit',
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Widget _rowSummary(String label, String val, {Color? color}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: heading3(FontWeight.w400, bnw900, 'Outfit')),
          Text(
            val,
            style: heading3(FontWeight.w600, color ?? bnw900, 'Outfit'),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(Map<String, dynamic> method) {
    bool isSelected = _selectedMethod == method['label'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = (_selectedMethod == method['label'])
              ? null
              : method['label'];
          if (_selectedMethod != null) _fetchSubMethods(_selectedMethod!);
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: size12),
        padding: EdgeInsets.all(size12),
        decoration: BoxDecoration(
          color: isSelected ? primary100 : bnw100,
          borderRadius: BorderRadius.circular(size8),
          border: Border.all(color: isSelected ? primary500 : bnw200),
        ),
        child: Row(
          children: [
            Icon(method['icon'], color: bnw900, size: 40),
            SizedBox(width: size12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['label'],
                    style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  Text(
                    method['desc'],
                    style: heading4(FontWeight.w400, bnw600, 'Outfit'),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(PhosphorIcons.check_circle_fill, color: primary500),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMethodCard(Map<String, dynamic> sub) {
    bool isSelected =
        _selectedSubMethod?['idpaymentmethode'] == sub['idpaymentmethode'];
    return GestureDetector(
      onTap: () => setState(() => _selectedSubMethod = sub),
      child: Container(
        margin: EdgeInsets.only(bottom: size12),
        padding: EdgeInsets.all(size12),
        decoration: BoxDecoration(
          color: isSelected ? primary100 : bnw100,
          borderRadius: BorderRadius.circular(size8),
          border: Border.all(
            color: isSelected ? primary500 : bnw300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? primary300 : bnw100,
                borderRadius: BorderRadius.circular(size8),
              ),
              child: Icon(
                PhosphorIcons.wallet_fill,
                color: isSelected ? primary100 : bnw300,
              ),
            ),
            SizedBox(width: size12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub['payment_method'] ?? 'Unknown',
                    style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Pilih untuk membayar via ${sub['payment_method']}',
                    style: heading4(FontWeight.w400, bnw600, 'Outfit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickMoneyBtn(int amount) {
    return OutlinedButton(
      onPressed: () => _cashController.text = CurrencyInputFormatter.format(
        amount.toString(),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: size16),
      ),
      child: Text(
        NumberFormat.currency(
          locale: 'id',
          symbol: 'Rp. ',
          decimalDigits: 0,
        ).format(amount),
        style: heading3(FontWeight.w600, bnw900, 'Outfit'),
      ),
    );
  }

  void _showSelectDiscountModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        // 1. Initialize temporary state
        DiscountModel? tempSelected = _selectedDiscount;

        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bnw100,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
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
                      SizedBox(height: 20),
                      Text(
                        "Pilih Diskon Umum",
                        style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: FutureBuilder<List<DiscountModel>>(
                          future: _fetchDiscountsModal(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(
                                child: Text("Tidak ada diskon tersedia"),
                              );
                            }

                            final discounts = snapshot.data!;
                            return ListView.separated(
                              controller: scrollController,
                              itemCount: discounts.length,
                              separatorBuilder: (_, __) => SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final discount = discounts[index];
                                final isSelected =
                                    tempSelected?.id == discount.id;

                                // Formatted Value
                                String valueText = "";
                                if (discount.discountType == 'price') {
                                  valueText = NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(discount.discount);
                                } else {
                                  valueText = "${discount.discount}%";
                                }

                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      // Toggle temporary selection
                                      if (tempSelected?.id == discount.id) {
                                        tempSelected = null;
                                      } else {
                                        tempSelected = discount;
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? primary100 : bnw100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? primary500 : bnw300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          PhosphorIcons.tag_fill,
                                          color: primary500,
                                          size: 24,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                discount.name,
                                                style: heading3(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              Text(
                                                valueText,
                                                style: heading4(
                                                  FontWeight.w400,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              discount.date,
                                              style: body2(
                                                FontWeight.w400,
                                                bnw500,
                                                'Outfit',
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(
                                                Icons.check_circle,
                                                color: primary500,
                                                size: 20,
                                              )
                                            else
                                              Icon(
                                                Icons.circle_outlined,
                                                color: bnw300,
                                                size: 20,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
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
                          onPressed: () {
                            setState(() {
                              _selectedDiscount = tempSelected;
                            });
                            Navigator.pop(context);
                            _fetchCalculation();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary500,
                            padding: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Selesai',
                            style: TextStyle(
                              color: bnw100,
                              fontWeight: FontWeight.bold,
                            ),
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
      },
    );
  }

  Future<List<DiscountModel>> _fetchDiscountsModal() async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://unipos-dev-unipos-api-dev.yi8k7d.easypanel.host/api/discount",
        ),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({"order_by": "upDownNama"}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00' && data['data'] != null) {
          return (data['data'] as List)
              .map((e) => DiscountModel.fromJson(e))
              .where((d) => d.isActive && d.type == 'umum')
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching discounts: $e");
    }
    return [];
  }
}

class ProductDetailModal extends StatefulWidget {
  final Product product;
  final int? initialQty;
  final String? initialNotes;
  final Function(int qty, String notes) onAddToCart;

  ProductDetailModal({
    Key? key,
    required this.product,
    this.initialQty,
    this.initialNotes,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialQty != null) {
      _quantity = widget.initialQty!;
    }
    if (widget.initialNotes != null) {
      _notesController.text = widget.initialNotes!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bnw100,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
          SizedBox(height: 16),
          // Product Info
          Container(
            padding: EdgeInsets.all(size12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(size12),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(size8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      widget.product.imageUrl != null &&
                          widget.product.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              SvgPicture.asset('assets/logoProduct.svg'),
                        )
                      : Icon(Icons.coffee, size: 30, color: Colors.brown),
                ),
                SizedBox(width: size12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp. ',
                          decimalDigits: 0,
                        ).format(widget.product.price),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.product.category,
                        style: TextStyle(color: Colors.grey, fontSize: size12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Quantity Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jumlah',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  _buildQtyButton(false),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '$_quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildQtyButton(true),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          // Notes
          Text('Catatan', style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: size8),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Cth : Tambah ekstra topping Boba dan Gula 2 sendok',
              hintStyle: TextStyle(color: Colors.grey, fontSize: size12),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 24),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: primary500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size8),
                    ),
                  ),
                  child: Text(
                    'Batalkan',
                    style: TextStyle(
                      color: primary500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onAddToCart(_quantity, _notesController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary500,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size8),
                    ),
                  ),
                  child: Text(
                    'Tambah Ke Keranjang',
                    style: TextStyle(
                      color: bnw100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size8),
        ],
      ),
    );
  }

  Widget _buildQtyButton(bool isIncrement) {
    Color btnColor = isIncrement
        ? primary500
        : (_quantity > 1 ? primary500 : Colors.grey[300]!);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isIncrement) {
            _quantity++;
          } else if (_quantity > 1) {
            _quantity--;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          isIncrement ? Icons.add : Icons.remove,
          color: bnw100,
          size: 20,
        ),
      ),
    );
  }
}

class TransactionSuccessPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>>? localCart;

  TransactionSuccessPage({Key? key, required this.data, this.localCart})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract values from data
    final String customerName = data['customer_name'] ?? '-';
    final String paymentMethod =
        data['payment_name'] ?? data['payment_method'] ?? '-';
    final String transactionId =
        data['transactionid']?.toString() ??
        '-'; // Using transactionid from response
    final String cashier = data['pic_name'] ?? '-';
    final List<dynamic> details = data['detail'] ?? [];

    final int subTotal =
        int.tryParse(data['total_before_dsc_tax'].toString()) ?? 0;
    final int ppn = int.tryParse(data['ppn'].toString()) ?? 0;
    final int totalPay = int.tryParse(data['amount'].toString()) ?? 0;
    final int discount = int.tryParse(data['discount'].toString()) ?? 0;
    final int cashGiven = int.tryParse(data['money_paid'].toString()) ?? 0;
    final int change = int.tryParse(data['change_money'].toString()) ?? 0;

    return Scaffold(
      backgroundColor: bnw100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bnw100,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Transaksi Berhasil',
          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size16, vertical: size24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Informasi Pesanan",
                        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      SizedBox(height: size16),
                      _rowInfo("Nama Pembeli", customerName),
                      _rowInfo("Metode Pembayaran", paymentMethod),
                      _rowInfo(
                        "Nomor Pesanan",
                        transactionId,
                      ), // Updated to use real ID
                      _rowInfo("Kasir", cashier),
                      Divider(height: 32, thickness: 1),
                      Text(
                        "Rincian Pesanan",
                        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      SizedBox(height: size16),
                      ...details.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;

                        // Adapter for detail item
                        final String name =
                            item['shortname'] ?? item['name'] ?? 'Item';
                        final int qty =
                            int.tryParse(item['quantity'].toString()) ?? 0;
                        final int price =
                            int.tryParse(item['price'].toString()) ?? 0;
                        // notes might be in description or not present in this structure
                        final String notes =
                            item['description']?.toString() ?? '';

                        // Attempt to find variants from localCart
                        List<dynamic>? uiVariants;
                        if (localCart != null && index < localCart!.length) {
                          // Try to match basic properties if possible, or trust index
                          final localItem = localCart![index];
                          // Optional: check product name similarity?
                          // For now, index is safest assumption if flow is direct.
                          uiVariants = localItem['variants_ui'];
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: size12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "x$qty ",
                                style: heading2(
                                  FontWeight.w600,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              SizedBox(width: size8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          name,
                                          style: heading2(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp. ',
                                            decimalDigits: 0,
                                          ).format(
                                            int.tryParse(
                                                  item['amount']?.toString() ??
                                                      '0',
                                                ) ??
                                                price,
                                          ),
                                          style: heading2(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (item['discount_type'] != null)
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id',
                                          symbol: 'Rp. ',
                                          decimalDigits: 0,
                                        ).format(price),
                                        style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontFamily: 'Outfit',
                                          color: bnw500,
                                          fontSize: sp12,
                                        ),
                                      ),
                                    if (uiVariants != null &&
                                        uiVariants.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: uiVariants.map<Widget>((v) {
                                            return Text(
                                              "+ ${v['name']} (${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(v['amount'])})",
                                              style: heading4(
                                                FontWeight.w600,
                                                bnw600,
                                                'Outfit',
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    SizedBox(height: size12),
                                    if (notes.isNotEmpty)
                                      Text(
                                        "Catatan : $notes",
                                        style: heading4(
                                          FontWeight.w600,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      Divider(height: 32, thickness: 1),
                      _rowInfo(
                        "Sub Total",
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp. ',
                          decimalDigits: 0,
                        ).format(subTotal),
                      ),
                      _rowInfo(
                        "PPN",
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp. ',
                          decimalDigits: 0,
                        ).format(ppn),
                      ),
                      if (discount > 0)
                        _rowInfo(
                          "Diskon",
                          "- ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(discount)}",
                        ),
                      Divider(height: 32, thickness: 1),
                      _rowInfo(
                        "Uang Tunai",
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp. ',
                          decimalDigits: 0,
                        ).format(cashGiven),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Kembalian",
                            style: TextStyle(color: primary500),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp. ',
                              decimalDigits: 0,
                            ).format(change),
                            style: TextStyle(
                              color: primary500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Bayar",
                            style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp. ',
                              decimalDigits: 0,
                            ).format(totalPay),
                            style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.print, color: bnw100),
                  label: Text(
                    "Cetak Struk",
                    style: TextStyle(
                      color: bnw100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary500,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: primary500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size8),
                    ),
                  ),
                  child: Text(
                    "Kembali Ke Kasir",
                    style: TextStyle(
                      color: primary500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: size8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: heading3(FontWeight.w400, bnw900, 'Outfit')),
          Text(value, style: heading3(FontWeight.w600, bnw900, 'Outfit')),
        ],
      ),
    );
  }
}

class RupiahInputFormatter extends services.TextInputFormatter {
  final NumberFormat _nf = NumberFormat.decimalPattern('id');

  @override
  services.TextEditingValue formatEditUpdate(
    services.TextEditingValue oldValue,
    services.TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const services.TextEditingValue(
        text: '',
        selection: services.TextSelection.collapsed(offset: 0),
      );
    }
    final number = int.tryParse(digits) ?? 0;
    final formatted = _nf.format(number);

    return services.TextEditingValue(
      text: formatted,
      selection: services.TextSelection.collapsed(offset: formatted.length),
    );
  }
}
