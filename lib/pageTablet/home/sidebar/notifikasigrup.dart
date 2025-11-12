import 'dart:convert';
import 'dart:developer';

import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/models/notificationModel.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_showModalBottom.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/tokomodel.dart';
import '../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class NotifikasiGrup extends StatefulWidget {
  NotifikasiGrup({Key? key}) : super(key: key);

  @override
  State<NotifikasiGrup> createState() => _NotifikasiGrupState();
}

class _NotifikasiGrupState extends State<NotifikasiGrup> {
  List<ModelDataToko>? datas;
  IO.Socket? socket;
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    connectWebSocket();
  }

  void connectWebSocket() async {
    socket = IO.io(
      'https://unipos-dev-notification-service-dev.yi8k7d.easypanel.host/',
      // url,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'extraHeaders': {
          'token': checkToken,
          'deviceid': identifier,
        },
        'path': '/socket.io',
      },
    );

    socket?.connect();

    // Emit 'joinRoom' untuk bergabung ke dalam room tertentu
    socket?.on('connect', (_) {
      print('Connected to WebSocket');
      socket?.emit(
        'joinRoom',
      );
    });

    // Mendengarkan event 'newNotifications'
    socket?.on('newNotifications', (data) async {
      // Cetak data yang diterima untuk memeriksa formatnya
      print('Received data (newNotifications): $data');

      setState(() {
        if (data is List) {
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              NotificationModel newNotification =
                  NotificationModel.fromJson(item);
              notifications.add(newNotification);

              // Simpan notifikasi ke SharedPreferences
              saveNotifications();
            } else {
              print('Data item tidak sesuai format: $item');
            }
          }
        } else {
          print('Data tidak sesuai format (expected List): $data');
        }
      });
    });

    // Mendengarkan event 'notificationData'
    socket?.on('notificationData', (data) async {
      // Cetak data yang diterima untuk memeriksa formatnya
      print('Received data (notificationData): $data');

      setState(() {
        if (data is List) {
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              NotificationModel newNotification =
                  NotificationModel.fromJson(item);
              notifications.add(newNotification);

              // Simpan notifikasi ke SharedPreferences
              saveNotifications();
            } else {
              print('Data item tidak sesuai format: $item');
            }
          }
        } else {
          print('Data tidak sesuai format (expected List): $data');
        }
      });
    });

    // Menangani error
    socket?.on('error', (data) {
      print('Error: $data');
    });

    // Menangani disconnect
    socket?.on('disconnect', (_) {
      print('Disconnected from WebSocket');
    });
  }

// Fungsi untuk menyimpan notifikasi ke SharedPreferences
  Future<void> saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notificationsJson = notifications
        .map((notification) => jsonEncode(notification.toJson()))
        .toList();
    await prefs.setStringList('notifications', notificationsJson);
  }

// Fungsi untuk memuat notifikasi dari SharedPreferences saat aplikasi dimulai
  Future<void> loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notificationsJson = prefs.getStringList('notifications');
    if (notificationsJson != null) {
      setState(() {
        notifications = notificationsJson
            .map((notificationJson) =>
                NotificationModel.fromJson(jsonDecode(notificationJson)))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: size16),
              Expanded(
                child: Container(
                  // padding: EdgeInsets.all(size16),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border.all(color: bnw300),
                    borderRadius: BorderRadius.circular(size16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: size24, horizontal: size16),
                        // margin: EdgeInsets.symmetric(vertical: size16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: bnw900,
                              width: width1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notifikasi',
                              style:
                                  heading3(FontWeight.w600, bnw900, 'OUtfit'),
                            ),
                            // buttonLoutline(
                            //     Row(
                            //       children: [
                            //         Icon(
                            //           PhosphorIcons.trash_fill,
                            //           color: danger500,
                            //           size: size20,
                            //         ),
                            //         SizedBox(width: size12),
                            //         Text(
                            //           'Hapus Semua',
                            //           style: heading4(
                            //               FontWeight.w600, danger500, 'OUtfit'),
                            //         ),
                            //       ],
                            //     ),
                            //     danger500)
                          ],
                        ),
                      ),
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
                                        FontWeight.w600, bnw900, 'OUtfit'),
                                  )
                                ],
                              )
                            : ListView.builder(
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: size16, horizontal: size16),
                                    // margin: EdgeInsets.symmetric(vertical: size16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: bnw900,
                                          width: width1 - 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notifications[index].title,
                                              style: heading4(FontWeight.w600,
                                                  bnw900, 'Outfit'),
                                            ),
                                            Text(
                                              notifications[index].type,
                                              style: heading4(FontWeight.w400,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showModalBottom(
                                              context,
                                              MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              IntrinsicHeight(
                                                child: Padding(
                                                  padding: EdgeInsets.all(28.0),
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          notifications[index]
                                                              .title,
                                                          style: heading2(
                                                            FontWeight.w600,
                                                            bnw900,
                                                            'Outfit',
                                                          ),
                                                        ),
                                                        Text(
                                                          notifications[index]
                                                              .description,
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                        Text(
                                                          notifications[index]
                                                              .date,
                                                          style: heading4(
                                                              FontWeight.w400,
                                                              bnw900,
                                                              'Outfit'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: buttonL(
                                            Center(
                                              child: Text(
                                                'Lihat',
                                                style: body1(FontWeight.w600,
                                                    bnw100, 'Outfit'),
                                              ),
                                            ),
                                            primary500,
                                            primary500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
