import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/cart_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/order/order_success_screen.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/services/order_api.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailModal extends StatefulWidget {
  final ProductModel? productModel;
  final String? type;
  final Future<dynamic> Function()? loadCount;
  const ProductDetailModal({
    Key? key,
    this.productModel,
    this.type,
    this.loadCount,
  }) : super(key: key);

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  List<ProductVariation> variation = [];

  bool load = false;
  bool isAvailable = false;
  bool isOutStock = false;
  bool loadingAdd = false;
  num? variationPrice = 0;
  num? variationSalePrice = 0;
  String? variationName = '';
  Map<String, dynamic>? variationResult;
  int? variationStock = 0;

  bool chekQty = false;
  String errorText = "";
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    quantity = widget.productModel!.minMaxQuantity!.minQty;
    widget.productModel!.cartQuantity =
        widget.productModel!.minMaxQuantity!.minQty;
    minMax = null;
    initVariation();
  }

  /*add to cart*/
  void addCart(ProductModel product) async {
    setState(() {
      loadingAdd = true;
    });
    print('Add Cart');
    if (variationPrice != 0) {
      print("Variation Price : $variationPrice");

      product.productPrice = variationPrice;
    }
    if (minMax != null) {
      product.minMaxQuantity = minMax;
    }
    List<ProductImageModel> images = [];
    if (product.variantId != null) {
      for (int i = 0; i < product.availableVariations!.length; i++) {
        if (product.availableVariations![i].variationId == product.variantId) {
          images.add(ProductImageModel(
              src: product.availableVariations![i].image!.url!,
              name: product.availableVariations![i].image!.title));
        }
      }
      product.selectedVariation = variation;
      product.variationName = variationName;
      product.showImage = images[0].src;
    }
    if (product.variantId == null) {
      product.showImage = product.images![0].src;
    }
    ProductModel productCart = product;
    printLog(productCart.showImage!, name: "image add");
    if (productCart.minMaxQuantity!.minQty > productCart.productStock!) {
      Navigator.pop(context, true);
      return snackBar(context,
          message:
              "Minimum purchase is ${productCart.minMaxQuantity!.minQty} pcs");
    }
    List<CartProductItem> line = [];
    line.add(CartProductItem(
        productId: productCart.id,
        quantity: productCart.cartQuantity,
        variationId: productCart.variantId == 0 ? null : productCart.variantId,
        variation: productCart.selectedVariation));
    if (Provider.of<HomeProvider>(context, listen: false).syncCart &&
        Session.data.getBool('isLogin')!) {
      OrderAPI().addCart(action: "create", line: line).then((data) {
        if (data['status'] == "success") {
          checkSPcart(productCart);
          setState(() {
            load = false;
          });
        } else {
          setState(() {
            load = false;
          });
          Navigator.pop(context);
          snackBar(context, message: "Failed to update cart");
        }
      });
    } else {
      checkSPcart(productCart);
    }
  }

  /*check sharedprefs for cart*/
  checkSPcart(ProductModel productCart) async {
    if (!Session.data.containsKey('cart')) {
      List<ProductModel> listCart = [];
      productCart.priceTotal =
          (productCart.cartQuantity! * productCart.productPrice!);
      //PENGECEKAN MAX QTY
      if (productCart.minMaxQuantity!.maxQty >= productCart.cartQuantity!) {
        listCart.add(productCart);
      } else if (productCart.minMaxQuantity!.maxQty <
          productCart.cartQuantity!) {
        Navigator.pop(context, false);
        return snackBar(context,
            message:
                "Maximum purchase is ${productCart.minMaxQuantity!.maxQty} pcs");
      }
      setState(() {
        loadingAdd = false;
      });
      await Session.data.setString('cart', json.encode(listCart));
    } else {
      List products = await json.decode(Session.data.getString('cart')!);

      List<ProductModel> listCart = products
          .map((product) => new ProductModel.fromJson(product))
          .toList();

      int index = products.indexWhere((prod) =>
          prod["id"] == productCart.id &&
          prod["variant_id"] == productCart.variantId &&
          prod["variation_name"] == productCart.variationName);

      if (index != -1) {
        productCart.cartQuantity =
            listCart[index].cartQuantity! + productCart.cartQuantity!;

        productCart.priceTotal =
            (productCart.cartQuantity! * productCart.productPrice!);
        //PENGECEKAN MAX QTY
        if (productCart.minMaxQuantity!.maxQty >= productCart.cartQuantity!) {
          listCart[index] = productCart;
        } else if (productCart.minMaxQuantity!.maxQty <
            productCart.cartQuantity!) {
          Navigator.pop(context, false);
          return snackBar(context,
              message:
                  "Maximum purchase is ${productCart.minMaxQuantity!.maxQty} pcs");
        }
        setState(() {
          loadingAdd = false;
        });
        await Session.data.setString('cart', json.encode(listCart));
      } else {
        productCart.priceTotal =
            (productCart.cartQuantity! * productCart.productPrice!);
        //PENGECEKAN MAX QTY
        if (productCart.minMaxQuantity!.maxQty >= productCart.cartQuantity!) {
          listCart.insert(0, productCart);
        } else if (productCart.minMaxQuantity!.maxQty <
            productCart.cartQuantity!) {
          Navigator.pop(context, false);
          return snackBar(context,
              message:
                  "Maximum purchase is ${productCart.minMaxQuantity!.maxQty} pcs");
        }
        setState(() {
          loadingAdd = false;
        });
        await Session.data.setString('cart', json.encode(listCart));
      }
    }
    widget.loadCount!();
    this.setState(() {});
    Navigator.pop(context, true);
    return snackBar(context,
        message:
            AppLocalizations.of(context)!.translate('product_success_atc')!);
  }

  /*init variation & check if variation true*/
  initVariation() {
    if (widget.productModel!.attributes!.isNotEmpty &&
        widget.productModel!.type == 'variable') {
      widget.productModel!.customVariation!.forEach((element) {
        print("Variation True");
        setState(() {
          variation.add(new ProductVariation(
              id: element.id,
              value: element.selectedValue,
              columnName: element.slug));
        });
      });
      checkProductVariant(widget.productModel!);
    }
    if (widget.productModel!.type == 'simple' &&
        widget.productModel!.productStock != 0) {
      setState(() {
        isAvailable = true;
      });
    }
  }

  MinMaxQuantity? minMax;

  /*get variant id, if product have variant*/
  checkProductVariant(ProductModel productModel) async {
    setState(() {
      load = true;
    });
    var tempVar = [];
    productModel.customVariation!.forEach((element) {
      setState(() {
        tempVar.add(element.selectedName);
      });
    });
    printLog(json.encode(productModel));
    variationName = tempVar.join(", ");
    productModel.variationName = variationName;
    final product = Provider.of<ProductProvider>(context, listen: false);
    final Future<Map<String, dynamic>?> productResponse =
        product.checkVariation(productId: productModel.id, list: variation);

    productResponse.then((value) {
      if (value!['variation_id'] != 0) {
        setState(() {
          productModel.variantId = value['variation_id'];
          productModel.minMaxQuantity =
              MinMaxQuantity.fromJson(value['data']['minmax_quantity']);
          productModel.cartQuantity = productModel.minMaxQuantity!.minQty;
          load = false;
          variationResult = value;
          minMax = MinMaxQuantity.fromJson(value['data']['minmax_quantity']);
          productModel.availableVariations!.forEach((element) {
            if (element.variationId == productModel.variantId) {
              variationPrice = element.displayPrice!;
            }
          });
          if (value['data']['wholesales'] != null &&
              value['data']['wholesales'].isNotEmpty) {
            if (value['data']['wholesales'][0]['price'].isNotEmpty &&
                Session.data.getString('role') == 'wholesale_customer') {
              variationPrice =
                  double.parse(value['data']['wholesales'][0]['price']);
            }
          }
          if (value['data']['stock_status'] == 'instock' &&
                  value['data']['stock_quantity'] == null ||
              value['data']['stock_quantity'] == 0 &&
                  value['data']['stock_status'] == 'instock') {
            variationStock = 999;
            isAvailable = true;
            isOutStock = false;
          } else if (value['data']['stock_status'] == 'outofstock') {
            print('outofstock');
            isAvailable = true;
            isOutStock = true;
            variationStock = 0;
          } else if (value['data']['price'] == 0) {
            print('price not set');
            isAvailable = false;
            isOutStock = false;
            variationStock = 0;
          } else {
            print('else');
            variationStock = value['data']['stock_quantity'];
            isAvailable = true;
            isOutStock = false;
          }
        });
      } else {
        if (mounted)
          setState(() {
            variationPrice = 0;
            isAvailable = false;
            load = false;
          });
      }
      printLog(isAvailable.toString(), name: 'Is Available');
      printLog(isOutStock.toString(), name: 'Is Out Stock');
    });
  }

  Future onFinishBuyNow() async {
    //if (mounted) {
    print("masuk sini");
    await Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => OrderSuccess()));
    //}
  }

  buyNow() async {
    print("Buy Now");
    if (widget.productModel!.minMaxQuantity!.minQty >
        widget.productModel!.productStock!) {
      Navigator.pop(context, true);
      return snackBar(context,
          message:
              "Minimum purchase is ${widget.productModel!.minMaxQuantity!.minQty} pcs");
    }
    await Provider.of<OrderProvider>(context, listen: false).buyNow(context,
        product: widget.productModel, onFinishBuyNow: onFinishBuyNow);
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Wrap(children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      child: Icon(
                    Icons.square,
                    color: Colors.transparent,
                  )),
                  Container(
                    height: 5.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        child: Icon(
                      Icons.clear,
                      color: Colors.transparent,
                    )),
                  )
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: widget.productModel!.customVariation!.length,
                    itemBuilder: (context, i) {
                      CustomVariationModel customVariation =
                          widget.productModel!.customVariation![i];
                      return Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Row(children: [
                                  Text(
                                    "${customVariation.name} : ",
                                    style: TextStyle(
                                        fontSize: responsiveFont(12),
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "${customVariation.selectedName}",
                                    style: TextStyle(
                                        fontSize: responsiveFont(12),
                                        fontWeight: FontWeight.w500),
                                  )
                                ]),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              i == 0
                                  ? Container(
                                      child: GridView.builder(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          physics: ScrollPhysics(),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                              crossAxisSpacing: 15,
                                              mainAxisSpacing: 15,
                                              childAspectRatio: customVariation
                                                              .optionVariation![
                                                                  0]
                                                              .image ==
                                                          null ||
                                                      !Provider.of<
                                                                  HomeProvider>(
                                                              context,
                                                              listen: false)
                                                          .showVariationWithImage
                                                  ? 1 / 0.4
                                                  : 1 / 1),
                                          itemCount: customVariation
                                              .optionVariation!.length,
                                          itemBuilder: (context, j) {
                                            OptionVariation optionVariation =
                                                customVariation
                                                    .optionVariation![j];
                                            if (optionVariation.image == null &&
                                                optionVariation.image == '') {
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    customVariation
                                                            .selectedName =
                                                        optionVariation.name;
                                                    customVariation
                                                            .selectedValue =
                                                        optionVariation.value;
                                                  });
                                                  variation.forEach((element) {
                                                    if (element.id != 0) {
                                                      if (element.columnName ==
                                                          customVariation
                                                              .slug) {
                                                        setState(() {
                                                          element.value =
                                                              optionVariation
                                                                  .value;
                                                        });
                                                      }
                                                    } else {
                                                      if (element.columnName ==
                                                          customVariation
                                                              .slug) {
                                                        setState(() {
                                                          element.value =
                                                              optionVariation
                                                                  .name;
                                                        });
                                                      }
                                                    }
                                                  });
                                                  checkProductVariant(
                                                      widget.productModel!);
                                                },
                                                child: Container(
                                                  height: 20.h,
                                                  width: 60.w,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        width: 2,
                                                        color: widget
                                                                    .productModel!
                                                                    .customVariation![
                                                                        i]
                                                                    .selectedName ==
                                                                widget
                                                                    .productModel!
                                                                    .customVariation![
                                                                        i]
                                                                    .optionVariation![
                                                                        j]
                                                                    .name
                                                            ? primaryColor
                                                            : Colors
                                                                .grey[300]!),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Icon(Icons
                                                      .image_not_supported_rounded),
                                                ),
                                              );
                                            }
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  customVariation.selectedName =
                                                      optionVariation.name;
                                                  customVariation
                                                          .selectedValue =
                                                      optionVariation.value;
                                                });
                                                variation.forEach((element) {
                                                  if (element.id != 0) {
                                                    if (element.columnName ==
                                                        customVariation.slug) {
                                                      setState(() {
                                                        element.value =
                                                            optionVariation
                                                                .value;
                                                      });
                                                    }
                                                  } else {
                                                    if (element.columnName ==
                                                        customVariation.slug) {
                                                      setState(() {
                                                        element.value =
                                                            optionVariation
                                                                .name;
                                                      });
                                                    }
                                                  }
                                                });
                                                checkProductVariant(
                                                    widget.productModel!);
                                              },
                                              child: optionVariation.image !=
                                                      null
                                                  ? Container(
                                                      height: 20.h,
                                                      width: 60.w,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            width: 2,
                                                            color: widget
                                                                        .productModel!
                                                                        .customVariation![
                                                                            i]
                                                                        .selectedName ==
                                                                    widget
                                                                        .productModel!
                                                                        .customVariation![
                                                                            i]
                                                                        .optionVariation![
                                                                            j]
                                                                        .name
                                                                ? primaryColor
                                                                : Colors.grey[
                                                                    300]!),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: !Provider.of<
                                                                      HomeProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .showVariationWithImage
                                                          ? Center(
                                                              child: Text(
                                                                  optionVariation
                                                                      .name!),
                                                            )
                                                          : CachedNetworkImage(
                                                              fit: BoxFit.fill,
                                                              imageUrl:
                                                                  optionVariation
                                                                      .image!,
                                                              imageBuilder:
                                                                  (context,
                                                                          imageProvider) =>
                                                                      Container(
                                                                height: 20.h,
                                                                width: 60.w,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      300],
                                                                  // border: Border.all(
                                                                  //     width: 2,
                                                                  //     color: widget
                                                                  //                 .productModel!
                                                                  //                 .customVariation![
                                                                  //                     i]
                                                                  //                 .selectedName ==
                                                                  //             widget
                                                                  //                 .productModel!
                                                                  //                 .customVariation![
                                                                  //                     i]
                                                                  //                 .optionVariation![
                                                                  //                     j]
                                                                  //                 .name
                                                                  //         ? primaryColor
                                                                  //         : Colors
                                                                  //             .white),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  image:
                                                                      DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              placeholder: (context,
                                                                      url) =>
                                                                  customLoading(),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Icon(Icons
                                                                      .image_not_supported_rounded),
                                                            ))
                                                  : Container(
                                                      height: 60.h,
                                                      width: 60.w,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        // color: Colors.white,
                                                        border: Border.all(
                                                            width: 2,
                                                            color: widget
                                                                        .productModel!
                                                                        .customVariation![
                                                                            i]
                                                                        .selectedName ==
                                                                    widget
                                                                        .productModel!
                                                                        .customVariation![
                                                                            i]
                                                                        .optionVariation![
                                                                            j]
                                                                        .name
                                                                ? primaryColor
                                                                : Colors.grey[
                                                                    300]!),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Text(
                                                          optionVariation.name!,
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                            );
                                          }),
                                    )
                                  : Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      runSpacing: 10.0,
                                      spacing: 10.0,
                                      children: [
                                        for (int j = 0;
                                            j <
                                                widget
                                                    .productModel!
                                                    .customVariation![i]
                                                    .optionVariation!
                                                    .length;
                                            j++)
                                          _buildVarianNonImage(
                                              customVariation, j)
                                      ],
                                    ),
                              SizedBox(
                                height: 5,
                              ),
                            ]),
                      );
                    })),
          ],
        ),
        load
            ? Shimmer.fromColors(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  margin: EdgeInsets.all(15),
                  height: 35.h,
                ),
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!)
            : !isAvailable
                ? Container(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('select_var_not_avail')!,
                      textAlign: TextAlign.center,
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(
                        left: 15, right: 15, top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                AppLocalizations.of(context)!.translate('qty')!,
                                style: TextStyle(
                                    fontSize: responsiveFont(12),
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (widget
                                                  .productModel!.cartQuantity! >
                                              widget.productModel!
                                                  .minMaxQuantity!.minQty) {
                                            widget.productModel!.cartQuantity =
                                                widget.productModel!
                                                        .cartQuantity! -
                                                    1;
                                            chekQty = false;
                                            errorText = "";
                                          } else {
                                            chekQty = true;
                                            errorText =
                                                "Minimum purchase is ${widget.productModel!.minMaxQuantity!.minQty} pcs";
                                            // snackBar(
                                            //   context,
                                            //   message:
                                            //       "Minimum purchase is ${widget.productModel!.minMaxQuantity!.minQty} pcs",
                                            //   behavior:
                                            //       SnackBarBehavior.floating,
                                            // );
                                          }
                                        });
                                      },
                                      child:
                                          widget.productModel!.cartQuantity! >
                                                  widget.productModel!
                                                      .minMaxQuantity!.minQty
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[400],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: Colors.black,
                                                  ),
                                                )
                                              : Container(
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: Colors.grey,
                                                  ),
                                                )),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                    widget.productModel!.cartQuantity
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                    )),
                                SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: InkWell(
                                      onTap: widget.productModel!
                                                      .productStock! <=
                                                  widget.productModel!
                                                      .cartQuantity! ||
                                              isOutStock ||
                                              widget.productModel!
                                                      .cartQuantity! >=
                                                  widget.productModel!
                                                      .minMaxQuantity!.maxQty
                                          ? () {
                                              if (widget.productModel!
                                                      .cartQuantity! >=
                                                  widget.productModel!
                                                      .minMaxQuantity!.maxQty) {
                                                setState(() {
                                                  chekQty = true;
                                                  errorText =
                                                      "Maximum purchase is ${widget.productModel!.minMaxQuantity!.maxQty} pcs";
                                                });
                                              } else {
                                                setState(() {
                                                  chekQty = false;
                                                  errorText = "";
                                                });
                                              }
                                            }
                                          : () {
                                              setState(() {
                                                chekQty = false;
                                                errorText = "";
                                                widget.productModel!
                                                    .cartQuantity = widget
                                                        .productModel!
                                                        .cartQuantity! +
                                                    1;
                                              });
                                            },
                                      child:
                                          widget.productModel!.productStock! >
                                                      widget.productModel!
                                                          .cartQuantity! &&
                                                  !isOutStock &&
                                                  widget
                                                          .productModel!
                                                          .minMaxQuantity!
                                                          .maxQty >
                                                      widget.productModel!
                                                          .cartQuantity!
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[400],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.black,
                                                  ),
                                                )
                                              : Container(
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.grey,
                                                  ),
                                                )),
                                )
                              ],
                            ),
                          ],
                        ),
                        Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widget.productModel!.type == 'simple'
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        stringToCurrency(
                                            widget.productModel!.productPrice!,
                                            context),
                                        style: TextStyle(
                                            color: secondaryColor,
                                            fontSize: responsiveFont(12),
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        widget.productModel!.productStock == 999
                                            ? '${AppLocalizations.of(context)!.translate('stock')} : ${AppLocalizations.of(context)!.translate('available')}'
                                            : '${AppLocalizations.of(context)!.translate('stock')} : ${widget.productModel!.productStock}',
                                        style: TextStyle(
                                          fontSize: responsiveFont(12),
                                        ),
                                      )
                                    ],
                                  )
                                : Visibility(
                                    visible:
                                        widget.productModel!.type == 'variable',
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Visibility(
                                              visible: variationSalePrice != 0,
                                              child: Text(
                                                stringToCurrency(
                                                    variationPrice!, context),
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize:
                                                        responsiveFont(12),
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              stringToCurrency(
                                                  variationSalePrice != 0
                                                      ? variationSalePrice!
                                                      : variationPrice!,
                                                  context),
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: responsiveFont(12),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          variationStock == 999
                                              ? '${AppLocalizations.of(context)!.translate('stock')} : ${AppLocalizations.of(context)!.translate('in_stock')}'
                                              : '${AppLocalizations.of(context)!.translate('stock')} : $variationStock',
                                          style: TextStyle(
                                            fontSize: responsiveFont(12),
                                          ),
                                        )
                                      ],
                                    ))
                          ],
                        ))
                      ],
                    ),
                  ),
        Visibility(
            visible: chekQty,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                errorText,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            )),
        _buildAllBtn()
      ]);
    });
  }

  _buildAllBtn() {
    final isDarkMode = Provider.of<AppNotifier>(context).isDarkMode;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: isDarkMode ? null : Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black54,
                blurRadius: 5.0,
              )
            ],
          ),
          height: 50.h,
          width: double.infinity,
          child: widget.type == 'all'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBtnATC(),
                    SizedBox(
                      width: 15,
                    ),
                    _buildBtnBuy()
                  ],
                )
              : widget.type == 'add'
                  ? Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: _buildBtnATC(),
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: _buildBtnBuy(),
                    )),
    );
  }

  _buildBtnATC() {
    return Container(
      width: 130.w,
      height: 30.h,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: !isAvailable || load || isOutStock
                    ? Colors.grey
                    : secondaryColor,
                //Style of the border
              ),
              alignment: Alignment.center,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5))),
          onPressed: !isAvailable || load || isOutStock || loadingAdd
              ? null
              : () {
                  if (widget.productModel!.productStock != null &&
                          widget.productModel!.productStock != 0 ||
                      !isOutStock) {
                    addCart(widget.productModel!);
                  } else {
                    return _outOfStockAlert();
                  }
                },
          child: loadingAdd
              ? customLoading()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: responsiveFont(9),
                      color: !isAvailable || load || isOutStock
                          ? Colors.grey
                          : secondaryColor,
                    ),
                    Text(
                      AppLocalizations.of(context)!.translate('add_to_cart')!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: responsiveFont(9),
                        color: !isAvailable || load || isOutStock
                            ? Colors.grey
                            : secondaryColor,
                      ),
                    )
                  ],
                )),
    );
  }

  _buildBtnBuy() {
    final isSolid = Provider.of<HomeProvider>(context, listen: false).isSolid;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isSolid ? buttonColor : null,
          gradient: isSolid
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: !isAvailable || load || isOutStock
                      ? [Colors.black12, Colors.grey]
                      : [primaryColor, secondaryColor])),
      width: 130.w,
      height: 30.h,
      child: TextButton(
        onPressed: !isAvailable || load || isOutStock
            ? null
            : () {
                if (widget.productModel!.productStock != null &&
                    widget.productModel!.productStock != 0) {
                  buyNow();
                } else {
                  return _outOfStockAlert();
                }
              },
        child: Text(
          AppLocalizations.of(context)!.translate('buy_now')!,
          style: TextStyle(
            color: isSolid ? textButtonColor : Colors.white,
            fontSize: responsiveFont(9),
          ),
        ),
      ),
    );
  }

  _buildVarianNonImage(CustomVariationModel customVariation, int i) {
    OptionVariation optionVariation = customVariation.optionVariation![i];
    return InkWell(
      onTap: () {
        setState(() {
          customVariation.selectedName = optionVariation.name;
          customVariation.selectedValue = optionVariation.value;
        });
        variation.forEach((element) {
          if (element.id != 0) {
            if (element.columnName == customVariation.slug) {
              setState(() {
                element.value = optionVariation.value;
              });
            }
          } else {
            if (element.columnName == customVariation.slug) {
              setState(() {
                element.value = optionVariation.name;
              });
            }
          }
        });
        checkProductVariant(widget.productModel!);
      },
      child: Container(
        padding: EdgeInsets.all(5),
        width: 90.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // color: Colors.white,
          border: Border.all(
              width: 2,
              color: customVariation.selectedName == optionVariation.name
                  ? primaryColor
                  : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          optionVariation.name!,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  _outOfStockAlert() {
    Navigator.pop(context);
    snackBar(context, message: 'Product out ouf stock.');
  }
}
