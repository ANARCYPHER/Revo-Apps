import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/pages/blog/blog_detail_screen.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/product/product_detail_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/webview/webview.dart';
import 'package:provider/provider.dart';

class BannerPopImage extends StatelessWidget {
  const BannerPopImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bannerPopUp =
        Provider.of<HomeProvider>(context, listen: false).bannerPopUp;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.read<HomeProvider>().changePopBannerStatus(false);

              if (bannerPopUp.first.linkTo == 'URL') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewScreen(
                      title: bannerPopUp.first.titleSlider,
                      url: bannerPopUp.first.name,
                    ),
                  ),
                );
              }
              if (bannerPopUp.first.linkTo == 'category') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BrandProducts(
                              categoryId: bannerPopUp.first.product.toString(),
                              brandName: bannerPopUp.first.name,
                            )));
              }
              if (bannerPopUp.first.linkTo == 'blog') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlogDetail(
                      id: bannerPopUp.first.product.toString(),
                    ),
                  ),
                );
              }
              if (bannerPopUp.first.linkTo == 'product') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductDetail(
                              productId: bannerPopUp.first.product.toString(),
                            )));
              }
              if (bannerPopUp.first.linkTo == 'attribute') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BrandProducts(
                              attribute: bannerPopUp.first.product.toString(),
                              brandName: bannerPopUp.first.name,
                            )));
              }
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: CachedNetworkImage(
                fit: BoxFit.contain,
                imageUrl: bannerPopUp.first.image!,
                // placeholder: (context, url) => customLoading(),
                errorWidget: (context, url, error) => Icon(
                  Icons.image_not_supported_rounded,
                  size: 25,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              context.read<HomeProvider>().changePopBannerStatus(false);
              Navigator.pop(context);
            },
            child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5))),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withOpacity(0.7),
                )),
          )
        ],
      ),
    );
  }
}
