import 'product.dart';

class ProductListResponse {
  final List<Product> data;
  final String? message;
  final bool isLoadMore;

  ProductListResponse(this.data, this.message, this.isLoadMore);

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ProductListResponse(
      (data['items'] as List).map((e) => Product.fromJson(e)).toList(),
      data['message'],
      data['has_next'],
    );
  }
}
