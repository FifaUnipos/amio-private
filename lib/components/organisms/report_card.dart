import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/pageTablet/tokopage/sidebar/laporanToko/classLaporan.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

class ReportCard extends StatelessWidget {
  final ObjectLaporan obj;
  final int index;
  final PageController pageController;

  const ReportCard({
    required this.obj,
    required this.index,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pageController.jumpToPage(index + 1);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(size16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: size16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obj.title,
                        maxLines: 2,
                        style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        obj.description,
                        style: body1(FontWeight.w400, bnw800, 'Outfit'),
                      ),
                    ],
                  ),
                ),
                Icon(obj.icon, color: bnw900, size: 36),
              ],
            ),
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: bnw100,
                border: Border.all(color: primary500),
                borderRadius: BorderRadius.circular(size8),
              ),
              child: Center(
                child: Text(
                  'Lihat Laporan',
                  style: heading4(FontWeight.w600, primary500, 'Outfit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
