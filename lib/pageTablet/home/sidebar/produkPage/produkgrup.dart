import 'dart:developer';
import 'dart:io';

import 'package:amio/pageTablet/home/sidebar/produkPage/lihatProduk.dart';
import 'package:amio/pageTablet/home/sidebar/produkPage/tambahBanyakProduk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:amio/utils/component.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../main.dart';
import '../../../../models/tokomodel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../../utils/skeletons.dart';
import 'tambahProduk.dart';

Color maainColor = Color(0xFF1363DF);

class ProdukGrup extends StatefulWidget {
  String token;
  ProdukGrup({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<ProdukGrup> createState() => _ProdukGrupState();
}

class _ProdukGrupState extends State<ProdukGrup> {
  TextEditingController searchController = TextEditingController();
  PageController _pageController = PageController();
  List<ModelDataToko>? datas;

  late String _name, _merchid;

  @override
  void initState() {
    checkConnection(context);
    _name = '';
    _merchid = '';
    nameEditProduk = '';
    hargaEditProduk = '';
    jenisProductEdit = '';
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      datas = await getAllToko(context, widget.token, '', textvalueOrderBy);

      setState(() {});

      _pageController = PageController(
        initialPage: 0,
        keepPage: true,
        viewportFraction: 1,
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  refreshTampilan() {
    nameEditProduk = '';
    hargaEditProduk = '';
    jenisProductEdit = '';
    kodejenisProductEdit = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
              padding: EdgeInsets.all(size16),
              margin: EdgeInsets.all(size16),
              decoration: BoxDecoration(
          color: bnw100,
          borderRadius: BorderRadius.circular(size16),
              ),
              child: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          pageSnapping: true,
          reverse: false,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            print('$index');
          },
          children: [
            mainPageProduk(context),
            LihatProdukPage(
              token: widget.token,
              merchId: _merchid,
              name: _name,
              pageController: _pageController,
            ),
            TambahProdukPage(
              name: _name,
              datas: datas ?? [],
              pageController: _pageController,
            ),
            TambahBanyakProdukPagPage(
              pageController: _pageController,
              token: widget.token,
            )
          ],
              ),
            ),
        ));
  }

  mainPageProduk(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Produk',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Produk yang akan dijual belikan',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              ),
              SizedBox(width: size32),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: TextField(
                          controller: searchController,
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (value) async {
                            datas = await getAllToko(
                                context, widget.token, value, '');
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(vertical: size12),
                            isDense: true,
                            filled: true,
                            fillColor: bnw200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(size8),
                              borderSide: BorderSide(
                                color: bnw300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(size8),
                              borderSide: BorderSide(
                                width: 2,
                                color: primary500,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(size8),
                              borderSide: BorderSide(
                                color: bnw300,
                              ),
                            ),
                            prefixIcon: Container(
                              margin: EdgeInsets.only(left: 20, right: size12),
                              child: Icon(
                                PhosphorIcons.magnifying_glass,
                                color: bnw900,
                                size: 20,
                              ),
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      searchController.text = '';
                                      initState();
                                    },
                                    child: Icon(
                                      PhosphorIcons.x_fill,
                                      size: 20,
                                      color: bnw900,
                                    ),
                                  )
                                : null,
                            hintText: 'Cari nama toko',
                            hintStyle:
                                heading3(FontWeight.w500, bnw400, 'Outfit'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size16),
                    GestureDetector(
                      onTap: () {
                        _pageController.jumpToPage(3);

                        setState(() {});
                      },
                      child: buttonXL(
                        Row(
                          children: [
                            Icon(PhosphorIcons.plus, color: bnw100),
                            SizedBox(width: size12),
                            Text(
                              'Produk',
                              style:
                                  heading3(FontWeight.w600, bnw100, 'Outfit'),
                            ),
                          ],
                        ),
                        140,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size16),
        orderByTokoField(),
        SizedBox(height: size16),
        Text(
          'Pilih Toko',
          style: heading2(FontWeight.w400, bnw900, 'Outfit'),
        ),
        SizedBox(height: size16),
        datas == null
            ? SkeletonCard()
            : Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 130,
                    // childAspectRatio: 2.977,
                    crossAxisCount: 2,
                    crossAxisSpacing: size16,
                    mainAxisSpacing: size16,
                  ),
                  itemCount: datas!.length,
                  itemBuilder: (context, i) {
                    return Container(
                      padding: EdgeInsets.all(size16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size16),
                        border: Border.all(color: bnw300),
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(1000),
                                  child: SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: datas![i].logomerchant_url != null
                                        ? Image.network(
                                            datas![i]
                                                .logomerchant_url
                                                .toString(),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    SizedBox(
                                              child: Icon(
                                                PhosphorIcons.storefront_fill,
                                                size: 60,
                                                color: bnw900,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 60,
                                          ),
                                  ),
                                ),
                                SizedBox(width: size24),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        datas![i].name ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: heading2(
                                          FontWeight.w700,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      Text(
                                        '${datas![i].address}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: body1(
                                          FontWeight.w400,
                                          bnw800,
                                          'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size16),
                            GestureDetector(
                              onTap: () {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 10),
                                  curve: Curves.easeIn,
                                );
                                log(datas![i].name.toString());
                                log(datas![i].merchantid.toString());

                                _name = datas![i].name.toString();
                                _merchid = datas![i].merchantid.toString();

                                setState(() {});
                              },
                              child: buttonLoutline(
                                Center(
                                  child: Text(
                                    'Lihat Produk',
                                    style: heading4(
                                      FontWeight.w600,
                                      primary500,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                                primary500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
      ],
    );
  }

  orderByTokoField() {
    return IntrinsicWidth(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showModalBottomSheet(
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
                                    orderByTokoText.length,
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
                                          label: Text(orderByTokoText[index],
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
                                textOrderBy =
                                    orderByTokoText[valueOrderByProduct];
                                textvalueOrderBy =
                                    orderByToko[valueOrderByProduct];

                                Navigator.pop(context);
                                initState();
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
}

// Hello world

class CheckBoxPage extends StatefulWidget {
  List<ModelDataToko>? datas;
  CheckBoxPage({
    Key? key,
    required this.datas,
  }) : super(key: key);
  @override
  _CheckBoxPageState createState() => _CheckBoxPageState();
}

class _CheckBoxPageState extends State<CheckBoxPage> {
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
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            GestureDetector(
              onTap: _selectAll,
              child: SizedBox(
                width: 50,
                child: Icon(
                  isFalseAvailable
                      ? Icons.check_box_outline_blank
                      : Icons.check_box,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                'Foto Toko',
                style: heading4(FontWeight.w700, bnw100, 'Outfit'),
              ),
            ),
            SizedBox(
              width: 200,
              child: Text(
                'Nama Toko',
                style: heading4(FontWeight.w700, bnw100, 'Outfit'),
              ),
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'Alamat',
                  style: heading4(FontWeight.w700, bnw100, 'Outfit'),
                ),
              ),
            ),
          ]),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: primary100, borderRadius: BorderRadius.circular(size12)),
            child: ListView.builder(
              itemBuilder: (builder, index) {
                ModelDataToko data = datas[index];
                selectedFlag[index] = selectedFlag[index] ?? false;
                bool? isSelected = selectedFlag[index];

                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
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
                      SizedBox(width: size32),
                      SizedBox(
                        width: 200,
                        child: Text(
                          datas[index].name ?? '',
                          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            '${datas[index].address} ${datas[index].district} ${datas[index].village} ${datas[index].regencies} ${datas[index].province} ${datas[index].zipcode}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                //   ListTile(
                // // onLongPress: () => onLongPress(isSelected, index),
                // onTap: () => onTap(isSelected, index),
                // title: Text("${data['name']}"),
                // subtitle: Text("${data['email']}"),
                // leading: _buildSelectIcon(isSelected!, data),
                // );
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
      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
      color: Theme.of(context).primaryColor,
    );
    // if (isSelectionMode) {
    // } else {
    //   return CircleAvatar(
    //     child: Text('${data['id']}'),
    //   );
    // }
  }

  // FloatingActionButton? _buildSelectAllButton() {
  //   bool isFalseAvailable = selectedFlag.containsValue(false);
  //   if (isSelectionMode) {
  //     return FloatingActionButton(
  //       onPressed: _selectAll,
  //       child: Icon(
  //         isFalseAvailable ? Icons.done_all : Icons.remove_done,
  //       ),
  //     );
  //   } else {
  //     return null;
  //   }
  // }

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
