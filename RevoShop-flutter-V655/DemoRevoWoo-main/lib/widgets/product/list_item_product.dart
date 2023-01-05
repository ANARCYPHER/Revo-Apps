import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nyoba/pages/product/product_detail_screen.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:hexcolor/hexcolor.dart';

class ListItemProduct extends StatelessWidget {
  final ProductModel? product;
  final int? i, itemCount;

  ListItemProduct({this.product, this.i, this.itemCount});

  @override
  Widget build(BuildContext context) {
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
        margin: EdgeInsets.symmetric(vertical: 2),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: 60.h,
                  height: 60.h,
                  child: product!.images!.isEmpty
                      ? Icon(
                          Icons.image_not_supported,
                          size: 50,
                        )
                      : CachedNetworkImage(
                          imageUrl: product!.images![0].src!,
                          placeholder: (context, url) => customLoading(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
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
                          Text(
                            product!.productName!,
                            style: TextStyle(
                                fontSize: responsiveFont(10),
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          HtmlWidget(
                            product!.productDescription!.length > 100
                                ? '${product!.productDescription!.substring(0, 100)} ...'
                                : product!.productDescription!,
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: responsiveFont(9)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        children: [
                          Visibility(
                            visible: product!.discProduct != 0,
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: stringToCurrency(
                                          double.parse(product!.productRegPrice),
                                          context),
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize: responsiveFont(9),
                                          color: HexColor("C4C4C4"))),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
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
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
