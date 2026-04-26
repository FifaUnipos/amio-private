import 'package:flutter/material.dart';

/// Wrapper widget yang otomatis melepas fokus keyboard/textfield
/// ketika user mengetuk area di luar textfield manapun.
///
/// Cara pakai:
/// ```dart
/// Scaffold(
///   body: TapToUnfocus(
///     child: YourPageContent(),
///   ),
/// )
/// ```
class TapToUnfocus extends StatelessWidget {
  const TapToUnfocus({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}
