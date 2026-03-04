import 'package:flutter/material.dart';
import 'package:unipos_app_335/components/moleculs/unipos_modal.dart';
import 'package:unipos_app_335/models/notificationModel.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/format_date_notification.dart';

class ModalNotificationShowDetail {
  static void show(BuildContext context, NotificationModel notif) {
    UniposModal.show(
      context,
      title: 'Detail Notifikasi',
      suffixButtonShow: false,
      onTapClose: () {
        Navigator.pop(context);
      },
      onTapPrefixButton: () {
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  notif.title,
                  style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                ),
                Text(
                  formatDateNotificationDetail(notif.date),
                  style: heading4(FontWeight.w400, bnw700, 'Outfit'),
                ),
              ],
            ),
            Text(
              notif.description,
              style: heading4(FontWeight.w400, bnw900, 'Outfit'),
            ),
          ],
        ),
      ),
    );
  }
}
