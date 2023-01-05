import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/models/cart_model.dart';
import 'package:nyoba/models/checkout_data_model.dart';
import 'package:nyoba/models/checkout_guest_model.dart';
import 'package:nyoba/models/coupon_model.dart';
import 'package:nyoba/models/customer_data_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/account/account_address_edit_screen.dart';
import 'package:nyoba/pages/account/account_address_screen.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/pages/order/coupon_screen.dart';
import 'package:nyoba/pages/order/my_order_screen.dart';
import 'package:nyoba/pages/order/order_success_screen.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/checkout_provider.dart';
import 'package:nyoba/provider/coupon_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:nyoba/provider/wallet_provider.dart';
import 'package:nyoba/services/order_api.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/webview/checkout_webview.dart';
import 'package:nyoba/widgets/webview/webview.dart';
import 'package:provider/provider.dart';
import 'package:uiblock/uiblock.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CheckOutNative extends StatefulWidget {
  final List<CartProductItem>? line;
  final bool? fromBuyNow;
  final bool? fromLive;
  const CheckOutNative(
      {Key? key, this.fromBuyNow, this.line, this.fromLive = false})
      : super(key: key);

  @override
  State<CheckOutNative> createState() => _CheckOutNativeState();
}

class _CheckOutNativeState extends State<CheckOutNative> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool shouldPop = false;
  CheckoutProvider? checkoutProvider;
  UserProvider? userProvider;
  TextEditingController noteController = new TextEditingController();
  late StreamSubscription subscription;
  var isDeviceConnected = false;
  bool isAlertSet = false;
  String textLoading = "";
  String shipping = "";
  String payment = "";
  bool chooseShipping = false;
  bool choosePayment = false;
  int? chosenPayment;
  int? chosenShipping;
  String coupon = "";
  double couponMount = 0;
  double shipCost = 0;
  AppNotifier? appNotifier;

  @override
  void initState() {
    super.initState();
    appNotifier = Provider.of<AppNotifier>(context, listen: false);
    checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<CheckoutProvider>().getConectivity();
      context.read<CheckoutProvider>().reset();
    });
    // if (Provider.of<HomeProvider>(context, listen: false).syncCart) {
    printLog(json.encode(widget.line), name: "line item check");
    loadData();
    // }
    loadCart();
    for (int i = 0; i < widget.line!.length; i++) {
      qtyTotal += widget.line![i].quantity!;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  int qtyTotal = 0;
  List<String> listData = [];
  List<SearchCouponModel> products = [];
  List<Map<String, dynamic>> coupons = [];

  Future<void> getProductCart() async {
    products.clear();
    if (checkoutProvider!.lineItems != null) {
      for (int i = 0; i < checkoutProvider!.lineItems.length; i++) {
        products.add(SearchCouponModel(
            id: checkoutProvider!.lineItems[i].productId,
            quantity: checkoutProvider!.lineItems[i].qty,
            variationId: checkoutProvider!.lineItems[i].variantId));
      }
    }
  }

  bool payWithWallet = false;
  bool isWallet = false;
  double wallet = 0;
  double total = 0;
  bool payWithPoint = false;

  loadData() async {
    coupons.clear();
    setState(() {
      if (Provider.of<CouponProvider>(context, listen: false).couponUsed !=
          null) {
        coupon = Provider.of<CouponProvider>(context, listen: false)
            .couponUsed!
            .code!;
        coupons.add({"code": coupon});
        couponMount = double.parse(
            Provider.of<CouponProvider>(context, listen: false)
                .couponUsed!
                .discountAmount
                .toString());
      }
    });
    String countryId = Session.data.getString("country_id") ?? "";
    String stateId = Session.data.getString("state_id") ?? "";
    String postcode = Session.data.getString("postcode") ?? "";
    String city = Session.data.getString("city") ?? "";
    String subdistrict = Session.data.getString("subdistrict") ?? "";
    await Provider.of<CheckoutProvider>(context, listen: false)
        .getCheckoutData(
            line: widget.line,
            countryId: countryId,
            postcode: postcode,
            stateId: stateId,
            city: city,
            subdistrict: subdistrict)
        .then((value) {
      getProductCart();
      Provider.of<CheckoutProvider>(context, listen: false)
          .calculateTotal(
        ship: shipCost,
        disc: couponMount,
        wallet: wallet,
        isWallet: payWithWallet,
      )
          .then((value) {
        wallet = double.parse(
            Provider.of<WalletProvider>(context, listen: false).walletBalance!);
        total =
            Provider.of<CheckoutProvider>(context, listen: false).grandTotal!;
        if (wallet >= total) {
          isWallet = true;
        } else if (wallet == 0) {
          isWallet = true;
        }
        if (!Session.data.getBool("isLogin")!) {
          isWallet = true;
        }
        context.read<CheckoutProvider>().checkPoin(coupon: couponMount);
        printLog(wallet.toString(), name: "wallet");
      });
    });
    printLog(isWallet.toString(), name: "wallet");
    printLog("ship : ${json.encode(checkoutProvider!.shiped)}");
    printLog("payment : ${json.encode(checkoutProvider!.payment)}");
  }

  List<ProductModel> productCart = [];
  List<CartProductItem> lineCreate = [];
  List<String> billing = [];

  Future<bool> back() async {
    printLog("length cart : ${productCart.length}");
    lineCreate.clear();
    for (int i = 0; i < productCart.length; i++) {
      lineCreate.add(new CartProductItem(
          productId: productCart[i].id,
          quantity: productCart[i].cartQuantity,
          variationId: productCart[i].variantId,
          variation: productCart[i].selectedVariation));
    }
    if (!Session.data.getBool("isLogin")!) {
      Session.data.setString("country_id", "");
      Session.data.setString("state_id", "");
      Session.data.setString("postcode", "");
    }
    printLog("line create : ${json.encode(widget.line)} ");
    if (Session.data.containsKey('product_buy_now')) {
      Session.data.remove('product_buy_now');
    }
    if (widget.line!.length == lineCreate.length) {
      return true;
    }
    if (Provider.of<HomeProvider>(context, listen: false).syncCart) {
      await Provider.of<CheckoutProvider>(context, listen: false)
          .deleteCart(line: widget.line!)
          .then((value) {
        printLog("masuk - ${value}");
        checkoutProvider!.createCart(line: lineCreate).then((value) {
          // checkoutProvider!.reset();
          return true;
        });
        if (value) {}
      });
    }

    return false;
  }

  Future<bool> loadCart() async {
    if (Session.data.containsKey('cart')) {
      List? listCart = await json.decode(Session.data.getString('cart')!);

      setState(() {
        productCart = listCart!
            .map((product) => new ProductModel.fromJson(product))
            .toList();
      });
      if (productCart.isNotEmpty) {
        context
            .read<OrderProvider>()
            .fetchProductCart(productCart)
            .then((value) {
          setState(() {
            productCart = value;
          });
        });
      }
      return true;
    }
    return false;
  }

  Future removeOrderedItems() async {
    printLog("LINE : ${json.encode(widget.line)} \n ");
    for (int i = 0; i < widget.line!.length; i++) {
      if (widget.line![i].variationId == null) {
        productCart
            .removeWhere((element) => element.id == widget.line![i].productId);
      } else {
        productCart.removeWhere(
            (element) => element.variantId == widget.line![i].variationId);
      }
    }
    printLog("cart : ${json.encode(productCart)}");
    List<CartProductItem>? line = [];
    for (int i = 0; i < productCart.length; i++) {
      if (!productCart[i].isSelected!) {
        line.add(new CartProductItem(
            productId: productCart[i].id,
            quantity: productCart[i].cartQuantity,
            variationId: productCart[i].variantId == 0
                ? null
                : productCart[i].variantId));
      }
    }
    printLog("line : ${json.encode(line)}");
    if (Provider.of<HomeProvider>(context, listen: false).syncCart) {
      OrderAPI().addCart(action: "create", line: line);
    }
    saveData();
    await Provider.of<CouponProvider>(context, listen: false).clearCoupon();
    // await Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => OrderSuccess()));
  }

  saveData() async {
    await Session.data.setString('cart', json.encode(productCart));
    printLog(productCart.toString(), name: "Cart Product");
    Provider.of<OrderProvider>(context, listen: false)
        .loadCartCount()
        .then((value) => setState(() {}));
  }

  Future<bool> saveOrderGuest(dynamic value) async {
    if (!Session.data.getBool('isLogin')!) {
      List<CheckoutGuest> listOrder = [];

      if (Session.data.containsKey('order_guest')) {
        List orders = json.decode(Session.data.getString('order_guest')!);

        listOrder =
            orders.map((order) => new CheckoutGuest.fromJson(order)).toList();
      }
      String urlRequest = url +
          "/checkout/order-received/" +
          value['id'].toString() +
          "/?key=" +
          value['order_key'].toString();
      listOrder.add(new CheckoutGuest(
          url: urlRequest,
          createdAt: DateTime.now().toString(),
          orderId: value['id']));
      Session.data.setString('order_guest', json.encode(listOrder));
      printLog("MASUK SINI OI : ${Session.data.getString('order_guest')}");
      return true;
    }
    return false;
  }

  _launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      snackBar(context, color: Colors.red, message: 'Could not launch $url');
      throw 'Could not launch $url';
    }
  }

  placeOrder() async {
    if (checkoutProvider!.shiped == null) {
      UIBlock.unblock(context);
      return snackBar(context,
          message:
              AppLocalizations.of(context)!.translate('pls_select_shipping')!);
    }
    if (checkoutProvider!.titleCourier == "Choose Courier Services" &&
        checkoutProvider!.shipping == "other_courier") {
      UIBlock.unblock(context);
      return snackBar(context,
          message:
              AppLocalizations.of(context)!.translate('pls_select_shipping')!);
    }
    if (checkoutProvider!.payment == null) {
      UIBlock.unblock(context);
      return snackBar(context,
          message:
              AppLocalizations.of(context)!.translate('pls_select_payment')!);
    }
    if (checkoutProvider!.user == null) {
      UIBlock.unblock(context);
      return snackBar(context,
          message:
              AppLocalizations.of(context)!.translate('pls_enter_shipping')!);
    }
    UserData? userBilling;

    if (!Session.data.getBool('isLogin')!) {
      userBilling = new UserData(
          firstName: billing[0],
          lastName: billing[1],
          company: billing[2],
          country: billing[11],
          countryName: billing[3],
          address1: billing[6],
          address2: billing[7],
          city: billing[5],
          state: billing[12],
          stateName: billing[4],
          postcode: billing[8],
          phone: billing[9],
          email: billing[10]);
      Session.data.setString("country_id", "");
      Session.data.setString("state_id", "");
      Session.data.setString("postcode", "");
    }
    await Provider.of<CheckoutProvider>(context, listen: false)
        .placeOrder(
            line: widget.line,
            bill: Session.data.getBool('isLogin')!
                ? checkoutProvider!.user!
                : userBilling!,
            ship: checkoutProvider!.shiped,
            pay: checkoutProvider!.payment,
            coupon: coupons,
            note: noteController.text,
            partialPayment: payWithWallet)
        .then((value) {
      printLog("value place: ${json.encode(value)}");
      if (value.toString().contains("error")) {
        UIBlock.unblock(context);
        return snackBar(context,
            message: AppLocalizations.of(context)!
                .translate('invalid_billing_addr')!);
      } else if (!value.toString().contains("error")) {
        checkoutProvider!.reset();
        Session.data.setString('order_number', value['id'].toString());
        printLog(Session.data.getString('order_number')!,
            name: "ORDER NUMBER CHECKOUT NATIVE");
        loadCart().then((data) {
          if (data) {
            removeOrderedItems();
          }
        });
        if (value['payment_link'] != "") {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutWebView(
                  // fromPlaceOrder: true,
                  url: value['payment_link'],
                ),
              ));
          // s_launchUrl(value['payment_link']);
        } else if (value['payment_link'] == "") {
          if (Session.data.getBool('isLogin')!) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderSuccess(),
                ));
          } else {
            saveOrderGuest(value).then((value) {
              if (value) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderSuccess(),
                    ));
              }
            });
          }
        }
      } else if (!value) {
        return snackBar(context,
            message:
                AppLocalizations.of(context)!.translate('failed_place_order')!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final grandTotal = Provider.of<CheckoutProvider>(
      context,
    ).grandTotal;
    Widget buildBody = Container(
      child: ListenableProvider.value(
        value: checkoutProvider!,
        child: Consumer<CheckoutProvider>(builder: (context, value, child) {
          if (value.loading) {
            return customLoading();
          }
          return buildAddress(value.user!);
        }),
      ),
    );

    return WillPopScope(
      onWillPop: () => back().then((value) async {
        if (widget.fromLive!) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => HomeScreen()),
              (Route<dynamic> route) => false);
        } else if (!widget.fromLive!) {
          Navigator.pop(context);
        }
        return true;
      }),
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.translate("checkout")!,
              style: TextStyle(
                fontSize: responsiveFont(16),
                fontWeight: FontWeight.w500,
                // color: Colors.black,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                back().then((value) {
                  // Provider.of<CheckoutProvider>(context, listen: false).reset();
                  if (widget.fromLive!) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => HomeScreen()),
                        (Route<dynamic> route) => false);
                  } else {
                    Navigator.pop(context);
                  }
                });
              },
              icon: Icon(
                Icons.arrow_back,
                color: appNotifier!.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Consumer<CheckoutProvider>(
                  builder: (context, value, child) {
                    return value.loading
                        ? Container(
                            height: MediaQuery.of(context).size.height,
                            child: Center(child: customLoading()))
                        : Column(children: [
                            Expanded(
                              child: ListView(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Column(
                                          //crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            buildShipedTo(),
                                            Divider(
                                                color: HexColor("#d5d5d5"),
                                                thickness: 1),
                                            buildBody,
                                            SizedBox(
                                              height: 10,
                                            )
                                          ]),
                                    ),
                                    ListenableProvider.value(
                                      value: checkoutProvider,
                                      child: Consumer<CheckoutProvider>(
                                        builder: (context, value, child) {
                                          return Container(
                                            margin: EdgeInsets.only(top: 10),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            color: appNotifier!.isDarkMode
                                                ? null
                                                : HexColor("#fafafa"),
                                            child: Column(children: [
                                              listProduct(),
                                            ]),
                                          );
                                        },
                                      ),
                                    ),
                                    buildNote(),
                                    buildButton(
                                        title:
                                            "${AppLocalizations.of(context)!.translate("coupon_code")!} ${coupon == "" ? "" : ": $coupon"}",
                                        image: "coupon",
                                        finalTitle: ""),
                                    buildButton(
                                        title: AppLocalizations.of(context)!
                                            .translate('shipping_method')!,
                                        image: "truck",
                                        finalTitle: ""),
                                    Visibility(
                                        visible: value.listCourier!.isNotEmpty,
                                        child: buildButtonCourier()),
                                    buildButton(
                                        title: AppLocalizations.of(context)!
                                            .translate('payment_method')!,
                                        image: "card",
                                        finalTitle: ""),
                                    Visibility(
                                      visible:
                                          Session.data.getBool('isLogin')! &&
                                              (grandTotal! > wallet) &&
                                              wallet != 0,
                                      child: Row(children: [
                                        Checkbox(
                                          value: payWithWallet,
                                          activeColor: primaryColor,
                                          onChanged: (value) {
                                            Provider.of<CheckoutProvider>(
                                                    context,
                                                    listen: false)
                                                .calculateTotal(
                                              ship: shipCost,
                                              disc: couponMount,
                                              wallet: wallet,
                                              isWallet: value,
                                            );
                                            setState(() {
                                              payWithWallet = value!;
                                            });
                                          },
                                        ),
                                        Text(
                                          'Pay by Wallet (Balance ${stringToCurrency(wallet, context)})',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ]),
                                    ),
                                    Visibility(
                                      visible: Session.data
                                              .getBool('isLogin')! &&
                                          value.pointsRedemption!.point != 0,
                                      child: Row(children: [
                                        Checkbox(
                                          value: payWithPoint,
                                          activeColor: primaryColor,
                                          onChanged: (val) {
                                            Provider.of<CheckoutProvider>(
                                                    context,
                                                    listen: false)
                                                .calculateTotal(
                                                    ship: shipCost,
                                                    disc: couponMount,
                                                    wallet: wallet,
                                                    isWallet: payWithWallet,
                                                    point: value
                                                        .pointsRedemption!
                                                        .totalDisc,
                                                    isPoint: val);

                                            if (!payWithPoint) {
                                              coupons.add({
                                                "code": value.pointsRedemption!
                                                    .discCoupon
                                              });
                                            } else if (payWithPoint) {
                                              coupons.removeWhere((item) =>
                                                  item['code'] ==
                                                  "${value.pointsRedemption!.discCoupon}");
                                            }
                                            printLog(json.encode(coupons));
                                            setState(() {
                                              payWithPoint = val!;
                                            });
                                          },
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: Text(
                                            'Use ${value.pointsRedemption!.point} Points for a ${stringToCurrency(value.pointsRedemption!.totalDisc!, context)} discount on this order!',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700),
                                            softWrap: true,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ]),
                                    ),
                                    buildSummary(),
                                  ]),
                            ),
                            buildBottomBarCart()
                          ]);
                  },
                ),
              ),
            ],
          )),
    );
  }

  buildBottomBarCart() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 1,
          color: HexColor("DDDDDD"),
        ),
        Consumer<CheckoutProvider>(
          builder: (context, value, child) {
            return Material(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${AppLocalizations.of(context)!.translate('total')}  ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${stringToCurrency(value.newTotal!, context)}',
                            style: TextStyle(
                                color: appNotifier!.isDarkMode
                                    ? null
                                    : HexColor("#6e6e6e")),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          UIBlock.block(
                            context,
                            backgroundColor: Colors.black54,
                            customLoaderChild:
                                LoadingAnimationWidget.staggeredDotsWave(
                                    color: primaryColor, size: 80),
                            childBuilder: (BuildContext context) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LoadingAnimationWidget.staggeredDotsWave(
                                          color: primaryColor, size: 80),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .translate('place_order_text')!,
                                        // "Mohon menunggu sebentar.\n\nSaat ini sistem sedang\nmemproses transaksi Anda.\n\nJangan menutup aplikasi\nsampai transaksi selesai.",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Visibility(
                                        visible: value.isAlertSet,
                                        child: GestureDetector(
                                          onTap: () {
                                            value.setAlert();
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => MyOrder(
                                                      // fromNative: true,
                                                      ),
                                                ));
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: primaryColor),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('check_order')!,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                          placeOrder();
                        },
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.all(15),
                            backgroundColor: primaryColor),
                        child: Text(
                          AppLocalizations.of(context)!
                              .translate('place_order')!,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ));
          },
        )
      ],
    );
  }

  Widget buildSummary() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: EdgeInsets.only(right: 10),
      child: Consumer<CheckoutProvider>(
        builder: (context, value, child) {
          return value.loading
              ? customLoading()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('summary')!,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.translate('total_price')!} ($qtyTotal ${AppLocalizations.of(context)!.translate('items')!})",
                          style: TextStyle(
                              color: appNotifier!.isDarkMode
                                  ? null
                                  : HexColor("#6e6e6e")),
                        ),
                        Spacer(),
                        Text(
                          "${stringToCurrency(value.total!, context)}",
                          style: TextStyle(
                              color: appNotifier!.isDarkMode
                                  ? null
                                  : HexColor("#6e6e6e")),
                        )
                      ],
                    ),
                    Visibility(
                      visible: chooseShipping,
                      child: Row(
                        children: [
                          Container(
                            width: 240,
                            child: Text(
                              "${AppLocalizations.of(context)!.translate('total_shipping')!} (${value.shipping})",
                              style: TextStyle(
                                  color: appNotifier!.isDarkMode
                                      ? null
                                      : HexColor("#6e6e6e")),
                              maxLines: 2,
                            ),
                          ),
                          Spacer(),
                          Text(
                            "${value.shippingCost}",
                            style: TextStyle(
                                color: appNotifier!.isDarkMode
                                    ? null
                                    : HexColor("#6e6e6e")),
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: coupon != "",
                      child: Row(
                        children: [
                          Text(
                            "${AppLocalizations.of(context)!.translate('total_disc')!} ($coupon)",
                            style: TextStyle(
                                color: appNotifier!.isDarkMode
                                    ? null
                                    : HexColor("#6e6e6e")),
                          ),
                          Spacer(),
                          Text(
                            "-${stringToCurrency(couponMount, context)}",
                            style: TextStyle(
                                color: appNotifier!.isDarkMode
                                    ? null
                                    : Colors.red),
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: payWithWallet,
                      child: Row(
                        children: [
                          Text(
                            "Via Wallet",
                            style: TextStyle(
                                color: appNotifier!.isDarkMode
                                    ? null
                                    : HexColor("#6e6e6e")),
                          ),
                          Spacer(),
                          Text(
                            "-${stringToCurrency(wallet, context)}",
                            style: TextStyle(
                                color: appNotifier!.isDarkMode
                                    ? null
                                    : Colors.red),
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: payWithPoint,
                      child: Row(
                        children: [
                          Text(
                            "Point Redemption",
                            style: TextStyle(
                                color: appNotifier!.isDarkMode
                                    ? null
                                    : HexColor("#6e6e6e")),
                          ),
                          Spacer(),
                          Text(
                            "-${stringToCurrency(value.pointsRedemption!.totalDisc!, context)}",
                            style: TextStyle(
                                color: appNotifier!.isDarkMode
                                    ? null
                                    : Colors.red),
                          )
                        ],
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  //No 1 of button courier
  buildButtonCourier() {
    return Consumer<CheckoutProvider>(
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () {
            showMaterialModalBottomSheet(
              context: context,
              enableDrag: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              builder: (context) => buildBottomSheetCourier(
                  count: value.listCourier!.length,
                  list: value.listCourier!,
                  idx: 4),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: HexColor("#d5d5d5"))),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    "images/order/truck.png",
                    width: 25,
                    height: 25,
                    color: primaryColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 230,
                    child: value.titleCourier != "Choose Courier Services"
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${value.titleCourier!} (${stringToCurrency(double.parse(value.courierCost!), context)})",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: appNotifier!.isDarkMode
                                          ? null
                                          : HexColor("#6e6e6e"))),
                              Text(
                                  "Estimasi : ${value.courierEtd == "" ? "-" : value.courierEtd}",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: appNotifier!.isDarkMode
                                          ? null
                                          : HexColor("#6e6e6e")))
                            ],
                          )
                        : Text("${value.titleCourier!}",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: appNotifier!.isDarkMode
                                    ? null
                                    : HexColor("#6e6e6e"))),
                  ),
                  Spacer(),
                  value.titleCourier != "Choose Courier Services"
                      ? Icon(Icons.check)
                      : Icon(Icons.arrow_right)
                ]),
          ),
        );
      },
    );
  }

  //No 2 of button courier
  buildBottomSheetCourier({int? count, List<Couriers>? list, int? idx}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: count! < 8
          ? (100 + (100 * count)).toDouble()
          : MediaQuery.of(context).size.height - 80,
      child: ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    color: appNotifier!.isDarkMode ? null : HexColor("#a4a4a4"),
                  )),
              Text(
                "${AppLocalizations.of(context)!.translate('select')!} Courier",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color:
                        appNotifier!.isDarkMode ? null : HexColor("#6e6e6e")),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: list!.length,
                itemBuilder: (context, index) {
                  return buildButtonSheetCourier(
                      title: list[index].methodTitle, index: index, idx: idx);
                },
              ),
            ],
          ),
        )
      ]),
    );
  }

  //No 3 of button courier
  Widget buildButtonSheetCourier({String? title, int? index, int? idx}) {
    return Consumer<CheckoutProvider>(
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () {
            context.read<CheckoutProvider>().setCourier(index, context);
            setState(() {
              shipCost = value.listCourier![index!].cost!.toDouble();
              chooseShipping = true;
              Provider.of<CheckoutProvider>(context, listen: false)
                  .calculateTotal(
                ship: shipCost,
                disc: couponMount,
                wallet: wallet,
                isWallet: payWithWallet,
              )
                  .then((value) {
                wallet = double.parse(
                    Provider.of<WalletProvider>(context, listen: false)
                        .walletBalance!);
                total = Provider.of<CheckoutProvider>(context, listen: false)
                    .grandTotal!;
                if (wallet >= total) {
                  setState(() {
                    isWallet = true;
                  });
                } else if (wallet == 0) {
                  setState(() {
                    isWallet = true;
                  });
                } else if (wallet < total) {
                  setState(() {
                    isWallet = false;
                  });
                }
                printLog("${isWallet.toString()} - ${wallet} - $total",
                    name: "wallet");
              });
            });
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            margin: EdgeInsets.symmetric(vertical: 5),
            height: 60,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: index == value.indexCourier
                    ? primaryColor
                    : appNotifier!.isDarkMode
                        ? null
                        : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: HexColor("#a4a4a4"))),
            child: Row(children: [
              Container(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "$title (${stringToCurrency(double.parse(value.listCourier![index!].cost!.toString()), context)})",
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: index == value.indexCourier
                                ? Colors.white
                                : appNotifier!.isDarkMode
                                    ? null
                                    : HexColor("#6e6e6e"))),
                    Text(
                        "Estimasi : ${value.listCourier![index].etd == "" ? "-" : value.listCourier![index].etd}",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: index == value.indexCourier
                                ? Colors.white
                                : appNotifier!.isDarkMode
                                    ? null
                                    : HexColor("#6e6e6e")))
                  ],
                ),
              ),
              Spacer(),
              Icon(Icons.arrow_right)
            ]),
          ),
        );
      },
    );
  }

  //No 2 of button coupon, shipping, payment
  buildBottomSheet({String? title, int? count, List<String>? list, int? idx}) {
    final temp = title!.split(" ");
    String tempTitle = temp[0];
    return Container(
      width: MediaQuery.of(context).size.width,
      height: (100 + (100 * count!)).toDouble(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.close,
              color: appNotifier!.isDarkMode ? null : HexColor("#a4a4a4"),
            )),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${AppLocalizations.of(context)!.translate('select')!} $title",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color:
                        appNotifier!.isDarkMode ? null : HexColor("#6e6e6e")),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: list!.length,
                itemBuilder: (context, index) {
                  return buildButtonSheet(
                      title: list[index],
                      method: tempTitle,
                      index: index,
                      idx: idx);
                },
              ),
            ],
          ),
        )
      ]),
    );
  }

  //No 3 of button coupon, shipping, payment
  Widget buildButtonSheet(
      {String? title, String? method, int? index, int? idx}) {
    final grandTotal = Provider.of<CheckoutProvider>(context).grandTotal;
    return Consumer<CheckoutProvider>(
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () {
            print(index);
            if (idx == 2) {
              setState(() {
                payment = title!;
                choosePayment = true;
                chosenPayment = index!;
                printLog(isWallet.toString(), name: "wallet");
                value.setPayment(index, isWallet);
              });
            } else if (idx == 1) {
              printLog("Masuk");
              setState(() {
                shipping = title!;
                chosenShipping = index!;
                if (value.shippingLines[index].methodTitle != "other_courier") {
                  chooseShipping = true;
                }
                if (value.shippingLines[index].methodTitle == "other_courier") {
                  chooseShipping = false;
                }
                Provider.of<CheckoutProvider>(context, listen: false)
                    .insertCourier(value.shippingLines[index].couriers);
                value.setShipping(index, context);
                shipCost = value.shippingLines[index].cost!.toDouble();

                Provider.of<CheckoutProvider>(context, listen: false)
                    .calculateTotal(
                  ship: shipCost,
                  disc: couponMount,
                  wallet: wallet,
                  isWallet: payWithWallet,
                )
                    .then((value) {
                  wallet = double.parse(
                      Provider.of<WalletProvider>(context, listen: false)
                          .walletBalance!);
                  total = Provider.of<CheckoutProvider>(context, listen: false)
                      .grandTotal!;
                  if (wallet >= total) {
                    setState(() {
                      isWallet = true;
                    });
                  } else if (wallet == 0) {
                    setState(() {
                      isWallet = true;
                    });
                  } else if (wallet < total) {
                    setState(() {
                      isWallet = false;
                    });
                  }
                  printLog("${isWallet.toString()} - ${wallet} - $total",
                      name: "wallet");
                });
              });
            }
            print("payment : $payment - shipping : $shipping");
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            margin: EdgeInsets.symmetric(vertical: 5),
            height: 60,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: idx == 2
                    ? index == value.indexPayment
                        ? primaryColor
                        : appNotifier!.isDarkMode
                            ? null
                            : Colors.white
                    : index == value.indexShipping
                        ? primaryColor
                        : appNotifier!.isDarkMode
                            ? null
                            : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: HexColor("#a4a4a4"))),
            child: Row(children: [
              Container(
                width: 200,
                child: Text("$title",
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: idx == 2
                            ? index == value.indexPayment
                                ? Colors.white
                                : appNotifier!.isDarkMode
                                    ? null
                                    : HexColor("#6e6e6e")
                            : index == value.indexShipping
                                ? Colors.white
                                : appNotifier!.isDarkMode
                                    ? null
                                    : HexColor("#6e6e6e"))),
              ),
              Spacer(),
              Icon(Icons.arrow_right)
            ]),
          ),
        );
      },
    );
  }

  //NO 1 of button coupon, shipping, payment
  Widget buildButton({String? title, String? image, String? finalTitle}) {
    final grandTotal = Provider.of<CheckoutProvider>(context).grandTotal;
    return Consumer<CheckoutProvider>(
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () {
            listData.clear();
            int idx = 1;
            if (value.user!.firstName != null &&
                Session.data.getBool('isLogin')!) {
              //USER LOGIN
              if (image != "coupon") {
                if (image == "truck") {
                  setState(() {
                    idx = 1;
                    printLog(
                        checkoutProvider!.shippingLines.length.toString() + "-",
                        name: "shipping");
                  });
                  if (checkoutProvider!.shippingLines.isEmpty) {
                    printLog("masuk");
                    return snackBar(context,
                        message: AppLocalizations.of(context)!
                            .translate("alert_shipping_null")!);
                  }
                  for (int i = 0;
                      i < checkoutProvider!.shippingLines.length;
                      i++) {
                    if (checkoutProvider!.shippingLines[i].methodTitle ==
                        "other_courier") {
                      listData.add(AppLocalizations.of(context)!
                          .translate('other_courier')!);
                    } else {
                      listData.add(
                          "${checkoutProvider!.shippingLines[i].methodTitle!} (${stringToCurrency(checkoutProvider!.shippingLines[i].cost!, context)})");
                    }
                  }
                }
                if (image == "card") {
                  setState(() {
                    idx = 2;
                    printLog("Masuk");
                  });
                  for (int i = 0;
                      i < checkoutProvider!.paymentMethods.length;
                      i++) {
                    if (checkoutProvider!.paymentMethods[i].id != "wallet") {
                      listData
                          .add(checkoutProvider!.tempPaymentMethods[i].title!);
                    } else if (checkoutProvider!.paymentMethods[i].id ==
                        "wallet") {
                      if (isWallet && grandTotal! < wallet) {
                        listData.add((checkoutProvider!
                                .paymentMethods[i].title! +
                            " (Balance ${stringToCurrency(wallet, context)})"));
                      }
                    }
                  }
                }
                showMaterialModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  builder: (context) => buildBottomSheet(
                      title: title,
                      count: listData.length,
                      list: listData,
                      idx: idx),
                );
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CouponScreen(products: products),
                    )).then((value) async {
                  setState(() {
                    coupons.clear();
                    coupon = Provider.of<CouponProvider>(context, listen: false)
                        .couponUsed!
                        .code!;
                    coupons.add({"code": coupon});
                    couponMount = double.parse(
                        Provider.of<CouponProvider>(context, listen: false)
                            .couponUsed!
                            .discountAmount
                            .toString());
                    Provider.of<CheckoutProvider>(context, listen: false)
                        .resetPayment();
                  });
                  Provider.of<CheckoutProvider>(context, listen: false)
                      .calculateTotal(
                    ship: shipCost,
                    disc: couponMount,
                    wallet: wallet,
                    isWallet: payWithWallet,
                  )
                      .then((value) {
                    wallet = double.parse(
                        Provider.of<WalletProvider>(context, listen: false)
                            .walletBalance!);
                    total =
                        Provider.of<CheckoutProvider>(context, listen: false)
                            .grandTotal!;
                    if (wallet >= total) {
                      isWallet = true;
                    } else if (wallet == 0) {
                      isWallet = true;
                    }
                  });
                  context
                      .read<CheckoutProvider>()
                      .checkPoin(coupon: couponMount);
                  print("coupon : $coupon");
                });
              }
            } else if (!Session.data.getBool('isLogin')!) {
              //USER TIDAK LOGIN
              if (image != "coupon") {
                if (image == "truck") {
                  setState(() {
                    idx = 1;
                  });
                  if (checkoutProvider!.shippingLines.isEmpty) {
                    printLog("masuk");
                    return snackBar(context,
                        message: AppLocalizations.of(context)!
                            .translate("alert_shipping_null")!);
                  }
                  for (int i = 0;
                      i < checkoutProvider!.shippingLines.length;
                      i++) {
                    if (checkoutProvider!.shippingLines[i].methodTitle ==
                        "other_courier") {
                      listData.add(AppLocalizations.of(context)!
                          .translate('other_courier')!);
                    } else {
                      listData.add(
                          "${checkoutProvider!.shippingLines[i].methodTitle!} (${stringToCurrency(checkoutProvider!.shippingLines[i].cost!, context)})");
                    }
                  }
                }
                if (image == "card") {
                  setState(() {
                    idx = 2;
                    printLog("Masuk");
                  });
                  for (int i = 0;
                      i < checkoutProvider!.paymentMethods.length;
                      i++) {
                    if (checkoutProvider!.paymentMethods[i].id != "wallet") {
                      listData.add(checkoutProvider!.paymentMethods[i].title!);
                    } else if (checkoutProvider!.paymentMethods[i].id ==
                        "wallet") {
                      if (isWallet) {
                        listData
                            .add(checkoutProvider!.paymentMethods[i].title!);
                      }
                    }
                  }
                }
                showMaterialModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  builder: (context) => buildBottomSheet(
                      title: title,
                      count: listData.length,
                      list: listData,
                      idx: idx),
                );
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CouponScreen(products: products),
                    )).then((value) async {
                  setState(() {
                    coupons.clear();
                    coupon = Provider.of<CouponProvider>(context, listen: false)
                        .couponUsed!
                        .code!;
                    coupons.add({"code": coupon});
                    couponMount = double.parse(
                        Provider.of<CouponProvider>(context, listen: false)
                            .couponUsed!
                            .discountAmount
                            .toString());
                  });
                  Provider.of<CheckoutProvider>(context, listen: false)
                      .calculateTotal(
                    ship: shipCost,
                    disc: couponMount,
                    wallet: wallet,
                    isWallet: payWithWallet,
                  );
                  print("coupon : $coupon");
                });
              }
            } else if (value.user!.firstName == null) {
              return snackBar(context,
                  message:
                      "${AppLocalizations.of(context)!.translate('pls_add_change_addr')!}");
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: HexColor("#d5d5d5"))),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    "images/order/$image.png",
                    width: 25,
                    height: 25,
                    color: primaryColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 230,
                    child: Text(
                        value.titlePayment == null &&
                                value.titleShipping == null
                            ? "$title"
                            : image == "card" && value.titlePayment != null
                                ? "${value.titlePayment}"
                                : image == "truck" &&
                                        value.titleShipping != null
                                    ? "${value.titleShipping}"
                                    : "$title",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: appNotifier!.isDarkMode
                                ? null
                                : HexColor("#6e6e6e"))),
                  ),
                  Spacer(),
                  (image == "card" && value.titlePayment != null) ||
                          (image == "truck" && value.titleShipping != null) ||
                          (image == "coupon" && coupon.isNotEmpty)
                      ? Icon(Icons.check)
                      : Icon(Icons.arrow_right)
                ]),
          ),
        );
      },
    );
  }

  Widget buildNote() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, bottom: 5),
            child: Text(
              AppLocalizations.of(context)!.translate('order_notes')!,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: appNotifier!.isDarkMode ? null : HexColor("#6e6e6e"),
                  fontSize: 16),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: HexColor("#d5d5d5"))),
            child: TextField(
                controller: noteController,
                maxLines: 5,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: InputBorder.none,
                  hintText:
                      AppLocalizations.of(context)!.translate('your_notes')!,
                  hintStyle: TextStyle(fontSize: responsiveFont(12)),
                )),
          )
        ],
      ),
    );
  }

  Widget buildShipedTo() {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          AppLocalizations.of(context)!.translate('shipped_to')!,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        TextButton(
            onPressed: () async {
              if (Session.data.getBool('isLogin')!) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountAddressScreen(),
                    )).then((value) {
                  loadData();
                });
              } else if (billing.isNotEmpty) {
                printLog(billing.toString(), name: "billing");
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountAddressEditScreen(
                        billingEmpty: false,
                        title: 'billing',
                        isGuest: true,
                        billing: billing,
                      ),
                    )).then((value) {
                  if (value != null) {
                    billing.clear();
                    billing = value;
                    setState(() {});
                    loadData();
                  }
                });
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountAddressEditScreen(
                        title: "billing",
                        isGuest: true,
                        billingEmpty: true,
                      ),
                    )).then((value) {
                  if (value != null) {
                    billing.clear();
                    billing = value;
                    setState(() {
                      loadData();
                    });
                  }
                  printLog("billing : $value");
                });
              }
            },
            child: Text(
              AppLocalizations.of(context)!.translate('add_change_addr')!,
              style: TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ))
      ]),
    );
  }

  Widget buildAddress(UserData user) {
    return user.firstName != null &&
            Session.data.getBool('isLogin')! &&
            user.firstName != ""
        ? Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    user.firstName! + " " + user.lastName!,
                    // " ${user.company != null && user.company != "" ? "(${user.company})" : ""}",
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    user.phone!,
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    user.email!,
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    user.address1! + ", " + "${user.address2 ?? ""}",
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    user.city! + " - " + (user.stateName!),
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    (user.countryName!) + " - " + user.postcode!,
                    style: TextStyle(fontSize: 12),
                  ),
                ]),
          )
        : !Session.data.getBool('isLogin')! && billing.isNotEmpty
            ? Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        billing[0] + " " + billing[1],
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(billing[9], style: TextStyle(fontSize: 12)),
                      Text(billing[10], style: TextStyle(fontSize: 12)),
                      // Text(billing[2] == "" ? "-" : billing[2]),
                      Text(billing[6] + ", " + billing[7],
                          style: TextStyle(fontSize: 12)),
                      Text(billing[5] + " - " + billing[4],
                          style: TextStyle(fontSize: 12)),
                      Text(billing[3] + " - " + billing[8],
                          style: TextStyle(fontSize: 12)),
                    ]),
              )
            : Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .translate('pls_add_change_addr')!,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ]),
              );
  }

  Widget listProduct() {
    return Container(
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: checkoutProvider!.lineItems.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              itemProduct(checkoutProvider!.lineItems[index], index),
              index != checkoutProvider!.lineItems.length - 1
                  ? Divider(
                      color: HexColor("#d5d5d5"),
                      thickness: 1,
                    )
                  : Container()
            ],
          );
        },
      ),
    );
  }

  Widget itemProduct(LineItem item, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(children: [
        Container(
          margin: EdgeInsets.only(right: 10),
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: item.image!,
              fit: BoxFit.fill,
              placeholder: (context, url) => customLoading(),
              errorWidget: (context, url, error) => Icon(
                Icons.image_not_supported_rounded,
                size: 25,
              ),
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: MediaQuery.of(context).size.width - 120,
            child: Text(
              "${item.name}",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Visibility(
            visible: item.variation != "",
            child: Container(
              width: MediaQuery.of(context).size.width - 120,
              child: Text(
                "${item.variation}",
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Text(
            "${item.qty} ${AppLocalizations.of(context)!.translate('items')} ${item.weight == 0 ? "" : "(${item.weight}kg)"}",
            style: TextStyle(fontSize: 12),
          ),
          Text(
            "${stringToCurrency(item.subtotal!, context)}",
            style: TextStyle(fontSize: 12),
          ),
        ]),
      ]),
    );
  }
}
