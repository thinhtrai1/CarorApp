import 'dart:developer' as dev;

class Util {
  Util._();

  static void log(Object? message, {bool error = false}) {
    dev.log('${error ? '🔴' : '🟣'}$message', name: 'Caror');
    // debugPrint('${error ? '\x1B[31m' : '\x1B[36m'} $message\x1B[0m', wrapWidth: 256);
  }

  static bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }
}
