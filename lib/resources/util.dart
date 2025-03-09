import 'dart:developer' as dev;
import 'package:caror/data/data_service.dart';
import 'package:caror/entity/product.dart';
import 'package:caror/resources/generated/l10n.dart';
import 'package:encrypt/encrypt.dart' as e;
import 'package:share_plus/share_plus.dart';

class Util {
  Util._();

  static const ask = 'com.app.caror.**';

  static String encrypt(data) {
    final key = e.Key.fromUtf8(ask);
    final iv = e.IV.fromUtf8(ask);
    final encrypter = e.Encrypter(e.AES(key));
    return encrypter.encrypt(data.toString(), iv: iv).base64;
  }

  static String? decrypt(String data) {
    try {
      final key = e.Key.fromUtf8(ask);
      final iv = e.IV.fromUtf8(ask);
      final encrypter = e.Encrypter(e.AES(key));
      return encrypter.decrypt(e.Encrypted.fromBase64(data), iv: iv);
    } catch (e) {
      log('Decrypt QR Code: $e', error: true);
    }
    return null;
  }

  static shareProduct(Product product) {
    final shareUrl = DataService.getFullUrl('share/${Util.encrypt(product.id)}');
    Share.share('${product.name}\n\n${S.current.visit_caror_to_enjoy_now}\n$shareUrl');
  }

  static void log(Object? message, {bool error = false}) {
    dev.log('${error ? '🔴' : '🟣'}$message', name: 'Caror');
    // debugPrint('${error ? '\x1B[31m' : '\x1B[36m'} $message\x1B[0m', wrapWidth: 256);
  }

  static bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }
}
