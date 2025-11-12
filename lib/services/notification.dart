import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data.containsKey('data')) {
    // Handle data message
    final data = message.data['data'];
  }

  if (message.data.containsKey('notification')) {
    // Handle notification message
    final notification = message.data['notification'];
  }

  // or do other work
}

class FCM {
  final streamCtrl = StreamController<String>.broadcast();
  final titleCtrl = StreamController<String>.broadcast();
  final bodyCtrl = StreamController<String>.broadcast();

  setNotifiications() {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    // Handle when app is in active state
    foregroundNotification();

    // Handle when app is running in background
    backgroundNotification();

    // Handle when app is closed by user or terminate
    terminateNotification();
  }

  foregroundNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.containsKey('data')) {
        streamCtrl.sink.add(message.data['data']);
      }
      if (message.data.containsKey('notification')) {
        streamCtrl.sink.add(message.data['notification']);
      }

      titleCtrl.sink.add(message.notification!.title!);
      bodyCtrl.sink.add(message.notification!.body!);
    });
  }

  backgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.containsKey('data')) {
        streamCtrl.sink.add(message.data['data']);
      }
      if (message.data.containsKey('notification')) {
        streamCtrl.sink.add(message.data['notification']);
      }

      titleCtrl.sink.add(message.notification!.title!);
      bodyCtrl.sink.add(message.notification!.body!);
    });
  }

  terminateNotification() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (initialMessage.data.containsKey('data')) {
        streamCtrl.sink.add(initialMessage.data['data']);
      }
      if (initialMessage.data.containsKey('notification')) {
        streamCtrl.sink.add(initialMessage.data['notification']);
      }

      titleCtrl.sink.add(initialMessage.notification!.title!);
      bodyCtrl.sink.add(initialMessage.notification!.body!);
    }
  }

  disponse() {
    streamCtrl.close();
    titleCtrl.close();
    bodyCtrl.close();
  }
}
