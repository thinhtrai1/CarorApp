import 'dart:math';

class Product {
  final int id;
  final String name;
  final int price;
  final String thumbnail;
  final double rate;
  final String description;
  final int shopId;
  final String shopName;
  final int addedAt;

  Product(this.id, this.name, this.price, this.thumbnail, this.rate, this.description, this.shopId, this.shopName, this.addedAt);

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      json['id'],
      json['name'],
      json['price'],
      // json['thumbnail'],
      _images[_random.nextInt(_images.length)],
      json['rate'],
      json['description'],
      json['shopId'],
      json['shopName'],
      json['addedAt'],
    );
  }
}

final _random = Random();
final _images = [
  'https://vnn-imgs-a1.vgcloud.vn/static.cand.com.vn/Files/Image/hientk/2019/09/28/thumb_660_a5b95b44-b5d7-4891-aacb-bc1fe8484d27.jpg',
  'https://tinbanxe.vn/uploads/car/mceu_11313383821631098564856.jpg',
  'https://s1.cdn.autoevolution.com/images/models/MERCEDES-BENZ_C-Class-2021_main.jpg',
  'https://cdn.motor1.com/images/mgl/bqxR3/s1/live-photos-of-mercedes-eqg-concept-from-iaa-2021.webp'
];
