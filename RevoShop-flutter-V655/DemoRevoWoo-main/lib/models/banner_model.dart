class BannerModel {
  // Model
  final int? product;
  final String? titleSlider;
  final String? image;
  final String? type;
  final String? name;
  final String? linkTo;

  BannerModel(
      {this.product,
      this.titleSlider,
      this.image,
      this.name,
      this.type,
      this.linkTo});

  Map toJson() => {
        'product': product,
        'title_slider': titleSlider,
        'image': image,
        'name': name,
        'type': type,
        'link_to': linkTo
      };

  BannerModel.fromJson(Map json)
      : product = json['product'],
        titleSlider = json['title_slider'],
        image = json['image'],
        type = json['type'],
        name = json['name'],
        linkTo = json['link_to'];
}
