import 'package:flutter/material.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/models/notificationModel.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/format_date_notification.dart';

class NotificationDataList extends StatelessWidget {
  const NotificationDataList({super.key, required this.data});

  final NotificationModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: size16, horizontal: size16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: bnw900.withOpacity(0.3), width: 0.5),
        ),
      ),
      child: Row(
        spacing: isTabletLayout(context) ? 32 : 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                ),
                Text(
                  data.description,
                  style: heading4(FontWeight.w400, bnw700, 'Outfit'),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Text(
            formatDateNotification(data.date),
            style: heading4(FontWeight.w400, bnw500, 'Outfit'),
          ),
        ],
      ),
    );
  }
}
