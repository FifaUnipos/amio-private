import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/data/model/merchant/merchant_sorting_data.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

class MerchantCard extends StatelessWidget {
  final MerchantSortingData merchant;
  final VoidCallback onTap;
  final String buttonText;
  final bool editable;
  final bool deletable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MerchantCard({
    super.key,
    required this.merchant,
    required this.onTap,
    this.editable = false,
    this.deletable = false,
    this.onEdit = _defaultCallback,
    this.onDelete = _defaultCallback,
    this.buttonText = 'Lihat Toko',
  });
  static void _defaultCallback() {}
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size16),
        border: Border.all(color: bnw300),
      ),
      child: IntrinsicHeight(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: size16,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(1000),
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: merchant.logomerchant_url != null
                        ? Image.network(
                            merchant.logomerchant_url!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              PhosphorIcons.storefront_fill,
                              size: 60,
                              color: bnw900,
                            ),
                          )
                        : Icon(
                            PhosphorIcons.storefront_fill,
                            size: 60,
                            color: bnw900,
                          ),
                  ),
                ),
                SizedBox(width: size24),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchant.name ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        merchant.address ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: body1(FontWeight.w400, bnw800, 'Outfit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _ActionButtons(
              onTap: onTap,
              buttonText: buttonText,
              editable: editable,
              deletable: deletable,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onTap;
  final String buttonText;
  final bool editable;
  final bool deletable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionButtons({
    required this.onTap,
    this.editable = false,
    this.deletable = false,
    required this.onEdit,
    required this.onDelete,
    this.buttonText = 'Lihat Toko',
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: size16,
      children: [
        if (editable)
          Expanded(
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: bnw100,
                  border: Border.all(color: bnw300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIcons.pencil_line),
                    const SizedBox(width: 16),
                    Text(
                      'Ubah',
                      style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ],
                ),
              ),
            ),
          ),

        if (deletable)
          GestureDetector(
            onTap: onDelete,
            child: Container(
              height: 40,
              width: 50,
              decoration: BoxDecoration(
                color: bnw100,
                border: Border.all(color: red500),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(PhosphorIcons.trash_fill, color: red500, size: 18),
            ),
          ),
        if (!editable && !deletable) ...[
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: buttonLoutline(
                Center(
                  child: Text(
                    buttonText,
                    style: heading4(FontWeight.w600, primary500, 'Outfit'),
                  ),
                ),
                primary500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
