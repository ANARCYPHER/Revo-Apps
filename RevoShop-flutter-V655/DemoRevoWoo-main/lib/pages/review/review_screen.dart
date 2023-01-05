import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/models/review_model.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/review_provider.dart';
import 'package:nyoba/widgets/product/product_photoview.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_localizations.dart';
import '../../utils/utility.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewScreen extends StatefulWidget {
  ReviewScreen({Key? key}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  //init data blog
  load() async {
    await Provider.of<ReviewProvider>(context, listen: false)
        .fetchHistoryReview();
  }

  @override
  Widget build(BuildContext context) {
    final review = Provider.of<ReviewProvider>(context, listen: false);

    Widget buildReview = Container(
      child: ListenableProvider.value(
        value: review,
        child: Consumer<ReviewProvider>(builder: (context, value, child) {
          if (value.isLoading) {
            return ListView.separated(
                primary: false,
                shrinkWrap: true,
                itemCount: 44,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 5,
                    // color: HexColor('EEEEEE'),
                  );
                },
                itemBuilder: (context, i) {
                  return Column(
                    children: [buildShimmerHistory()],
                  );
                });
          }
          if (value.listHistory.isEmpty) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: primaryColor,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate("your_review")!,
                  )
                ],
              ),
            );
          }
          return ListView.separated(
              primary: false,
              shrinkWrap: true,
              itemCount: value.listHistory.length,
              separatorBuilder: (BuildContext context, int index) {
                return Container();
              },
              itemBuilder: (context, i) {
                return Column(
                  children: [buildCardHistory(value.listHistory[i])],
                );
              });
        }),
      ),
    );

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        // backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            // color: Colors.black,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.translate('review')!,
          style: TextStyle(
            fontSize: responsiveFont(14),
            fontWeight: FontWeight.w500,
            // color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [Expanded(child: buildReview)],
      ),
    );
  }

  Widget buildShimmerHistory() {
    return Container(
        width: 330.w,
        // color: Colors.white,
        padding: EdgeInsets.all(10),
        child: Shimmer.fromColors(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white),
                ),
                Expanded(
                    child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
                      ),
                      /*Text(
                  "Varian: M - Red",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: HexColor('424242')),
                ),*/
                      RatingBarIndicator(
                        rating: 5,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 45,
                        direction: Axis.horizontal,
                      ),
                      Container(
                        width: double.infinity,
                        height: 10,
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: 100,
                        height: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ))
              ],
            ),
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!));
  }

  Widget buildCardHistory(ReviewHistoryModel model) {
    final isPhotoActive =
        Provider.of<HomeProvider>(context, listen: false).isPhotoReviewActive;
    return Card(
      margin: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
              child: Image.network(model.imageProduct!),
            ),
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    convertDateFormatShortMonth(
                        DateTime.parse(model.commentDate!)),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: HexColor('9E9E9E')),
                  ),
                  Text(
                    model.titleProduct!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      // color: HexColor('212121')
                    ),
                  ),
                  /*Text(
                    "Varian: M - Red",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: HexColor('424242')),
                  ),*/
                  RatingBarIndicator(
                    rating: double.parse(model.star!),
                    itemBuilder: (context, index) => Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 45,
                    direction: Axis.horizontal,
                  ),
                  Text(
                    model.content!.isNotEmpty ? model.content! : 'No Reviews',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: HexColor('9E9E9E')),
                  ),
                  model.image!.isEmpty || !isPhotoActive
                      ? Container()
                      : GridView.builder(
                          shrinkWrap: true,
                          itemCount: model.image!.length,
                          physics: ScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 1 / 1,
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5),
                          itemBuilder: (context, i) {
                            final _imageReview = model.image![i];
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                print("View Image");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProductPhotoView(
                                              image: _imageReview,
                                            )));
                              },
                              child: Container(
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5)),
                                height: 65.h,
                                width: 65.w,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: CachedNetworkImage(
                                      imageUrl: _imageReview,
                                      fit: BoxFit.fitHeight,
                                      memCacheHeight: 100,
                                      memCacheWidth: 100,
                                      placeholder: (context, url) =>
                                          customLoading(),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                        Icons.image_not_supported_rounded,
                                        size: 25,
                                      ),
                                    )),
                              ),
                            );
                          }),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
