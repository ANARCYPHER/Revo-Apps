import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class VariationModel {
  int? id, stockQuantity;
  String? price, regularPrice, salePrice;
  List<AttributeModel>? attributes = [];

  VariationModel(
      {this.id,
      this.stockQuantity,
      this.price,
      this.regularPrice,
      this.salePrice,
      this.attributes});

  Map toJson() => {
        'id': id,
        'stock_quantity': stockQuantity,
        'price': price,
        'regular_price': regularPrice,
        'sale_price': salePrice,
        'attributes': attributes,
      };

  VariationModel.fromJson(Map json) {
    id = json['id'];
    stockQuantity = json['stock_quantity'];
    price = json['price'];
    regularPrice = json['regular_price'];
    salePrice = json['sale_price'];
    if (json['meta_data'] != null) {
      json['meta_data'].forEach((v) {
        if (v['key'] == 'wholesale_customer_wholesale_price' &&
            v['value'].isNotEmpty &&
            Session.data.getString('role') == 'wholesale_customer') {
          price = v['value'];
          printLog(price!, name: 'Price Wholesale');
        }
      });
    }
  }
}

class AttributeModel {
  int? id;
  String? name, options;

  AttributeModel({this.id, this.name, this.options});

  Map toJson() => {
        'id': id,
        'name': name,
        'options': options,
      };

  AttributeModel.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        options = json['options'];
}
