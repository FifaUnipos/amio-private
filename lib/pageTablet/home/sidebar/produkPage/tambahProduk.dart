import 'dart:developer';

import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../models/tokomodel.dart';
import '../../../../services/checkConnection.dart';

import '../../../tokopage/sidebar/produkToko/produk.dart';import '../../../../utils/component/component_button.dart';import '../../../../utils/component/component_color.dart';

class TambahProdukPage extends StatefulWidget {
  String name;
  List<ModelDataToko> datas;
  PageController pageController;
  TambahProdukPage({
    Key? key,
    required this.name,
    required this.datas,
    required this.pageController,
  }) : super(key: key);

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  @override
  Widget build(BuildContext context) {
    String name = widget.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    widget.pageController.jumpTo(0);
                  },
                  child: Icon(
                    PhosphorIcons.arrow_left,
                    size: size48,
                    color: bnw900,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    Text(
                      'Produk',
                      style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                searchField(
                  200,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(PhosphorIcons.magnifying_glass),
                      Text(
                        'Cari nama produk',
                        style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(size12),
                  margin: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: primary500),
                    borderRadius: BorderRadius.circular(size8),
                  ),
                  child: Icon(PhosphorIcons.files_fill, color: primary500),
                ),
                GestureDetector(
                  child: buttonXL(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(PhosphorIcons.plus, color: bnw100),
                        Text(
                          'Produk',
                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                        )
                      ],
                    ),
                    140,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size12),
        Row(
          children: [
            buttonLoutline(
              GestureDetector(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Urutkan',
                          style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        Text(
                          ' dari Nama Toko A ke Z',
                          style: heading3(FontWeight.w400, bnw600, 'Outfit'),
                        ),
                      ],
                    ),
                    Icon(PhosphorIcons.caret_down),
                  ],
                ),
              ),
              bnw300,
            ),
          ],
        ),
        SizedBox(height: size12),
        Expanded(
          child: CheckBoxLihatProduk(
            datas: widget.datas,
          ),
        )
      ],
    );
  }
}

class CheckBoxLihatProduk extends StatefulWidget {
  List<ModelDataToko>? datas;
  CheckBoxLihatProduk({
    Key? key,
    required this.datas,
  }) : super(key: key);
  @override
  _CheckBoxLihatProdukState createState() => _CheckBoxLihatProdukState();
}

class _CheckBoxLihatProdukState extends State<CheckBoxLihatProduk> {
  bool isSelectionMode = false;

  List<ModelDataToko>? staticData;
  Map<int, bool> selectedFlag = {};
  // Map<int, bool> selectedFlag = {};

  @override
  void initState() {
    checkConnection(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      body: newnew(widget.datas),
      // floatingActionButton: _buildSelectAllButton(),
    );
  }

  Column newnew(List<ModelDataToko>? datas) {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    bool light = true;

    return Column(
      children: [
        Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: primary500,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size12),
                topRight: Radius.circular(size12),
              ),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(
                width: 200,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _selectAll,
                      child: SizedBox(
                        width: 50,
                        child: Icon(
                          isFalseAvailable
                              ? PhosphorIcons.square
                              : PhosphorIcons.check_square_fill,
                          color: bnw100,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        'Info Produk',
                        style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 50),
              SizedBox(
                width: 90,
                child: Text(
                  'Kategori',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: 90,
                child: Text(
                  'Harga',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: 90,
                child: Text(
                  'PPN',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                child: Text(
                  'Tampilkan dikasir',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  '',
                  style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
            ])),
        Expanded(
          child: Container(
            color: primary100,
            child: ListView.builder(
              itemBuilder: (builder, index) {
                ModelDataToko data = datas[index];
                selectedFlag[index] = selectedFlag[index] ?? false;
                bool? isSelected = selectedFlag[index];

                return Padding(
                  padding: EdgeInsets.only(bottom: size8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        // onTap: () => onTap(isSelected, index),
                        onTap: () {
                          onTap(isSelected, index);
                          log(data.name.toString());
                        },
                        child: SizedBox(
                          width: 50,
                          child: _buildSelectIcon(isSelected!, data),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: datas[index].logomerchant_url != null
                              ? Image.network(
                                  datas[index].logomerchant_url.toString(),
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                ),
                        ),
                      ),
                      SizedBox(width: size24),
                      SizedBox(
                        width: 120,
                        child: Text(
                          datas[index].name ?? '',
                          style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: Text(
                          '${datas[index].name}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: Text(
                          '${datas[index].name}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: Switch(
                          value: light,
                          onChanged: (bool value) {
                            setState(() {
                              light = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Switch(
                          value: light,
                          onChanged: (bool value) {
                            setState(() {
                              light = value;
                            });
                          },
                        ),
                      ),
                      Spacer(),
                      buttonL(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIcons.pencil_line),
                            SizedBox(width: 6),
                            Text(
                              "Atur",
                              style: body1(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                          ],
                        ),
                        
                        bnw100,
                        bnw900,
                      ),
                      SizedBox(width: size24),
                    ],
                  ),
                );
              },
              // itemCount: staticData!.length,
              itemCount: datas!.length,
            ),
          ),
        ),
      ],
    );
  }

  void onTap(bool isSelected, int index) {
    setState(() {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);
    });
    // if (isSelectionMode) {
    // } else {
    //   // Open Detail Page
    // }
  }

  void onLongPress(bool isSelected, int index) {
    setState(() {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }

  Widget _buildSelectIcon(bool isSelected, ModelDataToko data) {
    return Icon(
      isSelected ? PhosphorIcons.check_square_fill : PhosphorIcons.square,
      color: primary500,
    );
    // if (isSelectionMode) {
    // } else {
    //   return CircleAvatar(
    //     child: Text('${data['id']}'),
    //   );
    // }
  }

  void _selectAll() {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    // If false will be available then it will select all the checkbox
    // If there will be no false then it will de-select all
    selectedFlag.updateAll((key, value) => isFalseAvailable);
    setState(() {
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }
}
