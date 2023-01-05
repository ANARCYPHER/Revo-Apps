class BannerMiniModel {
  // Model
  final int? product;
  final String? titleSlider;
  final String? image;
  final String? type;
  final String? name;
  final String? linkTo;

  BannerMiniModel(
      {this.product,
      this.titleSlider,
      this.image,
      this.type,
      this.name,
      this.linkTo});

  Map toJson() => {
        'product': product,
        'title_slider': titleSlider,
        'image': image,
        'type': type,
        'name': name,
        'link_to': linkTo
      };

  BannerMiniModel.fromJson(Map json)
      : product = json['product'],
        titleSlider = json['title_slider'],
        image = json['image'],
        type = json['type'],
        name = json['name'],
        linkTo = json['link_to'];
}
