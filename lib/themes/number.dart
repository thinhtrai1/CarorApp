import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Number {
  static final NumberFormat _format = NumberFormat("#,###.##", "en_US");

  static String priceFormat(num n) {
    return _format.format(n) + ' đ';
  }

  static double getScreenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  static double getStatusBarHeight(BuildContext context) => MediaQuery.of(context).viewPadding.top;
}
