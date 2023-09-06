// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:amio/utils/component.dart';
// import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
// import '../../../../../main.dart';
// import '../../../../../models/tokomodel.dart';
// import '../../../../../services/apimethod.dart';
// import 'lihatKeuanganGrup.dart';

// class KeuanganGrup extends StatefulWidget {
//   String token;
//   KeuanganGrup({
//     Key? key,
//     required this.token,
//   }) : super(key: key);

//   @override
//   State<KeuanganGrup> createState() => _KeuanganGrupState();
// }

// class _KeuanganGrupState extends State<KeuanganGrup>
//     with TickerProviderStateMixin {
//   PageController _pageController = PageController();
//   TabController? _tabController;

//   List<ModelDataToko>? datas;

//   @override
//   void initState() {
//     _tabController = TabController(length: 3, vsync: this);
//     log(datas.toString());
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//       datas = await getAllToko(context, widget.token, '', '');
//       setState(() {});

//       _pageController = PageController(
//         initialPage: 0,
//         keepPage: true,
//         viewportFraction: 1,
//       );
//     });

//     super.initState();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   late String nameMerch = '', idMerch = '';

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
//       body: SafeArea(child: akunPage(context)),
//     );
//   }

//   Container akunPage(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(12),
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: bnw100,
//       ),
//       child: PageView(
//         physics: NeverScrollableScrollPhysics(),
//         controller: _pageController,
//         children: [
//           mainAkunPage(context),
//           LihatKeuanganGrup(
//             token: widget.token,
//             namemerch: nameMerch,
//             tabController: _tabController!,
//             pageController: _pageController,
//             merchid: idMerch,
//           ),
//         ],
//       ),
//     );
//   }

//   Column mainAkunPage(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Akun',
//                   style: heading1(FontWeight.w700, bnw900, 'Outfit'),
//                 ),
//                 Text(
//                   'Atur akun pekerja di setiap toko',
//                   style: heading3(FontWeight.w300, bnw900, 'Outfit'),
//                 ),
//               ],
//             ),
//             searchField(
//               260,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Icon(PhosphorIcons.magnifying_glass),
//                   Text(
//                     'Cari nama atau alamat toko',
//                     style: heading3(FontWeight.w400, bnw500, 'Outfit'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             buttonLoutline(
//               GestureDetector(
//                   child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         'Urutkan',
//                         style: heading3(FontWeight.w600, bnw900, 'Outfit'),
//                       ),
//                       Text(
//                         ' dari Nama Toko A ke Z',
//                         style: heading3(FontWeight.w400, bnw600, 'Outfit'),
//                       ),
//                     ],
//                   ),
//                   const Icon(PhosphorIcons.caret_down),
//                 ],
//               )),
              
//               bnw300,
//             ),
//           ],
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 12, bottom: 12),
//           child: Text(
//             'Pilih Toko',
//             style: heading2(FontWeight.w400, bnw900, 'Outfit'),
//           ),
//         ),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   childAspectRatio: (MediaQuery.of(context).size.width /
//                       (MediaQuery.of(context).size.height / 1.2)),
//                   children: List.generate(
//                     datas!.length,
//                     (i) => Container(
//                       padding: const EdgeInsets.all(16),
//                       margin: EdgeInsets.all(8),
//                       height: 216,
//                       width: 333,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(color: Colors.grey.shade300)),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(1000),
//                                 child: SizedBox(
//                                   height: 60,
//                                   width: 60,
//                                   child: datas![i].logomerchant_url != null
//                                       ? Image.network(
//                                           datas![i].logomerchant_url.toString(),
//                                           fit: BoxFit.cover,
//                                         )
//                                       : const Icon(
//                                           Icons.person,
//                                           size: 60,
//                                         ),
//                                 ),
//                               ),
//                               SizedBox(width: 20),
//                               Flexible(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       datas![i].name ?? '',
//                                       style: heading2(
//                                           FontWeight.w700, bnw900, 'Outfit'),
//                                     ),
//                                     Text(
//                                       '${datas![i].address}',
//                                       maxLines: 2,
//                                       overflow: TextOverflow.fade,
//                                       style: body2(
//                                           FontWeight.w400, bnw800, 'Outfit'),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const Spacer(),
//                           GestureDetector(
//                             onTap: () async {
//                               nameMerch = datas![i].name.toString();
//                               idMerch = datas![i].merchantid.toString();

//                               _pageController.nextPage(
//                                 duration: const Duration(milliseconds: 10),
//                                 curve: Curves.easeIn,
//                               );

//                               log(datas![i].merchantid.toString());
//                               setState(() {});
//                             },
//                             // onTap: () => log(datas![i].name.toString()),
//                             child: buttonLoutline(
//                               Center(
//                                 child: Text(
//                                   'Lihat Keuangan',
//                                   style: heading4(
//                                     FontWeight.w600,
//                                     primary500,
//                                     'Outfit',
//                                   ),
//                                 ),
//                               ),
                              
//                               primary500,
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }
