import 'package:nyoba/models/product_model.dart';

class AvailableVariation {
  dynamic attributes;
  String? availabilityHtml;
  bool? backordersAllowed;
  Dimensions? dimensions;
  String? dimensionsHtml;
  dynamic displayPrice;
  dynamic displayRegularPrice;
  Image? image;
  dynamic imageId;
  bool? isDownloadable;
  bool? isInStock;
  bool? isPurchasable;
  String? isSoldIndividually;
  bool? isVirtual;
  dynamic maxQty;
  int? minQty;
  String? priceHtml;
  String? sku;
  String? variationDescription;
  int? variationId;
  bool? variationIsActive;
  bool? variationIsVisible;
  String? weight;
  String? weightHtml;
  int? cashbackAmount;
  String? cashbackHtml;
  String? imageCatalog;
  dynamic dealTime;
  String? imageSinglePage;
  List<Option>? option;
  String? formatedPrice;
  dynamic formatedSalesPrice;
  List<VariationMetaData>? metaData;
  MinMaxQuantity? minMaxQuantity;

  AvailableVariation(
      {this.attributes,
      this.availabilityHtml,
      this.backordersAllowed,
      this.dimensions,
      this.dimensionsHtml,
      this.displayPrice,
      this.displayRegularPrice,
      this.image,
      this.imageId,
      this.isDownloadable,
      this.isInStock,
      this.isPurchasable,
      this.isSoldIndividually,
      this.isVirtual,
      this.maxQty,
      this.minQty,
      this.priceHtml,
      this.sku,
      this.variationDescription,
      this.variationId,
      this.variationIsActive,
      this.variationIsVisible,
      this.weight,
      this.weightHtml,
      this.cashbackAmount,
      this.cashbackHtml,
      this.imageCatalog,
      this.dealTime,
      this.imageSinglePage,
      this.option,
      this.formatedPrice,
      this.formatedSalesPrice,
      this.metaData,
      this.minMaxQuantity});

  AvailableVariation.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null ? json['attributes'] : null;
    availabilityHtml = json['availability_html'];
    backordersAllowed = json['backorders_allowed'];
    dimensions = json['dimensions'] != null
        ? new Dimensions.fromJson(json['dimensions'])
        : null;
    dimensionsHtml = json['dimensions_html'];
    displayPrice = json['display_price'] != null ? json['display_price'] : 0;
    displayRegularPrice = json['display_regular_price'];
    image = json['image'] == null
        ? null
        : json['image'].isEmpty
            ? null
            : new Image.fromJson(json['image']);
    imageId = json['image_id'];
    isDownloadable = json['is_downloadable'];
    isInStock = json['is_in_stock'];
    isPurchasable = json['is_purchasable'];
    isSoldIndividually = json['is_sold_individually'];
    isVirtual = json['is_virtual'];
    maxQty = !json['is_in_stock']
        ? 0
        : json['max_qty'] != "" && json['max_qty'] != null
            ? int.parse(json['max_qty'].toString())
            : 9999;
    minQty = json['min_qty'] != "" && json['min_qty'] != null
        ? int.parse(json['min_qty'].toString())
        : 0;
    priceHtml = json['price_html'];
    sku = json['sku'];
    variationDescription = json['variation_description'];
    variationId = json['variation_id'];
    variationIsActive = json['variation_is_active'];
    variationIsVisible = json['variation_is_visible'];
    weight = json['weight'];
    weightHtml = json['weight_html'];
    cashbackAmount = json['cashback_amount'];
    cashbackHtml = json['cashback_html'];
    imageCatalog = json['image_catalog'];
    dealTime = json['deal_time'];
    imageSinglePage = json['image_single_page'];
    if (json['option'] != null) {
      option = <Option>[];
      json['option'].forEach((v) {
        option!.add(new Option.fromJson(v));
      });
    }
    if (json['meta_data'] != null) {
      metaData = <VariationMetaData>[];
      json['meta_data'].forEach((v) {
        metaData!.add(new VariationMetaData.fromJson(v));
      });
    }
    formatedPrice = json['formated_price'];
    formatedSalesPrice = json['formated_sales_price'];
    if (json['minmax_quantity'] != null) {
      minMaxQuantity = MinMaxQuantity.fromJson(json['minmax_quantity']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!;
    }
    data['availability_html'] = this.availabilityHtml;
    data['backorders_allowed'] = this.backordersAllowed;
    if (this.dimensions != null) {
      data['dimensions'] = this.dimensions!.toJson();
    }
    data['dimensions_html'] = this.dimensionsHtml;
    data['display_price'] = this.displayPrice;
    data['display_regular_price'] = this.displayRegularPrice;
    if (this.image != null) {
      data['image'] = this.image!.toJson();
    }
    data['image_id'] = this.imageId;
    data['is_downloadable'] = this.isDownloadable;
    data['is_in_stock'] = this.isInStock;
    data['is_purchasable'] = this.isPurchasable;
    data['is_sold_individually'] = this.isSoldIndividually;
    data['is_virtual'] = this.isVirtual;
    data['max_qty'] = this.maxQty;
    data['min_qty'] = this.minQty;
    data['price_html'] = this.priceHtml;
    data['sku'] = this.sku;
    data['variation_description'] = this.variationDescription;
    data['variation_id'] = this.variationId;
    data['variation_is_active'] = this.variationIsActive;
    data['variation_is_visible'] = this.variationIsVisible;
    data['weight'] = this.weight;
    data['weight_html'] = this.weightHtml;
    data['cashback_amount'] = this.cashbackAmount;
    data['cashback_html'] = this.cashbackHtml;
    data['image_catalog'] = this.imageCatalog;
    data['deal_time'] = this.dealTime;
    data['image_single_page'] = this.imageSinglePage;
    if (this.option != null) {
      data['option'] = this.option!.map((v) => v.toJson()).toList();
    }
    if (this.metaData != null) {
      data['meta_data'] = this.metaData!.map((v) => v.toJson()).toList();
    }
    data['formated_price'] = this.formatedPrice;
    data['formated_sales_price'] = this.formatedSalesPrice;
    data['minmax_quantity'] = this.minMaxQuantity;
    return data;
  }
}

class Dimensions {
  String? length;
  String? width;
  String? height;

  Dimensions({this.length, this.width, this.height});

  Dimensions.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['length'] = this.length;
    data['width'] = this.width;
    data['height'] = this.height;
    return data;
  }
}

class Image {
  String? title;
  String? caption;
  String? url;
  String? alt;
  String? src;
  dynamic srcset;
  dynamic sizes;
  dynamic fullSrc;
  int? fullSrcW;
  int? fullSrcH;
  String? galleryThumbnailSrc;
  int? galleryThumbnailSrcW;
  int? galleryThumbnailSrcH;
  String? thumbSrc;
  int? thumbSrcW;
  int? thumbSrcH;
  int? srcW;
  int? srcH;

  Image(
      {this.title,
      this.caption,
      this.url,
      this.alt,
      this.src,
      this.srcset,
      this.sizes,
      this.fullSrc,
      this.fullSrcW,
      this.fullSrcH,
      this.galleryThumbnailSrc,
      this.galleryThumbnailSrcW,
      this.galleryThumbnailSrcH,
      this.thumbSrc,
      this.thumbSrcW,
      this.thumbSrcH,
      this.srcW,
      this.srcH});

  Image.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    caption = json['caption'];
    url = json['url'];
    alt = json['alt'];
    src = json['src'];
    srcset = json['srcset'];
    sizes = json['sizes'];
    fullSrc = json['full_src'];
    fullSrcW = json['full_src_w'];
    fullSrcH = json['full_src_h'];
    galleryThumbnailSrc = json['gallery_thumbnail_src'];
    galleryThumbnailSrcW = json['gallery_thumbnail_src_w'];
    galleryThumbnailSrcH = json['gallery_thumbnail_src_h'];
    thumbSrc = json['thumb_src'];
    thumbSrcW = json['thumb_src_w'];
    thumbSrcH = json['thumb_src_h'];
    srcW = json['src_w'];
    srcH = json['src_h'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['caption'] = this.caption;
    data['url'] = this.url;
    data['alt'] = this.alt;
    data['src'] = this.src;
    data['srcset'] = this.srcset;
    data['sizes'] = this.sizes;
    data['full_src'] = this.fullSrc;
    data['full_src_w'] = this.fullSrcW;
    data['full_src_h'] = this.fullSrcH;
    data['gallery_thumbnail_src'] = this.galleryThumbnailSrc;
    data['gallery_thumbnail_src_w'] = this.galleryThumbnailSrcW;
    data['gallery_thumbnail_src_h'] = this.galleryThumbnailSrcH;
    data['thumb_src'] = this.thumbSrc;
    data['thumb_src_w'] = this.thumbSrcW;
    data['thumb_src_h'] = this.thumbSrcH;
    data['src_w'] = this.srcW;
    data['src_h'] = this.srcH;
    return data;
  }
}

class Option {
  String? key;
  String? value;

  Option({this.key, this.value});

  Option.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}

class VariationMetaData {
  int? id;
  String? key;
  var value;

  VariationMetaData({this.id, this.key, this.value});

  Map toJson() => {
        'id': id,
        'key': key,
        'value': value,
      };

  VariationMetaData.fromJson(Map json)
      : id = json['id'],
        key = json['key'],
        value = json['value'];
}
