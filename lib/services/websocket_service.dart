// lib/services/websocket_service.dart
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/models/notificationModel.dart';
import 'package:unipos_app_335/services/unipos_notification_service.dart';

class WebSocketService extends ChangeNotifier {

  String linkWebsocket = 'https://amio-unipos-unipos-notification.yi8k7d.easypanel.host/';
  // String linkWebsocket =  'https://unipos-dev-notification-service-dev.yi8k7d.easypanel.host/',

  // ✅ Pisah jadi 2 socket
  IO.Socket? socket; // untuk notifikasi
  IO.Socket? transactionSocket; // untuk transaksi QRIS

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

  // ✅ Connect notifikasi (existing, tidak berubah)
  void connect(String? token, String? deviceId, {String? merchantId}) {
    if (socket != null &&
        token == _lastToken &&
        deviceId == _lastDeviceId &&
        merchantId == _lastMerchantId) {
      if (socket!.connected) {
        debugPrint('🔌 WebSocket notif already connected. Skipping.');
      }
      return;
    }

    debugPrint('🔌 Connecting Notification WebSocket...');
    _lastToken = token;
    _lastDeviceId = deviceId;
    _lastMerchantId = merchantId;

    if (socket != null) {
      socket?.clearListeners();
      socket?.disconnect();
      socket?.dispose();
    }

    socket = IO.io(
      linkWebsocket,
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
      debugPrint('✅ Notification WebSocket Connected');
      socket?.emit('subscribeTransaction', {'transactionId': merchantId});
    });

    socket?.on(
      'connect_error',
      (err) => debugPrint('❌ Notif connect error: $err'),
    );

    socket?.on('notificationData', (data) {
      if (data is! List) return;
      final parsed = data
          .map((item) => NotificationModel.fromJson(item))
          .toList()
          .cast<NotificationModel>();
      parsed.sort((a, b) => b.id.compareTo(a.id));
      notifications = parsed;
      notifyListeners();
    });

    socket?.on('newNotifications', (data) async {
      if (data is! List) return;
      int notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      for (var item in data) {
        final notif = NotificationModel.fromJson(item);
        if (notifications.any((n) => n.id == notif.id)) continue;
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

    socket?.on(
      'disconnect',
      (reason) => debugPrint('❌ Notif disconnected: $reason'),
    );
    socket?.onAny(
      (event, data) => debugPrint('📡 Notif event: $event → $data'),
    );
  }

  // ✅ Connect khusus transaksi QRIS
  void connectTransaction(
    String? token,
    String? deviceId,
    String transactionId,
  ) {
    debugPrint('🔌 Connecting Transaction WebSocket for $transactionId...');

    // Dispose socket transaksi sebelumnya kalau ada
    if (transactionSocket != null) {
      transactionSocket?.clearListeners();
      transactionSocket?.disconnect();
      transactionSocket?.dispose();
      transactionSocket = null;
    }

    transactionSocket = IO.io(
      linkWebsocket,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .setExtraHeaders({'token': token ?? '', 'deviceid': identifier ?? ''})
          .setPath('/socket.io')
          .build(),
    );

    transactionSocket?.connect();

    transactionSocket?.on('connect', (_) {
      debugPrint('✅ Transaction WebSocket Connected for $transactionId');

      transactionSocket?.emit('subscribeTransaction', {
        'transactionId': transactionId,
        'transaction_id': transactionId,
      });

      transactionSocket?.emit('joinRoom', {
        'room': 'subscribeTransaction',
        'transactionId': transactionId,
        'transaction_id': transactionId,
      });

      debugPrint('🏠 Joined room subscribeTransaction for $transactionId');
    });

    transactionSocket?.on(
      'connect_error',
      (err) => debugPrint('❌ Transaction connect error: $err'),
    );
    transactionSocket?.on(
      'disconnect',
      (reason) => debugPrint('❌ Transaction disconnected: $reason'),
    );
    transactionSocket?.onAny(
      (event, data) => debugPrint('📡 Transaction event: $event → $data'),
    );
  }

  // ✅ Disconnect hanya socket transaksi setelah QRIS selesai
  void disconnectTransaction() {
    debugPrint('🔌 Disconnecting Transaction WebSocket...');
    transactionSocket?.clearListeners();
    transactionSocket?.disconnect();
    transactionSocket?.dispose();
    transactionSocket = null;
  }

  void disconnect() {
    socket?.clearListeners();
    socket?.disconnect();
    socket?.dispose();
    disconnectTransaction();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
