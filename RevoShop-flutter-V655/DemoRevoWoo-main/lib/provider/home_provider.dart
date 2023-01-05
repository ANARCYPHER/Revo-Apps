import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:nyoba/models/aftership_check_model.dart';
import 'package:nyoba/models/banner_mini_model.dart';
import 'package:nyoba/models/banner_model.dart';
import 'package:nyoba/models/billing_address_model.dart';
import 'package:nyoba/models/categories_model.dart';
import 'package:nyoba/models/contact_model.dart';
import 'package:nyoba/models/general_settings_model.dart';
import 'package:nyoba/models/home_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/models/variation_model.dart';
import 'package:nyoba/provider/category_provider.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/services/home_api.dart';
import 'package:nyoba/services/product_api.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';

class HomeProvider with ChangeNotifier {
  bool isReload = false;
  bool loading = false;
  bool guestCheckoutActive = false;
  bool isBannerPopChanged = false;
  bool isPhotoReviewActive = false;
  bool isChatActive = false;
  bool isGiftActive = false;
  bool isWalletActive = false;
  bool isSolid = false;
  bool toolTip = false;
  bool finishToolTip = false;
  bool syncCart = false;
  bool checkoutFrom = false;
  bool showSoldItem = false;
  bool showAverageRating = false;
  bool showRatingSection = false;
  bool showVariationWithImage = false;
  String imageGuide = "";

  /*List Main Slider Banner Model*/
  List<BannerModel> banners = [];

  /*List Banner Mini Product Model*/
  List<BannerMiniModel> bannerSpecial = [];
  List<BannerMiniModel> bannerLove = [];

  /*Banner PopUp*/
  List<BannerMiniModel> bannerPopUp = [];

  /*List Home Mini Categories Model*/
  List<CategoriesModel> categories = [];

  /*List Intro Page Model*/
  List<GeneralSettingsModel> intro = [];

  //List product category home
  List<ProductCategoryModel> productCategories = [];

  //List new product
  List<ProductModel> listNewProduct = [];

  /*General Settings Model*/
  GeneralSettingsModel splashscreen = new GeneralSettingsModel();
  GeneralSettingsModel logo = new GeneralSettingsModel();
  GeneralSettingsModel wa = new GeneralSettingsModel();
  GeneralSettingsModel sms = new GeneralSettingsModel();
  GeneralSettingsModel phone = new GeneralSettingsModel();
  GeneralSettingsModel about = new GeneralSettingsModel();
  GeneralSettingsModel currency = new GeneralSettingsModel();
  GeneralSettingsModel formatCurrency = new GeneralSettingsModel();
  GeneralSettingsModel privacy = new GeneralSettingsModel();
  GeneralSettingsModel terms = new GeneralSettingsModel();
  GeneralSettingsModel image404 = new GeneralSettingsModel();
  GeneralSettingsModel imageThanksOrder = new GeneralSettingsModel();
  GeneralSettingsModel imageNoTransaction = new GeneralSettingsModel();
  GeneralSettingsModel imageSearchEmpty = new GeneralSettingsModel();
  GeneralSettingsModel imageNoLogin = new GeneralSettingsModel();
  GeneralSettingsModel searchBarText = new GeneralSettingsModel();
  GeneralSettingsModel sosmedLink = new GeneralSettingsModel();

  bool? isBarcodeActive = false;

  /*List billing address*/
  List<BillingAddress> billingAddress = [];

  /*Flash Sales Model*/
  List<FlashSaleHomeModel> flashSales = [];

  /*Extend Product Model*/
  List<ProductExtendHomeModel> specialProducts = [];
  List<ProductExtendHomeModel> bestProducts = [];
  List<ProductExtendHomeModel> recommendationProducts = [];
  List<ProductModel> tempProducts = [];

  /*Intro Page Status*/
  String? introStatus;

  /*App Color*/
  List<GeneralSettingsModel> appColors = [];

  bool loadingMore = false;

  bool? isLoadHomeSuccess = true;

  PackageInfo? packageInfo;

  List<ContactModel>? contacts = [];

  AfterShipCheck? afterShipCheck;

  int? photoMaxSize = 1000;
  int? photoMaxFiles = 2;

  bool blogCommentFeature = false;

  bool loadBanner = false;

  Future<void> fetchHomeData(context) async {
    await fetchProductCategories(context);
  }

  Future<void> fetchProductCategories(context) async {
    final categories = Provider.of<CategoryProvider>(context, listen: false);
    //if (categories.productCategories.isEmpty) {
    Future.wait(
        [categories.fetchProductCategories(), fetchNewProducts(context)]);
    //}
  }

  Future<void> fetchNewProducts(context) async {
    final product = Provider.of<ProductProvider>(context, listen: false);
    await product.fetchNewProducts('', page: 1);
  }

  Future<bool> fetchBlogComment() async {
    // loading = true;
    await HomeAPI().homeDataApi().then((data) {
      if (data.statusCode == 200) {
        final response = json.decode(data.body);
        if (response['general_settings']['blog_comment_feature'] != null) {
          blogCommentFeature =
              response['general_settings']['blog_comment_feature'];
          printLog(blogCommentFeature.toString(), name: 'blogComment');
        } else {
          blogCommentFeature = false;
        }
      }
    });
    // loading = false;
    notifyListeners();
    return blogCommentFeature;
  }

  setFinishToolTip() {
    finishToolTip = true;
    notifyListeners();
  }

  Future<bool?> fetchHome(context) async {
    loadBanner = true;
    loading = true;
    await HomeAPI().homeDataApi().then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);
        /*Add Data Main Slider*/
        banners.clear();
        for (Map item in responseJson['main_slider']) {
          banners.add(BannerModel.fromJson(item));
        }
        banners = new List.from(banners.reversed);
        /*End*/

        /*Add Data Mini Categories Home*/
        categories.clear();
        for (Map item in responseJson['mini_categories']) {
          categories.add(CategoriesModel.fromJson(item));
        }
        categories = new List.from(categories.reversed);
        // categories.add(new CategoriesModel(
        //     image: 'images/lobby/viewMore.png',
        //     categories: null,
        //     id: null,
        //     titleCategories:
        //         AppLocalizations.of(context)!.translate('view_more')));
        /*End*/

        /*Add Data Flash Sales Home*/
        for (Map item in responseJson['products_flash_sale']) {
          flashSales.add(FlashSaleHomeModel.fromJson(item));
        }
        /*End*/

        /*Add Data Mini Banner Home*/
        bannerSpecial.clear();
        bannerLove.clear();
        for (Map item in responseJson['mini_banner']) {
          if (item['type'] == 'Special Promo') {
            bannerSpecial.add(BannerMiniModel.fromJson(item));
          } else if (item['type'] == 'Love These Items') {
            bannerLove.add(BannerMiniModel.fromJson(item));
          }
        }
        /*End*/

        /*Add Data Banner PopUp*/
        bannerPopUp.clear();
        isBannerPopChanged = false;
        for (Map item in responseJson['popup_promo']) {
          bannerPopUp.add(BannerMiniModel.fromJson(item));
        }
        final DateTime now = DateTime.now();
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        final String formatted = formatter.format(now);
        if (Session.data.containsKey('image_popup_date')) {
          if (formatted != Session.data.getString('image_popup_date')) {
            isBannerPopChanged = true;
          }
        } else {
          isBannerPopChanged = true;
        }
        Session.data.setString('image_popup_date', formatted);
        /*End*/

        /*Add Data Special Products*/
        specialProducts.clear();
        for (Map item in responseJson['products_special']) {
          specialProducts.add(ProductExtendHomeModel.fromJson(item));
        }
        /*End*/

        /*Add Data Best Products*/
        bestProducts.clear();
        for (Map item in responseJson['products_our_best_seller']) {
          bestProducts.add(ProductExtendHomeModel.fromJson(item));
        }
        /*End*/

        /*Add Data Recommendation Products*/
        recommendationProducts.clear();
        for (Map item in responseJson['products_recomendation']) {
          recommendationProducts.add(ProductExtendHomeModel.fromJson(item));
        }
        /*End*/

        /*Add Data General Settings*/
        for (Map item in responseJson['general_settings']['empty_image']) {
          if (item['title'] == '404_images') {
            image404 = GeneralSettingsModel.fromJson(item);
          } else if (item['title'] == 'thanks_order') {
            imageThanksOrder = GeneralSettingsModel.fromJson(item);
          } else if (item['title'] == 'no_transaksi' ||
              item['title'] == 'empty_transaksi') {
            imageNoTransaction = GeneralSettingsModel.fromJson(item);
          } else if (item['title'] == 'search_empty') {
            imageSearchEmpty = GeneralSettingsModel.fromJson(item);
          } else if (item['title'] == 'login_required') {
            imageNoLogin = GeneralSettingsModel.fromJson(item);
          }
        }

        printLog(imageNoTransaction.toString());

        logo = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['logo']);
        wa = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['wa']);
        sms = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['sms']);
        phone = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['phone']);
        about = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['about']);
        currency = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['currency']);
        formatCurrency = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['format_currency']);
        privacy = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['privacy_policy']);
        terms = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['term_condition']);
        if (responseJson['general_settings']['livechat_to_revopos'] != null) {
          isChatActive =
              responseJson['general_settings']['livechat_to_revopos'];
        }
        if (responseJson['general_settings']['terawallet'] != null) {
          isWalletActive = responseJson['general_settings']['terawallet'];
        }
        if (responseJson['general_settings']['gift_box'] != null) {
          String temp = responseJson['general_settings']['gift_box'];
          if (temp != "hide") {
            isGiftActive = true;
          }
        }
        if (responseJson['general_settings']['searchbar_text'] != null) {
          searchBarText = GeneralSettingsModel.fromJson(
              responseJson['general_settings']['searchbar_text']);
        }
        if (responseJson['general_settings']['sosmed_link'] != null) {
          sosmedLink = GeneralSettingsModel.fromJson(
              responseJson['general_settings']['sosmed_link']);
        }
        if (responseJson['general_settings']['product_settings'] != null) {
          showSoldItem = responseJson['general_settings']['product_settings']
              ['show_sold_item_data'];
          showAverageRating = responseJson['general_settings']
              ['product_settings']['show_average_rating_data'];
          showRatingSection = responseJson['general_settings']
              ['product_settings']['show_rating_section'];
          showVariationWithImage = responseJson['general_settings']
              ['product_settings']['show_variation_with_image'];
        }
        if (responseJson['general_settings']['barcode_active'] != null) {
          isBarcodeActive = responseJson['general_settings']['barcode_active'];
        }

        if (responseJson['general_settings']['guest_checkout'] != null) {
          guestCheckoutActive =
              responseJson['general_settings']['guest_checkout'] == 'disable'
                  ? false
                  : true;
        }

        if (responseJson['general_settings']['guide_feature'] != null) {
          toolTip = responseJson['general_settings']['guide_feature']['status'];

          imageGuide =
              responseJson['general_settings']['guide_feature']['image'];
        }

        if (responseJson['general_settings']['sync_cart'] != null) {
          syncCart = responseJson['general_settings']['sync_cart'];
        }

        if (responseJson['general_settings']['checkout'] != null) {
          checkoutFrom = responseJson['general_settings']['checkout'];
        }

        if (responseJson['general_settings']['photoreviews_active'] != null) {
          isPhotoReviewActive =
              responseJson['general_settings']['photoreviews_active'];
        }
        if (responseJson['general_settings']['photoreviews_maxfiles'] != null) {
          photoMaxFiles =
              responseJson['general_settings']['photoreviews_maxfiles'];
        }
        if (responseJson['general_settings']['photoreviews_maxsize'] != null) {
          photoMaxSize =
              responseJson['general_settings']['photoreviews_maxsize'];
        }

        billingAddress.clear();
        if (responseJson['general_settings']['additional_billing_address'] !=
            null) {
          printLog(
              "MASUK 1: ${json.encode(responseJson['general_settings']['additional_billing_address'])}");
          for (Map item in responseJson['general_settings']
              ['additional_billing_address']) {
            billingAddress.add(BillingAddress.fromJson(item));
          }
          printLog("MASUK : ${json.encode(billingAddress)}");
        }

        /*End*/

        /*Add Data Intro Page & Splash Screen*/
        splashscreen =
            GeneralSettingsModel.fromJson(responseJson['splashscreen']);
        intro.clear();
        for (Map item in responseJson['intro']) {
          intro.add(GeneralSettingsModel.fromJson(item));
        }
        intro = new List.from(intro.reversed);

        introStatus = responseJson['intro_page_status'];
        /*End*/

        //Add Data home categories
        productCategories.clear();
        if (responseJson['categories'] != null) {
          for (Map item in responseJson['categories']) {
            productCategories.add(ProductCategoryModel.fromJson(item));
          }
        }

        listNewProduct.clear();
        if (responseJson['new_product'] != null) {
          for (Map item in responseJson['new_product']) {
            listNewProduct.add(ProductModel.fromJson(item));
          }
          for (int i = 0; i < listNewProduct.length; i++) {
            if (listNewProduct[i].type == 'variable') {
              for (int j = 0;
                  j < listNewProduct[i].availableVariations!.length;
                  j++) {
                if (listNewProduct[i]
                            .availableVariations![j]
                            .displayRegularPrice -
                        listNewProduct[i]
                            .availableVariations![j]
                            .displayPrice !=
                    0) {
                  double temp = ((listNewProduct[i]
                                  .availableVariations![j]
                                  .displayRegularPrice -
                              listNewProduct[i]
                                  .availableVariations![j]
                                  .displayPrice) /
                          listNewProduct[i]
                              .availableVariations![j]
                              .displayRegularPrice) *
                      100;
                  if (listNewProduct[i].discProduct! < temp) {
                    listNewProduct[i].discProduct = temp;
                  }
                }
              }
            }
          }
        }

        /*Set Data App Color*/
        if (responseJson['app_color'] != null) {
          appColors.clear();
          for (Map item in responseJson['app_color']) {
            appColors.add(GeneralSettingsModel.fromJson(item));
          }
        }

        if (responseJson['general_settings']['buynow_button_style'] ==
            'solid') {
          isSolid = true;
        }
        printLog(isSolid.toString(), name: "is solid button");

        /*End*/

        contacts!.clear();
        if (wa.description != null && wa.description != '') {
          contacts!.add(new ContactModel(
              id: wa.title, title: 'WhatsApp', url: wa.description));
        }
        if (phone.description != null && phone.description != '') {
          contacts!.add(new ContactModel(
              id: phone.title, title: 'Call', url: "+${phone.description}"));
        }
        if (sms.description != null && sms.description != '') {
          contacts!.add(new ContactModel(
              id: sms.title, title: 'SMS', url: "+${sms.description}"));
        }
        if (isChatActive) {
          contacts!
              .add(new ContactModel(id: "chat", title: "Live Chat", url: ""));
        }

        if (responseJson['aftership'] != null) {
          afterShipCheck = AfterShipCheck.fromJson(responseJson['aftership']);
        }

        printLog(afterShipCheck!.pluginActive.toString(), name: 'AfterShip');

        print("Completed");
        loading = false;
        loadBanner = false;
        notifyListeners();
      } else {
        loading = false;
        loadBanner = false;
        isLoadHomeSuccess = false;
        notifyListeners();
        print("Load Failed");
      }
    });
    return isLoadHomeSuccess;
    try {} catch (e) {
      loading = false;
      loadBanner = false;
      isLoadHomeSuccess = false;
      notifyListeners();
      printLog('Error, $e', name: "Home Load Failed");
      return isLoadHomeSuccess;
    }
  }

  Future<bool> fetchMoreRecommendation(String? productId, {int? page}) async {
    loadingMore = true;
    await ProductAPI()
        .fetchMoreProduct(
            include: productId, page: page, perPage: 10, order: '', orderBy: '')
        .then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        tempProducts.clear();
        for (Map item in responseJson) {
          tempProducts.add(ProductModel.fromJson(item));
        }

        loadVariationData(listProduct: tempProducts, load: loadingMore)
            .then((value) {
          tempProducts.forEach((element) {
            recommendationProducts[0].products!.add(element);
          });
          loadingMore = false;
          notifyListeners();
        });
      } else {
        print("Load Failed");
        loadingMore = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool?> loadVariationData(
      {required List<ProductModel> listProduct, bool? load}) async {
    listProduct.forEach((element) async {
      if (element.type == 'variable') {
        List<VariationModel> variations = [];
        notifyListeners();
        load = true;
        await ProductAPI()
            .productVariations(productId: element.id.toString())
            .then((value) {
          if (value.statusCode == 200) {
            final variation = json.decode(value.body);

            for (Map item in variation) {
              if (item['price'].isNotEmpty) {
                variations.add(VariationModel.fromJson(item));
              }
            }

            variations.forEach((v) {
              /*printLog('${element.productName} ${v.id} ${v.price}',
                  name: 'Price Variation 2');*/
              element.variationPrices!.add(double.parse(v.price!));
            });

            element.variationPrices!.sort((a, b) => a.compareTo(b));
          }
          load = false;
          notifyListeners();
        });
      } else {
        load = false;
        notifyListeners();
      }
    });
    return load;
  }

  changeIsReload() {
    isReload = false;
    notifyListeners();
  }

  setPackageInfo(value) {
    packageInfo = value;
    notifyListeners();
  }

  changePopBannerStatus(value) {
    isBannerPopChanged = value;
    notifyListeners();
  }
}
