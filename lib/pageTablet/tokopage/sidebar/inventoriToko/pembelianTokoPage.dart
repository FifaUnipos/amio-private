import 'dart:developer';

import 'package:amio/main.dart';
import 'package:amio/models/inventoriModel/pembelianInventoriModel.dart';
import 'package:amio/models/produkmodel.dart';
import 'package:amio/pageTablet/tokopage/sidebar/produkToko/produk.dart';
import 'package:amio/services/apimethod.dart';
import 'package:amio/utils/component/component_button.dart';
import 'package:amio/utils/component/component_color.dart';
import 'package:amio/utils/component/component_orderBy.dart';
import 'package:amio/utils/component/component_showModalBottom.dart';
import 'package:amio/utils/component/component_size.dart';
import 'package:amio/utils/component/component_textHeading.dart';
import 'package:amio/utils/component/skeletons.dart';
import 'package:amio/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';

class PemesananPage extends StatefulWidget {
  String token;
  PemesananPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<PemesananPage> createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  List<PembelianModel>? datasProduk;

  TextEditingController searchController = TextEditingController();

  bool isSelectionMode = false;
  Map<int, bool> selectedFlag = {};
  List<String> listProduct = List.empty(growable: true);
  List<String> cartProductIds = [];

  List<String>? productIdCheckAll;

  String textInventori = "Persediaan";
  String checkFill = 'kosong';

  double expandedPage = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      datasProduk = await getPembelian(widget.token, '', '', textvalueOrderBy);

      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return 
    SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  orderBy(context),
                  SizedBox(width: size12),
                ],
              ),
              // buttonLoutlineColor(
              //     Row(
              //       children: [
              //         Icon(
              //           PhosphorIcons.archive_box_fill,
              //           color: orange500,
              //           size: size24,
              //         ),
              //         SizedBox(width: size12),
              //         Text(
              //           'Persediaan Habis : 1',
              //           style: TextStyle(
              //             color: orange500,
              //             fontFamily: 'Outfit',
              //             fontWeight: FontWeight.w400,
              //           ),
              //         ),
              //       ],
              //     ),
              //     orange100,
              //     orange500),
            ],
          ),
          //! table produk
          SizedBox(height: size16),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primary500,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size16),
                      topRight: Radius.circular(size16),
                    ),
                  ),
                  child: isSelectionMode == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              child: GestureDetector(
                                onTap: () {
                                  _selectAll(productIdCheckAll);
                                },
                                child: SizedBox(
                                  width: 50,
                                  child: Icon(
                                    isSelectionMode
                                        ? PhosphorIcons.check
                                        : PhosphorIcons.square,
                                    color: bnw100,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: Text(
                                  'Tanggal Pembelian',
                                  style: heading4(
                                      FontWeight.w700, bnw100, 'Outfit'),
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            SizedBox(width: size16),
                            SizedBox(width: size16),
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: Text(
                                  'Total Harga',
                                  style: heading4(
                                      FontWeight.w700, bnw100, 'Outfit'),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            SizedBox(
                              child: GestureDetector(
                                onTap: () {
                                  _selectAll(productIdCheckAll);
                                },
                                child: SizedBox(
                                  width: 50,
                                  child: Icon(
                                    checkFill == 'penuh'
                                        ? PhosphorIcons.check_square_fill
                                        : isSelectionMode
                                            ? PhosphorIcons.check_square_fill
                                            : PhosphorIcons.square,
                                    color: bnw100,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              '${listProduct.length}/${datasProduk!.length} Produk Terpilih',
                              // 'produk terpilih',
                              style:
                                  heading4(FontWeight.w600, bnw100, 'Outfit'),
                            ),
                            SizedBox(width: size8),
                            GestureDetector(
                              onTap: () {
                                showBottomPilihan(
                                  context,
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            'Yakin Ingin Menghapus Produk?',
                                            style: heading1(FontWeight.w600,
                                                bnw900, 'Outfit'),
                                          ),
                                          SizedBox(height: size16),
                                          Text(
                                            'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
                                            style: heading2(FontWeight.w400,
                                                bnw900, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: size16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                // deleteProduk(
                                                //   context,
                                                //   widget.token,
                                                //   listProduct,
                                                //   "",
                                                // ).then(
                                                //   (value) async {
                                                //     if (value == '00') {
                                                //       refreshDataProduk();
                                                //       await Future.delayed(Duration(seconds: 1));
                                                //       conNameProduk.text = '';
                                                //       conHarga.text = '';
                                                //       idProduct = '';
                                                //       _pageController.jumpToPage(0);
                                                //       setState(() {});
                                                //       initState();
                                                //     }
                                                //   },
                                                // );
                                                // refreshDataProduk();

                                                setState(() {});
                                                initState();
                                              },
                                              child: buttonXLoutline(
                                                Center(
                                                  child: Text(
                                                    'Iya, Hapus',
                                                    style: heading3(
                                                        FontWeight.w600,
                                                        primary500,
                                                        'Outfit'),
                                                  ),
                                                ),
                                                MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                primary500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: size12),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: buttonXL(
                                                Center(
                                                  child: Text(
                                                    'Batalkan',
                                                    style: heading3(
                                                        FontWeight.w600,
                                                        bnw100,
                                                        'Outfit'),
                                                  ),
                                                ),
                                                MediaQuery.of(context)
                                                    .size
                                                    .width,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: buttonL(
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(PhosphorIcons.trash_fill,
                                        color: bnw900),
                                    Text(
                                      'Hapus Semua',
                                      style: heading3(
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                  ],
                                ),
                                bnw100,
                                bnw300,
                              ),
                            ),
                            SizedBox(width: size8),
                          ],
                        ),
                ),
                datasProduk == null
                    ? SkeletonCardLine()
                    : Expanded(
                        child: Container(
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
                            onRefresh: () async {
                              setState(() {});
                              initState();
                            },
                            child: ListView.builder(
                              // physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: datasProduk!.length,
                              itemBuilder: (builder, index) {
                                PembelianModel data = datasProduk![index];
                                selectedFlag[index] =
                                    selectedFlag[index] ?? false;
                                bool? isSelected = selectedFlag[index];
                                final dataProduk = datasProduk![index];
                                productIdCheckAll = datasProduk!
                                    .map((data) => data.groupId!)
                                    .toList();

                                return Container(
                                  // padding: EdgeInsets.symmetric(
                                  //     horizontal: size16, vertical: size12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: bnw300, width: width1),
                                    ),
                                  ),
                                  child: Row(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Row(
                                          children: [
                                            InkWell(
                                              // onTap: () => onTap(isSelected, index),
                                              onTap: () {
                                                onTap(
                                                  isSelected,
                                                  index,
                                                  dataProduk.groupId,
                                                );
                                                // log(data.name.toString());
                                                // print(dataProduk.isActive);

                                                print(listProduct);
                                              },
                                              child: SizedBox(
                                                width: 50,
                                                child: _buildSelectIcon(
                                                  isSelected!,
                                                  data,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              datasProduk![index]
                                                      .activityDate ??
                                                  '',
                                              style: heading4(FontWeight.w600,
                                                  bnw900, 'Outfit'),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: size120),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          FormatCurrency.convertToIdr(
                                            datasProduk![index].totalPrice,
                                          ),
                                          style: heading4(FontWeight.w600,
                                              bnw900, 'Outfit'),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              // itemCount: staticData!.length,
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

  orderBy(BuildContext context) {
    return IntrinsicWidth(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showModalBottomSheet(
              constraints: const BoxConstraints(
                maxWidth: double.infinity,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context, setState) => IntrinsicHeight(
                    child: Container(
                      padding:
                          EdgeInsets.fromLTRB(size32, size16, size32, size32),
                      decoration: BoxDecoration(
                        color: bnw100,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(size12),
                          topLeft: Radius.circular(size12),
                        ),
                      ),
                      child: Column(
                        children: [
                          dividerShowdialog(),
                          SizedBox(height: size16),
                          Container(
                            width: double.infinity,
                            color: bnw100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Urutkan',
                                  style: heading2(
                                      FontWeight.w700, bnw900, 'Outfit'),
                                ),
                                Text(
                                  'Tentukan data yang akan tampil',
                                  style: heading4(
                                      FontWeight.w400, bnw600, 'Outfit'),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Pilih Urutan',
                                  style: heading3(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                                Wrap(
                                  children: List<Widget>.generate(
                                    orderByProductText.length,
                                    (int index) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: size16),
                                        child: ChoiceChip(
                                          padding: EdgeInsets.symmetric(
                                              vertical: size12),
                                          backgroundColor: bnw100,
                                          selectedColor: primary100,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color:
                                                  valueOrderByProduct == index
                                                      ? primary500
                                                      : bnw300,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(size8),
                                          ),
                                          label: Text(orderByProductText[index],
                                              style: heading4(
                                                  FontWeight.w400,
                                                  valueOrderByProduct == index
                                                      ? primary500
                                                      : bnw900,
                                                  'Outfit')),
                                          selected:
                                              valueOrderByProduct == index,
                                          onSelected: (bool selected) {
                                            setState(() {
                                              print(index);
                                              // _value =
                                              //     selected ? index : null;
                                              valueOrderByProduct = index;
                                            });
                                            setState(() {});
                                          },
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size32),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                print(valueOrderByProduct);
                                print(orderByProductText[valueOrderByProduct]);

                                textOrderBy =
                                    orderByProductText[valueOrderByProduct];
                                textvalueOrderBy =
                                    orderByProduct[valueOrderByProduct];
                                orderByProduct[valueOrderByProduct];
                                Navigator.pop(context);
                                // initState();
                              },
                              child: buttonXL(
                                Center(
                                  child: Text(
                                    'Tampilkan',
                                    style: heading3(
                                        FontWeight.w600, bnw100, 'Outfit'),
                                  ),
                                ),
                                0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          });
        },
        child: buttonLoutline(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Urutkan',
                style: heading3(
                  FontWeight.w600,
                  bnw900,
                  'Outfit',
                ),
              ),
              Text(
                ' dari $textOrderBy',
                style: heading3(
                  FontWeight.w400,
                  bnw900,
                  'Outfit',
                ),
              ),
              SizedBox(width: size12),
              Icon(
                PhosphorIcons.caret_down,
                color: bnw900,
                size: size24,
              )
            ],
          ),
          bnw300,
        ),
      ),
    );
  }

  void onTap(bool isSelected, int index, productId) {
    if (index >= 0 && index < selectedFlag.length) {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);

      if (selectedFlag[index] == true) {
        // Periksa apakah productId sudah ada di dalam listProduct sebelum menambahkannya
        if (!listProduct.contains(productId)) {
          listProduct.add(productId);
        }
      } else {
        // Hapus productId dari listProduct jika sudah ada
        listProduct.remove(productId);
      }

      setState(() {});
    }
  }

  void onLongPress(bool isSelected, int index) {
    setState(() {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }

  Widget _buildSelectIcon(bool isSelected, PembelianModel data) {
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

  void _selectAll(productId) {
    bool isFalseAvailable = selectedFlag.containsValue(false);

    selectedFlag.updateAll((key, value) => isFalseAvailable);
    log(productId.toString());
    setState(
      () {
        if (selectedFlag.containsValue(false)) {
          checkFill = 'kosong';
          listProduct.clear();
          isSelectionMode = selectedFlag.containsValue(false);
          isSelectionMode = selectedFlag.containsValue(true);
        } else {
          checkFill = 'penuh';
          listProduct.clear();
          listProduct.addAll(productId);
          isSelectionMode = selectedFlag.containsValue(true);
        }
      },
    );
  }
}
