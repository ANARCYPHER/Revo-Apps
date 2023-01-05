import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/utility.dart';

class InAppWebview extends StatefulWidget {
  final url;
  final String title;

  const InAppWebview({super.key, required this.url, required this.title});
  @override
  InAppWebviewState createState() => new InAppWebviewState();
}

class InAppWebviewState extends State<InAppWebview> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: responsiveFont(16),
              fontWeight: FontWeight.w500,
              // color: Colors.black
            ),
          ),
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
                  initialOptions: options,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunchUrlString(url)) {
                        // Launch the App
                        await launchUrlString(url,
                            mode: LaunchMode.externalApplication);
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.querySelector('.wws-popup__open-btn').remove()");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementById('headerwrap').style.display= 'none';");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementById('footerwrap').style.display= 'none';");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementsByTagName('header')[0].style.display= 'none';");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementsByTagName('footer')[0].style.display= 'none';");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('return-to-shop')[0].style.display= 'none';");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('page-title')[0].style.display= 'none';");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('woocommerce-error')[0].style.display= 'none';");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('woocommerce-breadcrumb')[0].style.display= 'none';");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('useful-links')[0].style.display= 'none';");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('widget woocommerce widget_product_search')[1].style.display= 'none';");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('wws-popup-container wws-popup-container--position')[1].style.display= 'none';");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementById('wws-layout-1').style.display= 'none';");
                    await webViewController?.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('entry-title')[0].style.display= 'none';");
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = this.url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
          // ButtonBar(
          //   alignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     ElevatedButton(
          //       child: Icon(Icons.arrow_back),
          //       onPressed: () {
          //         webViewController?.goBack();
          //       },
          //     ),
          //     ElevatedButton(
          //       child: Icon(Icons.arrow_forward),
          //       onPressed: () {
          //         webViewController?.goForward();
          //       },
          //     ),
          //     ElevatedButton(
          //       child: Icon(Icons.refresh),
          //       onPressed: () {
          //         webViewController?.reload();
          //       },
          //     ),
          //   ],
          // ),
        ])));
  }
}
