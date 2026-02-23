import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/pageMobile/promoPageMobile/discount_model.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'promoPageMobile.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/currency_formatter.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

class AddPromoPageMobile extends StatefulWidget {
  final String token;
  final String merchantId;
  final DiscountModel? editDiscount; // If null, create mode

  const AddPromoPageMobile({
    Key? key,
    required this.token,
    required this.merchantId,
    this.editDiscount,
  }) : super(key: key);

  @override
  State<AddPromoPageMobile> createState() => _AddPromoPageMobileState();
}

class _AddPromoPageMobileState extends State<AddPromoPageMobile> {
  // Constants
  final String _createUrl = createDiskonLink;
  final String _updateUrl = updateDiskonLink;
  final String _getProductsUrl = getProdukDiskonLink;
  final String _showUrl = getSingleDiskonLink;

  // Form State
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _productSelectionController =
      TextEditingController();

  String _type = 'Umum'; // Umum | Per Produk
  String _valueType = 'Rupiah'; // Rupiah | Persen
  String _activePeriod = 'Selamanya'; // Selamanya | Kustom Waktu
  bool _isActive = true;

  // Product Selection State
  List<DiscountProductModel> _allProducts = [];
  List<DiscountProductModel> _selectedProducts = [];
  bool _isLoadingProducts = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editDiscount != null) {
      _loadEditData();
    }
    // Prefetch products if needed or just wait until "Per Produk" is selected?
    // Let's prefetch to be safe if editing Per Produk
  }

  Future<void> _loadEditData() async {
    _nameController.text = widget.editDiscount!.name;

    // Fetch detailed data
    try {
      final response = await http.post(
        Uri.parse(_showUrl),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({"id": widget.editDiscount!.id}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00') {
          final d = data['data'];
          // Update State
          setState(() {
            _nameController.text = d['name'];
            _valueController.text = d['discount']?.toString() ?? '0';
            _type = (d['type'] == 'per_produk') ? 'Per Produk' : 'Umum';
            _valueType = (d['discount_type'] == 'percentage')
                ? 'Persen'
                : 'Rupiah';
            _isActive =
                d['is_active'] ==
                true; // API might return bool or string "true" logic check needed if string

            if (d['start_date'] != null &&
                d['start_date'].toString().isNotEmpty &&
                d['start_date'] != '0000-00-00') {
              _activePeriod = 'Kustom Waktu';
              _startDateController.text = d['start_date'];
              _endDateController.text = d['end_date'];
            } else {
              _activePeriod = 'Selamanya';
            }

            // Load Products
            if (_type == 'Per Produk') {
              if (d['products'] != null) {
                // We need to fetch ALL products first, then mark selected.
                _fetchProducts(initialSelection: (d['products'] as List));
              } else {
                _fetchProducts();
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading edit data: $e");
    }
  }

  Future<void> _fetchProducts({List<dynamic>? initialSelection}) async {
    setState(() => _isLoadingProducts = true);
    try {
      final response = await http.post(
        Uri.parse(_getProductsUrl),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({"merchantid": ""}), // Empty per instructions
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == '00' && data['data'] != null) {
          List<DiscountProductModel> loaded = (data['data']['products'] as List)
              .map((e) => DiscountProductModel.fromJson(e))
              .toList();

          setState(() {
            _allProducts = loaded;

            if (initialSelection != null) {
              // Mark selected
              List<String> selectedIds = initialSelection
                  .map((e) => e['productid'].toString())
                  .toList();
              for (var p in _allProducts) {
                if (selectedIds.contains(p.productId)) {
                  p.isSelected = true;
                  _selectedProducts.add(p);
                }
              }
              _updateProductSelectionText();
            }
            _isLoadingProducts = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
      setState(() => _isLoadingProducts = false);
    }
  }

  void _updateProductSelectionText() {
    if (_selectedProducts.isEmpty) {
      _productSelectionController.text = "";
    } else {
      _productSelectionController.text =
          "${_selectedProducts.length} Produk Terpilih";
    }
  }

  Future<void> _showProductSelector() async {
    if (_allProducts.isEmpty) {
      await _fetchProducts();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.all(16),
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
                    "Pilih Produk",
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Cari nama produk",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (val) {
                      // Optional: Implement Client-side Search
                    },
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _allProducts.length,
                      separatorBuilder: (ctx, i) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final product = _allProducts[index];
                        // Check if product is available
                        // It is unavailable if it has a discount_status AND (we are creating NEW promo OR it belongs to a DIFFERENT promo)
                        bool isUnavailable =
                            product.discountStatus.isNotEmpty &&
                            (widget.editDiscount == null ||
                                product.discountId != widget.editDiscount!.id);

                        return CheckboxListTile(
                          title: Text(
                            product.name,
                            style: isUnavailable
                                ? heading3(
                                    FontWeight.w600,
                                    Colors.grey,
                                    'Outfit',
                                  )
                                : heading3(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                FormatCurrency.convertToIdr(product.price),
                                style: body2(FontWeight.w400, bnw500, 'Outfit'),
                              ),
                              if (isUnavailable)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    product.discountStatus,
                                    style: body2(
                                      FontWeight.w400,
                                      Colors.red,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          value: isUnavailable ? false : product.isSelected,
                          activeColor: primary500,
                          onChanged: isUnavailable
                              ? null
                              : (val) {
                                  setStateDialog(() {
                                    product.isSelected = val ?? false;
                                  });
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
                          _selectedProducts = _allProducts
                              .where((p) => p.isSelected)
                              .toList();
                          _updateProductSelectionText();
                        });
                        Navigator.pop(context);
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
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveDiscount() async {
    if (!_formKey.currentState!.validate()) return;
    if (_type == 'Per Produk' && _selectedProducts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Pilih minimal satu produk")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final url = widget.editDiscount == null ? _createUrl : _updateUrl;

      // Serialize Product IDs
      // If "Umum", send empty array "[]", if "Per Produk", send actual IDs.
      String productIdsString;
      if (_type == 'Per Produk') {
        List<String> ids = _selectedProducts.map((p) => p.productId).toList();
        productIdsString = jsonEncode(ids); // "[\"id1\",\"id2\"]"
      } else {
        productIdsString = "[]"; // Empty array as string
      }

      final body = {
        if (widget.editDiscount != null) "id": widget.editDiscount!.id,
        "merchantid": widget.merchantId,
        "productid": productIdsString,
        "name": _nameController.text,
        "discount": _valueController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        "discount_type": _valueType == 'Persen' ? 'percentage' : 'price',
        "start_date": _activePeriod == 'Kustom Waktu'
            ? _startDateController.text
            : "",
        "end_date": _activePeriod == 'Kustom Waktu'
            ? _endDateController.text
            : "",
        "is_active": _isActive.toString(),
        "active_period": _activePeriod == 'Selamanya' ? 'forever' : 'range',
      };

      print("Sending Discount Data: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00') {
          Navigator.pop(context); // Success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Gagal menyimpan")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("Error saving discount: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      appBar: AppBar(
        title: Text(
          widget.editDiscount == null ? "Tambah Promo" : "Ubah Promo",
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: bnw100,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Tipe Diskon *"),
              Row(
                children: [
                  Expanded(
                    child: _buildSelectCard(
                      "Umum",
                      _type == "Umum",
                      PhosphorIcons.squares_four_fill,
                      () => setState(() => _type = "Umum"),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildSelectCard(
                      "Per Produk",
                      _type == "Per Produk",
                      PhosphorIcons.shopping_bag_fill,
                      () {
                        setState(() => _type = "Per Produk");
                        // Optionally prefetch here
                        if (_allProducts.isEmpty) _fetchProducts();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              if (_type == "Per Produk") ...[
                _buildLabel("Produk *"),
                GestureDetector(
                  onTap: _showProductSelector,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _productSelectionController,
                      decoration: InputDecoration(
                        hintText: "Pilih Produk",
                        suffixIcon: Icon(Icons.keyboard_arrow_down),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (val) =>
                          _type == "Per Produk" && _selectedProducts.isEmpty
                          ? "Wajib pilih produk"
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],

              _buildLabel("Nama Diskon *"),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Contoh: Diskon Tahun Baru",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Nama wajib diisi" : null,
              ),
              SizedBox(height: 16),

              _buildLabel("Harga Diskon *"),
              Row(
                children: [
                  Expanded(
                    child: _buildSelectCard(
                      "Rupiah",
                      _valueType == "Rupiah",
                      PhosphorIcons.money_fill,
                      () => setState(() => _valueType = "Rupiah"),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildSelectCard(
                      "Persen",
                      _valueType == "Persen",
                      PhosphorIcons.percent,
                      () => setState(() => _valueType = "Persen"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (_valueType == "Rupiah")
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  decoration: InputDecoration(
                    prefixText: "Rp ",
                    hintText: "0",
                    border: UnderlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Nilai wajib diisi" : null,
                ),
              if (_valueType == "Persen")
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  // inputFormatters: [CurrencyInputFormatter()],
                  decoration: InputDecoration(
                    prefixIcon: Icon(PhosphorIcons.percent, color: bnw900),
                    suffixText: '%',
                    hintText: "0",
                    border: UnderlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Nilai wajib diisi" : null,
                ),

              SizedBox(height: 16),

              _buildLabel("Masa Aktif Diskon *"),
              Column(
                children: [
                  _buildPeriodSelector(
                    "Selamanya",
                    _activePeriod == "Selamanya",
                    PhosphorIcons.hourglass_high_fill,
                    () => setState(() => _activePeriod = "Selamanya"),
                  ),
                  SizedBox(height: 8),
                  _buildPeriodSelector(
                    "Kustom Waktu",
                    _activePeriod == "Kustom Waktu",
                    PhosphorIcons.timer_fill,
                    () => setState(() => _activePeriod = "Kustom Waktu"),
                  ),
                ],
              ),

              if (_activePeriod == "Kustom Waktu") ...[
                SizedBox(height: 16),
                _buildLabel("Waktu Mulai *"),
                GestureDetector(
                  onTap: () => _selectDate(_startDateController),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: InputDecoration(
                        hintText: "Pilih Tanggal",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: Icon(Icons.keyboard_arrow_down),
                      ),
                      validator: (val) =>
                          _activePeriod == "Kustom Waktu" &&
                              (val == null || val.isEmpty)
                          ? "Wajib diisi"
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                _buildLabel("Waktu Berakhir *"),
                GestureDetector(
                  onTap: () => _selectDate(_endDateController),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _endDateController,
                      decoration: InputDecoration(
                        hintText: "Pilih Tanggal",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: Icon(Icons.keyboard_arrow_down),
                      ),
                      validator: (val) =>
                          _activePeriod == "Kustom Waktu" &&
                              (val == null || val.isEmpty)
                          ? "Wajib diisi"
                          : null,
                    ),
                  ),
                ),
              ],

              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status Diskon",
                        style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      Text(
                        _isActive ? "Aktif" : "Tidak Aktif",
                        style: body2(FontWeight.w400, bnw600, 'Outfit'),
                      ),
                    ],
                  ),

                  Switch(
                    value: _isActive,
                    activeColor: primary500,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ],
              ),

              SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              await _saveDiscount();
                              if (mounted) {
                                _nameController.clear();
                                _valueController.clear();
                                _startDateController.clear();
                                _endDateController.clear();
                                _selectedProducts.clear();
                                _updateProductSelectionText();
                                setState(() {
                                  _type = 'Umum';
                                  _activePeriod = 'Selamanya';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Berhasil disimpan, silahkan tambah baru",
                                    ),
                                  ),
                                );
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: primary500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Simpan & Tambah Baru",
                        style: heading3(FontWeight.w600, primary500, 'Outfit'),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveDiscount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.editDiscount == null ? "Tambah" : "Simpan",
                        style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text.replaceAll('*', ''),
          style: heading3(FontWeight.w500, bnw900, 'Outfit'),
          children: [
            if (text.contains('*'))
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectCard(
    String label,
    bool isSelected,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? primary100 : bnw100,
          border: Border.all(color: isSelected ? primary500 : bnw300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primary500 : bnw900,
                fontWeight: FontWeight.w400,
                fontFamily: 'Outfit',
              ),
            ),
            Icon(icon, size: 20, color: isSelected ? primary500 : bnw500),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(
    String label,
    bool isSelected,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? primary100 : bnw100,
          border: Border.all(color: isSelected ? primary500 : bnw300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primary500 : bnw900,
                fontWeight: FontWeight.w400,
                fontFamily: 'Outfit',
              ),
            ),
            Spacer(),
            Icon(icon, size: 20, color: isSelected ? primary500 : bnw900),
          ],
        ),
      ),
    );
  }
}
