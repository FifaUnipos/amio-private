import 'package:flutter/material.dart';
import 'package:unipos_app_335/services/unipos_notification_service.dart';

class UniposNotificationProvider extends ChangeNotifier {
  final UniposNotificationService flutterNotificationService;

  UniposNotificationProvider(this.flutterNotificationService);

  int _notificationId = 0;
  bool? _permission = false;
  bool? get permission => _permission;

  Future<void> requestPermissions() async {
    _permission = await flutterNotificationService.requestPermissions();
    notifyListeners();
  }

  void showNotification() {
    _notificationId += 1;
    flutterNotificationService.showNotification(
      id: _notificationId,
      title: "Hidup Jokowi",
      body: "Hidup Jokowi Hidup Jokowi! $_notificationId",
      payload: "this is payload from notification with id $_notificationId",
    );
  }
}
