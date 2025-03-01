import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:caror/data/shared_preferences.dart';
import 'package:caror/entity/people.dart';
import 'package:caror/entity/product.dart';
import 'package:caror/entity/common_list_response.dart';
import 'package:caror/entity/user.dart';
import 'package:caror/resources/generated/l10n.dart';
import 'package:caror/resources/theme.dart';
import 'package:caror/resources/util.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DataService {
  const DataService._();

  static String baseUrl = 'https://nguyenducthinh-springboot.appspot.com/';

  static String getFullUrl(String path) => '$baseUrl$path';

  static Uri _getApiUrl(String path) => Uri.parse('${baseUrl}api/$path');

  static String _pretty(dynamic json) {
    return const JsonEncoder.withIndent('    ').convert(json);
  }

  static Future<T?> _getResponse<T>({
    required String path,
    bool post = false,
    bool formUrlencoded = false,
    Object? body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? converter,
  }) async {
    String message;
    final url = _getApiUrl(path).replace(queryParameters: queryParameters);

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
        final b = body == null ? '' : '\n${_pretty(body)}';
        Util.log('Request ${post ? 'POST' : 'GET'}: $url$b');
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (kDebugMode) {
          Util.log('======> ${response.statusCode}:\n${_pretty(data)}');
        }
        return converter?.call(data['data']);
      } else {
        if (kDebugMode) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          Util.log(
            '======> Error: ${response.statusCode} ${response.reasonPhrase}:\n${_pretty(data)}',
            error: true,
          );
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
        Util.log('Request ${post ? 'POST' : 'GET'}: $url$b');
        Util.log('======> Error: $e', error: true);
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

  static Future<CommonListResponse<T>?> _getResponseList<T>({
    required String path,
    bool post = false,
    bool formUrlencoded = false,
    Object? body,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) converter,
  }) {
    return _getResponse(
      path: path,
      post: post,
      formUrlencoded: formUrlencoded,
      body: body,
      queryParameters: queryParameters,
      converter: (p0) => CommonListResponse.fromJson(p0, converter),
    );
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
      converter: User.fromJson,
    );
    return response;
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
      converter: User.fromJson,
    );
    return response;
  }

  static Future<CommonListResponse<Product>?> getProducts(int page) async {
    final response = await _getResponseList(
      path: 'product/$page',
      converter: Product.fromJson,
    );
    return response;
  }

  static Future<CommonListResponse<Product>?> getProductsByIds(int page, List<int> ids) async {
    final response = await _getResponseList(
      path: 'product/$page',
      queryParameters: {'ids': ids.join(',')},
      converter: Product.fromJson,
    );
    return response;
  }

  static Future<Product?> getProductDetail(String id) async {
    final response = await _getResponse(
      path: 'product?id=$id',
      converter: Product.fromJson,
    );
    return response;
  }

  static Future<List<People>?> getPeoples() async {
    final response = await _getResponse(
      path: 'peoples',
      converter: (p0) => (p0 as List).map(People.fromJson).toList(),
    );
    return response;
  }
}
