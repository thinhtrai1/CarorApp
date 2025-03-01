import 'package:caror/data/shared_preferences.dart';
import 'package:caror/resources/generated/l10n.dart';
import 'package:caror/widget/progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class App {
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

Route createAnimateRoute(BuildContext parentContext, Widget page) {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final windowSize = MediaQuery.of(parentContext).size;
      final box = parentContext.findRenderObject() as RenderBox;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      final relativeRect = RelativeRect.fromSize(rect, windowSize);
      final tween = RelativeRectTween(begin: relativeRect, end: RelativeRect.fill);
      final rectAnimation = tween.chain(CurveTween(curve: Curves.ease)).animate(animation);
      return Stack(
        children: [
          PositionedTransition(rect: rectAnimation, child: child),
        ],
      );
    },
  );
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
      return WillPopScope(
        onWillPop: () async => false,
        child: Center(
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
                const CustomProgressBar(color: Colors.black, size: 32, duration: Duration(milliseconds: 500)),
                const SizedBox(width: 8),
                Text(
                  message ?? S.current.loading,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

const shimmerItemCount = 5;
const colorShimmer = Color(0xFFd5d5d5);
const colorShadow = Color(0xFFE8E8E8);
const colorLight = Color(0xFF888888);

DateFormat get dateFormat => DateFormat(S.current.date_format, AppPreferences.getLanguageCode());

String getLanguageName(String code) {
  switch (code) {
    case 'vi':
      return 'Việt Nam';
    case 'ja':
      return '日本';
    case 'zh':
      return '中文';
    default:
      return 'English';
  }
}
