import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'component_size.dart';

import '../component/component_color.dart';

class TextfieldAtom extends TextFormField {
  TextfieldAtom.rounded({
    super.key,
    required String hintText,
    required super.keyboardType,
    bool isPassword = false,
  }) : super(
          textAlign: TextAlign.start,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size8),
                borderSide: BorderSide(
                  width: size12,
                  style: BorderStyle.solid,
                )),
            contentPadding: EdgeInsets.all(size8),
          ),
        );

  TextfieldAtom.notRounder(
      {super.key,
      required String hintText,
      required mycontroller,
      required super.keyboardType,
      bool isPassword = false})
      : super(
          cursorColor: primary500,
          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
          controller: mycontroller,
          // onChanged: (value) {
          // mycontroller.text = value;
          //   setState(() {});
          // },
          onSaved: (value) {
            // setState(() {
            //   mycontroller.text = value;
            // });
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
                width: width1,
                color: bnw500,
              ),
            ),
            hintStyle: heading2(FontWeight.w600, bnw500, 'Outfit'),
          ),
        );
}
