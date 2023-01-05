import 'package:flutter/foundation.dart';
import 'package:nyoba/models/product_model.dart';
import 'dart:convert';
import 'package:nyoba/services/flash_sale_api.dart';
import 'package:nyoba/models/flash_sale_model.dart';

import 'package:nyoba/services/product_api.dart';

class FlashSaleProvider with ChangeNotifier {
  FlashSaleModel? flashSale;
  bool loading = true;
  List<FlashSaleModel> flashSales = [];
  List<ProductModel> flashSaleProducts = [];

  FlashSaleProvider() {
    fetchFlashSale();
  }

  Future<bool> fetchFlashSale() async {
    loading = true;
    await FlashSaleAPI().fetchHomeFlashSale().then((data) async {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        for (Map item in responseJson) {
          flashSales.add(FlashSaleModel.fromJson(item));
        }
        loading = false;
        notifyListeners();
        if (flashSales.isNotEmpty) {
          fetchFlashSaleProducts(flashSales.first.products!);
        }
      } else {
        loading = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchFlashSaleProducts(String productId) async {
    loading = true;
    await ProductAPI().fetchProduct(include: productId).then((data) {
      if (data != null) {
        final responseJson = data;

        flashSaleProducts.clear();
        for (Map item in responseJson) {
          flashSaleProducts.add(ProductModel.fromJson(item));
        }
        loading = false;

        notifyListeners();
      } else {
        print("Load Failed");
        loading = false;
        notifyListeners();
      }
    });
    return true;
  }
}
