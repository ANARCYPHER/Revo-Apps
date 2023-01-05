import 'package:nyoba/models/product_model.dart';

class FlashSaleHomeModel {
  // Model
  int? id;
  String? title;
  String? startDate;
  String? endDate;
  String? image;
  List<ProductModel>? products;

  FlashSaleHomeModel(
      {this.id,
      this.title,
      this.image,
      this.startDate,
      this.endDate,
      this.products});

  Map toJson() => {
        'id': id,
        'title': title,
        'start': startDate,
        'end': endDate,
        'image': image,
        'products': products
      };

  FlashSaleHomeModel.fromJson(Map json) {
    id = json['id'];
    title = json['title'];
    startDate = json['start'];
    endDate = json['end'];
    image = json['image'];
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products!.add(new ProductModel.fromJson(v));
      });
    }
  }

  @override
  String toString() {
    return 'FlashSaleHomeModel{id: $id, title: $title, startDate: $startDate, endDate: $endDate, image: $image, products: $products}';
  }
}

class ProductExtendHomeModel {
  // Model
  String? title;
  String? description;
  List<ProductModel>? products;

  ProductExtendHomeModel({this.title, this.description, this.products});

  Map toJson() =>
      {'title': title, 'description': description, 'products': products};

  ProductExtendHomeModel.fromJson(Map json) {
    description = json['description'];
    title = json['title'];
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products!.add(new ProductModel.fromJson(v));
      });
    }
  }
}
