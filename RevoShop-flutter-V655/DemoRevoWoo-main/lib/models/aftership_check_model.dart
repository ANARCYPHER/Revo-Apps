class AfterShipCheck {
  bool? pluginActive;
  String? aftershipDomain;

  AfterShipCheck({this.pluginActive, this.aftershipDomain});

  AfterShipCheck.fromJson(Map<String, dynamic> json) {
    pluginActive = json['plugin_active'];
    aftershipDomain = json['aftership_domain'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['plugin_active'] = this.pluginActive;
    data['aftership_domain'] = this.aftershipDomain;
    return data;
  }
}
