import 'dart:convert';

import 'package:caror/data/shared_preferences.dart';
import 'package:caror/entity/LoginResponse.dart';
import 'package:caror/entity/ProductListResponse.dart';
import 'package:caror/entity/ProductResponse.dart';
import 'package:caror/entity/User.dart';
import 'package:caror/entity/PeopleListResponse.dart';
import 'package:caror/generated/l10n.dart';
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
    String message;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return converter.call(jsonDecode(utf8.decode(response.bodyBytes)));
      } on Exception catch (_) {
        message = S.current.an_error_occurred;
      } catch (_) {
        message = S.current.an_error_occurred;
      }
    }
    if (response.statusCode > 499 && response.statusCode < 512) {
      message = S.current.server_error;
    } else {
      message = S.current.an_error_occurred;
    }
    showToast(message);
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
    return _getResponse(response, LoginResponse.fromJson)?.data;
  }

  static Future<User?> register(String username, String password, String email, String firstname, String lastname) async {
    final response = await http.post(
      _getApiUrl('user/register'),
      headers: _getHeader(type: 'application/x-www-form-urlencoded'),
      body: {
        'username': username,
        'password': password,
        'email': email,
        'firstname': firstname,
        'lastname': lastname,
      },
    );
    return _getResponse(response, LoginResponse.fromJson)?.data;
  }

  static Future<ProductListResponse?> getProducts(int page) async {
    final response = await http.get(
      _getApiUrl('product/$page'),
      headers: _getHeader(),
    );
    return _getResponse(response, ProductListResponse.fromJson);
  }

  static Future<ProductResponse?> getProductDetail(String id) async {
    final response = await http.get(
      _getApiUrl('product?id=$id'),
      headers: _getHeader(),
    );
    return _getResponse(response, ProductResponse.fromJson);
  }

  static Future<PeopleListResponse?> getPeoples() async {
    final response = await http.get(
      _getApiUrl('peoples'),
      headers: _getHeader(),
    );
    return _getResponse(response, PeopleListResponse.fromJson);
  }
}
