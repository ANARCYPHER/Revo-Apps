import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nyoba/pages/product/product_detail_screen.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/provider/wishlist_provider.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/widgets/product/product_detail_modal.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class ListItemWishlist extends StatelessWidget {
  final ProductModel? product;
  final int? i, itemCount;
  final Future<dynamic> Function()? loadCartCount;

  ListItemWishlist({this.i, this.itemCount, this.product, this.loadCartCount});

  @override
  Widget build(BuildContext context) {
    var setWishlist = () async {
      final wishlist = Provider.of<WishlistProvider>(context, listen: false);

      wishlist.listWishlistProduct.removeAt(i!);

      final Future<Map<String, dynamic>?> setWishlist = wishlist
          .setWishlistProduct(context, productId: product!.id.toString());

      setWishlist.then((value) {
        print("200");
      });
    };

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
        decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(5)),
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: 80.h,
                  height: 80.h,
                  child: Image.network(product!.images![0].src!),
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product!.productName!,
                        style: TextStyle(fontSize: responsiveFont(12)),
                      ),
                      Visibility(
                        visible: product!.discProduct != 0,
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
                                "${product!.discProduct!.round()}%",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsiveFont(9)),
                              ),
                            ),
                            Container(
                              width: 5,
                            ),
                            Text(
                              product!.type == 'simple'
                                  ? stringToCurrency(
                                      double.parse(product!.productRegPrice),
                                      context)
                                  : product!.variationRegPrices!.first ==
                                          product!.variationRegPrices!.last
                                      ? '${stringToCurrency(product!.variationRegPrices!.first, context)}'
                                      : '${stringToCurrency(product!.variationRegPrices!.first, context)} - ${stringToCurrency(product!.variationRegPrices!.last, context)}',
                              style: TextStyle(
                                  fontSize: responsiveFont(8),
                                  color: HexColor("C4C4C4"),
                                  decoration: TextDecoration.lineThrough),
                            )
                          ],
                        ),
                      ),
                      product!.type == 'simple'
                          ? Text(
                              stringToCurrency(product!.productPrice!, context),
                              style: TextStyle(
                                  fontSize: responsiveFont(10),
                                  fontWeight: FontWeight.w600,
                                  color: secondaryColor),
                            )
                          : Text(
                              product!.variationPrices!.first ==
                                      product!.variationPrices!.last
                                  ? '${stringToCurrency(product!.variationPrices!.first, context)}'
                                  : '${stringToCurrency(product!.variationPrices!.first, context)} - ${stringToCurrency(product!.variationPrices!.last, context)}',
                              style: TextStyle(
                                  fontSize: responsiveFont(10),
                                  fontWeight: FontWeight.w600,
                                  color: secondaryColor),
                            ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: setWishlist,
                            child: Container(
                              width: 25.h,
                              height: 25.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: secondaryColor,
                                ),
                              ),
                              child: Icon(
                                Icons.delete,
                                color: primaryColor,
                              ),
                              // Image.asset("images/account/trash.png"),
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: secondaryColor,
                              ),
                            ),
                            onPressed: () {
                              if (product!.productStock! >= 1) {
                                showMaterialModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  builder: (context) => ProductDetailModal(
                                      productModel: product,
                                      type: "add",
                                      loadCount: loadCartCount),
                                );
                              } else {
                                snackBar(context,
                                    message: AppLocalizations.of(context)!
                                        .translate('product_out_stock')!);
                              }
                            },
                            child: Text(
                              "+ ${AppLocalizations.of(context)!.translate('add_to_cart')}",
                              style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: responsiveFont(9)),
                            ),
                          )
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
