import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/checkout_guest_model.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutWebView extends StatefulWidget {
  final url;
  final Future<dynamic> Function()? onFinish;
  final bool fromOrder;
  final bool withAppBar;
  final bool fromMyOrder;
  final bool fromCart;

  CheckoutWebView(
      {Key? key,
      this.url,
      this.onFinish,
      this.fromOrder = false,
      this.withAppBar = true,
      this.fromMyOrder = false,
      this.fromCart = false})
      : super(key: key);
  @override
  CheckoutWebViewState createState() => CheckoutWebViewState();
}

class CheckoutWebViewState extends State<CheckoutWebView> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  WebViewController? _webViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  _launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      snackBar(context, color: Colors.red, message: 'Could not launch $url');
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final guestCheckoutActive =
        Provider.of<HomeProvider>(context, listen: false).guestCheckoutActive;
    return Scaffold(
        appBar: widget.withAppBar
            ? AppBar(
                backgroundColor: Colors.white,
                title: widget.fromMyOrder
                    ? Text(
                        AppLocalizations.of(context)!
                            .translate('order_detail')!,
                        style: TextStyle(color: Colors.black),
                      )
                    : Text(
                        !widget.fromOrder &&
                                guestCheckoutActive &&
                                !Session.data.getBool('isLogin')!
                            ? '${AppLocalizations.of(context)!.translate('checkout_as_guest')}'
                            : widget.fromOrder
                                ? 'Payment Order'
                                : '${AppLocalizations.of(context)!.translate('checkout_order')}',
                        style: TextStyle(color: Colors.black),
                      ),
                leading: IconButton(
                  color: Colors.black,
                  onPressed: () => Navigator.pop(context),
                  icon: Platform.isIOS
                      ? Icon(Icons.arrow_back_ios)
                      : Icon(Icons.arrow_back),
                ),
              )
            : null,
        body: Stack(
          children: [
            WebView(
              initialUrl: widget.url,
              gestureRecognizers: Set()
                ..add(Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer())),
              javascriptMode: JavascriptMode.unrestricted,
              onProgress: (int progress) {
                print("WebView is loading (progress : $progress%)");
                if (progress != 100) {
                  setState(() {
                    isLoading = true;
                  });
                } else {
                  setState(() {
                    isLoading = false;
                  });
                }
                _webViewController?.runJavascript(
                    "document.getElementById('headerwrap').style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementById('footerwrap').style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByTagName('header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByTagName('footer')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('return-to-shop')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('page-title')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woocommerce-error')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woocommerce-breadcrumb')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('entry-title')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woocommerce-MyAccount-navigation')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woo-wallet-sidebar')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woo-wallet-content-heading')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByTagName('hr')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('mf-navigation-mobile')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('site-header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('header-mobile-v1')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('header-mobile-v2')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('mobile-header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-main-header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('wd-toolbar')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('wd-toolbar-label-show')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woodmart-toolbar-label-show')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woodmart-toolbar')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-sticky-header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-clone')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-main-header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-sticked')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-row')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-general-header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-not-sticky-row')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-without-bg')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-border-fullwidth')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-color-dark')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-flex-flex-middle')[0].style.display= 'none';");
              },
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController = webViewController;
                _controller.complete(webViewController);
                webViewController.clearCache();
                final cookieManager = CookieManager();
                cookieManager.clearCookies();
              },
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith('gojek:')) {
                  print('blocking navigation to $request}');
                  _launchUrl(request.url);
                  return NavigationDecision.prevent;
                }
                if (request.url.startsWith('upi:')) {
                  print('blocking navigation to $request}');
                  _launchUrl(request.url);
                  return NavigationDecision.prevent;
                }
                if (request.url.startsWith('whatsapp:')) {
                  print('blocking navigation to $request}');
                  _launchUrl(request.url);
                  return NavigationDecision.prevent;
                }
                if (request.url.contains("/checkout/order-received/")) {
                  print("cek");
                  final items = request.url.split("/checkout/order-received/");

                  if (items.length > 1) {
                    final number = items[1].split("/")[0];
                    Session.data.setString('order_number', number);

                    if (guestCheckoutActive &&
                        !Session.data.getBool('isLogin')!) {
                      List<CheckoutGuest> listOrder = [];

                      if (Session.data.containsKey('order_guest')) {
                        List orders =
                            json.decode(Session.data.getString('order_guest')!);

                        listOrder = orders
                            .map((order) => new CheckoutGuest.fromJson(order))
                            .toList();
                      }
                      listOrder.add(new CheckoutGuest(
                          url: request.url,
                          createdAt: DateTime.now().toString(),
                          orderId: int.parse(number)));
                      Session.data
                          .setString('order_guest', json.encode(listOrder));
                    }
                  }
                  if (!widget.fromOrder) {
                    print("HALO BRODI 2");
                    if (widget.fromCart) {
                      widget.onFinish!();
                    } else if (!widget.fromCart) {
                      Provider.of<OrderProvider>(context, listen: false)
                          .onFinishBuyNow(context);
                    }
                  } else {
                    Navigator.pop(context, '200');
                    snackBar(context,
                        color: Colors.green, message: 'Payment Success');
                  }
                  return NavigationDecision.prevent;
                }
                print('allowing navigation to $request');
                return NavigationDecision.navigate;
              },
              onPageStarted: (String url) {
                print('Page started loading: $url');
              },
              onPageFinished: (String url) {
                print('Page finished loading: $url');
                _webViewController?.runJavascript(
                    "document.getElementById('headerwrap').style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementById('footerwrap').style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByTagName('header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByTagName('footer')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('return-to-shop')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('page-title')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woocommerce-error')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woocommerce-breadcrumb')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('entry-title')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woocommerce-MyAccount-navigation')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woo-wallet-sidebar')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woo-wallet-content-heading')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByTagName('hr')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('mf-navigation-mobile')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('site-header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('header-mobile-v1')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('header-mobile-v2')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('mobile-header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-main-header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('wd-toolbar')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('wd-toolbar-label-show')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woodmart-toolbar-label-show')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('woodmart-toolbar')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-sticky-header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-clone')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-main-header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-sticked')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-row')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-general-header')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-not-sticky-row')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-without-bg')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-border-fullwidth')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-color-dark')[0].style.display= 'none';");
                _webViewController?.runJavascript(
                    "document.getElementsByClassName('whb-flex-flex-middle')[0].style.display= 'none';");
              },
              gestureNavigationEnabled: true,
            ),
            isLoading
                ? Center(
                    child: customLoading(),
                  )
                : Stack(),
          ],
        ));
  }
}
