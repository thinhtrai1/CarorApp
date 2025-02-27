import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:caror/data/shared_preferences.dart';
import 'package:caror/entity/login_response.dart';
import 'package:caror/entity/product_list_response.dart';
import 'package:caror/entity/product_response.dart';
import 'package:caror/entity/user.dart';
import 'package:caror/entity/people_list_response.dart';
import 'package:caror/generated/l10n.dart';
import 'package:caror/themes/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DataService {
  static String baseUrl = 'https://nguyenducthinh-springboot.appspot.com/';

  static String getFullUrl(String path) => '$baseUrl$path';

  static _getApiUrl(String path) => Uri.parse('${baseUrl}api/$path');

  static Future<T?> _getResponse<T>({
    required String path,
    bool post = false,
    bool formUrlencoded = false,
    Object? body,
    T? Function(Map<String, dynamic>)? converter,
  }) async {
    String message;
    final url = _getApiUrl(path);

    try {
      final accessToken = AppPreferences.getAccessToken();
      final headers = {
        "Content-Type": post && formUrlencoded
            ? 'application/x-www-form-urlencoded'
            : 'application/json; charset=UTF-8',
        if (accessToken != null) "Authorization": 'Bearer $accessToken',
      };
      final response = post
          ? await http.post(url, headers: headers, body: body)
          : await http.get(url, headers: headers);
      if (kDebugMode) {
        final b = !post || body == null ? '' : '\n${_pretty(body)}';
        _log('Request ${post ? 'POST' : 'GET'}: $url$b');
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (kDebugMode) {
          _log('======> ${response.statusCode}:\n${_pretty(data)}');
        }
        return converter?.call(data);
      } else {
        if (kDebugMode) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          _log('======> Error: ${response.statusCode} ${response.reasonPhrase}:\n${_pretty(data)}');
        }
        if (response.statusCode > 499 && response.statusCode < 512) {
          message = S.current.server_error;
        } else {
          message = S.current.an_error_occurred;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        final b = !post || body == null ? '' : '\n${_pretty(body)}';
        _log('Request ${post ? 'POST' : 'GET'}: $url$b');
        _log('======> Error: $e');
      }
      if (e is SocketException || e is TimeoutException) {
        message = S.current.network_error;
      } else {
        message = S.current.an_error_occurred;
      }
    }
    showToast(message);
    return null;
  }

  static _log(String message) {
    log(message);
  }

  static String _pretty(dynamic json) {
    return const JsonEncoder.withIndent('    ').convert(json);
  }

  static Future<User?> login(String username, String password) async {
    final response = await _getResponse(
      path: 'user/login',
      post: true,
      formUrlencoded: true,
      body: {
        'username': username,
        'password': password,
      },
      converter: LoginResponse.fromJson,
    );
    return response?.data;
  }

  static Future<User?> register(
    String username,
    String password,
    String email,
    String firstname,
    String lastname,
  ) async {
    final response = await _getResponse(
      path: 'user/register',
      post: true,
      formUrlencoded: true,
      body: {
        'username': username,
        'password': password,
        'email': email,
        'firstname': firstname,
        'lastname': lastname,
      },
      converter: LoginResponse.fromJson,
    );
    return response?.data;
  }

  static Future<ProductListResponse?> getProducts(int page) async {
    final response = await _getResponse(
      path: 'product/$page',
      converter: ProductListResponse.fromJson,
    );
    return response;
  }

  static Future<ProductResponse?> getProductDetail(String id) async {
    final response = await _getResponse(
      path: 'product?id=$id',
      converter: ProductResponse.fromJson,
    );
    return response;
  }

  static Future<PeopleListResponse?> getPeoples() async {
    final response = await _getResponse(
      path: 'peoples',
      converter: PeopleListResponse.fromJson,
    );
    return response;
  }
}
