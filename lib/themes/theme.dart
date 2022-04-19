import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class App {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const ask = 'com.app.caror.caror.MainActivity';
}

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
  return CupertinoPageRoute(builder: (_) => widget);
}

void showToast(String? msg) {
  if (msg != null) {
    Fluttertoast.showToast(
      msg: msg,
    );
  }
}

void showLoading(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black26,
    builder: (BuildContext context) {
      return Center(
        child: Container(
          height: 48,
          padding: const EdgeInsets.only(left: 12, right: 24),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(24)),
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SpinKitFadingCircle(color: Colors.black, size: 32, duration: Duration(milliseconds: 500)),
              const SizedBox(width: 8),
              Text(
                message ?? 'Loading...',
                style: const TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: 14,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

const shimmerItemCount = 5;
const colorShimmer = Color(0xFFd5d5d5);
const colorShadow = Color(0xFFE8E8E8);
const colorDark = Color(0xFF444444);
const colorLight = Color(0xFF888888);

final dateFormat = DateFormat('MMMM dd \'at\' hh:mm', 'en_US');
