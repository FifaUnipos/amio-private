import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/unipos_size.dart';

class UniposTextField extends StatelessWidget {
  const UniposTextField({
    super.key,
    this.onChanged,
    this.controller,
    this.hintText = 'Cth : Transaksi salah karena ada kesalahan penginputan.',
    this.errorText = '',
    this.maxLines = null,
    this.keyboardType = TextInputType.multiline,
  });

  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String hintText;
  final String errorText;
  final int? maxLines;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: heading2(FontWeight.w600, bnw900, 'Outfit'),
      onChanged: onChanged,
      cursorColor: primary500,
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: uniposSize16),
        hintText: hintText,
        hintStyle: heading2(FontWeight.w600, bnw400, 'Outfit'),
        errorText: errorText.isNotEmpty ? errorText : null,
        errorStyle: body1(FontWeight.w500, red500, 'Outfit'),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 2, color: primary500),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 1, color: bnw400),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 2, color: red500),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 1, color: red500),
        ),
      ),
    );
  }
}

