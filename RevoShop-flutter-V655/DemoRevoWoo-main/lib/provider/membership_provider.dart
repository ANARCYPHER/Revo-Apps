import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:nyoba/models/membership_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/services/membership_api.dart';
import 'package:nyoba/utils/utility.dart';

class MembershipProvider with ChangeNotifier {
  List listMemberships = [];
  bool isMembershipLoading = true;
  fetchMembership() async {
    isMembershipLoading = true;
    printLog(isMembershipLoading.toString(), name: "loading sebelum");
    try {
      await MembershipAPI().getDataMembership().then((data) {
        // printLog(listMemberships.toString(), name: "Membership before fetch");
        if (data.isNotEmpty) {
          listMemberships.clear();
          for (var item in data) {
            listMemberships.add(ProductModel.fromJson(item));
          }
          // printLog(jsonEncode(listMemberships), name: "Membership after fetch");
          isMembershipLoading = false;
          printLog(isMembershipLoading.toString(),
              name: "loading setelah fetch");
          notifyListeners();
        }
      });
    } catch (e) {
      printLog(e.toString());
      isMembershipLoading = false;
      notifyListeners();
    }
  }
}
