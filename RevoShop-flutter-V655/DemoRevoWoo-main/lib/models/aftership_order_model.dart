class AftershipOrder {
  String? trackingId;
  String? trackingNumber;
  String? slug;
  AdditionalFields? additionalFields;
  List<LineItems>? lineItems;
  Metrics? metrics;

  AftershipOrder(
      {this.trackingId,
      this.trackingNumber,
      this.slug,
      this.additionalFields,
      this.lineItems,
      this.metrics});

  AftershipOrder.fromJson(Map<dynamic, dynamic> json) {
    trackingId = json['tracking_id'];
    trackingNumber = json['tracking_number'];
    slug = json['slug'];
    additionalFields = json['additional_fields'] != null
        ? new AdditionalFields.fromJson(json['additional_fields'])
        : null;
    if (json['line_items'] != null) {
      lineItems = <LineItems>[];
      json['line_items'].forEach((v) {
        lineItems!.add(new LineItems.fromJson(v));
      });
    }
    metrics =
        json['metrics'] != null ? new Metrics.fromJson(json['metrics']) : null;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['tracking_id'] = this.trackingId;
    data['tracking_number'] = this.trackingNumber;
    data['slug'] = this.slug;
    if (this.additionalFields != null) {
      data['additional_fields'] = this.additionalFields!.toJson();
    }
    if (this.lineItems != null) {
      data['line_items'] = this.lineItems!.map((v) => v.toJson()).toList();
    }
    if (this.metrics != null) {
      data['metrics'] = this.metrics!.toJson();
    }
    return data;
  }
}

class AdditionalFields {
  String? accountNumber;
  String? key;
  String? postalCode;
  String? shipDate;
  String? destinationCountry;
  String? state;

  AdditionalFields(
      {this.accountNumber,
      this.key,
      this.postalCode,
      this.shipDate,
      this.destinationCountry,
      this.state});

  AdditionalFields.fromJson(Map<dynamic, dynamic> json) {
    accountNumber = json['account_number'];
    key = json['key'];
    postalCode = json['postal_code'];
    shipDate = json['ship_date'];
    destinationCountry = json['destination_country'];
    state = json['state'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['account_number'] = this.accountNumber;
    data['key'] = this.key;
    data['postal_code'] = this.postalCode;
    data['ship_date'] = this.shipDate;
    data['destination_country'] = this.destinationCountry;
    data['state'] = this.state;
    return data;
  }
}

class LineItems {
  int? id;
  int? quantity;

  LineItems({this.id, this.quantity});

  LineItems.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    quantity = json['quantity'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['id'] = this.id;
    data['quantity'] = this.quantity;
    return data;
  }
}

class Metrics {
  String? createdAt;
  String? updatedAt;

  Metrics({this.createdAt, this.updatedAt});

  Metrics.fromJson(Map<dynamic, dynamic> json) {
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
