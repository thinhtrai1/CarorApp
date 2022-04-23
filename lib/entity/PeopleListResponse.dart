import 'package:caror/entity/People.dart';

class PeopleListResponse {
  final List<People> data;
  final String? message;
  final bool isLoadMore;

  PeopleListResponse(this.data, this.message, this.isLoadMore);

  factory PeopleListResponse.fromJson(Map<String, dynamic> json) {
    return PeopleListResponse(
      (json['data'] as List).map((e) => People.fromJson(e)).toList(),
      json['message'],
      json['isLoadMore'],
    );
  }
}
