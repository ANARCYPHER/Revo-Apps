import 'package:nyoba/services/base_woo_api.dart';

String appId = '1590795778';
String url = "https://demoonlineshop.revoapps.id";

// oauth_consumer_key
String consumerKey = "ck_3dd50eabf6ac18ab07078c39227d552afb3909a3";
String consumerSecret = "cs_f571992a893d1f7227a9275f4c38051047cc60ba";

// String version = '2.5.6';

// baseAPI for WooCommerce
BaseWooAPI baseAPI = BaseWooAPI(url, consumerKey, consumerSecret);

const debugNetworkProxy = false;
