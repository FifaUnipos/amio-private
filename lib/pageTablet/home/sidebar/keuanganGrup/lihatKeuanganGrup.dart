// import 'package:flutter/material.dart';
// import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

// import '../../../../models/produkmodel.dart';
// import '../../../../models/tokoModel/riwayatTransaksiTokoModel.dart';
// import '../../../../models/tokoModel/singleRiwayatModel.dart';
// import '../../../../services/apimethod.dart';
// import '../../../../utils/component.dart';

// class LihatKeuanganGrup extends StatefulWidget {
//   String token, merchid, namemerch;
//   PageController pageController;
//   TabController tabController;
//   LihatKeuanganGrup({
//     Key? key,
//     required this.token,
//     required this.merchid,
//     required this.namemerch,
//     required this.pageController,
//     required this.tabController,
//   }) : super(key: key);

//   @override
//   State<LihatKeuanganGrup> createState() => _LihatKeuanganGrupState();
// }

// class _LihatKeuanganGrupState extends State<LihatKeuanganGrup> {
//   List<TokoDataRiwayatModel>? datasRiwayat;

//   bool isSelectionMode = false;
//   Map<int, bool> selectedFlag = {};

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback(
//       (timeStamp) async {
//         datasRiwayat = await getRiwayatTransaksi(
//           context,
//           widget.token,
//           '1',
//           widget.merchid,
//         );
//         setState(() {});
//       },
//     );

//     setState(() {
//       print(datasRiwayat.toString());
//       datasRiwayat;
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }

//   // double width = MediaQuery.of(context).size.width;
//   double? width;
//   double widtValue = 120;

//   double heightInformation = 0;
//   double widthInformation = 0;

//   String? transactionidValue;

//   @override
//   Widget build(BuildContext context) {
//     var pageController = widget.pageController;
//     TabController tabController = widget.tabController;

//     // double width = MediaQuery.of(context).size.width;
//     bool isFalseAvailable = selectedFlag.containsValue(false);

//     return datasRiwayat == null
//         ? Container(
//             margin: const EdgeInsets.all(12),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               color: bnw100,
//             ),
//             child: Scaffold(
//               backgroundColor: bnw100,
//               body: Center(child: loading()),
//             ),
//           )
//         : Container(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         widget.pageController.jumpToPage(0);
//                       },
//                       child: Icon(
//                         PhosphorIcons.arrow_left,
//                         color: bnw900,
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Keuangan',
//                           style: heading1(FontWeight.w700, bnw900, 'Outfit'),
//                         ),
//                         Text(
//                           widget.namemerch,
//                           style: heading3(FontWeight.w300, bnw900, 'Outfit'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   child: TabBar(
//                     controller: tabController,
//                     unselectedLabelColor: bnw600,
//                     labelColor: primary500,
//                     labelStyle: heading2(FontWeight.w400, bnw900, 'Outfit'),
//                     physics: const NeverScrollableScrollPhysics(),
//                     onTap: (value) {
//                       print(value);

//                       if (value == 0) {
//                         pageController.animateToPage(
//                           1,
//                           duration: const Duration(milliseconds: 10),
//                           curve: Curves.ease,
//                         );
//                       } else if (value == 1) {
//                         pageController.animateToPage(
//                           2,
//                           duration: const Duration(milliseconds: 10),
//                           curve: Curves.ease,
//                         );
//                       }
//                       setState(() {});
//                     },
//                     tabs: const [
//                       Tab(
//                         text: 'Pendapatan Lain-Lain',
//                       ),
//                       Tab(
//                         text: 'Pengeluaran Lain-Lain',
//                       ),
//                       Tab(
//                         text: 'Rekonsiliasi',
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 10, bottom: 10),
//                   child: buttonLoutline(
//                     GestureDetector(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 'Urutkan',
//                                 style:
//                                     heading3(FontWeight.w600, bnw900, 'Outfit'),
//                               ),
//                               Text(
//                                 ' dari Nama Toko A ke Z',
//                                 style:
//                                     heading3(FontWeight.w400, bnw600, 'Outfit'),
//                               ),
//                             ],
//                           ),
//                           const Icon(PhosphorIcons.caret_down),
//                         ],
//                       ),
//                     ),
//                     bnw300,
//                   ),
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     controller: tabController,
//                     children: [
//                       pendapatanLain(isFalseAvailable),
//                       pendapatanLain(isFalseAvailable),
//                       Container(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//   }

//   pendapatanLain(bool isFalseAvailable) {
//     return Row(
//       children: [
//         AnimatedContainer(
//           duration: const Duration(seconds: 1),
//           width: width,
//           child: Expanded(
//             child: Column(
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: primary500,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(12),
//                       topRight: Radius.circular(12),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 16.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         GestureDetector(
//                           onTap: _selectAll,
//                           child: SizedBox(
//                             width: width,
//                             child: Icon(
//                               isFalseAvailable
//                                   ? PhosphorIcons.square
//                                   : PhosphorIcons.check_square_fill,
//                               color: bnw100,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: widtValue - 50,
//                           child: Text(
//                             'Tanggal',
//                             style: heading4(FontWeight.w700, bnw100, 'Outfit'),
//                           ),
//                         ),
//                         SizedBox(
//                           width: widtValue,
//                           child: Text(
//                             'Jenis Pendapatan',
//                             style: heading4(FontWeight.w600, bnw100, 'Outfit'),
//                           ),
//                         ),
//                         SizedBox(
//                           width: widtValue,
//                           child: Text(
//                             'Keterangan',
//                             style: heading4(FontWeight.w600, bnw100, 'Outfit'),
//                           ),
//                         ),
//                         SizedBox(
//                           width: widtValue,
//                           child: Text(
//                             'Nilai',
//                             style: heading4(FontWeight.w600, bnw100, 'Outfit'),
//                           ),
//                         ),
//                         SizedBox(
//                           width: widtValue,
//                           child: Text(
//                             'ID Pendaatan',
//                             style: heading4(FontWeight.w600, bnw100, 'Outfit'),
//                           ),
//                         ),
//                         SizedBox(
//                           width: widtValue,
//                           child: Text(
//                             '',
//                             style: heading4(FontWeight.w600, bnw100, 'Outfit'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: primary100,
//                       borderRadius: const BorderRadius.only(
//                         bottomLeft: Radius.circular(12),
//                         bottomRight: Radius.circular(12),
//                       ),
//                     ),
//                     child: ListView.builder(
//                       padding: EdgeInsets.zero,
//                       itemCount: datasRiwayat!.length,
//                       physics: const BouncingScrollPhysics(),
//                       itemBuilder: (builder, index) {
//                         TokoDataRiwayatModel data = datasRiwayat![index];
//                         selectedFlag[index] = selectedFlag[index] ?? false;
//                         bool? isSelected = selectedFlag[index];
//                         final dataProduk = datasRiwayat![index];

//                         return Column(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       onTap(isSelected, index);
//                                     },
//                                     child: SizedBox(
//                                       width: width,
//                                       child:
//                                           _buildSelectIcon(isSelected!, data),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: widtValue,
//                                     child: Text(
//                                       datasRiwayat![index].customer.toString(),
//                                       style: heading4(
//                                           FontWeight.w400, bnw900, 'Outfit'),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: widtValue,
//                                     child: Text(
//                                       datasRiwayat![index]
//                                           .transactionid
//                                           .toString(),
//                                       style: heading4(
//                                           FontWeight.w400, bnw900, 'Outfit'),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: widtValue,
//                                     child: Text(
//                                       datasRiwayat![index].pic.toString(),
//                                       style: heading4(
//                                           FontWeight.w400, bnw900, 'Outfit'),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: widtValue,
//                                     child: Text(
//                                       FormatCurrency.convertToIdr(
//                                               datasRiwayat![index].amount)
//                                           .toString(),
//                                       style: heading4(
//                                           FontWeight.w400, bnw900, 'Outfit'),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: widtValue,
//                                     child: Text(
//                                       datasRiwayat![index].entrydate.toString(),
//                                       style: heading4(
//                                           FontWeight.w400, bnw900, 'Outfit'),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const Divider(thickness: 1.2)
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         widthInformation == 0
//             ? Container()
//             : Expanded(
//                 child: FutureBuilder(
//                   future: getSingleRiwayatTransaksi(
//                       widget.token, transactionidValue),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData) {
//                       Map<String, dynamic> data = snapshot.data!['data'];
//                       List detail = data['detail'];
//                       return AnimatedContainer(
//                         duration: const Duration(seconds: 1),
//                         padding: const EdgeInsets.all(16),
//                         height: heightInformation,
//                         width: widthInformation,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: bnw300),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: ListView(
//                                 padding: EdgeInsets.zero,
//                                 physics: const BouncingScrollPhysics(),
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'Informasi Pesanan',
//                                         style: heading3(
//                                             FontWeight.w600, bnw900, 'Outfit'),
//                                       ),
//                                       SizedBox(
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   'Nama Pembeli',
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                                 const SizedBox(height: 6),
//                                                 Text(
//                                                   'Metode Pembayaran',
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                                 const SizedBox(height: 6),
//                                                 Text(
//                                                   'Nomor Pesanan',
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                                 const SizedBox(height: 6),
//                                                 Text(
//                                                   'Kasir',
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                               ],
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.end,
//                                               children: [
//                                                 Text(
//                                                   data['customer'],
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                                 const SizedBox(height: 6),
//                                                 Text(
//                                                   data['payment_method']
//                                                       .toString(),
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                                 const SizedBox(height: 6),
//                                                 Text(
//                                                   data['transactionid']
//                                                       .toString(),
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                                 const SizedBox(height: 6),
//                                                 Text(
//                                                   data['pic'] ?? '',
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                                 const SizedBox(height: 10),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                           top: 8.0,
//                                           bottom: 8.0,
//                                         ),
//                                         child: Text(
//                                           'Rincian Pesanan',
//                                           style: heading3(FontWeight.w600,
//                                               bnw900, 'Outfit'),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   //! error
//                                   Expanded(
//                                     child: ListView.builder(
//                                       shrinkWrap: true,
//                                       padding: EdgeInsets.zero,
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       itemCount: detail.length,
//                                       itemBuilder: (context, index) {
//                                         return SizedBox(
//                                           child: Column(
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Text(
//                                                     'x${detail[index]['quantity']}',
//                                                     style: heading3(
//                                                         FontWeight.w600,
//                                                         bnw900,
//                                                         'Outfit'),
//                                                   ),
//                                                   Container(
//                                                     margin:
//                                                         const EdgeInsets.only(
//                                                             left: 8, right: 8),
//                                                     height: 48,
//                                                     width: 48,
//                                                     child: Image.network(
//                                                       detail[index]
//                                                           ['product_image'],
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                   Column(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Text(
//                                                         detail[index]['name'] ??
//                                                             '',
//                                                         style: heading3(
//                                                             FontWeight.w600,
//                                                             bnw900,
//                                                             'Outfit'),
//                                                       ),
//                                                       Text(
//                                                         FormatCurrency.convertToIdr(
//                                                                 detail[index][
//                                                                         'amount'] ??
//                                                                     '')
//                                                             .toString(),
//                                                         style: body1(
//                                                             FontWeight.w400,
//                                                             bnw900,
//                                                             'Outfit'),
//                                                       ),
//                                                       Text(
//                                                         'Catatan : ${detail[index]['description']}',
//                                                         style: body1(
//                                                             FontWeight.w400,
//                                                             bnw900,
//                                                             'Outfit'),
//                                                       ),
//                                                     ],
//                                                   )
//                                                 ],
//                                               ),
//                                               const Divider(),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Rincian Pembayaran',
//                                           style: heading3(FontWeight.w600,
//                                               bnw900, 'Outfit'),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   'Nama Pembeli',
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                                 const SizedBox(height: 8),
//                                                 Text(
//                                                   'Sub Total',
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                                 const SizedBox(height: 8),
//                                                 Text(
//                                                   'PPN',
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                               ],
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.end,
//                                               children: [
//                                                 Text(
//                                                   data['customer'] ?? '',
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                                 const SizedBox(height: 8),
//                                                 Text(
//                                                   FormatCurrency.convertToIdr(
//                                                           data['total_before_dsc_tax'] ??
//                                                               '')
//                                                       .toString(),
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                                 const SizedBox(height: 8),
//                                                 Text(
//                                                   FormatCurrency.convertToIdr(
//                                                           data['ppn'] ?? '')
//                                                       .toString(),
//                                                   style: heading4(
//                                                       FontWeight.w400,
//                                                       bnw900,
//                                                       'Outfit'),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                             top: 8.0,
//                                             bottom: 8.0,
//                                           ),
//                                           child: Row(
//                                             children: List.generate(
//                                               300 ~/ 6,
//                                               (index) => Expanded(
//                                                 child: Container(
//                                                   color: index % 2 == 0
//                                                       ? Colors.transparent
//                                                       : bnw900,
//                                                   height: 1,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               'Total',
//                                               style: heading3(FontWeight.w600,
//                                                   bnw900, 'Outfit'),
//                                             ),
//                                             Text(
//                                               FormatCurrency.convertToIdr(
//                                                       data['amount'] ?? '')
//                                                   .toString(),
//                                               style: heading3(FontWeight.w600,
//                                                   bnw900, 'Outfit'),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             GestureDetector(
//                                 onTap: () {
//                                   width = null;
//                                   widtValue = 120;
//                                   heightInformation = 0;
//                                   widthInformation = 0;
//                                   setState(() {});
//                                 },
//                                 child: buttonXL(
//                                   Center(
//                                       child: Text(
//                                     'Selesai',
//                                     style: heading3(
//                                         FontWeight.w600, bnw100, 'Outfit'),
//                                   )),
//                                   double.infinity,
//                                 )),
//                           ],
//                         ),
//                       );
//                     } else if (snapshot.hasError) {
//                       // return Text("Error: ${snapshot.error}");
//                       return Center(child: loading());
//                     }
//                     return Center(child: loading());
//                   },
//                 ),
//               ),
//       ],
//     );
//   }

//   void _selectAll() {
//     bool isFalseAvailable = selectedFlag.containsValue(false);
//     // If false will be available then it will select all the checkbox
//     // If there will be no false then it will de-select all
//     selectedFlag.updateAll((key, value) => isFalseAvailable);
//     setState(() {
//       isSelectionMode = selectedFlag.containsValue(true);
//     });
//   }

//   void onTap(bool isSelected, int index) {
//     setState(() {
//       selectedFlag[index] = !isSelected;
//       isSelectionMode = selectedFlag.containsValue(true);
//     });
//     // if (isSelectionMode) {
//     // } else {
//     //   // Open Detail Page
//     // }
//   }

//   Widget _buildSelectIcon(bool isSelected, TokoDataRiwayatModel data) {
//     return Icon(
//       isSelected ? PhosphorIcons.check_square_fill : PhosphorIcons.square,
//       color: primary500,
//     );
//     // if (isSelectionMode) {
//     // } else {
//     //   return CircleAvatar(
//     //     child: Text('${data['id']}'),
//     //   );
//     // }
//   }
// }
