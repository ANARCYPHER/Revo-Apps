import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class CategoriesAPI {
  fetchCategories({String showPopular = ''}) async {
    var response = await baseAPI.getAsync('$category?show_popular=$showPopular',
        isCustom: true);
    return response;
  }

  fetchProductCategories({int? parent, page}) async {
    String? code = Session.data.getString("language_code");
    //var url = '$productCategories?parent=$parent&page=$page&per_page=30'; --OLD URL
    var url = '$productCategories?_embed&lang=$code';
    var response = await baseAPI.getAsync('$url', printedLog: true);
    printLog("Product Categories : ${response.body}");
    return response;
  }

  fetchPopularCategories() async {
    var response = await baseAPI.getAsync('$popularCategories', isCustom: true);
    return response;
  }

  fetchSubCategories({int? parent, page}) async {
    Map data = {
      "lang": Session.data.getString("language_code"),
      "parent": parent
    };
    printLog(data.toString());
    var response = await baseAPI.postAsync(
      '$allCategoriesUrl',
      data,
      isCustom: true,
    );
    return response;
  }

  fetchAllCategories() async {
    Map data = {"lang": Session.data.getString("language_code")};
    printLog(data.toString());
    var response = await baseAPI.postAsync(
      '$allCategoriesUrl',
      data,
      isCustom: true,
    );
    return response;
  }
}
