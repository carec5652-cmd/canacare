import 'package:flutter/material.dart';

// Custom Page Transitions - انتقالات مخصصة بين الصفحات

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;

  SlideRightRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      );
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;

  FadeRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
}

class ScaleRoute extends PageRouteBuilder {
  final Widget page;

  ScaleRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOutCubic;

          var scaleTween = Tween<double>(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve));

          var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

          return ScaleTransition(
            scale: animation.drive(scaleTween),
            child: FadeTransition(opacity: animation.drive(fadeTween), child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      );
}

class SlideUpRoute extends PageRouteBuilder {
  final Widget page;

  SlideUpRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      );
}

// Helper to navigate with custom transition
class NavigationHelper {
  static Future<T?> slideRight<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(SlideRightRoute(page: page) as Route<T>);
  }

  static Future<T?> fade<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(FadeRoute(page: page) as Route<T>);
  }

  static Future<T?> scale<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(ScaleRoute(page: page) as Route<T>);
  }

  static Future<T?> slideUp<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(SlideUpRoute(page: page) as Route<T>);
  }
}
