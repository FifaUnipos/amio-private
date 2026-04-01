import 'dart:async';
import 'dart:developer';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:unipos_app_335/components/merchant/sort_bottom_sheet_button.dart';
import 'package:unipos_app_335/components/organisms/merchant_card.dart';

import 'package:unipos_app_335/data/model/merchant/merchant_sorting_data.dart';
import 'package:unipos_app_335/data/static/merchant/merchant_sorting_state.dart';
import 'package:unipos_app_335/providers/merchant/merchant_sorting_provider.dart';

import '../../../../utils/component/component_showModalBottom.dart';

import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../../utils/component/component_button.dart';
import '../../../../models/tokomodel.dart';
import '../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';

import '../../../../utils/component/component_color.dart';
import '../../../../utils/component/component_orderBy.dart';
import '../../../../utils/component/skeletons.dart';
import 'lihatAkun.dart';
import 'tambahAkunPage.dart';
import 'ubahAkun.dart';

String account_imageAkun = "";

class AkunGrup extends StatefulWidget {
  String token;
  AkunGrup({Key? key, required this.token}) : super(key: key);

  @override
  State<AkunGrup> createState() => _AkunGrupState();
}

class _AkunGrupState extends State<AkunGrup> {
  PageController _pageController = PageController();
  List<MerchantSortingData>? datas;

  TextEditingController searchController = TextEditingController();

  String nameMerchant = "",
      merchantId = "",
      address = "",
      province = "",
      district = "",
      village = "",
      regencies = "",
      zipcode = "",
      businesstype = "",
      logomerchant_url = "";

  Timer? _debounce;

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(seconds: 2), () async {
      context.read<MerchantSortingProvider>().fetchMerchantSorting(
        widget.token,
        value,
        textvalueOrderByStore,
      );
      setState(() {});
    });
  }

  @override
  void initState() {
    checkConnection(context);
    log(datas.toString());
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageController.page!.round() == 0) {
          showModalBottomExit(context);
          return false;
        } else {
          _pageController.jumpToPage(_pageController.page!.round() - 1);
          return false;
        }
      },
      child: Scaffold(
        // backgroundColor: primaryColor,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.all(size16),
            padding: EdgeInsets.all(size16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size16),
              color: bnw100,
            ),
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                mainAkunPage(context),
                lihatAkunPage(
                  title: nameMerchant,
                  token: widget.token,
                  pageController: _pageController,
                  merchid: merchantId,
                ),
                TambahAkunPage(
                  merchid: merchantId,
                  token: widget.token,
                  pageController: _pageController,
                  namemerchant: nameMerchant,
                  address: address,
                  province: province,
                  regencies: regencies,
                  district: district,
                  village: village,
                  zipcode: zipcode,
                  businesstype: businesstype,
                  logomerchant_url: logomerchant_url,
                ),
                UbahAkunPage(
                  token: widget.token,
                  pageController: _pageController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column mainAkunPage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akun',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Atur akun pekerja di setiap toko',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
            SizedBox(width: size16),
            Expanded(
              child: TextField(
                cursorColor: primary500,
                controller: searchController,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: size12),
                  isDense: true,
                  filled: true,
                  fillColor: bnw200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(size8),
                    borderSide: BorderSide(color: bnw300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(size8),
                    borderSide: BorderSide(width: 2, color: primary500),
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
                            size: size24,
                            color: bnw900,
                          ),
                        )
                      : null,
                  hintText: 'Cari nama toko',
                  hintStyle: heading3(FontWeight.w500, bnw400, 'Outfit'),
                ),
              ),
            ),
          ],
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
                                onTap: () async {
                                  setState(() {});
                                  nameMerchant = dataStore[i].name.toString();
                                  merchantId = dataStore[i].merchantid.toString();
                                  address = dataStore[i].address.toString();
                                  province = dataStore[i].province.toString();
                                  district = dataStore[i].district.toString();
                                  village = dataStore[i].village.toString();
                                  regencies = dataStore[i].regencies.toString();
                                  zipcode = dataStore[i].zipcode.toString();
                                  businesstype = "Car Wash";
                                  logomerchant_url = dataStore[i].logomerchant_url
                                      .toString();

                                  _pageController.nextPage(
                                    duration: Duration(milliseconds: 10),
                                    curve: Curves.easeIn,
                                  );
                                  // log(dataStore[i].merchantid.toString());
                                  log(merchantId);
                                },
                                buttonText: 'Lihat Akun',
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
