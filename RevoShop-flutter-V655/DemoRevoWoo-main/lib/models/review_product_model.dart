import 'package:nyoba/utils/utility.dart';

class ReviewProduct {
  int? id;
  String? dateCreated;
  String? dateCreatedGmt;
  int? productId;
  String? productName;
  String? productPermalink;
  String? status;
  String? reviewer;
  String? reviewerEmail;
  String? review;
  int? rating;
  bool? verified;
  ReviewerAvatarUrls? reviewerAvatarUrls;
  Links? lLinks;
  List<String>? image = [];

  ReviewProduct(
      {this.id,
      this.dateCreated,
      this.dateCreatedGmt,
      this.productId,
      this.productName,
      this.productPermalink,
      this.status,
      this.reviewer,
      this.reviewerEmail,
      this.review,
      this.rating,
      this.verified,
      this.reviewerAvatarUrls,
      this.lLinks,
      this.image});

  ReviewProduct.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    dateCreated = json['date_created'];
    dateCreatedGmt = json['date_created_gmt'];
    productId = json['product_id'];
    productName = json['product_name'];
    productPermalink = json['product_permalink'];
    status = json['status'];
    reviewer = json['reviewer'];
    reviewerEmail = json['reviewer_email'];
    review = json['review'];
    rating = json['rating'];
    verified = json['verified'];
    reviewerAvatarUrls = json['reviewer_avatar_urls'] != null
        ? new ReviewerAvatarUrls.fromJson(json['reviewer_avatar_urls'])
        : null;
    lLinks = json['_links'] != null ? new Links.fromJson(json['_links']) : null;
    if (json['image'] != null && json['image'] != "") {
      List<String> _image = [];
      printLog("IMAGE NOT NULL");
      json['image'].forEach((v) {
        _image.add(v);
        printLog("Add Image");
      });
      image = _image;
    }
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['id'] = this.id;
    data['date_created'] = this.dateCreated;
    data['date_created_gmt'] = this.dateCreatedGmt;
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    data['product_permalink'] = this.productPermalink;
    data['status'] = this.status;
    data['reviewer'] = this.reviewer;
    data['reviewer_email'] = this.reviewerEmail;
    data['review'] = this.review;
    data['rating'] = this.rating;
    data['verified'] = this.verified;
    if (this.reviewerAvatarUrls != null) {
      data['reviewer_avatar_urls'] = this.reviewerAvatarUrls!.toJson();
    }
    if (this.lLinks != null) {
      data['_links'] = this.lLinks!.toJson();
    }
    if (this.image != null) {
      data['image'] = this.image!;
    }
    return data;
  }
}

class ReviewerAvatarUrls {
  String? s24;
  String? s48;
  String? s96;

  ReviewerAvatarUrls({this.s24, this.s48, this.s96});

  ReviewerAvatarUrls.fromJson(Map<dynamic, dynamic> json) {
    s24 = json['24'];
    s48 = json['48'];
    s96 = json['96'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['24'] = this.s24;
    data['48'] = this.s48;
    data['96'] = this.s96;
    return data;
  }
}

class Links {
  Self? self;
  Self? collection;
  Self? up;
  Reviewer? reviewer;

  Links({this.self, this.collection, this.up, this.reviewer});

  Links.fromJson(Map<dynamic, dynamic> json) {
    self = json['self'] != null ? new Self.fromJson(json['self']) : null;
    collection = json['collection'] != null
        ? new Self.fromJson(json['collection'])
        : null;
    up = json['up'] != null ? new Self.fromJson(json['up']) : null;
    reviewer = json['reviewer'] != null
        ? new Reviewer.fromJson(json['reviewer'])
        : null;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    if (this.self != null) {
      data['self'] = this.self!.toJson();
    }
    if (this.collection != null) {
      data['collection'] = this.collection!.toJson();
    }
    if (this.up != null) {
      data['up'] = this.up!.toJson();
    }
    if (this.reviewer != null) {
      data['reviewer'] = this.reviewer!.toJson();
    }
    return data;
  }
}

class Self {
  String? href;

  Self({this.href});

  Self.fromJson(Map<dynamic, dynamic> json) {
    href = json['href'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['href'] = this.href;
    return data;
  }
}

class Reviewer {
  bool? embeddable;
  String? href;

  Reviewer({this.embeddable, this.href});

  Reviewer.fromJson(Map<dynamic, dynamic> json) {
    embeddable = json['embeddable'];
    href = json['href'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['embeddable'] = this.embeddable;
    data['href'] = this.href;
    return data;
  }
}
