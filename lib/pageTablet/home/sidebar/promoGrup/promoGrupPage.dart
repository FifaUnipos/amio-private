import 'dart:async';
import 'dart:developer';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:unipos_app_335/components/merchant/sort_bottom_sheet_button.dart';
import 'package:unipos_app_335/components/organisms/merchant_card.dart';

import 'package:unipos_app_335/data/static/merchant/merchant_sorting_state.dart';
import 'package:unipos_app_335/providers/merchant/merchant_sorting_provider.dart';

import '../../../../utils/component/component_showModalBottom.dart';
import 'dart:io';

import '../produkPage/lihatProduk.dart';
import '../produkPage/tambahBanyakProduk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';

import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import '../../../../utils/component/component_button.dart';
import '../../../../main.dart';
import '../../../../models/tokomodel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../../utils/component/skeletons.dart';
import 'lihatDiskonPage.dart';
import '../../../../utils/component/component_orderBy.dart';
import 'tambahDiskonGrupPage.dart';
import '../../../../utils/component/component_color.dart';

class PromoGrup extends StatefulWidget {
  String token;
  PromoGrup({Key? key, required this.token}) : super(key: key);

  @override
  State<PromoGrup> createState() => _PromoGrupState();
}

class _PromoGrupState extends State<PromoGrup> {
  TextEditingController searchController = TextEditingController();
  PageController _pageController = PageController();
  List<ModelDataToko>? dataStore;

  late String _name, _merchid;
  Timer? _debounce;

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(seconds: 2), () async {
      context.read<MerchantSortingProvider>().fetchMerchantSorting(
        widget.token,
        '',
        textvalueOrderByStore,
      );
      setState(() {});
    });
  }

  @override
  void initState() {
    checkConnection(context);
    _name = '';
    _merchid = '';
    nameEditProduk = '';
    hargaEditProduk = '';
    jenisProductEdit = '';
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      context.read<MerchantSortingProvider>().fetchMerchantSorting(
        widget.token,
        '',
        textvalueOrderByStore,
      );

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
    _debounce?.cancel();
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
    return WillPopScope(
      onWillPop: () async {
        if (_pageController.page!.round() == 0) {
          showModalBottomExit(context);
          return false;
        }
        return true;
      },
      child: Scaffold(
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
                PromosiGrup(
                  token: widget.token,
                  merchid: _merchid,
                  name: _name,
                  pageController: _pageController,
                ),
                // TambahBanyakVoucherPage(
                //   pageController: _pageController,
                //   token: widget.token,
                //   merchid: _merchid,
                // )
              ],
            ),
          ),
        ),
      ),
    );
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
                    'Promo',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Promo yang akan dijual belikan',
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
                          onChanged: _onChanged,
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
                              borderSide: BorderSide(
                                width: 2,
                                color: primary500,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(size8),
                              borderSide: BorderSide(color: bnw300),
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
                            hintStyle: heading3(
                              FontWeight.w500,
                              bnw400,
                              'Outfit',
                            ),
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
        SizedBox(height: size16),
        SortBottomSheetButton(
          options: orderByTokoText,
          initialIndex: valueOrderByStore,
          onConfirm: (i) async {
            setState(() {
              valueOrderByStore = i;
              textvalueOrderByStore = orderByToko[i];
            });
            await context.read<MerchantSortingProvider>().fetchMerchantSorting(
              widget.token,
              '',
              textvalueOrderByStore,
            );
          },
        ),
        SizedBox(height: size16),
        Text('Pilih Toko', style: heading2(FontWeight.w400, bnw900, 'Outfit')),
        SizedBox(height: size16),

        Expanded(
          child: Consumer<MerchantSortingProvider>(
            builder: (context, value, child) {
              return switch (value.resultState) {
                MerchantSortingResultNoneState() => const Center(
                  child: Text('Tidak ada data'),
                ),
                MerchantSortingResultErrorState(message: var message) => Center(
                  child: Text('Erorr $message'),
                ),
                MerchantSortingResultLoadingState() => Center(
                  child: SkeletonCard(),
                ),
                MerchantSortingResultLoadedState(data: var dataStore) => Container(
                  child: RefreshIndicator(
                    color: bnw100,
                    backgroundColor: primary500,
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: MasonryGridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                ),
                            crossAxisSpacing: size16,
                            mainAxisSpacing: size16,
                            itemCount: dataStore.length,
                            itemBuilder: (context, i) {
                              return MerchantCard(
                                merchant: dataStore[i],
                                onTap: () {
                                  _pageController.nextPage(
                                    duration: Duration(milliseconds: 10),
                                    curve: Curves.easeIn,
                                  );
                                  log(dataStore[i].name.toString());
                                  log(dataStore[i].merchantid.toString());

                                  _name = dataStore[i].name.toString();
                                  _merchid = dataStore[i].merchantid.toString();

                                  setState(() {});
                                },
                                buttonText: 'Lihat Promo',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              };
            },
          ),
        ),
      ],
    );
  }
}

// Hello world

class CheckBoxPage extends StatefulWidget {
  List<ModelDataToko>? datas;
  CheckBoxPage({Key? key, required this.datas}) : super(key: key);
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: primary100,
              borderRadius: BorderRadius.circular(size12),
            ),
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
                              : Icon(PhosphorIcons.storefront_fill, size: 60),
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
