import 'package:flutter/material.dart';
import 'package:skeletons_forked/skeletons_forked.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/unipos_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

enum UniposButtonOptionState { defaultState, active }

enum UniposButtonOptionVariant {
  normal,
  primary;

  Color getBgColor(UniposButtonOptionState state) {
    if (state == UniposButtonOptionState.defaultState) {
      switch (this) {
        case UniposButtonOptionVariant.normal:
          return bnw100;
        case UniposButtonOptionVariant.primary:
          return primary100;
      }
    } else {
      // active state
      switch (this) {
        case UniposButtonOptionVariant.normal:
          return primary100;
        case UniposButtonOptionVariant.primary:
          return primary500;
      }
    }
  }

  Color getFgColor(UniposButtonOptionState state) {
    if (state == UniposButtonOptionState.defaultState) {
      switch (this) {
        case UniposButtonOptionVariant.normal:
          return bnw900;
        case UniposButtonOptionVariant.primary:
          return primary500;
      }
    } else {
      // active state
      switch (this) {
        case UniposButtonOptionVariant.normal:
          return primary500;
        case UniposButtonOptionVariant.primary:
          return primary500;
      }
    }
  }

  Color getBorderColor(UniposButtonOptionState state) {
    if (state == UniposButtonOptionState.defaultState) {
      switch (this) {
        case UniposButtonOptionVariant.normal:
          return bnw300;
        case UniposButtonOptionVariant.primary:
          return bnw300;
      }
    } else {
      // active state
      switch (this) {
        case UniposButtonOptionVariant.normal:
          return primary500;
        case UniposButtonOptionVariant.primary:
          return primary500;
      }
    }
  }
}

enum UniposButtonOptionSize {
  small,
  medium,
  large;

  EdgeInsets get padding {
    switch (this) {
      case UniposButtonOptionSize.small:
        return EdgeInsets.symmetric(
         horizontal: uniposSize12,
          vertical: uniposSize8,
        );
      case UniposButtonOptionSize.medium:
        return EdgeInsets.symmetric(
          horizontal: uniposSize16,
          vertical: uniposSize12,
        );
      case UniposButtonOptionSize.large:
        return EdgeInsets.symmetric(
          horizontal: uniposSize16,
          vertical: uniposSize12,
        );
    }
  }

  double get iconSizeValue {
    switch (this) {
      case UniposButtonOptionSize.small:
        return 12.0;
      case UniposButtonOptionSize.medium:
        return 16.0;
      case UniposButtonOptionSize.large:
        return 20.0;
    }
  }

  TextStyle getTextStyle(Color fgColor) {
    switch (this) {
      case UniposButtonOptionSize.small:
        return body1(FontWeight.w600, fgColor, 'Outfit');
      case UniposButtonOptionSize.medium:
        return heading4(FontWeight.w600, fgColor, 'Outfit');
      case UniposButtonOptionSize.large:
        return heading3(FontWeight.w600, fgColor, 'Outfit');
    }
  }
}

class UniposButtonOption extends StatelessWidget {
  const UniposButtonOption({
    super.key,
    this.textShow = true,
    this.text = "Button",
    this.onTap,
    this.variant = UniposButtonOptionVariant.normal,
    this.state = UniposButtonOptionState.defaultState,
    this.icon,
    this.size = UniposButtonOptionSize.large,
    this.isLoading = false,
  });

  final String text;
  final bool textShow;
  final VoidCallback? onTap;
  final UniposButtonOptionVariant variant;
  final UniposButtonOptionState state;
  final IconData? icon;
  final UniposButtonOptionSize size;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bgColor = variant.getBgColor(state);
    final fgColor = variant.getFgColor(state);
    final borderColor = variant.getBorderColor(state);

    // Responsive logic: downgrade size by one step if the screen is Mobile (< 600px width)
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    UniposButtonOptionSize effectiveSize = size;
    if (isMobile) {
      if (size == UniposButtonOptionSize.large) {
        effectiveSize = UniposButtonOptionSize.large;
      } else if (size == UniposButtonOptionSize.medium) {
        effectiveSize = UniposButtonOptionSize.medium;
      }
      // if it's already small, it remains small
    }

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Stack(
        children: [
          Container(
            padding: effectiveSize.padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(uniposSize8),
            ),
            child: Opacity(
              opacity: isLoading ? 0.0 : 1.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: fgColor, size: effectiveSize.iconSizeValue),
                    if (textShow)
                      SizedBox(width: uniposSize16), // space antar icon & text
                  ],

                  if (textShow)
                    Text(text, style: effectiveSize.getTextStyle(fgColor)),
                ],
              ),
            ),
          ),
          if (!isLoading)
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
          if (isLoading)
            Positioned.fill(
              child: SkeletonAvatar(
                style: SkeletonAvatarStyle(
                  borderRadius: BorderRadius.circular(uniposSize8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
