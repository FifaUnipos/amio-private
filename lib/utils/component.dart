import 'dart:async';
import 'dart:developer';

import 'package:amio/pageMobile/pageHelperMobile/loginRegisMobile/loginPageMobile.dart';
import 'package:amio/pageMobile/pageTokoMobile/pengembanganPage.dart';
import 'package:amio/pagehelper/loginregis/login_page.dart';
import 'package:amio/utils/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletons/skeletons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../pagehelper/splashscreen.dart';
import '../pageTablet/home/dashboard.dart';
import '../pageTablet/home/sidebar/bantuan.dart';
import '../pageTablet/tokopage/dashboardtoko.dart';
import '../services/apimethod.dart';

String linkCSwa =
    'https://api.whatsapp.com/send?phone=6285947737725&text=Hallo%20saya%20ingin%20menanyakan%20tentang%20UniPOS';

//? sp to double px
double sp32 = 22;
double sp24 = 17.4;
double sp20 = 14.4;
double sp18 = 13.4;
double sp16 = 12;
double sp14 = 11;
double sp12 = 9;
double sp10 = 8;

//? sizedbox size
double size120 = 84;
double size64 = 44;
double size56 = 40;
double size48 = 36;
double size44 = 35;
double size40 = 32;
double size32 = 24;
double size24 = 18;
double size20 = 16;
double size16 = 11;
double size12 = 8;
double size8 = 6;
double size4 = 3;

double width1 = 1;
double width2 = 2;
double width4 = 3;

//? --- Color --- ?//
const int _bluePrimaryValue = 0xFF2E61D7;
const MaterialColor blueku = MaterialColor(
  _bluePrimaryValue,
  <int, Color>{
    50: Color(0xFFE3F2FD),
    100: Color(0xFFD8E2F8),
    200: Color(0xFFAEC2EF),
    300: Color(0xFF83A1E7),
    400: Color(0xFF5881DF),
    500: Color(_bluePrimaryValue),
    600: Color(0xFF1E88E5),
    700: Color(0xFF1976D2),
    800: Color(0xFF1565C0),
    900: Color(0xFF0D47A1),
  },
);

Color primary100 = const Color(0xFFD8E2F8);
Color primary200 = const Color(0xFFAEC2EF);
Color primary300 = const Color(0xFF83A1E7);
Color primary400 = const Color(0xFF5881DF);
Color primary500 = const Color(0xFF2E61D7);
Color primary600 = const Color(0xFF224CB0);
Color primary700 = const Color(0xFF193A85);
Color primary800 = const Color(0xFF11275A);
Color primary900 = const Color(0xFF09152F);

Color orange100 = const Color(0xFFFFE5CC);
Color orange200 = const Color(0xFFFFCC99);
Color orange300 = const Color(0xFFFFB266);
Color orange400 = const Color(0xFFFF9832);
Color orange500 = const Color(0xFFFF8000);
Color orange600 = const Color(0xFFCC6600);
Color orange700 = const Color(0xFF994D00);
Color orange800 = const Color(0xFF663300);
Color orange900 = const Color(0xFF331A00);

Color red100 = const Color(0xFFFDBFCF);
Color red200 = const Color(0xFFFB8EA9);
Color red300 = const Color(0xFFF95D84);
Color red400 = const Color(0xFFF72C5F);
Color red500 = const Color(0xFFE60940);
Color red600 = const Color(0xFFB60733);
Color red700 = const Color(0xFF850525);
Color red800 = const Color(0xFF530317);
Color red900 = const Color(0xFF22010A);

Color green100 = const Color(0xFFA3FFE9);
Color green200 = const Color(0xFF70FFDC);
Color green300 = const Color(0xFF3DFFD0);
Color green400 = const Color(0xFF0AFFC3);
Color green500 = const Color(0xFF00D6A2);
Color green600 = const Color(0xFF00A37B);
Color green700 = const Color(0xFF007055);
Color green800 = const Color(0xFF003D2E);
Color green900 = const Color(0xFF000A08);

Color bnw100 = const Color(0xFFFFFFFF);
Color bnw200 = const Color(0xFFF5F5F5);
Color bnw300 = const Color(0xFFCCCCCC);
Color bnw400 = const Color(0xFF999999);
Color bnw500 = const Color(0xFF808080);
Color bnw600 = const Color(0xFF666666);
Color bnw700 = const Color(0xFF4D4D4D);
Color bnw800 = const Color(0xFF333333);
Color bnw900 = const Color(0xFF1A1A1A);

//? Color Status
Color waring100 = const Color(0xFFFFF0E0);
Color waring200 = const Color(0xFFFFCC99);
Color waring300 = const Color(0xFFFFB266);
Color waring400 = const Color(0xFFFF9832);
Color waring500 = const Color(0xFFFF8000);
Color waring600 = const Color(0xFFCC6600);
Color waring700 = const Color(0xFF994D00);
Color waring800 = const Color(0xFF663300);
Color waring900 = const Color(0xFF331A00);

Color danger100 = const Color(0xFFFDBFCF);
Color danger200 = const Color(0xFFFB8EA9);
Color danger300 = const Color(0xFFF95D84);
Color danger400 = const Color(0xFFF72C5F);
Color danger500 = const Color(0xFFE60940);
Color danger600 = const Color(0xFFB60733);
Color danger700 = const Color(0xFF850525);
Color danger800 = const Color(0xFF530317);
Color danger900 = const Color(0xFF22010A);

Color succes100 = const Color(0xFFD6FFF5);
Color succes200 = const Color(0xFF70FFDC);
Color succes300 = const Color(0xFF3DFFD0);
Color succes400 = const Color(0xFF0AFFC3);
Color succes500 = const Color(0xFF00D6A2);
Color succes600 = const Color(0xFF00A37B);
Color succes700 = const Color(0xFF007055);
Color succes800 = const Color(0xFF003D2E);
Color succes900 = const Color(0xFF000A08);

Color shadowCard = const Color(0x3D000000);

String errorText = '';

String textOrderBy = 'Nama Toko A ke Z ';
String textvalueOrderBy = 'upDownNama';

List alasanTagihanText = [
  "Salah Input Produk",
  "Produk Tidak Tersedia",
  "Transaksi Lama",
  "Kurang Catatan",
  "Tidak Sesuai Pesanan",
  "Kesalahan Pembeli",
];

List orderByProductText = [
  "Nama Produk A ke Z",
  "Nama Produk Z ke A",
  "Produk Terbaru",
  "Produk Terlama",
  "Harga Tertinggi",
  "Harga Terendah",
];

List orderByRiwayatText = [
  "Riwayat Terbaru",
  "Riwayat Terlama",
  "Nama Pembeli A ke Z",
  "Nama Pembeli Z ke A",
  "Total Tertinggi",
  "Total Terendah",
];

List orderByTagihanText = [
  "Tagihan Terbaru",
  "Tagihan Terlama",
  "Nama Pembeli A ke Z",
  "Nama Pembeli Z ke A",
  "Total Tertinggi",
  "Total Terendah",
];

List orderByVoucherText = [
  "Nama Voucher A ke Z",
  "Nama Voucher Z ke A",
  "Voucher Terbaru",
  "Voucher Terlama",
  "Harga Tertinggi",
  "Harga Terendah",
];

List orderByPelangganText = [
  "Nama Pelanggan A ke Z",
  "Nama Pelanggan Z ke A",
  "Pelanggan Terbaru",
  "Pelanggan Terlama",
];

List orderByTokoText = [
  "Nama Toko A ke Z",
  "Nama Toko Z ke A",
  "Toko Terbaru",
  "Toko Terlama",
];

List orderByAkunText = [
  "Nama Akun A ke Z",
  "Nama Akun Z ke A",
  "Akun Terbaru",
  "Akun Terlama",
];

//! orderby
List orderByProduct = [
  "upDownNama",
  "downUpNama",
  "upDownCreate",
  "downUpCreate",
  "downUpHarga",
  "upDownHarga",
];
List orderByPelanggan = [
  "upDownNama",
  "downUpNama",
  "upDownPelanggan",
  "downUpPelanggan",
];
List orderByToko = [
  "upDownNama",
  "downUpNama",
  "upDownCreate",
  "downUpCreate",
];
List orderByAkun = [
  "upDownNama",
  "downUpNama",
  "upDownAccount",
  "downUpAccount",
];
List orderByRiwayatTagihan = [
  "upDownCreate",
  "downUpCreate",
  "upDownNama",
  "downUpNama",
  "downUpAmount",
  "upDownAmount",
];

int valueOrderByProduct = 0;

class FormatCurrency {
  static String convertToIdr(dynamic number) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(number);
  }
}

String formatCurrency(int amount) {
  final formatter = NumberFormat('#,###', 'id_ID');

  return formatter.format(amount);
}

Completer<void> loadingCompleter = Completer<void>();

void whenLoading(context) {
  showDialog(
    barrierDismissible: false,
    useRootNavigator: true,
    context: context,
    builder: (context) => Builder(
      builder: (BuildContext context) {
        loadingCompleter = Completer<void>();
        return const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(),
          ),
        );
      },
    ),
  );
}

Future<void> closeLoading(context) async {
  if (!loadingCompleter.isCompleted) {
    Navigator.of(context, rootNavigator: true).pop();
    loadingCompleter.complete();
  }
}

dividerShowdialog() {
  return Container(
    width: 120,
    height: 4,
    decoration: ShapeDecoration(
      color: bnw300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(size8)),
    ),
  );
}

loading() {
  return SizedBox(
    height: 40,
    width: 40,
    child: Image.asset('assets/loading.gif'),
  );
}

skeletonNonExpanded() {
  return SizedBox(
    // height: MediaQuery.of(context).size.height,
    // width: MediaQuery.of(context).size.width,
    child: SkeletonListView(
      scrollable: true,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLine(style: SkeletonLineStyle(height: 60)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      itemCount: 10,
    ),
  );
}

//* Button *//

//! XXL Button

buttonXXL(Widget mywidget, double width) {
  return IntrinsicHeight(
    child: Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: size24, vertical: size16),
      decoration: BoxDecoration(
        color: primary500,
        borderRadius: BorderRadius.circular(size8),
      ),
      child: mywidget,
    ),
  );
}

buttonXXLoutline(Widget mywidget, double width, Color colorBorder) {
  return IntrinsicWidth(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: size24, vertical: size16),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: width1,
            color: colorBorder,
          ),
          borderRadius: BorderRadius.circular(size8),
        ),
      ),
      child: mywidget,
    ),
  );
}

buttonXXLonOff(Widget mywidget, double width, Color color) {
  return IntrinsicWidth(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: size24, vertical: size16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size8),
      ),
      child: mywidget,
    ),
  );
}

buttonXXLExpanded(Widget mywidget, Color color) {
  return Expanded(
    child: IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size24, vertical: size16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size8),
        ),
        child: mywidget,
      ),
    ),
  );
}

//! XL Button
buttonXL(Widget mywidget, double width) {
  return IntrinsicWidth(
    child: IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size20, vertical: size16),
        decoration: BoxDecoration(
          color: primary500,
          borderRadius: BorderRadius.circular(size8),
        ),
        child: mywidget,
      ),
    ),
  );
}

buttonXLExpanded(Widget mywidget, Color colorBorder) {
  return Expanded(
    child: IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size20, vertical: size16),
        decoration: BoxDecoration(
          color: primary500,
          borderRadius: BorderRadius.circular(size8),
        ),
        child: mywidget,
      ),
    ),
  );
}

buttonXLonOff(Widget mywidget, double width, Color color) {
  return Container(
    width: width,
    padding: EdgeInsets.symmetric(horizontal: size20, vertical: size16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

buttonXLpress(Widget mywidget, double width) {
  return Container(
    width: width,
    padding: EdgeInsets.symmetric(horizontal: size20, vertical: size16),
    decoration: BoxDecoration(
      color: primary600,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

buttonXLoutline(Widget mywidget, double width, Color colorBorder) {
  return IntrinsicWidth(
    child: Container(
      height: size56,
      padding: EdgeInsets.symmetric(horizontal: size20),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: width1,
            color: colorBorder,
          ),
          borderRadius: BorderRadius.circular(size8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          mywidget,
        ],
      ),
    ),
  );
}

buttonXLoutlineExpanded(Widget mywidget, Color colorBorder) {
  return Expanded(
    child: Container(
      height: size56,
      padding: EdgeInsets.symmetric(horizontal: size20),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: width1,
            color: colorBorder,
          ),
          borderRadius: BorderRadius.circular(size8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          mywidget,
        ],
      ),
    ),
  );
}

//! L Button
buttonL(Widget mywidget, Color color, borderColor) {
  return IntrinsicWidth(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: size12, vertical: size8),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: width1),
        borderRadius: BorderRadius.circular(size8),
      ),
      child: mywidget,
    ),
  );
}

buttonLpress(Widget mywidget) {
  return Container(
    width: 191,
    height: 48,
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
    decoration: BoxDecoration(
      color: primary600,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

buttonLoutline(Widget mywidget, Color colorBorder) {
  return IntrinsicHeight(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: size16, vertical: size12),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: width1,
            color: colorBorder,
          ),
          borderRadius: BorderRadius.circular(size8),
        ),
      ),
      child: mywidget,
    ),
  );
}

buttonLoutlineExpanded(Widget mywidget, Color colorBorder) {
  return Expanded(
    child: IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size16, vertical: size12),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: width1,
              color: colorBorder,
            ),
            borderRadius: BorderRadius.circular(size8),
          ),
        ),
        child: mywidget,
      ),
    ),
  );
}

buttonLoutlineColor(Widget mywidget, Color color, colorBorder) {
  return IntrinsicWidth(
    child: IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size16, vertical: size12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: colorBorder),
          borderRadius: BorderRadius.circular(size8),
        ),
        child: mywidget,
      ),
    ),
  );
}

//! M Button
buttonM(Widget mywidget, Color color) {
  return IntrinsicWidth(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: size12, vertical: size16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size8),
      ),
      child: mywidget,
    ),
  );
}

buttonMoutlineColor(Widget mywidget, colorBorder) {
  return Container(
    height: size44,
    padding: EdgeInsets.symmetric(horizontal: size12),
    // padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
    decoration: BoxDecoration(
      border: Border.all(color: colorBorder),
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

//! S Button
buttonS(Widget mywidget, color) {
  return Container(
    width: 32,
    height: 32,
    // padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

buttonSpress(Widget mywidget, width) {
  return Container(
    width: width,
    height: 36,
    padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
    decoration: BoxDecoration(
      color: primary600,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

//! XS Button
buttonXS(Widget mywidget) {
  return Container(
    width: 141,
    height: 32,
    padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
    decoration: BoxDecoration(
      color: primary500,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

buttonXSpress(Widget mywidget) {
  return Container(
    width: 141,
    height: 32,
    padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
    decoration: BoxDecoration(
      color: primary600,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

//* Text Heading Label *//

heading1(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp32,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

heading2(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp24,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

heading3(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp20,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

heading4(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp18,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

body1(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp16,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

body2(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp14,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

body3(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp12,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

body4(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp10,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

//* Textfield

textfieldXL(
  title,
  hintText,
  textError,
  TextEditingController controller,
  bool validate,
) {
  return StatefulBuilder(
    builder: (context, setState) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: heading4(FontWeight.w500, bnw900, 'Outfit'),
            ),
            Text(
              '*',
              style: heading4(FontWeight.w700, red500, 'Outfit'),
            ),
          ],
        ),
        IntrinsicHeight(
          child: Container(
            child: TextFormField(
              style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              onChanged: (value) {
                setState(() {});
              },
              cursorColor: primary500,
              controller: controller,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: size12),
                hintText: hintText,
                hintStyle: heading2(FontWeight.w600, bnw400, 'Outfit'),
                errorText: validate ? textError : null,
                errorStyle: body1(FontWeight.w500, red500, 'Outfit'),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: primary500,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: bnw400,
                  ),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: red500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

//* Dropdownfield

dropdownfieldXL(
  title,
  textContent,
  hintText,
) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: bnw100,
      border: Border(
        bottom: BorderSide(
          width: 1,
          color: bnw400,
        ),
      ),
    ),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //!depan
          Row(
            children: [
              Text(
                title,
                style: heading4(FontWeight.w400, bnw900, 'Outfit'),
              ),
              Text(
                ' *',
                style: heading4(FontWeight.w400, red500, 'Outfit'),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: size12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  textContent == null ? hintText : textContent.toString(),
                  style: heading2(FontWeight.w600,
                      textContent == null ? bnw400 : bnw900, 'Outfit'),
                ),
                Icon(
                  PhosphorIcons.caret_down,
                  color: bnw900,
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

//* Imagefiled

imagefieldXL(
  myImage,
  VoidCallback getImage,
  title,
  textDesc,
  textTambahUbah,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: heading4(FontWeight.w500, bnw900, 'Outfit'),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          GestureDetector(
              onTap: () => getImage(),
              child: Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  border: Border.all(color: bnw900),
                  borderRadius: BorderRadius.circular(size8),
                ),
                child: myImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(size8),
                        child: Image.file(myImage!, fit: BoxFit.fill),
                      )
                    : const Icon(PhosphorIcons.plus),
              )),
          const SizedBox(width: 10),
          Text(
            textDesc,
            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
          ),
        ],
      ),
      GestureDetector(
        onTap: () => getImage(),
        child: IntrinsicHeight(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: bnw100,
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: bnw400,
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: size12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      textTambahUbah,
                      style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                    Icon(
                      PhosphorIcons.plus,
                      color: bnw900,
                    )
                  ],
                ),
              ),
            ),
          ),

          // TextFormField(
          //   style: heading2(FontWeight.w600, bnw900, 'Outfit'),
          //   decoration: InputDecoration(
          //     enabled: false,
          //     hintText: textTambahUbah,
          //     suffixIcon: const Icon(PhosphorIcons.plus),
          //     hintStyle: heading2(FontWeight.w600, bnw900, 'Outfit'),
          //   ),
          // ),
        ),
      ),
    ],
  );
}

//* L Notification

notifLpembayaran(
  String title,
  subTitle,
  double width,
  Color color,
  colorBorder,
  colorIcon,
) {
  return Container(
    padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size8),
      color: color,
      border: Border.all(color: colorBorder),
    ),
    height: 66,
    width: width,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                PhosphorIcons.warning_fill,
                color: colorIcon,
                size: 26,
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: body1(FontWeight.w400, bnw900, 'Outfit')),
                Text(subTitle,
                    style: heading4(FontWeight.w600, bnw900, 'Outfit')),
              ],
            )
          ],
        ),
        const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(),
        ),
      ],
    ),
  );
}

showHelpSheet(BuildContext context, Widget widget) {
  return showDialog(
    // barrierDismissible: false,
    // useRootNavigator: false,
    context: context,
    builder: (context) => Center(
      child: Container(
        height: MediaQuery.of(context).size.height / 1.4,
        width: MediaQuery.of(context).size.width / 1.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: bnw100,
        ),
        child: widget,
      ),
    ),
  );
}

Future<dynamic> showBottomPilihan(BuildContext context, Widget child) {
  return showModalBottomSheet(
    useRootNavigator: false,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(size16),
    ),
    context: context,
    builder: (context) {
      return Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: ShapeDecoration(
          color: bnw100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size16),
              topRight: Radius.circular(size16),
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
          child: IntrinsicHeight(
              child: Column(
            children: [
              dividerShowdialog(),
              SizedBox(height: size16),
              child,
            ],
          )),
        ),
      );
    },
  );
}

showModalBottom(BuildContext context, height, child) {
  showModalBottomSheet(
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    context: context,
    builder: (context) {
      return StatefulBuilder(
        // dipakein IntrinsicHeight dan height dihapus
        builder: (context, setState) => IntrinsicHeight(
          child: Container(
            // height: height,
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: child,
          ),
        ),
      );
    },
  );
}

showModalBottomDropdownAtur(BuildContext context, height, child) {
  showModalBottomSheet(
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    context: context,
    builder: (context) {
      return StatefulBuilder(
        // dipakein IntrinsicHeight dan height dihapus
        builder: (context, setState) => IntrinsicHeight(
          child: Container(
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: child,
          ),
        ),
      );
    },
  );
}

showModalBottomProfile(BuildContext context, height, child) {
  showModalBottomSheet(
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    context: context,
    builder: (context) {
      return StatefulBuilder(
        // dipakein IntrinsicHeight dan height dihapus
        builder: (context, setState) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: child,
          ),
        ),
      );
    },
  );
}

sessionPage(BuildContext context, String token) {
  return Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => statusProfile == 'Group_Merchant'
          ? SidebarXExampleApp(
              id: identifier.toString(),
              // token: jsonResponse['token'],
              token: token,
            )
          : SidebarXExampleAppToko(
              token: token,
              id: identifier.toString(),
            ),
    ),
  );
}

sessionPageMobile(BuildContext context, String token) {
  return Navigator.pushReplacement(
    context,
    MaterialPageRoute(
        builder: (context) => statusProfile == 'Group_Merchant'
            ? TahapPengembanganPage()
            : TahapPengembanganPage()),
  );
}

searchField(double width, Widget mywidget) {
  return Container();
}
// searchField(double width, Widget mywidget) {
//   return Container(
//     height: 50,
//     width: width,
//     padding: const EdgeInsets.only(left: 12, right: 12),
//     decoration: BoxDecoration(
//       color: bnw200,
//       borderRadius: BorderRadius.circular(size8),
//       border: Border.all(color: bnw300),
//     ),
//     child: mywidget,
//   );
// }

//* Appbar
appbar(BuildContext context, bool login) {
  return SafeArea(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: size12),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => login
                  ? Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ))
                  : Navigator.of(context).pop(),
              child: Icon(
                PhosphorIcons.arrow_left,
                size: size40,
                color: bnw900,
              ),
            ),
            GestureDetector(
              onTap: () {
                helpQuestionShow(context);
              },
              child: Icon(
                PhosphorIcons.question,
                size: size40,
                color: bnw900,
              ),
            ),
          ]),
    ),
  );
}

appbarMobile(BuildContext context, bool login) {
  return SafeArea(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: size12),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => login
                  ? Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPageMobile(),
                      ))
                  : Navigator.of(context).pop(),
              child: Icon(
                PhosphorIcons.arrow_left,
                size: 32,
                color: bnw900,
              ),
            ),
            GestureDetector(
              onTap: () {
                helpQuestionShow(context);
              },
              child: Icon(
                PhosphorIcons.question,
                size: 32,
                color: bnw900,
              ),
            ),
          ]),
    ),
  );
}

helpQuestionShow(BuildContext context) {
  return showModalBottomSheet(
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    context: context,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size8),
                topRight: Radius.circular(size8))),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(size32, size12, size32, size32),
              child: Column(
                children: [
                  dividerShowdialog(),
                  SizedBox(height: size16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2.2,
                    child: SvgPicture.asset(
                      'assets/newIllustration/Help.svg',
                    ),
                  ),
                  SizedBox(height: size16),
                  Text(
                    "Butuh Bantuan?",
                    style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  Text(
                    "Silahkan untuk menghubungi customer service untuk menanyakan permasalahan.",
                    style: heading2(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: size32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: buttonXLoutline(
                            Center(
                              child: Text(
                                'Gak jadi',
                                style: heading3(
                                    FontWeight.w600, primary500, 'Outfit'),
                              ),
                            ),
                            100,
                            primary500,
                          ),
                        ),
                      ),
                      SizedBox(width: size16),
                      Expanded(
                        child: SizedBox(
                          height: size56,
                          child: GestureDetector(
                              onTap: () {
                                try {
                                  launch(linkCSwa);
                                } catch (e) {}
                              },
                              child: buttonXL(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIcons.whatsapp_logo_fill,
                                      color: bnw100,
                                    ),
                                    SizedBox(width: size12),
                                    Text(
                                      'Hubungkan ke Customer Service',
                                      style: heading3(
                                          FontWeight.w600, bnw100, 'Outfit'),
                                    )
                                  ],
                                ),
                                double.infinity,
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showSnackBarComponent(BuildContext context, String text, String rc) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: FutureBuilder(
          future: Future.delayed(Duration(seconds: 2)),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Navigator.pop(context);
            }
            return Container(
              margin: const EdgeInsets.all(20),
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size8),
                color: rc == '00' ? succes600 : red500,
              ),
              child: Center(
                child: Text(
                  text,
                  style: heading2(FontWeight.w700, bnw100, 'Outfit'),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

dash() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      300 ~/ 4,
      (index) => Expanded(
        child: Container(
          color: index % 2 == 0 ? bnw900 : Colors.transparent,
          height: 1,
        ),
      ),
    ),
  );
}

void showSnackbar(BuildContext context, jsonResponse) async {
  showSnackBarComponent(
    context,
    jsonResponse['message'] ?? jsonResponse['data'],
    jsonResponse['rc'],
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (jsonResponse['rc'] == '63' || jsonResponse['rc'] == '14') {
    prefs.remove('token');
    prefs.remove('deviceid');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}

String nameku = nameProfile;
String getInitials() {
  List<String> namekus = nameku.split(' ');
  String initials = '';
  int numWords = namekus.length > 1 ? 2 : 1;

  for (var i = 0; i < numWords; i++) {
    initials += '${namekus[i][0]}';
  }

  return initials;
}
