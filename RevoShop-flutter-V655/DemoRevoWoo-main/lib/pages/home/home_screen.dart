import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nyoba/pages/account/account_screen.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/show_case_view.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:upgrader/upgrader.dart';
import '../../app_localizations.dart';
import '../auth/login_screen.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'lobby_screen.dart';
import '../category/category_screen.dart';
import '../order/cart_screen.dart';
import '../blog/blog_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool? isLogin = false;
  Animation<double>? animation;
  late AnimationController controller;
  List<bool> isAnimate = [false, false, false, false, false];
  Timer? _timer;
  late StreamSubscription subscription;
  var isDeviceConnected = false;
  bool isAlertSet = false;

  final GlobalKey globalKeyOne = GlobalKey();
  final GlobalKey globalKeyTwo = GlobalKey();
  final GlobalKey globalKeyThree = GlobalKey();
  final GlobalKey globalKeyFour = GlobalKey();

  static List<Widget> _widgetOptions = [];

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    getConectivity();
    super.initState();
    _widgetOptions = <Widget>[
      LobbyScreen(
        globalKeyTwo: globalKeyTwo,
        globalKeyThree: globalKeyThree,
      ),
      BlogScreen(),
      CategoryScreen(
        isFromHome: true,
      ),
      CartScreen(
        isFromHome: true,
      ),
      AccountScreen()
    ];
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = Tween<double>(begin: 24, end: 24).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0,
          0.150,
          curve: Curves.ease,
        ),
      ),
    );
    if (!Session.data.getBool('big_update')!) {
      Session.data.remove('cart');
      Session.data.setBool('big_update', true);
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print(Session.data.getBool('tool_tip')!);
      if (Session.data.getBool('tool_tip')!) {
        ShowCaseWidget.of(context)
            .startShowCase([globalKeyOne, globalKeyTwo, globalKeyThree]);
      }

      context.read<OrderProvider>().loadCartCount();
    });
  }

  getConectivity() {
    subscription = Connectivity().onConnectivityChanged.listen((event) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!isDeviceConnected && isAlertSet == false) {
        showDialogBox();
        setState(() {
          isAlertSet = true;
        });
      }
    });
  }

  showDialogBox() {
    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => WillPopScope(
        child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            insetPadding: EdgeInsets.all(0),
            content: Builder(
              builder: (context) {
                return Container(
                  height: 220.h,
                  width: 330.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                color: primaryColor),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('warning_internet_connection')!,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 24.h,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('no_internet_connection')!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: responsiveFont(14),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 24.h,
                          ),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context, "Cancel");
                              setState(() {
                                isAlertSet = false;
                              });
                              isDeviceConnected =
                                  await InternetConnectionChecker()
                                      .hasConnection;
                              if (!isDeviceConnected) {
                                showDialogBox();
                                setState(() {
                                  isAlertSet = true;
                                });
                              }
                            },
                            child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.refresh),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Click to Refresh")
                                    ])),
                          )
                        ],
                      )),
                    ],
                  ),
                );
              },
            )),
        onWillPop: () async => false,
      ),
    );
  }

  Future<bool> _onWillPop() {
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
                              .translate('body_exit_alert')!,
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
                                onTap: () => Navigator.of(context).pop(true),
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
    ).then((value) => value as bool);
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
          canDismissDialog: false,
          showIgnore: false,
          showReleaseNotes: false,
          messages: CustomMessages()),
      child: WillPopScope(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                _widgetOptions.elementAt(_selectedIndex),
                // Visibility(
                //     visible: !isDeviceConnected,
                //     child: Container(
                //       color: Colors.black.withOpacity(0.5),
                //       height: double.infinity,
                //       width: double.infinity,
                //     )),
                // Visibility(
                //   visible: !isDeviceConnected,
                //   child: AlertDialog(
                //       contentPadding: EdgeInsets.zero,
                //       shape: RoundedRectangleBorder(
                //           borderRadius:
                //               BorderRadius.all(Radius.circular(15.0))),
                //       insetPadding: EdgeInsets.all(0),
                //       content: Builder(
                //         builder: (context) {
                //           return Container(
                //             height: 150.h,
                //             width: 330.w,
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [
                //                 Container(
                //                     child: Column(
                //                   mainAxisAlignment:
                //                       MainAxisAlignment.spaceBetween,
                //                   children: [
                //                     Container(
                //                       alignment: Alignment.center,
                //                       padding:
                //                           EdgeInsets.symmetric(vertical: 12),
                //                       decoration: BoxDecoration(
                //                           borderRadius: BorderRadius.only(
                //                             topLeft: Radius.circular(15),
                //                             topRight: Radius.circular(15),
                //                           ),
                //                           color: primaryColor),
                //                       child: Text(
                //                         "Warning!",
                //                         style: TextStyle(
                //                             color: Colors.white,
                //                             fontWeight: FontWeight.w500),
                //                       ),
                //                     ),
                //                     SizedBox(
                //                       height: 24.h,
                //                     ),
                //                     Text(
                //                       "No Internet Connection",
                //                       textAlign: TextAlign.center,
                //                       style: TextStyle(
                //                           fontSize: responsiveFont(14),
                //                           fontWeight: FontWeight.w500),
                //                     ),
                //                     SizedBox(
                //                       height: 24.h,
                //                     ),
                //                     // GestureDetector(
                //                     //   onTap: () async {
                //                     //     Navigator.pop(context, "Cancel");
                //                     //     setState(() {
                //                     //       isAlertSet = false;
                //                     //     });
                //                     //     isDeviceConnected =
                //                     //         await InternetConnectionChecker()
                //                     //             .hasConnection;
                //                     //     if (!isDeviceConnected) {
                //                     //       showDialogBox();
                //                     //       setState(() {
                //                     //         isAlertSet = true;
                //                     //       });
                //                     //     }
                //                     //   },
                //                     //   child: Container(
                //                     //     alignment: Alignment.center,
                //                     //     padding: EdgeInsets.symmetric(vertical: 11),
                //                     //     decoration: BoxDecoration(
                //                     //         borderRadius: BorderRadius.only(
                //                     //           bottomLeft: Radius.circular(15),
                //                     //           bottomRight: Radius.circular(15),
                //                     //         ),
                //                     //         color: primaryColor),
                //                     //     child: Text(
                //                     //       "Ok",
                //                     //       style: TextStyle(
                //                     //         color: Colors.white,
                //                     //       ),
                //                     //     ),
                //                     //   ),
                //                     // )
                //                   ],
                //                 )),
                //               ],
                //             ),
                //           );
                //         },
                //       )),
                // ),
              ],
            ),
            bottomNavigationBar: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: controller,
                  builder: bottomNavBar,
                ),
              ],
            ),
          ),
          onWillPop: _onWillPop),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    subscription.cancel();
    super.dispose();
  }

  Widget bottomNavBar(BuildContext context, Widget? child) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 5)]),
      child: BottomAppBar(
        child: Container(
          height: 50.h,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () async {
                    setState(() {
                      isAnimate[0] = true;
                      _animatedFlutterLogoState(0);
                    });
                    await _onItemTapped(0);
                  },
                  child: Container(
                      child: navbarItem(
                          0,
                          // "images/lobby/home.png",
                          // "images/lobby/homeClicked.png",
                          Icon(
                            Icons.home,
                            size: 25.h,
                          ),
                          Icon(
                            Icons.home,
                            size: 25.h,
                          ),
                          AppLocalizations.of(context)!.translate('home')!,
                          28,
                          14)),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isAnimate[1] = true;
                        _animatedFlutterLogoState(1);

                        _onItemTapped(1);
                      });
                    },
                    child: Container(
                        child: navbarItem(
                            1,
                            // "images/lobby/writing.png",
                            // "images/lobby/writingClicked.png",
                            Icon(
                              Icons.rate_review,
                              size: 25.h,
                            ),
                            Icon(
                              Icons.rate_review,
                              size: 25.h,
                            ),
                            AppLocalizations.of(context)!.translate('blog')!,
                            28,
                            14)),
                  )),
              Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isAnimate[2] = true;
                        _animatedFlutterLogoState(2);

                        _onItemTapped(2);
                      });
                    },
                    child: Container(
                        child: navbarItem(
                            2,
                            // "images/lobby/category.png",
                            // "images/lobby/categoryClicked.png",
                            Icon(
                              Icons.widgets,
                              size: 25.h,
                            ),
                            Icon(
                              Icons.widgets,
                              size: 25.h,
                            ),
                            AppLocalizations.of(context)!
                                .translate('category')!,
                            28,
                            14)),
                  )),
              Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isAnimate[3] = true;
                        _animatedFlutterLogoState(3);

                        _onItemTapped(3);
                      });
                    },
                    child: Container(
                        child: navbarItem(
                            3,
                            // "images/lobby/cart.png",
                            // "images/lobby/cartClicked.png",
                            Icon(
                              Icons.shopping_cart,
                              size: 25.h,
                            ),
                            Icon(
                              Icons.shopping_cart,
                              size: 25.h,
                            ),
                            AppLocalizations.of(context)!.translate('cart')!,
                            28,
                            14)),
                  )),
              Expanded(
                  flex: 2,
                  child: ShowCaseView(
                    globalKey: globalKeyOne,
                    index: 0,
                    // shapeBorder: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.all(Radius.circular(100))),
                    description: !Session.data.getBool('isLogin')!
                        ? AppLocalizations.of(context)!.translate('tip_1')!
                        : AppLocalizations.of(context)!
                            .translate('tip_1_login')!,
                    child: InkWell(
                      onTap: () {
                        if (Session.data.getBool('isLogin') != null) {
                          setState(() {
                            isLogin = Session.data.getBool('isLogin');
                          });
                        }
                        if (!isLogin!) {
                          setState(() {
                            _widgetOptions[4] = Login();
                          });
                        } else {
                          setState(() {
                            _widgetOptions[4] = AccountScreen();
                          });
                        }
                        printLog(isLogin.toString(), name: 'isLogin');
                        printLog(Session.data.getBool('isLogin').toString(),
                            name: 'isLoginShared');
                        setState(() {
                          isAnimate[4] = true;
                          _animatedFlutterLogoState(4);

                          _onItemTapped(4);
                        });
                      },
                      child: Container(
                          child: navbarItem(
                              4,
                              // "images/lobby/account.png",
                              // "images/lobby/accountClicked.png",
                              Icon(
                                Icons.person,
                                size: 25.h,
                              ),
                              Icon(
                                Icons.person,
                                size: 25.h,
                              ),
                              AppLocalizations.of(context)!
                                  .translate('account')!,
                              28,
                              14)),
                    ),
                  ))
            ],
          ),
        ),
        shape: CircularNotchedRectangle(),
        elevation: 5,
      ),
    );
  }

  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  _animatedFlutterLogoState(int index) {
    _timer = new Timer(const Duration(milliseconds: 200), () {
      setState(() {
        isAnimate[index] = false;
      });
    });
    return _timer;
  }

  Widget navbarItem(
    int index,
    // String image,
    // String clickedImage,
    Icon icon,
    Icon iconClicked,
    String title,
    int width,
    int smallWidth,
  ) {
    var count = Provider.of<OrderProvider>(context).cartCount;

    final gradientColor = List<Color>.from([primaryColor, secondaryColor]);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 5,
        ),
        Stack(
          children: [
            AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: isAnimate[index] == true ? 0 : 1,
              child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  alignment: Alignment.bottomCenter,
                  width: isAnimate[index] == true ? smallWidth.w : width.w,
                  height: isAnimate[index] == true ? smallWidth.w : width.w,
                  child: _selectedIndex == index
                      ?
                      // Image.asset(clickedImage)
                      ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (rect) => LinearGradient(
                                  colors: gradientColor,
                                  begin: Alignment.topCenter)
                              .createShader(rect),
                          child: icon,
                        )
                      : icon),
            ),
            Visibility(
              child: Positioned(
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(0.2),
                  decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black54, blurRadius: 1)
                      ]),
                  constraints: BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child:
                      Consumer<OrderProvider>(builder: (context, data, child) {
                    return Text(
                      '${data.cartCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }),
                ),
              ),
              visible: index == 3 && count != 0,
            )
          ],
        ),
        Container(
          alignment: Alignment.topCenter,
          child: Text(
            title,
            style: TextStyle(
                fontWeight: _selectedIndex == index
                    ? FontWeight.w600
                    : FontWeight.normal,
                fontSize: responsiveFont(8),
                fontFamily: 'Poppins',
                color: _selectedIndex == index ? primaryColor : null),
          ),
        ),
      ],
    );
  }
}

class CustomMessages extends UpgraderMessages {
  /// Override the message function to provide custom language localization.
  @override
  String? message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.body:
        return 'App Name : {{appName}}\nYour Version : {{currentInstalledVersion}}\nAvailable : {{currentAppStoreVersion}}';
      case UpgraderMessage.buttonTitleIgnore:
        return 'Ignore';
      case UpgraderMessage.buttonTitleLater:
        return 'Later';
      case UpgraderMessage.buttonTitleUpdate:
        return 'Update Now';
      case UpgraderMessage.prompt:
        return 'Would you like to update it now?';
      case UpgraderMessage.title:
        return 'New Version Available';
      case UpgraderMessage.releaseNotes:
        break;
    }
    return null;
    // Messages that are not provided above can still use the default values.
  }
}
