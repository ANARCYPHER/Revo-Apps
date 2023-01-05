import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/pages/notification/notification_screen.dart';
import 'package:nyoba/pages/order/order_success_screen.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final url;
  final String? title;
  bool? fromNotif = false;

  WebViewScreen({Key? key, this.url, this.title, this.fromNotif})
      : super(key: key);
  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  WebViewController? _webViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    printLog(widget.url, name: "URL WEBVIEW");
  }

  backPopDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          insetPadding: EdgeInsets.all(0),
          content: Builder(
            builder: (context) {
              return Container(
                height: 150,
                width: 330,
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
                              .translate('title_exit_alert')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: responsiveFont(14),
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Do you want to leave this page?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: responsiveFont(12),
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    Container(
                        child: Column(
                      children: [
                        Container(
                          color: Colors.black12,
                          height: 2,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(false),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15)),
                                      color: primaryColor),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('no')!,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderSuccess(),
                                    )),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(15)),
                                      color: Colors.white),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('yes')!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: primaryColor),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ))
                  ],
                ),
              );
            },
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // backPopDialog();
        if (widget.fromNotif == true) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationScreen(fromPushNotif: true),
              ),
              (route) => false);
        }

        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            // backgroundColor: Colors.white,
            title: Text(
              widget.title!,
              style: TextStyle(
                fontSize: responsiveFont(16),
                fontWeight: FontWeight.w500,
                // color: Colors.black
              ),
            ),
            leading: IconButton(
              //color: Colors.black,
              onPressed: () {
                // backPopDialog();
                if (widget.fromNotif == true) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NotificationScreen(fromPushNotif: true),
                      ),
                      (route) => false);
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Platform.isIOS
                  ? Icon(Icons.arrow_back_ios)
                  : Icon(Icons.arrow_back),
            ),
          ),
          body: Stack(
            children: [
              WebView(
                initialUrl: widget.url,
                javascriptMode: JavascriptMode.unrestricted,
                onProgress: (int progress) {
                  print("WebView is loading (progress : $progress%)");
                  _webViewController?.runJavascript(
                      "document.querySelector('.wws-popup__open-btn').remove()");
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
                      "document.getElementsByClassName('useful-links')[0].style.display= 'none';");
                  _webViewController?.runJavascript(
                      "document.getElementsByClassName('widget woocommerce widget_product_search')[1].style.display= 'none';");
                  _webViewController?.runJavascript(
                      "document.getElementsByClassName('wws-popup-container wws-popup-container--position')[1].style.display= 'none';");
                  _webViewController?.runJavascript(
                      "document.getElementById('wws-layout-1').style.display= 'none';");
                },
                onWebViewCreated: (WebViewController webViewController) {
                  _webViewController = webViewController;
                  _controller.complete(webViewController);
                },
                onPageStarted: (String url) {
                  print('Page started loading: $url');
                },
                onPageFinished: (String url) {
                  print('Page finished loading: $url');
                  setState(() {
                    isLoading = false;
                  });
                  _webViewController?.runJavascript(
                      "document.querySelector('.wws-popup__open-btn').remove()");
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
                      "document.getElementsByClassName('useful-links')[0].style.display= 'none';");
                  _webViewController?.runJavascript(
                      "document.getElementsByClassName('widget woocommerce widget_product_search')[1].style.display= 'none';");
                  _webViewController?.runJavascript(
                      "document.getElementsByClassName('wws-popup-container wws-popup-container--position')[1].style.display= 'none';");
                  _webViewController?.runJavascript(
                      "document.getElementById('wws-layout-1').style.display= 'none';");
                },
                gestureNavigationEnabled: true,
              ),
              isLoading
                  ? Center(
                      child: customLoading(),
                    )
                  : Stack(),
            ],
          )),
    );
  }
}
