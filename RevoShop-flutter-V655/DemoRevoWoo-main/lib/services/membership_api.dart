import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class MembershipAPI {
  getDataMembership() {
    var data = {
      "cookie": Session.data.getString("cookie"),
      "slug_category": "membership-plan",
    };
    printLog(data.toString(), name: "DATA MEMBERSHIP");
    var response = baseAPI.postAsync(
      membershipDetail,
      data,
      isCustom: true,
      printedLog: true,
    );
    return response;
  }
}
