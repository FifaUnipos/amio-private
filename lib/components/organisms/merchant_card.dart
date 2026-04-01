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

  const MerchantCard({
    super.key,
    required this.merchant,
    required this.onTap,
    this.buttonText = 'Lihat Toko',
  });

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
            SizedBox(height: size16),
            GestureDetector(
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
          ],
        ),
      ),
    );
  }
}