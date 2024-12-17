import 'package:flutter/material.dart';

class FadePageTransition<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageTransition({required this.page})
      : super(
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, 0.1), // Slide up slightly
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
  );
}
