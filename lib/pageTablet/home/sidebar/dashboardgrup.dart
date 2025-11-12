
// import 'package:flutter/material.dart';
// import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
// import 'package:unipos_app_335/main.dart';
// import 'package:unipos_app_335/services/apimethod.dart';
// import 'package:unipos_app_335/utils/component.dart';
// import '../../../../services/checkConnection.dart';

// class DashboardGrup extends StatefulWidget {
//   String token;
//   DashboardGrup({
//     Key? key,
//     required this.token,
//   }) : super(key: key);

//   @override
//   State<DashboardGrup> createState() => _DashboardGrupState();
// }

// class _DashboardGrupState extends State<DashboardGrup> {
//   @override
//   void initState() {
//     checkConnection(context);
//     super.initState();
//     dashboard(identifier, widget.token);

//     pendapatanDas;
//     membersDas;
//     transaksiDas;
//     rataTransaksiDas;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(12, 30, 12, 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: bnw100,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       height: MediaQuery.of(context).size.height,
//       width: MediaQuery.of(context).size.width,
//       child: Padding(
//         padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
//         child: ListView(
//           physics: BouncingScrollPhysics(),
//           children: [
//             Column(
//               // mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Dashboard',
//                   style: heading1(FontWeight.w700, Colors.black, 'Outfit'),
//                 ),
//                 Text(
//                   'Papan Informasi Toko',
//                   style: heading3(FontWeight.w300, Colors.black, 'Outfit'),
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.only(right: 12, top: 12),
//                       height: 330,
//                       width: 490,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: bnw300),
//                       ),
//                       child: Column(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             height: 140,
//                             decoration: BoxDecoration(
//                               color: primary200,
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     SizedBox(
//                                       child: Row(
//                                         children: [
//                                           Image.asset(
//                                             'assets/images/fifapaylogo.png',
//                                             height: 40,
//                                           ),
//                                           const SizedBox(width: 12),
//                                           Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 'FifaPay',
//                                                 style: heading2(FontWeight.w600,
//                                                     bnw900, 'Outfit'),
//                                               ),
//                                               Text(
//                                                 nameProfile ?? '',
//                                                 style: body1(FontWeight.w300,
//                                                     bnw900, 'Outfit'),
//                                               ),
//                                             ],
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                     Text(
//                                       "Rp. -",
//                                       style: heading1(
//                                           FontWeight.w700, bnw900, 'Outfit'),
//                                     )
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//                                 buttonXL(
//                                   Center(
//                                     child: Text(
//                                       'Hubungkan FifaPay',
//                                       style: heading3(
//                                           FontWeight.w600, bnw100, 'Outfit'),
//                                     ),
//                                   ),
//                                   MediaQuery.of(context).size.width,
//                                 )
//                               ],
//                             ),
//                           ),
//                           Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   frameDash(
//                                     'Pendapatan',
//                                     FormatCurrency.convertToIdr(pendapatanDas),
//                                     // 'Rp. $pendapatanDas',
//                                     '',
//                                     PhosphorIcons.money_fill,
//                                   ),
//                                   frameDash(
//                                     'Total Pelanggan',
//                                     membersDas,
//                                     'Pelanggan',
//                                     PhosphorIcons.users_three_fill,
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   frameDash(
//                                     'Transaksi',
//                                     transaksiDas,
//                                     'Produk Terjual',
//                                     PhosphorIcons.shopping_cart_simple_fill,
//                                   ),
//                                   frameDash(
//                                     'Rata - rata Perhari',
//                                     FormatCurrency.convertToIdr(
//                                         rataTransaksiDas),
//                                     'Transaksi',
//                                     PhosphorIcons.shopping_cart_simple_fill,
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Padding(
//                     //   padding: const EdgeInsets.only(top: 12, bottom: 12),
//                     //   child: Row(
//                     //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     //     children: [
//                     //       Text(
//                     //         'Analisis Penjualan',
//                     //         style: heading2(
//                     //             FontWeight.w600, Colors.black, 'Outfit'),
//                     //       ),
//                     //       SizedBox(width: 80),
//                     //       Row(
//                     //         children: [
//                     //           analisisBttn('1 Mg'),
//                     //           analisisBttn('1 Bln'),
//                     //           analisisBttn('3 Bln'),
//                     //           analisisBttn('6 Bln'),
//                     //           analisisBttn('1 Thn'),
//                     //         ],
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),

//                     FutureBuilder(
//                       future: getDataChart(context, widget.token),
//                       builder: (context, snapshot) {
//                         // log(data.toString());

//                         if (snapshot.hasData) {
//                           var data = snapshot.data!['data']['banner'];
//                           return SizedBox(
//                             width: MediaQuery.of(context).size.width / 2,
//                             child: ListView.builder(
//                               shrinkWrap: true,
//                               physics: NeverScrollableScrollPhysics(),
//                               itemCount: data.length,
//                               itemBuilder: (context, index) => Container(
//                                 decoration: BoxDecoration(
//                                   // border: Border.all(color: bnw300),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Image.network(
//                                   data[index]['banner'],
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           );
//                         }

//                         return loading();
//                       },
//                     ),

//                     // Container(
//                     //   height: 200,
//                     //   decoration: BoxDecoration(
//                     //     borderRadius: BorderRadius.circular(8),
//                     //     border: Border.all(color: bnw200),
//                     //     color: bnw100,
//                     //     boxShadow: [
//                     //       BoxShadow(
//                     //         color: bnw400,
//                     //         // spreadRadius: 5,
//                     //         blurRadius: 7,
//                     //         // offset: Offset(0, 3), // changes position of shadow
//                     //       ),
//                     //     ],
//                     //   ),
//                     //   child: FutureBuilder<List<dynamic>>(
//                     //     future: getDataChart(widget
//                     //         .token), // function that makes the HTTP POST request
//                     //     builder: (context, snapshot) {
//                     //       if (snapshot.hasData) {
//                     //         List<FlSpot> spots = [];
//                     //         for (int i = 0; i < snapshot.data!.length; i++) {
//                     //           spots.add(FlSpot(i.toDouble(),
//                     //               snapshot.data![i]['qty'].toDouble()));
//                     //         }
//                     //         return SizedBox(
//                     //           child: LineChartSample2(spots: spots),
//                     //         );
//                     //       } else if (snapshot.hasError) {
//                     //         return Text("${snapshot.error}");
//                     //       }
//                     //       return CircularProgressIndicator();
//                     //     },
//                     //   ),
//                     //   // child: LineChartSample2(),
//                     // ),

//                     // Container(
//                     //   margin: const EdgeInsets.only(top: 20),
//                     //   height: 200,
//                     //   decoration: BoxDecoration(
//                     //     borderRadius: BorderRadius.circular(8),
//                     //     border: Border.all(color: bnw200),
//                     //     color: bnw100,
//                     //     boxShadow: [
//                     //       BoxShadow(
//                     //         color: bnw400,
//                     //         // spreadRadius: 5,
//                     //         blurRadius: 7,
//                     //         // offset: Offset(0, 3),
//                     //       ),
//                     //     ],
//                     //   ),
//                     //   child: FutureBuilder<List<dynamic>>(
//                     //     future: getDataChart(widget
//                     //         .token), // function that makes the HTTP POST request
//                     //     builder: (context, snapshot) {
//                     //       if (snapshot.hasData) {
//                     //         List<FlSpot> spots = [];
//                     //         for (int i = 0; i < snapshot.data!.length; i++) {
//                     //           spots.add(FlSpot(i.toDouble(),
//                     //               snapshot.data![i]['qty'].toDouble()));
//                     //         }
//                     //         return SizedBox(
//                     //           child: LineChartSample2(spots: spots),
//                     //         );
//                     //       } else if (snapshot.hasError) {
//                     //         return Text("${snapshot.error}");
//                     //       }
//                     //       return CircularProgressIndicator();
//                     //     },
//                     //   ),
//                     //   // child: LineChartSample2(),
//                     // ),

//                     // Column(
//                     //   crossAxisAlignment: CrossAxisAlignment.start,
//                     //   children: [
//                     //     Text(
//                     //       'Inventori',
//                     //       style: heading2(FontWeight.w600, bnw900, 'Outfit'),
//                     //     ),
//                     //     Row(
//                     //       children: [
//                     //         frame70(
//                     //           'Stok Persediaan Habis',
//                     //           '2',
//                     //           'Barang',
//                     //           200,
//                     //           red500,
//                     //         ),
//                     //         const SizedBox(width: 8),
//                     //         frame70(
//                     //           'Stok Persediaan Habis',
//                     //           '2',
//                     //           'Barang',
//                     //           260,
//                     //           orange500,
//                     //         ),
//                     //       ],
//                     //     )
//                     //   ],
//                     // )
//                   ],
//                 ),
//                 FutureBuilder(
//                   future: dashboardSide(context, widget.token),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData) {
//                       List datatop =
//                           snapshot.data!['data']['product']['top-three'];
//                       List dataunder =
//                           snapshot.data!['data']['product']['under-three'];

//                       return Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8, bottom: 8),
//                               child: Text(
//                                 'Penjualan Terlaris',
//                                 style: heading2(
//                                     FontWeight.w600, Colors.black, 'Outfit'),
//                               ),
//                             ),
//                             SizedBox(
//                                 height: 300,
//                                 child: datatop.isNotEmpty
//                                     ? ListView.builder(
//                                         physics: NeverScrollableScrollPhysics(),
//                                         itemCount: datatop.length,
//                                         itemBuilder: (context, index) {
//                                           return Container(
//                                             margin: const EdgeInsets.only(
//                                                 top: 4, bottom: 4),
//                                             padding: const EdgeInsets.only(
//                                                 left: 10, right: 10),
//                                             height: 80,
//                                             width: 240,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                               color: bnw100,
//                                               border: Border.all(
//                                                   color: bnw300, width: 1.4),
//                                             ),
//                                             child: Center(
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceAround,
//                                                 children: [
//                                                   Text(
//                                                     (index + 1).toString(),
//                                                     style: heading2(
//                                                         FontWeight.w700,
//                                                         bnw900,
//                                                         'Outfit'),
//                                                   ),
//                                                   Container(
//                                                     padding:
//                                                         const EdgeInsets.only(
//                                                             left: 8, right: 8),
//                                                     height: 60,
//                                                     width: 60,
//                                                     child: Image.network(
//                                                       datatop[index]
//                                                           ['product_image'],
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     width: 100,
//                                                     child: Column(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .center,
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         Flexible(
//                                                           child: Text(
//                                                             datatop[index]
//                                                                 ['name'],
//                                                             style: heading3(
//                                                                 FontWeight.w600,
//                                                                 bnw900,
//                                                                 'Outfit'),
//                                                           ),
//                                                         ),
//                                                         Text(
//                                                           datatop[index]
//                                                               ['typeproducts'],
//                                                           style: body1(
//                                                               FontWeight.w400,
//                                                               bnw900,
//                                                               'Outfit'),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     child: Text(
//                                                       datatop[index]['qty'],
//                                                       style: heading2(
//                                                           FontWeight.w700,
//                                                           primary500,
//                                                           'Outfit'),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       )
//                                     : Text('Belum Melakukan Transaksi')),
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8, bottom: 8),
//                               child: Text(
//                                 'Penjualan Terendah',
//                                 style: heading2(
//                                     FontWeight.w600, Colors.black, 'Outfit'),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 300,
//                               child: dataunder.isNotEmpty
//                                   ? ListView.builder(
//                                       physics: NeverScrollableScrollPhysics(),
//                                       itemCount: dataunder.length,
//                                       itemBuilder: (context, index) {
//                                         return Container(
//                                           margin: const EdgeInsets.only(
//                                               top: 4, bottom: 4),
//                                           padding: const EdgeInsets.only(
//                                               left: 10, right: 10),
//                                           height: 80,
//                                           width: 240,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                             color: bnw100,
//                                             border: Border.all(
//                                                 color: bnw300, width: 1.4),
//                                           ),
//                                           child: Center(
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.spaceAround,
//                                               children: [
//                                                 Text(
//                                                   (index + 1).toString(),
//                                                   style: heading2(
//                                                       FontWeight.w700,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                                 Container(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                           left: 8, right: 8),
//                                                   height: 60,
//                                                   width: 60,
//                                                   child: Image.network(
//                                                     datatop[index]
//                                                         ['product_image'],
//                                                     fit: BoxFit.cover,
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   width: 100,
//                                                   child: Column(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Flexible(
//                                                         child: Text(
//                                                           dataunder[index]
//                                                               ['name'],
//                                                           style: heading3(
//                                                               FontWeight.w600,
//                                                               bnw900,
//                                                               'Outfit'),
//                                                         ),
//                                                       ),
//                                                       Text(
//                                                         datatop[index]
//                                                             ['typeproducts'],
//                                                         style: body1(
//                                                             FontWeight.w400,
//                                                             bnw900,
//                                                             'Outfit'),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 Expanded(
//                                                   child: Text(
//                                                     dataunder[index]['qty'],
//                                                     style: heading2(
//                                                         FontWeight.w700,
//                                                         primary500,
//                                                         'Outfit'),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     )
//                                   : Text('Belum Melakukan Transaksi'),
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//                     return Expanded(child: Center(child: loading()));
//                   },
//                 ),
//               ],
//             ),
//             // SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   // Container frame70(String title, value, subtitle, double width, Color color) {
//   //   return Container(
//   //     padding: const EdgeInsets.all(16),
//   //     height: 100,
//   //     width: width,
//   //     decoration: BoxDecoration(
//   //       borderRadius: BorderRadius.circular(16),
//   //       border: Border.all(color: bnw300),
//   //       color: bnw100,
//   //     ),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         Text(
//   //           title,
//   //           style: heading3(FontWeight.w600, bnw900, 'Outfit'),
//   //         ),
//   //         Text(
//   //           value,
//   //           style: heading2(FontWeight.w700, color, 'Outfit'),
//   //         ),
//   //         Text(
//   //           subtitle,
//   //           style: heading4(FontWeight.w400, bnw900, 'Outfit'),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // SizedBox analisisBttn(String title) {
//   //   return SizedBox(
//   //     child: Row(
//   //       children: [
//   //         Container(
//   //           margin: EdgeInsets.only(left: 6),
//   //           width: 42,
//   //           height: 38,
//   //           decoration: BoxDecoration(
//   //             borderRadius: BorderRadius.circular(8),
//   //             border: Border.all(color: bnw900),
//   //           ),
//   //           child: Center(
//   //             child: Text(
//   //               title,
//   //               style: heading4(FontWeight.w600, bnw900, 'Outfit'),
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Container frameDash(String title, value, desc, IconData icon) {
//     return Container(
//       margin: EdgeInsets.fromLTRB(0, 8, 8, 0),
//       height: 80,
//       width: 236,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         // color: primary200,
//       ),
//       child: Row(
//         children: [
//           Container(
//             margin: EdgeInsets.all(8),
//             height: 49,
//             width: 49,
//             decoration: BoxDecoration(
//               color: primary200,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: primary500,
//               size: 30,
//             ),
//           ),
//           SizedBox(
//             width: 155,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SizedBox(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: heading3(FontWeight.w600, bnw900, 'Outfit'),
//                       ),
//                       Text(
//                         '$value',
//                         style: heading3(FontWeight.w700, primary500, 'Outfit'),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Icon(
//                   PhosphorIcons.caret_right_fill,
//                   size: 16,
//                   color: primary500,
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   // Container sideCard(String numb) {
//   //   return Container(
//   //     margin: const EdgeInsets.only(top: 4, bottom: 4),
//   //     padding: const EdgeInsets.only(left: 10, right: 10),
//   //     height: 80,
//   //     width: 240,
//   //     decoration: BoxDecoration(
//   //       borderRadius: BorderRadius.circular(8),
//   //       color: bnw100,
//   //       border: Border.all(color: bnw300, width: 1.4),
//   //     ),
//   //     child: Center(
//   //       child: Row(
//   //         mainAxisAlignment: MainAxisAlignment.spaceAround,
//   //         children: [
//   //           Text(
//   //             numb,
//   //             style: heading2(FontWeight.w700, bnw900, 'Outfit'),
//   //           ),
//   //           Padding(
//   //             padding: const EdgeInsets.only(left: 8, right: 8),
//   //             child: Image.asset('assets/product.png'),
//   //           ),
//   //           SizedBox(
//   //             width: 100,
//   //             child: Column(
//   //               mainAxisAlignment: MainAxisAlignment.center,
//   //               crossAxisAlignment: CrossAxisAlignment.start,
//   //               children: [
//   //                 Flexible(
//   //                   child: Text(
//   //                     'Matcha Latte Cappuchino',
//   //                     style: heading3(FontWeight.w600, bnw900, 'Outfit'),
//   //                   ),
//   //                 ),
//   //                 Text(
//   //                   'Makanan',
//   //                   style: body1(FontWeight.w400, bnw900, 'Outfit'),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //           Expanded(
//   //             child: Text(
//   //               '3.2 Jt',
//   //               style: heading2(FontWeight.w700, primary500, 'Outfit'),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

// }
