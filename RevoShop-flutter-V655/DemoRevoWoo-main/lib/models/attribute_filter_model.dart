class AttributeFilter {
  String? taxonomy;
  String? field;
  List<String>? terms;
  String? operator;

  AttributeFilter({this.taxonomy, this.field, this.terms, this.operator});

  AttributeFilter.fromJson(Map<String, dynamic> json) {
    taxonomy = json['taxonomy'];
    field = json['field'];
    terms = json['terms'].cast<String>();
    operator = json['operator'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['taxonomy'] = this.taxonomy;
    data['field'] = this.field;
    data['terms'] = this.terms;
    data['operator'] = this.operator;
    return data;
  }
}