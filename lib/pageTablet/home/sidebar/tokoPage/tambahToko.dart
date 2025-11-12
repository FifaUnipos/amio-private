// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:io' as Io;
// import 'dart:typed_data';
// import 'package:flutter_launcher_icons/xml_templates.dart';
// import 'package:http/http.dart' as http;

// import 'package:flutter/material.dart';
// import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../../../main.dart';
// import '../../../../models/tokomodel.dart';
// import '../../../../pagehelper/loginregis/daftar_akun_toko.dart';
// import '../../../../services/apimethod.dart';
// import '../../../../services/checkConnection.dart';
// import '../../../../utils/component.dart';
// import '../../../tokopage/sidebar/produkToko/produk.dart';

// class CreateMerchant extends StatefulWidget {
//   List<ModelDataToko> datas;
//   String token;
//   PageController pageController = PageController();
//   CreateMerchant({
//     Key? key,
//     required this.token,
//     required this.pageController,
//     required this.datas,
//   }) : super(key: key);

//   @override
//   State<CreateMerchant> createState() => _CreateMerchantState();
// }

// class _CreateMerchantState extends State<CreateMerchant> {
//   TextEditingController conNameMerch = TextEditingController();
//   TextEditingController conCodeStore = TextEditingController();
//   TextEditingController conAddress = TextEditingController();
//   TextEditingController conCodePos = TextEditingController();

//   TextEditingController searchController = TextEditingController();

//   File? myImage;
//   Uint8List? bytes;
//   String? img64;
//   List<String> images = [];

//   Future<void> getImage() async {
//     var picker = ImagePicker();
//     PickedFile? image;

//     image = await picker.getImage(source: ImageSource.gallery);
//     if (image!.path.isEmpty == false) {
//       myImage = File(image.path);

//       bytes = await Io.File(myImage!.path).readAsBytes();
//       setState(() {
//         img64 = base64Encode(bytes!);
//         images.add(img64!);
//       });
//       // Clipboard.setData(ClipboardData(text: img64));
//     } else {
//       print('Error Image');
//     }
//   }

//   String? tipe, prov, kab, kec, desa;
//   String? iditpe, idprov, idkab, idkec, iddesa;

//   @override
//   void initState() {
//     checkConnection(context);
//     getAllToko(context, widget.token, '', '');
//     autoReload();
//     _getProvinceList();
//     _getTipeList();
//     super.initState();
//   }

//   void autoReload() {
//     setState(() {
//       tipe;
//       prov;
//       kab;
//       kec;
//       desa;
//     });
//   }

//   var bttnValidated = false;

//   @override
//   Widget build(BuildContext context) {
//     return
//      Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(size16),
//         color: bnw100,
//       ),
//       child: Column(
//         // crossAxisAlignment: CrossAxisAlignment.start,
//         // mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Container(
//             width: double.infinity,
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => widget.pageController.previousPage(
//                     duration: Duration(milliseconds: 10),
//                     curve: Curves.easeInBack,
//                   ),
//                   child: Icon(
//                     PhosphorIcons.arrow_left,
//                     size: size48,
//                     color: bnw900,
//                   ),
//                 ),
//                 SizedBox(width: size16),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Tambah Toko',
//                       style: heading1(FontWeight.w700, bnw900, 'Outfit'),
//                     ),
//                     Text(
//                       'Isi data toko dengan lengkap',
//                       style: heading3(FontWeight.w400, bnw900, 'Outfit'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: size16),
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(size16),
//                 color: bnw100,
//               ),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: ListView(
//                       physics: BouncingScrollPhysics(),
//                       padding: EdgeInsets.zero,
//                       children: [
//                         Text(
//                           'Logo Toko',
//                           style: heading4(FontWeight.w400, bnw900, 'Outfit'),
//                         ),
//                         SizedBox(height: size12),
//                         Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () => tambahGambar(context),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: bnw900),
//                                   borderRadius: BorderRadius.circular(size8),
//                                 ),
//                                 height: 80,
//                                 width: 80,
//                                 child: myImage != null
//                                     ? Image.file(myImage!, fit: BoxFit.cover)
//                                     : Icon(PhosphorIcons.plus),
//                               ),
//                             ),
//                             SizedBox(width: size12),
//                             Text(
//                               'Masukkan logo atau foto yang menandakan identitas dari tokomu.',
//                               style:
//                                   heading4(FontWeight.w400, bnw900, 'Outfit'),
//                             ),
//                           ],
//                         ),
//                         GestureDetector(
//                           onTap: () => tambahGambar(context),
//                           child: SizedBox(
//                             child: TextFormField(
//                               cursorColor: primary500,
//                               style:
//                                   heading3(FontWeight.w600, bnw900, 'Outfit'),
//                               decoration: InputDecoration(
//                                 focusedBorder: UnderlineInputBorder(
//                                   borderSide: BorderSide(
//                                     width: 2,
//                                     color: primary500,
//                                   ),
//                                 ),
//                                 enabledBorder: UnderlineInputBorder(
//                                   borderSide: BorderSide(
//                                     width: width1,
//                                     color: bnw500,
//                                   ),
//                                 ),
//                                 enabled: false,
//                                 suffixIcon: Icon(
//                                   PhosphorIcons.plus,
//                                   color: bnw900,
//                                 ),
//                                 hintText: 'Tambah Gambar',
//                                 hintStyle:
//                                     heading2(FontWeight.w600, bnw900, 'Outfit'),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: size16),
//                         fieldAddToko('Tambah Toko ', 'King Dragon Roll Jakarta',
//                             conNameMerch),
//                         SizedBox(height: size16),
//                         fieldAddToko(
//                             'Alamat',
//                             'Jl. Pramuka No.99, RT 001/RW 002, Marga Wisata',
//                             conAddress),
//                         SizedBox(height: size16),
//                         fieldTipeUsaha(),
//                         SizedBox(height: size16),
//                         Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: SizedBox(
//                                     width: MediaQuery.of(context).size.width,
//                                     child: provinceField(context),
//                                   ),
//                                 ),
//                                 SizedBox(width: size16),
//                                 Expanded(
//                                   child: SizedBox(
//                                     width:
//                                         MediaQuery.of(context).size.width / 2.6,
//                                     child: regenciesField(context),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: size16),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Expanded(
//                                   child: SizedBox(
//                                     width:
//                                         MediaQuery.of(context).size.width / 2.6,
//                                     child: districtField(context),
//                                   ),
//                                 ),
//                                 SizedBox(width: size16),
//                                 Expanded(
//                                   child: SizedBox(
//                                     width:
//                                         MediaQuery.of(context).size.width / 2.6,
//                                     child: villageField(),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: size16),
//                         fieldAddTokoZip('Kode Pos', '1234', conCodePos),
//                         SizedBox(height: size16),
//                         // DropDown(token: widget.token),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: size16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             createMerch(
//                                     context,
//                                     widget.token,
//                                     conNameMerch.text,
//                                     conAddress.text,
//                                     idprov,
//                                     idkab,
//                                     idkec,
//                                     iddesa,
//                                     conCodePos.text,
//                                     img64,
//                                     widget.pageController,
//                                     iditpe)
//                                 .then((value) {
//                               if (value == '00') {
//                                 conNameMerch.text = '';
//                                 conAddress.text = '';
//                                 conCodePos.text = '';
//                                 idprov = '';
//                                 idkab = '';
//                                 idkec = '';
//                                 iddesa = '';
//                                 iditpe = '';
//                               }
//                             });
//                             setState(() {});
//                           },
//                           child: buttonXLoutline(
//                             Center(
//                               child: Text(
//                                 'Simpan & Tambah Baru',
//                                 style:
//                                     heading3(FontWeight.w600, bnw900, 'Outfit'),
//                               ),
//                             ),
//                             MediaQuery.of(context).size.width,
//                             bnw900,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: size16),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               whenLoading(context);
//                               createMerch(
//                                       context,
//                                       widget.token,
//                                       conNameMerch.text,
//                                       conAddress.text,
//                                       idprov,
//                                       idkab,
//                                       idkec,
//                                       iddesa,
//                                       conCodePos.text,
//                                       img64,
//                                       widget.pageController,
//                                       iditpe)
//                                   .then((value) async {
//                                 if (value == '00') {
//                                   autoReload();
//                                   closeLoading(context);
//                                   await Future.delayed(Duration(seconds: 2));
//                                   widget.pageController.jumpToPage(0);
//                                   getAllToko(context, widget.token, '', '');
//                                 }
//                               });
//                             });

//                             initState();
//                           },
//                           child: buttonXL(
//                             Center(
//                               child: Text(
//                                 'Tambah',
//                                 style:
//                                     heading3(FontWeight.w600, bnw100, 'Outfit'),
//                               ),
//                             ),
//                             MediaQuery.of(context).size.width,
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   fieldTipeUsaha() {
//     bool isKeyboardActive = false;

//     return GestureDetector(
//       onTap: () => setState(
//         () {
//           autoReload();
//           // log(tipe.toString());
//           showModalBottomSheet(
//             isScrollControlled: true,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(size24),
//             ),
//             context: context,
//             builder: (context) {
//               return StatefulBuilder(
//                 builder: (BuildContext context, setState) =>
//                     FractionallySizedBox(
//                   heightFactor: isKeyboardActive ? 0.9 : 0.80,
//                   child: GestureDetector(
//                     onTap: () => textFieldFocusNode.unfocus(),
//                     child: Container(
//                       padding: EdgeInsets.only(
//                           bottom: MediaQuery.of(context).viewInsets.bottom),
//                       height: MediaQuery.of(context).size.height / 1.8,
//                       decoration: BoxDecoration(
//                         color: bnw100,
//                         borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(size12),
//                           topLeft: Radius.circular(size12),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.only(left: size12, right: size12),
//                         child: Column(
//                           children: [
//                             Container(
//                               margin: EdgeInsets.all(size8),
//                               height: 4,
//                               width: 140,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(size8),
//                                 color: bnw300,
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.fromLTRB(
//                                   size8, size16, size8, size16),
//                               child: FocusScope(
//                                 child: Focus(
//                                   onFocusChange: (value) {
//                                     isKeyboardActive = value;
//                                     setState(() {});
//                                   },
//                                   child: TextField(
//                                     cursorColor: primary500,
//                                     controller: searchController,
//                                     focusNode: textFieldFocusNode,
//                                     onChanged: (value) {
//                                       _runSearchTipeUsaha(value);
//                                       setState(() {});
//                                     },
//                                     decoration: InputDecoration(
//                                         contentPadding: EdgeInsets.symmetric(
//                                             vertical: size12),
//                                         isDense: true,
//                                         filled: true,
//                                         fillColor: bnw200,
//                                         border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(size8),
//                                           borderSide: BorderSide(
//                                             color: bnw300,
//                                           ),
//                                         ),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(size8),
//                                           borderSide: BorderSide(
//                                             width: 2,
//                                             color: primary500,
//                                           ),
//                                         ),
//                                         enabledBorder: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(size8),
//                                           borderSide: BorderSide(
//                                             color: bnw300,
//                                           ),
//                                         ),
//                                         suffixIcon: searchController
//                                                 .text.isNotEmpty
//                                             ? GestureDetector(
//                                                 onTap: () {
//                                                   searchController.text = '';
//                                                   _runSearchTipeUsaha('');
//                                                   setState(() {});
//                                                 },
//                                                 child: Icon(
//                                                   PhosphorIcons.x_fill,
//                                                   size: 20,
//                                                   color: bnw900,
//                                                 ),
//                                               )
//                                             : null,
//                                         prefixIcon: Icon(
//                                           PhosphorIcons.magnifying_glass,
//                                           color: bnw500,
//                                         ),
//                                         hintText: 'Cari',
//                                         hintStyle: heading3(
//                                             FontWeight.w500, bnw500, 'Outfit')),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: ListView.builder(
//                                 keyboardDismissBehavior:
//                                     ScrollViewKeyboardDismissBehavior.onDrag,
//                                 physics: BouncingScrollPhysics(),
//                                 itemCount: searchResultListTipeUsaha?.length,
//                                 itemBuilder: (context, index) {
//                                   final tipeUsaha =
//                                       searchResultListTipeUsaha?[index];
//                                   final isSelected =
//                                       tipeUsaha == selectedTipeUsaha;

//                                   return Column(
//                                     children: [
//                                       ListTile(
//                                         title: Text(
//                                           tipeUsaha['nama_tipe'] != null
//                                               ? capitalizeEachWord(
//                                                   tipeUsaha['nama_tipe']
//                                                       .toString())
//                                               : '',
//                                         ),
//                                         trailing: Icon(
//                                           isSelected
//                                               ? PhosphorIcons.radio_button_fill
//                                               : PhosphorIcons.radio_button,
//                                           color:
//                                               isSelected ? primary500 : bnw900,
//                                         ),
//                                         onTap: () {
//                                           setState(() {
//                                             textFieldFocusNode.unfocus();
//                                             _mytipe = tipeUsaha['tipeusaha_id'];
//                                             iditpe = tipeUsaha['tipeusaha_id'];
//                                             tipe = tipeUsaha['nama_tipe'];

//                                             selectedTipeUsaha =
//                                                 tipeUsaha.toString();
//                                             _selectTipeUsaha(tipeUsaha);
//                                             _getRegenciesList(_myProvince);
//                                             print(tipeUsaha['nama_tipe']);
//                                           });
//                                         },
//                                       ),
//                                       Divider(color: bnw300),
//                                     ],
//                                   );
//                                 },
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 print(tipe);
//                                 _getRegenciesList(_myProvince);
//                                 autoReload();
//                                 // initState();
//                                 Navigator.pop(context);
//                               },
//                               child: buttonXXL(
//                                 Center(
//                                   child: Text(
//                                     'Selesai',
//                                     style: heading2(
//                                         FontWeight.w600, bnw100, 'Outfit'),
//                                   ),
//                                 ),
//                                 double.infinity,
//                               ),
//                             ),
//                             SizedBox(height: size8)
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: bnw100,
//           border: Border(
//             bottom: BorderSide(
//               width: width1,
//               color: bnw500,
//             ),
//           ),
//         ),
//         child: Align(
//           alignment: Alignment.centerLeft,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               //!depan
//               Row(
//                 children: [
//                   Text(
//                     'Tipe Usaha',
//                     style: heading4(FontWeight.w400, bnw900, 'Outfit'),
//                   ),
//                   Text(
//                     ' *',
//                     style: heading4(FontWeight.w400, red500, 'Outfit'),
//                   ),
//                 ],
//               ),

//               Container(
//                 padding: EdgeInsets.symmetric(vertical: size12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       tipe == null ? 'Tipe Usaha' : tipe.toString(),
//                       style: heading2(FontWeight.w600,
//                           tipe == null ? bnw500 : bnw900, 'Outfit'),
//                     ),
//                     Icon(
//                       PhosphorIcons.caret_down,
//                       color: bnw900,
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   fieldAddToko(title, hint, mycontroller) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 title,
//                 style: heading4(FontWeight.w500, bnw900, 'Outfit'),
//               ),
//               Text(
//                 '*',
//                 style: heading4(FontWeight.w700, red500, 'Outfit'),
//               ),
//             ],
//           ),
//           IntrinsicHeight(
//             child: Container(
//               child: TextFormField(
//                 cursorColor: primary500,
//                 style: heading2(FontWeight.w600, bnw900, 'Outfit'),
//                 controller: mycontroller,
//                 onChanged: (value) {
//                   if (conNameMerch.text.isNotEmpty &&
//                       conAddress.text.isNotEmpty &&
//                       conCodePos.text.isNotEmpty) {
//                     setState(() {
//                       bttnValidated = true;
//                     });
//                   }
//                 },
//                 decoration: InputDecoration(
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(
//                       width: 2,
//                       color: primary500,
//                     ),
//                   ),
//                   isDense: true,
//                   contentPadding: EdgeInsets.symmetric(vertical: size12),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(
//                       width: width1,
//                       color: bnw500,
//                     ),
//                   ),
//                   hintText: 'Cth : $hint',
//                   // hintTextDirection: TextDirection.ltr,
//                   hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   fieldAddTokoZip(title, hint, mycontroller) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 title,
//                 style: heading4(FontWeight.w500, bnw900, 'Outfit'),
//               ),
//               Text(
//                 ' *',
//                 style: heading4(FontWeight.w700, red500, 'Outfit'),
//               ),
//             ],
//           ),
//           IntrinsicHeight(
//             child: Container(
//               child: TextFormField(
//                 cursorColor: primary500,
//                 style: heading2(FontWeight.w600, bnw900, 'Outfit'),
//                 controller: mycontroller,
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) {
//                   if (conNameMerch.text.isNotEmpty &&
//                       conAddress.text.isNotEmpty &&
//                       conCodePos.text.isNotEmpty) {
//                     setState(() {
//                       bttnValidated = true;
//                     });
//                   }
//                 },
//                 decoration: InputDecoration(
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(
//                       width: 2,
//                       color: primary500,
//                     ),
//                   ),
//                   isDense: true,
//                   contentPadding: EdgeInsets.symmetric(vertical: size12),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(
//                       width: width1,
//                       color: bnw500,
//                     ),
//                   ),
//                   hintText: 'Cth : $hint',
//                   hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   GestureDetector provinceField(BuildContext context) {
//     bool isKeyboardActive = false;

//     return GestureDetector(
//       onTap: () {
//         setState(
//           () {
//             autoReload();
//             // log(prov.toString());
//             showModalBottomSheet(
//               isScrollControlled: true,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(size24),
//               ),
//               context: context,
//               builder: (context) {
//                 return StatefulBuilder(
//                   builder: (BuildContext context, setState) =>
//                       FractionallySizedBox(
//                     heightFactor: isKeyboardActive ? 0.9 : 0.80,
//                     child: GestureDetector(
//                       onTap: () => textFieldFocusNode.unfocus(),
//                       child: Container(
//                         padding: EdgeInsets.only(
//                             bottom: MediaQuery.of(context).viewInsets.bottom),
//                         height: MediaQuery.of(context).size.height / 1.8,
//                         decoration: BoxDecoration(
//                           color: bnw100,
//                           borderRadius: BorderRadius.only(
//                             topRight: Radius.circular(size12),
//                             topLeft: Radius.circular(size12),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.all(size8),
//                           child: Column(
//                             children: [
//                               Container(
//                                 margin: EdgeInsets.only(top: size12),
//                                 height: 4,
//                                 width: 140,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(size8),
//                                   color: bnw300,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(
//                                     size8, size16, size8, size16),
//                                 child: FocusScope(
//                                   child: Focus(
//                                     onFocusChange: (value) {
//                                       isKeyboardActive = value;
//                                       setState(() {});
//                                     },
//                                     child: TextField(
//                                       cursorColor: primary500,
//                                       controller: searchController,
//                                       focusNode: textFieldFocusNode,
//                                       onChanged: (value) {
//                                         //   isKeyboardActive = value.isNotEmpty;
//                                         _runSearchProvince(value);
//                                         setState(() {});
//                                       },
//                                       decoration: InputDecoration(
//                                           contentPadding: EdgeInsets.symmetric(
//                                               vertical: size12),
//                                           isDense: true,
//                                           filled: true,
//                                           fillColor: bnw200,
//                                           border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                             borderSide: BorderSide(
//                                               color: bnw300,
//                                             ),
//                                           ),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                             borderSide: BorderSide(
//                                               width: 2,
//                                               color: primary500,
//                                             ),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                             borderSide: BorderSide(
//                                               color: bnw300,
//                                             ),
//                                           ),
//                                           suffixIcon: searchController
//                                                   .text.isNotEmpty
//                                               ? GestureDetector(
//                                                   onTap: () {
//                                                     searchController.text = '';
//                                                     _runSearchProvince('');
//                                                     setState(() {});
//                                                   },
//                                                   child: Icon(
//                                                     PhosphorIcons.x_fill,
//                                                     size: 20,
//                                                     color: bnw900,
//                                                   ),
//                                                 )
//                                               : null,
//                                           prefixIcon: Icon(
//                                             PhosphorIcons.magnifying_glass,
//                                             color: bnw500,
//                                           ),
//                                           hintText: 'Cari',
//                                           hintStyle: heading3(FontWeight.w500,
//                                               bnw500, 'Outfit')),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: ListView.builder(
//                                   keyboardDismissBehavior:
//                                       ScrollViewKeyboardDismissBehavior.onDrag,
//                                   physics: BouncingScrollPhysics(),
//                                   itemCount: searchResultList?.length,
//                                   itemBuilder: (context, index) {
//                                     final province = searchResultList?[index];
//                                     final isSelected =
//                                         province == selectedProvince;

//                                     return Column(
//                                       children: [
//                                         ListTile(
//                                           title: Text(
//                                             province['NAME'] != null
//                                                 ? capitalizeEachWord(
//                                                     province['NAME'].toString())
//                                                 : '',
//                                           ),
//                                           trailing: Icon(
//                                             isSelected
//                                                 ? PhosphorIcons
//                                                     .radio_button_fill
//                                                 : PhosphorIcons.radio_button,
//                                             color: isSelected
//                                                 ? primary500
//                                                 : bnw900,
//                                           ),
//                                           onTap: () {
//                                             setState(() {
//                                               textFieldFocusNode.unfocus();
//                                               _myProvince = province['ID'];
//                                               idprov = province['ID'];

//                                               prov = province['NAME'];

//                                               selectedProvince =
//                                                   province.toString();
//                                               _selectProvince(province);
//                                               _getRegenciesList(_myProvince);
//                                               print(province['NAME']);
//                                             });
//                                           },
//                                         ),
//                                         Divider(color: bnw300),
//                                       ],
//                                     );
//                                   },
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   autoReload();
//                                   _getRegenciesList(_myProvince);
//                                   Navigator.pop(context);
//                                 },
//                                 child: buttonXXL(
//                                   Center(
//                                     child: Text(
//                                       'Selesai',
//                                       style: heading2(
//                                           FontWeight.w600, bnw100, 'Outfit'),
//                                     ),
//                                   ),
//                                   double.infinity,
//                                 ),
//                               ),
//                               SizedBox(height: size8)
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: bnw100,
//           border: Border(
//             bottom: BorderSide(
//               width: width1,
//               color: bnw500,
//             ),
//           ),
//         ),
//         child: Align(
//           alignment: Alignment.centerLeft,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     'Provinsi',
//                     style: heading4(FontWeight.w400, bnw900, 'Outfit'),
//                   ),
//                   Text(
//                     ' *',
//                     style: heading4(FontWeight.w400, danger500, 'Outfit'),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: size12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     prov == null
//                         ? Text(
//                             'Provinsi',
//                             style: heading2(FontWeight.w600, bnw500, 'Outfit'),
//                           )
//                         : Text(
//                             capitalizeEachWord(prov.toString()),
//                             style: heading2(FontWeight.w600, bnw900, 'Outfit'),
//                           ),
//                     Icon(
//                       PhosphorIcons.caret_down,
//                       color: bnw900,
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   GestureDetector regenciesField(BuildContext context) {
//     bool isKeyboardActive = false;
//     return GestureDetector(
//       onTap: () {
//         setState(
//           () {
//             autoReload();
//             // log(kab.toString());
//             showModalBottomSheet(
//               isScrollControlled: true,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(size24),
//               ),
//               context: context,
//               builder: (context) {
//                 return StatefulBuilder(
//                   builder: (BuildContext context, setState) =>
//                       FractionallySizedBox(
//                     heightFactor: isKeyboardActive ? 0.9 : 0.80,
//                     child: GestureDetector(
//                       onTap: () => textFieldFocusNode.unfocus(),
//                       child: Container(
//                         height: MediaQuery.of(context).size.height / 1.8,
//                         padding: EdgeInsets.only(
//                             bottom: MediaQuery.of(context).viewInsets.bottom),
//                         decoration: BoxDecoration(
//                           color: bnw100,
//                           borderRadius: BorderRadius.only(
//                             topRight: Radius.circular(size12),
//                             topLeft: Radius.circular(size12),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.only(left: size12, right: size12),
//                           child: Column(
//                             children: [
//                               Container(
//                                 margin: EdgeInsets.all(size8),
//                                 height: 4,
//                                 width: 140,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(size8),
//                                   color: bnw300,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(
//                                     size8, size16, size8, size16),
//                                 child: FocusScope(
//                                   child: Focus(
//                                     onFocusChange: (value) {
//                                       isKeyboardActive = value;
//                                       setState(() {});
//                                     },
//                                     child: TextField(
//                                       cursorColor: primary500,
//                                       onChanged: ((value) {
//                                         _runSearchRegencies(value);
//                                         setState(() {});
//                                       }),
//                                       controller: searchController,
//                                       focusNode: textFieldFocusNode,
//                                       decoration: InputDecoration(
//                                           contentPadding: EdgeInsets.symmetric(
//                                               vertical: size12),
//                                           isDense: true,
//                                           filled: true,
//                                           fillColor: bnw200,
//                                           border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                             borderSide: BorderSide(
//                                               color: bnw300,
//                                             ),
//                                           ),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                             borderSide: BorderSide(
//                                               width: 2,
//                                               color: primary500,
//                                             ),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                             borderSide: BorderSide(
//                                               color: bnw300,
//                                             ),
//                                           ),
//                                           suffixIcon: searchController
//                                                   .text.isNotEmpty
//                                               ? GestureDetector(
//                                                   onTap: () {
//                                                     searchController.text = '';
//                                                     _runSearchRegencies('');
//                                                     setState(() {});
//                                                   },
//                                                   child: Icon(
//                                                     PhosphorIcons.x_fill,
//                                                     size: 20,
//                                                     color: bnw900,
//                                                   ),
//                                                 )
//                                               : null,
//                                           prefixIcon: Icon(
//                                             PhosphorIcons.magnifying_glass,
//                                             color: bnw500,
//                                           ),
//                                           hintText: 'Cari',
//                                           hintStyle: heading3(FontWeight.w500,
//                                               bnw500, 'Outfit')),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: searchResultListRegencies == null
//                                     ? Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           Text("Isi Provinsi terlebih dahulu"),
//                                         ],
//                                       )
//                                     : ListView.builder(
//                                         keyboardDismissBehavior:
//                                             ScrollViewKeyboardDismissBehavior
//                                                 .onDrag,
//                                         itemCount:
//                                             searchResultListRegencies?.length ??
//                                                 0,
//                                         physics: BouncingScrollPhysics(),
//                                         itemBuilder: (context, index) {
//                                           final regencies =
//                                               searchResultListRegencies?[index];
//                                           final isSelected =
//                                               regencies == selectedRegencies;

//                                           return Column(
//                                             children: [
//                                               ListTile(
//                                                 title: Text(
//                                                   regencies['NAME'] != null
//                                                       ? capitalizeEachWord(
//                                                           regencies['NAME']
//                                                               .toString())
//                                                       : '',
//                                                 ),
//                                                 trailing: Icon(
//                                                   isSelected
//                                                       ? PhosphorIcons
//                                                           .radio_button_fill
//                                                       : PhosphorIcons
//                                                           .radio_button,
//                                                   color: isSelected
//                                                       ? primary500
//                                                       : bnw900,
//                                                 ),
//                                                 onTap: () {
//                                                   setState(() {
//                                                     textFieldFocusNode
//                                                         .unfocus();
//                                                     _myRegencies =
//                                                         regencies['ID'];
//                                                     idkab = regencies['ID'];
//                                                     kab = regencies['NAME']
//                                                         .toString();

//                                                     selectedRegencies =
//                                                         regencies.toString();
//                                                     _selectRegencies(regencies);
//                                                     _getDistrictList(
//                                                         _myRegencies);
//                                                     print(regencies['NAME']);
//                                                   });
//                                                 },
//                                               ),
//                                               Divider(color: bnw300),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   autoReload();
//                                   _getDistrictList(_myRegencies);
//                                   Navigator.pop(context);
//                                 },
//                                 child: buttonXXL(
//                                   Center(
//                                     child: Text(
//                                       'Selesai',
//                                       style: heading2(
//                                           FontWeight.w600, bnw100, 'Outfit'),
//                                     ),
//                                   ),
//                                   double.infinity,
//                                 ),
//                               ),
//                               SizedBox(height: size8)
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: bnw100,
//           border: Border(
//             bottom: BorderSide(
//               width: width1,
//               color: bnw500,
//             ),
//           ),
//         ),
//         child: Align(
//           alignment: Alignment.centerLeft,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     'Kabupaten/Kota',
//                     style: heading4(FontWeight.w400, bnw900, 'Outfit'),
//                   ),
//                   Text(
//                     ' *',
//                     style: heading4(FontWeight.w400, danger500, 'Outfit'),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: size12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     kab == null
//                         ? Text(
//                             'Kabupaten',
//                             style: heading2(FontWeight.w600, bnw500, 'Outfit'),
//                           )
//                         : Text(
//                             capitalizeEachWord(kab.toString()),
//                             style: heading2(FontWeight.w600, bnw900, 'Outfit'),
//                           ),
//                     Icon(
//                       PhosphorIcons.caret_down,
//                       color: bnw900,
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   GestureDetector districtField(BuildContext context) {
//     bool isKeyboardActive = false;
//     return GestureDetector(
//       onTap: () {
//         setState(
//           () {
//             autoReload();
//             // log(kec.toString());
//             showModalBottomSheet(
//               isScrollControlled: true,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(size24),
//               ),
//               context: context,
//               builder: (context) {
//                 return StatefulBuilder(
//                   builder: (BuildContext context, setState) =>
//                       FractionallySizedBox(
//                     heightFactor: isKeyboardActive ? 0.9 : 0.80,
//                     child: GestureDetector(
//                       onTap: () => textFieldFocusNode.unfocus(),
//                       child: Container(
//                         height: MediaQuery.of(context).size.height / 1.8,
//                         padding: EdgeInsets.only(
//                             bottom: MediaQuery.of(context).viewInsets.bottom),
//                         decoration: BoxDecoration(
//                           color: bnw100,
//                           borderRadius: BorderRadius.only(
//                             topRight: Radius.circular(size12),
//                             topLeft: Radius.circular(size12),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.only(left: size12, right: size12),
//                           child: Column(
//                             children: [
//                               Container(
//                                 margin: EdgeInsets.all(size8),
//                                 height: 4,
//                                 width: 140,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(size8),
//                                   color: bnw300,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(
//                                     size8, size16, size8, size16),
//                                 child: FocusScope(
//                                   child: Focus(
//                                     onFocusChange: (value) {
//                                       isKeyboardActive = value;
//                                       setState(() {});
//                                     },
//                                     child: TextField(
//                                       cursorColor: primary500,
//                                       focusNode: textFieldFocusNode,
//                                       controller: searchController,
//                                       onChanged: ((value) {
//                                         _runSearchDistrict(value);
//                                         setState(() {});
//                                       }),
//                                       decoration: InputDecoration(
//                                           contentPadding: EdgeInsets.symmetric(
//                                               vertical: size12),
//                                           isDense: true,
//                                           filled: true,
//                                           fillColor: bnw200,
//                                           border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                             borderSide: BorderSide(
//                                               color: bnw300,
//                                             ),
//                                           ),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                             borderSide: BorderSide(
//                                               width: 2,
//                                               color: primary500,
//                                             ),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                             borderSide: BorderSide(
//                                               color: bnw300,
//                                             ),
//                                           ),
//                                           suffixIcon: searchController
//                                                   .text.isNotEmpty
//                                               ? GestureDetector(
//                                                   onTap: () {
//                                                     searchController.text = '';
//                                                     _runSearchDistrict('');
//                                                     setState(() {});
//                                                   },
//                                                   child: Icon(
//                                                     PhosphorIcons.x_fill,
//                                                     size: 20,
//                                                     color: bnw900,
//                                                   ),
//                                                 )
//                                               : null,
//                                           prefixIcon: Icon(
//                                             PhosphorIcons.magnifying_glass,
//                                             color: bnw500,
//                                           ),
//                                           hintText: 'Cari',
//                                           hintStyle: heading3(FontWeight.w500,
//                                               bnw500, 'Outfit')),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: searchResultListDistrict == null
//                                     ? Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                               "Isi Kabupaten/Kota terlebih dahulu"),
//                                         ],
//                                       )
//                                     : ListView.builder(
//                                         keyboardDismissBehavior:
//                                             ScrollViewKeyboardDismissBehavior
//                                                 .onDrag,
//                                         physics: BouncingScrollPhysics(),
//                                         itemCount:
//                                             searchResultListDistrict?.length ??
//                                                 0,
//                                         itemBuilder: (context, index) {
//                                           final district =
//                                               searchResultListDistrict?[index];
//                                           final isSelected =
//                                               district == selectedDistrict;

//                                           return Column(
//                                             children: [
//                                               ListTile(
//                                                 title: Text(
//                                                   district['NAME'] != null
//                                                       ? capitalizeEachWord(
//                                                           district['NAME']
//                                                               .toString())
//                                                       : '',
//                                                 ),
//                                                 trailing: Icon(
//                                                   isSelected
//                                                       ? PhosphorIcons
//                                                           .radio_button_fill
//                                                       : PhosphorIcons
//                                                           .radio_button,
//                                                   color: isSelected
//                                                       ? primary500
//                                                       : bnw900,
//                                                 ),
//                                                 onTap: () {
//                                                   setState(() {
//                                                     textFieldFocusNode
//                                                         .unfocus();
//                                                     _mydistrict =
//                                                         district['ID'];
//                                                     idkec = district['ID'];

//                                                     kec = district['NAME'];

//                                                     selectedRegencies =
//                                                         district.toString();
//                                                     _selectDistrict(district);
//                                                     _getVillageList(
//                                                         _mydistrict);
//                                                     print(district['NAME']);
//                                                   });
//                                                 },
//                                               ),
//                                               Divider(color: bnw300),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   autoReload();
//                                   _getVillageList(_mydistrict);
//                                   Navigator.pop(context);
//                                 },
//                                 child: buttonXXL(
//                                   Center(
//                                     child: Text(
//                                       'Selesai',
//                                       style: heading2(
//                                           FontWeight.w600, bnw100, 'Outfit'),
//                                     ),
//                                   ),
//                                   double.infinity,
//                                 ),
//                               ),
//                               SizedBox(height: size8)
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: bnw100,
//           border: Border(
//             bottom: BorderSide(
//               width: width1,
//               color: bnw500,
//             ),
//           ),
//         ),
//         child: Align(
//           alignment: Alignment.centerLeft,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     'Kecamatan',
//                     style: heading4(FontWeight.w400, bnw900, 'Outfit'),
//                   ),
//                   Text(
//                     ' *',
//                     style: heading4(FontWeight.w400, danger500, 'Outfit'),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: size12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     kec == null
//                         ? Text(
//                             'Kecamatan',
//                             style: heading2(FontWeight.w600, bnw500, 'Outfit'),
//                           )
//                         : Text(
//                             capitalizeEachWord(kec.toString()),
//                             style: heading2(FontWeight.w600, bnw900, 'Outfit'),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                     Icon(
//                       PhosphorIcons.caret_down,
//                       color: bnw900,
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   GestureDetector villageField() {
//     bool isKeyboardActive = false;
//     return GestureDetector(
//       onTap: () {
//         setState(
//           () {
//             autoReload();
//             log(desa.toString());
//             showModalBottomSheet(
//               isScrollControlled: true,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(size24),
//               ),
//               context: context,
//               builder: (context) {
//                 return StatefulBuilder(
//                   builder: (BuildContext context, setState) =>
//                       FractionallySizedBox(
//                     heightFactor: isKeyboardActive ? 0.9 : 0.80,
//                     child: GestureDetector(
//                       onTap: () => textFieldFocusNode.unfocus(),
//                       child: Container(
//                         height: MediaQuery.of(context).size.height / 1.8,
//                         padding: EdgeInsets.only(
//                             bottom: MediaQuery.of(context).viewInsets.bottom),
//                         decoration: BoxDecoration(
//                           color: bnw100,
//                           borderRadius: BorderRadius.only(
//                             topRight: Radius.circular(size12),
//                             topLeft: Radius.circular(size12),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.only(left: size12, right: size12),
//                           child: Column(
//                             children: [
//                               Container(
//                                 margin: EdgeInsets.all(size8),
//                                 height: 4,
//                                 width: 140,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(size8),
//                                   color: bnw300,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(
//                                     size8, size16, size8, size16),
//                                 child: FocusScope(
//                                   child: Focus(
//                                     onFocusChange: (value) {
//                                       isKeyboardActive = value;
//                                       setState(() {});
//                                     },
//                                     child: TextField(
//                                       cursorColor: primary500,
//                                       focusNode: textFieldFocusNode,
//                                       controller: searchController,
//                                       onChanged: ((value) {
//                                         _runSearchVillage(value);
//                                         setState(() {});
//                                       }),
//                                       decoration: InputDecoration(
//                                           contentPadding: EdgeInsets.symmetric(
//                                               vertical: size12),
//                                           isDense: true,
//                                           filled: true,
//                                           fillColor: bnw200,
//                                           border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                             borderSide: BorderSide(
//                                               color: bnw300,
//                                             ),
//                                           ),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                             borderSide: BorderSide(
//                                               width: 2,
//                                               color: primary500,
//                                             ),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(size8),
//                                             borderSide: BorderSide(
//                                               color: bnw300,
//                                             ),
//                                           ),
//                                           suffixIcon: searchController
//                                                   .text.isNotEmpty
//                                               ? GestureDetector(
//                                                   onTap: () {
//                                                     searchController.text = '';
//                                                     _runSearchVillage('');
//                                                     setState(() {});
//                                                   },
//                                                   child: Icon(
//                                                     PhosphorIcons.x_fill,
//                                                     size: 20,
//                                                     color: bnw900,
//                                                   ),
//                                                 )
//                                               : null,
//                                           prefixIcon: Icon(
//                                             PhosphorIcons.magnifying_glass,
//                                             color: bnw500,
//                                           ),
//                                           hintText: 'Cari',
//                                           hintStyle: heading3(FontWeight.w500,
//                                               bnw500, 'Outfit')),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: searchResultListVillage == null
//                                     ? Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           Text("Isi Kecamatan terlebih dahulu"),
//                                         ],
//                                       )
//                                     : ListView.builder(
//                                         keyboardDismissBehavior:
//                                             ScrollViewKeyboardDismissBehavior
//                                                 .onDrag,
//                                         physics: BouncingScrollPhysics(),
//                                         itemCount:
//                                             searchResultListVillage?.length ??
//                                                 0,
//                                         itemBuilder: (context, index) {
//                                           final village =
//                                               searchResultListVillage?[index];
//                                           final isSelected =
//                                               village == selectedVillage;

//                                           return Column(
//                                             children: [
//                                               ListTile(
//                                                 title: Text(
//                                                   village['NAME'] != null
//                                                       ? capitalizeEachWord(
//                                                           village['NAME']
//                                                               .toString())
//                                                       : '',
//                                                 ),
//                                                 trailing: Icon(
//                                                   isSelected
//                                                       ? PhosphorIcons
//                                                           .radio_button_fill
//                                                       : PhosphorIcons
//                                                           .radio_button,
//                                                   color: isSelected
//                                                       ? primary500
//                                                       : bnw900,
//                                                 ),
//                                                 onTap: () {
//                                                   setState(() {
//                                                     textFieldFocusNode
//                                                         .unfocus();
//                                                     _myvillage = village['ID'];
//                                                     desa = village['NAME'];
//                                                     iddesa = village['ID'];

//                                                     selectedVillage =
//                                                         village.toString();
//                                                     _selectVillage(village);

//                                                     print(village['NAME']);
//                                                   });
//                                                 },
//                                               ),
//                                               Divider(color: bnw300),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   autoReload();
//                                   // _getVillageList(_);
//                                   Navigator.pop(context);
//                                 },
//                                 child: buttonXXL(
//                                   Center(
//                                     child: Text(
//                                       'Selesai',
//                                       style: heading2(
//                                           FontWeight.w600, bnw100, 'Outfit'),
//                                     ),
//                                   ),
//                                   double.infinity,
//                                 ),
//                               ),
//                               SizedBox(height: size8)
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: bnw100,
//           border: Border(
//             bottom: BorderSide(
//               width: width1,
//               color: bnw500,
//             ),
//           ),
//         ),
//         child: Align(
//           alignment: Alignment.centerLeft,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     'Kelurahan',
//                     style: heading4(FontWeight.w400, bnw900, 'Outfit'),
//                   ),
//                   Text(
//                     ' *',
//                     style: heading4(FontWeight.w400, danger500, 'Outfit'),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: size12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     desa == null
//                         ? Text(
//                             'Kelurahan',
//                             style: heading2(FontWeight.w600, bnw500, 'Outfit'),
//                           )
//                         : Text(
//                             capitalizeEachWord(desa.toString()),
//                             style: heading2(FontWeight.w600, bnw900, 'Outfit'),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                     Icon(
//                       PhosphorIcons.caret_down,
//                       color: bnw900,
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<dynamic>? provincesList;
//   List<dynamic>? searchResultList;
//   dynamic selectedProvince;
//   bool isItemSelected = false;

//   String? _myProvince;

//   String provinceInfoUrl = '$url/api/province';
//   Future _getProvinceList() async {
//     await http.post(
//       Uri.parse(provinceInfoUrl),
//       headers: {},
//       body: {
//         "deviceid": identifier,
//       },
//     ).then((response) {
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data != null && data['data'] != null) {
//           setState(() {
//             provincesList = List<dynamic>.from(data['data']);
//             searchResultList = provincesList;
//           });
//         }
//       }
//     });
//   }

//   void _runSearchProvince(String searchText) {
//     setState(() {
//       searchResultList = provincesList
//           ?.where(
//             (province) => province
//                 .toString()
//                 .toLowerCase()
//                 .contains(searchText.toLowerCase()),
//           )
//           .toList();
//     });
//   }

//   void _selectProvince(dynamic province) {
//     setState(() {
//       selectedProvince = province;
//       isItemSelected = true;
//     });
//   }

//   // Get Regencies information by API
//   List<dynamic>? regenciesList;
//   List<dynamic>? searchResultListRegencies;

//   dynamic selectedRegencies;
//   // bool isItemSelected = false;

//   String? _myRegencies;

//   String regenciesInfoUrl = '$url/api/regencies';
//   Future _getRegenciesList(idregencies) async {
//     await http.post(Uri.parse(regenciesInfoUrl), headers: {
//       // 'token': widget.token,
//     }, body: {
//       "deviceid": identifier,
//       "province": idregencies,
//     }).then((response) {
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data != null && data['data'] != null) {
//           setState(() {
//             regenciesList = List<dynamic>.from(data['data']);
//             searchResultListRegencies = regenciesList;
//           });
//         }
//       }
//     });
//   }

//   void _runSearchRegencies(String searchText) {
//     setState(() {
//       searchResultListRegencies = regenciesList
//           ?.where((regencies) => regencies
//               .toString()
//               .toLowerCase()
//               .contains(searchText.toLowerCase()))
//           .toList();
//     });
//   }

//   void _selectRegencies(dynamic regencies) {
//     setState(() {
//       selectedRegencies = regencies;
//       isItemSelected = true;
//     });
//   }

//   // Get District information by API
//   List<dynamic>? districtList;
//   List<dynamic>? searchResultListDistrict;

//   dynamic selectedDistrict;
//   String? _mydistrict;

//   String districtInfoUrl = '$url/api/district';
//   Future _getDistrictList(iddistrict) async {
//     await http.post(Uri.parse(districtInfoUrl), headers: {
//       // 'token': widget.token,
//     }, body: {
//       "deviceid": identifier,
//       "regencies": iddistrict,
//     }).then((response) {
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data != null && data['data'] != null) {
//           setState(() {
//             districtList = List<dynamic>.from(data['data']);
//             searchResultListDistrict = districtList;
//           });
//         }
//       }
//     });
//   }

//   void _runSearchDistrict(String searchText) {
//     setState(() {
//       searchResultListDistrict = districtList
//           ?.where((district) => district
//               .toString()
//               .toLowerCase()
//               .contains(searchText.toLowerCase()))
//           .toList();
//     });
//   }

//   void _selectDistrict(dynamic district) {
//     setState(() {
//       selectedDistrict = district;
//       isItemSelected = true;
//     });
//   }

//   // Get District information by API
//   List<dynamic>? villageList;
//   List<dynamic>? searchResultListVillage;

//   dynamic selectedVillage;
//   String? _myvillage;

//   String villageInfoUrl = '$url/api/village';
//   Future _getVillageList(idvillage) async {
//     await http.post(Uri.parse(villageInfoUrl), headers: {
//       // 'token': widget.token
//     }, body: {
//       "deviceid": identifier,
//       "district": idvillage,
//     }).then((response) {
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data != null && data['data'] != null) {
//           setState(() {
//             villageList = List<dynamic>.from(data['data']);
//             searchResultListVillage = villageList;
//           });
//         }
//       }
//     });
//   }

//   void _runSearchVillage(String searchText) {
//     setState(() {
//       searchResultListVillage = villageList
//           ?.where((village) => village
//               .toString()
//               .toLowerCase()
//               .contains(searchText.toLowerCase()))
//           .toList();
//     });
//   }

//   void _selectVillage(dynamic village) {
//     setState(() {
//       selectedVillage = village;
//       isItemSelected = true;
//     });
//   }

//   // Get District information by API
//   List<dynamic>? tipeList;
//   List<dynamic>? searchResultListTipeUsaha;

//   dynamic selectedTipeUsaha;

//   String? _mytipe;

//   String tipeInfoUrl = '$url/api/tipeusaha';
//   Future _getTipeList() async {
//     await http.post(Uri.parse(tipeInfoUrl), headers: {
//       // 'token': widget.token
//     }, body: {
//       "deviceid": identifier,
//     }).then((response) {
//       final data = json.decode(response.body);
//       if (data != null && data['data'] != null) {
//         setState(() {
//           tipeList = List<dynamic>.from(data['data']);
//           searchResultListTipeUsaha = tipeList;
//         });
//       }
//     });
//   }

//   void _runSearchTipeUsaha(String searchText) {
//     setState(() {
//       searchResultListTipeUsaha = tipeList
//           ?.where((tipeUsaha) => tipeUsaha
//               .toString()
//               .toLowerCase()
//               .contains(searchText.toLowerCase()))
//           .toList();
//     });
//   }

//   void _selectTipeUsaha(dynamic tipeUsaha) {
//     setState(() {
//       selectedTipeUsaha = tipeUsaha;
//       isItemSelected = true;
//     });
//   }

//   tambahGambar(BuildContext context) async {
//     showModalBottomSheet(
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(25),
//       ),
//       context: context,
//       builder: (context) => IntrinsicHeight(
//         child: Container(
//           padding:
//               EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//           decoration: BoxDecoration(
//             color: bnw100,
//             borderRadius: BorderRadius.only(
//               topRight: Radius.circular(size8),
//               topLeft: Radius.circular(size8),
//             ),
//           ),
//           child: Padding(
//             padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 dividerShowdialog(),
//                 SizedBox(height: size16),
//                 myImage != null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(120),
//                         child: Container(
//                             height: 200,
//                             width: 200,
//                             color: bnw400,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(size8),
//                               child: Image.file(
//                                 myImage!,
//                                 fit: BoxFit.cover,
//                               ),
//                             )),
//                       )
//                     : Container(
//                         height: 200,
//                         width: 200,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(120),
//                           // border: Border.all(),
//                         ),
//                         child: Icon(
//                           PhosphorIcons.storefront_fill,
//                           color: bnw900,
//                           size: 200,
//                         )),
//                 SizedBox(height: size16),
//                 Column(
//                   children: [
//                     GestureDetector(
//                       onTap: () async {
//                         await getImage();
//                         Navigator.pop(context);
//                       },
//                       child: SizedBox(
//                         child: TextFormField(
//                           cursorColor: primary500,
//                           enabled: false,
//                           style: heading3(FontWeight.w400, bnw900, 'Outfit'),
//                           decoration: InputDecoration(
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   width: 2,
//                                   color: primary500,
//                                 ),
//                               ),
//                               focusColor: primary500,
//                               prefixIcon: Icon(
//                                 PhosphorIcons.plus,
//                                 color: bnw900,
//                               ),
//                               hintText: 'Tambah Foto',
//                               hintStyle:
//                                   heading3(FontWeight.w400, bnw900, 'Outfit')),
//                         ),
//                       ),
//                     ),
//                     myImage != null
//                         ? GestureDetector(
//                             onTap: () async {
//                               img64 = null;
//                               myImage = null;
//                               Navigator.pop(context);
//                               setState(() {});
//                             },
//                             child: SizedBox(
//                               child: TextFormField(
//                                 cursorColor: primary500,
//                                 enabled: false,
//                                 style:
//                                     heading3(FontWeight.w400, bnw900, 'Outfit'),
//                                 decoration: InputDecoration(
//                                   focusedBorder: UnderlineInputBorder(
//                                     borderSide: BorderSide(
//                                       width: 2,
//                                       color: primary500,
//                                     ),
//                                   ),
//                                   focusColor: primary500,
//                                   prefixIcon: Icon(
//                                     PhosphorIcons.trash,
//                                     color: bnw900,
//                                   ),
//                                   hintText: 'Hapus Foto',
//                                   hintStyle: heading3(
//                                     FontWeight.w400,
//                                     bnw900,
//                                     'Outfit',
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         : SizedBox(),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
