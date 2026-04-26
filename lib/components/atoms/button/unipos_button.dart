import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/unipos_size.dart';

enum UniposButtonVariant {
  primary,
  secondary,
  tertiary;

  Color get colorLoading {
    switch (this) {
      case UniposButtonVariant.primary:
        return bnw100;
      case UniposButtonVariant.secondary:
      case UniposButtonVariant.tertiary:
        return primary500;
    }
  }

  Color getBgColor(bool isDisabled) {
    if (isDisabled) return bnw300;
    return this == UniposButtonVariant.primary ? primary500 : Colors.transparent;
  }

  Color getFgColor(bool isDisabled) {
    if (isDisabled) return bnw500;
    return this == UniposButtonVariant.primary ? bnw100 : primary500;
  }
}

enum UniposButtonSize {
  small,
  medium,
  large;

  BorderRadius get btnRadius {
    switch (this) {
      case UniposButtonSize.small:
        return BorderRadius.circular(uniposSize8);
      case UniposButtonSize.medium:
        return BorderRadius.circular(uniposSize8);
      case UniposButtonSize.large:
        return BorderRadius.circular(uniposSize8);
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case UniposButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: uniposSize12,
          vertical: uniposSize8,
        );
      case UniposButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: uniposSize16,
          vertical: uniposSize12,
        );
      case UniposButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: uniposSize16,
          vertical: uniposSize12,
        );
    }
  }

  double get iconSizeValue {
    switch (this) {
      case UniposButtonSize.small:
        return 12.0;
      case UniposButtonSize.medium:
        return 16.0;
      case UniposButtonSize.large:
        return 20.0;
    }
  }

  TextStyle getTextStyle(Color fgColor) {
    switch (this) {
      case UniposButtonSize.small:
        return body1(FontWeight.w600, fgColor, 'Outfit');
      case UniposButtonSize.medium:
        return heading3(FontWeight.w600, fgColor, 'Outfit');
      case UniposButtonSize.large:
        return heading3(FontWeight.w600, fgColor, 'Outfit');
    }
  }
}

class UniposButton extends StatelessWidget {
  const UniposButton({
    super.key,
    this.textShow = true,
    this.text = "Button",
    this.onTap,
    this.variant = UniposButtonVariant.primary,
    this.icon,
    this.size = UniposButtonSize.large,
    this.loading = false,
  });

  final String text;
  final bool textShow;
  final VoidCallback? onTap;
  final UniposButtonVariant variant;
  final IconData? icon;
  final UniposButtonSize size;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    UniposButtonSize effectiveSize = size;
    if (isMobile) {
      if (size == UniposButtonSize.large) {
        effectiveSize = UniposButtonSize.large;
      } else if (size == UniposButtonSize.medium) {
        effectiveSize = UniposButtonSize.medium;
      }
    }

    final isDisabled = onTap == null && !loading;
    final bgColor = variant.getBgColor(isDisabled);
    final fgColor = variant.getFgColor(isDisabled);

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Stack(
        children: [
          Container(
            padding: effectiveSize.padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: effectiveSize.btnRadius,
            ),
            child: Row(
              mainAxisSize: variant == UniposButtonVariant.tertiary
                  ? MainAxisSize.min
                  : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  SizedBox(
                    width: effectiveSize.iconSizeValue,
                    height: effectiveSize.iconSizeValue,
                    child: CircularProgressIndicator(
                      color: variant.colorLoading,
                      strokeWidth: 2,
                    ),
                  ),
                if (icon != null && !loading) ...[
                  Icon(icon, color: fgColor, size: effectiveSize.iconSizeValue),
                  if (textShow)
                    SizedBox(width: uniposSize16), // space antar icon & text
                ],
                if (textShow && !loading)
                  Text(text, style: effectiveSize.getTextStyle(fgColor)),
              ],
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: effectiveSize.btnRadius,
                  border: Border.all(
                    width: 1,
                    color: variant == UniposButtonVariant.secondary
                        ? primary500
                        : Colors.transparent,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Center(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
