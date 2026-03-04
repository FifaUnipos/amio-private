import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:unipos_app_335/components/notification/modal_notification_show_detail.dart';
import 'package:unipos_app_335/components/notification/notification_data_list.dart';
import 'package:unipos_app_335/models/notificationModel.dart';
import 'package:unipos_app_335/providers/notifications/payload_provider.dart';
import 'package:unipos_app_335/services/unipos_notification_service.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';

class DashboardWithNotif extends StatefulWidget {
  final List<NotificationModel> notifications;

  const DashboardWithNotif({super.key, required this.notifications});

  @override
  State<DashboardWithNotif> createState() => _DashboardWithNotifState();
}

class _DashboardWithNotifState extends State<DashboardWithNotif> {
  StreamSubscription<String?>? _notifSubscription;

  void _configureSelectNotificationSubject() {
    _notifSubscription = selectNotificationStream.stream.listen((String? payload) {
      context.read<PayloadProvider>().payload = payload;
    });
  }

  @override
  void initState() {
    super.initState();
    _configureSelectNotificationSubject();
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 80,
        ),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pemberitahuan',
              style: heading2(FontWeight.w700, bnw900, 'Outfit'),
            ),
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: bnw300),
                  borderRadius: BorderRadius.circular(size16),
                ),
                child: widget.notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/illustration/imageHelp.svg',
                              height: 120,
                            ),
                            Text(
                              'Tidak ada Notifikasi baru',
                              style: heading3(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: widget.notifications.length,
                        itemBuilder: (context, index) {
                          final notif = widget.notifications[index];
                          return GestureDetector(
                            onTap: () {
                              ModalNotificationShowDetail.show(context, notif);
                            },
                            child: NotificationDataList(data: notif),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
