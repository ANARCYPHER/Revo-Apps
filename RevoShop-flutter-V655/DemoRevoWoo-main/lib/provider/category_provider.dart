import 'package:flutter/foundation.dart';
import 'package:nyoba/models/categories_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'dart:convert';
import 'package:nyoba/services/categories_api.dart';
import 'package:nyoba/services/product_api.dart';
import 'package:nyoba/utils/utility.dart';

class CategoryProvider with ChangeNotifier {
  CategoriesModel? category;
  bool loading = true;
  bool loadingAll = true;
  bool loadingProductCategories = true;
  bool loadingSub = false;

  List<CategoriesModel> categories = [];
  List<ProductCategoryModel> productCategories = [];

  List<AllCategoriesModel> allCategories = [];
  List<AllCategoriesModel> subCategories = [];
  List<PopularCategoriesModel> popularCategories = [];
  int? currentSelectedCategory;
  int? currentSelectedCountSub;
  int? currentPage;

  List<ProductModel> listProductCategory = [];
  List<ProductModel> listTempProduct = [];

  CategoryProvider() {
    // fetchCategories();
    // fetchProductCategories();
  }

  Future<bool> fetchCategories() async {
    await CategoriesAPI().fetchCategories().then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        for (Map item in responseJson) {
          categories.add(CategoriesModel.fromJson(item));
        }
        categories.add(new CategoriesModel(
            image: 'images/lobby/viewMore.png',
            categories: null,
            id: null,
            titleCategories: 'View More'));
        loading = false;
        notifyListeners();
      } else {
        loading = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchProductCategories() async {
    loadingProductCategories = true;
    //notifyListeners();
    await CategoriesAPI().fetchProductCategories().then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        productCategories.clear();
        for (Map item in responseJson) {
          productCategories.add(ProductCategoryModel.fromJson(item));
        }
        loadingProductCategories = false;
        notifyListeners();
      } else {
        loadingProductCategories = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchAllCategories() async {
    var result;
    allCategories.clear();
    await CategoriesAPI().fetchAllCategories().then((data) {
      result = data;
      printLog(result.toString());
      for (Map item in result) {
        allCategories.add(AllCategoriesModel.fromJson(item));
      }
      loadingAll = false;
      notifyListeners();
    });
    return true;
  }

  resetData() {
    allCategories.clear();
    subCategories.clear();
    listProductCategory.clear();
    currentSelectedCategory = 0;
    notifyListeners();
  }

  Future<bool> fetchSubCategories(int? parent, page) async {
    loadingSub = true;
    await CategoriesAPI()
        .fetchSubCategories(parent: parent, page: page)
        .then((data) {
      printLog("Data sub : ${json.encode(data)}");
      if (data.isNotEmpty) {
        final responseJson = data;

        if (page == 1) {
          subCategories.clear();
        }

        for (Map item in responseJson) {
          subCategories.add(AllCategoriesModel.fromJson(item));
        }
        loadingSub = false;
        notifyListeners();
      } else {
        loadingSub = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchPopularCategories() async {
    loadingSub = true;
    await CategoriesAPI().fetchPopularCategories().then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        popularCategories.clear();
        for (Map item in responseJson) {
          popularCategories.add(PopularCategoriesModel.fromJson(item));
        }
        loadingSub = false;
        notifyListeners();
      } else {
        loadingSub = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchProductsCategory(String category, {int page = 1}) async {
    loadingSub = true;
    await ProductAPI()
        .fetchProduct(category: category, page: page, perPage: 5)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        if (page == 1) {
          listProductCategory.clear();
        }

        int count = 0;

        for (Map item in responseJson) {
          listProductCategory.add(ProductModel.fromJson(item));
          count++;
        }

        if (count >= 5) {
          listProductCategory.add(ProductModel());
        }

        loadingSub = false;
        notifyListeners();
      } else {
        loadingSub = false;
        notifyListeners();
      }
    });
    return true;
  }
}
