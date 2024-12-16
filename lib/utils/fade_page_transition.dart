import 'package:flutter/material.dart';

class FadePageTransition<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageTransition({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
