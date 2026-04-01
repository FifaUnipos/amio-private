import 'dart:async';
import 'dart:developer';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:unipos_app_335/components/merchant/sort_bottom_sheet_button.dart';
import 'package:unipos_app_335/components/organisms/merchant_card.dart';
import 'package:unipos_app_335/data/model/merchant/merchant_sorting_data.dart';
import 'package:unipos_app_335/data/static/merchant/merchant_sorting_state.dart';
import 'package:unipos_app_335/pageTablet/home/sidebar/coaPageGrup/lihatCoaPage.dart';
import 'package:unipos_app_335/providers/merchant/merchant_sorting_provider.dart';

import '../../../../utils/component/component_showModalBottom.dart';
import 'dart:io';

import '../transaksiGrup/pengaturanGrup.dart';
import '../transaksiGrup/riwayatGrup.dart';
import '../transaksiGrup/tagihanGrup.dart';
import '../../../tokopage/sidebar/transaksiToko/pesananPage.dart';
import '../../../../utils/printer/printerPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import '../../../../services/checkConnection.dart';

import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import '../../../../utils/component/component_orderBy.dart';
import '../../../../main.dart';
import '../../../../models/tokomodel.dart';
import '../../../../services/apimethod.dart';
import '../../../../utils/component/component_color.dart';
import '../../../../utils/component/skeletons.dart';
import '../../../../../utils/component/component_button.dart';

class COAPageGrup extends StatefulWidget {
  String token;
  COAPageGrup({Key? key, required this.token}) : super(key: key);

  @override
  State<COAPageGrup> createState() => _COAPageGrupState();
}

class _COAPageGrupState extends State<COAPageGrup>
    with TickerProviderStateMixin {
  PageController _pageController = PageController();
  TabController? _tabController;

  TextEditingController searchController = TextEditingController();

  List<MerchantSortingData>? datas;

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

    _tabController = TabController(length: 3, vsync: this);

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

  late String merchid = '', namemerch = '';

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
                homePageCOAGrup(context),
                LihatCOAPageGrup(
                  token: widget.token,
                  nameMerch: namemerch,
                  merchID: merchid,
                  pageController: _pageController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  homePageCOAGrup(BuildContext context) {
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
                  'Chart of Accounts',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Atur COA tokomu dengan lengkap',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
            SizedBox(width: size16),
            Expanded(
              child: TextField(
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
                                  setState(() {
                                    merchid = dataStore[i].merchantid
                                        .toString();
                                    namemerch = dataStore[i].name.toString();

                                    _pageController.jumpToPage(1);
                                    // log(dataStore[i].name.toString());
                                    print(dataStore[i].merchantid.toString());
                                  });
                                },
                                buttonText: 'Lihat COA',
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
