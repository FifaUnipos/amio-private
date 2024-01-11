import 'dart:developer';

import 'package:amio/utils/component.dart';
import 'package:flutter/material.dart';

import 'package:amio/services/apimethod.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../models/tokoModel/rekonModel.dart';

PageController rekonPageController = PageController();
String? yearRekon, monthRekon;

class RekonToko extends StatefulWidget {
  String token;
  RekonToko({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<RekonToko> createState() => _RekonTokoState();
}

class _RekonTokoState extends State<RekonToko> {
  int tapTrue = 0;

  @override
  void initState() {
    getRekon(widget.token, yearRekon, monthRekon);
    rekonPageController = PageController(
      initialPage: 0,
      keepPage: true,
      viewportFraction: 1,
    );

    super.initState();
  }

  double widtValue = 80;
  double? width;

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: rekonPageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        getYear(),
        getMonth(),
        RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            await getRekon(widget.token, yearRekon, monthRekon);
          },
          child: FutureBuilder(
            future: getRekon(widget.token, yearRekon, monthRekon),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //List<RekonModel>? data = snapshot.data;
                var data = snapshot.data;
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
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      rekonPageController.jumpToPage(1);
                                    },
                                    child: Icon(PhosphorIcons.arrow_left,
                                        color: bnw100),
                                  ),
                                  SizedBox(width: size16),
                                  Text(
                                    'Rekonsiliasi - Bulan ${data['bulanTahun']}',
                                    style: heading4(
                                        FontWeight.w700, bnw100, 'Outfit'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                        color: primary100,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(size12),
                          bottomRight: Radius.circular(size12),
                        ),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: data['rekonsiliasi'].length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ExpansionTile(
                                backgroundColor: primary200,
                                trailing: Icon(
                                  PhosphorIcons.caret_down_fill,
                                  color: bnw900,
                                ),
                                title: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            data['rekonsiliasi'][index]['hari'],
                                            style: heading4(FontWeight.w400,
                                                bnw900, 'Outfit')),
                                        Text(
                                            data['rekonsiliasi'][index]
                                                ['tanggal'],
                                            style: heading4(FontWeight.w600,
                                                bnw900, 'Outfit')),
                                      ],
                                    ),
                                    Spacer(),
                                    data['rekonsiliasi'][index]['status']
                                                    ['belumDiCek']
                                                .toString() ==
                                            '0'
                                        ? Container()
                                        : buttonLoutlineColor(
                                            Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text('Belum Dicek : ',
                                                        style: heading4(
                                                            FontWeight.w600,
                                                            danger500,
                                                            'Outfit')),
                                                    Text(
                                                        data['rekonsiliasi']
                                                                        [index]
                                                                    ['status']
                                                                ['belumDiCek']
                                                            .toString(),
                                                        style: heading4(
                                                            FontWeight.w600,
                                                            danger500,
                                                            'Outfit')),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            danger100,
                                            danger100,
                                          ),
                                    SizedBox(width: size16),
                                    data['rekonsiliasi'][index]['status']
                                                    ['tidakSesuai']
                                                .toString() ==
                                            '0'
                                        ? Container()
                                        : buttonLoutlineColor(
                                            Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text('Tidak Sesuai : ',
                                                        style: heading4(
                                                            FontWeight.w600,
                                                            bnw500,
                                                            'Outfit')),
                                                    Text(
                                                        data['rekonsiliasi']
                                                                        [index]
                                                                    ['status']
                                                                ['tidakSesuai']
                                                            .toString(),
                                                        style: heading4(
                                                            FontWeight.w600,
                                                            bnw500,
                                                            'Outfit')),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            bnw200,
                                            bnw200,
                                          ),
                                    SizedBox(width: size16),
                                    data['rekonsiliasi'][index]['status']
                                                    ['sesuai']
                                                .toString() ==
                                            '0'
                                        ? Container()
                                        : buttonLoutlineColor(
                                            Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text('Sesuai : ',
                                                        style: heading4(
                                                            FontWeight.w600,
                                                            succes500,
                                                            'Outfit')),
                                                    Text(
                                                        data['rekonsiliasi']
                                                                        [index]
                                                                    ['status']
                                                                ['sesuai']
                                                            .toString(),
                                                        style: heading4(
                                                            FontWeight.w600,
                                                            succes500,
                                                            'Outfit')),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            succes100,
                                            succes100,
                                          ),
                                    SizedBox(width: size16),
                                  ],
                                ),
                                children: [
                                  if (data['rekonsiliasi'][index]['detail']
                                      .isEmpty)
                                    Container(),
                                  Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.all(size16),
                                    child: Wrap(
                                      spacing: size8,
                                      runSpacing: size8,
                                      children: data['rekonsiliasi'][index]
                                              ['detail']
                                          .map<Widget>((detailItem) {
                                        return Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.7,
                                          padding: EdgeInsets.all(size8),
                                          decoration: BoxDecoration(
                                            color: bnw100,
                                            border: Border.all(color: bnw300),
                                            borderRadius:
                                                BorderRadius.circular(size8),
                                          ),
                                          child: Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${detailItem['payment_method']['payment_method']}',
                                                    style: heading4(
                                                        FontWeight.w600,
                                                        bnw900,
                                                        'Outfit'),
                                                  ),
                                                  Text(
                                                      FormatCurrency
                                                          .convertToIdr(
                                                              detailItem[
                                                                  'amount']),
                                                      style: heading4(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit')),
                                                  // Add other details from 'detailItem'
                                                ],
                                              ),
                                              Spacer(),
                                              detailItem['isDone'] == '0'
                                                  ? buttonLoutlineColor(
                                                      Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  'Belum Dicek',
                                                                  style: heading4(
                                                                      FontWeight
                                                                          .w600,
                                                                      danger500,
                                                                      'Outfit')),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      danger100,
                                                      danger100,
                                                    )
                                                  : detailItem['isDone'] == '1'
                                                      ? buttonLoutlineColor(
                                                          Row(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      'Tidak Sesuai',
                                                                      style: heading4(
                                                                          FontWeight
                                                                              .w600,
                                                                          bnw900,
                                                                          'Outfit')),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          bnw200,
                                                          bnw200,
                                                        )
                                                      : buttonLoutlineColor(
                                                          Row(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text('Sesuai',
                                                                      style: heading4(
                                                                          FontWeight
                                                                              .w600,
                                                                          succes500,
                                                                          'Outfit')),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          succes100,
                                                          succes100,
                                                        ),
                                              SizedBox(width: size16),
                                              GestureDetector(
                                                onTap: () {
                                                  tapTrue = 0;
                                                  showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(
                                                      builder:
                                                          (context, setState) =>
                                                              IntrinsicHeight(
                                                        child: Container(
                                                          padding: EdgeInsets.only(
                                                              bottom: MediaQuery
                                                                      .of(context)
                                                                  .viewInsets
                                                                  .bottom),
                                                          // height: MediaQuery.of(context).size.height / 1,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: bnw100,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topRight: Radius
                                                                  .circular(12),
                                                              topLeft: Radius
                                                                  .circular(12),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    size32,
                                                                    size16,
                                                                    size32,
                                                                    size32),
                                                            child: Column(
                                                              children: [
                                                                dividerShowdialog(),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                        height:
                                                                            size16),
                                                                    Text(
                                                                      'Tunai',
                                                                      style: heading1(
                                                                          FontWeight
                                                                              .w700,
                                                                          bnw900,
                                                                          'Outfit'),
                                                                    ),
                                                                    Text(
                                                                      'Konfirmasi data sesuai atau tidak tidak ',
                                                                      style: heading4(
                                                                          FontWeight
                                                                              .w400,
                                                                          bnw700,
                                                                          'Outfit'),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            size16),
                                                                    Container(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            'Pilih Tipe Pesanan',
                                                                            style: heading2(
                                                                                FontWeight.w400,
                                                                                bnw900,
                                                                                'Outfit'),
                                                                          ),
                                                                          SizedBox(
                                                                              height: size16),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      tapTrue = 2;
                                                                                    });
                                                                                  },
                                                                                  child: IntrinsicWidth(
                                                                                    child: Container(
                                                                                      height: size56,
                                                                                      padding: EdgeInsets.symmetric(horizontal: size20),
                                                                                      decoration: ShapeDecoration(
                                                                                        color: tapTrue == 2 ? primary100 : bnw100,
                                                                                        shape: RoundedRectangleBorder(
                                                                                          side: BorderSide(
                                                                                            width: width2,
                                                                                            color: tapTrue == 2 ? primary500 : bnw300,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(size8),
                                                                                        ),
                                                                                      ),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Text('Sesuai', style: heading3(FontWeight.w400, tapTrue == 2 ? primary500 : bnw900, 'Outfit')),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: size16),
                                                                              Expanded(
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      tapTrue = 1;
                                                                                    });
                                                                                  },
                                                                                  child: IntrinsicWidth(
                                                                                    child: Container(
                                                                                      height: size56,
                                                                                      padding: EdgeInsets.symmetric(horizontal: size20),
                                                                                      decoration: ShapeDecoration(
                                                                                        color: tapTrue == 1 ? primary100 : bnw100,
                                                                                        shape: RoundedRectangleBorder(
                                                                                          side: BorderSide(
                                                                                            width: width2,
                                                                                            color: tapTrue == 1 ? primary500 : bnw300,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(size8),
                                                                                        ),
                                                                                      ),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Text('Tidak Sesuai', style: heading3(FontWeight.w400, tapTrue == 1 ? primary500 : bnw900, 'Outfit')),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            size16),
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          'Keterangan ',
                                                                          style: heading4(
                                                                              FontWeight.w400,
                                                                              bnw900,
                                                                              'Outfit'),
                                                                        ),
                                                                        Text(
                                                                          '*',
                                                                          style: heading4(
                                                                              FontWeight.w400,
                                                                              danger500,
                                                                              'Outfit'),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    FocusScope(
                                                                      child:
                                                                          Focus(
                                                                        onFocusChange:
                                                                            (value) {
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        child:
                                                                            TextFormField(
                                                                          style:
                                                                              heading2(
                                                                            FontWeight.w600,
                                                                            bnw900,
                                                                            'Outfit',
                                                                          ),
                                                                          decoration: InputDecoration(
                                                                              focusColor: primary500,
                                                                              hintText: 'Cth : Tidak sesuai dengan pengeluaran',
                                                                              hintStyle: heading2(
                                                                                FontWeight.w600,
                                                                                bnw400,
                                                                                'Outfit',
                                                                              )),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        size32),
                                                                tapTrue == 0
                                                                    ? Container()
                                                                    : Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceAround,
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                GestureDetector(
                                                                              onTap: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: buttonXLoutline(
                                                                                Center(
                                                                                  child: Text(
                                                                                    'Batal',
                                                                                    style: heading3(FontWeight.w600, primary500, 'Outfit'),
                                                                                  ),
                                                                                ),
                                                                                MediaQuery.of(context).size.width,
                                                                                primary500,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: size16),
                                                                          Expanded(
                                                                            child:
                                                                                GestureDetector(
                                                                              onTap: () {
                                                                                whenLoading(context);
                                                                                saveRekon(context, widget.token, detailItem['id'], tapTrue.toString());
                                                                                errorText = '';

                                                                                setState(() {
                                                                                  getRekon(widget.token, yearRekon, monthRekon);
                                                                                  data = snapshot.data;
                                                                                });
                                                                              },
                                                                              child: buttonXL(
                                                                                Center(
                                                                                  child: Text(
                                                                                    'Simpan',
                                                                                    style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                                                                                  ),
                                                                                ),
                                                                                MediaQuery.of(context).size.width,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  PhosphorIcons.pencil_line,
                                                  color: primary500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    )),
                    SizedBox(height: size16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(size8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(size8),
                              border: Border.all(color: bnw300),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: primary100,
                                    borderRadius: BorderRadius.circular(size8),
                                  ),
                                  padding: EdgeInsets.all(size12),
                                  child: Center(
                                    child: Icon(
                                      PhosphorIcons.money_fill,
                                      color: primary500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Keseluruhan',
                                      style: heading3(
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                    Text(
                                        FormatCurrency.convertToIdr(
                                            data['total_keseluruhan']),
                                        style: heading3(FontWeight.w700,
                                            primary500, 'Outfit')),
                                  ],
                                ),
                                Spacer(),
                                Icon(
                                  PhosphorIcons.dots_three_vertical,
                                  color: bnw900,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: size16),
                        pendapatanDetail(data, 'Belum Dicek', 'belumDiCek',
                            PhosphorIcons.square),
                        SizedBox(width: size16),
                        pendapatanDetail(data, 'Tidak Sesuai', 'tidakSesuai',
                            PhosphorIcons.x),
                        SizedBox(width: size16),
                        pendapatanDetail(data, 'Sesuai', 'sesuai',
                            PhosphorIcons.check_square),
                      ],
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
                print(snapshot.data);

                return Text(snapshot.error.toString());
              }
              return SizedBox(
                width: size20,
                height: size20,
                child: loading(),
              );
            },
          ),
        ),
      ],
    );
  }

  Container pendapatanDetail(data, title, status, iconData) {
    return Container(
        padding: EdgeInsets.all(size8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size8),
          border: Border.all(color: bnw300),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: primary100,
                borderRadius: BorderRadius.circular(size8),
              ),
              padding: EdgeInsets.all(size12),
              child: Center(
                child: Icon(
                  iconData,
                  color: primary500,
                ),
              ),
            ),
            SizedBox(width: size16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                ),
                Text(data['detail']['$status'].toString(),
                    style: heading3(FontWeight.w700, primary500, 'Outfit')),
              ],
            ),
            SizedBox(width: size16),
          ],
        ));
  }

  Row getYear() {
    return Row(
      children: [
        AnimatedContainer(
          duration: Duration(seconds: 1),
          width: width,
          child: Expanded(
            child: Column(
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
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.calendar_blank_fill,
                                  color: bnw100),
                              SizedBox(width: size16),
                              Text(
                                'Pilih Tahun Rekonsiliasi',
                                style:
                                    heading4(FontWeight.w700, bnw100, 'Outfit'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primary100,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(size12),
                        bottomRight: Radius.circular(size12),
                      ),
                    ),
                    child: FutureBuilder(
                        future: getYearRekon(widget.token),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data;
                            // print(snapshot.data);
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: snapshot.data.length,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (builder, index) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        setState(() {
                                          yearRekon =
                                              (data![index]['year'].toString());
                                        });
                                        rekonPageController.jumpToPage(1);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.fromLTRB(
                                            16, size12, 0, size12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                      PhosphorIcons
                                                          .calendar_blank_fill,
                                                      color: bnw900),
                                                  SizedBox(width: size16),
                                                  Text(
                                                    data![index]['year']
                                                        .toString(),
                                                    style: heading4(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(thickness: 1.2)
                                  ],
                                );
                              },
                            );
                          }

                          return Container();
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  getMonth() {
    return Row(
      children: [
        AnimatedContainer(
          duration: Duration(seconds: 1),
          width: width,
          child: Expanded(
            child: Column(
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
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  rekonPageController.jumpToPage(0);
                                },
                                child: Icon(PhosphorIcons.arrow_left,
                                    color: bnw100),
                              ),
                              SizedBox(width: size16),
                              Text(
                                'Bulan',
                                style:
                                    heading4(FontWeight.w700, bnw100, 'Outfit'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primary100,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(size12),
                        bottomRight: Radius.circular(size12),
                      ),
                    ),
                    child: FutureBuilder(
                        future: getMonthRekon(widget.token, yearRekon, ''),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data;
                            // print(snapshot.data);
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: snapshot.data.length,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (builder, index) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    setState(() {
                                      monthRekon =
                                          data![index]['bulan'].toString();
                                      getRekon(
                                          widget.token, yearRekon, monthRekon);
                                    });
                                    rekonPageController.jumpToPage(2);
                                  },
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            16, size12, size12, size12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                    PhosphorIcons
                                                        .calendar_blank_fill,
                                                    color: bnw900),
                                                SizedBox(width: size16),
                                                Text(
                                                  data![index]['bulanTahun']
                                                      .toString(),
                                                  style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                              ],
                                            ),
                                            data![index]['angka'] == 0
                                                ? Container(
                                                    width: 80,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: danger100,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Sesuai',
                                                        style: heading4(
                                                            FontWeight.w600,
                                                            danger500,
                                                            'Outfit'),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 80,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: succes100,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Sesuai ',
                                                        style: heading4(
                                                            FontWeight.w600,
                                                            succes600,
                                                            'Outfit'),
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                      Divider(thickness: 1.2)
                                    ],
                                  ),
                                );
                              },
                            );
                          }

                          return Container();
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
