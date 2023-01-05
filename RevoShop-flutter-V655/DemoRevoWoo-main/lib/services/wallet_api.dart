import 'dart:convert';

import 'package:nyoba/services/session.dart';

import '../constant/constants.dart';
import '../constant/global_url.dart';
import '../utils/utility.dart';

class WalletAPI {
  webViewWallet(type) async {
    Map data = {
      "payment_method": "xendit_bniva",
      "payment_method_title": "Bank Transfer - BNI",
      "set_paid": true,
      "line_items": [],
      "customer_id": Session.data.getInt('id'),
      "status": "completed",
      "coupon_lines": [],
      "wallet_tab": type,
      "token": Session.data.getString('cookie')
    };

    final jsonOrder = json.encode(data);
    printLog(jsonOrder, name: 'Json Order');

    //Convert Json to bytes
    var bytes = utf8.encode(jsonOrder);
    //Convert bytes to base64
    var order = base64.encode(bytes);

    var response = await baseAPI.getAsync(
        '$orderApi?order=$order', isOrder: true);
    return response;
  }

  listTransaction() async {
    String id = Session.data.getInt('id').toString();
    var response = await baseAPI.getAsync('$transactionWalletUrl/$id',
        version: 2, isCustom: true);
    return response;
  }

  balance() async {
    String id = Session.data.getInt('id').toString();
    var response = await baseAPI.getAsync('$balanceWalletUrl/$id',
        version: 2, isCustom: true);
    return response;
  }
}
