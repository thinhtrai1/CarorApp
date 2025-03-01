class Product {
  final int id;
  final String name;
  final int price;
  final String image;
  final String thumbnail;
  final double rate;
  final String description;
  final int shopId;
  final String shopName;
  final int addedAt;
  int qty = 0;

  Product(
    this.id,
    this.name,
    this.price,
    this.image,
    this.thumbnail,
    this.rate,
    this.description,
    this.shopId,
    this.shopName,
    this.addedAt,
  );

  factory Product.fromJson(dynamic json) {
    return Product(
      json['id'],
      json['name'],
      json['price'],
      json['image'],
      json['thumbnail'],
      json['rate'],
      json['description'],
      json['shopId'],
      json['shopName'],
      json['addedAt'],
    );
  }
}
