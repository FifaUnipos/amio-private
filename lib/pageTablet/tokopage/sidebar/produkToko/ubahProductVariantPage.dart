import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/services/provider.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/utilities.dart';

class UbahProductVariantPage extends StatefulWidget {
  final String? token, merchantId;
  final PageController pageController;

  const UbahProductVariantPage({
    Key? key,
    required this.token,
    this.merchantId,
    required this.pageController,
  }) : super(key: key);

  @override
  _UbahProductVariantPageState createState() => _UbahProductVariantPageState();
}

class _UbahProductVariantPageState extends State<UbahProductVariantPage> {
  int? expandedIndex;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();

    // Ambil data dari provider saat halaman dibuka
    final provider = Provider.of<ProductVariantProvider>(
      context,
      listen: false,
    );

    // Kalau provider ada data dari API, map ke struktur categories
    if (provider.productVariants.isNotEmpty) {
      categories = _mapApiDataToCategories(provider.productVariants);
    } else {
      // Kosongkan supaya nanti muncul teks "Belum ada product variant"
      categories = [];
    }
  }

  void formatInputRp(TextEditingController controller, String text) {
    String cleanText = text.replaceAll('.', '');
    int value = int.tryParse(cleanText) ?? 0;
    String formattedAmount = formatCurrency(value);
    controller.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  // 🔹 Konversi response API ke struktur categories
  List<Map<String, dynamic>> _mapApiDataToCategories(List<dynamic> apiData) {
    return apiData.map<Map<String, dynamic>>((cat) {
      return {
        'title': cat['title'] ?? 'Unnamed Category',
        'maximumSelect': cat['maximum_selected'] ?? 1,
        'displayInCasir': (cat['is_active'] ?? 1) == 1,
        'isRequired': (cat['is_required'] ?? 0) == 1,
        'variants': (cat['product_variants'] as List<dynamic>? ?? [])
            .map<Map<String, dynamic>>((variant) {
              final name = variant['name'] ?? '';
              final price = double.tryParse('${variant['price'] ?? 0}') ?? 0.0;
              return {
                'variantName': name,
                'price': price,
                'priceOnline':
                    double.tryParse(
                      '${variant['price_online_shop'] ?? variant['price'] ?? 0}',
                    ) ??
                    0.0,
                'displayInCasir': (variant['is_active'] ?? 1) == 1,
                'controllerVariantName': TextEditingController(text: name),
                'controllerVariantPrice': TextEditingController(
                  text: price.toString(),
                ),
              };
            })
            .toList(),
      };
    }).toList();
  }

  // 🔹 Tambah kategori baru
  void _addCategory() {
    setState(() {
      categories.add({
        'title': 'Kategori Baru',
        'maximumSelect': 1,
        'displayInCasir': true,
        'isRequired': false,
        'variants': [],
      });
    });
  }

  // 🔹 Tambah varian baru ke kategori tertentu
  void _addVariant(int categoryIndex) {
    setState(() {
      categories[categoryIndex]['variants'].add({
        'variantName': '',
        'price': 0.0,
        'priceOnline': 0.0,
        'displayInCasir': false,
        'controllerVariantName': TextEditingController(),
        'controllerVariantPrice': TextEditingController(),
      });
    });
  }

  // 🔹 Hapus varian
  void _removeVariant(int categoryIndex, int variantIndex) {
    setState(() {
      categories[categoryIndex]['variants'].removeAt(variantIndex);
    });
  }

  // 🔹 Hapus kategori
  void _removeCategory(int index) {
    setState(() {
      categories.removeAt(index);
    });
  }

  // 🔹 Buat array untuk dikirim ke API
  List<Map<String, dynamic>> generateArrayData() {
    return categories.map((category) {
      return {
        "id": null,
        "title": category['title'] ?? 'Unnamed Category',
        "max_selected": category['maximumSelect'],
        "is_active": category['displayInCasir'] ? 1 : 0,
        "is_required": category['isRequired'] ? 1 : 0,
        "product_variant": category['variants'].map((variant) {
          return {
            "id": null,
            "name": variant['variantName'] ?? 'Unnamed Variant',
            "shortname":
                (variant['variantName']?.substring(
                  0,
                  min(12, variant['variantName']?.length ?? 0),
                )) ??
                'Shortname',
            "price": variant['price'],
            "price_online_shop": variant['priceOnline'],
            "is_active": variant['displayInCasir'] ? 1 : 0,
          };
        }).toList(),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Header
        Row(
          children: [
            GestureDetector(
              onTap: () => widget.pageController.jumpToPage(0),
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
                  'Produk Variant',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Variant akan ditambahkan ke produk terpilih',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size16),

        // 🔹 Body
        Expanded(
          child: categories.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada product variant",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    var category = categories[index];
                    bool isExpanded = expandedIndex == index;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              "Kategori Variant #${index + 1}",
                              style: heading2(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _removeCategory(index),
                                  child: Icon(Icons.close, color: danger500),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                expandedIndex = isExpanded ? null : index;
                              });
                            },
                          ),

                          // 🔹 Expanded Body
                          if (isExpanded)
                            Padding(
                              padding: EdgeInsets.all(size12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  _buildTextField(
                                    label: "Judul Kategori *",
                                    initialValue: category['title'],
                                    hint: "Contoh: Takaran Gula",
                                    onChanged: (val) => category['title'] = val,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildTextField(
                                    label: "Maximum Select *",
                                    initialValue: category['maximumSelect']
                                        .toString(),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) =>
                                        category['maximumSelect'] =
                                            int.tryParse(val) ?? 1,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSwitch(
                                    label: "Tampilkan di kasir *",
                                    value: category['displayInCasir'],
                                    onChanged: (val) => setState(
                                      () => category['displayInCasir'] = val,
                                    ),
                                  ),
                                  _buildSwitch(
                                    label: "Wajib diisikan *",
                                    value: category['isRequired'],
                                    onChanged: (val) => setState(
                                      () => category['isRequired'] = val,
                                    ),
                                  ),
                                  const Divider(),
                                  Text(
                                    "Variant",
                                    style: heading2(
                                      FontWeight.w600,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // 🔹 Daftar Varian
                                  for (
                                    int v = 0;
                                    v < category['variants'].length;
                                    v++
                                  )
                                    _buildVariantCard(index, v),

                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: () => _addVariant(index),
                                    child: const Text("Tambah Variant"),
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

        // 🔹 Footer Buttons
        SizedBox(height: size12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _addCategory,
                child: buttonXLoutline(
                  Center(
                    child: Text(
                      'Tambah Kategori Variant',
                      style: heading3(FontWeight.w600, primary600, 'Outfit'),
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
                onTap: () {
                  List<Map<String, dynamic>> arrayResult = generateArrayData();
                  print(arrayResult);
                  createProductVariant(
                    context,
                    widget.token,
                    widget.merchantId ?? '',
                    productIdVariant,
                    arrayResult,
                  ).then((value) {
                    if (value == "00") {
                      widget.pageController.jumpToPage(0);
                      productIdVariant = '';
                    }
                  });
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
        ),
      ],
    );
  }

  // 🔹 Helper Widget Builders
  Widget _buildTextField({
    required String label,
    String? initialValue,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: heading3(FontWeight.w500, bnw900, 'Outfit')),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Text(label, style: heading4(FontWeight.w500, bnw900, 'Outfit')),
        const Spacer(),
        Switch(activeColor: primary500, value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildVariantCard(int categoryIndex, int variantIndex) {
    var variant = categories[categoryIndex]['variants'][variantIndex];
    return Card(
      color: bnw100,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(size12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Nama Varian *",
                  style: heading3(FontWeight.w500, bnw900, 'Outfit'),
                ),
                GestureDetector(
                  onTap: () => _removeVariant(categoryIndex, variantIndex),
                  child: Text(
                    "Hapus",
                    style: TextStyle(
                      color: danger500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: variant['controllerVariantName'],
              decoration: const InputDecoration(
                hintText: "Contoh: Roti Biasa",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => variant['variantName'] = val,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: variant['controllerVariantPrice'],

                    decoration: const InputDecoration(
                      labelText: "Harga *",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      formatInputRp(variant['controllerVariantPrice'], val);

                      // Parse nilai bersih (tanpa titik/pemisah ribuan)
                      String cleanValue = val.replaceAll(RegExp(r'[^0-9]'), '');
                      double parsedPrice = double.tryParse(cleanValue) ?? 0.0;
                      variant['price'] = parsedPrice;
                    },
                  ),
                ),
                // const SizedBox(width: 8),
                // Expanded(
                //   child: TextFormField(
                //     decoration: const InputDecoration(
                //       labelText: "Harga Online *",
                //       border: OutlineInputBorder(),
                //     ),
                //     keyboardType: TextInputType.number,
                //     onChanged: (val) {
                //       formatInputRp(variant['controllerVariantPrice'], val);
                //       variant['priceOnline'] = double.tryParse(val) ?? 0.0;
                //     },
                //   ),
                // ),
              ],
            ),
            _buildSwitch(
              label: "Tampilkan di kasir *",
              value: variant['displayInCasir'],
              onChanged: (val) =>
                  setState(() => variant['displayInCasir'] = val),
            ),
          ],
        ),
      ),
    );
  }
}
