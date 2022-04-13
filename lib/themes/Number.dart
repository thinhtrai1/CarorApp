import 'package:intl/intl.dart';


class NumberUtil {
  static final NumberFormat _format = NumberFormat("#,###.##", "en_US");

  static String priceFormat(num n) {
    return _format.format(n) + 'đ';
  }
}