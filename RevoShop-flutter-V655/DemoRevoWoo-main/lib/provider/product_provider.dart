import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/attribute_filter_model.dart';
import 'package:nyoba/models/filter_data_model.dart';
import 'package:nyoba/models/product_extend_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/models/review_model.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/services/product_api.dart';
import 'package:nyoba/services/review_api.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

class ProductProvider with ChangeNotifier {
  bool loadingFeatured = false;
  bool loadingBestDeals = false;
  bool loadingNew = false;

  bool loadingExtends = true;
  bool loadingSpecial = true;
  bool loadingBest = true;
  bool loadingRecommendation = true;
  bool loadingDetail = true;
  bool loadingCategory = false;
  bool loadingBrand = false;
  bool loadingMore = true;

  bool loadingReview = false;
  bool loadAddReview = false;
  bool loadingRecent = false;

  String? message;

  List<ProductModel> listFeaturedProduct = [];
  List<ProductModel> listMoreFeaturedProduct = [];

  List<ProductModel> listBestDeal = [];

  List<ProductModel> listNewProduct = [];
  List<ProductModel> listMoreNewProduct = [];

  List<ProductModel> listSpecialProduct = [];
  List<ProductModel> listMoreSpecialProduct = [];

  List<ProductModel> listBestProduct = [];
  List<ProductModel> listRecentProduct = [];
  List<ProductModel> listRecommendationProduct = [];
  List<ProductModel> listCategoryProduct = [];
  List<ProductModel> listBrandProduct = [];

  List<ProductModel> listMoreExtendProduct = [];
  List<ProductModel> listTempProduct = [];

  List<ReviewHistoryModel> listReviewLimit = [];

  List<AttributeFilter>? attributeFilter = [];
  String? paramAttrFilter;

  late ProductExtendModel productSpecial;
  late ProductExtendModel productBest;
  late ProductExtendModel productRecommendation;

  String? productRecent;

  ProductModel? productDetail;

  // Image Review Product
  List<XFile>? imageFileList = [];
  List<XFile>? imageFileInvalidList = [];
  List<String>? imageBase64 = [];

  dynamic pickImageError;
  String? retrieveDataError;
  final ImagePicker _picker = ImagePicker();

  ProductProvider() {
    fetchFeaturedProducts();
    fetchExtendProducts('our_best_seller');
    fetchExtendProducts('special');
    fetchExtendProducts('recomendation');
  }

  Future<bool> fetchFeaturedProducts(
      {int page = 1, String? order = '', String? orderBy = ''}) async {
    loadingFeatured = true;
    await ProductAPI()
        .fetchMoreProduct(
            page: page, order: order!, orderBy: orderBy, featured: true)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        if (page == 1) {
          listFeaturedProduct.clear();
          listMoreFeaturedProduct.clear();
        }

        for (Map item in responseJson) {
          if (page == 1) {
            listFeaturedProduct.add(ProductModel.fromJson(item));
          }
          listMoreFeaturedProduct.add(ProductModel.fromJson(item));
        }

        loadingFeatured = false;
        notifyListeners();
      } else {
        loadingFeatured = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchNewProducts(String category, {int page = 1}) async {
    loadingNew = true;
    await ProductAPI()
        .fetchProduct(category: category, page: page)
        .then((data) {
      if (data != null) {
        final responseJson = data;
        printLog(responseJson.toString(), name: "response new produk");

        if (page == 1) {
          listNewProduct.clear();
          listMoreNewProduct.clear();
        }
        for (Map item in responseJson) {
          if (page == 1) {
            listNewProduct.add(ProductModel.fromJson(item));
            listMoreNewProduct.add(ProductModel.fromJson(item));
          } else {
            listMoreNewProduct.add(ProductModel.fromJson(item));
          }
        }
        for (int i = 0; i < listNewProduct.length; i++) {
          if (listNewProduct[i].type == 'variable') {
            for (int j = 0;
                j < listNewProduct[i].availableVariations!.length;
                j++) {
              if (listNewProduct[i]
                          .availableVariations![j]
                          .displayRegularPrice -
                      listNewProduct[i].availableVariations![j].displayPrice !=
                  0) {
                double temp = ((listNewProduct[i]
                                .availableVariations![j]
                                .displayRegularPrice -
                            listNewProduct[i]
                                .availableVariations![j]
                                .displayPrice) /
                        listNewProduct[i]
                            .availableVariations![j]
                            .displayRegularPrice) *
                    100;
                if (listNewProduct[i].discProduct! < temp) {
                  listNewProduct[i].discProduct = temp;
                }
              }
            }
          }
        }

        loadingNew = false;
        notifyListeners();
      } else {
        loadingNew = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchExtendProducts(type) async {
    await ProductAPI().fetchExtendProduct(type).then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        for (Map item in responseJson) {
          if (type == 'our_best_seller') {
            productBest = ProductExtendModel.fromJson(item);
          } else if (type == 'special') {
            productSpecial = ProductExtendModel.fromJson(item);
          } else if (type == 'recomendation') {
            productRecommendation = ProductExtendModel.fromJson(item);
          }
        }
        notifyListeners();
      } else {
        notifyListeners();
        print("Load Extend Failed");
      }
    });
    return true;
  }

  Future<bool> fetchRecentProducts() async {
    await ProductAPI().fetchRecentViewProducts().then((data) {
      if (data["products"].toString().isNotEmpty) {
        productRecent = data["products"];
        this.fetchListRecentProducts(productRecent);
      }
      notifyListeners();
    });
    return true;
  }

  Future<bool> fetchListRecentProducts(productId) async {
    await ProductAPI()
        .fetchMoreProduct(
            include: productId, order: 'desc', orderBy: 'popularity')
        .then((data) {
      if (data != null) {
        final responseJson = data;

        listRecentProduct.clear();
        for (Map item in responseJson) {
          listRecentProduct.add(ProductModel.fromJson(item));
        }

        loadingRecent = false;
        notifyListeners();
      } else {
        print("Load Recent Failed");
        loadingRecent = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> hitViewProducts(productId) async {
    await ProductAPI().hitViewProductsAPI(productId).then((data) {
      notifyListeners();
    });
    return true;
  }

  Future<ProductModel?> fetchProductDetail(String? productId) async {
    loadingDetail = true;
    await ProductAPI().fetchDetailProduct(productId).then((data) {
      if (data != null) {
        final responseJson = data;
        // printLog("detail product : $data");
        productDetail = ProductModel.fromJson(responseJson.first);

        loadingDetail = false;
        notifyListeners();
      } else {
        print("Load Failed");
        loadingDetail = false;
        notifyListeners();
      }
    });
    return productDetail;
  }

  Future<ProductModel?> fetchProductDetailSlug(String? slug) async {
    loadingDetail = true;
    await ProductAPI().fetchDetailProductSlug(slug).then((data) {
      if (data != null) {
        final responseJson = data;

        for (Map item in responseJson) {
          productDetail = ProductModel.fromJson(item);
        }

        notifyListeners();
      } else {
        print("Load Failed");
        notifyListeners();
      }
    });
    return productDetail;
  }

  Future<Map<String, dynamic>?> checkVariation({productId, list}) async {
    var result;
    await ProductAPI().checkVariationProduct(productId, list).then((data) {
      result = data;
      notifyListeners();
      printLog(json.encode(result));
    });
    return result;
  }

  Future<bool> fetchCategoryProduct(
      String category, int page, String order, String orderBy) async {
    loadingCategory = true;
    await ProductAPI()
        .fetchBrandProduct(
            order: order, orderBy: 'rand', page: page, perPage: 20)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        if (page == 1) {
          listCategoryProduct.clear();
        }
        for (Map item in responseJson) {
          listCategoryProduct.add(ProductModel.fromJson(item));
        }

        loadingCategory = false;
        notifyListeners();
      } else {
        loadingCategory = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchBrandProductBySlug(
      {String? category,
      int? page,
      String? order,
      String? orderBy,
      String? attribute,
      String? slug}) async {
    loadingBrand = true;
    await ProductAPI()
        .fetchBrandProduct(
            page: page, attributeFilter: attributeFilter, slug: slug)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        listTempProduct.clear();
        if (page == 1) {
          listBrandProduct.clear();
        }
        for (Map item in responseJson) {
          listBrandProduct.add(ProductModel.fromJson(item));
        }
        for (int i = 0; i < listBrandProduct.length; i++) {
          if (listBrandProduct[i].type == 'variable') {
            for (int j = 0;
                j < listBrandProduct[i].availableVariations!.length;
                j++) {
              if (listBrandProduct[i]
                          .availableVariations![j]
                          .displayRegularPrice -
                      listBrandProduct[i]
                          .availableVariations![j]
                          .displayPrice !=
                  0) {
                double temp = ((listBrandProduct[i]
                                .availableVariations![j]
                                .displayRegularPrice -
                            listBrandProduct[i]
                                .availableVariations![j]
                                .displayPrice) /
                        listBrandProduct[i]
                            .availableVariations![j]
                            .displayRegularPrice) *
                    100;
                if (listBrandProduct[i].discProduct! < temp) {
                  listBrandProduct[i].discProduct = temp;
                }
              }
            }
          }
        }

        loadingBrand = false;
        notifyListeners();
      } else {
        loadingBrand = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchBrandProduct(
      {String? category,
      int? page,
      String? order,
      String? orderBy,
      String? attribute,
      String? slug}) async {
    loadingBrand = true;
    await ProductAPI()
        .fetchBrandProduct(
            category: category!,
            order: order!,
            orderBy: orderBy!,
            page: page,
            attribute: attribute!,
            attributeFilter: attributeFilter,
            slug: slug)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        listTempProduct.clear();
        if (page == 1) {
          listBrandProduct.clear();
        }
        for (Map item in responseJson) {
          listBrandProduct.add(ProductModel.fromJson(item));
        }
        for (int i = 0; i < listBrandProduct.length; i++) {
          if (listBrandProduct[i].type == 'variable') {
            for (int j = 0;
                j < listBrandProduct[i].availableVariations!.length;
                j++) {
              if (listBrandProduct[i]
                          .availableVariations![j]
                          .displayRegularPrice -
                      listBrandProduct[i]
                          .availableVariations![j]
                          .displayPrice !=
                  0) {
                double temp = ((listBrandProduct[i]
                                .availableVariations![j]
                                .displayRegularPrice -
                            listBrandProduct[i]
                                .availableVariations![j]
                                .displayPrice) /
                        listBrandProduct[i]
                            .availableVariations![j]
                            .displayRegularPrice) *
                    100;
                if (listBrandProduct[i].discProduct! < temp) {
                  listBrandProduct[i].discProduct = temp;
                }
              }
            }
          }
        }

        loadingBrand = false;
        notifyListeners();
      } else {
        loadingBrand = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<List<String>> generateImageBase64() async {
    loadAddReview = true;
    List<String> _temp = [];
    if (imageFileList!.isNotEmpty) {
      imageBase64 = [];

      for (var element in imageFileList!) {
        final file = File(element.path);
        final bytes = file.readAsBytesSync().lengthInBytes;
        final kb = bytes / 1024;
        List<int> imageBytes = await file.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        printLog(kb.toString(), name: 'File Size KB');
        imageBase64!.add(base64Image);
        printLog(imageBase64.toString(), name: 'ListBase64');
      }
      _temp = imageBase64!;
      printLog(_temp.toString(), name: 'Temps');
    }
    notifyListeners();
    return _temp;
  }

  Future<Map<String, dynamic>?> addReview(context,
      {productId, review, rating}) async {
    loadAddReview = true;
    var result;

    try {
      printLog(imageBase64.toString(), name: 'Image Base64');

      await ReviewAPI()
          .inputReview(productId, review, rating, image: imageBase64)
          .then((data) {
        result = data;

        if (result['status'] == 'success') {
          imageBase64 = [];
          Navigator.pop(context);
          snackBar(context,
              message:
                  '${AppLocalizations.of(context)!.translate('success_review')}');
        } else {
          snackBar(context, message: 'Error, ${result['message']}');
        }
        loadAddReview = false;

        notifyListeners();
        printLog(result.toString());
      });
      return result;
    } catch (e) {
      result = {"message": "$e"};
      loadAddReview = false;
      notifyListeners();
      return result;
    }
  }

  Future<bool> fetchMoreExtendProduct(String? productId,
      {int? page, required String order, String? orderBy}) async {
    loadingMore = true;
    await ProductAPI()
        .fetchMoreProduct(
            include: productId, page: page, order: order, orderBy: orderBy)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        listTempProduct.clear();
        if (page == 1) {
          listMoreExtendProduct.clear();
        }
        for (Map item in responseJson) {
          listMoreExtendProduct.add(ProductModel.fromJson(item));
        }

        loadingMore = false;
        notifyListeners();
      } else {
        print("Load Failed");
        loadingMore = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchBestDeals(
      {int page = 1, String? order = 'desc', String? orderBy = 'rand'}) async {
    loadingBestDeals = true;
    await ProductAPI()
        .fetchMoreProduct(
            page: page, order: order!, orderBy: orderBy, perPage: 20)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        if (page == 1) {
          listBestDeal.clear();
        }

        for (Map item in responseJson) {
          listBestDeal.add(ProductModel.fromJson(item));
        }

        loadingBestDeals = false;
        notifyListeners();
      } else {
        loadingBestDeals = false;
        notifyListeners();
      }
    });
    return true;
  }

  setAttributeFilter(FilterDataModel filter) {
    attributeFilter!.clear();
    filter.dataFilter!.forEach((element) {
      List<TermFilter> termFilter = element.termFilter;
      List<String> terms = [];
      termFilter.forEach((e) {
        if (e.isSelected!) {
          terms.add(e.name!);
        }
      });
      if (terms.isNotEmpty) {
        attributeFilter!.add(new AttributeFilter(
            taxonomy: element.taxonomy,
            field: 'slug',
            operator: 'IN',
            terms: terms));
      }
    });
    notifyListeners();
  }

  void _setImageFileListFromFile(XFile? value) {
    imageFileList = value == null ? null : <XFile>[value];
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.files == null) {
        _setImageFileListFromFile(response.file);
      } else {
        imageFileList = response.files;
      }
    } else {
      retrieveDataError = response.exception!.code;
    }
  }

  Future<void> onImageButtonPressed(
      BuildContext context, ImageSource source) async {
    try {
      final maxSize =
          Provider.of<HomeProvider>(context, listen: false).photoMaxSize;
      final maxFiles =
          Provider.of<HomeProvider>(context, listen: false).photoMaxFiles;

      imageFileInvalidList = [];

      final List<XFile>? pickedFileList = await _picker.pickMultiImage();

      pickedFileList!.forEach((element) async {
        final file = File(element.path);
        final bytes = file.readAsBytesSync().lengthInBytes;
        final kb = bytes / 1024;

        if (kb < maxSize!) {
          printLog(imageFileList!.length.toString());
          if (imageFileList!.length < maxFiles!) {
            imageFileList!.add(element);
          } else {
            imageFileInvalidList!.add(element);
          }
        } else {
          imageFileInvalidList!.add(element);
        }
      });

      printLog("${imageFileList!.length}", name: 'Image Total');
      notifyListeners();
    } catch (e) {
      pickImageError = e;
      notifyListeners();
    }
  }

  setRetrieveDataError() {
    retrieveDataError = null;
    notifyListeners();
  }

  reset() {
    loadingBrand = true;
    attributeFilter = [];
    notifyListeners();
  }

  resetReview() {
    imageFileList = [];
    imageFileInvalidList = [];
    imageBase64 = [];
    notifyListeners();
  }
}
