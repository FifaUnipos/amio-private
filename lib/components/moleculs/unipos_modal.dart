import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/components/atoms/button/unipos_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/unipos_size.dart';

class UniposModal extends StatelessWidget {
  final String title;
  final String? description;
  final bool prefixButtonShow;
  final bool suffixButtonShow;
  final String prefixTextButton;
  final String suffixTextButton;
  final VoidCallback? onTapPrefixButton;
  final VoidCallback? onTapSuffixButton;
  final Widget? child;
  final VoidCallback? onTapClose;

  const UniposModal({
    Key? key,
    required this.title,
    required this.description,
    this.prefixButtonShow = true,
    this.suffixButtonShow = true,
    this.prefixTextButton = 'Tutup',
    this.suffixTextButton = 'Selesai',
    this.onTapPrefixButton,
    this.onTapSuffixButton,
    this.child,
    this.onTapClose,
  }) : super(key: key);

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? description,
    bool? prefixButtonShow,
    bool? suffixButtonShow,
    String prefixTextButton = 'Tutup',
    String suffixTextButton = 'Selesai',
    VoidCallback? onTapPrefixButton,
    VoidCallback? onTapSuffixButton,
    Widget? child,
    VoidCallback? onTapClose,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: bnw100,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: UniposModal(
            title: title,
            description: description,
            prefixButtonShow: prefixButtonShow ?? true,
            suffixButtonShow: suffixButtonShow ?? true,
            prefixTextButton: prefixTextButton,
            suffixTextButton: suffixTextButton,
            onTapPrefixButton: onTapPrefixButton,
            onTapSuffixButton: onTapSuffixButton,
            child: child,
            onTapClose: onTapClose,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            spacing: uniposSize32,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                spacing: 16,
                children: [
                  Container(
                    width: uniposSize60,
                    height: uniposSize4,
                    decoration: BoxDecoration(
                      color: bnw300,
                      borderRadius: BorderRadius.all(
                        Radius.circular(uniposSizeFull),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: heading1(FontWeight.bold, bnw900, 'Outfit'),
                          ),
                          if (description != null)
                            Text(
                              description!,
                              style: heading3(
                                FontWeight.normal,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onTapClose,
                        child: Icon(PhosphorIcons.x, size: uniposSize24),
                      ),
                    ],
                  ),
                ],
              ),
              if (child != null) child!,
              Row(
                spacing: 8,
                children: [
                  if (prefixButtonShow)
                    Expanded(
                      child: UniposButton(
                        text: prefixTextButton,
                        variant: UniposButtonVariant.secondary,
                        onTap: onTapPrefixButton,
                      ),
                    ),
                  if (suffixButtonShow)
                    Expanded(
                      child: UniposButton(
                        text: suffixTextButton,
                        onTap: onTapSuffixButton,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
