import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/unipos_size.dart';

class UniposTextField extends StatelessWidget {
  const UniposTextField({
    super.key,
    this.title = "Judul Field",
    this.showTitle = true,
    this.onChanged,
    this.controller,
    this.hintText = 'Cth : Transaksi salah karena ada kesalahan penginputan.',
    this.errorText = '',
    this.maxLines = null,
    this.keyboardType = TextInputType.multiline,
    this.inputFormatters = const [],
    this.required = false,
    this.focusNode,
    this.onFieldSubmitted,
    this.textInputAction,
    this.readOnly = false,
    this.onTapOutside,
  });

  final String title;
  final bool showTitle;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String hintText;
  final String errorText;
  final int? maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool required;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final TapRegionCallback? onTapOutside;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showTitle)
          Row(
            children: [
              Text(title, style: body1(FontWeight.w500, bnw900, 'Outfit')),
              if (required)
                Text(' *', style: body1(FontWeight.w700, red500, 'Outfit')),
            ],
          ),
        TextFormField(
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          readOnly: readOnly,
          onTapOutside: onTapOutside ?? (_) => FocusScope.of(context).unfocus(),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
          onChanged: onChanged,
          cursorColor: primary500,
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.only(
              top: uniposSize8,
              bottom: uniposSize12,
            ),
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
        ),
      ],
    );
  }
}
