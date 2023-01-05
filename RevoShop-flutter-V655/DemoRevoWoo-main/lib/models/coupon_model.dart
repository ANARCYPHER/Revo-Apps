class CouponModel {
  int? id;
  String? code, amount, discountType, description, minAmount, maxAmount;
  dynamic dateCreated, dateModified, dateExpires;
  bool? excludeSaleItems;
  List<int>? productCategories;
  List<int>? excProductCategories;
  int? discountAmount;

  CouponModel(
      {this.id,
      this.code,
      this.amount,
      this.dateCreated,
      this.dateModified,
      this.discountType,
      this.description,
      this.dateExpires,
      this.minAmount,
      this.maxAmount,
      this.excludeSaleItems,
      this.productCategories,
      this.excProductCategories,
      this.discountAmount});

  Map toJson() => {
        'id': id,
        'code': code,
        'amount': amount,
        'date_created': dateCreated,
        'date_modified': dateModified,
        'discount_type': discountType,
        'description': description,
        'date_expires': dateExpires,
        'min_amount': minAmount,
        'max_amount': maxAmount,
        'exclude_sale_items': excludeSaleItems,
        'product_categories': productCategories,
        'excluded_product_categories': excProductCategories,
        'discount_amount': discountAmount
      };

  CouponModel.fromJson(Map json) {
    id = json['id'];
    code = json['code'];
    amount = json['amount'];
    dateCreated = json['date_created'];
    dateModified = json['date_modified'];
    discountType = json['discount_type'];
    description = json['description'];
    if (json['date_expires'] != null) {
      dateExpires = json['date_expires']['date'];
    }
    minAmount = json['min_amount'];
    maxAmount = json['max_amount'];
    excludeSaleItems = json['exclude_sale_items'];
    discountAmount = json['discount_amount'];
    if (json['product_categories'] != null) {
      productCategories = [];
      for (var item in json['product_categories']) {
        productCategories!.add(item);
      }
    }
    if (json['excluded_product_categories'] != null) {
      excProductCategories = [];
      for (var item in json['excluded_product_categories']) {
        excProductCategories!.add(item);
      }
    }
  }

  @override
  String toString() {
    return 'CouponModel{id: $id, code: $code, amount: $amount, dateCreated: $dateCreated, dateModified: $dateModified, discountType: $discountType, description: $description, dateExpires: $dateExpires, minAmount: $minAmount, maxAmount: $maxAmount}';
  }
}

class SearchCouponModel {
  int? id;
  int? quantity;
  int? variationId;

  SearchCouponModel({this.id, this.quantity, this.variationId});

  Map toJson() => {'id': id, 'quantity': quantity, 'variation_id': variationId};
}
