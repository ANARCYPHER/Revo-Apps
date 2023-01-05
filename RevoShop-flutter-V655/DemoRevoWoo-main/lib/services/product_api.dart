import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/models/attribute_filter_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class ProductAPI {
  fetchProduct({
    String include = '',
    bool? featured,
    int page = 1,
    int perPage = 8,
    String parent = '',
    String search = '',
    String category = '',
    String productId = '',
    String slug = '',
  }) async {
    Map data = {
      if (include.isNotEmpty) "include": include,
      "page": page,
      "per_page": perPage,
      "lang": Session.data.getString("language_code"),
      "cookie": Session.data.containsKey("cookie")
          ? Session.data.getString('cookie')
          : null,
      if (parent.isNotEmpty) "parent": parent,
      if (search.isNotEmpty) "search": search,
      if (category.isNotEmpty) "category": category,
      if (slug.isNotEmpty) "slug": slug,
      if (productId.isNotEmpty) "id": productId,
      if (featured != null) "featured": featured,
    };

    printLog(data.toString(), name: "Data Param Product");

    var response =
        await baseAPI.postAsync(customProductUrl, data, isCustom: true);
    return response;
  }

  fetchExtendProduct(String type) async {
    var response =
        await baseAPI.getAsync('$extendProducts?type=$type', isCustom: true);
    return response;
  }

  fetchRecentViewProducts() async {
    Map data = {"cookie": Session.data.getString('cookie')};
    var response =
        await baseAPI.postAsync('$recentProducts', data, isCustom: true);
    printLog(Session.data.getString('cookie')!);
    return response;
  }

  hitViewProductsAPI(productId) async {
    Map data = {
      "cookie": Session.data.getString('cookie'),
      "product_id": productId,
      "ip_address": Session.data.getString('ip')
    };
    var response =
        await baseAPI.postAsync('$hitViewedProducts', data, isCustom: true);
    printLog(Session.data.getString('cookie')!);
    return response;
  }

  fetchDetailProduct(String? productId) async {
    Map data = {
      "id": productId,
      "lang": Session.data.getString("language_code"),
      "cookie": Session.data.containsKey("cookie")
          ? Session.data.getString('cookie')
          : null,
    };
    printLog("data detail product : $data");
    var response =
        await baseAPI.postAsync(customProductUrl, data, isCustom: true);
    printLog("response detail product : $response");
    return response;
  }

  fetchDetailProductSlug(String? slug) async {
    Map data = {
      "slug": slug,
      "lang": Session.data.getString("language_code"),
      "cookie": Session.data.containsKey("cookie")
          ? Session.data.getString("cookie")
          : null,
    };
    var response =
        await baseAPI.postAsync(customProductUrl, data, isCustom: true);
    return response;
  }

  searchProduct({String search = '', String category = '', int? page}) async {
    Map data = {
      "page": page,
      "lang": Session.data.getString("language_code"),
      "cookie": Session.data.containsKey("cookie")
          ? Session.data.getString("cookie")
          : null,
      if (search.isNotEmpty) "search": search,
      if (category.isNotEmpty) "category": category,
    };
    var response =
        await baseAPI.postAsync(customProductUrl, data, isCustom: true);
    return response;
  }

  checkVariationProduct(int? productId, List<ProductVariation>? list) async {
    Map data = {
      "product_id": productId,
      "variation": list,
      "cookie": Session.data.containsKey('cookie')
          ? Session.data.getString('cookie')
          : "",
    };
    printLog(data.toString());
    var response = await baseAPI.postAsync(
      '$checkVariations',
      data,
      isCustom: true,
    );
    return response;
  }

  fetchBrandProduct(
      {int? page = 1,
      int perPage = 8,
      String search = '',
      String category = '',
      String order = 'desc',
      String orderBy = 'popularity',
      String attribute = '',
      String? slug,
      List<AttributeFilter>? attributeFilter}) async {
    Map data = {
      "page": page,
      "per_page": perPage,
      "lang": Session.data.getString("language_code"),
      "order": order,
      "order_by": orderBy,
      "cookie": Session.data.containsKey("cookie")
          ? Session.data.getString('cookie')
          : null,
      "slug_category": slug,
      if (search.isNotEmpty) "search": search,
      "category": category,
      if (attribute.isNotEmpty) "attribute": attribute,
      if (attributeFilter != null && attributeFilter.isNotEmpty)
        "attribute": attributeFilter
    };

    printLog(data.toString(), name: 'Param Brand');
    var response =
        await baseAPI.postAsync(customProductUrl, data, isCustom: true);
    return response;
  }

  reviewProduct({String productId = ''}) async {
    var response =
        await baseAPI.getAsync('$reviewProductUrl?product=$productId');
    return response;
  }

  reviewProductLimit({String productId = ''}) async {
    var response = await baseAPI
        .getAsync('$reviewProductUrl?product=$productId&per_page=1&page=1');
    return response;
  }

  fetchMoreProduct(
      {int? page = 1,
      int perPage = 8,
      String search = '',
      String? include = '',
      String category = '',
      String order = 'desc',
      String? orderBy = 'popularity',
      bool? featured}) async {
    Map data = {
      if (include!.isNotEmpty) "include": include,
      "page": page,
      "per_page": perPage,
      "lang": Session.data.getString("language_code"),
      if (search.isNotEmpty) "search": search,
      if (category.isNotEmpty) "category": category,
      "order": order,
      "order_by": orderBy,
      if (featured != null) "featured": featured,
      "cookie": Session.data.containsKey("cookie")
          ? Session.data.getString('cookie')
          : null,
    };

    printLog(data.toString(), name: "Data Param Product");

    var response =
        await baseAPI.postAsync(customProductUrl, data, isCustom: true);

    return response;
  }

  scanProductAPI(String? code) async {
    Map data = {"code": code};
    printLog(data.toString());
    var response = await baseAPI.postAsync(
      '$getBarcodeUrl',
      data,
      isCustom: true,
    );
    return response;
  }

  productVariations({String? productId = ''}) async {
    var response = await baseAPI.getAsync('$product/$productId/variations');
    return response;
  }

  filterData(String? category) async {
    Map data = {"category": category};
    var response =
        await baseAPI.postAsync('$dataFilterAttr', data, isCustom: true);
    return response;
  }
}
