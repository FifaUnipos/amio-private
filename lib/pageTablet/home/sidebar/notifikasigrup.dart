import 'package:provider/provider.dart';
import 'package:unipos_app_335/components/notification/notification_data_list.dart';
import 'package:unipos_app_335/data/model/merchant/merchant_sorting_data.dart';
import 'package:unipos_app_335/models/notificationModel.dart';
import 'package:unipos_app_335/components/notification/modal_notification_show_detail.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/services/websocket_service.dart';
import 'package:unipos_app_335/utils/component/component_showModalBottom.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:flutter_svg/svg.dart';

import '../../../models/tokomodel.dart';
import '../../../../utils/component/component_color.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class NotifikasiGrup extends StatefulWidget {
  NotifikasiGrup({Key? key}) : super(key: key);

  @override
  State<NotifikasiGrup> createState() => _NotifikasiGrupState();
}

class _NotifikasiGrupState extends State<NotifikasiGrup> {
  List<MerchantSortingData>? datas;
  IO.Socket? socket;
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final wsService = context.watch<WebSocketService>();
    final notifications = wsService.notifications;
    return WillPopScope(
      onWillPop: () async {
        showModalBottomExit(context);
        return false;
      },
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.all(size16),
          padding: EdgeInsets.all(size16),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.circular(size16),
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pemberitahuan',
                    style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    nameToko ?? '',
                    style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    border: Border.all(color: bnw300),
                    borderRadius: BorderRadius.circular(size16),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: notifications.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    height: 120,
                                    'assets/illustration/imageHelp.svg',
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    'Tidak ada Notifikasi baru',
                                    style: heading3(
                                      FontWeight.w600,
                                      bnw900,
                                      'OUtfit',
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      ModalNotificationShowDetail.show(
                                        context,
                                        notifications[index],
                                      );
                                    },
                                    child: NotificationDataList(
                                      data: notifications[index],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
