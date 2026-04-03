import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/utilities.dart';


class SortBottomSheetButton extends StatelessWidget {
  const SortBottomSheetButton({
    super.key,
    required this.options,
    required this.onConfirm,
    this.initialIndex = 0,
    this.buttonLabel = 'Urutkan',
    this.sheetTitle = 'Urutkan',
    this.sheetSubtitle = 'Tentukan data yang akan tampil',
    this.sectionLabel = 'Pilih Urutan',
    this.confirmLabel = 'Tampilkan',
  });

  final List<dynamic> options;
  final ValueChanged<int> onConfirm;
  final int initialIndex;
  final String buttonLabel;
  final String sheetTitle;
  final String sheetSubtitle;
  final String sectionLabel;
  final String confirmLabel;

  void _openSheet(BuildContext context) async {
    final int? selectedIndex = await showModalBottomSheet<int>(
      context: context,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      builder: (sheetContext) {
        int localIndex = initialIndex;

        return StatefulBuilder(
          builder: (_, setSheet) => IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size12),
                  topLeft: Radius.circular(size12),
                ),
              ),
              child: Column(
                children: [
                  dividerShowdialog(),
                  SizedBox(height: size16),
                  Container(
                    width: double.infinity,
                    color: bnw100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sheetTitle,
                          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                        ),
                        Text(
                          sheetSubtitle,
                          style: heading4(FontWeight.w400, bnw600, 'Outfit'),
                        ),
                        SizedBox(height: size20),
                        Text(
                          sectionLabel,
                          style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                        Wrap(
                          children: List<Widget>.generate(
                            options.length,
                            (int index) {
                              return Padding(
                                padding: EdgeInsets.only(right: size16),
                                child: ChoiceChip(
                                  padding: EdgeInsets.symmetric(
                                    vertical: size12,
                                  ),
                                  backgroundColor: bnw100,
                                  selectedColor: primary100,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: localIndex == index
                                          ? primary500
                                          : bnw300,
                                    ),
                                    borderRadius: BorderRadius.circular(size8),
                                  ),
                                  label: Text(
                                    options[index],
                                    style: heading4(
                                      FontWeight.w400,
                                      localIndex == index
                                          ? primary500
                                          : bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                  selected: localIndex == index,
                                  onSelected: (_) =>
                                      setSheet(() => localIndex = index),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size32),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetContext, localIndex);
                      },
                      child: buttonXL(
                        Center(
                          child: Text(
                            confirmLabel,
                            style: heading3(
                              FontWeight.w600,
                              bnw100,
                              'Outfit',
                            ),
                          ),
                        ),
                        0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedIndex != null) {
      onConfirm(selectedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: GestureDetector(
        onTap: () => _openSheet(context),
        child: buttonLoutline(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                buttonLabel,
                style: heading3(FontWeight.w600, bnw900, 'Outfit'),
              ),
              Text(
                ' dari ${options[initialIndex]}',
                style: heading3(FontWeight.w400, bnw900, 'Outfit'),
              ),
              SizedBox(width: size12),
              Icon(PhosphorIcons.caret_down, color: bnw900, size: size24),
            ],
          ),
          bnw300,
        ),
      ),
    );
  }
}