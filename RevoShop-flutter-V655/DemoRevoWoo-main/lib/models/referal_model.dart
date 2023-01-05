class ReferalModel {
  String? referralLink;
  String? dashboardLink;

  ReferalModel({this.referralLink, this.dashboardLink});

  ReferalModel.fromJson(Map<String, dynamic> json) {
    referralLink = json['referral_link'];
    dashboardLink = json['dashboard_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['referral_link'] = this.referralLink;
    data['dashboard_link'] = this.dashboardLink;
    return data;
  }
}
