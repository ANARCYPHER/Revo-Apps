import 'package:flutter/material.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/product/product_detail_screen.dart';
import 'package:nyoba/services/product_api.dart';
import 'package:nyoba/utils/utility.dart';

class SearchProvider with ChangeNotifier {
  bool loadingSearch = false;
  bool loadingQr = false;

  String? message;

  List<ProductModel> listSearchProducts = [];

  String? productWishlist;

  Future<bool> searchProducts(String search, int page) async {
    loadingSearch = true;
    await ProductAPI().searchProduct(search: search, page: page).then((data) {
      if (data != null) {
        final responseJson = data;

        printLog(responseJson.toString(), name: 'Wishlist');
        if (page == 1) listSearchProducts.clear();
        if (search.isNotEmpty) {
          for (Map item in responseJson) {
            listSearchProducts.add(ProductModel.fromJson(item));
          }
        }

        loadingSearch = false;
        notifyListeners();
      } else {
        print("Load Failed");
        loadingSearch = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> scanProduct(String? code, context) async {
    loadingQr = true;
    await ProductAPI().scanProductAPI(code).then((data) {
      if (data['id'] != null) {
        loadingQr = false;
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetail(
                      productId: data['id'].toString(),
                    )));
      } else if (data['status'] == 'error') {
        loadingQr = false;
        Navigator.pop(context);
        snackBar(context, message: "Product not found", color: Colors.red);
      }
      loadingQr = false;
      notifyListeners();
    });
    return true;
  }
}
