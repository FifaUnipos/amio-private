import 'dart:developer';

import 'package:unipos_app_335/pageTablet/home/sidebar/notifikasigrup.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/coaToko/coaPage.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoriToko/inventoriMerchantOnly.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoriToko/inventoriTokoPage.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/unitConvertionToko/unitConvertPage.dart';

import '../../main.dart';
import '../../utils/component/component_orderBy.dart';
import '../../utils/component/component_size.dart';
import 'sidebar/inventoriToko/inventori.dart';

import 'sidebar/transaksiToko/pesananPage.dart';
import 'sidebar/transaksiToko/transaksi.dart';

import '../../utils/printer/printerPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../pagehelper/loginregis/login_page.dart';
import '../../services/apimethod.dart';
import '../../services/notification.dart';
import '../../utils/component/component_color.dart';
import '../../utils/component/component_loading.dart';
import '../home/sidebar/bantuan.dart';
import '../home/sidebar/profile_page.dart';
import '../home/sidebar/tokoPage/tokogrup.dart';
import '../test/akun.dart';
import '../test/dashboardnew.dart';

import 'sidebar/keuanganToko/keuanganToko.dart';
import 'sidebar/laporanToko/laporanToko.dart';
import 'sidebar/pelangganToko/pelanggan.dart';
import 'sidebar/produkToko/produk.dart';
import 'sidebar/promosiToko/promosi.dart';
import 'sidebar/tokoToko/toko.dart';

bool selectedIndexSideBar = false;
bool showingMenuSidebar = true;
int iconSelectedSidebar = 0;

class SidebarXExampleAppToko extends StatefulWidget {
  final String token, id;
  SidebarXExampleAppToko({Key? key, required this.token, required this.id})
      : super(key: key);

  @override
  State<SidebarXExampleAppToko> createState() => _SidebarXExampleAppTokoState();
}

class _SidebarXExampleAppTokoState extends State<SidebarXExampleAppToko> {
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  late FirebaseMessaging messaging;

  PageController _pageController = PageController();
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    iconSelectedSidebar = 0;
    deviceDetails();
    dashboardKulasedaya(checkToken ?? '');
    myprofile(widget.token);
    nameProfile;
    statusProfile;
    emailProfile;
    phoneProfile;
    imageProfile;

    setState(() {});

    _pageController = PageController(
      initialPage: 0,
      keepPage: true,
      viewportFraction: 1,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniPOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primary500,
        canvasColor: primary500,
        fontFamily: 'Outfit',
        scaffoldBackgroundColor: primary500,
        // textTheme: TextTheme(
        //     // bodyText2: heading4(FontWeight.w600, bnw100, 'Outfit'),
        //     ),
      ),
      home: Builder(
        builder: (context) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              drawerEnableOpenDragGesture: false,
              key: _key,
              appBar: isSmallScreen
                  ? AppBar(
                      title: Text(_getTitleByIndex(_controller.selectedIndex)),
                      leading: IconButton(
                        onPressed: () {
                          _controller.setExtended(true);
                          _key.currentState?.openDrawer();
                          print(widget.token);
                        },
                        icon: Icon(Icons.menu),
                      ),
                    )
                  : null,
              drawer: ExampleSidebarXToko(
                controller: _controller,
                token: widget.token,
                pageController: _pageController,
              ),
              body: Row(
                children: [
                  if (!isSmallScreen)
                    ExampleSidebarXToko(
                      controller: _controller,
                      token: widget.token,
                      pageController: _pageController,
                    ),
                  Expanded(
                    child: Center(
                      child: PageView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        pageSnapping: true,
                        reverse: false,
                        onPageChanged: (index) {
                          print('index ke $index');
                        },
                        children: [
                          _ScreensExample(
                            controller: _controller,
                            token: widget.token,
                          ),
                          ProfilePage(token: widget.token)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExampleSidebarXToko extends StatefulWidget {
  final String token;
  PageController pageController = PageController();
  ExampleSidebarXToko({
    Key? key,
    required this.token,
    required this.controller,
    required this.pageController,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  State<ExampleSidebarXToko> createState() => _ExampleSidebarXTokoState();
}

class _ExampleSidebarXTokoState extends State<ExampleSidebarXToko> {
  @override
  void initState() {
    // checkEmail(widget.token, identifier, context, emailProfile.toString());
    iconSelectedSidebar = 0;
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        setState(() {
          myprofile(widget.token);

          nameProfile;
          statusProfile;
          emailProfile;
          phoneProfile;
          imageProfile;
          print("Email " + emailChecker.toString());
          emailChecker;
          // checkEmail(widget.token, identifier, emailProfile.toString());
        });
      },
    );
    deviceDetails();
    callName();
    super.initState();
  }

  Future callName() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        setState(() {
          myprofile(widget.token);

          nameProfile;
          statusProfile;
          emailProfile;
          phoneProfile;
          imageProfile;
          // print("Email " + emailChecker.toString());
          emailChecker;
          // checkEmail(widget.token, identifier, emailProfile.toString());
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: widget.controller,
      theme: SidebarXTheme(
        decoration: BoxDecoration(color: primary500),
        hoverColor: primary500,
        textStyle: heading4(FontWeight.w600, bnw100, 'Outfit'),
        selectedTextStyle: heading4(
          FontWeight.w600,
          selectedIndexSideBar == false ? bnw900 : bnw100,
          'Outfit',
        ),
        itemMargin: EdgeInsets.only(left: size16),
        selectedItemMargin: EdgeInsets.only(left: size16),
        itemTextPadding: EdgeInsets.only(left: size12),
        selectedItemTextPadding: EdgeInsets.only(left: size12),
        itemPadding: EdgeInsets.symmetric(horizontal: size16, vertical: size12),
        selectedItemPadding:
            EdgeInsets.symmetric(horizontal: size16, vertical: size12),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size12),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size12),
          color: selectedIndexSideBar == false ? bnw100 : primary500,
        ),
        iconTheme: IconThemeData(
          color: bnw100,
          size: size32,
        ),
        selectedIconTheme: IconThemeData(
          color: selectedIndexSideBar == true ? bnw100 : primary500,
          size: size32,
        ),
      ),
      extendedTheme: SidebarXTheme(
        width: 160,
        // width: 180,
        decoration: BoxDecoration(
          color: primary500,
        ),
      ),
      // footerDivider: divider,
      showToggleButton: false,
      footerBuilder: (context, extended) => Container(
        padding: EdgeInsets.fromLTRB(size16, size16, 0, size16),
        child: nameProfile != null
            ? GestureDetector(
                onTap: () {
                  myprofile(widget.token);
                  selectedIndexSideBar = true;
                  iconSelectedSidebar = -1;
                  widget.pageController.nextPage(
                    duration: Duration(milliseconds: 10),
                    curve: Curves.ease,
                  );

                  setState(() {});
                },
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      width: double.infinity,
                      color:
                          selectedIndexSideBar != false ? primary500 : bnw100,
                    ),
                    Container(
                      height: 60,
                      padding: showingMenuSidebar == true
                          ? EdgeInsets.fromLTRB(size12, 4, size12, 4)
                          : EdgeInsets.all(size12),
                      decoration: BoxDecoration(
                        color:
                            selectedIndexSideBar == false ? primary500 : bnw100,
                        borderRadius: BorderRadius.circular(size8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          imageProfile == null
                              ? Container(
                                  height: 28,
                                  width: 28,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(1000),
                                    child: SizedBox(
                                      child: CircleAvatar(
                                        backgroundColor: primary200,
                                        radius: 50,
                                        // backgroundImage: NetworkImage(imageUrl),
                                        child: Center(
                                          child: Text(
                                            getInitials().toUpperCase(),
                                            style: body1(FontWeight.w600,
                                                bnw900, 'Outfit'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 28,
                                  width: 28,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(1000),
                                    child: SizedBox(
                                        child: Image.network(
                                      imageProfile,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }

                                        return Center(child: loading());
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              CircleAvatar(
                                        backgroundColor: primary200,
                                        radius: 50,
                                        // backgroundImage: NetworkImage(imageUrl),
                                        child: Center(
                                          child: Text(
                                            getInitials().toUpperCase(),
                                            style: body1(FontWeight.w600,
                                                bnw900, 'Outfit'),
                                          ),
                                        ),
                                      ),
                                    )),
                                  ),
                                ),
                          showingMenuSidebar == true
                              ? SizedBox(width: size8)
                              : SizedBox(),
                          showingMenuSidebar == true
                              ? Expanded(
                                  child: Container(
                                    child: showingMenuSidebar == true
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nameProfile,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: heading4(
                                                    FontWeight.w600,
                                                    selectedIndexSideBar ==
                                                            false
                                                        ? bnw100
                                                        : bnw900,
                                                    'Outfit'),
                                              ),
                                              Text(
                                                statusProfile ==
                                                        'Group_Merchant'
                                                    ? 'Grup Toko'
                                                    : 'Toko',
                                                style: body1(
                                                    FontWeight.w400,
                                                    selectedIndexSideBar ==
                                                            false
                                                        ? bnw100
                                                        : bnw900,
                                                    'Outfit'),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color:
                          selectedIndexSideBar != false ? primary500 : bnw100,
                    ),
                  ],
                ),
              )
            : loading(),
      ),

      headerBuilder: (context, extended) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: size16),
            child: ListView(
              padding: EdgeInsets.only(left: size16, bottom: size12),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.controller.toggleExtended();
                      showingMenuSidebar = !showingMenuSidebar;
                      print(showingMenuSidebar);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size16, vertical: size12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: SvgPicture.asset(
                            'assets/minimize.svg',
                            color: bnw100,
                          ),
                        ),
                        showingMenuSidebar == true
                            ? SizedBox(width: size12)
                            : SizedBox(),
                        showingMenuSidebar == true
                            ? SizedBox(
                                child: Text(
                                  'Kecilkan Menu',
                                  style: heading4(
                                      FontWeight.w600, bnw100, 'Outfit'),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
                showingMenuSidebar == true
                    ? SizedBox(
                        child: SvgPicture.asset(
                          'assets/uniposLogoText.svg',
                          color: bnw100,
                          height: 60,
                        ),
                      )
                    : SizedBox(
                        child: Image.asset(
                          'assets/images/UniPOSLogo.png',
                          color: bnw100,
                          height: 60,
                        ),
                      ),
              ],
            ),
          ),
        );
      },

      items: [
        SidebarXItem(
          icon: iconSelectedSidebar == 0
              ? PhosphorIcons.gauge_fill
              : PhosphorIcons.gauge,
          label: 'Dashboard',
          onTap: () {
            widget.pageController.jumpToPage(0);
            widget.controller.selectedIndex;
            setState(() {
              selectedIndexSideBar = false;
            });
            // print("Token " + checkToken);
            debugPrint(widget.token);
            debugPrint(identifier);
            iconSelectedSidebar = 0;
            valueOrderByProduct = 0;
          },
        ),
        SidebarXItem(
          icon: iconSelectedSidebar == 1
              ? PhosphorIcons.bell_fill
              : PhosphorIcons.bell,
          label: 'Notifikasi',
          onTap: () {
            log("asade ${roleAccount.toString()}");
            widget.pageController.jumpToPage(0);
            widget.controller.selectedIndex;
            setState(() {
              selectedIndexSideBar = false;
            });
            debugPrint(widget.token);
            debugPrint(identifier);
            iconSelectedSidebar = 1;
            valueOrderByProduct = 0;
          },
        ),
        SidebarXItem(
          icon: iconSelectedSidebar == 2
              ? PhosphorIcons.storefront_fill
              : PhosphorIcons.storefront,
          label: 'Toko',
          onTap: () {
            widget.pageController.jumpToPage(0);
            widget.controller.selectedIndex;
            setState(() {
              selectedIndexSideBar = false;
              iconSelectedSidebar = 2;
              valueOrderByProduct = 0;
              print(iconSelectedSidebar);
            });
          },
        ),
        SidebarXItem(
          icon: iconSelectedSidebar == 3
              ? PhosphorIcons.shopping_bag_open_fill
              : PhosphorIcons.shopping_bag_open,
          label: 'Produk',
          onTap: () {
            widget.pageController.jumpToPage(0);
            widget.controller.selectedIndex;
            setState(() {
              selectedIndexSideBar = false;
              iconSelectedSidebar = 3;
              valueOrderByProduct = 0;
              print(widget.controller.selectedIndex);
            });
          },
        ),
        SidebarXItem(
          icon: iconSelectedSidebar == 4
              ? PhosphorIcons.archive_box_fill
              : PhosphorIcons.archive_box,
          label: 'Inventori',
          onTap: () {
            widget.pageController.jumpToPage(0);
            widget.controller.selectedIndex;
            setState(() {
              selectedIndexSideBar = false;
              iconSelectedSidebar = 4;
              valueOrderByProduct = 0;
            });
          },
        ),
        // SidebarXItem(
        //   icon: iconSelectedSidebar == 5
        //       ? PhosphorIcons.circles_three_fill
        //       : PhosphorIcons.circles_three,
        //   label: 'BOM',
        //   onTap: () {
        //     widget.pageController.jumpToPage(0);
        //     widget.controller.selectedIndex;
        //     setState(() {
        //       selectedIndexSideBar = false;
        //       iconSelectedSidebar = 5;
        //       valueOrderByProduct = 0;
        //     });
        //   },
        // ),
        // SidebarXItem(
        //   icon: iconSelectedSidebar == 5
        //       ? PhosphorIcons.cardholder_fill
        //       : PhosphorIcons.cardholder,
        //   label: 'COA',
        //   onTap: () {
        //     widget.pageController.jumpToPage(0);
        //     widget.controller.selectedIndex;
        //     setState(() {
        //       selectedIndexSideBar = false;
        //       iconSelectedSidebar = 5;
        //       valueOrderByProduct = 0;
        //     });
        //   },
        // ),
        SidebarXItem(
          icon: iconSelectedSidebar == 5
              ? PhosphorIcons.shopping_cart_simple_fill
              : PhosphorIcons.shopping_cart_simple,
          label: 'Transaksi',
          onTap: () {
            widget.pageController.jumpToPage(0);
            widget.controller.selectedIndex;
            setState(() {
              selectedIndexSideBar = false;
              iconSelectedSidebar = 5;
              valueOrderByProduct = 0;
            });
          },
        ),
        // SidebarXItem(
        //   icon: iconSelectedSidebar == 6
        //       ? PhosphorIcons.money_fill
        //       : PhosphorIcons.money,
        //   label: 'Keuangan',
        //   onTap: () {
        //     widget.pageController.jumpToPage(0);
        //     widget.controller.selectedIndex;
        //     setState(() {
        //       selectedIndexSideBar = false;
        //       iconSelectedSidebar = 6;
        //       valueOrderByProduct = 0;
        //     });
        //   },
        // ),
        SidebarXItem(
          icon: iconSelectedSidebar == 6
              ? PhosphorIcons.identification_card_fill
              : PhosphorIcons.identification_card,
          label: 'Pelanggan',
          onTap: () {
            widget.pageController.jumpToPage(0);
            widget.controller.selectedIndex;
            setState(() {
              selectedIndexSideBar = false;
              iconSelectedSidebar = 6;
              valueOrderByProduct = 0;
            });
          },
        ),
        SidebarXItem(
          icon: iconSelectedSidebar == 7
              ? PhosphorIcons.tag_fill
              : PhosphorIcons.tag,
          label: 'Promo',
          onTap: () {
            widget.pageController.jumpToPage(0);
            widget.controller.selectedIndex;
            setState(() {
              selectedIndexSideBar = false;
              iconSelectedSidebar = 7;
              valueOrderByProduct = 0;
            });
          },
        ),
        SidebarXItem(
          icon: iconSelectedSidebar == 8
              ? PhosphorIcons.file_text_fill
              : PhosphorIcons.file_text,
          label: 'Laporan',
          onTap: () {
            widget.pageController.jumpToPage(0);
            widget.controller.selectedIndex;
            setState(() {
              selectedIndexSideBar = false;
              iconSelectedSidebar = 8;
            });
          },
        ),
        SidebarXItem(
          icon: iconSelectedSidebar == 9
              ? PhosphorIcons.question_fill
              : PhosphorIcons.question,
          label: 'Bantuan',
          onTap: () {
            widget.pageController.jumpToPage(0);
            widget.controller.selectedIndex;
            setState(() {
              selectedIndexSideBar = false;
              iconSelectedSidebar = 9;
            });
          },
        ),
        SidebarXItem(
          icon: iconSelectedSidebar == 10
              ? PhosphorIcons.printer_fill
              : PhosphorIcons.printer,
          label: 'Printer',
          onTap: () {
            widget.pageController.jumpToPage(0);
            widget.controller.selectedIndex;
            setState(() {
              selectedIndexSideBar = false;
              iconSelectedSidebar = 10;
            });
          },
        ),
      ],
    );
  }
}

class _ScreensExample extends StatefulWidget {
  String token;
  _ScreensExample({
    Key? key,
    required this.token,
    required this.controller,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  State<_ScreensExample> createState() => _ScreensExampleState();
}

class _ScreensExampleState extends State<_ScreensExample> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        // print(widget.controller.selectedIndex);
        // widget.controller.jumpToPage(0);
        // widget.controller.selectIndex(widget.controller.selectedIndex - 1);
        // showModalBottomExit(context);
        return true;
      },
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          // final pageTitle = _getTitleByIndex(widget.controller.selectedIndex);

          switch (widget.controller.selectedIndex) {
            case 0:
              // case 1:
              return Dashboarpagenew(token: widget.token);
            case 1:
              return NotifikasiGrup();

            case 2:
              return TokoPageToko(token: widget.token);
            case 3:
              return ProdukToko(token: widget.token);
            // case 3:
            // return InventoriPage(token: widget.token);
            // return COAPage(token: widget.token);
            case 4:
              return typeAccount == 'Merchant_Only'
                  ? InventoriPageMerchantOnly(token: widget.token)
                  : InventoriPageTest(token: widget.token);

            // return UnitConvertionPage(token: widget.token);

            // case 5:
            //   return UnitConvertionPage(token: widget.token);

            // case 5:
              // return InventoriPage(token: widget.token);
              // return COAPage(token: widget.token);
            case 5:
              return TransactionPage(token: widget.token);
            // case 6:
            //   return LihatKeuanganToko(token: widget.token);
            case 6:
              // case 7:
              return PelangganToko(token: widget.token);

            case 7:
              return PromosiToko(token: widget.token);
            case 8:
              return LaporanToko(
                token: widget.token,
                controller: widget.controller,
              );
            // return TestingSaja();
            case 9:
              return BantuanGrup();
            case 10:
              return BluetoothPage();
            default:
              return Text(
                'Not found page',
                // style: theme.textTheme.headlzine5,
              );
          }
        },
      ),
    );
  }
}

String _getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return 'Notifikasi';
    case 1:
      return 'Dashboard';
    case 2:
      return 'Toko';
    case 3:
      return 'Produk';
    case 4:
      return 'Inventori';
    default:
      return 'Not found page';
  }
}
