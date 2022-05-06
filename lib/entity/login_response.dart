import 'user.dart';

class LoginResponse {
  final String? message;
  final User? data;

  LoginResponse(this.message, this.data) : super();

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return LoginResponse(
      json['message'],
      data != null ? User.fromJson(data) : null,
    );
  }
}
