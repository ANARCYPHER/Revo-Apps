import 'package:nyoba/models/countries_model.dart';

class BillingAddress {
  String? name, type;

  BillingAddress({this.name, this.type});

  Map toJson() => {'name': name, 'type': type};

  BillingAddress.fromJson(Map json) {
    name = json['name'];
    type = json['type'];
  }
}

class State {
  String? code, name;
  List<City>? cities;

  State({this.code, this.name, this.cities});

  Map toJson() => {'code': code, 'name': name, 'cities': cities};

  State.fromJson(Map json) {
    code = json['code'];
    name = json['name'];
    if (json['cities'] != null) {
      json['cities'].forEach((v) {
        cities!.add(City.fromJson(v));
      });
    }
  }
}
