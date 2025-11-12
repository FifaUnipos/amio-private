import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerProvider with ChangeNotifier {
  final interval = const Duration(seconds: 1);
  final int timerMaxSeconds = 120;

  int currentSeconds = 0;
  Timer? _timer;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  void startTimeout() {
    stopTimer();
    currentSeconds = 0;

    _timer = Timer.periodic(interval, (timer) {
      currentSeconds = timer.tick;
      if (timer.tick >= timerMaxSeconds) {
        timer.cancel();
        notifyListeners();
      }
      notifyListeners();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}
