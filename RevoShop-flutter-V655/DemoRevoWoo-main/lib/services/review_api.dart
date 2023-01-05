import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class ReviewAPI {
  historyReview() async {
    Map data = {
      "cookie": Session.data.getString('cookie'),
    };
    printLog(data.toString());
    var response = await baseAPI.postAsync(
      '$historyReviewUrl',
      data,
      isCustom: true,
    );
    return response;
  }

  inputReview(productId, review, rating, {List<String>? image}) async {
    Map data = {
      "product_id": productId,
      "comments": review,
      "cookie": Session.data.getString('cookie'),
      "rating": rating,
      if (image != null) "image": image
    };
    printLog(data.toString());
    var response =
        await baseAPI.postAsync('$addReviewUrl', data, isCustom: true);
    return response;
  }

  productReview(productId) async {
    var response = await baseAPI.getAsync(
      'products/reviews?product=$productId',
      isCustom: true,
    );
    return response;
  }
}
