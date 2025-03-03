import 'package:caror/resources/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._();

  static late final SharedPreferences _instance;

  static init() async => _instance = await SharedPreferences.getInstance();

  static String? _getString(String key, {String? defValue}) => _instance.getString(key) ?? defValue;

  static Future<bool> _setString(String key, String value) async => _instance.setString(key, value);

  static setAccessToken(String token) => _setString('pref_token', token);

  static getAccessToken() => _getString('pref_token');

  static setUsername(String token) => _setString('pref_username', token);

  static getUsername() => _getString('pref_username');

  static setPassword(String token) => _setString('pref_password', token);

  static getPassword() => _getString('pref_password');

  static setUserInfo(String userJson) => _setString('pref_user_info', userJson);

  static getUserInfo() => _getString('pref_user_info');

  static void addToCart(int id, int count) {
    final cart = getCart();
    for (var i = 0; i < count.abs(); i++) {
      if (count > 0) {
        cart.add(id.toString());
      } else {
        cart.remove(id.toString());
      }
    }
    _instance.setStringList('pref_cart', cart);
  }

  static List<String> getCart() => _instance.getStringList('pref_cart') ?? [];

  static setLanguageCode(String code) => _setString('pref_language_code', code);

  static getLanguageCode() =>
      _getString('pref_language_code') ?? S.delegate.supportedLocales.first.languageCode;

  static logout() {
    _instance.remove('pref_token');
    _instance.remove('pref_username');
    _instance.remove('pref_password');
    _instance.remove('pref_user_info');
    _instance.remove('pref_cart');
  }
}
