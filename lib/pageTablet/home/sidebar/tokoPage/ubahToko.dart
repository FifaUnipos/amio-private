// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:io' as Io;
// import 'dart:typed_data';
// import 'package:unipos_app_335/utils/skeletons.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:http/http.dart' as http;

// import 'package:flutter/material.dart';
// import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';

// import '../../../../main.dart';
// import '../../../../models/tokoModel/singletokomodel.dart';
// import '../../../../pagehelper/loginregis/daftar_akun_toko.dart';
// import '../../../../services/apimethod.dart';
// import '../../../../services/checkConnection.dart';
// import '../../../../utils/component.dart';
// import '../../../tokopage/sidebar/produkToko/produk.dart';

// class ChangeMerchant extends StatefulWidget {
//   String token, merchantid;
//   PageController pageController = PageController();
//   ChangeMerchant({
//     Key? key,
//     required this.token,
//     required this.merchantid,
//     required this.pageController,
//   }) : super(key: key);

//   @override
//   State<ChangeMerchant> createState() => _ChangeMerchantState();
// }

// class _ChangeMerchantState extends State<ChangeMerchant> {
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
//         imageEditToko = '';
//       });
//       // Clipboard.setData(ClipboardData(text: img64));
//     } else {
//       print('Error Image');
//     }
//   }

//   late PageController pageController = widget.pageController;

//   List<SingleDataToko>? singleDatas;

//   TextEditingController searchController = TextEditingController();

//   late TextEditingController conNameMerch =
//       TextEditingController(text: nameMerchantUbah);
//   late TextEditingController conAddress =
//       TextEditingController(text: addressMerchantUbah);
//   late TextEditingController conCodePos =
//       TextEditingController(text: zipMerchantUbah);

//   String? tipe = tipeUbah,
//       prov = nameProvUbah,
//       kab = nameregUbah,
//       kec = nameDisUbah,
//       desa = nameVillageUbah;

//   // String? tipe = tipeUbah,
//   //     provUbah = nameProvUbah,
//   //     kabUbah = nameregUbah,
//   //     disUbah = nameDisUbah,
//   //     villageUbah = nameVillageUbah;

//   String? idprov = kodeProvUbah,
//       idkab = kodeRegUbah,
//       idkec = kodeDisUbah,
//       iddesa = kodeVillageUbah,
//       idtipe = idtipeUbah;

//   @override
//   void initState() {
//     checkConnection(context);

//     pageController;
//     _getProvinceList();
//     _getTipeList();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     conNameMerch.dispose();
//     conAddress.dispose();
//     conCodePos.dispose();
//     pageController.dispose();
//     super.dispose();
//   }

//   void autoReload() {
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isKeyboardActive = false;

//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             GestureDetector(
//               onTap: () {
//                 widget.pageController.jumpToPage(0);
//               },
//               child: Icon(
//                 PhosphorIcons.arrow_left,
//                 size: size48,
//                 color: bnw900,
//               ),
//             ),
//             SizedBox(width: size12),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Ubah Toko',
//                   style: heading1(FontWeight.w700, bnw900, 'Outfit'),
//                 ),
//                 Text(
//                   'Isi data toko dengan lengkap',
//                   style: heading3(FontWeight.w300, bnw900, 'Outfit'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         SizedBox(height: size16),
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(size16),
//               color: bnw100,
//             ),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: ListView(
//                     padding: EdgeInsets.zero,
//                     physics: BouncingScrollPhysics(),
//                     children: [
//                       Text(
//                         'Foto Profil',
//                         style: heading4(FontWeight.w400, bnw900, 'Outfit'),
//                       ),
//                       SizedBox(height: size16),
//                       Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () => tambahGambar(context),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: bnw900),
//                                 borderRadius: BorderRadius.circular(size8),
//                               ),
//                               height: 80,
//                               width: 80,
//                               child: myImage != null
//                                   ? ClipRRect(
//                                       borderRadius:
//                                           BorderRadius.circular(size8),
//                                       child: Image.file(
//                                         myImage!,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     )
//                                   : imageEditToko == ''
//                                       ? ClipRRect(
//                                           borderRadius:
//                                               BorderRadius.circular(size8),
//                                           child: Image.network(
//                                             imageEditToko,
//                                             fit: BoxFit.cover,
//                                             errorBuilder:
//                                                 (context, error, stackTrace) =>
//                                                     SizedBox(
//                                               child: SvgPicture.asset(
//                                                   'assets/logoProduct.svg'),
//                                             ),
//                                           ),
//                                         )
//                                       : ClipRRect(
//                                           borderRadius:
//                                               BorderRadius.circular(size8),
//                                           child: Image.network(
//                                             imageEditToko,
//                                             fit: BoxFit.cover,
//                                             errorBuilder:
//                                                 (context, error, stackTrace) =>
//                                                     GestureDetector(
//                                               onTap: () {
//                                                 tambahGambar(context);
//                                               },
//                                               child: SizedBox(
//                                                 child: Icon(
//                                                   PhosphorIcons.plus,
//                                                   color: bnw900,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                             ),
//                           ),
//                           SizedBox(width: size16),
//                           Text(
//                             'Masukkan logo atau foto yang menandakan identitas dari tokomu.',
//                             style: heading4(FontWeight.w400, bnw900, 'Outfit'),
//                           ),
//                         ],
//                       ),

//                       GestureDetector(
//                         onTap: () => tambahGambar(context),
//                         child: IntrinsicHeight(
//                           child: TextFormField(
//                             cursorColor: primary500,
//                             style: heading2(FontWeight.w600, bnw900, 'Outfit'),
//                             decoration: InputDecoration(
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   width: 2,
//                                   color: primary500,
//                                 ),
//                               ),
//                               enabledBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   width: 1.5,
//                                   color: bnw500,
//                                 ),
//                               ),
//                               enabled: false,
//                               suffixIcon: Icon(
//                                 PhosphorIcons.plus,
//                                 color: bnw900,
//                               ),
//                               hintText: 'Tambah Gambar',
//                               hintStyle:
//                                   heading2(FontWeight.w600, bnw900, 'Outfit'),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: size16),
//                       fieldAddToko('Nama Toko ', conNameMerch, conNameMerch),
//                       SizedBox(height: size16),
//                       fieldAddToko('Alamat', conAddress, conAddress),
//                       SizedBox(height: size16),
//                       fieldTipeUsaha(),
//                       SizedBox(height: size16),
//                       Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: provinceField(context),
//                               ),
//                               SizedBox(width: size16),
//                               Expanded(
//                                 child: regenciesField(context),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: size16),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: districtField(context),
//                               ),
//                               SizedBox(width: size16),
//                               Expanded(
//                                 child: villageField(),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: size16),
//                       fieldZipToko('Kode Pos', conCodePos, conCodePos),
//                       SizedBox(height: size16),
//                       // DropDown(token: widget.token),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: size16),
//                 SizedBox(
//                   width: double.infinity,
//                   child: GestureDetector(
//                     onTap: () {
//                       // print(img64);
//                       updateMerch(
//                         context,
//                         widget.token,
//                         widget.merchantid,
//                         conNameMerch.text,
//                         conAddress.text,
//                         idprov,
//                         idkab,
//                         idkec,
//                         iddesa,
//                         conCodePos.text,
//                         img64,
//                         widget.pageController,
//                         idtipe,
//                       );

//                       initState();

//                       setState(() {});
//                     },
//                     child: buttonXL(
//                       Center(
//                         child: Text(
//                           'Simpan',
//                           style: heading3(FontWeight.w600, bnw100, 'Outfit'),
//                         ),
//                       ),
//                       MediaQuery.of(context).size.width,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   fieldAddToko(title, hint, mycontroller) {
//     return StatefulBuilder(
//       builder: (context, setState) => Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   title,
//                   style: body1(FontWeight.w500, bnw900, 'Outfit'),
//                 ),
//                 Text(
//                   ' *',
//                   style: body1(FontWeight.w700, red500, 'Outfit'),
//                 ),
//               ],
//             ),
//             IntrinsicHeight(
//               child: TextFormField(
//                 cursorColor: primary500,
//                 style: heading2(FontWeight.w600, bnw900, 'Outfit'),
//                 controller: mycontroller,
//                 // onChanged: (value) {
//                 // mycontroller.text = value;
//                 //   setState(() {});
//                 // },
//                 onSaved: (value) {
//                   setState(() {
//                     mycontroller.text = value;
//                   });
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
//                   hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   fieldZipToko(title, hint, mycontroller) {
//     return StatefulBuilder(
//       builder: (context, setState) => Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   title,
//                   style: body1(FontWeight.w500, bnw900, 'Outfit'),
//                 ),
//                 Text(
//                   ' *',
//                   style: body1(FontWeight.w700, red500, 'Outfit'),
//                 ),
//               ],
//             ),
//             IntrinsicHeight(
//               child: TextFormField(
//                 cursorColor: primary500,
//                 style: heading2(FontWeight.w600, bnw900, 'Outfit'),
//                 controller: mycontroller,
//                 // onChanged: (value) {
//                 // mycontroller.text = value;
//                 //   setState(() {});
//                 // },
//                 keyboardType: TextInputType.number,
//                 onSaved: (value) {
//                   setState(() {
//                     mycontroller.text = value;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(
//                       width: 2,
//                       color: primary500,
//                     ),
//                   ),
//                   contentPadding: EdgeInsets.symmetric(vertical: size12),
//                   isDense: true,
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(
//                       width: 1.5,
//                       color: bnw500,
//                     ),
//                   ),
//                   hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   GestureDetector fieldTipeUsaha() {
//     bool isKeyboardActive = false;
//     return GestureDetector(
//       onTap: () => setState(
//         () {
//           autoReload();
//           log(tipe.toString());
//           showModalBottomSheet(
//             isScrollControlled: true,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(25),
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
//                         borderRadius: const BorderRadius.only(
//                           topRight: Radius.circular(12),
//                           topLeft: Radius.circular(12),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: size12),
//                         child: Column(
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.all(8),
//                               height: 4,
//                               width: 140,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 color: bnw300,
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
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
//                                           borderSide: BorderSide(
//                                             color: bnw300,
//                                           ),
//                                         ),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: bnw200,
//                                           ),
//                                         ),
//                                         enabledBorder: OutlineInputBorder(
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
//                                             idtipe = tipeUsaha['tipeusaha_id'];
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
//                                 autoReload();
//                                 _getRegenciesList(_myProvince);
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
//                             const SizedBox(height: 8)
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
//               width: 1.5,
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
//                     'Tipe Usaha',
//                     style: heading4(FontWeight.w400, bnw900, 'Outfit'),
//                   ),
//                   Text(
//                     ' *',
//                     style: heading4(FontWeight.w400, danger500, 'Outfit'),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: size12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     tipe == null
//                         ? Text(
//                             'Tipe Usaha',
//                             style: heading2(FontWeight.w600, bnw500, 'Outfit'),
//                           )
//                         : Text(
//                             tipe == null
//                                 ? 'Tipe Usaha'
//                                 : toBeginningOfSentenceCase(tipe.toString()) ??
//                                     '',
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

//   GestureDetector provinceField(BuildContext context) {
//     bool isKeyboardActive = false;

//     return GestureDetector(
//       onTap: () {
//         setState(
//           () {
//             autoReload();
//             log(prov.toString());
//             showModalBottomSheet(
//               isScrollControlled: true,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(25),
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
//                           borderRadius: const BorderRadius.only(
//                             topRight: Radius.circular(12),
//                             topLeft: Radius.circular(12),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8),
//                           child: Column(
//                             children: [
//                               Container(
//                                 margin: const EdgeInsets.only(top: 12),
//                                 height: 4,
//                                 width: 140,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8),
//                                   color: bnw300,
//                                 ),
//                               ),
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.fromLTRB(8, 16, 8, 16),
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
//                               const SizedBox(height: 8)
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
//               width: 1.5,
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
//               Padding(
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
//             log(kab.toString());
//             showModalBottomSheet(
//               isScrollControlled: true,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(25),
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
//                           borderRadius: const BorderRadius.only(
//                             topRight: Radius.circular(12),
//                             topLeft: Radius.circular(12),
//                           ),
//                         ),
//                         child: Padding(
//                           padding:
//                               const EdgeInsets.only(left: 12.0, right: 12.0),
//                           child: Column(
//                             children: [
//                               Container(
//                                 margin: const EdgeInsets.all(8),
//                                 height: 4,
//                                 width: 140,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8),
//                                   color: bnw300,
//                                 ),
//                               ),
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.fromLTRB(8, 16, 8, 16),
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
//                                       onChanged: ((value) {
//                                         _runSearchRegencies(value);
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
//                                         children: const [
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
//                               const SizedBox(height: 8)
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
//               width: 1.5,
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
//               Padding(
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
//             log(kec.toString());
//             showModalBottomSheet(
//               isScrollControlled: true,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(25),
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
//                           borderRadius: const BorderRadius.only(
//                             topRight: Radius.circular(12),
//                             topLeft: Radius.circular(12),
//                           ),
//                         ),
//                         child: Padding(
//                           padding:
//                               const EdgeInsets.only(left: 12.0, right: 12.0),
//                           child: Column(
//                             children: [
//                               Container(
//                                 margin: const EdgeInsets.all(8),
//                                 height: 4,
//                                 width: 140,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8),
//                                   color: bnw300,
//                                 ),
//                               ),
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.fromLTRB(8, 16, 8, 16),
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
//                                         children: const [
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
//                               const SizedBox(height: 8)
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
//           border: Border(
//             bottom: BorderSide(
//               width: 1.5,
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
//               Padding(
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
//                 borderRadius: BorderRadius.circular(25),
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
//                           borderRadius: const BorderRadius.only(
//                             topRight: Radius.circular(12),
//                             topLeft: Radius.circular(12),
//                           ),
//                         ),
//                         child: Padding(
//                           padding:
//                               const EdgeInsets.only(left: 12.0, right: 12.0),
//                           child: Column(
//                             children: [
//                               Container(
//                                 margin: const EdgeInsets.all(8),
//                                 height: 4,
//                                 width: 140,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8),
//                                   color: bnw300,
//                                 ),
//                               ),
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.fromLTRB(8, 16, 8, 16),
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
//                                         children: const [
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
//                               const SizedBox(height: 8)
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
//               width: 1.5,
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
//               Padding(
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
//                 imageEditToko.isNotEmpty
//                     ? Container(
//                         height: 200,
//                         width: 200,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(120),
//                           child: Image.network(
//                             imageEditToko,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) =>
//                                 SizedBox(
//                               child: SvgPicture.asset('assets/logoProduct.svg'),
//                             ),
//                           ),
//                         ),
//                       )
//                     : myImage != null
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(120),
//                             child: Container(
//                                 height: 200,
//                                 width: 200,
//                                 color: bnw400,
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(size8),
//                                   child: Image.file(
//                                     myImage!,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )),
//                           )
//                         : Container(
//                             height: 200,
//                             width: 200,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(120),
//                             ),
//                             child: SvgPicture.asset(
//                               'assets/logoProduct.svg',
//                               fit: BoxFit.cover,
//                             ),
//                           ),
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
//                     (myImage != null || imageEditToko != '')
//                         ? GestureDetector(
//                             onTap: () async {
//                               img64 = null;
//                               myImage = null;
//                               imageEditToko = '';
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
