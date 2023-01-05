import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nyoba/models/review_model.dart';
import 'package:nyoba/models/review_product_model.dart';
import 'package:nyoba/services/review_api.dart';
import 'package:nyoba/utils/utility.dart';

class ReviewProvider with ChangeNotifier {
  bool isLoading = false;
  bool isLoadingReview = false;

  List<ReviewHistoryModel> listHistory = [];
  List<ReviewProduct> listReviewLimit = [];

  List<ReviewProduct> listReviewAllStar = [];
  List<ReviewProduct> listReviewFiveStar = [];
  List<ReviewProduct> listReviewFourStar = [];
  List<ReviewProduct> listReviewThreeStar = [];
  List<ReviewProduct> listReviewTwoStar = [];
  List<ReviewProduct> listReviewOneStar = [];

  Future<List?> fetchHistoryReview() async {
    isLoading = !isLoading;
    var result;
    await ReviewAPI().historyReview().then((data) {
      result = data;

      listHistory.clear();

      printLog(result.toString());

      for (Map item in result) {
        listHistory.add(ReviewHistoryModel.fromJson(item));
      }

      isLoading = !isLoading;
      notifyListeners();
      printLog(result.toString());
    });
    return result;
  }

  Future<List?> fetchReviewProduct(productId) async {
    isLoadingReview = true;
    listReviewAllStar.clear();
    listReviewOneStar.clear();
    listReviewTwoStar.clear();
    listReviewThreeStar.clear();
    listReviewFourStar.clear();
    listReviewFiveStar.clear();
    var result;
    await ReviewAPI().productReview(productId).then((data) {
      if (data.statusCode == 200) {
        result = json.decode(data.body);
        printLog(result.toString());

        for (Map item in result) {
          if (item['status'] == 'approved') {
            listReviewAllStar.add(ReviewProduct.fromJson(item));
          }
        }

        if (listReviewAllStar.isNotEmpty) {
          listReviewLimit.add(listReviewAllStar.first);
        }

        listReviewAllStar.forEach((element) {
          if (element.rating! == 5) {
            listReviewFiveStar.add(element);
          } else if (element.rating! == 4) {
            listReviewFourStar.add(element);
          } else if (element.rating! == 3) {
            listReviewThreeStar.add(element);
          } else if (element.rating! == 2) {
            listReviewTwoStar.add(element);
          } else if (element.rating! == 1) {
            listReviewOneStar.add(element);
          }
        });
      }

      isLoadingReview = false;
      notifyListeners();
      printLog(result.toString());
    });
    return result;
  }
}
