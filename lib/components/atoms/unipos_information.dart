import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/status_transaction.dart';
import 'package:unipos_app_335/utils/component/unipos_size.dart';

enum UniposInformationHierarchy { primary, secondary, tertiary }

enum UniposInformationVariant {
  success,
  warning,
  danger,
  general;

  Color getBgColor(UniposInformationHierarchy hierarchy) {
    if (hierarchy == UniposInformationHierarchy.primary) {
      switch (this) {
        case UniposInformationVariant.success:
          return succes500;
        case UniposInformationVariant.warning:
          return waring500;
        case UniposInformationVariant.danger:
          return danger500;
        case UniposInformationVariant.general:
          return bnw900;
      }
    } else if (hierarchy == UniposInformationHierarchy.tertiary) {
      switch (this) {
        case UniposInformationVariant.success:
          return succes100;
        case UniposInformationVariant.warning:
          return waring100;
        case UniposInformationVariant.danger:
          return danger100;
        case UniposInformationVariant.general:
          return bnw100;
      }
    }
    return Colors.transparent;
  }

  Color getFgColor(UniposInformationHierarchy hierarchy) {
    if (hierarchy == UniposInformationHierarchy.primary) {
      return bnw100;
    }
    switch (this) {
      case UniposInformationVariant.success:
        return succes500;
      case UniposInformationVariant.warning:
        return waring500;
      case UniposInformationVariant.danger:
        return danger500;
      case UniposInformationVariant.general:
        return bnw700;
    }
  }

  Color getBorderColor(UniposInformationHierarchy hierarchy) {
    if (hierarchy == UniposInformationHierarchy.secondary) {
      switch (this) {
        case UniposInformationVariant.success:
          return succes500;
        case UniposInformationVariant.warning:
          return waring500;
        case UniposInformationVariant.danger:
          return danger500;
        case UniposInformationVariant.general:
          return bnw700;
      }
    }
    return Colors.transparent;
  }
}

extension UniposInformationVariantExt on UniposInformationVariant {
  static UniposInformationVariant fromIsPaid(dynamic isPaid) {
    if (statusTransactionSuccess.contains(isPaid)) {
      return UniposInformationVariant.success;
    } else if (statusTransactionProcessCancel.contains(isPaid)) {
      return UniposInformationVariant.warning;
    } else if (statusTransactionCancel.contains(isPaid)) {
      return UniposInformationVariant.danger;
    }
    return UniposInformationVariant.general;
  }
}

enum UniposInformationSize {
  extraSmall,
  small,
  medium,
  large;

  EdgeInsets get padding {
    switch (this) {
      case UniposInformationSize.extraSmall:
        return EdgeInsets.symmetric(
          horizontal: uniposSize8,
          vertical: uniposSize4,
        );
      case UniposInformationSize.small:
        return EdgeInsets.symmetric(
          horizontal: uniposSize12,
          vertical: uniposSize8,
        );
      case UniposInformationSize.medium:
        return EdgeInsets.symmetric(
          horizontal: uniposSize12,
          vertical: uniposSize8,
        );
      case UniposInformationSize.large:
        return EdgeInsets.symmetric(
          horizontal: uniposSize16,
          vertical: uniposSize12,
        );
    }
  }

  double get iconSizeValue {
    switch (this) {
      case UniposInformationSize.extraSmall:
        return 12.0;
      case UniposInformationSize.small:
        return 16.0;
      case UniposInformationSize.medium:
        return 16.0;
      case UniposInformationSize.large:
        return 20.0;
    }
  }
   double get gapSizeValue {
    switch (this) {
      case UniposInformationSize.extraSmall:
        return 4.0;
      case UniposInformationSize.small:
        return 8.0;
      case UniposInformationSize.medium:
        return 16.0;
      case UniposInformationSize.large:
        return 20.0;
    }
  }

  TextStyle getTextStyle(Color fgColor) {
    switch (this) {
      case UniposInformationSize.extraSmall:
        return heading4(FontWeight.w600, fgColor, 'Outfit');
      case UniposInformationSize.small:
        return heading4(FontWeight.w600, fgColor, 'Outfit');
      case UniposInformationSize.medium:
        return heading3(FontWeight.w600, fgColor, 'Outfit');
      case UniposInformationSize.large:
        return heading3(FontWeight.w600, fgColor, 'Outfit');
    }
  }
}

class UniposInformation extends StatelessWidget {
  const UniposInformation({
    super.key,
    required this.text,
    this.showIcon = true,
    this.isFullWidth = false,
    this.size = UniposInformationSize.large,
    this.variant = UniposInformationVariant.general,
    this.hierarchy = UniposInformationHierarchy.tertiary,
  });

  final String text;
  final bool showIcon;
  final bool isFullWidth;
  final UniposInformationSize size;
  final UniposInformationVariant variant;
  final UniposInformationHierarchy hierarchy;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    UniposInformationSize effectiveSize = size;
    if (isMobile) {
      if (size == UniposInformationSize.large) {
        effectiveSize = UniposInformationSize.large;
      } else if (size == UniposInformationSize.medium) {
        effectiveSize = UniposInformationSize.medium;
      } else if (size == UniposInformationSize.small) {
        effectiveSize = UniposInformationSize.small;
      }
    }

    final backgroundColor = variant.getBgColor(hierarchy);
    final foregroundColor = variant.getFgColor(hierarchy);
    final borderColor = variant.getBorderColor(hierarchy);

    return Stack(
      children: [
        Container(
          width: isFullWidth ? double.infinity : null,
          padding: effectiveSize.padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(uniposSize8),
          ),
          child: Row(
            spacing: effectiveSize.gapSizeValue,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (isFullWidth)
                Expanded(
                  child: Text(
                    text,
                    style: effectiveSize.getTextStyle(foregroundColor),
                  ),
                )
              else
                Flexible(
                  child: Text(
                    text,
                    style: effectiveSize.getTextStyle(foregroundColor),
                  ),
                ),
              if (showIcon)
                Icon(
                  PhosphorIcons.info_fill,
                  color: foregroundColor,
                  size: effectiveSize.iconSizeValue,
                ),
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
    );
  }
}
