import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/apimethod.dart';
import '../../../../utils/component/component_showModalBottom.dart';

import '../../../tokopage/sidebar/transaksiToko/transaksi.dart';
import '../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';

class PengaturanGrup extends StatefulWidget {
  String token, namemerch, merchid;
  PageController pageController;
  TabController tabController;
  PengaturanGrup({
    Key? key,
    required this.token,
    required this.namemerch,
    required this.merchid,
    required this.pageController,
    required this.tabController,
  }) : super(key: key);

  @override
  State<PengaturanGrup> createState() => _PengaturanGrupState();
}

class _PengaturanGrupState extends State<PengaturanGrup> {
  File? myImage;
  Uint8List? bytes;
  String? img64;
  List<String> images = [];

  Future<void> getImage() async {
    var picker = ImagePicker();
    PickedFile? image;

    image = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 900,
      maxWidth: 900,
    );
    if (image!.path.isEmpty == false) {
      myImage = File(image.path);

      bytes = await Io.File(myImage!.path).readAsBytes();
      setState(() {
        img64 = base64Encode(bytes!);
        images.add(img64!);
      });
      // Clipboard.setData(ClipboardData(text: img64));
    } else {
      print('Error Image');
    }
  }

  @override
  void initState() {
    getStruk(context, widget.token, widget.merchid);
    getQris(context, widget.token, widget.merchid);
    super.initState();
  }

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
          SizedBox(height: size16),
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
                            'Pembayaran QRIS',
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          Text(
                            logoQris != '' ? 'Terhubung' : 'Belum Terhubung',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: size16),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                getQris(context, widget.token, widget.merchid)
                                    .then((value) {
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
                                          Column(
                                        children: [
                                          Text(
                                            'Pembayaran QRIS',
                                            style: heading1(FontWeight.w600,
                                                bnw900, 'Outfit'),
                                          ),
                                          SizedBox(height: size16),
                                          Container(
                                            height: 260,
                                            width: 260,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(size8),
                                              border: Border.all(color: bnw300),
                                            ),
                                            child: logoQris == ''
                                                ? Icon(PhosphorIcons.plus)
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size8),
                                                    child: Image.network(
                                                      logoQris ?? '',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              await getImage().then(
                                                (value) => uploadQris(
                                                  context,
                                                  widget.token,
                                                  img64,
                                                  widget.merchid,
                                                ).then(
                                                  (value) {
                                                    // Navigator.pop(context);
                                                  },
                                                ),
                                              );
                                              setState(() {});
                                              initState();
                                            },
                                            child: SizedBox(
                                              child: TextFormField(
                                                enabled: false,
                                                style: heading3(FontWeight.w400,
                                                    bnw900, 'Outfit'),
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: size16),
                                                    isDense: true,
                                                    focusColor: primary500,
                                                    prefixIcon: Icon(
                                                      size: size24,
                                                      logoQris != ''
                                                          ? PhosphorIcons
                                                              .pencil_line
                                                          : PhosphorIcons.plus,
                                                      color: bnw900,
                                                    ),
                                                    hintText: logoQris != ''
                                                        ? 'Atur QRIS'
                                                        : 'Tambah QRIS',
                                                    hintStyle: heading3(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit')),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: size16),
                                          logoQris != ''
                                              ? GestureDetector(
                                                  onTap: () async {
                                                    deleteQris(
                                                      context,
                                                      widget.token,
                                                      widget.merchid,
                                                    );
                                                    setState(() {});
                                                    initState();
                                                  },
                                                  child: SizedBox(
                                                    child: TextFormField(
                                                      enabled: false,
                                                      style: heading3(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                      decoration:
                                                          InputDecoration(
                                                              focusColor:
                                                                  primary500,
                                                              prefixIcon: Icon(
                                                                PhosphorIcons
                                                                    .trash,
                                                                size: size24,
                                                                color: bnw900,
                                                              ),
                                                              hintText:
                                                                  'Hapus QRIS',
                                                              hintStyle:
                                                                  heading3(
                                                                      FontWeight
                                                                          .w400,
                                                                      bnw900,
                                                                      'Outfit')),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                });
                              },
                              child: logoQris != ''
                                  ? buttonXLoutline(
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(PhosphorIcons.pencil_line,
                                              color: primary500),
                                          SizedBox(width: size12),
                                          Text(
                                            'Atur QRIS',
                                            style: heading3(FontWeight.w600,
                                                primary500, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      0,
                                      primary500,
                                    )
                                  : buttonXL(
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(PhosphorIcons.plus,
                                              color: bnw100),
                                          SizedBox(width: size12),
                                          Text(
                                            'Tambah QRIS',
                                            style: heading3(FontWeight.w600,
                                                bnw100, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      0,
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
                            logoStruk == '' ? 'Belum Terhubung' : 'Terhubung',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: size16),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                getStruk(context, widget.token, widget.merchid)
                                    .then((value) {
                                  value == '00'
                                      ? showBottomPilihan(
                                          context,
                                          Column(
                                            children: [
                                              Text(
                                                'Logo Struk',
                                                style: heading1(FontWeight.w600,
                                                    bnw900, 'Outfit'),
                                              ),
                                              SizedBox(height: size16),
                                              Container(
                                                height: 260,
                                                width: 260,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size8),
                                                  border:
                                                      Border.all(color: bnw300),
                                                ),
                                                child: logoStruk == ''
                                                    ? Icon(PhosphorIcons.plus)
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    size8),
                                                        child: Image.network(
                                                          logoStruk ?? '',
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                              ),
                                              SizedBox(height: size16),
                                              GestureDetector(
                                                onTap: () async {
                                                  await getImage().then(
                                                      (value) => uploadStruk(
                                                            context,
                                                            widget.token,
                                                            img64,
                                                            widget.merchid,
                                                          ));
                                                  setState(() {});
                                                  initState();
                                                },
                                                child: SizedBox(
                                                  child: TextFormField(
                                                    enabled: false,
                                                    style: heading3(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit'),
                                                    decoration: InputDecoration(
                                                        focusColor: primary500,
                                                        prefixIcon: Icon(
                                                          logoStruk != ''
                                                              ? PhosphorIcons
                                                                  .pencil_line
                                                              : PhosphorIcons
                                                                  .plus,
                                                          color: bnw900,
                                                        ),
                                                        hintText: logoStruk !=
                                                                ''
                                                            ? 'Atur Struk'
                                                            : 'Tambah Struk',
                                                        hintStyle: heading3(
                                                            FontWeight.w400,
                                                            bnw900,
                                                            'Outfit')),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: size16),
                                              logoStruk != ''
                                                  ? GestureDetector(
                                                      onTap: () async {
                                                        deleteStruk(
                                                          context,
                                                          widget.token,
                                                          widget.merchid,
                                                        );

                                                        setState(() {});
                                                        initState();
                                                      },
                                                      child: SizedBox(
                                                        child: TextFormField(
                                                          enabled: false,
                                                          style: heading3(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                          decoration:
                                                              InputDecoration(
                                                                  focusColor:
                                                                      primary500,
                                                                  prefixIcon:
                                                                      Icon(
                                                                    PhosphorIcons
                                                                        .trash,
                                                                    color:
                                                                        bnw900,
                                                                  ),
                                                                  hintText:
                                                                      'Hapus Struk',
                                                                  hintStyle: heading3(
                                                                      FontWeight
                                                                          .w400,
                                                                      bnw900,
                                                                      'Outfit')),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                            ],
                                          ),
                                        )
                                      : null;
                                });
                                setState(() {});
                              },
                              child: logoStruk != ''
                                  ? buttonXLoutline(
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(PhosphorIcons.pencil_line,
                                              color: primary500),
                                          SizedBox(width: size12),
                                          Text(
                                            'Atur Struk',
                                            style: heading3(FontWeight.w600,
                                                primary500, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      0,
                                      primary500)
                                  : buttonXL(
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(PhosphorIcons.plus,
                                              color: bnw100),
                                          SizedBox(width: size12),
                                          Text(
                                            'Tambah Struk',
                                            style: heading3(FontWeight.w600,
                                                bnw100, 'Outfit'),
                                          ),
                                        ],
                                      ),
                                      0,
                                    ),
                            ),
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
