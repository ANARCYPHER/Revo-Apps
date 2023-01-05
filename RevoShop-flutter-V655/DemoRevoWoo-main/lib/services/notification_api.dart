import 'dart:convert';

import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class NotificationAPI {
  notification() async {
    Map data = {
      "cookie": Session.data.getString('cookie'),
    };
    printLog(json.encode(data), name: "data notification");
    var response = await baseAPI.postAsync(
      newNotificationUrl,
      data,
      isCustom: true,
    );
    printLog(json.encode(response), name: "Response notification");
    return response;
  }

  readNotification(int id, String type) async {
    Map data = {
      "cookie": Session.data.getString('cookie'),
      "id": id,
      "type": type,
    };
    printLog(data.toString(), name: "data notif");
    var response =
        await baseAPI.postAsync(readNotificationUrl, data, isCustom: true);
    return response;
  }
}
