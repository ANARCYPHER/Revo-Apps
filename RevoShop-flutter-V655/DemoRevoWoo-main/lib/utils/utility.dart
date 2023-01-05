import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'dart:developer';

import 'package:nyoba/pages/auth/login_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/widgets/home/card_item_shimmer.dart';
import 'package:nyoba/widgets/product/product_detail_modal.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../app_localizations.dart';

Color primaryColor = HexColor("ED1D1D");
Color secondaryColor = HexColor("960000");
Color buttonColor = HexColor("");
Color textButtonColor = HexColor("");

double responsiveFont(double designFont) {
  return ScreenUtil().setSp(designFont + 2);
}

Widget customLoading({Color? color}) {
  return LoadingFlipping.circle(
    borderColor: color != null ? color : secondaryColor,
    borderSize: 3.0,
    size: 30.0,
    duration: Duration(milliseconds: 500),
  );
}

Widget customLoadingShimmer({Color? color}) {
  return Shimmer.fromColors(
      child: Container(
        height: 30,
        width: 30,
      ),
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!);
}

printLog(String message, {String? name}) {
  return log(message, name: name ?? 'log');
}

convertDateFormatShortMonth(date) {
  String dateTime = DateFormat("dd MMMM yyyy").format(date);
  return dateTime;
}

convertDateFormatSlash(date) {
  String dateTime = DateFormat("dd/MM/yyyy").format(date);
  return dateTime;
}

convertDateFormatFull(date) {
  String dateTime = DateFormat("dd MMMM yyyy").format(date);
  return dateTime;
}

convertDateFormatDash(date) {
  String dateTime = DateFormat("dd-MM-yyyy").format(date);
  return dateTime;
}

snackBar(context,
    {required String message,
    Color? color,
    int duration = 2,
    SnackBarBehavior? behavior}) {
  final snackBar = SnackBar(
    content: Text(message),
    behavior: behavior,
    backgroundColor: color != null ? color : null,
    duration: Duration(seconds: duration),
  );
  return ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

String? alertPhone(context) {
  return AppLocalizations.of(context)!.translate('hint_otp');
}

loadingPop(context) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
          content: Container(
              height: MediaQuery.of(context).size.height * 0.05,
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  customLoading(),
                  SizedBox(width: 10),
                  Text("Loading...")
                ],
              )));
    },
    barrierDismissible: false,
  );
}

buildNoConnection(context) {
  return Container(
    child: Text("No internet Connection."),
  );
}

buildNoAuth(context) {
  final imageNoLogin =
      Provider.of<HomeProvider>(context, listen: false).imageNoLogin;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      imageNoLogin.image == null
          ? Icon(
              Icons.not_interested,
              color: primaryColor,
              size: 75,
            )
          : CachedNetworkImage(
              imageUrl: imageNoLogin.image!,
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
        AppLocalizations.of(context)!.translate("pls_login_first")!,
        style: TextStyle(
          // color: Colors.black,
          fontWeight: FontWeight.w500, fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 10,
      ),
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primaryColor, secondaryColor])),
        height: 30.h,
        width: MediaQuery.of(context).size.width * 0.5,
        child: TextButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Login()));
          },
          child: Text(
            AppLocalizations.of(context)!.translate("login")!,
            style: TextStyle(
                color: Colors.white,
                fontSize: responsiveFont(10),
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    ],
  );
}

convertHtmlUnescape(String textCharacter) {
  var unescape = HtmlUnescape();
  var text = unescape.convert(textCharacter);
  return text;
}

Widget shimmerProductItemSmall() {
  return ListView.separated(
    itemCount: 6,
    scrollDirection: Axis.horizontal,
    itemBuilder: (context, i) {
      return CardItemShimmer(
        i: i,
        itemCount: 6,
      );
    },
    separatorBuilder: (BuildContext context, int index) {
      return SizedBox(
        width: 5,
      );
    },
  );
}

Widget shimmerMiniBanner() {
  return Shimmer.fromColors(
    highlightColor: primaryColor,
    baseColor: secondaryColor,
    child: Container(
      width: double.infinity,
      height: double.infinity,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    ),
  );
}

Widget buildSearchEmpty(context, text) {
  final searchEmpty =
      Provider.of<HomeProvider>(context, listen: false).imageSearchEmpty;
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        searchEmpty.image == null
            ? Icon(
                Icons.search,
                color: primaryColor,
                size: 75,
              )
            : CachedNetworkImage(
                imageUrl: searchEmpty.image!,
                height: MediaQuery.of(context).size.height * 0.4,
                placeholder: (context, url) => Container(),
                errorWidget: (context, url, error) => Icon(
                      Icons.search,
                      color: primaryColor,
                      size: 75,
                    )),
        Container(
          alignment: Alignment.topCenter,
          child: Text(
            text,
            style: TextStyle(fontSize: 18),
          ),
        )
      ],
    ),
  );
}

buildButtonCart(context, product) {
  final loadCount =
      Provider.of<OrderProvider>(context, listen: false).loadCartCount;
  return GestureDetector(
    onTap: () {
      if (product!.stockStatus != 'outofstock' && product!.productStock! >= 1) {
        showMaterialModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          builder: (context) => ProductDetailModal(
              productModel: product, type: "add", loadCount: loadCount),
        );
      } else {
        snackBar(context,
            message:
                AppLocalizations.of(context)!.translate('product_out_stock')!);
      }
    },
    child: Icon(
      Icons.add_shopping_cart,
      color: secondaryColor,
      size: 20.h,
    ),
  );
}

buildError(context) {
  return Container(
    padding: EdgeInsets.all(15),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_outlined,
          size: 64,
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          child: Text(
            "${AppLocalizations.of(context)!.translate('opps')}!",
            style: TextStyle(fontSize: responsiveFont(24)),
          ),
        ),
        Container(
          child: Text(
            "${AppLocalizations.of(context)!.translate('something_went_wrong')}.",
            style: TextStyle(fontSize: responsiveFont(18)),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        MaterialButton(
          padding: EdgeInsets.all(10),
          onPressed: () {
            Phoenix.rebirth(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.refresh),
              Text(
                "${AppLocalizations.of(context)!.translate('refresh_app')}.",
              )
            ],
          ),
        )
      ],
    ),
  );
}
