// import 'dart:convert';
// import 'dart:developer';

// import 'package:unipos_app_335/main.dart';
// import 'package:unipos_app_335/models/inventoriModel/pembelianInventoriModel.dart';
// import 'package:unipos_app_335/models/produkmodel.dart';
// import 'package:unipos_app_335/pageTablet/tokopage/sidebar/inventoriToko/ubahPersediaanTokoPage.dart';
// import 'package:unipos_app_335/pageTablet/tokopage/sidebar/produkToko/produk.dart';
// import 'package:unipos_app_335/services/apimethod.dart';
// import 'package:unipos_app_335/utils/component/component_button.dart';
// import 'package:unipos_app_335/utils/component/component_color.dart';
// import 'package:unipos_app_335/utils/component/component_loading.dart';
// import 'package:unipos_app_335/utils/component/component_orderBy.dart';
// import 'package:unipos_app_335/utils/component/component_showModalBottom.dart';
// import 'package:unipos_app_335/utils/component/component_size.dart';
// import 'package:unipos_app_335/utils/component/component_textHeading.dart';
// import 'package:unipos_app_335/utils/component/skeletons.dart';
// import 'package:unipos_app_335/utils/utilities.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
// import 'package:flutter_svg/svg.dart';

// class PemesananPage extends StatefulWidget {
//   String token;
//   PageController pageController;
//   PemesananPage({
//     Key? key,
//     required this.token,
//     required this.pageController,
//   }) : super(key: key);

//   @override
//   State<PemesananPage> createState() => _PemesananPageState();
// }

// class _PemesananPageState extends State<PemesananPage> {
//   List<PembelianModel>? datasProduk;

//   TextEditingController searchController = TextEditingController();
//   TextEditingController judulPembelian = TextEditingController();
//   DateTime? _selectedDate;
//   String tanggalAwal = '', tanggalAkhir = '';

//   List<Map<String, dynamic>> dataPemakaian = [];
//   final Map<String, Map<String, dynamic>> selectedDataPemakaian = {};

//   bool isSelectionMode = false;
//   Map<int, bool> selectedFlag = {};
//   List<String> listProduct = List.empty(growable: true);
//   List<String> cartProductIds = [];

//   List<String>? productIdCheckAll;

//   String textInventori = "Persediaan";
//   String checkFill = 'kosong';

//   double expandedPage = 0;

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//       datasProduk = await getPembelian(widget.token, '', '', textvalueOrderBy);

//       setState(() {});
//     });

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return 
//     SizedBox(
//       height: MediaQuery.of(context).size.height,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: size16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   orderBy(context),
//                   SizedBox(width: size12),
//                 ],
//               ),
//               // buttonLoutlineColor(
//               //     Row(
//               //       children: [
//               //         Icon(
//               //           PhosphorIcons.archive_box_fill,
//               //           color: orange500,
//               //           size: size24,
//               //         ),
//               //         SizedBox(width: size12),
//               //         Text(
//               //           'Persediaan Habis : 1',
//               //           style: TextStyle(
//               //             color: orange500,
//               //             fontFamily: 'Outfit',
//               //             fontWeight: FontWeight.w400,
//               //           ),
//               //         ),
//               //       ],
//               //     ),
//               //     orange100,
//               //     orange500),
//             ],
//           ),
//           //! table produk
//           SizedBox(height: size16),
//           Expanded(
//             child: Column(
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: primary500,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(size16),
//                       topRight: Radius.circular(size16),
//                     ),
//                   ),
//                   child: isSelectionMode == false
//                       ? Row(
//                           // mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Expanded(
//                               flex: 4,
//                               child: Row(
//                                 children: [
//                                   SizedBox(
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         _selectAll(productIdCheckAll);
//                                       },
//                                       child: SizedBox(
//                                         width: 50,
//                                         child: Icon(
//                                           isSelectionMode
//                                               ? PhosphorIcons.check
//                                               : PhosphorIcons.square,
//                                           color: bnw100,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     child: Text(
//                                       'Judul',
//                                       style: heading4(
//                                           FontWeight.w700, bnw100, 'Outfit'),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Expanded(
//                               flex: 4,
//                               child: Container(
//                                 child: Text(
//                                   'Tanggal Pembelian',
//                                   style: heading4(
//                                       FontWeight.w700, bnw100, 'Outfit'),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 4,
//                               child: Container(
//                                 child: Text(
//                                   'Total Harga',
//                                   style: heading4(
//                                       FontWeight.w700, bnw100, 'Outfit'),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: size16),
//                             Opacity(
//                               opacity: 0,
//                               child: buttonL(
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       PhosphorIcons.pencil_line_fill,
//                                       color: bnw900,
//                                       size: size24,
//                                     ),
//                                     SizedBox(width: size16),
//                                     Text(
//                                       'Atur',
//                                       style: heading3(
//                                           FontWeight.w600, bnw900, 'Outfit'),
//                                     ),
//                                   ],
//                                 ),
//                                 bnw100,
//                                 bnw300,
//                               ),
//                             )
//                           ],
//                         )
//                       : Row(
//                           children: [
//                             SizedBox(
//                               child: GestureDetector(
//                                 onTap: () {
//                                   _selectAll(productIdCheckAll);
//                                 },
//                                 child: SizedBox(
//                                   width: 50,
//                                   child: Icon(
//                                     checkFill == 'penuh'
//                                         ? PhosphorIcons.check_square_fill
//                                         : isSelectionMode
//                                             ? PhosphorIcons.check_square_fill
//                                             : PhosphorIcons.square,
//                                     color: bnw100,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               '${listProduct.length}/${datasProduk!.length} Produk Terpilih',
//                               // 'produk terpilih',
//                               style:
//                                   heading4(FontWeight.w600, bnw100, 'Outfit'),
//                             ),
//                             SizedBox(width: size8),
//                             GestureDetector(
//                               onTap: () {
//                                 showBottomPilihan(
//                                   context,
//                                   Column(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Column(
//                                         children: [
//                                           Text(
//                                             'Yakin Ingin Menghapus Produk?',
//                                             style: heading1(FontWeight.w600,
//                                                 bnw900, 'Outfit'),
//                                           ),
//                                           SizedBox(height: size16),
//                                           Text(
//                                             'Data produk yang sudah dihapus tidak dapat dikembalikan lagi.',
//                                             style: heading2(FontWeight.w400,
//                                                 bnw900, 'Outfit'),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(height: size16),
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: GestureDetector(
//                                               onTap: () {
//                                                 setState(() {
//                                                   deletePembelian(
//                                                     context,
//                                                     widget.token,
//                                                     listProduct,
//                                                   ).then(
//                                                     (value) {
//                                                       setState(() {
//                                                         isSelectionMode = false;
//                                                         listProduct = [];
//                                                         listProduct.clear();
//                                                         selectedFlag.clear();
//                                                       });
//                                                       initState();
//                                                     },
//                                                   );
//                                                 });

//                                                 setState(() {});
//                                                 initState();
//                                               },
//                                               child: buttonXLoutline(
//                                                 Center(
//                                                   child: Text(
//                                                     'Iya, Hapus',
//                                                     style: heading3(
//                                                         FontWeight.w600,
//                                                         primary500,
//                                                         'Outfit'),
//                                                   ),
//                                                 ),
//                                                 MediaQuery.of(context)
//                                                     .size
//                                                     .width,
//                                                 primary500,
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(width: size12),
//                                           Expanded(
//                                             child: GestureDetector(
//                                               onTap: () {
//                                                 Navigator.pop(context);
//                                               },
//                                               child: buttonXL(
//                                                 Center(
//                                                   child: Text(
//                                                     'Batalkan',
//                                                     style: heading3(
//                                                         FontWeight.w600,
//                                                         bnw100,
//                                                         'Outfit'),
//                                                   ),
//                                                 ),
//                                                 MediaQuery.of(context)
//                                                     .size
//                                                     .width,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                               child: buttonL(
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Icon(PhosphorIcons.trash_fill,
//                                         color: bnw900),
//                                     Text(
//                                       'Hapus Semua',
//                                       style: heading3(
//                                           FontWeight.w600, bnw900, 'Outfit'),
//                                     ),
//                                   ],
//                                 ),
//                                 bnw100,
//                                 bnw300,
//                               ),
//                             ),
//                             SizedBox(width: size8),
//                           ],
//                         ),
//                 ),
//                 datasProduk == null
//                     ? SkeletonCardLine()
//                     : Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: primary100,
//                             borderRadius: BorderRadius.only(
//                               bottomLeft: Radius.circular(size12),
//                               bottomRight: Radius.circular(size12),
//                             ),
//                           ),
//                           child: RefreshIndicator(
//                             color: bnw100,
//                             backgroundColor: primary500,
//                             onRefresh: () async {
//                               setState(() {});
//                               initState();
//                             },
//                             child: ListView.builder(
//                               // physics: BouncingScrollPhysics(),

//                               padding: EdgeInsets.zero,
//                               itemCount: datasProduk!.length,
//                               itemBuilder: (builder, index) {
//                                 PembelianModel data = datasProduk![index];
//                                 selectedFlag[index] =
//                                     selectedFlag[index] ?? false;
//                                 bool? isSelected = selectedFlag[index];
//                                 final dataProduk = datasProduk![index];
//                                 productIdCheckAll = datasProduk!
//                                     .map((data) => data.groupId!)
//                                     .toList();

//                                 return Container(
//                                   padding:
//                                       EdgeInsets.symmetric(vertical: size12),
//                                   decoration: BoxDecoration(
//                                     border: Border(
//                                       bottom: BorderSide(
//                                           color: bnw300, width: width1),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     // mainAxisAlignment:
//                                     //     MainAxisAlignment.spaceAround,
//                                     children: [
//                                       Expanded(
//                                         flex: 4,
//                                         child: Row(
//                                           children: [
//                                             InkWell(
//                                               // onTap: () => onTap(isSelected, index),
//                                               onTap: () {
//                                                 onTap(
//                                                   isSelected,
//                                                   index,
//                                                   dataProduk.groupId,
//                                                 );
//                                                 // log(data.name.toString());
//                                                 // print(dataProduk.isActive);

//                                                 print(listProduct);
//                                               },
//                                               child: SizedBox(
//                                                 width: 50,
//                                                 child: _buildSelectIcon(
//                                                   isSelected!,
//                                                   data,
//                                                 ),
//                                               ),
//                                             ),
//                                             Text(
//                                               datasProduk![index].title ?? '',
//                                               style: heading4(FontWeight.w600,
//                                                   bnw900, 'Outfit'),
//                                               maxLines: 3,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(width: size16),
//                                       Expanded(
//                                         flex: 4,
//                                         child: Text(
//                                           datasProduk![index].activityDate ??
//                                               '',
//                                           style: heading4(FontWeight.w600,
//                                               bnw900, 'Outfit'),
//                                           maxLines: 3,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       SizedBox(width: size16),
//                                       Expanded(
//                                         flex: 4,
//                                         child: Text(
//                                           FormatCurrency.convertToIdr(
//                                             datasProduk![index].totalPrice,
//                                           ),
//                                           style: heading4(FontWeight.w600,
//                                               bnw900, 'Outfit'),
//                                           maxLines: 3,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       SizedBox(width: size16),
//                                       GestureDetector(
//                                         onTap: () {
//                                           showModalBottom(
//                                             context,
//                                             MediaQuery.of(context).size.height,
//                                             IntrinsicHeight(
//                                               child: Padding(
//                                                 padding: EdgeInsets.all(28.0),
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.center,
//                                                   children: [
//                                                     Row(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: [
//                                                         Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Text(
//                                                               datasProduk![
//                                                                           index]
//                                                                       .groupId ??
//                                                                   '',
//                                                               // dataProduk
//                                                               //     .nameItem!,
//                                                               style: heading2(
//                                                                   FontWeight
//                                                                       .w600,
//                                                                   bnw900,
//                                                                   'Outfit'),
//                                                             ),
//                                                             Text(
//                                                               datasProduk![
//                                                                           index]
//                                                                       .activityDate ??
//                                                                   '',
//                                                               style: heading4(
//                                                                   FontWeight
//                                                                       .w400,
//                                                                   bnw900,
//                                                                   'Outfit'),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         GestureDetector(
//                                                           onTap: () =>
//                                                               Navigator.pop(
//                                                                   context),
//                                                           child: Icon(
//                                                             PhosphorIcons
//                                                                 .x_fill,
//                                                             color: bnw900,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     SizedBox(height: size24),
//                                                     GestureDetector(
//                                                       onTap: () {
//                                                         Navigator.pop(context);
//                                                         // getDetailPembelian(
//                                                         //         context,
//                                                         //         widget.token,
//                                                         //         datasProduk![
//                                                         //                 index]
//                                                         //             .groupId
//                                                         //             .toString())
//                                                         //     .then((value) {
//                                                         //   Future.delayed(
//                                                         //           const Duration(
//                                                         //               seconds:
//                                                         //                   1))
//                                                         //       .then((value) => widget
//                                                         //           .pageController
//                                                         //           .jumpToPage(
//                                                         //               4));
//                                                         // });
//                                                         groupIdInventoryUbah =
//                                                             datasProduk![index]
//                                                                 .groupId
//                                                                 .toString();

//                                                         Future.delayed(Duration(
//                                                                 seconds: 2))
//                                                             .then((value) => widget
//                                                                 .pageController
//                                                                 .jumpToPage(4));
//                                                         setState(() {});
//                                                       },
//                                                       behavior: HitTestBehavior
//                                                           .translucent,
//                                                       child: modalBottomValue(
//                                                         'Ubah Bahan',
//                                                         PhosphorIcons
//                                                             .pencil_line,
//                                                       ),
//                                                     ),
//                                                     SizedBox(height: size12),
//                                                     GestureDetector(
//                                                       behavior: HitTestBehavior
//                                                           .translucent,
//                                                       onTap: () {
//                                                         Navigator.pop(context);
//                                                         showBottomPilihan(
//                                                           context,
//                                                           Column(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               Column(
//                                                                 children: [
//                                                                   Text(
//                                                                     'Yakin Ingin Menghapus Bahan?',
//                                                                     style: heading1(
//                                                                         FontWeight
//                                                                             .w600,
//                                                                         bnw900,
//                                                                         'Outfit'),
//                                                                   ),
//                                                                   SizedBox(
//                                                                       height:
//                                                                           size16),
//                                                                   Text(
//                                                                     'Data bahan yang sudah dihapus tidak dapat dikembalikan lagi.',
//                                                                     style: heading2(
//                                                                         FontWeight
//                                                                             .w400,
//                                                                         bnw900,
//                                                                         'Outfit'),
//                                                                   ),
//                                                                   SizedBox(
//                                                                       height:
//                                                                           size16),
//                                                                 ],
//                                                               ),
//                                                               Row(
//                                                                 children: [
//                                                                   Expanded(
//                                                                     child:
//                                                                         GestureDetector(
//                                                                       onTap:
//                                                                           () {
//                                                                         setState(
//                                                                             () {
//                                                                           List<String>
//                                                                               dataBahan =
//                                                                               [
//                                                                             datasProduk![index].groupId.toString()
//                                                                           ];
//                                                                           deletePembelian(
//                                                                             context,
//                                                                             widget.token,
//                                                                             dataBahan,
//                                                                           ).then(
//                                                                             (value) {
//                                                                               setState(() {});
//                                                                               initState();
//                                                                             },
//                                                                           );
//                                                                         });
//                                                                       },
//                                                                       child:
//                                                                           buttonXLoutline(
//                                                                         Center(
//                                                                           child:
//                                                                               Text(
//                                                                             'Iya, Hapus',
//                                                                             style: heading3(
//                                                                                 FontWeight.w600,
//                                                                                 primary500,
//                                                                                 'Outfit'),
//                                                                           ),
//                                                                         ),
//                                                                         MediaQuery.of(context)
//                                                                             .size
//                                                                             .width,
//                                                                         primary500,
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   SizedBox(
//                                                                       width:
//                                                                           12),
//                                                                   Expanded(
//                                                                     child:
//                                                                         GestureDetector(
//                                                                       onTap:
//                                                                           () {
//                                                                         Navigator.pop(
//                                                                             context);
//                                                                       },
//                                                                       child:
//                                                                           buttonXL(
//                                                                         Center(
//                                                                           child:
//                                                                               Text(
//                                                                             'Batalkan',
//                                                                             style: heading3(
//                                                                                 FontWeight.w600,
//                                                                                 bnw100,
//                                                                                 'Outfit'),
//                                                                           ),
//                                                                         ),
//                                                                         MediaQuery.of(context)
//                                                                             .size
//                                                                             .width,
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         );
//                                                       },
//                                                       child: modalBottomValue(
//                                                         'Hapus Pembelian',
//                                                         PhosphorIcons.trash,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                         child: buttonL(
//                                           Row(
//                                             children: [
//                                               Icon(
//                                                 PhosphorIcons.pencil_line_fill,
//                                                 color: bnw900,
//                                                 size: size24,
//                                               ),
//                                               SizedBox(width: size16),
//                                               Text(
//                                                 'Atur',
//                                                 style: heading3(FontWeight.w600,
//                                                     bnw900, 'Outfit'),
//                                               ),
//                                             ],
//                                           ),
//                                           bnw100,
//                                           bnw300,
//                                         ),
//                                       ),
//                                       SizedBox(width: size16),
//                                     ],
//                                   ),
//                                 );
//                               },
//                               // itemCount: staticData!.length,
//                             ),
//                           ),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   fieldTambahBahan(title, mycontroller, hintText) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 title,
//                 style: body1(FontWeight.w500, bnw900, 'Outfit'),
//               ),
//               Text(
//                 ' *',
//                 style: body1(FontWeight.w700, red500, 'Outfit'),
//               ),
//             ],
//           ),
//           IntrinsicHeight(
//             child: TextFormField(
//               cursorColor: primary500,
//               // keyboardType: numberNo,
//               style: heading2(FontWeight.w600, bnw900, 'Outfit'),
//               controller: mycontroller,
//               onSaved: (value) {
//                 mycontroller.text = value;
//                 setState(() {});
//               },
//               decoration: InputDecoration(
//                 focusedBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(
//                     width: 2,
//                     color: primary500,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(vertical: size12),
//                 isDense: true,
//                 enabledBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(
//                     width: 1.5,
//                     color: bnw500,
//                   ),
//                 ),
//                 hintText: 'Cth : $hintText',
//                 hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   orderBy(BuildContext context) {
//     return IntrinsicWidth(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             showModalBottomSheet(
//               constraints: const BoxConstraints(
//                 maxWidth: double.infinity,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(25),
//               ),
//               context: context,
//               builder: (context) {
//                 return StatefulBuilder(
//                   builder: (BuildContext context, setState) => IntrinsicHeight(
//                     child: Container(
//                       padding:
//                           EdgeInsets.fromLTRB(size32, size16, size32, size32),
//                       decoration: BoxDecoration(
//                         color: bnw100,
//                         borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(size12),
//                           topLeft: Radius.circular(size12),
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           dividerShowdialog(),
//                           SizedBox(height: size16),
//                           Container(
//                             width: double.infinity,
//                             color: bnw100,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Urutkan',
//                                   style: heading2(
//                                       FontWeight.w700, bnw900, 'Outfit'),
//                                 ),
//                                 Text(
//                                   'Tentukan data yang akan tampil',
//                                   style: heading4(
//                                       FontWeight.w400, bnw600, 'Outfit'),
//                                 ),
//                                 SizedBox(height: 20),
//                                 Text(
//                                   'Pilih Urutan',
//                                   style: heading3(
//                                       FontWeight.w400, bnw900, 'Outfit'),
//                                 ),
//                                 Wrap(
//                                   children: List<Widget>.generate(
//                                     orderByProductText.length,
//                                     (int index) {
//                                       return Padding(
//                                         padding: EdgeInsets.only(right: size16),
//                                         child: ChoiceChip(
//                                           padding: EdgeInsets.symmetric(
//                                               vertical: size12),
//                                           backgroundColor: bnw100,
//                                           selectedColor: primary100,
//                                           shape: RoundedRectangleBorder(
//                                             side: BorderSide(
//                                               color:
//                                                   valueOrderByProduct == index
//                                                       ? primary500
//                                                       : bnw300,
//                                             ),
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                           ),
//                                           label: Text(orderByProductText[index],
//                                               style: heading4(
//                                                   FontWeight.w400,
//                                                   valueOrderByProduct == index
//                                                       ? primary500
//                                                       : bnw900,
//                                                   'Outfit')),
//                                           selected:
//                                               valueOrderByProduct == index,
//                                           onSelected: (bool selected) {
//                                             setState(() {
//                                               print(index);
//                                               // _value =
//                                               //     selected ? index : null;
//                                               valueOrderByProduct = index;
//                                             });
//                                             setState(() {});
//                                           },
//                                         ),
//                                       );
//                                     },
//                                   ).toList(),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: size32),
//                           SizedBox(
//                             width: double.infinity,
//                             child: GestureDetector(
//                               onTap: () {
//                                 print(valueOrderByProduct);
//                                 print(orderByProductText[valueOrderByProduct]);

//                                 textOrderBy =
//                                     orderByProductText[valueOrderByProduct];
//                                 textvalueOrderBy =
//                                     orderByProduct[valueOrderByProduct];
//                                 orderByProduct[valueOrderByProduct];
//                                 Navigator.pop(context);
//                                 // initState();
//                               },
//                               child: buttonXL(
//                                 Center(
//                                   child: Text(
//                                     'Tampilkan',
//                                     style: heading3(
//                                         FontWeight.w600, bnw100, 'Outfit'),
//                                   ),
//                                 ),
//                                 0,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           });
//         },
//         child: buttonLoutline(
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Text(
//                 'Urutkan',
//                 style: heading3(
//                   FontWeight.w600,
//                   bnw900,
//                   'Outfit',
//                 ),
//               ),
//               Text(
//                 ' dari $textOrderBy',
//                 style: heading3(
//                   FontWeight.w400,
//                   bnw900,
//                   'Outfit',
//                 ),
//               ),
//               SizedBox(width: size12),
//               Icon(
//                 PhosphorIcons.caret_down,
//                 color: bnw900,
//                 size: size24,
//               )
//             ],
//           ),
//           bnw300,
//         ),
//       ),
//     );
//   }

//   void onTap(bool isSelected, int index, productId) {
//     if (index >= 0 && index < selectedFlag.length) {
//       selectedFlag[index] = !isSelected;
//       isSelectionMode = selectedFlag.containsValue(true);

//       if (selectedFlag[index] == true) {
//         // Periksa apakah productId sudah ada di dalam listProduct sebelum menambahkannya
//         if (!listProduct.contains(productId)) {
//           listProduct.add(productId);
//         }
//       } else {
//         // Hapus productId dari listProduct jika sudah ada
//         listProduct.remove(productId);
//       }

//       setState(() {});
//     }
//   }

//   void onLongPress(bool isSelected, int index) {
//     setState(() {
//       selectedFlag[index] = !isSelected;
//       isSelectionMode = selectedFlag.containsValue(true);
//     });
//   }

//   Widget _buildSelectIcon(bool isSelected, PembelianModel data) {
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

//   void _selectAll(productId) {
//     bool isFalseAvailable = selectedFlag.containsValue(false);

//     selectedFlag.updateAll((key, value) => isFalseAvailable);
//     log(productId.toString());
//     setState(
//       () {
//         if (selectedFlag.containsValue(false)) {
//           checkFill = 'kosong';
//           listProduct.clear();
//           isSelectionMode = selectedFlag.containsValue(false);
//           isSelectionMode = selectedFlag.containsValue(true);
//         } else {
//           checkFill = 'penuh';
//           listProduct.clear();
//           listProduct.addAll(productId);
//           isSelectionMode = selectedFlag.containsValue(true);
//         }
//       },
//     );
//   }

//   Widget _buildSelectIconInventori(bool isSelected, data) {
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
