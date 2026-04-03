import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';

void formatInputPrice(TextEditingController textController) {
  String text = textController.text.replaceAll('.', '');
  if (text.isEmpty) return;

  int value = int.tryParse(text) ?? 0;
  if (value == 0) return;

  String formattedAmount = formatCurrency(value);

  textController.value = TextEditingValue(
    text: formattedAmount,
    selection: TextSelection.collapsed(offset: formattedAmount.length),
  );
}
