// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

// import 'package:amio/utils/component.dart';

// import '../../../main.dart';
// import '../../../models/tokomodel.dart';
// import '../../../services/apimethod.dart';

// class InventoriGrup extends StatefulWidget {
//   String token;
//   InventoriGrup({
//     Key? key,
//     required this.token,
//   }) : super(key: key);

//   @override
//   State<InventoriGrup> createState() => _InventoriGrupState();
// }

// class _InventoriGrupState extends State<InventoriGrup>
//     with TickerProviderStateMixin {
//   List<ModelDataToko>? datas;
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//       datas = await getAllToko(context, widget.token, '', '');

//       setState(() {});
//     });

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (datas == null) {
//       return Padding(
//         padding: const EdgeInsets.all(30.0),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Scaffold(
//             backgroundColor: bnw100,
//             body: const Center(
//               child: SizedBox(
//                 height: 40,
//                 width: 40,
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//     return Scaffold(
//       // backgroundColor: primaryColor,
//       body: SafeArea(child: produkPage(context, widget.token)),
//     );
//   }

//   Container produkPage(BuildContext context, String token) {
//     TabController _controller = TabController(length: 2, vsync: this);

//     return Container(
//       margin: EdgeInsets.all(12),
//       padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: bnw100,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Inventori',
//                     style: heading1(FontWeight.w700, bnw900, 'Outfit'),
//                   ),
//                   Text(
//                     'Penyimpanan bahan - bahan dari sebuah Produk',
//                     style: heading3(FontWeight.w300, bnw900, 'Outfit'),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   searchField(
//                     220,
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         Icon(PhosphorIcons.magnifying_glass),
//                         Text(
//                           'Cari nama barang',
//                           style: heading3(FontWeight.w400, bnw500, 'Outfit'),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   buttonXL(
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Icon(PhosphorIcons.plus, color: bnw100),
//                         Text(
//                           'Bahan',
//                           style: heading3(FontWeight.w600, bnw100, 'Outfit'),
//                         )
//                       ],
//                     ),
//                     100,
//                   ),
//                 ],
//               )
//             ],
//           ),
//           const SizedBox(height: 20),
//           DecoratedBox(
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(width: 1, color: bnw300),
//               ),
//             ),
//             child: TabBar(
//               controller: _controller,
//               labelColor: primary500,
//               unselectedLabelColor: bnw600,
//               labelStyle: heading2(FontWeight.w400, bnw900, 'Outfit'),
//               tabs: const [
//                 Tab(
//                   text: "Barang",
//                 ),
//                 Tab(
//                   text: "Inventori Toko",
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _controller,
//               children: [
//                 barangBar(context),
//                 inventoriBarang(context),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Column barangBar(BuildContext context) {
//     return Column(
//       children: [
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             buttonLoutline(
//               GestureDetector(
//                   child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Text(
//                     'Urutkan',
//                     style: heading3(FontWeight.w600, bnw900, 'Outfit'),
//                   ),
//                   const Icon(PhosphorIcons.caret_down),
//                 ],
//               )),
              
//               bnw300,
//             ),
//             buttonLoutlineColor(
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Icon(PhosphorIcons.shopping_cart_simple_fill,
//                       color: orange500),
//                   Text(
//                     'Belum Terpenuhi : 3',
//                     style: heading4(
//                       FontWeight.w600,
//                       orange500,
//                       'Outfit',
//                     ),
//                   )
//                 ],
//               ),
//               // 220,
//               orange100,
//               orange500,
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Expanded(
//           child: CheckBoxInventori(
//             datas: [
//               ModelDataToko(
//                 merchantid: '',
//                 name: 'Matcha',
//                 address: 'Kilogram',
//                 province: '',
//                 zipcode: '',
//                 district: '',
//                 village: '',
//                 regencies: '',
//                 logomerchant_url: '',
//               ),
//               ModelDataToko(
//                 merchantid: '',
//                 name: 'Gula',
//                 address: 'Kilogram',
//                 province: '',
//                 zipcode: '',
//                 district: '',
//                 village: '',
//                 regencies: '',
//                 logomerchant_url: '',
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Expanded inventoriBarang(BuildContext context) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 16),
//           buttonLoutline(
//             GestureDetector(
//                 child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Text(
//                   'Urutkan',
//                   style: heading3(FontWeight.w600, bnw900, 'Outfit'),
//                 ),
//                 const Icon(PhosphorIcons.caret_down),
//               ],
//             )),
            
//             bnw300,
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 12, bottom: 12),
//             child: Text(
//               'Pilih Toko',
//               style: heading2(FontWeight.w400, bnw900, 'Outfit'),
//             ),
//           ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: GridView.count(
//                     crossAxisCount: 2,
//                     childAspectRatio: (MediaQuery.of(context).size.width /
//                         (MediaQuery.of(context).size.height / 1.2)),
//                     children: List.generate(
//                       datas!.length,
//                       (i) => Container(
//                         padding: const EdgeInsets.all(16),
//                         margin: EdgeInsets.all(8),
//                         height: 216,
//                         width: 333,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(color: Colors.grey.shade300)),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(1000),
//                                   child: SizedBox(
//                                     height: 60,
//                                     width: 60,
//                                     child: datas![i].logomerchant_url != null
//                                         ? Image.network(
//                                             datas![i]
//                                                 .logomerchant_url
//                                                 .toString(),
//                                             fit: BoxFit.cover,
//                                           )
//                                         : const Icon(
//                                             Icons.person,
//                                             size: 60,
//                                           ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 20),
//                                 Flexible(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         datas![i].name ?? '',
//                                         style: heading2(
//                                             FontWeight.w700, bnw900, 'Outfit'),
//                                       ),
//                                       Text(
//                                         '${datas![i].address} ${datas![i].district} ${datas![i].village} ${datas![i].regencies} ${datas![i].province} ${datas![i].zipcode}',
//                                         maxLines: 2,
//                                         overflow: TextOverflow.fade,
//                                         style: body2(
//                                             FontWeight.w400, bnw800, 'Outfit'),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const Spacer(),
//                             GestureDetector(
//                               onTap: () => log(datas![i].name.toString()),
//                               child: buttonLoutline(
//                                 Center(
//                                   child: Text(
//                                     'Lihat Produk',
//                                     style: heading4(
//                                       FontWeight.w600,
//                                       primary500,
//                                       'Outfit',
//                                     ),
//                                   ),
//                                 ),
                                
//                                 primary500,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class CheckBoxInventori extends StatefulWidget {
//   List<ModelDataToko>? datas;
//   CheckBoxInventori({
//     Key? key,
//     required this.datas,
//   }) : super(key: key);
//   @override
//   _CheckBoxInventoriState createState() => _CheckBoxInventoriState();
// }

// class _CheckBoxInventoriState extends State<CheckBoxInventori> {
//   bool isSelectionMode = false;

//   List<ModelDataToko>? staticData;
//   Map<int, bool> selectedFlag = {};
//   // Map<int, bool> selectedFlag = {};

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bnw100,
//       body: newnew(widget.datas),
//       // floatingActionButton: _buildSelectAllButton(),
//     );
//   }

//   Column newnew(List<ModelDataToko>? datas) {
//     bool isFalseAvailable = selectedFlag.containsValue(false);
//     return Column(
//       children: [
//         Container(
//           width: double.infinity,
//           height: 50,
//           decoration: BoxDecoration(
//             color: primary500,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(12),
//               topRight: Radius.circular(12),
//             ),
//           ),
//           child:
//               Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//             GestureDetector(
//               onTap: _selectAll,
//               child: SizedBox(
//                 width: 50,
//                 child: Icon(
//                   isFalseAvailable
//                       ? PhosphorIcons.square
//                       : PhosphorIcons.check_square,
//                   color: bnw100,
//                 ),
//               ),
//             ),
//             SizedBox(
//               width: 270,
//               child: Text(
//                 'Nama Barang',
//                 style: heading4(FontWeight.w700, bnw100, 'Outfit'),
//               ),
//             ),
//             SizedBox(
//               width: 200,
//               child: Text(
//                 'Satuan',
//                 style: heading4(FontWeight.w700, bnw100, 'Outfit'),
//               ),
//             ),
//             Expanded(
//               child: SizedBox(
//                 width: double.infinity,
//                 child: Text(
//                   'Alamat',
//                   style:
//                       heading4(FontWeight.w700, Colors.transparent, 'Outfit'),
//                 ),
//               ),
//             ),
//           ]),
//         ),
//         Expanded(
//           child: Container(
//             color: primary100,
//             child: ListView.builder(
//               itemBuilder: (builder, index) {
//                 ModelDataToko data = datas[index];
//                 selectedFlag[index] = selectedFlag[index] ?? false;
//                 bool? isSelected = selectedFlag[index];

//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Row(
//                     children: [
//                       InkWell(
//                         // onTap: () => onTap(isSelected, index),
//                         onTap: () {
//                           onTap(isSelected, index);
//                           log(data.name.toString());
//                         },
//                         child: SizedBox(
//                           width: 50,
//                           child: _buildSelectIcon(isSelected!, data),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 270,
//                         child: Text(
//                           datas[index].name ?? '',
//                           style: heading4(FontWeight.w400, bnw900, 'Outfit'),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 200,
//                         child: Text(
//                           datas[index].address ?? '',
//                           style: heading4(FontWeight.w400, bnw900, 'Outfit'),
//                         ),
//                       ),
//                       const Spacer(),
//                       Padding(
//                         padding: const EdgeInsets.only(right: 16),
//                         child: buttonMoutlineColor(
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Icon(PhosphorIcons.pencil_line),
//                               Text(
//                                 'Atur',
//                                 style: body2(FontWeight.w600, bnw900, 'Outfit'),
//                               )
//                             ],
//                           ),
//                           86,
//                           bnw100,
//                           bnw300,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               // itemCount: staticData!.length,
//               itemCount: datas!.length,
//             ),
//           ),
//         ),
//       ],
//     );
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

//   void onLongPress(bool isSelected, int index) {
//     setState(() {
//       selectedFlag[index] = !isSelected;
//       isSelectionMode = selectedFlag.containsValue(true);
//     });
//   }

//   Widget _buildSelectIcon(bool isSelected, ModelDataToko data) {
//     return Icon(
//       isSelected ? PhosphorIcons.check_square : PhosphorIcons.square,
//       color: bnw900,
//     );
//     // if (isSelectionMode) {
//     // } else {
//     //   return CircleAvatar(
//     //     child: Text('${data['id']}'),
//     //   );
//     // }
//   }

//   // FloatingActionButton? _buildSelectAllButton() {
//   //   bool isFalseAvailable = selectedFlag.containsValue(false);
//   //   if (isSelectionMode) {
//   //     return FloatingActionButton(
//   //       onPressed: _selectAll,
//   //       child: Icon(
//   //         isFalseAvailable ? Icons.done_all : Icons.remove_done,
//   //       ),
//   //     );
//   //   } else {
//   //     return null;
//   //   }
//   // }

//   void _selectAll() {
//     bool isFalseAvailable = selectedFlag.containsValue(false);
//     // If false will be available then it will select all the checkbox
//     // If there will be no false then it will de-select all
//     selectedFlag.updateAll((key, value) => isFalseAvailable);
//     setState(() {
//       isSelectionMode = selectedFlag.containsValue(true);
//     });
//   }
// }
