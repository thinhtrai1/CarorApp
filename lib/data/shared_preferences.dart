import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static late final SharedPreferences _instance;

  static Future<SharedPreferences> init() async => _instance = await SharedPreferences.getInstance();

  static String? _getString(String key, {String? defValue}) => _instance.getString(key) ?? defValue;

  static Future<bool> _setString(String key, String value) async => _instance.setString(key, value);

  static setAccessToken(String token) => _setString('pref_token', token);

  static getAccessToken() => _getString('pref_token');
}
