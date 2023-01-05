class GeneralSettingsModel{
  String? slug, title, image;
  dynamic description, position;

  GeneralSettingsModel({this.slug, this.title, this.image, this.description, this.position});

  Map toJson() => {
    'slug': slug,
    'title': title,
    'image': image,
    'description': description,
    'position': position
  };

  GeneralSettingsModel.fromJson(Map json) {
    slug = json['slug'].toString();
    title = json['title'];
    image = json['image'];
    description = json['description'];
    if (json['position'] != null){
      position = json['position'];
    }
  }

  @override
  String toString() {
    return 'GeneralSettingsModel{slug: $slug, title: $title, image: $image, description: $description, position: $position}';
  }
}