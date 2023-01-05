import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nyoba/pages/blog/blog_detail_screen.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/chat/chat_page.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/pages/intro/splash_screen.dart';
import 'package:nyoba/pages/product/product_detail_screen.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/webview/webview.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

import '../pages/notification/notification_screen.dart';
import '../provider/notification_provider.dart';
import '../services/session.dart';
import '../utils/global_variable.dart';

class DeeplinkConfig {
  Future Function()? onLinkClicked;
  Future<Widget> initUniLinks(BuildContext context) async {
    Widget screen = SplashScreen();
    try {
      String? initialLink = await getInitialLink();
      print(initialLink);
      if (initialLink != null) {
        Uri uri = Uri.parse(initialLink);
        print(uri);
        printLog('Deeplink Exists!', name: 'Deeplink');
        pathUrl(uri, context, true);
        screen = SplashScreen(
          onLinkClicked: onLinkClicked,
        );
      }
      if (selectedNotificationPayload != null) {
        var _payload = json.decode(selectedNotificationPayload!);
        if (_payload['type'] == 'order') {
          printLog(_payload['type'].toString(), name: "Payload Type");
          onLinkClicked = () async => await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => NotificationScreen()));
        } else if (_payload['type'] == 'chat') {
          printLog(_payload['type'].toString(), name: "Payload Type");
          onLinkClicked = () async => await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ChatPage()));
        } else {
          printLog(_payload['type'].toString(), name: "Payload Type");
          print("Else");
          Uri uri = Uri.parse(_payload['click_action']);
          pathUrl(uri, context, true);
        }
        screen = SplashScreen(
          onLinkClicked: onLinkClicked,
        );
      }
    } on PlatformException {
      print("Error");
    }
    return screen;
  }

  pathUrl(Uri uri, BuildContext context, bool fromLaunchApp,
      {int? id, String? type, bool? fromNotif = false}) async {
    /*Shop (Detail Product)*/
    printLog(uri.pathSegments.toString(), name: "Uri pathsegment");
    printLog('Message id deeplink' + id.toString());
    printLog('Message type deeplink' + type.toString());

    if (uri.pathSegments.isEmpty) {
      if (uri.toString().contains('?ref=')) {
        printLog(uri.toString(), name: "URI");
        var ref = uri.toString().split('=');
        printLog(ref[1], name: "REF");
        Session.data.setString('ref', ref[1]);
        if (fromLaunchApp) {
          onLinkClicked = () async => await Navigator.push(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else {
          await Navigator.of(GlobalVariable.navState.currentContext!)
              .push(MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      } else {
        if (fromNotif == true) {
          debugPrint('Message id deeplink' + id.toString());
          debugPrint('Message type deeplink' + type.toString());
          await Provider.of<NotificationProvider>(context, listen: false)
              .fetchReadNotif(id!, "push_notif");
          await Navigator.of(GlobalVariable.navState.currentContext!)
              .push(MaterialPageRoute(
                  builder: (context) => WebViewScreen(
                        title: "Push Notification",
                        url: uri.toString(),
                        fromNotif: true,
                      )));
        } else {
          await Navigator.of(GlobalVariable.navState.currentContext!)
              .push(MaterialPageRoute(
                  builder: (context) => WebViewScreen(
                        title: "Push Notification",
                        url: uri.toString(),
                        fromNotif: true,
                      )));
        }
      }
    } else if (uri.pathSegments[0] == "shop" ||
        uri.pathSegments[0] == "product") {
      if (uri.pathSegments[1].isNotEmpty) {
        print("Detail Product");
        if (fromNotif == true) {
          print("Detail Product");
          if (fromLaunchApp) {
            await Provider.of<NotificationProvider>(context, listen: false)
                .fetchReadNotif(id!, "push_notif");
            onLinkClicked = () async => await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProductDetail(
                          slug: uri.pathSegments[1],
                        )));
          } else {
            await Provider.of<NotificationProvider>(context, listen: false)
                .fetchReadNotif(id!, "push_notif");
            await Navigator.of(GlobalVariable.navState.currentContext!)
                .push(MaterialPageRoute(
                    builder: (context) => ProductDetail(
                          slug: uri.pathSegments[1],
                        )));
          }
        } else {
          if (fromLaunchApp) {
            onLinkClicked = () async => await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProductDetail(
                          slug: uri.pathSegments[1],
                        )));
          } else {
            await Navigator.of(GlobalVariable.navState.currentContext!)
                .push(MaterialPageRoute(
                    builder: (context) => ProductDetail(
                          slug: uri.pathSegments[1],
                        )));
          }
        }
      }
    } else if (uri.pathSegments[0] == "product-category") {
      if (uri.pathSegments[1].isNotEmpty) {
        if (fromNotif == true) {
          if (fromLaunchApp) {
            await Provider.of<NotificationProvider>(context, listen: false)
                .fetchReadNotif(id!, "push_notif");
            onLinkClicked = () async => await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BrandProducts(
                          slug: uri.pathSegments[1],
                          brandName: uri.pathSegments[1],
                        )));
          } else {
            await Provider.of<NotificationProvider>(context, listen: false)
                .fetchReadNotif(id!, "push_notif");
            await Navigator.of(GlobalVariable.navState.currentContext!)
                .push(MaterialPageRoute(
                    builder: (context) => BrandProducts(
                          slug: uri.pathSegments[1],
                          brandName: uri.pathSegments[1],
                        )));
          }
        } else {
          if (fromLaunchApp) {
            onLinkClicked = () async => await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BrandProducts(
                          slug: uri.pathSegments[1],
                          brandName: uri.pathSegments[1],
                        )));
          } else {
            await Navigator.of(GlobalVariable.navState.currentContext!)
                .push(MaterialPageRoute(
                    builder: (context) => BrandProducts(
                          slug: uri.pathSegments[1],
                          brandName: uri.pathSegments[1],
                        )));
          }
        }
      }
    } else if (uri.pathSegments[0] == "artikel" ||
        uri.pathSegments[0] == "articles" ||
        uri.pathSegments[0] == "blog" ||
        uri.pathSegments[0] == "blogs" ||
        uri.pathSegments[0] == "post") {
      if (uri.pathSegments[1].isNotEmpty) {
        print("Detail Blog");
        debugPrint(uri.toString());
        debugPrint(uri.pathSegments[0]);
        debugPrint(uri.pathSegments[1]);
        if (fromNotif == true) {
          if (fromLaunchApp) {
            await Provider.of<NotificationProvider>(context, listen: false)
                .fetchReadNotif(id!, "push_notif");
            onLinkClicked = () async => await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BlogDetail(
                          slug: uri.pathSegments[1],
                        )));
          } else {
            await Provider.of<NotificationProvider>(context, listen: false)
                .fetchReadNotif(id!, "push_notif");
            await Navigator.of(GlobalVariable.navState.currentContext!)
                .push(MaterialPageRoute(
                    builder: (context) => BlogDetail(
                          slug: uri.pathSegments[1],
                        )));
          }
        } else {
          if (fromLaunchApp) {
            onLinkClicked = () async => await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BlogDetail(
                          slug: uri.pathSegments[1],
                        )));
          } else {
            await Navigator.of(GlobalVariable.navState.currentContext!)
                .push(MaterialPageRoute(
                    builder: (context) => BlogDetail(
                          slug: uri.pathSegments[1],
                        )));
          }
        }
      }
    } else {
      if (fromNotif == true) {
        debugPrint('Message id deeplink' + id.toString());
        debugPrint('Message type deeplink' + type.toString());
        await Provider.of<NotificationProvider>(context, listen: false)
            .fetchReadNotif(id!, "push_notif");
        await Navigator.of(GlobalVariable.navState.currentContext!)
            .push(MaterialPageRoute(
                builder: (context) => WebViewScreen(
                      title: "Push Notification",
                      url: uri.toString(),
                      fromNotif: true,
                    )));
      } else {
        await Navigator.of(GlobalVariable.navState.currentContext!)
            .push(MaterialPageRoute(
                builder: (context) => WebViewScreen(
                      title: "Push Notification",
                      url: uri.toString(),
                      fromNotif: true,
                    )));
      }
    }
  }
}
