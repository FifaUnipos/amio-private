import 'dart:developer';
import 'dart:io';

import 'package:amio/pageTablet/home/sidebar/transaksiGrup/pengaturanGrup.dart';
import 'package:amio/pageTablet/home/sidebar/transaksiGrup/riwayatGrup.dart';
import 'package:amio/pageTablet/home/sidebar/transaksiGrup/tagihanGrup.dart';
import 'package:amio/pageTablet/tokopage/sidebar/transaksiToko/pesananPage.dart';
import 'package:amio/utils/printer/printerPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../services/checkConnection.dart';
import 'package:amio/utils/component.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../main.dart';
import '../../../../models/tokomodel.dart';
import '../../../../services/apimethod.dart';
import '../../../../utils/skeletons.dart';

Color maainColor = Color(0xFF1363DF);

class TransaksiGrup extends StatefulWidget {
  String token;
  TransaksiGrup({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<TransaksiGrup> createState() => _TransaksiGrupState();
}

class _TransaksiGrupState extends State<TransaksiGrup>
    with TickerProviderStateMixin {
  PageController _pageController = PageController();
  TabController? _tabController;

  TextEditingController searchController = TextEditingController();

  List<ModelDataToko>? datas;

  @override
  void initState() {
    checkConnection(context);
    _tabController = TabController(length: 3, vsync: this);

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

  late String merchid = '', namemerch = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('haai');
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
                homePageTransaksiGrup(context),
                TagihanPageGrup(
                  bluetooth: bluetooth,
                  token: widget.token,
                  pageController: _pageController,
                  tabController: _tabController!,
                  merchid: merchid,
                  namemerch: namemerch,
                ),
                RiwayatPageGrup(
                  bluetooth: bluetooth,
                  token: widget.token,
                  pageController: _pageController,
                  tabController: _tabController!,
                  merchid: merchid,
                  namemerch: namemerch,
                ),
                PengaturanGrup(
                  token: widget.token,
                  pageController: _pageController,
                  tabController: _tabController!,
                  namemerch: namemerch,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  homePageTransaksiGrup(BuildContext context) {
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
                  'Transaksi',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Memantau riwayat transaksi disetiap toko',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            ),
            SizedBox(width: size16),
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: (value) async {
                  datas = await getAllToko(context, widget.token, value, '');
                  setState(() {});
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: size12),
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
                child: RefreshIndicator(
                  color: bnw100,
                  backgroundColor: primary500,
                  onRefresh: () async {
                    initState();
                    setState(() {});
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                              height: 216,
                              width: 333,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(size16),
                                  border: Border.all(color: bnw300)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(1000),
                                        child: SizedBox(
                                          height: 60,
                                          width: 60,
                                          child:
                                              datas![i].logomerchant_url != null
                                                  ? Image.network(
                                                      datas![i]
                                                          .logomerchant_url
                                                          .toString(),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          SizedBox(
                                                              child: Icon(
                                                        PhosphorIcons
                                                            .storefront_fill,
                                                        size: 60,
                                                        color: bnw900,
                                                      )),
                                                    )
                                                  : Icon(
                                                      Icons.person,
                                                      size: 60,
                                                    ),
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              datas![i].name ?? '',
                                              style: heading2(FontWeight.w700,
                                                  bnw900, 'Outfit'),
                                            ),
                                            Text(
                                              '${datas![i].address}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: body2(FontWeight.w400,
                                                  bnw800, 'Outfit'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        merchid =
                                            datas![i].merchantid.toString();
                                        namemerch = datas![i].name.toString();

                                        _pageController.jumpToPage(1);
                                        // log(datas![i].name.toString());
                                        log(datas![i].merchantid.toString());
                                      });
                                    },
                                    child: buttonLoutline(
                                      Center(
                                        child: Text(
                                          'Lihat Transaksi',
                                          style: heading4(
                                            FontWeight.w600,
                                            primary500,
                                            'Outfit',
                                          ),
                                        ),
                                      ),
                                      primary500,
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
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
