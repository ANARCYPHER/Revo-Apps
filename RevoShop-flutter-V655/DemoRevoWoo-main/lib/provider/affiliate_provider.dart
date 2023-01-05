import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/webview/inapp_webview.dart';
import 'package:nyoba/widgets/webview/webview.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../constant/global_url.dart';
import '../services/session.dart';

class AffiliateProvider with ChangeNotifier {
  Future affiliateDetails(context) async {
    var cookie = Session.data.getString('cookie');
    printLog('$url/wp-json/revo-admin/v1/$affiliateDetail?cookie=$cookie',
        name: "URL");
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InAppWebview(
                  url:
                      '$url/wp-json/revo-admin/v1/$affiliateDetail?cookie=$cookie',
                  title: AppLocalizations.of(context)!.translate('details')!,
                )));
  }
}
