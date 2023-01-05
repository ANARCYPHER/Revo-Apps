import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nyoba/models/checkout_guest_model.dart';
import 'package:nyoba/pages/intro/intro_screen.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/provider/chat_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/wallet_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/custom_page_route.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

class SplashScreen extends StatefulWidget {
  final Future Function()? onLinkClicked;
  SplashScreen({Key? key, this.onLinkClicked}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool loadHomeSuccess = true;
  bool isHaveInternetConnection = false;

  String? _versionName;

  bool isVideo = false;
  late VideoPlayerController _controller;

  Future startSplashScreen() async {
    final home = Provider.of<HomeProvider>(context, listen: false);
    final ext = p.extension(home.splashscreen.image!);
    FlutterNativeSplash.remove();
    printLog(ext, name: 'Extension Splash');
    var duration = Duration(milliseconds: 2500);

    if (ext == '.mp4') {
      var videoDuration;
      setState(() {
        isVideo = true;
      });
      _controller = VideoPlayerController.network(home.splashscreen.image!)
        ..initialize().then((_) {
          setState(() {
            videoDuration = _controller.value.duration;
            printLog(videoDuration.toString(), name: 'DurationVideo');
            duration = videoDuration;
          });
          _controller.play();
          navigateScreen(duration);
        });
    } else if (ext == '.gif') {
      duration = Duration(milliseconds: 5000);
      navigateScreen(duration);
    } else {
      navigateScreen(duration);
    }
  }

  Future navigateScreen(duration) async {
    printLog(duration.toString(), name: 'Duration');
    final home = Provider.of<HomeProvider>(context, listen: false);

    return Timer(duration, () {
      if (!Session.data.containsKey('big_update')) {
        Session.data.setBool('big_update', false);
      }
      if (home.introStatus == 'show') {
        Navigator.of(context).pushReplacement(
          CustomPageRoute(
            direction: AxisDirection.left,
            child: IntroScreen(
              intro: home.intro,
            ),
          ),
        );
      } else {
        if (!Session.data.containsKey('isIntro')) {
          Session.data.setBool('isLogin', false);
          Session.data.setBool('isIntro', false);
        }
        if (!Session.data.containsKey('tool_tip')) {
          Session.data.setBool('tool_tip', true);
        }
        if (home.toolTip) {
          Session.data.setBool('tool_tip', true);
        }
        Session.data.getBool('isIntro')!
            ? Navigator.of(context).pushReplacement(
                CustomPageRoute(
                  direction: AxisDirection.left,
                  child: ShowCaseWidget(
                      builder: Builder(
                    builder: (context) => HomeScreen(),
                  )),
                ),
              )
            : Navigator.of(context).pushReplacement(
                CustomPageRoute(
                  direction: AxisDirection.left,
                  child: IntroScreen(
                    intro: home.intro,
                  ),
                ),
              );
      }
      if (widget.onLinkClicked != null) {
        print("URL Available");
        if (home.introStatus == 'show') {
          Navigator.of(context).pushReplacement(
            CustomPageRoute(
              child: HomeScreen(),
              direction: AxisDirection.left,
            ),
            // MaterialPageRoute(
            //   builder: (_) {
            //     return HomeScreen();
            //   },
            // ),
          );
        }
        widget.onLinkClicked!();
      }
    });
  }

  Future _init() async {
    final _packageInfo = await PackageInfo.fromPlatform();

    context.read<HomeProvider>().setPackageInfo(_packageInfo);

    return _packageInfo.version;
  }

  @override
  void initState() {
    super.initState();
    printLog(widget.onLinkClicked.toString());
    loadHome();
    loadWallet();
    loadUnreadMessage();
    checkInternetConnection();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  checkInternetConnection() {
    InternetConnectionChecker().onStatusChange.listen(
      (event) {
        final hasInternet = event == InternetConnectionStatus.connected;

        setState(() {
          this.isHaveInternetConnection = hasInternet;
        });
      },
    );
  }

  loadUnreadMessage() async {
    if (Session.data.containsKey('isLogin')) {
      if (Session.data.getBool('isLogin')!)
        await Provider.of<ChatProvider>(context, listen: false)
            .checkUnreadMessage();
    }
  }

  loadWallet() async {
    if (Session.data.containsKey('isLogin')) {
      if (Session.data.getBool('isLogin')!)
        await Provider.of<WalletProvider>(context, listen: false)
            .fetchBalance();
    }
  }

  loadHome() async {
    await Provider.of<HomeProvider>(context, listen: false)
        .fetchHome(context)
        .then((value) async {
      if (!Session.data.containsKey('order_guest')) {
        List<CheckoutGuest> listOrder = [];

        Session.data.setString('order_guest', json.encode(listOrder));
      }
      final appColors =
          Provider.of<HomeProvider>(context, listen: false).appColors;
      this.setState(() {
        loadHomeSuccess = value!;
      });
      appColors.forEach((element) {
        setState(() {
          if (element.title == 'primary') {
            primaryColor = HexColor(element.description!);
          } else if (element.title == 'secondary') {
            secondaryColor = HexColor(element.description!);
          } else if (element.title == 'button_color') {
            buttonColor = HexColor(element.description!);
          } else {
            textButtonColor = HexColor(element.description!);
          }
        });
      });
      if (loadHomeSuccess) {
        if (mounted) await startSplashScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = Provider.of<HomeProvider>(context, listen: false);

    return Scaffold(
        body: isHaveInternetConnection
            ? buildNoConnection(context)
            : home.loading
                ? Container()
                : loadHomeSuccess
                    ? isVideo
                        ? videoSplashScreen()
                        : imageSplashScreen()
                    : buildError(context));
  }

  imageSplashScreen() {
    final home = Provider.of<HomeProvider>(context, listen: false);

    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(home.splashscreen.image!))),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    home.splashscreen.title!,
                    style: TextStyle(fontSize: 22, color: Colors.grey),
                  ),
                  Text(
                    home.splashscreen.description!,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: _init(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _versionName = snapshot.data as String?;
                  return Text(
                    'Version ' + _versionName!,
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ));
  }

  videoSplashScreen() {
    return Center(
      child: _controller.value.isInitialized
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: VideoPlayer(_controller),
            )
          : Container(),
    );
  }
}
