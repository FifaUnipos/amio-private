import 'package:dio/dio.dart';
import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/utilities.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../utils/component/component_size.dart';
import 'package:flutter_svg/svg.dart';


import '../utils/component/component_button.dart';
import '../utils/component/component_color.dart';
import '../utils/component/component_size.dart';

class ConnectionChecker {
  Future<bool> checkInternet() async {
    try {
      var response = await Dio().head(
        'https://api.prod.amio.my.id/api/test',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

Future<void> checkConnection(BuildContext context) async {
  final connectionStatus = await ConnectionChecker().checkInternet();

  if (!connectionStatus) {
    dialogNoConnection(context, () {
      checkConnection(context);
    });
  }
}

Future<dynamic> dialogNoConnection(context, VoidCallback retryCallback) {
  return showModalBottomSheet(
    constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    context: context,
    builder: (BuildContext context) {
      return IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(size12),
              topLeft: Radius.circular(size12),
            ),
          ),
          child: Column(
            children: [
              dividerShowdialog(),
              SizedBox(height: size16),
              SvgPicture.asset(
                'assets/illustration/errorKoneksi.svg',
                height: MediaQuery.of(context).size.height / 2.2,
              ),
              Text(
                'Maaf, koneksi internet kamu terputus.',
                style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              ),
              SizedBox(height: size8),
              Text(
                'Silahkan periksa kembali koneksi internet kamu!',
                style: heading2(FontWeight.w400, bnw900, 'Outfit'),
              ),
              SizedBox(height: size32),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await Future.delayed(Duration(seconds: 2));
                    retryCallback();
                  },
                  child: buttonXL(
                    Center(
                      child: Text(
                        'Oke',
                        style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                      ),
                    ),
                    double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<dynamic> dialogNoPrinter(context) {
  return showModalBottomSheet(
    constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    context: context,
    builder: (BuildContext context) {
      return IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(size12),
              topLeft: Radius.circular(size12),
            ),
          ),
          child: Column(
            children: [
              dividerShowdialog(),
              SizedBox(height: size16),
              SvgPicture.asset(
                'assets/newIllustration/ErrorPrinter.svg',
                height: MediaQuery.of(context).size.height / 2.2,
              ),
              Text(
                'Maaf, tidak ada koneksi Printer.',
                style: heading2(FontWeight.w600, bnw900, 'Outfit'),
              ),
              SizedBox(height: size8),
              Text(
                'Silahkan periksa kembali printer kamu!',
                style: heading2(FontWeight.w400, bnw900, 'Outfit'),
              ),
              SizedBox(height: size32),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: buttonXL(
                      Center(
                          child: Text(
                        'Oke',
                        style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                      )),
                      double.infinity),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
