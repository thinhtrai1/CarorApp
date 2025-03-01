class CommonListResponse<T> {
  final List<T> data;
  final bool isLoadMore;

  CommonListResponse(this.data, this.isLoadMore);

  factory CommonListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) converter,
  ) {
    return CommonListResponse(
      (json['items'] as List).map(converter).toList(),
      json['has_next'],
    );
  }
}
