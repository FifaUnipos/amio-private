import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'component_size.dart';

import 'package:flutter/services.dart';
import '../component/component_color.dart';
import 'component_button.dart';

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
    constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
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
    constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
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
            // width: double.infinity,
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
    constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
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
            // width: MediaQuery.of(context).size.width,
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
    constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
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

showModalBottomExit(context) {
  showModalBottomProfile(
    context,
    MediaQuery.of(context).size.height / 2.8,
    Column(
      children: [
        dividerShowdialog(),
        SizedBox(height: size16),
        Text(
          'Kamu yakin ingin keluar aplikasi?',
          style: heading1(FontWeight.w600, bnw900, 'Outfit'),
        ),
        SizedBox(height: size8),
        Text(
          'Jika kamu keluar, semua data kamu akan tetap tersimpan.',
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
                      'Gak Jadi',
                      style: heading3(FontWeight.w600, primary500, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width,
                  primary500,
                ),
              ),
            ),
            SizedBox(width: size16),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  SystemNavigator.pop();
                },
                child: buttonXL(
                  Center(
                    child: Text(
                      'Iya, Keluar',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width,
                  // primary500,
                  // primary500,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
