import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/category/category_screen.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app_localizations.dart';
import '../../../provider/app_provider.dart';

class BadgeCategory extends StatelessWidget {
  final List dataCategories;

  BadgeCategory(this.dataCategories);

  final int item = 6;
  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<AppNotifier>(context, listen: false).appLocal;
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 7,
      child: ListView.separated(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) {
            var categories = dataCategories[i];
            var imageCategories = categories.image;
            var titleCategories = categories.titleCategories;

            return Container(
                margin: EdgeInsets.only(
                    left: locale == Locale('ar')
                        ? i == dataCategories.length - 1
                            ? 15
                            : 0
                        : i == 0
                            ? 15
                            : 0,
                    right: locale == Locale('ar')
                        ? i == 0
                            ? 15
                            : 0
                        : i == dataCategories.length - 1
                            ? 15
                            : 0
                    // left: 3,
                    // right: 3,
                    ),
                width: MediaQuery.of(context).size.width / 6,
                child: InkWell(
                  onTap: () {
                    if (titleCategories == 'view_more') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CategoryScreen(
                                    isFromHome: false,
                                  )));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BrandProducts(
                                    categoryId:
                                        dataCategories[i].categories.toString(),
                                    brandName:
                                        dataCategories[i].titleCategories ==
                                                null
                                            ? ""
                                            : dataCategories[i].titleCategories,
                                  )));
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                          flex: 3,
                          child: itemCategory(imageCategories, i,
                              type: titleCategories == 'view_more'
                                  ? 'view_more'
                                  : 'false')),
                      Container(
                        height: 5,
                      ),
                      Flexible(
                        flex: 3,
                        child: Container(
                          child: Text(
                            titleCategories == null
                                ? ""
                                : titleCategories == "view_more"
                                    ? AppLocalizations.of(context)!
                                        .translate('view_more')
                                    : convertHtmlUnescape(titleCategories),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: responsiveFont(8),
                                height: 1,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                ));
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: 15,
            );
          },
          itemCount: dataCategories.length),
    );
  }

  Widget itemCategory(String? image, int i, {String type = 'url'}) {
    return Container(
        padding: EdgeInsets.all(5),
        child:
            // type == 'url'
            // ?
            CachedNetworkImage(
          imageUrl: image!,
          placeholder: (context, url) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: customLoadingShimmer(),
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.error_outline_rounded,
            size: 60,
          ),
        )
        // : Image.asset(image!),
        );
  }
}
