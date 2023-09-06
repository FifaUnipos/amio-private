import 'dart:developer';

import 'package:amio/utils/component.dart';
import 'package:flutter/material.dart';

import 'package:amio/services/apimethod.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../models/tokoModel/rekonModel.dart';

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
  PageController pageController = PageController();
  String? year, month;

  @override
  void initState() {
    pageController = PageController(
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
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        getYear(),
        getMonth(),
        reconPage(),
      ],
    );
  }

  reconPage() {
    return FutureBuilder<List<RekonModel>>(
      future: getRekon(widget.token, year, month),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<RekonModel>? data = snapshot.data;

          return Column(
            children: [
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: primary500,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Row(
                          children: [
                            Icon(PhosphorIcons.calendar_blank_fill,
                                color: bnw100),
                            const SizedBox(width: 10),
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ExpansionPanelList(
                    elevation: 0,
                    children: data!.map<ExpansionPanel>((item) {
                      return ExpansionPanel(
                        backgroundColor: primary100,
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.hari!,
                                      style: heading4(
                                          FontWeight.w400, bnw900, 'Outfit'),
                                    ),
                                    Text(
                                      item.tanggal!,
                                      style: heading4(
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                  ],
                                ),
                                item.statusS == 0
                                    ? Container()
                                    : Container(
                                        width: 80,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: succes100,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Sesuai : ${item.statusBD.toString()}',
                                            style: heading4(FontWeight.w600,
                                                succes600, 'Outfit'),
                                          ),
                                        ),
                                      ),
                                item.statusTS == 0
                                    ? Container()
                                    : Container(
                                        width: 80,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: bnw200,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Sesuai : ${item.statusTS.toString()}',
                                            style: heading4(FontWeight.w600,
                                                bnw500, 'Outfit'),
                                          ),
                                        ),
                                      ),
                                item.statusBD == 0
                                    ? Container()
                                    : Container(
                                        width: 80,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: danger100,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Sesuai : ${item.statusBD.toString()}',
                                            style: heading4(FontWeight.w600,
                                                danger500, 'Outfit'),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          );
                        },
                        body: Container(
                          color: primary200,
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 10 / 2,
                            ),
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: item.detail!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: bnw100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: EdgeInsets.all(8),
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.detail![index].namePayment
                                              .toString(),
                                          style: heading4(FontWeight.w600,
                                              bnw900, 'Outfit'),
                                        ),
                                        Text(
                                          item.detail![index].value.toString(),
                                          style: heading4(FontWeight.w400,
                                              bnw900, 'Outfit'),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        item.detail![index].status == '0'
                                            ? Container(
                                                padding: EdgeInsets.only(
                                                    left: 8, right: 8),
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: bnw200,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Tidak Sesuai',
                                                    style: heading4(
                                                        FontWeight.w600,
                                                        bnw500,
                                                        'Outfit'),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        SizedBox(width: 8),
                                        Icon(
                                          PhosphorIcons.pencil,
                                          color: primary500,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        isExpanded: item.expanded,
                      );
                    }).toList(),
                    // animationDuration: const Duration(milliseconds: 1000),

                    expansionCallback: (index, isExpanded) {
                      setState(() {
                        data[index].expanded = !isExpanded;
                        // data[index].refresh();
                        print(data[index].expanded);
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);

          return Text(snapshot.error.toString());
        }
        return const SizedBox(
          height: 40,
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  getYear() {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          width: width,
          child: Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primary500,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.calendar_blank_fill,
                                  color: bnw100),
                              const SizedBox(width: 10),
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
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
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
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (builder, index) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          year =
                                              (data![index]['year'].toString());
                                        });
                                        pageController.jumpToPage(1);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 12, 0, 12),
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
                                                  const SizedBox(width: 10),
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
                                    const Divider(thickness: 1.2)
                                  ],
                                );
                              },
                            );
                          }

                          return loading();
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
          duration: const Duration(seconds: 1),
          width: width,
          child: Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primary500,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.calendar_blank_fill,
                                  color: bnw100),
                              const SizedBox(width: 10),
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
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: FutureBuilder(
                        future: getMonthRekon(widget.token, year, ''),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data;
                            // print(snapshot.data);
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: snapshot.data.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (builder, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      month = data![index]['angkaBulan'];
                                    });
                                    pageController.jumpToPage(2);
                                  },
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 12, 12, 12),
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
                                                const SizedBox(width: 10),
                                                Text(
                                                  data![index]['bulan']
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
                                      const Divider(thickness: 1.2)
                                    ],
                                  ),
                                );
                              },
                            );
                          }

                          return loading();
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
