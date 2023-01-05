class CountriesModel {
  String? code;
  String? name;
  List<States>? states;
  Links? lLinks;

  CountriesModel({this.code, this.name, this.states, this.lLinks});

  CountriesModel.fromJson(Map json) {
    code = json['code'];
    name = json['name'];
    if (json['states'] != null) {
      states = <States>[];
      json['states'].forEach((v) {
        states!.add(new States.fromJson(v));
      });
    }
    lLinks = json['_links'] != null ? new Links.fromJson(json['_links']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    if (this.states != null) {
      data['states'] = this.states!.map((v) => v.toJson()).toList();
    }
    if (this.lLinks != null) {
      data['_links'] = this.lLinks!.toJson();
    }
    return data;
  }
}

class States {
  dynamic code;
  String? name;

  States({this.code, this.name});

  States.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    return data;
  }
}

class Links {
  List<Self>? self;
  List<Self>? collection;

  Links({this.self, this.collection});

  Links.fromJson(Map<String, dynamic> json) {
    if (json['self'] != null) {
      self = <Self>[];
      json['self'].forEach((v) {
        self!.add(new Self.fromJson(v));
      });
    }
    if (json['collection'] != null) {
      collection = <Self>[];
      json['collection'].forEach((v) {
        collection!.add(new Self.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.self != null) {
      data['self'] = this.self!.map((v) => v.toJson()).toList();
    }
    if (this.collection != null) {
      data['collection'] = this.collection!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Self {
  String? href;

  Self({this.href});

  Self.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['href'] = this.href;
    return data;
  }
}

class Subdistrict {
  String? subdistrictId, cityId, city, subdistrictName, state, stateId;

  Subdistrict(
      {this.subdistrictId,
      this.cityId,
      this.city,
      this.subdistrictName,
      this.state,
      this.stateId});

  Map toJson() => {
        'city_id': cityId,
        'city': city,
        'id': subdistrictId,
        'value': subdistrictName,
        'state': state,
        'state_id': stateId
      };

  Subdistrict.fromJson(Map json) {
    subdistrictId = json['id'].toString();
    cityId = json['city_id'].toString();
    city = json['city'];
    subdistrictName = json['value'];
    state = json['state'];
    stateId = json['state_id'].toString();
  }
}

class City {
  String? cityId, stateId;
  String? value, state;

  City({this.cityId, this.stateId, this.value, this.state});

  Map toJson() => {
        'id': cityId,
        'value': value,
        'state': state,
        'state_id': stateId,
      };

  City.fromJson(Map json) {
    cityId = json['id'].toString();
    value = json['value'];
    state = json['state'];
    stateId = json['state_id'].toString();
  }
}
