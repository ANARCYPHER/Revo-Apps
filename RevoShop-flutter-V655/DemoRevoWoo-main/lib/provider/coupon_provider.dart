import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:nyoba/models/coupon_model.dart';
import 'dart:convert';
import 'package:nyoba/services/coupon_api.dart';
import 'package:nyoba/utils/utility.dart';

class CouponProvider with ChangeNotifier {
  bool loading = false;
  bool loadingUse = false;

  List<CouponModel> coupons = [];
  List<CouponModel> couponSearched = [];

  CouponModel? couponUsed;

  String? searchCoupon;
  int? currentPage;

  Future<void> fetchCoupon({page}) async {
    try {
      printLog("Fetching Coupon");
      loading = true;
      currentPage = page;
      await CouponAPI().newFetchListCoupon().then((data) {
        if (data != null) {
          final responseJson = data;
          printLog("response json coupon : ${json.encode(responseJson)}");
          coupons.clear();
          for (var item in responseJson) {
            DateTime exp = DateTime.now();
            if (item['date_expires'] != null) {
              exp = DateTime.parse(item['date_expires']['date']);
            }
            if (exp.isAfter(DateTime.now()) || item['date_expires'] == null)
              coupons.add(CouponModel.fromJson(item));
          }
          printLog("Coupons : ${json.encode(coupons)}");
          loading = false;
          notifyListeners();
        } else {
          coupons.clear();
          printLog("Gagal load");
          loading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      coupons.clear();
      printLog("Gagal load coupon");
      loading = false;
      notifyListeners();
    }
  }

  Future<void> newUseCoupon(context,
      {List<SearchCouponModel>? products, String? code}) async {
    loadingUse = true;
    await CouponAPI()
        .newSearchCoupon(products: products, code: code)
        .then((data) {
      couponSearched.clear();
      if (data != null && data["code"] != "invalid_coupon") {
        couponUsed = CouponModel.fromJson(data);
        loadingUse = false;
        notifyListeners();
      } else {
        loadingUse = false;
        notifyListeners();
        snackBar(context, message: HtmlUnescape().convert(data["message"]));
      }
    });
  }

  clearCoupon() {
    couponUsed = null;
    notifyListeners();
  }

  Future<void> useCoupon({search}) async {
    searchCoupon = search;
    CouponModel? _couponUsed;
    print(loadingUse);
    await CouponAPI().searchCoupon(search).then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        couponSearched.clear();
        for (Map item in responseJson) {
          couponSearched.add(CouponModel.fromJson(item));
        }

        if (couponSearched.isNotEmpty) {
          _couponUsed = couponSearched[0];
        }

        couponUsed = _couponUsed;

        print(couponUsed.toString());
        loadingUse = false;
        notifyListeners();
      } else {
        couponSearched.clear();

        loadingUse = false;
        notifyListeners();
      }
    });
  }
}
