import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/models/order_model.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/pages/order/my_order_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_localizations.dart';
import '../../provider/order_provider.dart';
import '../../utils/currency_format.dart';
import '../../utils/utility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'order_detail_screen.dart';

class OrderSuccess extends StatefulWidget {
  OrderSuccess({Key? key}) : super(key: key);

  @override
  _OrderSuccessState createState() => _OrderSuccessState();
}

class _OrderSuccessState extends State<OrderSuccess> {
  @override
  void initState() {
    super.initState();
    loadOrder();
  }

  String amount = "0";
  loadOrder() async {
    await Provider.of<OrderProvider>(context, listen: false)
        .fetchDetailOrder(Session.data.getString("order_number"))
        .then((value) {
      if (Provider.of<OrderProvider>(context, listen: false)
              .detailOrder!
              .feeLines!
              .length >
          0) {
        amount = Provider.of<OrderProvider>(context, listen: false)
            .detailOrder!
            .feeLines![0]
            .amount!
            .substring(1);
      } else {
        amount = "0";
      }
      loadOrderedItems();
    });
  }

  loadOrderedItems() async {
    await Provider.of<OrderProvider>(context, listen: false)
        .loadItemOrder(context);
    // Session.data.remove('order_number');
    this.setState(() {});
  }

  launchWaUrl(
      {required OrderModel detailOrder,
      required String appName,
      required String phoneNumber}) async {
    printLog("launchwaurl");
    List loopOrder = [];
    for (var i = 0; i < detailOrder.productItems!.length; i++) {
      loopOrder.add(
          "${detailOrder.productItems![i].productName}\n${detailOrder.productItems![i].quantity} X ${stringToCurrency(detailOrder.productItems![i].price!, context)}\n");
    }
    String orderSummary = loopOrder
        .toString()
        .replaceAll("[", "")
        .replaceAll("]", "")
        .replaceAll(", ", "");

    String orderNotes;
    if (detailOrder.customerNote != null && detailOrder.customerNote != "") {
      orderNotes = "Order Notes:\n${detailOrder.customerNote}";
    } else {
      orderNotes = "";
    }

    String message =
        """Hello, my name is ${detailOrder.billingInfo!.firstName} ${detailOrder.billingInfo!.lastName}, I just placed an order on the app $appName. Please check as soon as possible. Thank you.

Order ID : ${detailOrder.id}

Shipping Details :
${detailOrder.billingInfo!.firstName} ${detailOrder.billingInfo!.lastName}
${detailOrder.billingInfo!.phone}
${detailOrder.billingInfo!.email}
${detailOrder.billingInfo!.firstAddress}, ${detailOrder.billingInfo!.secondAddress}
${detailOrder.billingInfo!.city} - ${detailOrder.billingInfo!.state}
${detailOrder.billingInfo!.country} - ${detailOrder.billingInfo!.postCode}

Order Summary:
$orderSummary
Subtotal: ${stringToCurrency(detailOrder.subTotal!, context)}
Shipping Cost: ${stringToCurrency(double.parse(detailOrder.shippingTotal!), context)}
Discount: ${stringToCurrency(double.parse(detailOrder.discountTotal!), context)}
Total Orders: ${stringToCurrency(double.parse(detailOrder.total!), context)}

$orderNotes""";
    printLog(message, name: "MESSAGE");

    String encodedMessage = Uri.encodeFull(message);
    String url =
        'https://api.whatsapp.com/send/?phone=$phoneNumber&text=$encodedMessage';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderSuccess =
        Provider.of<HomeProvider>(context, listen: false).imageThanksOrder;
    final guestCheckoutActive =
        Provider.of<HomeProvider>(context, listen: false).guestCheckoutActive;
    final order = Provider.of<OrderProvider>(context, listen: false);
    final home = Provider.of<HomeProvider>(context, listen: false);
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                orderSuccess.image == null
                    ? Icon(
                        Icons.check_circle_outline,
                        color: primaryColor,
                        size: 75,
                      )
                    : CachedNetworkImage(
                        imageUrl: orderSuccess.image!,
                        height: MediaQuery.of(context).size.height * 0.4,
                        placeholder: (context, url) => Container(),
                        errorWidget: (context, url, error) => Icon(
                              Icons.check_circle_outline,
                              color: primaryColor,
                              size: 75,
                            )),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  margin: EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [primaryColor, secondaryColor])),
                  height: 30.h,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => HomeScreen()),
                          (Route<dynamic> route) => false);
                      if (!Session.data.getBool('isLogin')! &&
                          guestCheckoutActive) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MyOrder()));
                      } else {
                        printLog("TEST");
                        printLog(Session.data.getString('order_number')!,
                            name: "ORDER NUMBER ORDER SUCCESS");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderDetail(
                                      orderId: Session.data
                                          .getString('order_number'),
                                    )));
                      }
                    },
                    child: Text(
                      'Check Order',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: responsiveFont(10),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    launchWaUrl(
                        detailOrder: order.detailOrder!,
                        appName: home.packageInfo!.appName,
                        phoneNumber: home.wa.description);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: primaryColor)),
                    height: 30.h,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!
                            .translate('send_whatsapp_order')!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: responsiveFont(10),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => HomeScreen()),
                        (Route<dynamic> route) => false);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.translate('back_to_home')!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async => false);
  }
}
