import 'product.dart';

class ProductResponse {
  final Product? data;
  final String? message;

  ProductResponse(this.data, this.message);

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ProductResponse(
      data != null ? Product.fromJson(data) : null,
      json['message'],
    );
  }
}
