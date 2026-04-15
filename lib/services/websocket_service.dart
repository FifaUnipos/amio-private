// lib/services/websocket_service.dart
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:unipos_app_335/models/notificationModel.dart';
import 'package:unipos_app_335/services/unipos_notification_service.dart';

class WebSocketService extends ChangeNotifier {
  IO.Socket? socket;
  List<NotificationModel> notifications = [];
  final UniposNotificationService _notifService = UniposNotificationService();
  
  String? _lastToken;
  String? _lastDeviceId;
  String? _lastMerchantId;

  List<NotificationModel> _deduplicateById(List<NotificationModel> list) {
    final seen = <int>{};
    return list.where((n) {
      if (seen.contains(n.id)) return false;
      seen.add(n.id);
      return true;
    }).toList();
  }

  void connect(String? token, String? deviceId, {String? merchantId}) {
    // Prevent redundant connections if already connecting/connected with same credentials
    if (socket != null && 
        token == _lastToken && 
        deviceId == _lastDeviceId &&
        merchantId == _lastMerchantId) {
      if (socket!.connected) {
        debugPrint('🔌 WebSocket already connected. Skipping.');
      } else {
        debugPrint('🔌 WebSocket is active or connecting with same credentials. Skipping redundant restart.');
      }
      return;
    }

    debugPrint('🔌 Connecting WebSocket... token: $token, deviceId: $deviceId, merchantId: $merchantId');
    _lastToken = token;
    _lastDeviceId = deviceId;
    _lastMerchantId = merchantId;

    if (socket != null) {
       socket?.clearListeners();
       socket?.disconnect();
       socket?.dispose();
    }

    socket = IO.io(
      'https://amio-unipos-unipos-notification.yi8k7d.easypanel.host/',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .setExtraHeaders({'token': token ?? '', 'deviceid': deviceId ?? ''})
          .setPath('/socket.io')
          .build(),
    );

    socket?.connect();

    socket?.on('connect', (_) {
      debugPrint('✅ Connected to WebSocket');
      debugPrint('🏠 Emitting joinRoom with merchantId: $merchantId...');
      socket?.emit('joinRoom', {'merchant_id': merchantId});
    });

    socket?.on('connect_error', (err) {
      debugPrint('❌ Connect error: $err');
    });

    socket?.on('notificationData', (data) {
      debugPrint(
        '📦 notificationData received, count: ${data is List ? data.length : '?'}',
      );
      if (data is! List) {
        debugPrint('⚠️ notificationData bukan List: ${data.runtimeType}');
        return;
      }

      final parsed = data
          .map((item) => NotificationModel.fromJson(item))
          .toList()
          .cast<NotificationModel>();

      parsed.sort((a, b) => b.id.compareTo(a.id));
      notifications = parsed;
      notifyListeners();
    });

    socket?.on('newNotifications', (data) async {
      debugPrint(
        '🔔 newNotifications received, count: ${data is List ? data.length : '?'}',
      );
      if (data is! List) {
        debugPrint('⚠️ newNotifications bukan List: ${data.runtimeType}');
        return;
      }

      int notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      for (var item in data) {
        final notif = NotificationModel.fromJson(item);
        final alreadyExists = notifications.any((n) => n.id == notif.id);
        if (alreadyExists) continue;

        notifications.insert(0, notif);
        await _notifService.showNotification(
          id: notifId++,
          title: notif.title,
          body: notif.description,
          payload: notif.id.toString(),
        );
      }

      notifications = _deduplicateById(notifications);
      notifyListeners();
    });

    socket?.on('disconnect', (reason) {
      debugPrint('❌ Disconnected: $reason'); // ⬅️ cek alasan disconnect
    });

    socket?.onAny((event, data) {
      debugPrint('📡 Event received: $event → $data'); // ⬅️ tangkap semua event
    });
  }

  void disconnect() {
    socket?.clearListeners();
    socket?.disconnect();
    socket?.dispose();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
