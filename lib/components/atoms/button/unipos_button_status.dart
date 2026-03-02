import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/unipos_size.dart';

enum UniposButtonStatusHierarchy { primary, secondary, tertiary }

enum UniposButtonStatusVariant {
  success,
  warning,
  danger;

  Color getBgColor(UniposButtonStatusHierarchy hierarchy) {
    if (hierarchy == UniposButtonStatusHierarchy.primary) {
      switch (this) {
        case UniposButtonStatusVariant.success:
          return succes500;
        case UniposButtonStatusVariant.warning:
          return waring500;
        case UniposButtonStatusVariant.danger:
          return danger500;
      }
    }
    return Colors.transparent;
  }

  Color getFgColor(UniposButtonStatusHierarchy hierarchy) {
    if (hierarchy == UniposButtonStatusHierarchy.primary) {
      return bnw100;
    }
    switch (this) {
      case UniposButtonStatusVariant.success:
        return succes500;
      case UniposButtonStatusVariant.warning:
        return waring500;
      case UniposButtonStatusVariant.danger:
        return danger500;
    }
  }

  Color getBorderColor(UniposButtonStatusHierarchy hierarchy) {
    if (hierarchy == UniposButtonStatusHierarchy.secondary) {
      switch (this) {
        case UniposButtonStatusVariant.success:
          return succes500;
        case UniposButtonStatusVariant.warning:
          return waring500;
        case UniposButtonStatusVariant.danger:
          return danger500;
      }
    }
    return Colors.transparent;
  }
}

enum UniposButtonStatusSize {
  small,
  medium,
  large;

  EdgeInsets get padding {
    switch (this) {
      case UniposButtonStatusSize.small:
        return EdgeInsets.symmetric(horizontal: uniposSize12, vertical: uniposSize8);
      case UniposButtonStatusSize.medium:
        return EdgeInsets.symmetric(horizontal: uniposSize16, vertical: uniposSize12);
      case UniposButtonStatusSize.large:
        return EdgeInsets.symmetric(horizontal: uniposSize20, vertical: uniposSize16);
    }
  }

  double get iconSizeValue {
    switch (this) {
      case UniposButtonStatusSize.small:
        return 12.0;
      case UniposButtonStatusSize.medium:
        return 16.0;
      case UniposButtonStatusSize.large:
        return 20.0;
    }
  }

  TextStyle getTextStyle(Color fgColor) {
    switch (this) {
      case UniposButtonStatusSize.small:
        return body1(FontWeight.w600, fgColor, 'Outfit');
      case UniposButtonStatusSize.medium:
        return heading4(FontWeight.w600, fgColor, 'Outfit');
      case UniposButtonStatusSize.large:
        return heading3(FontWeight.w600, fgColor, 'Outfit');
    }
  }
}

class UniposButtonStatus extends StatelessWidget {
  const UniposButtonStatus({
    super.key,
    this.textShow = true,
    this.text = "Button",
    this.onTap,
    this.variant = UniposButtonStatusVariant.success,
    this.hierarchy = UniposButtonStatusHierarchy.primary,
    this.icon,
    this.size = UniposButtonStatusSize.large,
  });

  final String text;
  final bool textShow;
  final VoidCallback? onTap;
  final UniposButtonStatusVariant variant;
  final UniposButtonStatusHierarchy hierarchy;
  final IconData? icon;
  final UniposButtonStatusSize size;

  @override
  Widget build(BuildContext context) {
    final bgColor = variant.getBgColor(hierarchy);
    final fgColor = variant.getFgColor(hierarchy);
    final borderColor = variant.getBorderColor(hierarchy);

    // Responsive logic: downgrade size by one step if the screen is Mobile (< 600px width)
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    UniposButtonStatusSize effectiveSize = size;
    if (isMobile) {
      if (size == UniposButtonStatusSize.large) {
        effectiveSize = UniposButtonStatusSize.medium;
      } else if (size == UniposButtonStatusSize.medium) {
        effectiveSize = UniposButtonStatusSize.small;
      }
      // if it's already small, it remains small
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: effectiveSize.padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(uniposSize8),
            ),
            child: Row(
              mainAxisSize: hierarchy == UniposButtonStatusHierarchy.tertiary ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: fgColor, size: effectiveSize.iconSizeValue),
                  if (textShow)
                    SizedBox(width: uniposSize16), // space antar icon & text
                ],

                if (textShow) Text(text, style: effectiveSize.getTextStyle(fgColor)),
              ],
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(uniposSize8),
                  border: Border.all(
                    width: 1,
                    color: borderColor,
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
