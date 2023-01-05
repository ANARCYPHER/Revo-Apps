class LineItems {
  int? productId, quantity, variationId;

  LineItems({this.productId, this.quantity, this.variationId});

  Map toJson() => {
        'product_id': productId,
        'quantity': quantity,
        'variation_id': variationId
      };

  LineItems.fromJson(Map json) {
    productId = json['product_id'];
    quantity = json['quantity'];
    variationId = json['variation_id'];
  }
}
