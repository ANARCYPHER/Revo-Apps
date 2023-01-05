class MembershipModel {
  String? name;
  Membership? membership;

  MembershipModel(
    this.name,
    this.membership,
  );

  Map toJson() => {
        'name': name,
        'membership': membership,
      };

  MembershipModel.fromJson(Map json) {
    name = json['name'] ?? "";
    membership = Membership.fromJson(json['membership']);
  }
}

class Membership {
  String? planName, endDate;
  bool? status;

  Membership(this.planName, this.endDate, this.status);

  Membership.fromJson(Map json) {
    planName = json['plan_name'];
    endDate = json['end_date'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['plan_name'] = planName;
    data['end_date'] = endDate;
    data['status'] = status;
    return data;
  }
}
