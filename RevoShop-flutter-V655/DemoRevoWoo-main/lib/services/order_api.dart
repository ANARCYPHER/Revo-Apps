import 'dart:convert';

import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/models/cart_model.dart';
import 'package:nyoba/models/checkout_data_model.dart';
import 'package:nyoba/models/line_items_model.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class OrderAPI {
  checkoutOrder(order) async {
    var response = await baseAPI.getAsync('$orderApi?order=$order',
        isOrder: true, printedLog: true);
    return response;
  }

  listMyOrder(
      String? status, String? search, String? orderId, int? page) async {
    Map data = {
      "cookie": Session.data.getString('cookie'),
      "status": status,
      "search": search,
      "page": page,
      if (orderId != null) "order_id": orderId
    };
    printLog(json.encode(data));
    var response = await baseAPI.postAsync(
      '$listOrders',
      data,
      isCustom: true,
    );
    return response;
  }

  detailOrder(String? orderId) async {
    Map data = {
      "cookie": Session.data.getString('cookie'),
      "order_id": orderId
    };
    printLog(data.toString());
    var response = await baseAPI.postAsync(
      '$listOrders',
      data,
      isCustom: true,
    );
    return response;
  }

  loadProductCart(String? include) async {
    Map data = {
      "include": include,
      "lang": Session.data.getString("language_code"),
      "cookie": Session.data.containsKey("cookie")
          ? Session.data.getString("cookie")
          : null,
    };
    printLog(data.toString());
    var response = await baseAPI.postAsync(
      '$customProductUrl',
      data,
      isCustom: true,
    );
    return response;
  }

  checkPrice({List<LineItems>? lineItems}) async {
    Map data = {"line_items": lineItems};
    printLog(json.encode(data), name: "Line Items");
    var response =
        await baseAPI.postAsync('product/check-price', data, isCustom: true);
    printLog(json.encode(response), name: "Response check price");
    return response;
  }

  addCart({String? action, List<CartProductItem>? line}) async {
    Map data = {
      "cookie": Session.data.getString('cookie'),
      "action": action,
      "line_items": line
    };
    printLog("data add cart : ${json.encode(data)}");
    var response = await baseAPI.postAsync('$cart', data, isCustom: true);
    printLog('response : ${json.encode(response)}');
    return response;
  }

  checkoutData(
      {List<CartProductItem>? line,
      String? countryId,
      String? stateId,
      String? postcode,
      String? city,
      String? subdistrict}) async {
    Map data = {
      "cookie": Session.data.getString('cookie'),
      "line_items": line,
      "country_id": countryId,
      "state_id": stateId,
      'postcode': postcode,
      "city": city,
      "subdistrict": subdistrict
    };
    printLog("data : ${json.encode(data)}");
    var response =
        await baseAPI.postAsync('$checkoutDatas', data, isCustom: true);
    return response;
  }

  placeOrder(
      {List<CartProductItem>? line,
      UserData? bill,
      ShippingLine? ship,
      PaymentMethod? pay,
      List<Map<String, dynamic>>? coupon,
      String? note,
      bool? partialPayment}) async {
    Map data = {
      "cookie": Session.data.getString('cookie'),
      'line_items': line,
      'billing_address': bill,
      'shipping_lines': ship,
      'payment_method': pay,
      'coupon_lines': coupon,
      "order_notes": note,
      "wallet_partial_payment": partialPayment
    };
    printLog("data place : ${json.encode(data)}");
    var response =
        await baseAPI.postAsync('$placeOrders', data, isCustom: true);
    printLog("response place : ${json.encode(response)}");
    return response;
  }
}
