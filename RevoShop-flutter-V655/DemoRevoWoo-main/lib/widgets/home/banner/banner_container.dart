import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/product/product_detail_screen.dart';
import 'package:nyoba/utils/utility.dart';

import '../../../pages/blog/blog_detail_screen.dart';
import '../../webview/webview.dart';

class BannerContainer extends StatefulWidget {
  final List<dynamic> dataSlider;
  final int dataSliderLength;
  final double contentHeight;
  final Widget loading;

  BannerContainer(
      {required this.dataSliderLength,
      required this.contentHeight,
      required this.dataSlider,
      required this.loading});

  @override
  State<BannerContainer> createState() => _BannerContainerState();
}

class _BannerContainerState extends State<BannerContainer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 120.h,
          child: Swiper(
            itemBuilder: (BuildContext context, int i) {
              var slide = widget.dataSlider[i];

              var imageSlider = slide.image;
              var product = slide.product;

              return InkWell(
                onTap: () {
                  if (product != null) {
                    if (slide.linkTo == 'product') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductDetail(
                                    productId: slide.product.toString(),
                                  )));
                    }
                    if (slide.linkTo == 'URL') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewScreen(
                            title: slide.titleSlider,
                            url: slide.name,
                          ),
                        ),
                      );
                    }
                    if (slide.linkTo == 'category') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BrandProducts(
                                    categoryId: slide.product.toString(),
                                    brandName: slide.name,
                                  )));
                    }
                    if (slide.linkTo == 'blog') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlogDetail(
                            id: slide.product.toString(),
                          ),
                        ),
                      );
                    }

                    if (slide.linkTo == 'attribute') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BrandProducts(
                                    attribute: slide.product.toString(),
                                    brandName: slide.name,
                                  )));
                    }
                  }
                },
                child: CachedNetworkImage(
                  imageUrl: imageSlider,
                  placeholder: (context, url) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300])),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fill,
                      ),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
              );
            },
            itemCount: widget.dataSlider.length,
            viewportFraction: 1,
            autoplay: true,
            loop: true,
            scale: 0.8,
            autoplayDelay: 2600,
            pagination: SwiperPagination(
                margin: EdgeInsets.zero,
                builder: SwiperCustomPagination(builder: (context, config) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.dataSlider.asMap().entries.map((entry) {
                      return Container(
                        width: 9.0,
                        height: 3.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: config.activeIndex == entry.key
                                ? primaryColor
                                : Colors.white),
                      );
                    }).toList(),
                  );
                })),
          ),
        ),
      ],
    );
  }
}
