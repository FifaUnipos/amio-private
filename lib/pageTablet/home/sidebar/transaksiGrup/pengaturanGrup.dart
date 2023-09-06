import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../services/apimethod.dart';
import '../../../../utils/component.dart';

class PengaturanGrup extends StatefulWidget {
  String token, namemerch;
  PageController pageController;
  TabController tabController;
  PengaturanGrup({
    Key? key,
    required this.token,
    required this.namemerch,
    required this.pageController,
    required this.tabController,
  }) : super(key: key);

  @override
  State<PengaturanGrup> createState() => _PengaturanGrupState();
}

class _PengaturanGrupState extends State<PengaturanGrup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  widget.pageController.jumpToPage(0);
                },
                child: Icon(
                  PhosphorIcons.arrow_left,
                  size: size48,
                  color: bnw900,
                ),
              ),
              SizedBox(width: size12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaksi',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    widget.namemerch,
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TabBar(
              controller: widget.tabController,
              automaticIndicatorColorAdjustment: false,
              indicatorColor: primary500,
              labelColor: primary500,
              labelStyle: heading2(FontWeight.w400, bnw900, 'Outfit'),
              unselectedLabelColor: bnw600,
              physics: NeverScrollableScrollPhysics(),
              onTap: (value) {
                if (value == 0) {
                  widget.pageController.animateToPage(
                    1,
                    duration: Duration(milliseconds: 10),
                    curve: Curves.ease,
                  );
                } else if (value == 1) {
                  widget.pageController.animateToPage(
                    2,
                    duration: Duration(milliseconds: 10),
                    curve: Curves.ease,
                  );
                }
              },
              tabs: [
                Tab(
                  text: 'Tagihan',
                ),
                Tab(
                  text: 'Riwayat',
                ),
                Tab(
                  text: 'Pengaturan',
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: size12, bottom: size12),
            child: Text(
              'Metode Pembayaran',
              style: heading2(FontWeight.w700, bnw900, 'Outfit'),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(size16),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: bnw300),
                      borderRadius: BorderRadius.circular(size16),
                      color: bnw100,
                    ),
                    child: Column(children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(size12),
                          height: double.infinity,
                          width: double.infinity,
                          child: Image.asset(
                            'assets/qrislogo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QRIS',
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          Text(
                            'Terhubung',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: size16),
                          SizedBox(
                            width: double.infinity,
                            child: InkWell(
                              onTap: () {
                                showBottomPilihan(
                                  context,
                                  Center(
                                    // child: myImage != null
                                    child:
                                        // logoQris.isNotEmpty
                                        //     ? Image.network(
                                        //         logoQris,
                                        //         fit: BoxFit.fill,
                                        //       )
                                        //     :
                                        GestureDetector(
                                      onTap: () async {
                                        // await getImage().then(
                                        //   (value) => uploadQris(
                                        //     context,
                                        //     widget.token,
                                        //     img64,
                                        //   ).then(
                                        //     (value) {
                                        //       // Navigator.pop(context);
                                        //     },
                                        //   ),
                                        // );
                                      },
                                      child: Icon(PhosphorIcons.plus),
                                    ),
                                  ),
                                );
                              },
                              child: buttonXLoutline(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(PhosphorIcons.plus, color: primary500),
                                    SizedBox(width: size12),
                                    Text(
                                      'Tambah QRIS',
                                      style: heading3(FontWeight.w600,
                                          primary500, 'Outfit'),
                                    ),
                                  ],
                                ),
                                0,
                                primary500,
                              ),
                            ),
                          ),
                        ],
                      )
                    ]),
                  ),
                ),
                SizedBox(width: size12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(size16),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: bnw300),
                      borderRadius: BorderRadius.circular(size16),
                      color: bnw100,
                    ),
                    child: Column(children: [
                      Expanded(
                        child: Container(
                            padding: EdgeInsets.all(size12),
                            height: double.infinity,
                            width: double.infinity,
                            child: SvgPicture.asset('assets/logoStruk.svg')
                            // Image.asset(
                            //   'assets/fifapaylogolong.png',
                            //   fit: BoxFit.contain,
                            // ),
                            ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logo Pada Struk',
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          Text(
                            'Belum Terhubung',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: size16),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                                // onTap: () => getImage().then((value) =>
                                //     uploadStruk(
                                //         context, widget.token, logoStruk)),
                                child: buttonXLoutline(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(PhosphorIcons.plus,
                                            color: primary500),
                                        SizedBox(width: size12),
                                        Text(
                                          'Tambah',
                                          style: heading3(FontWeight.w600,
                                              primary500, 'Outfit'),
                                        ),
                                      ],
                                    ),
                                    0,
                                    primary500)),
                          ),
                        ],
                      )
                    ]),
                  ),
                ),

                // Container(
                //   padding:  EdgeInsets.all(size16),
                //   height: MediaQuery.of(context).size.height,
                //   width: MediaQuery.of(context).size.width / 2.6,
                //   decoration: BoxDecoration(
                //     border: Border.all(color: bnw300),
                //     borderRadius: BorderRadius.circular(size16),
                //     color: bnw100,
                //   ),
                //   child: Column(children: [
                //     Expanded(
                //       child: Container(
                //         padding:  EdgeInsets.all(size12),
                //         height: double.infinity,
                //         width: double.infinity,
                //         child: Image.asset(
                //           'assets/fifapaylogolong.png',
                //           fit: BoxFit.contain,
                //         ),
                //       ),
                //     ),
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(
                //           'Fifapay',
                //           style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                //         ),
                //         Text(
                //           'Belum Terhubung',
                //           style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                //         ),
                //          SizedBox(height: 18),
                //         buttonXLoutline(
                //             Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Icon(PhosphorIcons.plus, color: primary500),
                //                  SizedBox(width: size12),
                //                 Text(
                //                   'Hubungkan Fifapay',
                //                   style: heading3(
                //                       FontWeight.w600, primary500, 'Outfit'),
                //                 ),
                //               ],
                //             ),
                //             double.infinity,
                //             primary500)
                //       ],
                //     )
                //   ]),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
