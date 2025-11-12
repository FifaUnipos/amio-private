import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../services/apimethod.dart';
import '../../../../utils/component/component_color.dart';
import '../../../../utils/component/component_button.dart';

class UbahPelangganPage extends StatefulWidget {
  String token, memberid, nameEdit, nomorEdit, emailEdit, instagramEdit;
  PageController pageController;
  UbahPelangganPage({
    Key? key,
    required this.token,
    required this.memberid,
    required this.nameEdit,
    required this.nomorEdit,
    required this.emailEdit,
    required this.instagramEdit,
    required this.pageController,
  }) : super(key: key);

  @override
  State<UbahPelangganPage> createState() => _UbahPelangganPageState();
}

class _UbahPelangganPageState extends State<UbahPelangganPage> {
  late TextEditingController conNameEdit =
      TextEditingController(text: widget.nameEdit);
  late TextEditingController conPhoneEdit =
      TextEditingController(text: widget.nomorEdit);
  late TextEditingController conEmailEdit =
      TextEditingController(text: widget.emailEdit);
  late TextEditingController conInstagramEdit =
      TextEditingController(text: widget.instagramEdit);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  'Ubah Pelanggan',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  nameProfile ?? '',
                  style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: size16),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            physics: BouncingScrollPhysics(),
            children: [
              fieldEditProduk(
                'Nama Pelanggan',
                'Muhammad Nabil Musyaffa',
                conNameEdit,
                TextInputType.text,
                false,
              ),
              SizedBox(height: size16),
              fieldEditProduk(
                'Nomor Telepon',
                '0812346789',
                conPhoneEdit,
                TextInputType.number,
                false,
              ),
              SizedBox(height: size16),
              fieldEditProduk(
                'Email',
                'nabil@gmail.com',
                conEmailEdit,
                TextInputType.emailAddress,
                true,
              ),
              SizedBox(height: size16),
              fieldEditProduk(
                'Instagram',
                '@nabil742',
                conInstagramEdit,
                TextInputType.text,
                true,
              ),
            ],
          ),
        ),
        SizedBox(height: size16),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () {
              editPelanggan(
                context,
                widget.token,
                widget.memberid,
                conNameEdit.text,
                '',
                conPhoneEdit.text,
                conEmailEdit.text,
                conInstagramEdit.text,
              ).then((value) {
                if (value == '00') {
                  widget.pageController.jumpToPage(0);
                  setState(() {});
                }
              });

              initState();
              setState(() {});
            },
            child: buttonXL(
                Center(
                  child: Text(
                    'Simpan',
                    style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                  ),
                ),
                0),
          ),
        )
      ],
    );
  }

  fieldEditProduk(title, hint, mycontroller, TextInputType numberNo, bintang) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: heading4(FontWeight.w500, bnw900, 'Outfit'),
              ),
              Text(
                bintang ? '' : ' *',
                style: heading4(FontWeight.w700, red500, 'Outfit'),
              ),
            ],
          ),
          TextFormField(
            cursorColor: primary500,
            keyboardType: numberNo,
            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
            controller: mycontroller,
            onChanged: (value) {},
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: primary500,
                ),
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: size12),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: bnw500,
                ),
              ),
              hintText: 'Cth : $hint',
              hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }
}
