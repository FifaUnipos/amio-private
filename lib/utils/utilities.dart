import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/pageMobile/dashboardMobile.dart';
import 'package:unipos_app_335/pageMobile/pageHelperMobile/loginRegisMobile/loginPageMobile.dart';
import 'package:unipos_app_335/pageMobile/pageTokoMobile/pengembanganPage.dart';
import 'package:unipos_app_335/pageTablet/home/dashboard.dart';
import 'package:unipos_app_335/pageTablet/tokopage/dashboardtoko.dart';
import 'package:unipos_app_335/pagehelper/loginregis/login_page.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pageTablet/kasirPage/dashboardKasir.dart';

String linkCSwa =
    'https://api.whatsapp.com/send?phone=6289613806717&text=Hallo%20saya%20ingin%20menanyakan%20tentang%20UniPOS';

String errorText = '';

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

int parseFlexibleNumber(dynamic value) {
  if (value == null) return 0;

  // Ubah ke string dulu, lalu bersihkan
  String cleaned = value.toString().replaceAll(RegExp(r'[^0-9.,]'), '');

  // Ganti koma jadi titik, untuk jaga-jaga input lokal (misal "10,5")
  cleaned = cleaned.replaceAll(',', '.');

  double? result = double.tryParse(cleaned);
  return result?.round() ?? 0; // Bulatkan ke int
}

String formatCurrency(int amount) {
  final formatter = NumberFormat('#,###', 'id_ID');

  return formatter.format(amount);
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

searchField(double width, Widget mywidget) {
  return Container();
}

dropdownfieldXL(title, textContent, hintText) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: bnw100,
      border: Border(bottom: BorderSide(width: 1, color: bnw400)),
    ),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: heading4(FontWeight.w400, bnw900, 'Outfit')),
              Text(' *', style: heading4(FontWeight.w400, red500, 'Outfit')),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: size12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  textContent == null ? hintText : textContent.toString(),
                  style: heading2(
                    FontWeight.w600,
                    textContent == null ? bnw400 : bnw900,
                    'Outfit',
                  ),
                ),
                Icon(PhosphorIcons.caret_down, color: bnw900),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

imagefieldXL(myImage, VoidCallback getImage, title, textDesc, textTambahUbah) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: heading4(FontWeight.w500, bnw900, 'Outfit')),
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
            ),
          ),
          const SizedBox(width: 10),
          Text(textDesc, style: heading4(FontWeight.w400, bnw900, 'Outfit')),
        ],
      ),
      GestureDetector(
        onTap: () => getImage(),
        child: IntrinsicHeight(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: bnw100,
              border: Border(bottom: BorderSide(width: 1, color: bnw400)),
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
                    Icon(PhosphorIcons.plus, color: bnw900),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

sessionPage(BuildContext context, String token, typeAccount, roleAccount) {
  return Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) {
        if (typeAccount == 'Group_Merchant') {
          return SidebarXExampleApp(id: identifier.toString(), token: token);
        } else if (typeAccount == 'Merchant_Only') {
          return SidebarXExampleAppToko(
            token: token,
            id: identifier.toString(),
          );
        } else if (typeAccount == 'Merchant' && roleAccount == 'cashier') {
          return SidebarXKasirPage(token: token, id: identifier.toString());
        } else if (typeAccount == 'Merchant') {
          return SidebarXExampleAppToko(
            token: token,
            id: identifier.toString(),
          );
          // return Container(child: Text('HEllo cashier'));
        }
        return LoginPage();
      },

      // =>
      // statusProfile == 'Group_Merchant'
      //     ? SidebarXExampleApp(
      //         id: identifier.toString(),
      //         token: token,
      //       )
      //     : SidebarXExampleAppToko(
      //         token: token,
      //         id: identifier.toString(),
      //       ),
    ),
    (Route<dynamic> route) => false,
  );
}

sessionPageMobile(
  BuildContext context,
  String token,
  String typeAccount,
  String roleAccount,
) {
  return Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) {
        // 🔹 Sama seperti versi tablet
        // if (typeAccount == 'Group_Merchant') {
        //   // Halaman utama untuk Group Merchant
        //   return DashboardPageMobile(token: token);
        // }
        // //  else if (typeAccount == 'Merchant_Only') {
        // //   // Halaman merchant tunggal
        // //   return DashboardPageMobile(token: token);
        // // } else if (typeAccount == 'Merchant' && roleAccount == 'cashier') {
        // //   // Halaman kasir (bisa nanti diganti ke KasirPageMobile)
        // //   return KasirPageMobile(token: token);
        // // }
        // else if (typeAccount == 'Merchant') {
        //   // Halaman merchant biasa
        //   return DashboardPageMobile(token: token);
        // }

        // Default: jika gagal dikenali
        return DashboardPageMobile(token: checkToken,);
      },
    ),
    (Route<dynamic> route) => false,
  );
}

helpQuestionShow(BuildContext context) {
  return showModalBottomSheet(
    constraints: const BoxConstraints(maxWidth: double.infinity),
    isScrollControlled: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    context: context,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: bnw100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size8),
            topRight: Radius.circular(size8),
          ),
        ),
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
                    child: SvgPicture.asset('assets/newIllustration/Help.svg'),
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
                                  FontWeight.w600,
                                  primary500,
                                  'Outfit',
                                ),
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
                                      FontWeight.w600,
                                      bnw100,
                                      'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                              double.infinity,
                            ),
                          ),
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
