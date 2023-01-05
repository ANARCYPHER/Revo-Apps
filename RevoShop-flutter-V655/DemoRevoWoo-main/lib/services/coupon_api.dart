import 'dart:convert';

import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/models/coupon_model.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class CouponAPI {
  //OLD FETCH
  fetchListCoupon(page) async {
    var response = await baseAPI.getAsync('$coupon?page=$page&per_page=50');
    return response;
  }

  newFetchListCoupon() async {
    Map data = {'cookie': Session.data.getString('cookie')};
    var response = await baseAPI.postAsync('$listCoupon', data, isCustom: true);
    return response;
  }

  //OLD USE COUPON
  searchCoupon(code) async {
    var response =
        await baseAPI.getAsync('$coupon?code=$code&page=1&per_page=1');
    return response;
  }

  newSearchCoupon({List<SearchCouponModel>? products, String? code}) async {
    Map data = {
      'cookie': Session.data.getString('cookie'),
      'coupon_code': code,
      'products': products
    };
    printLog("data request use coupon : ${json.encode(data)}");
    var response =
        await baseAPI.postAsync('$applyCoupon', data, isCustom: true);
    printLog("use coupon : ${json.encode(response)}");
    return response;
  }
}
