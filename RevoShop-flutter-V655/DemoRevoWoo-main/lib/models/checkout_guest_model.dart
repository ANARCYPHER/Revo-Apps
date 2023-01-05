class CheckoutGuest {
  int? orderId;
  String? url, createdAt;

  CheckoutGuest({this.orderId, this.url, this.createdAt});

  Map toJson() => {
    'order_id': orderId,
    'url': url,
    'created_at': createdAt,
  };

  CheckoutGuest.fromJson(Map json) {
    orderId = json['order_id'];
    url = json['url'];
    createdAt = json['created_at'];
  }
}