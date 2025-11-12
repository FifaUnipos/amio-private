import 'dart:developer';

import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../../../../utils/component/component_button.dart';
import '../../../../services/apimethod.dart';
import '../../../../utils/component/component_color.dart';

class UbahPromosiPage extends StatefulWidget {
  String token, productid;
  PageController pageController;
  UbahPromosiPage({
    Key? key,
    required this.token,
    required this.productid,
    required this.pageController,
  }) : super(key: key);

  @override
  State<UbahPromosiPage> createState() => _UbahPromosiPageState();
}

class _UbahPromosiPageState extends State<UbahPromosiPage> {
  bool onswitchtampikan = true;
  String kasirAktif = "Aktif";

  late TextEditingController conNameProdukEdit =
      TextEditingController(text: nameEditPromosi);
  late TextEditingController conHargaEdit =
      TextEditingController(text: hargaProductPromosi);
  late TextEditingController conPointEdit =
      TextEditingController(text: poinEditPromosi);

  void formatInputRpHargaEdit() {
    String text = conHargaEdit.text.replaceAll('.', '');
    int value = int.tryParse(text)!;
    String formattedAmount = formatCurrency(value);

    conHargaEdit.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  void formatInputRpPoinEdit() {
    String text = conPointEdit.text.replaceAll('.', '');
    int value = int.tryParse(text)!;
    String formattedAmount = formatCurrency(value);

    conPointEdit.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  refreshTampilan() {
    setState(() {
      conNameProdukEdit.clear();
      conHargaEdit.clear();
      conPointEdit.clear();
      onswitchtampikan = true;
    });
  }

  @override
  void initState() {
    super.initState();

    conHargaEdit.addListener(formatInputRpHargaEdit);
    conPointEdit.addListener(formatInputRpPoinEdit);
  }

  void initial() {
    // if(){}
  }

  @override
  void dispose() {
    conNameProdukEdit.dispose();
    conHargaEdit.dispose();
    conPointEdit.dispose();
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
                  'Ubah Voucher',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Voucher akan ditambahkan kedalam Toko yang telah dipilih',
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
                'Nama Produk',
                conNameProdukEdit,
                TextInputType.text,
              ),
              SizedBox(height: size16),
              fieldEditProduk(
                'Coin',
                conPointEdit,
                TextInputType.number,
              ),
              SizedBox(height: size16),
              fieldEditProduk(
                'Harga Jual',
                conHargaEdit,
                TextInputType.number,
              ),
              SizedBox(height: size16),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    onswitchtampikan = !onswitchtampikan;
                    onswitchtampikan
                        ? kasirAktif = "Aktif"
                        : kasirAktif = "Tidak Aktif";
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tampilkan Di Kasir',
                          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        Text(
                          kasirAktif,
                          style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ],
                    ),
                    FlutterSwitch(
                      width: 52.0,
                      height: 28.0,
                      // value: snapshot.data['isPPN'] == 1 ? true : false,
                      value: onswitchtampikan,
                      padding: 0,
                      activeIcon: Icon(PhosphorIcons.check, color: primary500),
                      inactiveIcon: Icon(PhosphorIcons.x, color: bnw100),
                      activeColor: primary500,
                      inactiveColor: bnw100,
                      borderRadius: 30.0,
                      inactiveToggleColor: bnw900,
                      activeToggleColor: primary200,
                      activeSwitchBorder: Border.all(color: primary500),
                      inactiveSwitchBorder: Border.all(color: bnw300, width: 2),
                      onToggle: (val) {
                        onswitchtampikan = val;
                        onswitchtampikan
                            ? kasirAktif = "Aktif"
                            : kasirAktif = "Tidak Aktif";
                        log(onswitchtampikan.toString());
                        // log(kasirAktif);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size12),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () {
              List<String> value = [""];

              updateVoucher(
                context,
                widget.token,
                conNameProdukEdit.text,
                onswitchtampikan.toString(),
                conHargaEdit.text.replaceAll(RegExp(r'[^0-9]'), ''),
                conPointEdit.text.replaceAll(RegExp(r'[^0-9]'), ''),
                value,
                widget.pageController,
                widget.productid,
              ).then((value) {
                if (value == '00') {
                  widget.pageController.jumpToPage(0);
                  refreshTampilan();
                }
              });

              setState(() {});
              // initState();
            },
            child: buttonXL(
              Center(
                child: Text(
                  'Simpan',
                  style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                ),
              ),
              MediaQuery.of(context).size.width,
              // primary500,
            ),
          ),
        )
      ],
    );
  }

  fieldEditProduk(title, mycontroller, TextInputType numberNo) {
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
                ' *',
                style: heading4(FontWeight.w700, red500, 'Outfit'),
              ),
            ],
          ),
          TextFormField(
            cursorColor: primary500,
            keyboardType: numberNo,
            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
            controller: mycontroller,
            onSaved: (value) {
              mycontroller.text = value;
              setState(() {});
            },
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
              hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }
}
