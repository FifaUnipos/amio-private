import 'dart:async';


import 'package:flutter/material.dart';
import '../component/component_color.dart';

Completer<void> loadingCompleter = Completer<void>();

void whenLoading(context) {
  showDialog(
    barrierDismissible: false,
    useRootNavigator: true,
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Builder(
        builder: (BuildContext context) {
          loadingCompleter = Completer<void>();
          Future.delayed(Duration(seconds: 5), () {
            if (!loadingCompleter.isCompleted) {
              closeLoading(context);
            }
          });
          return Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: primary500,
              ),
            ),
          );
        },
      ),
    ),
  );
}

Future<void> closeLoading(context) async {
  if (!loadingCompleter.isCompleted) {
    Navigator.of(context, rootNavigator: true).pop();
    loadingCompleter.complete();
  }
}

loading() {
  return SizedBox(
    height: 40,
    width: 40,
    child: Image.asset('assets/loading.gif'),
  );
}
