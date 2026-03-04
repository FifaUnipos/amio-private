//* Text Heading Label *//


import 'package:flutter/material.dart';

import 'component_size.dart';

TextStyle heading1(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp32,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

TextStyle heading2(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp24,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

TextStyle heading3(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp20,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

TextStyle heading4(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp18,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

TextStyle heading4lineThrough(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp18,
    fontWeight: fontWeight,
    height: 1.22,
    decoration: TextDecoration.lineThrough,
  );
}

TextStyle body3lineThrough(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp12,
    fontWeight: fontWeight,
    height: 1.22,
    decoration: TextDecoration.lineThrough,
  );
}

TextStyle body1(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp16,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

TextStyle body2(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp14,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

TextStyle body3(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp12,
    fontWeight: fontWeight,
    height: 1.22,
  );
}

TextStyle body4(FontWeight fontWeight, Color color, String family) {
  return TextStyle(
    fontFamily: family,
    color: color,
    fontSize: sp10,
    fontWeight: fontWeight,
    height: 1.22,
  );
}
