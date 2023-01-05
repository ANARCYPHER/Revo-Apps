import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/product/product_photoview.dart';
import 'package:nyoba/widgets/stateless_widget.dart';
import 'package:provider/provider.dart';

class ProductReviewModal extends StatefulWidget {
  final ProductModel? product;
  final double? rating;
  const ProductReviewModal({Key? key, this.product, this.rating = 0})
      : super(key: key);

  @override
  State<ProductReviewModal> createState() => _ProductReviewModalState();
}

class _ProductReviewModalState extends State<ProductReviewModal> {
  TextEditingController reviewController = new TextEditingController();
  double? _rating = 0;
  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ProductProvider>(context, listen: false);
    final photoReviewActive =
        Provider.of<HomeProvider>(context, listen: false).isPhotoReviewActive;
    final maxFiles =
        Provider.of<HomeProvider>(context, listen: false).photoMaxFiles;

    Widget buildBtnReview = Container(
      child: ListenableProvider.value(
        value: product,
        child: Consumer<ProductProvider>(builder: (context, value, child) {
          return InkWell(
            onTap: value.loadAddReview
                ? null
                : () async {
                    if (_rating != 0 && reviewController.text.isNotEmpty) {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      await context
                          .read<ProductProvider>()
                          .generateImageBase64()
                          .then((value) => context
                                  .read<ProductProvider>()
                                  .addReview(context,
                                      productId: widget.product!.id,
                                      rating: _rating,
                                      review: reviewController.text)
                                  .then((value) {
                                setState(() {
                                  reviewController.clear();
                                  _rating = 0;
                                });
                              }));
                    } else {
                      snackBar(context,
                          message: '${AppLocalizations.of(context)!.translate('set_review_first')}');
                    }
                  },
            child: value.loadAddReview
                ? Container(
                    width: 100.w,
                    height: 40.h,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey),
                    alignment: Alignment.center,
                    child: customLoading(color: Colors.white),
                  )
                : Container(
                    width: 100.w,
                    height: 40.h,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _rating != 0 && reviewController.text.isNotEmpty
                            ? secondaryColor
                            : Colors.grey),
                    alignment: Alignment.center,
                    child: Text(
                      '${AppLocalizations.of(context)!.translate('submit')}',
                      style: TextStyle(
                          fontSize: responsiveFont(10),
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
          );
        }),
      ),
    );

    return Container(
      child: Wrap(children: [
        RevoStateless(
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey,
                )),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(children: [
            RevoStateless(
              child: Column(children: [
                Row(
                  children: [
                    widget.product!.images!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.product!.images!.first.src!,
                            fit: BoxFit.fitHeight,
                            width: 50.w,
                            height: 50.h,
                            memCacheHeight: 100,
                            memCacheWidth: 100,
                            placeholder: (context, url) => customLoading(),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_not_supported_rounded,
                              size: 25,
                            ),
                          )
                        : Icon(
                            Icons.image_not_supported_rounded,
                            size: 25,
                          ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                      child: Text(
                        "${widget.product!.productName}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
              ]),
            ),
            RatingBar.builder(
              initialRating: _rating!,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 50,
              itemBuilder: (context, _) => Icon(
                Icons.star_rounded,
                color: Colors.amber,
              ),
              onRatingUpdate: (value) {
                print(value);
                setState(() {
                  _rating = value;
                });
              },
            ),
          ]),
        ),
        RevoStateless(
          child: Container(
              child: Divider(
                height: 1,
                thickness: 0.5,
              ),
              margin: EdgeInsets.only(bottom: 10)),
        ),
        RevoStateless(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${AppLocalizations.of(context)!.translate('leave_review')}'),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: reviewController,
                    maxLines: 5,
                    maxLength: 200,
                    style: TextStyle(
                      fontSize: responsiveFont(11),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10)),
                        hintText:
                            "${AppLocalizations.of(context)!.translate('hint_review_new')}",
                        hintStyle: TextStyle(
                            fontSize: responsiveFont(11),
                            color: HexColor('9e9e9e')),
                        counterText: ''),
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                ],
              )),
        ),
        RevoStateless(
            child: Visibility(
          visible: photoReviewActive,
          child: Column(
            children: [
              Consumer<ProductProvider>(builder: ((context, value, child) {
                if (value.imageFileList!.isNotEmpty) {
                  return Container(
                    height: 80.h,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, i) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      print("View Image");
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductPhotoView(
                                                    isFile: true,
                                                    image: File(value
                                                        .imageFileList![i]
                                                        .path),
                                                  )));
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      height: 70.h,
                                      width: 70.w,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Image.file(
                                              File(
                                                  value.imageFileList![i].path),
                                              fit: BoxFit.cover)),
                                    ),
                                  ),
                                  Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          print("Remove Image");
                                          setState(() {
                                            value.imageFileList!.removeAt(i);
                                          });
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(600),
                                          child: Container(
                                            color: Colors.white,
                                            child: Icon(
                                              Icons.cancel,
                                              size: 25,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                      ))
                                ],
                              );
                            },
                            itemCount: value.imageFileList!.length,
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Visibility(
                            visible: value.imageFileList!.length < maxFiles!,
                            child: Container(
                              child: InkWell(
                                onTap: () {
                                  value
                                      .onImageButtonPressed(
                                          context, ImageSource.gallery)
                                      .then((v) {
                                    if (value
                                        .imageFileInvalidList!.isNotEmpty) {
                                      _showAlert(value.imageFileInvalidList);
                                    }
                                  });
                                },
                                child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: Radius.circular(5),
                                    color: Colors.grey[300]!,
                                    child: Container(
                                      width: 65.w,
                                      height: 65.h,
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        "images/product_detail/camera-icon.png",
                                        height: 25.h,
                                      ),
                                    )),
                              ),
                            ),
                          )
                        ]),
                  );
                }
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: InkWell(
                    onTap: () {
                      value
                          .onImageButtonPressed(context, ImageSource.gallery)
                          .then((v) {
                        if (value.imageFileInvalidList!.isNotEmpty) {
                          _showAlert(value.imageFileInvalidList);
                        }
                      });
                    },
                    child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(5),
                        padding: EdgeInsets.all(5),
                        color: Colors.grey[300]!,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "images/product_detail/camera-icon.png",
                                  height: 25.h,
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text("${AppLocalizations.of(context)!.translate('upload_photo')}")
                              ]),
                        )),
                  ),
                );
              })),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.centerRight,
                child: Text(
                  "${AppLocalizations.of(context)!.translate('max_files')}$maxFiles",
                  style: TextStyle(
                      fontSize: responsiveFont(10),
                      fontStyle: FontStyle.italic),
                ),
              ),
              SizedBox(
                height: 50.h,
              ),
            ],
          ),
        )),
        RevoStateless(
          child: Divider(
            height: 1,
            thickness: 0.5,
          ),
        ),
        RevoStateless(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                        "${AppLocalizations.of(context)!.translate('cust_important')}\n${AppLocalizations.of(context)!.translate('thanks_review')}"),
                  ),
                  buildBtnReview,
                ],
              )),
        ),
      ]),
    );
  }

  void _showAlert(List<XFile>? _invalid) {
    final maxSize =
        Provider.of<HomeProvider>(context, listen: false).photoMaxSize;

    SimpleDialog alert = SimpleDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              Text(
                "${_invalid!.length} ${AppLocalizations.of(context)!.translate('warning_review')} $maxSize KB",
                style: TextStyle(fontSize: responsiveFont(12)),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              Container(
                height: 80.h,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        print("View Image");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductPhotoView(
                                      isFile: true,
                                      image: File(_invalid[i].path),
                                    )));
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5)),
                        height: 70.h,
                        width: 70.w,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.file(File(_invalid[i].path),
                                fit: BoxFit.cover)),
                      ),
                    );
                  },
                  itemCount: _invalid.length,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        color: Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 0,
                        height: 40,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "${AppLocalizations.of(context)!.translate('close')}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
