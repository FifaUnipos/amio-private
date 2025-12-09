import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'dart:convert'; // For JSON encoding
import 'dart:math';

import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/utilities.dart'; // For min function

class ProductVariantPage extends StatefulWidget {
  String? token, merchantId;
  PageController? pageController;
  ProductVariantPage({
    Key? key,
    required this.token,
    this.merchantId,
    this.pageController,
  }) : super(key: key);

  @override
  _ProductVariantPageState createState() => _ProductVariantPageState();
}

class _ProductVariantPageState extends State<ProductVariantPage> {
  // List to hold the categories and variants
  List<Map<String, dynamic>> categories = [];
  int? expandedIndex;

  // Function to add a new category
  void _addCategory() {
    setState(() {
      categories.add({
        'categoryName': '',
        'maxSelect': 1,
        'is_active': true,
        'isRequired': false,
        'variants': [],
        'controllerNameEdit':
            TextEditingController(), // Controller for category name
        'controllerMaxSelect':
            TextEditingController(), // Controller for max select
      });
    });
  }

  void formatInputRp(TextEditingController controller, String text) {
    String cleanText = text.replaceAll('.', ''); // Bersihkan titik sebelumnya
    int value = int.tryParse(cleanText) ?? 0;
    String formattedAmount = formatCurrency(
      value,
    ); // Gunakan fungsi yang sudah ada
    controller.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  // Function to add a new variant to a category
  void _addVariant(int categoryIndex) {
    setState(() {
      categories[categoryIndex]['variants'].add({
        'variantName': '',
        'price': 0.0,
        'displayInCasir': false,
        'controllerVariantName':
            TextEditingController(), // Controller for variant name
        'controllerVariantPrice':
            TextEditingController(), // Controller for variant price
        'isActive': false, // Optional flag for variant activity
        'isRequired': false, // Optional flag for variant required status
      });
    });
  }

  // Function to remove a category
  void _removeCategory(int categoryIndex) {
    setState(() {
      categories[categoryIndex]['controllerNameEdit'].dispose();
      categories[categoryIndex]['controllerMaxSelect'].dispose();
      categories.removeAt(categoryIndex);
    });
  }

  // Function to remove a variant
  void _removeVariant(int categoryIndex, int variantIndex) {
    setState(() {
      categories[categoryIndex]['variants'][variantIndex]['controllerVariantName']
          .dispose();
      categories[categoryIndex]['variants'][variantIndex]['controllerVariantPrice']
          .dispose();
      categories[categoryIndex]['variants'].removeAt(variantIndex);
    });
  }

  // Custom field for input fields
  Widget fieldAddProduk(
    String title,
    String hint,
    TextEditingController myController,
    TextInputType keyboardType,
    Function(String) onChanged,
  ) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: body1(FontWeight.w500, bnw900, 'Outfit')),
              Text(' *', style: body1(FontWeight.w700, red500, 'Outfit')),
            ],
          ),
          IntrinsicHeight(
            child: TextFormField(
              cursorColor: Colors.blue, // primary500 color
              keyboardType: keyboardType,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 16,
              ),
              controller: myController,
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.blue,
                  ), // primary500 color
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.5,
                    color: Colors.grey,
                  ), // bnw500 color
                ),
                hintText: 'Cth : $hint',
                hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // Function to generate JSON data
  List<Map<String, dynamic>> generateArrayData() {
    List<Map<String, dynamic>> jsonData = categories.map((category) {
      return {
        "id": null,
        "title": category['categoryName'] ?? 'Unnamed Category',
        "max_selected": category['maxSelect'],
        "is_active": true,
        "is_required": category['isRequired'],
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
            "price_online_shop": variant['price'],
            "is_active": variant['isActive'], // Optional field
          };
        }).toList(),
      };
    }).toList();

    return jsonData; // Return the array (not string)
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                // refreshDataProduk();

                // getDataProduk(['']);

                widget.pageController?.jumpToPage(0);
              },
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
                  'Variant akan ditambahkan kedalam Produk yang telah dipilih',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size16),
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
                                    initialValue:
                                        category['categoryName'] ?? '',
                                    hint: "Contoh: Takaran Gula",
                                    onChanged: (val) =>
                                        category['categoryName'] = val,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildTextField(
                                    label: "Maximum Select *",
                                    initialValue: '1',
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) =>
                                        category['controllerMaxSelect'] =
                                            int.tryParse(val) ?? 1,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSwitch(
                                    label: "Tampilkan di kasir *",
                                    value: category['is_active'],

                                    onChanged: (val) => setState(
                                      () => category['is_active'] = val,
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
        SizedBox(height: size16),
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
                  // print(arrayResult);
                  createProductVariant(
                    context,
                    widget.token,
                    widget.merchantId ?? '',
                    productIdVariant,
                    arrayResult,
                  ).then((value) {
                    if (value == "00") {
                      widget.pageController?.jumpToPage(0);
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
