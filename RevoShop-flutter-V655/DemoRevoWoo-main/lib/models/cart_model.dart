import 'package:nyoba/services/session.dart';

class CartModel {
  // Model
  int? customerId;
  String? paymentMethod;
  String? paymentMethodTitle;
  bool? setPaid;
  String? status;
  String? token;
  List<CartProductItem>? listItem = [];
  List<CartCoupon>? listCoupon = [];
  String? lang = Session.data.getString("language_code");

  CartModel(
      {this.customerId,
      this.paymentMethod,
      this.paymentMethodTitle,
      this.setPaid,
      this.status,
      this.token,
      this.listItem,
      this.listCoupon,
      this.lang});

  Map toJson() => {
        'payment_method': paymentMethod,
        'payment_method_title': paymentMethodTitle,
        'set_paid': setPaid,
        'customer_id': customerId,
        'status': status,
        'token': token,
        'line_items': listItem,
        'coupon_lines': listCoupon,
        'lang': lang
      };
}

class CartProductItem {
  final int? productId;
  final int? quantity;
  final int? variationId;
  List<dynamic>? variation = [];

  CartProductItem(
      {this.productId, this.quantity, this.variationId, this.variation});

  Map toJson() => {
        'product_id': productId,
        'quantity': quantity,
        'variation_id': variationId,
        'variation': variation
      };
}

class CartCoupon {
  final String? code;

  CartCoupon({this.code});

  Map toJson() => {
        'code': code,
      };
}
