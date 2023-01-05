import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/cart_model.dart';
import 'package:nyoba/models/checkout_data_model.dart';
import 'package:nyoba/provider/wallet_provider.dart';
import 'package:nyoba/services/order_api.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

class CheckoutProvider with ChangeNotifier {
  bool loading = true;
  bool loadingOrder = false;
  UserData? user;
  List<LineItem> lineItems = [];
  List<ShippingLine> shippingLines = [];
  List<PaymentMethod> paymentMethods = [];
  List<PaymentMethod> tempPaymentMethods = [];
  PointsRedemption? pointsRedemption;
  late StreamSubscription subscription;
  var isDeviceConnected = false;
  bool isAlertSet = false;
  bool isWallet = false;

  Future<bool> deleteCart({List<CartProductItem>? line}) async {
    await OrderAPI().addCart(action: "delete", line: line).then((data) {
      printLog("data : $data");
      if (data['status'] == 'success') {
        return true;
      }
    });
    return false;
  }

  Future<bool> syncCart({List<CartProductItem>? line}) async {
    await OrderAPI().addCart(action: "sync", line: line).then((data) {
      printLog("data : $data");
      if (data['status'] == 'success') {
        return true;
      }
    });
    return false;
  }

  getConectivity() {
    subscription = Connectivity().onConnectivityChanged.listen((event) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!isDeviceConnected) {
        printLog("inet off", name: "check inet");
        isAlertSet = true;
        notifyListeners();
      }
    });
  }

  setAlert() {
    isAlertSet = false;
    notifyListeners();
  }

  Future createCart({List<CartProductItem>? line}) async {
    OrderAPI().addCart(action: "create", line: line);
  }

  int? indexPayment;
  int? indexShipping;
  int? indexCourier;
  String? titlePayment;
  String? titleShipping;
  String? shipping;
  String? shippingCost;
  double? total = 0;
  double? grandTotal = 0;
  double? newTotal = 0;
  ShippingLine? shiped;
  PaymentMethod? payment;
  String? titleCourier = "Choose Courier Services";
  String? courierCost = "0";
  String? courierEtd;
  Couriers? courier;
  List<Couriers>? listCourier = [];

  insertCourier(value) {
    listCourier = (value);
    notifyListeners();
  }

  setCourier(index, context) {
    indexCourier = index;
    titleCourier = listCourier![index].methodTitle;
    courierCost = listCourier![index].cost.toString();
    courierEtd = listCourier![index].etd;
    newTotal = total;
    ShippingLine? tempShip;
    shipping = titleCourier;
    shippingCost = "${stringToCurrency(double.parse(courierCost!), context)}";
    for (int i = 0; i < shippingLines.length; i++) {
      if (shippingLines[i].methodTitle == "other_courier") {
        tempShip = new ShippingLine(
            methodId: shippingLines[i].methodId,
            methodTitle: titleCourier,
            cost: double.parse(courierCost!));
      }
    }

    shiped = tempShip;
    if (payment?.id == "wallet") {
      payment = null;
      titlePayment = null;
      indexPayment = null;
    }
    notifyListeners();
  }

  setPayment(index, bool isWallet) {
    indexPayment = index;
    // if (isWallet) {
    titlePayment = "${paymentMethods[index].title}";
    payment = paymentMethods[index];
    notifyListeners();
    // }
    // else if (!isWallet) {
    //   if (paymentMethods[index].id == "wallet" ||
    //       paymentMethods[index - 1].id == "wallet") {
    //     printLog("masuk 1");
    //     titlePayment = "${paymentMethods[index + 1].title}";
    //     payment = paymentMethods[index + 1];
    //     notifyListeners();
    //   } else if (paymentMethods[index].id != "wallet") {
    //     printLog("masuk 2");
    //     titlePayment = "${paymentMethods[index].title}";
    //     payment = paymentMethods[index];
    //     notifyListeners();
    //   }
    // }

    notifyListeners();
  }

  reset() {
    indexPayment = null;
    titlePayment = null;
    indexShipping = null;
    titleShipping = null;
    titleCourier = "Choose Courier Services";
    user = null;
    shiped = null;
    payment = null;
    listCourier?.clear();
    notifyListeners();
  }

  setShipping(index, context) {
    titleCourier = "Choose Courier Services";
    indexCourier = 9999;
    indexShipping = index;
    grandTotal = total;
    newTotal = total;
    shipping = "${shippingLines[index].methodTitle}";
    shippingCost = "${stringToCurrency(shippingLines[index].cost!, context)}";
    titleShipping = shippingLines[index].methodTitle == "other_courier"
        ? AppLocalizations.of(context)!.translate('other_courier')
        : "${shippingLines[index].methodTitle} (${stringToCurrency(shippingLines[index].cost!, context)})";
    if (shippingLines[index].methodTitle != "other_courier") {
      shiped = shippingLines[index];
    } else {
      ShippingLine tempShip = new ShippingLine(
          methodId: shippingLines[index].methodId,
          methodTitle: titleCourier,
          cost: 0);
      shiped = tempShip;
    }
    if (payment?.id == "wallet") {
      payment = null;
      titlePayment = null;
      indexPayment = null;
    }
    notifyListeners();
  }

  resetPayment() {
    payment = null;
    titlePayment = null;
    indexPayment = null;
    notifyListeners();
  }

  double ratePoint = 0;
  checkPoin({double? coupon = 0}) {
    if (coupon != 0) {
      double temptotal = total! - coupon!;
      printLog(temptotal.toString());
      pointsRedemption!.totalDisc = temptotal.toInt();
      pointsRedemption!.point = temptotal.toInt() * ratePoint.toInt();
    }
  }

  Future<bool> calculateTotal(
      {double? ship,
      double? disc,
      double? wallet,
      bool? isWallet = false,
      bool? isPoint = false,
      int? point = 0}) async {
    grandTotal = total;
    newTotal = total;
    if (point != 0 && isPoint!) {
      grandTotal = grandTotal! - point!.toDouble();
      newTotal = newTotal! - point.toDouble();
    }
    if (isWallet!) {
      grandTotal = grandTotal! + ship! - disc!;
      if (disc <= (newTotal! + ship))
        newTotal = newTotal! + ship - disc - wallet!;
      else if (disc > (newTotal! + ship)) newTotal = 0;
    } else if (!isWallet) {
      grandTotal = grandTotal! + ship! - disc!;
      if (disc <= (newTotal! + ship))
        newTotal = newTotal! + ship - disc;
      else if (disc > (newTotal! + ship)) newTotal = 0;
    }

    notifyListeners();
    return true;
  }

  Future<dynamic> placeOrder(
      {List<CartProductItem>? line,
      UserData? bill,
      ShippingLine? ship,
      PaymentMethod? pay,
      List<Map<String, dynamic>>? coupon,
      String? note,
      bool? partialPayment}) async {
    var val;
    try {
      loadingOrder = true;
      notifyListeners();
      await OrderAPI()
          .placeOrder(
              line: line,
              bill: bill,
              ship: ship,
              pay: pay,
              coupon: coupon,
              note: note,
              partialPayment: partialPayment)
          .then((data) {
        printLog(json.encode(data));
        if (data != null) {
          val = data;
          return data;
        }
      });
      loadingOrder = false;
      notifyListeners();
      return val;
    } catch (e) {
      loadingOrder = false;
      print(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future getCheckoutData(
      {List<CartProductItem>? line,
      String? countryId,
      String? stateId,
      String? postcode,
      String? city,
      String? subdistrict}) async {
    loading = true;
    try {
      // if (Session.data.containsKey('cookie')) {
      //   line = null;
      // }
      lineItems.clear();
      shippingLines.clear();
      paymentMethods.clear();
      await OrderAPI()
          .checkoutData(
              line: line,
              countryId: countryId,
              stateId: stateId,
              postcode: postcode,
              city: city,
              subdistrict: subdistrict)
          .then((data) {
        var result;
        printLog("data 1: ${json.encode(data)}");
        if (data != null) {
          result = data;
          if (result['user_data'] != null) {
            user = UserData.fromJson(result['user_data']);
            printLog("data : ${json.encode(user)}");
          }
          printLog(json.encode(user), name: 'USER');
          if (result['line_items'] != null && result['line_items'].isNotEmpty) {
            for (Map item in result['line_items']) {
              lineItems.add(LineItem.fromJson(item));
            }
          }
          if (result['shipping_lines'] != null) {
            for (Map item in result['shipping_lines']) {
              shippingLines.add(ShippingLine.fromJson(item));
            }
          }
          if (result['payment_methods'] != null) {
            for (Map item in result['payment_methods']) {
              paymentMethods.add(PaymentMethod.fromJson(item));
            }
            tempPaymentMethods = paymentMethods;
          }
          if (result['points_redemption'] != null) {
            pointsRedemption =
                PointsRedemption.fromJson(result['points_redemption']);
            ratePoint = pointsRedemption!.point! / pointsRedemption!.totalDisc!;
          }
        }
        total = 0;
        for (int i = 0; i < lineItems.length; i++) {
          total = total! + lineItems[i].subtotal!;
        }
        grandTotal = total;
        newTotal = total;
        loading = false;
        notifyListeners();
      });
    } catch (e) {
      loading = false;
      notifyListeners();
      print(e.toString());
    }
  }
}
