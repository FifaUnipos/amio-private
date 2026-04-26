import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'component_size.dart';

import '../component/component_color.dart';

// ignore: must_be_immutable
class TextfieldAtom extends StatelessWidget {
  final String hintText;
  final TextInputType keyboardType;
  final bool isPassword;
  final dynamic mycontroller;
  final bool _isRounded;

  const TextfieldAtom.rounded({
    super.key,
    required this.hintText,
    required this.keyboardType,
    this.isPassword = false,
  })  : mycontroller = null,
        _isRounded = true;

  const TextfieldAtom.notRounder({
    super.key,
    required this.hintText,
    required this.mycontroller,
    required this.keyboardType,
    this.isPassword = false,
  }) : _isRounded = false;

  @override
  Widget build(BuildContext context) {
    if (_isRounded) {
      return TextFormField(
        keyboardType: keyboardType,
        textAlign: TextAlign.start,
        obscureText: isPassword,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size8),
            borderSide: BorderSide(
              width: size12,
              style: BorderStyle.solid,
            ),
          ),
          contentPadding: EdgeInsets.all(size8),
        ),
      );
    } else {
      return TextFormField(
        cursorColor: primary500,
        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
        controller: mycontroller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
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
              width: width1,
              color: bnw500,
            ),
          ),
          hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
        ),
      );
    }
  }
}
