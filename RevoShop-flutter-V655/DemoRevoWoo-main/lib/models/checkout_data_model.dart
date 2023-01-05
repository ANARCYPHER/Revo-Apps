class UserData {
  String? firstName,
      lastName,
      company,
      address1,
      address2,
      city,
      state,
      country,
      countryName,
      stateName,
      postcode,
      phone,
      email;

  UserData(
      {this.firstName,
      this.lastName,
      this.company,
      this.address1,
      this.address2,
      this.city,
      this.state,
      this.country,
      this.countryName,
      this.stateName,
      this.postcode,
      this.phone,
      this.email});

  Map toJson() => {
        'billing_first_name': firstName,
        "billing_last_name": lastName,
        "billing_company": company,
        "billing_country": country,
        "billing_country_name": countryName,
        "billing_address_1": address1,
        "billing_address_2": address2,
        "billing_city": city,
        "billing_state": state,
        "billing_state_name": stateName,
        "billing_postcode": postcode,
        "billing_phone": phone,
        "billing_email": email
      };

  UserData.fromJson(Map json) {
    firstName = json['billing_first_name'];
    lastName = json['billing_last_name'];
    company = json['billing_company'];
    country = json['billing_country'];
    countryName = json['billing_country_name'];
    address1 = json['billing_address_1'];
    address2 = json['billing_address_2'];
    city = json['billing_city'];
    state = json['billing_state'];
    stateName = json['billing_state_name'];
    postcode = json['billing_postcode'];
    phone = json['billing_phone'];
    email = json['billing_email'];
  }
}

class ShippingLine {
  String? methodId, methodTitle;
  num? cost;
  List<Couriers>? couriers = [];

  ShippingLine({this.methodId, this.methodTitle, this.cost, this.couriers});

  Map toJson() => {
        'method_id': methodId,
        'method_title': methodTitle,
        'cost': cost,
        'couriers': couriers
      };

  ShippingLine.fromJson(Map json) {
    methodId = json['method_id'];
    methodTitle = json['method_title'];
    cost = json['cost'];
    if (json['couriers'].isNotEmpty) {
      for (Map item in json['couriers']) {
        couriers?.add(Couriers.fromJson(item));
      }
    }
  }
}

class Couriers {
  String? courier, service, etd, currency, methodTitle;
  num? cost;
  Couriers(
      {this.courier,
      this.service,
      this.etd,
      this.cost,
      this.currency,
      this.methodTitle});

  Map toJson() => {
        "courier": courier,
        "service": service,
        "etd": etd,
        "cost": cost,
        "currency": currency,
        "method_title": methodTitle
      };

  Couriers.fromJson(Map json) {
    courier = json['courier'];
    service = json['service'];
    etd = json['etd'];
    cost = json['cost'];
    currency = json['currency'];
    methodTitle = json['method_title'];
  }
}

class LineItem {
  int? productId, qty, variantId;
  num? subtotal, weight;
  String? name, sku, price, image;
  dynamic variation;

  LineItem(
      {this.productId,
      this.qty,
      this.variantId,
      this.subtotal,
      this.weight,
      this.name,
      this.sku,
      this.price,
      this.image,
      this.variation});

  Map toJson() => {
        "product_id": productId,
        "name": name,
        "sku": sku,
        "price": price,
        "quantity": qty,
        "variation_id": variantId,
        "subtotal_order": subtotal,
        "image": image,
        "weight": weight,
        "variation": variation
      };

  LineItem.fromJson(Map json) {
    productId = json['product_id'];
    name = json['name'];
    sku = json['sku'];
    price = json['price'];
    qty = json['quantity'];
    variantId = json['variation_id'];
    subtotal = json['subtotal_order'];
    image = json['image'];
    weight = json['weight'];
    variation = json["variation"];
  }
}

class PaymentMethod {
  String? id, title, description;

  PaymentMethod({this.id, this.title, this.description});

  Map toJson() => {'id': id, 'title': title, 'description': description};

  PaymentMethod.fromJson(Map json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
  }
}

class PointsRedemption {
  int? point, totalDisc;
  String? discCoupon;

  PointsRedemption({this.point, this.totalDisc, this.discCoupon});

  Map toJson() => {
        'point_redemption': point,
        'total_discount': totalDisc,
        'discount_coupon': discCoupon
      };

  PointsRedemption.fromJson(Map json) {
    point = json['point_redemption'];
    totalDisc = json['total_discount'];
    discCoupon = json['discount_coupon'];
  }
}
