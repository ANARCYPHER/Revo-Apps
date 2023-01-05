import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:launch_review/launch_review.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/pages/account/account_address_screen.dart';
import 'package:nyoba/pages/account/account_membership_screen.dart';
import 'package:nyoba/pages/chat/chat_page.dart';
import 'package:nyoba/pages/language/language_screen.dart';
import 'package:nyoba/pages/account/account_detail_screen.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/pages/point/my_point_screen.dart';
import 'package:nyoba/pages/review/review_screen.dart';
import 'package:nyoba/provider/affiliate_provider.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/chat_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/login_provider.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/widgets/webview/webview.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../utils/share_link.dart';
import '../wishlist/wishlist_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../order/my_order_screen.dart';
import '../../utils/utility.dart';

class AccountScreen extends StatefulWidget {
  AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? _versionName;
  @override
  void initState() {
    super.initState();
    // loadDetail();
  }

  newLogoutPopDialog() {
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
                height: 150.h,
                width: 330.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      AppLocalizations.of(context)!
                          .translate("your_sess_expired")!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: responsiveFont(14),
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                        child: Column(
                      children: [
                        Container(
                          color: Colors.black12,
                          height: 2,
                        ),
                        GestureDetector(
                          onTap: () => logout(),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15)),
                                color: primaryColor),
                            child: Text(
                              "Ok",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
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

  showQrCode(String qrData) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          insetPadding: EdgeInsets.all(0),
          content: Builder(
            builder: (context) {
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                padding: EdgeInsets.all(0),
                height: 300.h,
                width: 330.w,
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          AppLocalizations.of(context)!.translate('my_qrcode')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: responsiveFont(14.h),
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          AppLocalizations.of(context)!.translate('qr_code')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: responsiveFont(14.h),
                              fontWeight: FontWeight.w500),
                        ),
                        QrImage(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 160.w,
                          gapless: false,
                        ),
                        Text(
                          qrData,
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                        )),
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15.0),
                                    bottomRight: Radius.circular(15.0),
                                  ),
                                  color: primaryColor),
                              height: 40.h,
                              width: double.infinity,
                              child: Center(
                                  child: Text(
                                AppLocalizations.of(context)!.translate('ok')!,
                                style: TextStyle(color: Colors.white),
                              )),
                            )),
                      ),
                    ),
                  ],
                ),
              );
            },
          )),
    );
  }

  referalCodePopUp(context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final locale = Provider.of<AppNotifier>(context, listen: false).appLocal;
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
                height: 150.h,
                width: 330.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      AppLocalizations.of(context)!.translate('ref_code')!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: responsiveFont(14),
                          fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.h, vertical: 10.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 15.w,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade200),
                        child: Text(
                          userProvider.refModel.referralLink!
                              .replaceAll("", "\u{200B}"),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                        child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              shareLinks(
                                  'referal',
                                  userProvider.refModel.referralLink,
                                  context,
                                  locale);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(15)),
                                  color: primaryColor),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.share_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .translate('share')!,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                      text: userProvider.refModel.referralLink))
                                  .then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .translate('link_copied')!),
                                  ),
                                );
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(15)),
                                  color: primaryColor),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.content_copy_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .translate('copy')!,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ))
                  ],
                ),
              );
            },
          )),
    );
  }

  loadDetail() async {
    await Provider.of<UserProvider>(context, listen: false)
        .fetchUserDetail()
        .then((value) {
      if (value!['message'] != null) {
        if (value['message'].contains('cookie')) {
          printLog('cookie ditemukan');
          newLogoutPopDialog();
        }
      }

      if (mounted) this.setState(() {});
    });
  }

  Future _init() async {
    final _packageInfo = await PackageInfo.fromPlatform();

    return _packageInfo.version;
  }

  logout() async {
    final home = Provider.of<HomeProvider>(context, listen: false);
    var auth = FirebaseAuth.instance;

    Session().removeUser();
    if (auth.currentUser != null) {
      await GoogleSignIn().signOut();
    }
    if (Session.data.getString('login_type') == 'apple') {
      await auth.signOut();
    }
    if (Session.data.getString('login_type') == 'facebook') {
      context.read<LoginProvider>().facebookSignOut();
    }
    setState(() {});
    home.isReload = true;
    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final generalSettings = Provider.of<HomeProvider>(context, listen: false);
    final unread =
        Provider.of<ChatProvider>(context, listen: false).unreadMessage;
    final firstname = Session.data.getString('firstname') ?? "";
    final isChatActive = Provider.of<HomeProvider>(context).isChatActive;
    final point = Provider.of<UserProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isDarkMode =
        Provider.of<AppNotifier>(context, listen: false).isDarkMode;
    final membershipPlan = Session.data.getString("membershipPlan");
    _launchPhoneURL(String phoneNumber) async {
      String url = 'tel:' + phoneNumber;
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.translate('title_myAccount')!,
          style: TextStyle(
            fontSize: responsiveFont(16),
            fontWeight: FontWeight.w500,
            // color: Colors.black
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<UserProvider>(
                      builder: (context, value, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          value.loading
                              ? Row(
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.translate('hello')},",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: responsiveFont(14),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Shimmer.fromColors(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          height: 20.h,
                                          width: 70.w,
                                        ),
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!),
                                  ],
                                )
                              : Text(
                                  "${AppLocalizations.of(context)!.translate('hello')}, ${firstname.length > 10 ? firstname.substring(0, 10) + '... ' : firstname} !",
                                  style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: responsiveFont(14),
                                      fontWeight: FontWeight.w500),
                                ),
                          Text(
                            AppLocalizations.of(context)!
                                .translate('welcome_back')!,
                            style: TextStyle(fontSize: responsiveFont(9)),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Visibility(
                          visible: isChatActive,
                          child: Container(
                            child: Stack(children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(10),
                                //   color: primaryColor,
                                // ),
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                primaryColor)),
                                    child: Text("Live Chat",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.white,
                                        )),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(),
                                          ));
                                    }),
                              ),
                              unread > 0
                                  ? Positioned(
                                      top: 5,
                                      right: 0,
                                      child: Container(
                                        constraints: BoxConstraints(
                                            minWidth: 20, minHeight: 20),
                                        child: Center(
                                            child: Text(
                                          unread.toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: responsiveFont(10)),
                                        )),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(120)),
                                            color: secondaryColor),
                                      ),
                                    )
                                  : Container()
                            ]),
                          ),
                        ),
                        Visibility(
                          visible: !userProvider.loading &&
                                  userProvider.user.phoneNumber != "" ||
                              userProvider.refModel.referralLink != "",
                          child: GestureDetector(
                            onTap: () {
                              String qrData = "";
                              if (url.contains('//99')) {
                                qrData = userProvider.user.phoneNumber!;
                              } else {
                                qrData = userProvider.refModel.referralLink!;
                              }
                              printLog(url);
                              showQrCode(qrData);
                            },
                            child: Image.asset(
                              "images/account/qr-code.png",
                              color: isDarkMode ? Colors.white : Colors.black,
                              height: 25.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
            Container(
              width: double.infinity,
              height: 5,
              color: Colors.black12,
            ),
            Consumer<UserProvider>(
              builder: (context, value, child) {
                return value.loading
                    ? Container()
                    : Visibility(
                        visible: value.point != null,
                        child: buildPointCard(),
                      );
              },
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 15, left: 15, bottom: 5),
              child: Text(
                AppLocalizations.of(context)!.translate('account')!,
                style: TextStyle(
                    fontSize: responsiveFont(10),
                    fontWeight: FontWeight.w600,
                    color: secondaryColor),
              ),
            ),
            Visibility(
              visible: !url.contains('//99') && userProvider.membershipActive!,
              child: accountButton("membership",
                  AppLocalizations.of(context)!.translate('membership_plan')!,
                  func: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountMembershipScreen()))
                    .then((value) => this.setState(() {}));
              }),
            ),
            accountButton("akun",
                AppLocalizations.of(context)!.translate('title_myAccount')!,
                func: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AccountDetailScreen()))
                  .then((value) => this.setState(() {}));
            }),
            accountButton("address",
                "${AppLocalizations.of(context)!.translate('my_address')}",
                func: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AccountAddressScreen()))
                  .then((value) => this.setState(() {}));
            }),
            point.loading
                ? Container()
                : Visibility(
                    visible: point.point != null,
                    child: accountButton("coin",
                        AppLocalizations.of(context)!.translate('my_point')!,
                        func: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyPoint()))
                          .then((value) => this.setState(() {}));
                    }),
                  ),
            SizedBox(
              height: 5,
            ),
            Visibility(
              visible: userProvider.refModel.referralLink != null &&
                  userProvider.refModel.referralLink != "" &&
                  !userProvider.loading,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 15, left: 15, bottom: 5),
                    child: Text(
                      AppLocalizations.of(context)!.translate('affiliate')!,
                      style: TextStyle(
                          fontSize: responsiveFont(10),
                          fontWeight: FontWeight.w600,
                          color: secondaryColor),
                    ),
                  ),
                  accountButton("affiliate_detail",
                      AppLocalizations.of(context)!.translate('details')!,
                      func: () async {
                    await Provider.of<AffiliateProvider>(context, listen: false)
                        .affiliateDetails(context);
                  }),
                  accountButton("ref_code",
                      AppLocalizations.of(context)!.translate('ref_code')!,
                      func: () {
                    referalCodePopUp(context);
                  }),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 15, left: 15, bottom: 5),
              child: Text(
                AppLocalizations.of(context)!.translate('transaction')!,
                style: TextStyle(
                    fontSize: responsiveFont(10),
                    fontWeight: FontWeight.w600,
                    color: secondaryColor),
              ),
            ),
            accountButton(
                "myorder", AppLocalizations.of(context)!.translate('my_order')!,
                func: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyOrder()));
            }),
            accountButton("wishlist",
                AppLocalizations.of(context)!.translate('wishlist')!, func: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => WishList()));
            }),
            Visibility(
              visible: Provider.of<HomeProvider>(context, listen: false)
                  .showRatingSection,
              child: accountButton(
                  "review", AppLocalizations.of(context)!.translate('review')!,
                  func: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ReviewScreen()));
              }),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 5, left: 15, bottom: 5),
              child: Text(
                AppLocalizations.of(context)!.translate('general_setting')!,
                style: TextStyle(
                    fontSize: responsiveFont(10),
                    fontWeight: FontWeight.w600,
                    color: secondaryColor),
              ),
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              width: 25.w,
                              height: 25.h,
                              child:
                                  Image.asset("images/account/darktheme.png")),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            AppLocalizations.of(context)!
                                .translate('dark_theme')!,
                            style: TextStyle(fontSize: responsiveFont(11)),
                          )
                        ],
                      ),
                      Consumer<AppNotifier>(
                          builder: (context, theme, _) => Switch(
                                value: theme.isDarkMode,
                                onChanged: (value) {
                                  setState(() {
                                    theme.isDarkMode = !theme.isDarkMode;
                                  });
                                  if (theme.isDarkMode) {
                                    theme.setDarkMode();
                                  } else {
                                    theme.setLightMode();
                                  }
                                },
                                activeTrackColor: Colors.lightGreenAccent,
                                activeColor: Colors.green,
                              )),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  height: 2,
                  color: Colors.black12,
                )
              ],
            ),
            accountButton("languange",
                AppLocalizations.of(context)!.translate('title_language')!,
                func: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LanguageScreen()));
            }),
            accountButton(
                "rateapp", AppLocalizations.of(context)!.translate('rate_app')!,
                func: () {
              if (Platform.isIOS) {
                LaunchReview.launch(writeReview: false, iOSAppId: appId);
              } else {
                LaunchReview.launch(
                    androidAppId: generalSettings.packageInfo!.packageName);
              }
            }),
            accountButton(
                "aboutus", AppLocalizations.of(context)!.translate('about_us')!,
                func: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                            url: generalSettings.about.description,
                            title: AppLocalizations.of(context)!
                                .translate('about_us'),
                          )));
            }),
            accountButton(
                "privacy", AppLocalizations.of(context)!.translate('privacy')!,
                func: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                            url: generalSettings.privacy.description,
                            title: AppLocalizations.of(context)!
                                .translate('privacy'),
                          )));
            }),
            accountButton("terms_conditions",
                AppLocalizations.of(context)!.translate('terms_conditions')!,
                func: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                            url: generalSettings.terms.description,
                            title: AppLocalizations.of(context)!
                                .translate('terms_conditions'),
                          )));
            }),
            accountButton(
                "contact", AppLocalizations.of(context)!.translate('contact')!,
                func: () {
              _launchPhoneURL("+" + generalSettings.phone.description!);
            }),
            accountButton(
                "logout", AppLocalizations.of(context)!.translate('logout')!,
                func: logoutPopDialog),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              alignment: Alignment.centerLeft,
              child: FutureBuilder(
                future: _init(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _versionName = snapshot.data as String?;
                    return Text(
                      '${AppLocalizations.of(context)!.translate('version')} ' +
                          _versionName!,
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: responsiveFont(10)),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              // Text(
              //   "${AppLocalizations.of(context).translate('version')} $version",
              //   style: TextStyle(
              //       fontWeight: FontWeight.w300, fontSize: responsiveFont(10)),
              // ),
            )
          ],
        ),
      ),
    );
  }

  Widget accountButton(String image, String title, {var func}) {
    final isDarkMode =
        Provider.of<AppNotifier>(context, listen: false).isDarkMode;
    return Column(
      children: [
        InkWell(
          onTap: func,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    image == "affiliate_detail"
                        ? Icon(Icons.connect_without_contact_rounded)
                        : image == "membership"
                            ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                child: Icon(
                                  FontAwesomeIcons.crown,
                                  color: isDarkMode == false
                                      ? Colors.grey[800]
                                      : Colors.white,
                                  size: 17.h,
                                ),
                              )
                            : Container(
                                width: 25.w,
                                height: 25.h,
                                child: Image.asset(
                                  "images/account/$image.png",
                                  color: isDarkMode ? Colors.white : null,
                                )),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      title,
                      style: TextStyle(fontSize: responsiveFont(11)),
                    )
                  ],
                ),
                Icon(Icons.keyboard_arrow_right)
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          width: double.infinity,
          height: 2,
          color: Colors.black12,
        )
      ],
    );
  }

  Widget buildPointCard() {
    final point = Provider.of<UserProvider>(context, listen: false);
    String fullName =
        "${Session.data.getString('firstname')} ${Session.data.getString('lastname')}";

    String _role = "${Session.data.getString('role') ?? ""}";
    String _membershipPlan =
        "${Session.data.getString('membershipPlan') ?? ""}";

    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

    if (point.point == null) {
      return Container();
    }
    return Container(
        margin: EdgeInsets.only(top: 15, left: 10, right: 10),
        child: Stack(
          children: [
            Image.asset("images/account/card_point.png"),
            Positioned(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  _membershipPlan == ""
                      ? capitalize(_role)
                      : capitalize(_membershipPlan),
                  style: TextStyle(
                      fontSize: responsiveFont(14),
                      color: secondaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              top: 15,
              right: 15,
            ),
            Positioned(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.translate('full_name')!,
                      style: TextStyle(
                          fontSize: responsiveFont(10),
                          color: primaryColor,
                          fontWeight: FontWeight.w400)),
                  Text(
                    fullName.length > 10
                        ? fullName.substring(0, 10) + '... '
                        : fullName,
                    style: TextStyle(
                        fontSize: responsiveFont(18),
                        color: secondaryColor,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
              bottom: 10,
              left: 15,
            ),
            Positioned(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppLocalizations.of(context)!.translate('total_point')!,
                      style: TextStyle(
                          fontSize: responsiveFont(10),
                          color: primaryColor,
                          fontWeight: FontWeight.w400)),
                  point.loading
                      ? Text(
                          '-',
                          style: TextStyle(
                              fontSize: responsiveFont(18),
                              color: secondaryColor,
                              fontWeight: FontWeight.w600),
                        )
                      : Text(
                          '${point.point!.pointsBalance} ${point.point!.pointsLabel}',
                          style: TextStyle(
                              fontSize: responsiveFont(18),
                              color: secondaryColor,
                              fontWeight: FontWeight.w600),
                        )
                ],
              ),
              bottom: 10,
              right: 15,
            )
          ],
        ));
  }

  logoutPopDialog() {
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
                height: 150.h,
                width: 330.w,
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
                          AppLocalizations.of(context)!
                              .translate('logout_body_alert')!,
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
                                onTap: () => logout(),
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
}
