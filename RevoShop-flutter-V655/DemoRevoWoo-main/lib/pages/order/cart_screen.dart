import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:nyoba/models/cart_model.dart';
import 'package:nyoba/models/coupon_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/order/order_success_screen.dart';
import 'package:nyoba/pages/product/product_detail_screen.dart';
import 'package:nyoba/provider/coupon_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/services/order_api.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_localizations.dart';
import 'coupon_screen.dart';
import '../../utils/utility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CartScreen extends StatefulWidget {
  final bool? isFromHome;
  CartScreen({Key? key, this.isFromHome}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<ProductModel> productCart = [];
  double totalPriceCart = 0;
  double tempTotal = 0;
  CouponProvider? couponProvider;
  int totalSelected = 0;
  bool isCouponUsed = false;
  bool isSelectedAll = false;
  bool loading = false;

  loadData() async {
    setState(() {
      loading = true;
    });
    List<CartProductItem>? line = [];
    if (Provider.of<HomeProvider>(context, listen: false).syncCart &&
        Session.data.getBool('isLogin')!) {
      // if (Session.data.containsKey('cart')) {
      //   List? listCart = await json.decode(Session.data.getString('cart')!);
      //   setState(() {
      //     productCart = listCart!
      //         .map((product) => new ProductModel.fromJson(product))
      //         .toList();
      //   });
      //   for (int i = 0; i < productCart.length; i++) {
      //     printLog("selected variant : ${productCart[i].selectedVariation}");
      //     line.add(new CartProductItem(
      //         productId: productCart[i].id,
      //         quantity: (productCart[i].cartQuantity),
      //         variationId: productCart[i].variantId == 0
      //             ? null
      //             : productCart[i].variantId,
      //         variation: productCart[i].variantId == 0
      //             ? null
      //             : productCart[i].selectedVariation));
      //   }
      await OrderAPI().addCart(action: "sync", line: line).then((data) {
        if (data != null && data.isNotEmpty) {
          productCart.clear();
          printLog("data sync : ${json.encode(data)}");
          Session.data.remove('cart');

          for (Map item in data) {
            productCart.add(new ProductModel.fromJson(item));
          }
          for (int i = 0; i < productCart.length; i++) {
            productCart[i].showImage = productCart[i].images![0].src;
          }
          // printLog(json.encode(productCart), name: "Product Cart");
          // if (productCart.isNotEmpty) {
          //   context
          //       .read<OrderProvider>()
          //       .fetchProductCart(productCart)
          //       .then((value) {
          //     setState(() {
          //       productCart = value;
          //     });
          selectedAll();
          setState(() {
            loading = false;
          });
          //   });
          // }
          Session.data.setString('cart', json.encode(productCart));
        } else {
          setState(() {
            loading = false;
          });
        }
      });
      if (productCart.length > products.length) {
        if (couponProvider!.couponUsed != null) {
          await Provider.of<CouponProvider>(context, listen: false)
              .clearCoupon();
          snackBar(context,
              message: AppLocalizations.of(context)!
                  .translate("pls_select_coupon")!);
        }
      }

      // }
    } else {
      if (Session.data.containsKey('cart')) {
        List? listCart = await json.decode(Session.data.getString('cart')!);

        setState(() {
          productCart = listCart!
              .map((product) => new ProductModel.fromJson(product))
              .toList();
        });
        if (productCart.isNotEmpty) {
          context
              .read<OrderProvider>()
              .fetchProductCart(productCart)
              .then((value) {
            setState(() {
              productCart = value;
            });

            printLog("panjang : ${productCart.length}");
            selectedAll();
          });
        }
        if (productCart.length > products.length) {
          if (couponProvider!.couponUsed != null) {
            await Provider.of<CouponProvider>(context, listen: false)
                .clearCoupon();
            snackBar(context,
                message: AppLocalizations.of(context)!
                    .translate("pls_select_coupon")!);
          }
        }
        setState(() {
          loading = false;
        });
        // printLog(json.encode(productCart), name: "Product Cart");
      } else {
        setState(() {
          loading = false;
        });
      }
    }
  }

  saveData() async {
    await Session.data.setString('cart', json.encode(productCart));
    printLog(productCart.toString(), name: "Cart Product");
    Provider.of<OrderProvider>(context, listen: false)
        .loadCartCount()
        .then((value) => setState(() {}));
  }

  /*Calculate Total If Item Selected*/
  calculateTotal(index) {
    if (productCart[index].isSelected!) {
      setState(() {
        totalSelected++;
      });
    } else {
      setState(() {
        totalSelected--;
      });
    }
    productCart.forEach((element) {
      if (element.isSelected!) {
        setState(() {
          isSelectedAll = true;
        });
      }
    });
    productCart.forEach((element) {
      if (!element.isSelected!) {
        setState(() {
          isSelectedAll = false;
        });
      }
    });
    reCalculateTotalOrder();
    setState(() {
      Session.data.setDouble('totalPriceCart', totalPriceCart);
    });
  }

  /*Select All Item*/
  selectedAll() {
    setState(() {
      isSelectedAll = !isSelectedAll;
    });
    if (isSelectedAll) {
      setState(() {
        totalPriceCart = 0;
      });
      productCart.forEach((element) {
        if (element.isProductAvailable!) {
          setState(() {
            totalSelected++;
            element.isSelected = true;
            totalPriceCart += element.priceTotal!;
          });
        }
      });
    } else {
      productCart.forEach((element) {
        setState(() {
          totalSelected--;
          element.isSelected = false;
          totalPriceCart -= element.priceTotal!;
        });
      });
    }
    reCalculateTotalOrder();
    setState(() {
      Session.data.setDouble('totalPriceCart', totalPriceCart);
    });
  }

  /*Increase Quantity Item*/
  increaseQuantity(index) async {
    setState(() {
      if (productCart[index].cartQuantity! <
          productCart[index].minMaxQuantity!.maxQty) {
        productCart[index].cartQuantity = productCart[index].cartQuantity! + 1;
      } else if (productCart[index].cartQuantity! >=
          productCart[index].minMaxQuantity!.maxQty) {
        return snackBar(context,
            message:
                "Maximum purchase is ${productCart[index].minMaxQuantity!.maxQty} pcs");
      }
      productCart[index].priceTotal =
          (productCart[index].cartQuantity! * productCart[index].productPrice!);
    });
    if (productCart[index].isSelected!) {
      if (couponProvider!.couponUsed != null) {
        await Provider.of<CouponProvider>(context, listen: false).clearCoupon();
        snackBar(context,
            message:
                AppLocalizations.of(context)!.translate("pls_select_coupon")!);
      }
      reCalculateTotalOrder();
    }
    saveData();
    List<CartProductItem>? line = [];
    line.add(new CartProductItem(
        productId: productCart[index].id,
        quantity: (productCart[index].cartQuantity!),
        variationId: productCart[index].variantId == 0
            ? null
            : productCart[index].variantId));
    if (Session.data.getBool('isLogin')! &&
        Provider.of<HomeProvider>(context, listen: false).syncCart) {
      Future.delayed(Duration(seconds: 1), () {
        OrderAPI().addCart(action: "update", line: line).then((data) async {
          if (data["status"] == "success") {
          } else {
            snackBar(context, message: "Failed to update cart");
          }
        });
      });
    }
  }

  /*Decrease Quantity Item*/
  decreaseQuantity(index) async {
    setState(() {
      if (productCart[index].cartQuantity! >
          productCart[index].minMaxQuantity!.minQty) {
        productCart[index].cartQuantity = productCart[index].cartQuantity! - 1;
      } else if (productCart[index].cartQuantity! <=
          productCart[index].minMaxQuantity!.maxQty) {
        return snackBar(context,
            message:
                "Minimum purchase is ${productCart[index].minMaxQuantity!.minQty} pcs");
      }
      productCart[index].priceTotal =
          (productCart[index].cartQuantity! * productCart[index].productPrice!);
    });
    if (productCart[index].isSelected!) {
      if (couponProvider!.couponUsed != null) {
        await Provider.of<CouponProvider>(context, listen: false).clearCoupon();
        snackBar(context,
            message:
                AppLocalizations.of(context)!.translate("pls_select_coupon")!);
      }
      reCalculateTotalOrder();
    }
    saveData();
    List<CartProductItem>? line = [];
    line.add(new CartProductItem(
        productId: productCart[index].id,
        quantity: (productCart[index].cartQuantity!),
        variationId: productCart[index].variantId == 0
            ? null
            : productCart[index].variantId));
    if (Session.data.getBool('isLogin')! &&
        Provider.of<HomeProvider>(context, listen: false).syncCart) {
      Future.delayed(Duration(seconds: 1), () {
        OrderAPI().addCart(action: "update", line: line).then((data) async {
          if (data["status"] == "success") {
          } else {
            snackBar(context, message: "Failed to update cart");
          }
        });
      });
    }
  }

  /*ReCalculate Total Order*/
  reCalculateTotalOrder() {
    setState(() {
      totalPriceCart = 0;
      totalSelected = 0;
    });
    productCart.forEach((element) {
      if (element.isSelected!) {
        setState(() {
          totalPriceCart += element.priceTotal!;
          totalSelected++;
        });
      }
    });
    calcDisc();
  }

  /*Remove Item & Save Cart To ShredPrefs*/
  removeItem(index) async {
    setState(() {
      loadingDelete = true;
    });
    List<CartProductItem>? line = [];
    line.add(new CartProductItem(
        productId: productCart[index].id,
        quantity: productCart[index].cartQuantity,
        variationId: productCart[index].variantId == 0
            ? null
            : productCart[index].variantId));
    if (Session.data.getBool('isLogin')! &&
        Provider.of<HomeProvider>(context, listen: false).syncCart) {
      OrderAPI().addCart(action: "delete", line: line).then((data) async {
        if (data['status'] == "success") {
          setState(() {
            productCart.removeAt(index);
          });
          if (couponProvider!.couponUsed != null) {
            await Provider.of<CouponProvider>(context, listen: false)
                .clearCoupon();
            snackBar(context,
                message: AppLocalizations.of(context)!
                    .translate("pls_select_coupon")!);
          }

          reCalculateTotalOrder();
          saveData();
          snackBar(context,
              message: AppLocalizations.of(context)!
                  .translate('delete_cart_message')!);
          setState(() {
            loadingDelete = false;
          });
        } else {
          snackBar(context, message: "Failed to delete cart");
          setState(() {
            loadingDelete = false;
          });
        }
      });
    } else {
      setState(() {
        productCart.removeAt(index);
      });
      if (couponProvider!.couponUsed != null) {
        await Provider.of<CouponProvider>(context, listen: false).clearCoupon();
        snackBar(context,
            message:
                AppLocalizations.of(context)!.translate("pls_select_coupon")!);
      }

      reCalculateTotalOrder();
      saveData();
      setState(() {
        loadingDelete = false;
      });
      snackBar(context,
          message:
              AppLocalizations.of(context)!.translate('delete_cart_message')!);
    }
  }

  bool loadingDelete = false;

  /*Remove Selected Item*/
  removeSelectedItem() async {
    setState(() {
      loadingDelete = true;
    });
    List<CartProductItem>? line = [];
    for (int i = 0; i < productCart.length; i++) {
      if (productCart[i].isSelected!) {
        line.add(new CartProductItem(
            productId: productCart[i].id,
            quantity: productCart[i].cartQuantity,
            variationId: productCart[i].variantId == 0
                ? null
                : productCart[i].variantId));
      }
    }
    if (Session.data.getBool('isLogin')! &&
        Provider.of<HomeProvider>(context, listen: false).syncCart) {
      OrderAPI().addCart(action: "delete", line: line).then((data) async {
        if (data['status'] == "success") {
          //setState(() {
          productCart.removeWhere((element) => element.isSelected!);
          //});
          if (couponProvider!.couponUsed != null) {
            await Provider.of<CouponProvider>(context, listen: false)
                .clearCoupon();
            if (productCart.length > 0) {
              snackBar(context,
                  message: AppLocalizations.of(context)!
                      .translate("pls_select_coupon")!);
            }
          }
          reCalculateTotalOrder();
          saveData();
          setState(() {
            loadingDelete = false;
          });
          Navigator.pop(context);
          snackBar(context,
              message: AppLocalizations.of(context)!
                  .translate('delete_cart_message')!);
        } else {
          setState(() {
            loadingDelete = false;
          });
          snackBar(context, message: "Failed to delete cart");
        }
      });
    } else {
      setState(() {
        productCart.removeWhere((element) => element.isSelected!);
      });
      if (couponProvider!.couponUsed != null) {
        await Provider.of<CouponProvider>(context, listen: false).clearCoupon();
        if (productCart.length > 0) {
          snackBar(context,
              message: AppLocalizations.of(context)!
                  .translate("pls_select_coupon")!);
        }
      }
      reCalculateTotalOrder();
      saveData();
      setState(() {
        loadingDelete = false;
      });
      Navigator.pop(context);
      snackBar(context,
          message:
              AppLocalizations.of(context)!.translate('delete_cart_message')!);
    }
  }

  String disc = '';

  /*Calculate Discount From Coupons*/
  calcDisc() {
    final coupons = Provider.of<CouponProvider>(context, listen: false);
    setState(() {
      tempTotal = totalPriceCart;
    });
    if (coupons.couponUsed != null) {
      setState(() {
        totalPriceCart -=
            double.parse(coupons.couponUsed!.discountAmount!.toString());
        if (coupons.couponUsed!.discountType != "percent") {
          disc = stringToCurrency(coupons.couponUsed!.discountAmount!, context);
        } else if (coupons.couponUsed!.discountType == "percent") {
          disc =
              "${stringToCurrency(coupons.couponUsed!.discountAmount!, context)} (${coupons.couponUsed!.amount}%)";
        }
      });
      // if (coupons.couponUsed!.discountType == "fixed_cart") {
      //   setState(() {
      //     totalPriceCart -= double.parse(coupons.couponUsed!.amount!).toInt();
      //     if (totalPriceCart >= 0) {
      //       disc = stringToCurrency(
      //           double.parse(coupons.couponUsed!.amount!), context);
      //     } else if (totalPriceCart < 0) {
      //       disc = stringToCurrency(tempTotal, context);
      //     }
      //   });
      // } else if (coupons.couponUsed!.discountType == "percent") {
      //   double temp =
      //       (double.parse(coupons.couponUsed!.amount!) / 100) * totalPriceCart;
      //   print("temp :$temp");
      //   if (coupons.couponUsed!.productCategories != null) {
      //     for (int i = 0; i < productCart.length; i++) {
      //       for (int j = 0; j < productCart[i].categories!.length; j++) {
      //         for (int k = 0;
      //             k < coupons.couponUsed!.productCategories!.length;
      //             k++) {
      //           if (coupons.couponUsed!.productCategories![k] ==
      //               productCart[i].categories![j].id) {
      //             temp = (double.parse(coupons.couponUsed!.amount!) / 100) *
      //                 productCart[i].priceTotal!;
      //           }
      //         }
      //       }
      //     }
      //   }
      //   setState(() {
      //     totalPriceCart -= temp;
      //     print("total : $totalPriceCart");
      //     disc =
      //         "${stringToCurrency(temp, context)} (${double.parse(coupons.couponUsed!.amount!).toInt()}%)";
      //   });
      // } else if (coupons.couponUsed!.discountType == "fixed_product") {
      //   int totalQty = 0;
      //   for (int i = 0; i < productCart.length; i++) {
      //     totalQty += productCart[i].cartQuantity!;
      //   }
      //   double temp = totalQty * double.parse(coupons.couponUsed!.amount!);
      //   printLog("${temp} - ");
      //   setState(() {
      //     totalPriceCart -= temp;
      //     if (totalPriceCart >= 0) {
      //       disc = stringToCurrency(temp, context);
      //     } else if (totalPriceCart < 0) {
      //       disc = stringToCurrency(tempTotal, context);
      //     }
      //   });
      // }
    }
    if (totalPriceCart < 0) {
      setState(() {
        totalPriceCart = 0;
      });
    }
    saveData();
  }

  List<SearchCouponModel> products = [];

  Future<void> getProductCart() async {
    products.clear();
    if (productCart.isNotEmpty) {
      for (int i = 0; i < productCart.length; i++) {
        printLog("productCart $i : ${json.encode(productCart[i])}");
        products.add(SearchCouponModel(
            id: productCart[i].id,
            quantity: productCart[i].cartQuantity,
            variationId: productCart[i].variantId));
      }
    }
  }

  bool loadingCheckout = false;

  /*Checkout*/
  checkOut() async {
    List<CartProductItem>? line = [];
    List<ProductModel>? selectedLine = [];
    setState(() {
      loadingCheckout = true;
    });
    for (int i = 0; i < productCart.length; i++) {
      if (!productCart[i].isSelected!) {
        line.add(new CartProductItem(
            productId: productCart[i].id,
            quantity: productCart[i].cartQuantity,
            variationId: productCart[i].variantId == 0
                ? null
                : productCart[i].variantId));
      } else {
        selectedLine.add(productCart[i]);
      }
    }
    await Provider.of<OrderProvider>(context, listen: false)
        .checkOutOrder(context,
            productCart: productCart,
            totalSelected: totalSelected,
            removeOrderedItems: removeOrderedItems)
        .then((value) {
      this.setState(() {});
    });
  }

  /*Remove Ordered Items*/
  Future removeOrderedItems() async {
    productCart.removeWhere((element) => element.isSelected!);
    saveData();
    await Provider.of<CouponProvider>(context, listen: false).clearCoupon();
    await Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => OrderSuccess()));
  }

  @override
  void initState() {
    super.initState();
    couponProvider = Provider.of<CouponProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadData();
    });
  }

  Widget trash(int index) {
    return InkWell(
      onTap: () async {
        removeItem(index);
      },
      child: Container(
          width: 16.w,
          height: 16.h,
          child: Icon(
            Icons.delete,
            color: primaryColor,
          )
          // Image.asset("images/cart/trash.png")
          ),
    );
  }

  int idx = 0;

  @override
  Widget build(BuildContext context) {
    final loadingCart =
        Provider.of<OrderProvider>(context, listen: false).isLoading;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        leading: !widget.isFromHome!
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  // color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,
        title: Text(
          AppLocalizations.of(context)!.translate('cart')!,
          style: TextStyle(
            fontSize: responsiveFont(16),
            fontWeight: FontWeight.w500,
            // color: Colors.black,
          ),
        ),
        actions: [
          InkWell(
            onTap: totalSelected == 0
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _buildPopupDelete(context),
                    );
                  },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.translate('delete_selected')!,
                style:
                    TextStyle(color: totalSelected != 0 ? Colors.grey : null),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: loading
                  ? ListView.separated(
                      itemBuilder: (context, index) {
                        return itemShimmer();
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 15,
                        );
                      },
                      itemCount: 2)
                  : ListView.separated(
                      itemBuilder: (context, i) {
                        return Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction) {
                              removeItem(i);
                            },
                            child: itemList(i));
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 15,
                        );
                      },
                      itemCount: productCart.length)),
          buildBottomBarCart()
        ],
      ),
    );
  }

  Widget itemShimmer() {
    return Shimmer.fromColors(
        child: Container(
          margin: EdgeInsets.only(left: 10, top: 10, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white,
                ),
                width: 30.h,
                height: 30.h,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                width: 80.h,
                height: 80.h,
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 10,
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 100,
                          height: 10,
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: 80,
                          height: 10,
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!);
  }

  Widget itemList(int index) {
    return Material(
      elevation: 5,
      child: Container(
        height: MediaQuery.of(context).size.height / 6,
        // color: Colors.white,
        padding: EdgeInsets.all(15),
        alignment: Alignment.topLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  if (productCart[index].isProductAvailable!) {
                    if (productCart[index].minMaxQuantity!.minQty <=
                            productCart[index].cartQuantity! &&
                        productCart[index].cartQuantity! <=
                            productCart[index].minMaxQuantity!.maxQty) {
                      setState(() {
                        productCart[index].isSelected =
                            !productCart[index].isSelected!;
                      });
                      if (couponProvider!.couponUsed != null) {
                        Provider.of<CouponProvider>(context, listen: false)
                            .clearCoupon();
                        snackBar(context,
                            message: AppLocalizations.of(context)!
                                .translate("pls_select_coupon")!);
                      }

                      calculateTotal(index);
                    } else if (productCart[index].minMaxQuantity!.minQty >
                        productCart[index].cartQuantity!) {
                      snackBar(context,
                          message:
                              "Minimum purchase is ${productCart[index].minMaxQuantity!.minQty} pcs");
                    } else if (productCart[index].minMaxQuantity!.maxQty <
                        productCart[index].cartQuantity!) {
                      snackBar(context,
                          message:
                              "Maximum purchase is ${productCart[index].minMaxQuantity!.maxQty} pcs");
                    }
                  } else {
                    printLog("Product Not Available");
                    snackBar(context,
                        message: AppLocalizations.of(context)!
                            .translate('product_out_stock')!);
                  }
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    shape: BoxShape.circle,
                    color: productCart[index].isSelected!
                        ? primaryColor
                        : Colors.white,
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: productCart[index].isProductAvailable!
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : Icon(
                              Icons.not_interested_sharp,
                              color: Colors.grey,
                              size: 20,
                            )),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductDetail(
                              productId: productCart[index].id.toString(),
                            )));
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 80.h,
                    width: 80.w,
                    child: CachedNetworkImage(
                      imageUrl: productCart[index].showImage ?? "",
                      placeholder: (context, url) => customLoading(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image_not_supported_rounded,
                        size: 25,
                      ),
                    ),
                  ),
                  if (!productCart[index].isProductAvailable!)
                    Container(
                      height: 80.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey.withOpacity(0.7),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      child: Text(
                        "${AppLocalizations.of(context)!.translate('sold')!.toUpperCase()}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductDetail(
                                productId: productCart[index].id.toString(),
                              )));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      productCart[index].productName!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: responsiveFont(9)),
                    ),
                    productCart[index].variantId != null
                        ? Visibility(
                            visible: productCart[index].variantId != null &&
                                productCart[index].variationName != null,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                      productCart[index].variationName ?? "",
                                      style: TextStyle(
                                          fontSize: responsiveFont(9),
                                          fontStyle: FontStyle.italic)),
                                ),
                              ],
                            ))
                        : Container(),
                    Visibility(
                      visible: productCart[index].discProduct != 0,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: secondaryColor,
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 7),
                              child: Text(
                                "${productCart[index].discProduct!.round()}%",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsiveFont(9)),
                              ),
                            ),
                            Container(
                              width: 5,
                            ),
                            Text(
                              stringToCurrency(
                                  double.parse(
                                      productCart[index].productRegPrice),
                                  context),
                              style: TextStyle(
                                  color: HexColor("C4C4C4"),
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: responsiveFont(8)),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            stringToCurrency(
                                productCart[index].productPrice!, context),
                            style: TextStyle(
                                fontSize: responsiveFont(10),
                                color: secondaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: [
                              loadingDelete && idx == index
                                  ? LoadingFlipping.circle(
                                      borderColor: primaryColor,
                                      borderSize: 3.0,
                                      size: 20.0,
                                      duration: Duration(milliseconds: 500),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        setState(() {
                                          idx = index;
                                        });
                                        removeItem(index);
                                      },
                                      child: Container(
                                          width: 25.w,
                                          height: 25.h,
                                          child: Icon(
                                            Icons.delete,
                                            color: primaryColor,
                                          )
                                          // Image.asset("images/cart/trash.png")
                                          ),
                                    ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 16.w,
                                height: 16.h,
                                child: InkWell(
                                  onTap: () async {
                                    if (productCart[index].cartQuantity! > 1) {
                                      decreaseQuantity(index);
                                    }
                                  },
                                  child: productCart[index].cartQuantity! > 1
                                      ? Image.asset("images/cart/minusDark.png")
                                      : Image.asset("images/cart/minus.png"),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(productCart[index].cartQuantity.toString()),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 16.w,
                                height: 16.h,
                                child: InkWell(
                                    onTap: productCart[index].productStock ==
                                                null &&
                                            productCart[index].productStock! <=
                                                productCart[index].cartQuantity!
                                        ? null
                                        : () async {
                                            setState(() {});
                                            increaseQuantity(index);
                                          },
                                    child: productCart[index].productStock !=
                                                null &&
                                            productCart[index].productStock! >
                                                productCart[index].cartQuantity!
                                        ? Image.asset("images/cart/plus.png")
                                        : Image.asset(
                                            "images/cart/plusDark.png")),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 6,
                    ),
                    Visibility(
                      visible: productCart[index].minMaxQuantity!.minQty >
                          productCart[index].cartQuantity!,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Minimum purchase is ${productCart[index].minMaxQuantity!.minQty} pcs",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: productCart[index].minMaxQuantity!.maxQty <
                          productCart[index].cartQuantity!,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Maximum purchase is ${productCart[index].minMaxQuantity!.maxQty} pcs",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  buildBottomBarCart() {
    final coupons = Provider.of<CouponProvider>(context, listen: false);
    print(coupons.couponUsed);

    return Column(
      children: [
        coupons.couponUsed != null
            ? Container(
                // color: Colors.white,
                padding: EdgeInsets.all(15),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                            width: 20.w,
                            height: 20.h,
                            child: Icon(
                              Icons.confirmation_num,
                              color: primaryColor,
                            )
                            // Image.asset("images/cart/coupon.png")
                            ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "${AppLocalizations.of(context)!.translate('using_coupon')} :",
                                style: TextStyle(
                                    fontSize: responsiveFont(10),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "${coupons.couponUsed!.code}",
                                style: TextStyle(
                                    fontSize: responsiveFont(10),
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      onTap: () {
                        setState(() {
                          coupons.couponUsed = null;
                        });
                        reCalculateTotalOrder();
                      },
                    )
                  ],
                ),
              )
            : GestureDetector(
                onTap: () async {
                  getProductCart().then((data) async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CouponScreen(
                                  products: products,
                                ))).then((value) {
                      setState(() {});
                      reCalculateTotalOrder();
                    });
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                          width: 20.w,
                          height: 20.h,
                          child: Icon(
                            Icons.confirmation_num,
                            color: primaryColor,
                          )
                          // Image.asset("images/cart/coupon.png")
                          ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          AppLocalizations.of(context)!
                              .translate('apply_coupon')!,
                          style: TextStyle(fontSize: responsiveFont(10)),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_right)
                    ],
                  ),
                ),
              ),
        Container(
          width: double.infinity,
          height: 1,
          color: HexColor("DDDDDD"),
        ),
        Material(
            elevation: 5,
            child: Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 15, right: 10),
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            selectedAll();
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                shape: BoxShape.circle,
                                color: isSelectedAll
                                    ? primaryColor
                                    : Colors.white),
                            child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )),
                          ),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.translate('select_all')!,
                        style: TextStyle(fontSize: responsiveFont(10)),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                              // style: TextStyle(color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(
                                    text:
                                        '${AppLocalizations.of(context)!.translate('total')} : ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                TextSpan(
                                    text: stringToCurrency(
                                        totalPriceCart.toDouble(), context),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor)),
                              ],
                            ),
                          ),
                          coupons.couponUsed == null
                              ? Container()
                              : Visibility(
                                  visible: coupons.couponUsed != null,
                                  child: Text(
                                    "${AppLocalizations.of(context)!.translate('discount')} : $disc",
                                    style:
                                        TextStyle(fontSize: responsiveFont(8)),
                                  ))
                        ],
                      ),
                      Container(
                        width: 15,
                      ),
                      TextButton(
                        onPressed: () {
                          checkOut();
                        },
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.all(15),
                            backgroundColor: totalSelected != 0
                                ? primaryColor
                                : Colors.grey),
                        child: Text(
                          "${AppLocalizations.of(context)!.translate('checkout')}($totalSelected)",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  )
                ],
              ),
              // color: Colors.white,
            ))
      ],
    );
  }

  Widget _buildPopupDelete(BuildContext context) {
    return new AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        insetPadding: EdgeInsets.all(0),
        content: Builder(
          builder: (context) {
            return Container(
              height: 150.h,
              width: 330.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        '${AppLocalizations.of(context)!.translate('delete')} $totalSelected item?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: responsiveFont(16),
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('delete_cart_confirm')!,
                              style: TextStyle(
                                fontSize: responsiveFont(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      removeSelectedItem();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate('delete')!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
