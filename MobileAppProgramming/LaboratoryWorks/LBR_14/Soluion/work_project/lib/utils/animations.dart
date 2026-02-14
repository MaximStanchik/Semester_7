import 'dart:math' as math;

import 'package:flutter/material.dart';

class SinInCurve extends Curve {
  const SinInCurve();

  @override
  double transformInternal(double t) {
    return math.sin(t * math.pi / 2);
  }
}

Route<T> buildSlideFadeRoute<T>({
  required WidgetBuilder builder,
  Offset begin = const Offset(0.10, 0),
  Curve curve = const SinInCurve(),
  Duration duration = const Duration(milliseconds: 420),
  Duration reverseDuration = const Duration(milliseconds: 360),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: curve);
      final offsetAnimation = Tween<Offset>(begin: begin, end: Offset.zero).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: offsetAnimation, child: child),
      );
    },
  );
}

Route<T> buildSlideUpFadeRoute<T>({
  required WidgetBuilder builder,
  double beginY = 0.14,
  Curve curve = const SinInCurve(),
  Duration duration = const Duration(milliseconds: 420),
  Duration reverseDuration = const Duration(milliseconds: 360),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: curve);
      final offsetAnimation = Tween<Offset>(begin: Offset(0, beginY), end: Offset.zero).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: offsetAnimation, child: child),
      );
    },
  );
}

Route<T> buildScaleFadeRoute<T>({
  required WidgetBuilder builder,
  Curve curve = const SinInCurve(),
  Duration duration = const Duration(milliseconds: 420),
  Duration reverseDuration = const Duration(milliseconds: 360),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: curve);
      final scale = Tween<double>(begin: 0.94, end: 1.0).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}
