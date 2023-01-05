import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/widgets/show_case_view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/pages/home/socmed_screen.dart';
import 'package:nyoba/pages/notification/notification_screen.dart';
import 'package:nyoba/pages/order/my_order_screen.dart';
import 'package:nyoba/pages/search/search_screen.dart';
import 'package:nyoba/pages/wishlist/wishlist_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/notification_provider.dart';
import 'package:nyoba/utils/utility.dart';

import '../../services/session.dart';

class HomeAppBar extends StatelessWidget {
  HomeAppBar({
    Key? key,
    required this.globalKeyTwo,
    required this.globalKeyThree,
  }) : super(key: key);
  final GlobalKey globalKeyTwo;
  final GlobalKey globalKeyThree;
  @override
  Widget build(BuildContext context) {
    final animatedText =
        Provider.of<HomeProvider>(context, listen: false).searchBarText;
    final notification =
        Provider.of<NotificationProvider>(context, listen: false)
            .unreadNotification;

    loadNotification() async {
      if (Session.data.getBool('isLogin')!) {
        await Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications();
      }
    }

    return Material(
      elevation: 5,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: primaryColor,
        ),
        child: Container(
          height: 65.h,
          padding: EdgeInsets.only(left: 15, right: 10, top: 15, bottom: 15),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen()));
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width: 200.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: primaryColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            animatedText.description != null
                                ? DefaultTextStyle(
                                    style: TextStyle(
                                        fontSize: responsiveFont(12),
                                        color: Colors.black45),
                                    child: AnimatedTextKit(
                                      isRepeatingAnimation: true,
                                      repeatForever: true,
                                      animatedTexts: [
                                        TyperAnimatedText(
                                            AppLocalizations.of(context)!
                                                .translate('search')!,
                                            speed: Duration(milliseconds: 80)),
                                        if (animatedText.description['text_1']
                                                .isNotEmpty &&
                                            animatedText.description != null)
                                          TyperAnimatedText(animatedText
                                              .description['text_1']),
                                        if (animatedText.description['text_2']
                                                .isNotEmpty &&
                                            animatedText.description != null)
                                          TyperAnimatedText(animatedText
                                              .description['text_2']),
                                        if (animatedText.description['text_3']
                                                .isNotEmpty &&
                                            animatedText.description != null)
                                          TyperAnimatedText(animatedText
                                              .description['text_3']),
                                        if (animatedText.description['text_4']
                                                .isNotEmpty &&
                                            animatedText.description != null)
                                          TyperAnimatedText(animatedText
                                              .description['text_4']),
                                        if (animatedText.description['text_5']
                                                .isNotEmpty &&
                                            animatedText.description != null)
                                          TyperAnimatedText(animatedText
                                              .description['text_5']),
                                      ],
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchScreen()));
                                      },
                                    ),
                                  )
                                : DefaultTextStyle(
                                    style: TextStyle(
                                        fontSize: responsiveFont(12),
                                        color: Colors.black45),
                                    child: AnimatedTextKit(
                                      isRepeatingAnimation: true,
                                      repeatForever: true,
                                      animatedTexts: [
                                        TyperAnimatedText(
                                            AppLocalizations.of(context)!
                                                .translate('search')!,
                                            speed: Duration(milliseconds: 80)),
                                      ],
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchScreen()));
                                      },
                                    ),
                                  ),
                          ],
                        )),
                  )),
              Container(
                width: 10.w,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SocmedScreen()));
                    },
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: 23.w,
                        child: Image.asset("images/lobby/icon-cs-app-bar.png")),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => WishList()));
                    },
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: 27.w,
                        child: Image.asset("images/lobby/heart.png")),
                  ),
                  Visibility(
                    visible: Session.data.getBool('tool_tip')!,
                    child: ShowCaseView(
                      globalKey: globalKeyTwo,
                      index: 1,
                      description:
                          AppLocalizations.of(context)!.translate('tip_2')!,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyOrder()));
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          height: 27.h,
                          width: 27.w,
                          child: Image.asset(
                            "images/lobby/document.png",
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !Session.data.getBool('tool_tip')!,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MyOrder()));
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        height: 27.h,
                        width: 27.w,
                        child: Image.asset(
                          "images/lobby/document.png",
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: Session.data.getBool('tool_tip')!,
                    child: ShowCaseView(
                      globalKey: globalKeyThree,
                      index: 2,
                      description:
                          AppLocalizations.of(context)!.translate('tip_3')!,
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationScreen()));
                          loadNotification();
                        },
                        child: Stack(
                          children: [
                            Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                width: 27.w,
                                child: Image.asset(
                                  "images/lobby/bellRinging.png",
                                )),
                            Visibility(
                              visible: notification.isNotEmpty &&
                                  Session.data.getBool('isLogin')!,
                              child: Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: HexColor("960000"),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      notification.length > 99
                                          ? "99+"
                                          : notification.length.toString(),
                                      style: TextStyle(
                                          fontSize: notification.length > 99
                                              ? 6.h
                                              : 8.h,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !Session.data.getBool('tool_tip')!,
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationScreen()));
                        loadNotification();
                      },
                      child: Stack(
                        children: [
                          Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              width: 27.w,
                              child: Image.asset(
                                "images/lobby/bellRinging.png",
                              )),
                          Visibility(
                            visible: notification.isNotEmpty &&
                                Session.data.getBool('isLogin')!,
                            child: Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: HexColor("960000"),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    notification.length > 99
                                        ? "99+"
                                        : notification.length.toString(),
                                    style: TextStyle(
                                        fontSize: notification.length > 99
                                            ? 6.h
                                            : 8.h,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
