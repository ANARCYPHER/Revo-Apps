import 'dart:convert';

import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class UserAPI {
  fetchDetail() async {
    Map data = {"cookie": Session.data.get('cookie')};
    printLog(data.toString(), name: "DATA FETCH USER");
    var response = await baseAPI.postAsync('$userDetail', data,
        isCustom: true, printedLog: true);
    return response;
  }

  updateUserInfo(
      {String? firstName,
      String? lastName,
      String? email,
      required String password,
      String? oldPassword,
      String? countryCode = "",
      String? phone = ""}) async {
    Map data = {
      "cookie": Session.data.get('cookie'),
      "first_name": firstName,
      "last_name": lastName,
      "user_email": email,
      "country_code": countryCode,
      "phone_number": phone,
      if (password.isNotEmpty) "user_pass": password,
      if (password.isNotEmpty) "old_pass": oldPassword
    };
    printLog(json.encode(data), name: "Data update user");
    var response = await baseAPI.postAsync('$updateUser', data, isCustom: true);
    return response;
  }

  checkPhoneNumber({String? phone, String? countryCode}) async {
    Map data = {
      "cookie": Session.data.getString("cookie"),
      "country_code": countryCode,
      "phone_number": phone
    };
    printLog(json.encode(data), name: "Data Check Phone");
    var response = await baseAPI.postAsync('$checkPhone', data, isCustom: true);
    printLog(json.encode(response), name: "Response Check Phone");
    return response;
  }
}
