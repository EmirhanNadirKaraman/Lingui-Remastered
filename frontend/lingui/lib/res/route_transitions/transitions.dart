import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class RouteTransitions {
  static Route<T> fadeTranistion<T>(
      BuildContext context, Widget child, CustomPage<T> page) {
    return PageRouteBuilder(
        settings: page,
        fullscreenDialog: page.fullscreenDialog,
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        pageBuilder: ((context, animation, secondaryAnimation) {
          return child;
        }));
  }
}
