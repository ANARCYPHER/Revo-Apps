import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nyoba/models/notification_model.dart';
import 'package:nyoba/services/notification_api.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class NotificationProvider with ChangeNotifier {
  bool isLoading = false;
  List<NotificationModel> notification = [];
  List unreadNotification = [];

  fetchReadNotif(int id, String type) async {
    printLog("masuk fecth read notif");
    var result;
    await NotificationAPI().readNotification(id, type).then((data) {
      result = data;
      printLog(result.toString(), name: "Hasil read notif");
    });
  }

  Future<List?> fetchNotifications({status, search}) async {
    isLoading = true;

    var result;
    await NotificationAPI().notification().then((data) async {
      result = data;
      notification.clear();
      unreadNotification.clear();

      // final List<dynamic> jsonDatas =
      //     jsonDecode(Session.data.getString('local_notif') ?? '[]');

      // if (Session.data.containsKey('local_notif')) {
      //   print("masuk session local_notif");
      //   final List<dynamic> jsonData =
      //       jsonDecode(Session.data.getString('local_notif') ?? '[]');
      //   printLog(Session.data.getString('local_notif').toString(),
      //       name: "LOKKAL NOTIF");
      //   notification = jsonData.map<NotificationModel>((jsonItem) {
      //     return NotificationModel.fromJson(jsonItem);
      //   }).toList();
      // }

      for (Map item in result) {
        notification.add(NotificationModel.fromJson(item));
      }

      for (var notif in notification) {
        if (notif.isRead == 0) {
          unreadNotification.add(notif);
        }
      }

      notification.sort((b, a) {
        var adate = DateTime.parse(a.createdAt!);
        var bdate = DateTime.parse(b.createdAt!);
        return adate.compareTo(
            bdate); //to get the order other way just switch `adate & bdate`
      });

      isLoading = false;
      notifyListeners();
    });
    return result;
  }
}
