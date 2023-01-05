import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/product/product_detail_screen.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../app_localizations.dart';

class GridItemCategory extends StatelessWidget {
  final int? i;
  final int? itemCount;
  final ProductModel? product;
  final String? categoryName;
  final int? categoryId;

  GridItemCategory(
      {this.i,
      this.itemCount,
      this.product,
      this.categoryName,
      this.categoryId});

  @override
  Widget build(BuildContext context) {
    if (i == 5) {
      return buildViewMore(context);
    }
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: Card(
          elevation: 5,
          margin: EdgeInsets.only(bottom: 1),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductDetail(
                            productId: product!.id.toString(),
                          )));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    product!.images!.isEmpty
                        ? Icon(
                            Icons.broken_image_outlined,
                            size: 50,
                          )
                        : AspectRatio(
                            aspectRatio: 1 / 1,
                            child: CachedNetworkImage(
                              imageUrl: product!.images![0].src!,
                              placeholder: (context, url) =>
                                  customLoadingShimmer(),
                              errorWidget: (context, url, error) => Icon(
                                Icons.image_not_supported_rounded,
                                size: 25,
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
                      ),
                    ),
                    Container(
                      height: 5,
                    ),
                  ],
                )),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Visibility(
                                visible: product!.discProduct != 0,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 25,
                                      height: 15,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: secondaryColor,
                                      ),
                                      child: Text(
                                        "${product!.discProduct!.round()}%",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: responsiveFont(7)),
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
                                                  double.parse(
                                                      product!.productRegPrice),
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
                                ),
                              ),
                              product!.type == 'simple'
                                  ? RichText(
                                      text: TextSpan(
                                        style: TextStyle(color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: stringToCurrency(
                                                  product!.productPrice!,
                                                  context),
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
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize:
                                                          responsiveFont(11),
                                                      color: secondaryColor))
                                              : TextSpan(
                                                  text: product!
                                                              .variationPrices!
                                                              .first ==
                                                          product!
                                                              .variationPrices!
                                                              .last
                                                      ? '${stringToCurrency(product!.variationPrices!.first, context)}'
                                                      : '${stringToCurrency(product!.variationPrices!.first, context)} - ${stringToCurrency(product!.variationPrices!.last, context)}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize:
                                                          responsiveFont(11),
                                                      color: secondaryColor)),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        buildButtonCart(context, product)
                      ],
                    )),
              ],
            ),
          )),
    );
  }

  Widget buildViewMore(context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: Card(
          elevation: 5,
          margin: EdgeInsets.only(bottom: 1),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BrandProducts(
                            categoryId: categoryId.toString(),
                            brandName: categoryName,
                          )));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Icon(
                    Icons.add,
                    color: secondaryColor,
                    size: 28,
                  ),
                ),
                Container(
                  child: Text(
                    AppLocalizations.of(context)!.translate('view_more')!,
                    style: TextStyle(
                        color: secondaryColor,
                        fontSize: responsiveFont(10),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    AppLocalizations.of(context)!.translate('sub_view_more')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: responsiveFont(8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
