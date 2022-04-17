import 'dart:convert';

import 'package:caror/data/shared_preferences.dart';
import 'package:caror/entity/LoginResponse.dart';
import 'package:caror/entity/ProductListResponse.dart';
import 'package:caror/entity/User.dart';
import 'package:caror/themes/theme.dart';
import 'package:http/http.dart' as http;

class DataService {
  static String baseUrl = 'https://nguyenducthinh.herokuapp.com';

  static String getFullUrl(String path) => '$baseUrl$path';

  static _getApiUrl(String path) => Uri.parse('$baseUrl/api/$path');

  static _getHeader({String type = 'application/json; charset=UTF-8'}) {
    final String? accessToken = AppPreferences.getAccessToken();
    return {
      "Content-Type": type,
      if (accessToken != null) "Authorization": 'Bearer $accessToken',
    };
  }

  static T? _getResponse<T>(http.Response response, T? Function(Map<String, dynamic>) converter) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return converter.call(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      String message;
      if (response.statusCode > 499 && response.statusCode < 512) {
        message = 'Server error!';
      } else {
        message = 'An error occurred!';
      }
      toast(message);
    }
    return null;
  }

  static Future<User?> login(String username, String password) async {
    final response = await http.post(
      _getApiUrl('user/login'),
      headers: _getHeader(type: 'application/x-www-form-urlencoded'),
      body: {
        'username': username,
        'password': password,
      },
    );
    return _getResponse(response, (json) => LoginResponse.fromJson(json).data);
  }

  static Future<ProductListResponse?> getProducts(int page) async {
    final response = await http.get(
      _getApiUrl('product/$page'),
      headers: _getHeader(),
    );
    // await Future.delayed(Duration(seconds: 5));
    return _getResponse(response, (json) => ProductListResponse.fromJson(json));
  }
}
