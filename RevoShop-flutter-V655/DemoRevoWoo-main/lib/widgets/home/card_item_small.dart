import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/pages/product/product_detail_screen.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../../provider/app_provider.dart';

class CardItem extends StatelessWidget {
  final ProductModel? product;

  final int? i, itemCount;

  CardItem({this.product, this.i, this.itemCount});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<AppNotifier>(context, listen: false).appLocal;
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetail(
                      productId: product!.id.toString(),
                    )));
      },
      child: Container(
        margin: EdgeInsets.only(
          left: locale == Locale('ar')
              ? i == itemCount! - 1
                  ? 15
                  : 0
              : i == 0
                  ? 15
                  : 0,
          right: locale == Locale('ar')
              ? i == 0
                  ? 15
                  : 0
              : i == itemCount! - 1
                  ? 15
                  : 0,
        ),
        decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(5)),
        width: 130.w,
        height: double.infinity,
        child: Card(
          elevation: 5,
          margin: EdgeInsets.only(bottom: 10, left: 2.5, right: 2.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5),
                            topLeft: Radius.circular(5)),
                      ),
                      child: product!.images!.isEmpty
                          ? Icon(
                              Icons.image_not_supported,
                              size: 50,
                            )
                          : CachedNetworkImage(
                              imageUrl: product!.images![0].src!,
                              placeholder: (context, url) =>
                                  customLoadingShimmer(),
                              errorWidget: (context, url, error) => Icon(
                                Icons.image_not_supported_rounded,
                                size: 25,
                              ),
                            ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                    child: Text(
                      product!.productName!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: responsiveFont(10)),
                      textScaleFactor: 1.0,
                    ),
                  ),
                ],
              )),
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: product!.discProduct != 0 &&
                                product!.discProduct != 0.0,
                            child: product!.type == 'simple'
                                ? Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: secondaryColor,
                                        ),
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        child: Text(
                                          "${product!.discProduct!.round()}%",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: responsiveFont(9)),
                                        ),
                                      ),
                                      Container(
                                        width: 5,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(color: Colors.black),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: stringToCurrency(
                                                    double.parse(product!
                                                        .productRegPrice),
                                                    context),
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    fontSize: responsiveFont(9),
                                                    color: HexColor("C4C4C4"))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: secondaryColor,
                                        ),
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        child: Text(
                                          "${product!.discProduct!.round()}%",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: responsiveFont(9)),
                                        ),
                                      ),
                                      Container(
                                        width: 5,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(color: Colors.black),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: product!
                                                            .variationRegPrices!
                                                            .first ==
                                                        product!
                                                            .variationRegPrices!
                                                            .last
                                                    ? '${stringToCurrency(product!.variationRegPrices!.first, context)}'
                                                    : '${stringToCurrency(product!.variationRegPrices!.first, context)} - ${stringToCurrency(product!.variationRegPrices!.last, context)}',
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    fontSize: responsiveFont(9),
                                                    color: HexColor("C4C4C4"))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          product!.type == 'simple'
                              ? RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: stringToCurrency(
                                              product!.productPrice!, context),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: responsiveFont(11),
                                              color: secondaryColor)),
                                    ],
                                  ),
                                )
                              : RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.black),
                                    children: <TextSpan>[
                                      product!.variationPrices!.isEmpty
                                          ? TextSpan(
                                              text: '',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: responsiveFont(11),
                                                  color: secondaryColor))
                                          : TextSpan(
                                              text: product!.variationPrices!
                                                          .first ==
                                                      product!
                                                          .variationPrices!.last
                                                  ? '${stringToCurrency(product!.variationPrices!.first, context)}'
                                                  : '${stringToCurrency(product!.variationPrices!.first, context)} - ${stringToCurrency(product!.variationPrices!.last, context)}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: responsiveFont(11),
                                                  color: secondaryColor)),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                    buildButtonCart(context, product)
                  ],
                ),
              ),
              Container(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
