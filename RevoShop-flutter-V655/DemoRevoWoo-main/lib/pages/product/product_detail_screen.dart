import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/pages/order/cart_screen.dart';
import 'package:nyoba/pages/product/product_more_screen.dart';
import 'package:nyoba/pages/wishlist/wishlist_screen.dart';
import 'package:nyoba/provider/flash_sale_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/provider/review_provider.dart';
import 'package:nyoba/provider/wishlist_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/share_link.dart';
import 'package:nyoba/widgets/home/card_item_small.dart';
import 'package:nyoba/widgets/home/grid_item.dart';
import 'package:nyoba/widgets/product/contact_modal.dart';
import 'package:nyoba/widgets/product/grid_item_shimmer.dart';
import 'package:nyoba/widgets/product/product_detail_modal.dart';
import 'package:nyoba/widgets/product/product_detail_variant.dart';
import 'package:nyoba/widgets/product/product_photoview.dart';
import 'package:nyoba/widgets/product/product_detail_shimmer.dart';
import 'package:nyoba/widgets/product_review/product_review_modal.dart';
import 'package:nyoba/widgets/youtube/youtube_player.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../app_localizations.dart';
import '../../models/product_model.dart';
import '../../provider/app_provider.dart';
import '../../utils/utility.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'product_review_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:like_button/like_button.dart';
import 'package:flutter/services.dart';
import 'featured_products/all_featured_product_screen.dart';

class ProductDetail extends StatefulWidget {
  final String? productId;
  final String? slug;
  ProductDetail({Key? key, this.productId, this.slug}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail>
    with TickerProviderStateMixin {
  late AnimationController _colorAnimationController;
  late AnimationController _textAnimationController;

  int itemCount = 10;

  bool? isWishlist = false;

  int cartCount = 0;
  TextEditingController reviewController = new TextEditingController();

  double rating = 0;

  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 30;
  bool isFlashSale = false;

  ProductModel? productModel;
  final CarouselController _controller = CarouselController();
  int _current = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ScrollController _scrollController = new ScrollController();
  int page = 1;

  @override
  void initState() {
    super.initState();
    final product = Provider.of<ProductProvider>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (product.listCategoryProduct.length % 20 == 0) {
          setState(() {
            page++;
          });
          loadLikeProduct();
        }
      }
    });
    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _textAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    loadDetail();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.axis == Axis.vertical) {
      _colorAnimationController.animateTo(scrollInfo.metrics.pixels / 350);
      _textAnimationController
          .animateTo((scrollInfo.metrics.pixels - 350) / 50);
      return true;
    } else {
      return false;
    }
  }

  Future loadDetail() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    loadCartCount();
    if (widget.slug == null) {
      await Provider.of<ProductProvider>(context, listen: false)
          .fetchProductDetail(widget.productId)
          .then((value) async {
        setState(() {
          productModel = value;
          printLog(json.encode(productModel!.isWishlist), name: "wishlist");
          printLog(json.encode(productModel), name: 'Product Model');
          productModel!.isSelected = false;
          if (Session.data.getBool('isLogin')!) {
            isWishlist = productModel!.isWishlist;
          }
        });
        checkFlashSale();

        if (Session.data.getBool('isLogin')!)
          await productProvider.hitViewProducts(widget.productId).then(
              (value) async => await productProvider.fetchRecentProducts());
      });
    } else {
      await Provider.of<ProductProvider>(context, listen: false)
          .fetchProductDetailSlug(widget.slug)
          .then((value) {
        setState(() {
          productModel = value;
          productModel!.isSelected = false;
          productProvider.loadingDetail = false;
          printLog(json.encode(productModel), name: 'Product Model');
        });
        checkFlashSale();
      });
    }
    if (productModel!.type == 'variable') {
      for (int j = 0; j < productModel!.availableVariations!.length; j++) {
        if (productModel!.availableVariations![j].displayRegularPrice -
                productModel!.availableVariations![j].displayPrice !=
            0) {
          double temp = ((productModel!
                          .availableVariations![j].displayRegularPrice -
                      productModel!.availableVariations![j].displayPrice) /
                  productModel!.availableVariations![j].displayRegularPrice) *
              100;
          if (productModel!.discProduct! < temp) {
            productModel!.discProduct = temp;
          }
        }
      }
    }
    if (mounted) secondLoad();
  }

  secondLoad() {
    // final wishlist = Provider.of<WishlistProvider>(context, listen: false);
    // if (Session.data.getBool('isLogin')!) {
    //   final Future<Map<String, dynamic>?> checkWishlist =
    //       wishlist.checkWishlistProduct(productId: productModel!.id.toString());

    //   checkWishlist.then((value) {
    //     printLog('Cek Wishlist Success');
    //     setState(() {
    //       isWishlist = value!['message'];
    //     });
    //   });
    // }
    loadReviewProduct();
  }

  Future<bool?> setWishlist(bool? isLiked) async {
    if (Session.data.getBool('isLogin')!) {
      setState(() {
        isWishlist = !isWishlist!;
        isLiked = isWishlist;
      });
      final wishlist = Provider.of<WishlistProvider>(context, listen: false);

      final Future<Map<String, dynamic>?> setWishlist = wishlist
          .setWishlistProduct(context, productId: productModel!.id.toString());

      setWishlist.then((value) async {
        await Provider.of<WishlistProvider>(context, listen: false)
            .loadWishlistProduct()
            .then((value) async {
          await Provider.of<WishlistProvider>(context, listen: false)
              .fetchWishlistProducts(wishlist.productWishlist!);
        });
        print("200");
      });
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => WishList()));
    }
    return isLiked;
  }

  Future<dynamic> loadCartCount() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<OrderProvider>(context, listen: false)
          .loadCartCount()
          .then((value) {
        setState(() {
          cartCount = value;
        });
      });
    });
  }

  loadReviewProduct() async {
    await Provider.of<ReviewProvider>(context, listen: false)
        .fetchReviewProduct(productModel!.id.toString())
        .then((value) => loadLikeProduct());
  }

  loadLikeProduct() async {
    if (mounted) {
      await Provider.of<ProductProvider>(context, listen: false)
          .fetchCategoryProduct(productModel!.categories![0].id.toString(),
              page, 'desc', 'popularity');
    }
  }

  checkFlashSale() {
    final flashsale = Provider.of<FlashSaleProvider>(context, listen: false);
    if (flashsale.flashSales.isNotEmpty) {
      setState(() {
        endTime = DateTime.parse(flashsale.flashSales[0].endDate!)
            .millisecondsSinceEpoch;
      });
    }

    if (flashsale.flashSaleProducts.isNotEmpty) {
      flashsale.flashSaleProducts.forEach((element) {
        if (productModel!.id.toString() == element.id.toString()) {
          setState(() {
            isFlashSale = true;
          });
        }
      });
    }
  }

  refresh() async {
    this.setState(() {});
    await loadDetail().then((value) {
      this.setState(() {});
      _refreshController.refreshCompleted();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ProductProvider>(context, listen: false);
    final isSolid = Provider.of<HomeProvider>(context, listen: false).isSolid;

    Widget buildWishlistBtn = LikeButton(
      size: 25,
      onTap: setWishlist,
      circleColor: CircleColor(start: primaryColor, end: secondaryColor),
      bubblesColor: BubblesColor(
        dotPrimaryColor: primaryColor,
        dotSecondaryColor: secondaryColor,
      ),
      isLiked: isWishlist,
      likeBuilder: (bool isLiked) {
        if (!isLiked) {
          return Icon(
            Icons.favorite_border,
            color: Colors.grey,
            size: 25,
          );
        }
        return Icon(
          Icons.favorite,
          color: Colors.red,
          size: 25,
        );
      },
    );

    return ListenableProvider.value(
      value: product,
      child: Consumer<ProductProvider>(builder: (context, value, child) {
        if (value.loadingDetail) {
          return ProductDetailShimmer();
        }
        List<Widget> itemSlider = [
          Icon(
            Icons.broken_image_outlined,
            size: 80,
          )
        ];
        if (productModel!.images!.isNotEmpty ||
            productModel!.videos!.isNotEmpty) {
          itemSlider = [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductPhotoView(
                              image: productModel!.images![0].src,
                            )));
              },
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: CachedNetworkImage(
                  imageUrl: productModel!.images![0].src!,
                  placeholder: (context, url) => customLoading(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported_rounded,
                    size: 25,
                  ),
                ),
              ),
            ),
            for (var i = 0; i < productModel!.videos!.length; i++)
              Container(
                child: YoutubePlayerWidget(
                  url: productModel!.videos![i].content,
                ),
              ),
            for (var i = 1; i < productModel!.images!.length; i++)
              InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductPhotoView(
                                  image: productModel!.images![i].src,
                                )));
                  },
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: CachedNetworkImage(
                      imageUrl: productModel!.images![i].src!,
                      placeholder: (context, url) => customLoading(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image_not_supported_rounded,
                        size: 25,
                      ),
                    ),
                  ))
          ];
        }
        final isDarkMode =
            Provider.of<AppNotifier>(context, listen: false).isDarkMode;
        return OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              _current = 0;
              return Scaffold(
                body: Container(
                  child: YoutubePlayerWidget(
                    url: productModel!.videos![0].content,
                  ),
                ),
              );
            } else if (orientation == Orientation.portrait) {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                  overlays: SystemUiOverlay.values);
              return ColorfulSafeArea(
                color: Colors.white,
                child: Scaffold(
                  appBar: appBar(productModel!) as PreferredSizeWidget?,
                  body: Stack(
                    children: [
                      SmartRefresher(
                        controller: _refreshController,
                        onRefresh: refresh,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  CarouselSlider(
                                    options: CarouselOptions(
                                        enableInfiniteScroll: false,
                                        viewportFraction: 1,
                                        aspectRatio: 1 / 1,
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            _current = index;
                                          });
                                        }),
                                    carouselController: _controller,
                                    items: itemSlider,
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: itemSlider
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        return GestureDetector(
                                          onTap: () => _controller
                                              .animateToPage(entry.key),
                                          child: Container(
                                              width: 10.0,
                                              height: 10.0,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 5.0,
                                                  horizontal: 2.0),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _current == entry.key
                                                    ? primaryColor
                                                    : primaryColor
                                                        .withOpacity(0.5),
                                              )),
                                        );
                                      }).toList(),
                                    ),
                                  )
                                ],
                              ),
                              Visibility(
                                  visible: isFlashSale,
                                  child: Container(
                                      alignment: Alignment.center,
                                      child: CountdownTimer(
                                        endTime: endTime,
                                        widgetBuilder:
                                            (_, CurrentRemainingTime? time) {
                                          if (time == null) {
                                            return Container();
                                          } else {
                                            int? hours = time.hours ?? 0;
                                            if (time.days != null &&
                                                time.days != 0) {
                                              hours = (time.days! * 24) +
                                                  time.hours!;
                                            } else if (time.hours != null) {
                                              hours = time.hours;
                                            } else if (time.hours == null) {
                                              hours = 0;
                                            } else if (time.hours == null &&
                                                time.min == null &&
                                                time.sec == null) {
                                              return Text('Flash Sale END');
                                            }
                                            return Container(
                                              width: double.infinity,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: primaryColor,
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: AssetImage(
                                                          "images/product_detail/bg_flashsale.png"))),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "FLASH SALE ENDS IN :",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 14),
                                                        ),
                                                        Text(
                                                            "${productModel!.totalSales} Item Sold",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10)),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 30.h,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          alignment:
                                                              Alignment.center,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 4,
                                                                  vertical: 3),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          width: 35.w,
                                                          height: 30.h,
                                                          child: Text(
                                                            hours! < 10
                                                                ? "0$hours"
                                                                : "$hours",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color:
                                                                    primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    responsiveFont(
                                                                        12)),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          child: Text(
                                                            ":",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    responsiveFont(
                                                                        12)),
                                                          ),
                                                        ),
                                                        Container(
                                                          alignment:
                                                              Alignment.center,
                                                          padding:
                                                              EdgeInsets.all(3),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          width: 30.w,
                                                          height: 30.h,
                                                          child: Text(
                                                            time.min == null
                                                                ? "00"
                                                                : time.min! < 10
                                                                    ? "0${time.min}"
                                                                    : "${time.min}",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color:
                                                                    primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    responsiveFont(
                                                                        12)),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          child: Text(
                                                            ":",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    responsiveFont(
                                                                        12)),
                                                          ),
                                                        ),
                                                        Container(
                                                          alignment:
                                                              Alignment.center,
                                                          padding:
                                                              EdgeInsets.all(3),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          width: 30.w,
                                                          height: 30.h,
                                                          child: Text(
                                                            time.sec! < 10
                                                                ? "0${time.sec}"
                                                                : "${time.sec}",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color:
                                                                    primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    responsiveFont(
                                                                        12)),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                      ))),
                              firstPart(productModel!, buildWishlistBtn),
                              Visibility(
                                  visible: productModel!.type == 'variable',
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 1,
                                        // color: HexColor("EEEEEE"),
                                      ),
                                      ProductDetailVariant(
                                        productModel: productModel!,
                                        loadCount: loadCartCount,
                                      ),
                                    ],
                                  )),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 15),
                                width: double.infinity,
                                height: 5,
                                color: isDarkMode
                                    ? Colors.black12
                                    : HexColor("EEEEEE"),
                              ),
                              secondPart(productModel!),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 15),
                                width: double.infinity,
                                height: 5,
                                color: isDarkMode
                                    ? Colors.black12
                                    : HexColor("EEEEEE"),
                              ),
                              Visibility(
                                visible: Provider.of<HomeProvider>(context,
                                        listen: false)
                                    .showRatingSection,
                                child: Column(
                                  children: [
                                    thirdPart(),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 15),
                                      width: double.infinity,
                                      height: 5,
                                      color: isDarkMode
                                          ? Colors.black12
                                          : HexColor("EEEEEE"),
                                    ),
                                    commentPart(),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 15),
                                      width: double.infinity,
                                      height: 5,
                                      color: isDarkMode
                                          ? Colors.black12
                                          : HexColor("EEEEEE"),
                                    ),
                                  ],
                                ),
                              ),
                              featuredProduct(),
                              SizedBox(
                                height: 15,
                              ),
                              onSaleProduct(),
                              SizedBox(
                                height: 15,
                              ),
                              sameCategoryProduct(),
                              if (product.loadingBrand && page != 1)
                                customLoading(),
                              SizedBox(
                                height: 70.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[900] : Colors.white,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 15.0,
                              )
                            ],
                          ),
                          height: 45.h,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: secondaryColor)),
                                child: InkWell(
                                  onTap: () {
                                    showMaterialModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      builder: (context) => ContactModal(
                                          idProduct:
                                              int.parse(widget.productId!)),
                                    );
                                  },
                                  child: ShaderMask(
                                    child: Image(
                                      image: AssetImage(
                                          "images/lobby/icon-cs-app-bar.png"),
                                      height: 30.h,
                                    ),
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                        colors: [
                                          secondaryColor,
                                          secondaryColor
                                        ],
                                        stops: [
                                          0.0,
                                          0.5,
                                        ],
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.srcATop,
                                  ),
                                ),
                              ),
                              Container(
                                height: 30.h,
                                child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: productModel!.stockStatus !=
                                                      'outofstock' &&
                                                  productModel!.productStock! >=
                                                      1
                                              ? secondaryColor
                                              : Colors
                                                  .grey, //Color of the border
                                          //Style of the border
                                        ),
                                        alignment: Alignment.center,
                                        shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(5))),
                                    onPressed: () {
                                      if (productModel!.stockStatus !=
                                              'outofstock' &&
                                          productModel!.productStock! >= 1) {
                                        showMaterialModalBottomSheet(
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                          ),
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          builder: (context) =>
                                              ProductDetailModal(
                                                  productModel: productModel,
                                                  type: "add",
                                                  loadCount: loadCartCount),
                                        );
                                      } else {
                                        snackBar(context,
                                            message:
                                                AppLocalizations.of(context)!
                                                    .translate(
                                                        'product_out_stock')!);
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          size: responsiveFont(9),
                                          color: productModel!.stockStatus !=
                                                      'outofstock' &&
                                                  productModel!.productStock! >=
                                                      1
                                              ? secondaryColor
                                              : Colors.grey,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .translate('add_to_cart')!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: responsiveFont(9),
                                            color: productModel!.stockStatus !=
                                                        'outofstock' &&
                                                    productModel!
                                                            .productStock! >=
                                                        1
                                                ? secondaryColor
                                                : Colors.grey,
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: isSolid ? buttonColor : null,
                                    gradient: isSolid
                                        ? null
                                        : LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: productModel!.stockStatus !=
                                                        'outofstock' &&
                                                    productModel!
                                                            .productStock! >=
                                                        1
                                                ? [primaryColor, secondaryColor]
                                                : [Colors.grey, Colors.grey])),
                                width: 132.w,
                                height: 30.h,
                                child: TextButton(
                                  onPressed: () {
                                    if (productModel!.stockStatus !=
                                            'outofstock' &&
                                        productModel!.productStock! >= 1) {
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                        ),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        builder: (context) =>
                                            ProductDetailModal(
                                                productModel: productModel,
                                                type: "buy",
                                                loadCount: loadCartCount),
                                      );
                                    } else {
                                      snackBar(context,
                                          message: AppLocalizations.of(context)!
                                              .translate('product_out_stock')!);
                                    }
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('buy_now')!,
                                    style: TextStyle(
                                        color: isSolid
                                            ? textButtonColor
                                            : Colors.white,
                                        fontSize: responsiveFont(9)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        );
      }),
    );
  }

  Widget sameCategoryProduct() {
    final product = Provider.of<ProductProvider>(context, listen: false);

    return ListenableProvider.value(
        value: product,
        child: Consumer<ProductProvider>(builder: (context, value, child) {
          if (value.loadingCategory && page == 1) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                      childAspectRatio: 65 / 125),
                  itemBuilder: (context, i) {
                    return GridItemShimmer();
                  }),
            );
          }
          return Visibility(
              visible: value.listCategoryProduct.isNotEmpty,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(left: 15, bottom: 10, right: 15),
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('you_might_also')!,
                      style: TextStyle(
                          fontSize: responsiveFont(14),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: GridView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: value.listCategoryProduct.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 2,
                            childAspectRatio: 78 / 125),
                        itemBuilder: (context, i) {
                          return GridItem(
                            i: i,
                            itemCount: value.listCategoryProduct.length,
                            product: value.listCategoryProduct[i],
                          );
                        }),
                  ),
                  if (value.loadingCategory && page != 1) customLoading()
                ],
              ));
        }));
  }

  Widget featuredProduct() {
    return Consumer<ProductProvider>(builder: (context, value, child) {
      if (value.loadingFeatured) {
        return customLoading();
      }
      return Visibility(
          visible: value.listFeaturedProduct.isNotEmpty,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 15, bottom: 10, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .translate('featured_products')!,
                      style: TextStyle(
                          fontSize: responsiveFont(14),
                          fontWeight: FontWeight.w600),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AllFeaturedProducts()));
                      },
                      child: Text(
                        AppLocalizations.of(context)!.translate('more')!,
                        style: TextStyle(
                            fontSize: responsiveFont(12),
                            fontWeight: FontWeight.w600,
                            color: secondaryColor),
                      ),
                    )
                  ],
                ),
              ),
              AspectRatio(
                aspectRatio: 3 / 2,
                child: ListView.separated(
                  itemCount: value.listFeaturedProduct.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    return CardItem(
                      product: value.listFeaturedProduct[i],
                      i: i,
                      itemCount: value.listFeaturedProduct.length,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: 5,
                    );
                  },
                ),
              )
            ],
          ));
    });
  }

  Widget onSaleProduct() {
    return Consumer<FlashSaleProvider>(builder: (context, value, child) {
      return Visibility(
          visible: value.flashSaleProducts.isNotEmpty,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 15, bottom: 10, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('flashsale')!,
                      style: TextStyle(
                          fontSize: responsiveFont(14),
                          fontWeight: FontWeight.w600),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductMoreScreen(
                                      include: value.flashSales[0].products,
                                      name: AppLocalizations.of(context)!
                                          .translate('flashsale')!,
                                    )));
                      },
                      child: Text(
                        AppLocalizations.of(context)!.translate('more')!,
                        style: TextStyle(
                            fontSize: responsiveFont(12),
                            fontWeight: FontWeight.w600,
                            color: secondaryColor),
                      ),
                    )
                  ],
                ),
              ),
              AspectRatio(
                aspectRatio: 3 / 1.9,
                child: ListView.separated(
                  itemCount: value.flashSaleProducts.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    return CardItem(
                      product: value.flashSaleProducts[i],
                      i: i,
                      itemCount: value.flashSaleProducts.length,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: 5,
                    );
                  },
                ),
              )
            ],
          ));
    });
  }

  Widget thirdPart() {
    final review = Provider.of<ReviewProvider>(context, listen: false);
    final product = Provider.of<ProductProvider>(context, listen: false);
    final isPhotoActive =
        Provider.of<HomeProvider>(context, listen: false).isPhotoReviewActive;

    Widget buildReview = Container(
      child: ListenableProvider.value(
        value: review,
        child: Consumer<ReviewProvider>(builder: (context, value, child) {
          if (value.isLoadingReview) {
            return Container();
          }
          if (value.listReviewLimit.isEmpty) {
            return Text(
              AppLocalizations.of(context)!.translate('empty_review_product')!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RatingBarIndicator(
                    rating: value.listReviewLimit[0].rating!.toDouble(),
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 15,
                    direction: Axis.horizontal,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "by ",
                    style: TextStyle(
                        color: HexColor("929292"), fontSize: responsiveFont(9)),
                  ),
                  Text(
                    value.listReviewLimit[0].reviewer!,
                    style: TextStyle(fontSize: responsiveFont(9)),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              HtmlWidget(
                value.listReviewLimit[0].review!,
                textStyle: TextStyle(
                    // color: HexColor("464646"),
                    fontWeight: FontWeight.w400,
                    fontSize: 10),
              ),
              value.listReviewLimit[0].image!.isEmpty || !isPhotoActive
                  ? Container()
                  : GridView.builder(
                      shrinkWrap: true,
                      itemCount: value.listReviewLimit[0].image!.length,
                      physics: ScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1 / 1,
                          crossAxisCount: 4,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5),
                      itemBuilder: (context, i) {
                        final _imageReview = value.listReviewLimit[0].image![i];
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
                            height: 70.h,
                            width: 70.w,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  imageUrl: _imageReview,
                                  fit: BoxFit.fitHeight,
                                  memCacheHeight: 100,
                                  memCacheWidth: 100,
                                  placeholder: (context, url) =>
                                      customLoading(),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.image_not_supported_rounded,
                                    size: 25,
                                  ),
                                )),
                          ),
                        );
                      }),
            ],
          );
        }),
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.translate('review')!,
                    style: TextStyle(
                        fontSize: responsiveFont(10),
                        fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Container(
                          width: 15.w,
                          height: 15.h,
                          child: Image.asset(
                              "images/product_detail/starGold.png")),
                      Text(
                        " ${product.productDetail!.avgRating} (${product.productDetail!.ratingCount} ${AppLocalizations.of(context)!.translate('review')})",
                        style: TextStyle(fontSize: responsiveFont(10)),
                      ),
                    ],
                  )
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductReview(
                                productId: productModel!.id.toString(),
                              )));
                },
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('see_all')!,
                      style: TextStyle(fontSize: responsiveFont(11)),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      size: responsiveFont(20),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 10,
          ),
          buildReview
        ],
      ),
    );
  }

  Widget commentPart() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.translate('add_review')!,
            style: TextStyle(
                fontSize: responsiveFont(12), fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            AppLocalizations.of(context)!.translate('comment')!,
            style: TextStyle(
                fontSize: responsiveFont(10), fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              showMaterialModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                builder: (context) =>
                    ProductReviewModal(rating: rating, product: productModel),
              ).then((value) => context.read<ProductProvider>().resetReview());
            },
            child: TextField(
              controller: reviewController,
              maxLines: 2,
              enabled: false,
              style: TextStyle(
                fontSize: 10,
              ),
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.grey)),
                border: OutlineInputBorder(
                    borderSide: new BorderSide(color: primaryColor)),
                hintText:
                    AppLocalizations.of(context)!.translate('hint_review'),
                hintStyle: TextStyle(fontSize: 10, color: HexColor('9e9e9e')),
              ),
              textInputAction: TextInputAction.done,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 25,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (value) {
              print(value);
              setState(() {
                rating = value;
              });
              showMaterialModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                builder: (context) =>
                    ProductReviewModal(rating: rating, product: productModel),
              ).then((value) => context.read<ProductProvider>().resetReview());
            },
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget secondPart(ProductModel model) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.translate('description')!,
            style: TextStyle(
                fontSize: responsiveFont(12), fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 5,
          ),
          HtmlWidget(
            model.productDescription!,
            textStyle: TextStyle(
              color: HexColor("929292"),
            ),
          ),
        ],
      ),
    );
  }

  Widget firstPart(ProductModel model, Widget btnFav) {
    return Container(
      margin: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              productModel!.type == 'simple'
                  ? RichText(
                      text: TextSpan(
                        style: TextStyle(color: primaryColor),
                        children: <TextSpan>[
                          TextSpan(
                              text: stringToCurrency(
                                  productModel!.productPrice!, context),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: responsiveFont(15),
                                  color: primaryColor)),
                        ],
                      ),
                    )
                  : RichText(
                      text: TextSpan(
                        style: TextStyle(color: primaryColor),
                        children: <TextSpan>[
                          productModel!.variationPrices!.isEmpty
                              ? TextSpan(
                                  text: '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: responsiveFont(11),
                                      color: secondaryColor))
                              : TextSpan(
                                  text: productModel!.variationPrices!.first ==
                                          productModel!.variationPrices!.last
                                      ? '${stringToCurrency(productModel!.variationPrices!.first, context)}'
                                      : '${stringToCurrency(productModel!.variationPrices!.first, context)} - ${stringToCurrency(productModel!.variationPrices!.last, context)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: responsiveFont(15),
                                      color: primaryColor)),
                        ],
                      ),
                    ),
              btnFav
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Visibility(
            visible: model.discProduct != 0,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: secondaryColor),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .translate('save_product')!,
                        style: TextStyle(
                            fontSize: responsiveFont(8),
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        "${model.discProduct!.round()}%",
                        style: TextStyle(
                            fontSize: responsiveFont(8), color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: primaryColor),
                    children: <TextSpan>[
                      TextSpan(
                          text: productModel!.type == 'simple'
                              ? stringToCurrency(
                                  double.parse(productModel!.productRegPrice),
                                  context)
                              : productModel!.variationRegPrices!.first ==
                                      productModel!.variationRegPrices!.last
                                  ? '${stringToCurrency(productModel!.variationRegPrices!.first, context)}'
                                  : '${stringToCurrency(productModel!.variationRegPrices!.first, context)} - ${stringToCurrency(productModel!.variationRegPrices!.last, context)}',
                          style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontSize: responsiveFont(12),
                              color: HexColor("C4C4C4"))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            model.productName!,
            style: TextStyle(fontSize: responsiveFont(11)),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Visibility(
                visible: Provider.of<HomeProvider>(context, listen: false)
                    .showSoldItem,
                child: Row(
                  children: [
                    Text(
                      "${AppLocalizations.of(context)!.translate('sold')} ",
                      style: TextStyle(
                          fontSize: responsiveFont(10),
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "${model.totalSales}",
                      style: TextStyle(fontSize: responsiveFont(10)),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: Provider.of<HomeProvider>(context, listen: false)
                        .showSoldItem &&
                    Provider.of<HomeProvider>(context, listen: false)
                        .showAverageRating,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 11,
                  width: 1,
                  color: Colors.black,
                ),
              ),
              Visibility(
                visible: Provider.of<HomeProvider>(context, listen: false)
                    .showAverageRating,
                child: Row(
                  children: [
                    Container(
                        width: 15.w,
                        height: 15.h,
                        child:
                            Image.asset("images/product_detail/starGold.png")),
                    Text(
                      " ${model.avgRating} (${model.ratingCount})",
                      style: TextStyle(fontSize: responsiveFont(10)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Visibility(
            visible: Provider.of<HomeProvider>(context, listen: false)
                    .showAverageRating ||
                Provider.of<HomeProvider>(context, listen: false).showSoldItem,
            child: SizedBox(
              height: 10,
            ),
          ),
          Text(
            model.stockStatus == 'instock'
                ? '${AppLocalizations.of(context)!.translate('available')}'
                : '${AppLocalizations.of(context)!.translate('out_stock')}',
            style: TextStyle(
                fontSize: responsiveFont(11),
                fontWeight: FontWeight.bold,
                color:
                    model.stockStatus == 'instock' ? Colors.green : Colors.red),
          ),
          SizedBox(
            height: 10,
          ),
          HtmlWidget(
            model.productShortDesc!,
            textStyle: TextStyle(
                color: HexColor("929292"), fontSize: responsiveFont(10)),
          ),
        ],
      ),
    );
  }

  Widget appBar(ProductModel model) {
    final locale = Provider.of<AppNotifier>(context, listen: false).appLocal;
    return AppBar(
      // backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back,
          // color: Colors.black,
        ),
      ),
      title: Text(
        model.productName ?? "",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: responsiveFont(16),
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CartScreen(
                          isFromHome: false,
                        )));
          },
          child: Container(
            width: 50,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.shopping_cart,
                  // color: Colors.black,
                ),
                Positioned(
                  right: 0,
                  top: 7,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: primaryColor),
                    alignment: Alignment.center,
                    child: Text(
                      cartCount.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsiveFont(9),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            shareLinks('product', model.link, context, locale);
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Icon(
              Icons.share,
              // color: Colors.black,
            ),
          ),
        )
      ],
    );
  }

  Widget itemList(
      String title, String discount, String price, String crossedPrice, int i) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProductDetail()));
      },
      child: Container(
        margin: EdgeInsets.only(
            left: i == 0 ? 15 : 0, right: i == itemCount - 1 ? 15 : 0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        width: MediaQuery.of(context).size.width / 3,
        height: double.infinity,
        child: Card(
          elevation: 5,
          margin: EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        topLeft: Radius.circular(5)),
                    color: primaryColor,
                  ),
                  child: Image.asset("images/lobby/laptop.png"),
                ),
              ),
              Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: responsiveFont(10)),
                          ),
                        ),
                        Container(
                          height: 5,
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: Text(
                              price,
                              style: TextStyle(
                                  fontSize: responsiveFont(10),
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        Container(
                          height: 5,
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
