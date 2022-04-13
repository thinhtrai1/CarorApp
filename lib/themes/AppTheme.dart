import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppTheme {
  static const primaryColor = Color(0xFF363636);
  static const primarySwatch = MaterialColor(
    0xFF232323,
    <int, Color>{
      50: Color(0xFFFAFAFA),
      100: Color(0xFFF5F5F5),
      200: Color(0xFFEEEEEE),
      300: Color(0xFFE0E0E0),
      350: Color(0xFFD6D6D6),
      // only for raised button while pressed in light theme
      400: Color(0xFFBDBDBD),
      500: Color(0xFF363636),
      600: Color(0xFF757575),
      700: Color(0xFF616161),
      800: Color(0xFF424242),
      850: Color(0xFF303030),
      // only for background color in dark theme
      900: Color(0xFF212121),
    },
  );
}



Route createRoute(Widget widget) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => widget,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.ease));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

void toast(String? msg) {
  Fluttertoast.showToast(msg: msg.toString(),);
}