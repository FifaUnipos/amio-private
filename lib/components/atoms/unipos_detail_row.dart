import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

class UniposDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final FontWeight labelWeight;
  final FontWeight valueWeight;
  final Color? labelColor;
  final Color? valueColor;

  const UniposDetailRow({
    Key? key,
    required this.label,
    required this.value,
    this.labelWeight = FontWeight.normal,
    this.valueWeight = FontWeight.normal,
    this.labelColor,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: heading3(
            labelWeight,
            labelColor ?? bnw900,
            'Outfit',
          ),
        ),
        Text(
          value,
          style: heading3(
            valueWeight,
            valueColor ?? bnw900,
            'Outfit',
          ),
        ),
      ],
    );
  }
}
