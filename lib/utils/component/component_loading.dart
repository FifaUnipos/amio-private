import 'dart:async';

import 'package:flutter/material.dart';
import '../component/component_color.dart';

Completer<void>? _loadingCompleter;
NavigatorState? _loadingNavigator;

void whenLoading(BuildContext context) {
  if (_loadingCompleter != null && !_loadingCompleter!.isCompleted) {
    return;
  }
  _loadingCompleter = Completer<void>();
  _loadingNavigator = Navigator.of(context, rootNavigator: true);

  showDialog(
    barrierDismissible: false,
    useRootNavigator: true,
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(color: primary500),
        ),
      ),
    ),
  );

  Future.delayed(const Duration(seconds: 7), () {
    if (_loadingCompleter != null && !_loadingCompleter!.isCompleted) {
      if (_loadingNavigator != null && _loadingNavigator!.canPop()) {
        _loadingNavigator!.pop();
      }
      _loadingCompleter!.complete();
    }
  });
}

Future<void> closeLoading(BuildContext context) async {
  if (_loadingCompleter != null && !_loadingCompleter!.isCompleted) {
    _loadingCompleter!.complete();
    if (_loadingNavigator != null && _loadingNavigator!.canPop()) {
      _loadingNavigator!.pop();
    }
  }
}

loading() {
  return SizedBox(
    height: 40,
    width: 40,
    child: Image.asset('assets/loading.gif'),
  );
}
