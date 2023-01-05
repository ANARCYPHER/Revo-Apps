import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/product/product_detail_modal.dart';
import 'package:provider/provider.dart';

class ProductDetailVariant extends StatefulWidget {
  final ProductModel? productModel;
  final Future<dynamic> Function()? loadCount;
  const ProductDetailVariant({Key? key, this.productModel, this.loadCount})
      : super(key: key);

  @override
  State<ProductDetailVariant> createState() => _ProductDetailVariantState();
}

class _ProductDetailVariantState extends State<ProductDetailVariant> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (widget.productModel!.stockStatus != 'outofstock' &&
                widget.productModel!.productStock! >= 1) {
              showMaterialModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                builder: (context) => ProductDetailModal(
                    productModel: widget.productModel,
                    type: "all",
                    loadCount: widget.loadCount),
              );
            } else {
              snackBar(context,
                  message: AppLocalizations.of(context)!
                      .translate('product_out_stock')!);
            }
          },
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 5, top: 10, bottom: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.productModel!.variationLabel!.join(", "),
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  )
                ]),
          ),
        ),
        !Provider.of<HomeProvider>(context, listen: false)
                .showVariationWithImage
            ? Container(
                height: 30.h,
                padding: EdgeInsets.only(left: 10, right: 10),
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      if (i == 4 &&
                          widget.productModel!.customVariation!.first
                                  .optionVariation!.length >
                              6) {
                        return GestureDetector(
                          child: Container(
                            height: 10.h,
                            width: 100.w,
                            child: Icon(Icons.more_horiz),
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          openSheet(i);
                        },
                        child: Container(
                            height: 10.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                width: 2, color: Colors.grey[300]!,
                                // color: widget.productModel!.customVariation![i]
                                //             .selectedName ==
                                //         widget.productModel!.customVariation![i]
                                //             .optionVariation![i].name
                                //     ? primaryColor
                                //     : Colors.grey[300]!
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(widget.productModel!.customVariation!
                                  .first.optionVariation![i].name!),
                            )),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        width: 10,
                      );
                    },
                    itemCount: widget.productModel!.customVariation!.first
                        .optionVariation!.length),
              )
            : Container(
                height: 70.h,
                padding: EdgeInsets.only(bottom: 15, right: 15, left: 15),
                child: ListView.separated(
                  itemCount: widget.productModel!.customVariation!.first
                              .optionVariation!.length >
                          6
                      ? 5
                      : widget.productModel!.customVariation!.first
                          .optionVariation!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    if (i == 4 &&
                        widget.productModel!.customVariation!.first
                                .optionVariation!.length >
                            6) {
                      return GestureDetector(
                        child: Container(
                          height: 20.h,
                          width: 30.w,
                          child: Icon(Icons.more_horiz),
                        ),
                      );
                    }
                    if (widget.productModel!.customVariation!.first
                            .optionVariation![i].image ==
                        null) {
                      return GestureDetector(
                        onTap: () {
                          openSheet(i);
                        },
                        child: Container(
                          height: 20.h,
                          width: 60.w,
                          decoration: BoxDecoration(
                            // color: Colors.white,
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                                widget.productModel!.customVariation!.first
                                    .optionVariation![i].name!,
                                textAlign: TextAlign.center),
                          ),
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        openSheet(i);
                      },
                      child: CachedNetworkImage(
                        imageUrl: widget.productModel!.customVariation!.first
                            .optionVariation![i].image!,
                        imageBuilder: (context, imageProvider) => Container(
                          height: 20.h,
                          width: 60.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => customLoading(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: 10,
                    );
                  },
                ),
              )
      ],
    );
  }

  openSheet(int i) {
    widget.productModel!.customVariation!.first.selectedName =
        widget.productModel!.customVariation!.first.optionVariation![i].name!;
    widget.productModel!.customVariation!.first.selectedValue =
        widget.productModel!.customVariation!.first.optionVariation![i].value!;
    if (widget.productModel!.stockStatus != 'outofstock' &&
        widget.productModel!.productStock! >= 1) {
      showMaterialModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(12),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => ProductDetailModal(
            productModel: widget.productModel,
            type: "all",
            loadCount: widget.loadCount),
      );
    } else {
      snackBar(context,
          message:
              AppLocalizations.of(context)!.translate('product_out_stock')!);
    }
  }
}
