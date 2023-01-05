import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/models/coupon_model.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/coupon_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/widgets/coupon/coupon_shimmer.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../utils/utility.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CouponScreen extends StatefulWidget {
  final List<SearchCouponModel>? products;
  CouponScreen({Key? key, this.products}) : super(key: key);

  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  TextEditingController couponController = new TextEditingController();
  int page = 1;
  bool isSearching = false;
  String? notes;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    await Provider.of<CouponProvider>(context, listen: false)
        .fetchCoupon(page: page);
  }

  newCheckCoupon(value) async {
    if (widget.products!.isNotEmpty) {
      setState(() {
        value.loadingUse = true;
      });
      await Provider.of<CouponProvider>(context, listen: false)
          .newUseCoupon(context,
              code: couponController.text, products: widget.products)
          .then((value) {
        setState(() {
          isSearching = true;
        });
      });
    } else {
      snackBar(context,
          message:
              "${AppLocalizations.of(context)!.translate("coupon_cart_empty")}");
    }
  }

  buildNoCoupon() {
    final image404 = Provider.of<HomeProvider>(context, listen: false).image404;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        image404.image == null
            ? Icon(
                Icons.not_interested,
                color: primaryColor,
                size: 75,
              )
            : CachedNetworkImage(
                imageUrl: image404.image!,
                height: MediaQuery.of(context).size.height * 0.4,
                placeholder: (context, url) => Container(),
                errorWidget: (context, url, error) => Icon(
                      Icons.not_interested,
                      color: primaryColor,
                      size: 75,
                    )),
        SizedBox(
          height: 10,
        ),
        Text(
          AppLocalizations.of(context)!.translate("dont_have_coupon")!,
          style: TextStyle(
              // color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<AppNotifier>(context).isDarkMode;
    final coupons = Provider.of<CouponProvider>(context, listen: false);
    Widget buildCoupons = Container(
      child: ListenableProvider.value(
        value: coupons,
        child: Consumer<CouponProvider>(builder: (context, value, child) {
          if (value.loading) {
            return CouponShimmer();
          }
          return ListView.separated(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemBuilder: (context, i) {
                return cardCoupons(value.coupons[i]);
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 15,
                );
              },
              itemCount: value.coupons.length);
        }),
      ),
    );

    Widget buildButtonUse = Container(
      child: ListenableProvider.value(
        value: coupons,
        child: Consumer<CouponProvider>(builder: (context, value, child) {
          print(value.loadingUse);
          if (value.loadingUse) {
            return TextButton(
              onPressed: null,
              style: TextButton.styleFrom(
                  padding: EdgeInsets.all(responsiveFont(7)),
                  backgroundColor: primaryColor),
              child: Container(
                height: 15.h,
                width: 15.w,
                child: customLoading(color: primaryColor),
              ),
            );
          }
          return TextButton(
            onPressed: couponController.text.isEmpty
                ? null
                : () {
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    newCheckCoupon(value);
                  },
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(responsiveFont(7)),
                backgroundColor:
                    couponController.text.isEmpty ? Colors.grey : primaryColor),
            child: Text(
              AppLocalizations.of(context)!.translate('use')!,
              style: TextStyle(color: Colors.white),
            ),
          );
        }),
      ),
    );

    Widget buildNotes = Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: ListenableProvider.value(
        value: coupons,
        child: Consumer<CouponProvider>(builder: (context, value, child) {
          if (value.couponUsed != null) {
            return Container(
              child: Text(
                value.couponUsed!.discountType != "percent"
                    ? '${AppLocalizations.of(context)!.translate('you_get')} ${stringToCurrency(double.parse(value.couponUsed!.discountAmount!.toString()), context)} ${AppLocalizations.of(context)!.translate('discount_after')}'
                    : '${AppLocalizations.of(context)!.translate('you_get')} ${value.couponUsed!.discountAmount!.toString().substring(0, 2)}% ${AppLocalizations.of(context)!.translate('discount_after')}',
                style: TextStyle(fontSize: responsiveFont(11)),
              ),
            );
          } else {
            return Container(
              child: Text(
                'Coupon code invalid.',
                style: TextStyle(fontSize: responsiveFont(11)),
              ),
            );
          }
        }),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            // color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.translate('coupon_code')!,
          style: TextStyle(
            fontSize: responsiveFont(16),
            fontWeight: FontWeight.w500,
            // color: Colors.black,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showBarModalBottomSheet(
                  context: context, builder: (context) => modalBottomSheet());
            },
            child: Container(
                margin: EdgeInsets.only(right: 10),
                width: 25.w,
                height: 25.h,
                child: Image.asset(
                  "images/cart/Faq.png",
                  color: isDarkMode ? Colors.white : null,
                )),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 15, right: 15, left: 15),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 30.h,
                    child: TextField(
                      controller: couponController,
                      style: TextStyle(fontSize: 14),
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        isCollapsed: true,
                        filled: true,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(5),
                          ),
                        ),
                        prefixIcon: Icon(Icons.search),
                        hintText: AppLocalizations.of(context)!
                            .translate('coupon_code'),
                        hintStyle: TextStyle(fontSize: responsiveFont(10)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                buildButtonUse
              ],
            ),
          ),
          Visibility(visible: isSearching, child: buildNotes),
          Container(
            width: double.infinity,
            height: 5,
            color: isDarkMode ? Colors.black12 : HexColor("DDDDDD"),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(15),
            child: Text(
              AppLocalizations.of(context)!.translate('coupon_available')!,
              style: TextStyle(
                  fontSize: responsiveFont(12), fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: !Session.data.getBool('isLogin')!
                ? Center(
                    child: buildNoAuth(context),
                  )
                : coupons.coupons.isNotEmpty
                    ? buildCoupons
                    : buildNoCoupon(),
          ),
          SizedBox(
            height: 10,
          ),
          coupons.coupons.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment
                            .bottomCenter, // 10% of the width, so there are ten blinds.
                        colors: <HexColor>[
                          secondaryColor as HexColor,
                          primaryColor as HexColor,
                        ], // red to yellow
                        tileMode: TileMode
                            .repeated, // repeats the gradient over the canvas
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('done')!,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget modalBottomSheet() {
    return Container(
        height: MediaQuery.of(context).size.height / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)!.translate('coupon_faq')!,
                    style: TextStyle(
                        fontSize: responsiveFont(14),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    AppLocalizations.of(context)!.translate('how_to_use')!,
                    style: TextStyle(
                        fontSize: responsiveFont(12),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    AppLocalizations.of(context)!.translate('sub_how_to_use')!,
                    style: TextStyle(
                      fontSize: responsiveFont(10),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    AppLocalizations.of(context)!.translate('how_to_get')!,
                    style: TextStyle(
                        fontSize: responsiveFont(12),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    AppLocalizations.of(context)!.translate('sub_how_to_get')!,
                    style: TextStyle(
                      fontSize: responsiveFont(10),
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment
                        .bottomCenter, // 10% of the width, so there are ten blinds.
                    colors: <HexColor>[
                      secondaryColor as HexColor,
                      primaryColor as HexColor,
                    ], // red to yellow
                    tileMode: TileMode
                        .repeated, // repeats the gradient over the canvas
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.translate('done')!,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ));
  }

  Widget cardCoupons(CouponModel couponModel) {
    bool _isValid = true;
    if (couponModel.dateExpires != null) {
      if (DateTime.parse(couponModel.dateExpires!).isBefore(DateTime.now()))
        _isValid = false;
    }
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Card(
                  child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        couponModel.discountType == "fixed_cart"
                            ? '${AppLocalizations.of(context)!.translate('you_will_get')} ${stringToCurrency(double.parse(couponModel.amount!), context)} ${AppLocalizations.of(context)!.translate('discount_by')}'
                            : couponModel.discountType == "percent"
                                ? '${AppLocalizations.of(context)!.translate('you_will_get')} ${couponModel.amount!.substring(0, 2)}% ${AppLocalizations.of(context)!.translate('discount_by')}'
                                : '${AppLocalizations.of(context)!.translate('you_will_get')} ${stringToCurrency(double.parse(couponModel.amount!), context)} ${AppLocalizations.of(context)!.translate('discount_each')}',
                        style: TextStyle(fontSize: responsiveFont(10)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5, bottom: 15),
                      child: Text(
                        couponModel.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: responsiveFont(8)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              _buildPopupDialog(context, couponModel),
                        );
                      },
                      child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            couponModel.dateExpires != null
                                ? "${AppLocalizations.of(context)!.translate('valid_until')} : ${convertDateFormatSlash(DateTime.parse(couponModel.dateExpires!))}"
                                : "${AppLocalizations.of(context)!.translate('valid_until')} : -",
                            style: TextStyle(
                                fontSize: responsiveFont(8),
                                color: primaryColor),
                          )),
                    )
                  ],
                ),
              )),
            ),
            Expanded(
              flex: 2,
              child: Card(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: secondaryColor,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.translate('get')!,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      Text(
                          couponModel.discountType == "percent"
                              ? '${couponModel.amount!.substring(0, 2)}%'
                              : stringToCurrency(
                                  double.parse(couponModel.amount!), context),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor:
                                _isValid ? primaryColor : Colors.grey,
                            padding: EdgeInsets.symmetric(horizontal: 30)),
                        onPressed: () {
                          if (_isValid) {
                            setState(() {
                              FlutterClipboard.copy(couponModel.code!).then(
                                  (value) => snackBar(context,
                                      message: AppLocalizations.of(context)!
                                          .translate('success_copied')!));
                            });
                          } else {
                            snackBar(context,
                                message: AppLocalizations.of(context)!
                                    .translate('failed_copied')!);
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.translate('copy')!,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPopupDialog(BuildContext context, CouponModel couponModel) {
    return new AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        insetPadding: EdgeInsets.all(0),
        content: Builder(
          builder: (context) {
            return Container(
              height: 215.h,
              width: 330.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        AppLocalizations.of(context)!
                            .translate('terms_condition')!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: responsiveFont(14),
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('coupon_value')!,
                              style: TextStyle(
                                  fontSize: responsiveFont(12),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              "${stringToCurrency(double.parse(couponModel.amount!), context)} discount.",
                              style: TextStyle(
                                fontSize: responsiveFont(10),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('duration_of_use')!,
                              style: TextStyle(
                                  fontSize: responsiveFont(12),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              couponModel.dateExpires != null
                                  ? "${AppLocalizations.of(context)!.translate('valid_until')} : ${convertDateFormatSlash(DateTime.parse(couponModel.dateExpires!))}"
                                  : "${AppLocalizations.of(context)!.translate('valid_until')} : -",
                              style: TextStyle(
                                fontSize: responsiveFont(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment
                              .bottomCenter, // 10% of the width, so there are ten blinds.
                          colors: <HexColor>[
                            secondaryColor as HexColor,
                            primaryColor as HexColor,
                          ], // red to yellow
                          tileMode: TileMode
                              .repeated, // repeats the gradient over the canvas
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate('done')!,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
