import 'product.dart';

class ProductListResponse {
  final List<Product> data;
  final String? message;
  final bool isLoadMore;

  ProductListResponse(this.data, this.message, this.isLoadMore);

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      (json['data'] as List).map((e) => Product.fromJson(e)).toList(),
      json['message'],
      json['isLoadMore'],
    );
  }
}
