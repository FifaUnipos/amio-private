//* Button *//

//! XXL Button

import 'package:flutter/material.dart';
import 'component_size.dart';
import '../component/component_color.dart';

buttonXXL(Widget mywidget, double width) {
  return IntrinsicHeight(
    child: Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: size24, vertical: size16),
      decoration: BoxDecoration(
        color: primary500,
        borderRadius: BorderRadius.circular(size8),
      ),
      child: mywidget,
    ),
  );
}

buttonXXLoutline(Widget mywidget, double width, Color colorBorder) {
  return IntrinsicWidth(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: size24, vertical: size16),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: width1, color: colorBorder),
          borderRadius: BorderRadius.circular(size8),
        ),
      ),
      child: mywidget,
    ),
  );
}

buttonXXLonOff(Widget mywidget, double width, Color color) {
  return IntrinsicHeight(
    child: Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: size24, vertical: size16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size8),
      ),
      child: mywidget,
    ),
  );
}

buttonXXLExpanded(Widget mywidget, Color color) {
  return Expanded(
    child: IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size24, vertical: size16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size8),
        ),
        child: mywidget,
      ),
    ),
  );
}

//! XL Button
buttonXL(Widget mywidget, double width) {
  return IntrinsicWidth(
    child: IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size20, vertical: size16),
        decoration: BoxDecoration(
          color: primary500,
          borderRadius: BorderRadius.circular(size8),
        ),
        child: mywidget,
      ),
    ),
  );
}

buttonXLExpanded(Widget mywidget, Color colorBorder) {
  return Expanded(
    child: IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size20, vertical: size16),
        decoration: BoxDecoration(
          color: primary500,
          borderRadius: BorderRadius.circular(size8),
        ),
        child: mywidget,
      ),
    ),
  );
}

buttonXLonOff(Widget mywidget, double width, Color color) {
  return Container(
    width: width,
    padding: EdgeInsets.symmetric(horizontal: size20, vertical: size16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

buttonXLactive(Widget mywidget, double width, Color colorBorder, Color color) {
  return IntrinsicWidth(
    child: Container(
      height: size56,
      padding: EdgeInsets.symmetric(horizontal: size20),
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: width1, color: colorBorder),
          borderRadius: BorderRadius.circular(size8),
        ),
      ),
      child: mywidget,
    ),
  );
}

buttonXLoutline(Widget mywidget, double width, Color colorBorder) {
  return IntrinsicWidth(
    child: Container(
      height: size56,
      padding: EdgeInsets.symmetric(horizontal: size20),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: width1, color: colorBorder),
          borderRadius: BorderRadius.circular(size8),
        ),
      ),
      child: mywidget,
    ),
  );
}

buttonXLoutlineExpanded(Widget mywidget, Color colorBorder) {
  return Expanded(
    child: Container(
      height: size56,
      padding: EdgeInsets.symmetric(horizontal: size20),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: width1, color: colorBorder),
          borderRadius: BorderRadius.circular(size8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [mywidget],
      ),
    ),
  );
}

//! L Button
buttonL(Widget mywidget, Color color, borderColor) {
  return IntrinsicWidth(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: size12, vertical: size8),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: width1),
        borderRadius: BorderRadius.circular(size8),
      ),
      child: mywidget,
    ),
  );
}

buttonLpress(Widget mywidget) {
  return Container(
    width: 191,
    height: 48,
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
    decoration: BoxDecoration(
      color: primary600,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

buttonLoutline(Widget mywidget, Color colorBorder) {
  return IntrinsicHeight(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: size16, vertical: size12),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: width1, color: colorBorder),
          borderRadius: BorderRadius.circular(size8),
        ),
      ),
      child: mywidget,
    ),
  );
}

buttonLoutlineExpanded(Widget mywidget, Color colorBorder) {
  return Expanded(
    child: IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size16, vertical: size12),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: width1, color: colorBorder),
            borderRadius: BorderRadius.circular(size8),
          ),
        ),
        child: mywidget,
      ),
    ),
  );
}

buttonLoutlineColor(Widget mywidget, Color color, colorBorder) {
  return IntrinsicWidth(
    child: IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size16, vertical: size12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: colorBorder),
          borderRadius: BorderRadius.circular(size8),
        ),
        child: mywidget,
      ),
    ),
  );
}

//! M Button
buttonM(Widget mywidget, Color color) {
  return IntrinsicWidth(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: size12, vertical: size16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size8),
      ),
      child: mywidget,
    ),
  );
}

buttonMoutlineColor(Widget mywidget, colorBorder) {
  return Container(
    height: size44,
    padding: EdgeInsets.symmetric(horizontal: size12),
    // padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
    decoration: BoxDecoration(
      border: Border.all(color: colorBorder),
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

//! S Button
buttonS(Widget mywidget, color) {
  return Container(
    width: 32,
    height: 32,
    // padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

buttonSpress(Widget mywidget, width) {
  return Container(
    width: width,
    height: 36,
    padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
    decoration: BoxDecoration(
      color: primary600,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

//! XS Button
buttonXS(Widget mywidget) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: size12, vertical: size8),
    decoration: BoxDecoration(
      color: primary500,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}

buttonXSpress(Widget mywidget) {
  return Container(
    width: 141,
    height: 32,
    padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
    decoration: BoxDecoration(
      color: primary600,
      borderRadius: BorderRadius.circular(size8),
    ),
    child: mywidget,
  );
}
