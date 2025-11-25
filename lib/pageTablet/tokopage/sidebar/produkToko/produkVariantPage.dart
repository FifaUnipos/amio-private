import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'dart:convert'; // For JSON encoding
import 'dart:math';

import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart'; // For min function

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
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, categoryIndex) {
              final category = categories[categoryIndex];
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ExpansionTile(
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    childrenPadding: EdgeInsets.all(size12),
                    // tilePadding: EdgeInsets.all(size12),
                    title: Text(
                      "Kategori Variant #${categoryIndex + 1}",
                      style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                    trailing: IconButton(
                      icon: Icon(PhosphorIcons.trash_fill),
                      onPressed: () => _removeCategory(categoryIndex),
                    ),
                    children: [
                      // Using the fieldAddProduk function for category input fields
                      fieldAddProduk(
                        'Judul Kategori',
                        'Takaran Gula',
                        category['controllerNameEdit'],
                        TextInputType.text,
                        (value) {
                          setState(() {
                            category['categoryName'] =
                                value; // Update category name
                          });
                        },
                      ),
                      SizedBox(height: size12),
                      fieldAddProduk(
                        'Maximum Select',
                        '1',
                        category['controllerMaxSelect'],
                        TextInputType.number,
                        (value) {
                          setState(() {
                            category['maxSelect'] =
                                int.tryParse(value) ?? 1; // Update maxSelect
                          });
                        },
                      ),
                      Column(
                        children: [
                          SwitchListTile(
                            activeColor: primary500,
                            title: Text(
                              "Tampilkan Di Kasir",
                              style: body1(FontWeight.w500, bnw900, 'Outfit'),
                            ),
                            value: category['is_active'],
                            onChanged: (value) {
                              setState(() {
                                category['is_active'] = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            activeColor: primary500,
                            title: Text(
                              "Wajib Diisi",
                              style: body1(FontWeight.w500, bnw900, 'Outfit'),
                            ),
                            value: category['isRequired'],
                            onChanged: (value) {
                              setState(() {
                                category['isRequired'] = value;
                              });
                            },
                          ),
                          SizedBox(height: size12),
                        ],
                      ),
                      Divider(),
                      Text("Variants"),
                      SizedBox(height: size12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics:
                            NeverScrollableScrollPhysics(), // Prevent double scroll
                        itemCount: category['variants'].length,
                        itemBuilder: (context, variantIndex) {
                          final variant = category['variants'][variantIndex];
                          return ListTile(
                            title: fieldAddProduk(
                              'Nama Variant',
                              'Takran Gula 1',
                              variant['controllerVariantName'],
                              TextInputType.text,
                              (value) {
                                setState(() {
                                  variant['variantName'] =
                                      value; // Update variant name
                                });
                              },
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size12),
                                fieldAddProduk(
                                  'Harga Variant',
                                  '5.000',
                                  variant['controllerVariantPrice'],
                                  TextInputType.number,
                                  (value) {
                                    setState(() {
                                      variant['price'] =
                                          double.tryParse(value) ??
                                          0.0; // Update price
                                    });
                                  },
                                ),
                                SwitchListTile(
                                  activeColor: primary500,
                                  title: Text("Tampilkan di kasir"),
                                  value: variant['displayInCasir'],
                                  onChanged: (value) {
                                    setState(() {
                                      variant['displayInCasir'] = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _removeVariant(categoryIndex, variantIndex);
                              },
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () => _addVariant(categoryIndex),
                        child: SizedBox(
                          width: double.infinity,
                          child: buttonXLoutline(
                            Center(
                              child: Text(
                                "Tambah Variant",
                                style: heading3(
                                  FontWeight.w600,
                                  primary600,
                                  'Outfit',
                                ),
                              ),
                            ),
                            double.infinity,
                            primary500,
                          ),
                        ),
                      ),
                    ],
                  ),
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
}
