import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nyoba/models/cart_model.dart';
import 'package:nyoba/models/order_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/auth/login_screen.dart';
import 'package:nyoba/pages/order/checkout_native_screen.dart';
import 'package:nyoba/pages/order/order_success_screen.dart';
import 'package:nyoba/provider/checkout_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/services/order_api.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/webview/checkout_webview.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import 'coupon_provider.dart';

class OrderProvider with ChangeNotifier {
  ProductModel? productDetail;
  String? status;
  String? search;

  bool isLoading = false;
  bool loadDataOrder = false;

  List<OrderModel> listOrder = [];
  List<OrderModel> tempOrder = [];
  int orderPage = 1;

  List<ProductModel?> listProductOrder = [];
  List<ProductModel?> tempProductOrder = [];

  String? variationName = '';

  OrderModel? detailOrder;
  int cartCount = 0;

  Future checkout(order) async {
    var result;
    await OrderAPI().checkoutOrder(order).then((data) {
      printLog(data, name: 'Link Order From API');
      result = data;
    });
    return result;
  }

  bool cekInsert = true;
  Future<List?> fetchOrders({status, search, orderId}) async {
    isLoading = true;
    var result;
    await OrderAPI()
        .listMyOrder(status, search, orderId, orderPage)
        .then((data) {
      result = data;
      List _order = result;

      tempOrder = [];
      if (cekInsert) {
        tempOrder
            .addAll(_order.map((order) => OrderModel.fromJson(order)).toList());
      }

      List<OrderModel> list = List.from(listOrder);
      list.addAll(tempOrder);
      listOrder = list;
      if (listOrder.length < 10) {
        cekInsert = false;
      }
      if (tempOrder.length % 10 == 0) {
        orderPage++;
      }

      listOrder.forEach((element) {
        element.productItems!.sort((a, b) => b.image!.compareTo(a.image!));
      });

      isLoading = false;
      notifyListeners();
      printLog(result.toString());
    });
    return result;
  }

  Future<List?> fetchDetailOrder(orderId) async {
    isLoading = true;
    var result;
    await OrderAPI().detailOrder(orderId).then((data) {
      result = data;
      printLog(result.toString());

      for (Map item in result) {
        detailOrder = OrderModel.fromJson(item);
      }

      isLoading = false;
      notifyListeners();
      printLog(result.toString());
    });
    return result;
  }

  Future<dynamic> loadCartCount() async {
    print('Load Count');
    List<ProductModel> productCart = [];
    int _count = 0;

    if (Session.data.containsKey('cart')) {
      List listCart = await json.decode(Session.data.getString('cart')!);

      productCart = listCart
          .map((product) => new ProductModel.fromJson(product))
          .toList();

      productCart.forEach((element) {
        _count += element.cartQuantity!;
      });
    }

    cartCount = _count;
    notifyListeners();
    return _count;
  }

  Future checkOutOrder(context,
      {int? totalSelected,
      List<ProductModel>? productCart,
      Future<dynamic> Function()? removeOrderedItems}) async {
    final coupons = Provider.of<CouponProvider>(context, listen: false);
    final guestCheckoutActive =
        Provider.of<HomeProvider>(context, listen: false).guestCheckoutActive;

    if (totalSelected == 0) {
      return snackBar(context, message: "Please select the product first.");
    } else {
      if (!Session.data.getBool('isLogin')! && !guestCheckoutActive) {
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Login(
                      isFromNavBar: false,
                    )));
      }
      CartModel cart = new CartModel();
      cart.listItem = [];
      productCart!.forEach((element) {
        if (element.isSelected!) {
          var variation = {};
          if (element.selectedVariation!.isNotEmpty) {
            element.selectedVariation!.forEach((elementVar) {
              String columnName = elementVar.columnName!.toLowerCase();
              String? value = elementVar.value;

              variation['attribute_$columnName'] = "$value";
            });
          }
          cart.listItem!.add(new CartProductItem(
              productId: element.id,
              quantity: element.cartQuantity,
              variationId: element.variantId,
              variation: [variation]));
        }
      });

      //init list coupon
      cart.listCoupon = [];
      //check coupon
      if (coupons.couponUsed != null) {
        cart.listCoupon!.add(new CartCoupon(code: coupons.couponUsed!.code));
      }

      //add to cart model
      cart.paymentMethod = "xendit_bniva";
      cart.paymentMethodTitle = "Bank Transfer - BNI";
      cart.setPaid = true;
      cart.customerId = Session.data.getInt('id');
      cart.status = 'completed';
      cart.lang = Session.data.getString("language_code");
      cart.token = guestCheckoutActive && Session.data.getBool('isLogin')!
          ? Session.data.getString('cookie')
          : !guestCheckoutActive && Session.data.getBool('isLogin')!
              ? Session.data.getString('cookie')
              : "";

      if (guestCheckoutActive && Session.data.getBool('isLogin')!) {
        printLog('Set Cookie', name: "COOKIEP");
      } else {
        printLog('No Set Cookie', name: "COOKIEP");
      }

      //Encode Json
      final jsonOrder = json.encode(cart);
      printLog(jsonOrder, name: 'Json Order');

      //Convert Json to bytes
      var bytes = utf8.encode(jsonOrder);

      //Convert bytes to base64
      var order = base64.encode(bytes);

      //Generate link WebView checkout
      if (Provider.of<HomeProvider>(context, listen: false).checkoutFrom) {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CheckOutNative(
                      fromBuyNow: false,
                      line: cart.listItem,
                    )));
      } else {
        await Provider.of<OrderProvider>(context, listen: false)
            .checkout(order)
            .then((value) async {
          printLog(value, name: 'Link Order');
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CheckoutWebView(
                        url: value,
                        onFinish: removeOrderedItems,
                        fromCart: true,
                      )));
        });
      }
    }
  }

  Future onFinishBuyNow(context) async {
    //if (mounted) {
    print("masuk sini");
    await Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => OrderSuccess()));
    //}
  }

  Future buyNow(context,
      {ProductModel? product,
      Future<dynamic> Function()? onFinishBuyNow}) async {
    final guestCheckoutActive =
        Provider.of<HomeProvider>(context, listen: false).guestCheckoutActive;
    if (!Session.data.getBool('isLogin')! && !guestCheckoutActive) {
      return Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Login(
                    isFromNavBar: false,
                  )));
    }
    CartModel cart = new CartModel();
    cart.listItem = [];

    var variation = {};
    if (product!.selectedVariation!.isNotEmpty) {
      product.selectedVariation!.forEach((elementVar) {
        String columnName = elementVar.columnName!.toLowerCase();
        String? value = elementVar.value;

        variation['attribute_$columnName'] = "$value";
      });
    }
    cart.listItem!.add(new CartProductItem(
        productId: product.id,
        quantity: product.cartQuantity,
        variationId: product.variantId,
        variation: [variation]));

    printLog(jsonEncode(cart.listItem!), name: "ISI Cart");
    printLog(jsonEncode(cart), name: "ISI Cart2");

    //init list coupon
    cart.listCoupon = [];

    //add to cart model
    cart.paymentMethod = "xendit_bniva";
    cart.paymentMethodTitle = "Bank Transfer - BNI";
    cart.setPaid = true;
    cart.customerId = Session.data.getInt('id');
    cart.lang = Session.data.getString("language_code");
    cart.status = 'completed';
    cart.token = guestCheckoutActive && Session.data.getBool('isLogin')!
        ? Session.data.getString('cookie')
        : !guestCheckoutActive && Session.data.getBool('isLogin')!
            ? Session.data.getString('cookie')
            : "";

    //Encode Json
    final jsonOrder = json.encode(cart);
    printLog(jsonOrder, name: 'Json Order');

    //Convert Json to bytes
    var bytes = utf8.encode(jsonOrder);

    //Convert bytes to base64
    var order = base64.encode(bytes);

    //Generate link WebView checkout
    if (Provider.of<HomeProvider>(context, listen: false).checkoutFrom) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CheckOutNative(
                    fromBuyNow: false,
                    line: cart.listItem,
                  )));
    } else {
      await Provider.of<OrderProvider>(context, listen: false)
          .checkout(order)
          .then((value) async {
        printLog(value, name: 'Link Order');
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CheckoutWebView(
                      url: value,
                      onFinish: null,
                      fromCart: false,
                    )));
      });
    }
  }

  Future loadItemOrder(context) async {
    loadDataOrder = true;
    if (detailOrder != null) {
      listProductOrder.clear();
      detailOrder!.productItems!.forEach((element) async {
        await Provider.of<ProductProvider>(context, listen: false)
            .fetchProductDetail(element.productId.toString())
            .then((value) {
          listProductOrder.add(value);
        });
      });
      loadDataOrder = false;
    }
  }

  Future<void> actionBuyAgain(context) async {
    detailOrder!.productItems!.forEach((elementOrder) {
      listProductOrder.forEach((element) {
        if (element!.id == elementOrder.productId) {
          print('${element.id} == ${elementOrder.productId}');
          element.variationName = variationName;
          element.productName = elementOrder.productName;
          element.cartQuantity = elementOrder.quantity;
          element.variantId = elementOrder.variationId;
          element.showImage = elementOrder.image;
          element.priceTotal = element.productPrice! * element.cartQuantity!;
          element.attributes!.forEach((elementAttr) {
            elementOrder.metaData!.forEach((elementMeta) {
              if (elementAttr.name!.toLowerCase().replaceAll(" ", "-") ==
                  elementMeta.key) {
                elementAttr.selectedVariant = elementMeta.value;
              }
            });
          });
        }
      });
    });
    List<CartProductItem> line = [];
    for (int i = 0; i < listProductOrder.length; i++) {
      await addCart(listProductOrder[i], context);
      line.add(CartProductItem(
          productId: listProductOrder[i]!.id,
          quantity: listProductOrder[i]!.cartQuantity,
          variationId: listProductOrder[i]!.variantId,
          variation: listProductOrder[i]!.selectedVariation));
    }
    if (Provider.of<HomeProvider>(context, listen: false).syncCart) {
      Provider.of<CheckoutProvider>(context, listen: false)
          .createCart(line: line)
          .then((value) {
        if (value.toString().contains("error")) {
          return snackBar(context, message: "Failed to add cart");
        }
      });
    }
    snackBar(context,
        message: AppLocalizations.of(context)!.translate('add_cart_message')!);
  }

  /*add to cart*/
  Future addCart(ProductModel? product, context) async {
    /*check sharedprefs for cart*/
    if (!Session.data.containsKey('cart')) {
      List<ProductModel?> listCart = [];

      listCart.add(product);

      await Session.data.setString('cart', json.encode(listCart));
    } else {
      List products = await json.decode(Session.data.getString('cart')!);

      printLog(products.length.toString());
      printLog(products.toString(), name: 'Cart Product');

      List<ProductModel?> listCart =
          products.map((product) => ProductModel.fromJson(product)).toList();

      printLog(listCart.toString(), name: 'List Cart');

      int index = products.indexWhere((prod) =>
          prod["id"] == product!.id && prod["variant_id"] == product.variantId);

      if (index != -1) {
        product!.cartQuantity =
            listCart[index]!.cartQuantity! + product.cartQuantity!;

        listCart[index] = product;

        await Session.data.setString('cart', json.encode(listCart));
      } else {
        listCart.add(product);
        await Session.data.setString('cart', json.encode(listCart));
      }
    }
  }

  Future<List<ProductModel>> fetchProductCart(
      List<ProductModel> cartProduct) async {
    isLoading = true;
    List<ProductModel>? _temp = cartProduct;
    try {
      var result;
      List<String> _tempInclude = [];
      cartProduct.forEach((element) {
        _tempInclude.add(element.id.toString());
      });
      await OrderAPI().loadProductCart(_tempInclude.join(',')).then((data) {
        result = data;
        tempProductOrder = [];
        for (Map item in result) {
          tempProductOrder.add(ProductModel.fromJson(item));
        }

        printLog(json.encode(cartProduct), name: "temp product order");

        tempProductOrder.forEach((tp) {
          cartProduct.forEach((cp) {
            if (tp?.id == cp.id) {
              cp.productPrice = cp.productPrice;
              cp.productRegPrice = cp.productRegPrice;
              cp.productSalePrice = cp.productSalePrice;
              cp.discProduct = tp?.discProduct;
              cp.stockStatus = tp?.stockStatus;
              cp.showImage = cp.images![0].src;
              printLog(cp.images![0].src.toString(), name: "image variant");
              cp.minMaxQuantity = tp?.minMaxQuantity;
              cp.manageStock = tp?.manageStock;
              cp.productStock = tp?.productStock;
              if (cp.type == 'simple' && cp.cartQuantity! > cp.productStock!) {
                cp.cartQuantity = 1;
              }
              cp.priceTotal = cp.cartQuantity! * tp!.productPrice!;

              if (cp.type == 'variable') {
                tp.availableVariations?.forEach((elvar) {
                  if (elvar.variationId == cp.variantId) {
                    cp.productPrice = elvar.displayPrice;
                    cp.productRegPrice = elvar.displayRegularPrice.toString();
                    cp.stockStatus =
                        elvar.isInStock! ? 'instock' : 'outofstock';
                    cp.productStock = elvar.maxQty;
                    if (cp.cartQuantity! > cp.productStock!) {
                      cp.cartQuantity = 1;
                    }
                    cp.priceTotal = cp.cartQuantity! * elvar.displayPrice;

                    printLog(
                        "Variable ${cp.variantId} ${cp.productName} ${cp.stockStatus} ${cp.productStock}");
                  }
                });
              }
              if (cp.stockStatus == 'outofstock' || cp.productStock == 0) {
                cp.isProductAvailable = false;
                cp.isSelected = false;
              } else {
                cp.isProductAvailable = true;
                cp.isSelected = true;
              }
            }
          });
        });

        _temp = cartProduct;

        isLoading = false;
        notifyListeners();
        printLog(result.toString());
      });
      return _temp!;
    } catch (e) {
      printLog(e.toString(), name: 'Load Cart Error');
      isLoading = false;
      notifyListeners();
      return _temp!;
    }
  }

  resetPage() {
    orderPage = 1;
    cekInsert = true;
    listOrder = [];
    tempOrder = [];
    isLoading = true;
    notifyListeners();
  }
}
