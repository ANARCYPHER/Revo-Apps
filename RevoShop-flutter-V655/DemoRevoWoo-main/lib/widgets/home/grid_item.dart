import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../pages/product/product_detail_screen.dart';

class GridItem extends StatelessWidget {
  final int? i;
  final int? itemCount;
  final ProductModel? product;

  GridItem({this.i, this.itemCount, this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(5)),
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
                      AspectRatio(
                        aspectRatio: 1 / 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: product!.images![0].src!,
                            placeholder: (context, url) => customLoading(),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_not_supported_rounded,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 5),
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
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                        alignment: Alignment.center,
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
                                                    fontSize:
                                                        responsiveFont(11),
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
                      )
                    ],
                  ),
                ),
                Container(
                  height: 5,
                ),
              ],
            ),
          )),
    );
  }
}
