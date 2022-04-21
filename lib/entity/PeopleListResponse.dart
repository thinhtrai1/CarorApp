import 'package:caror/entity/People.dart';

class PeopleListResponse {
  final List<People> data;
  final String? message;

  PeopleListResponse(this.data, this.message);

  factory PeopleListResponse.fromJson(Map<String, dynamic> json) {
    return PeopleListResponse(
      (json['data'] as List).map((e) => People.fromJson(e)).toList(),
      json['message'],
    );
  }
}
