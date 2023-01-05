import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/pages/chat/chat_page.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/chat_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/wallet_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ChatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loading = Provider.of<WalletProvider>(context).loadingBalance;
    final isChatActive = Provider.of<HomeProvider>(context).isChatActive;
    final unread = Provider.of<ChatProvider>(context).checkUnread;
    final lastMessage = Provider.of<ChatProvider>(context).lastMessage;
    final isDarkMode = Provider.of<AppNotifier>(context).isDarkMode;

    if (loading! && isChatActive)
      return Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 15),
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 40.h,
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
        child: Shimmer.fromColors(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      child: Image(
                        image: AssetImage("images/lobby/icon-cs-app-bar.png"),
                        height: 30.h,
                      ),
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [primaryColor, primaryColor],
                          stops: [
                            0.0,
                            0.5,
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      width: 150,
                      height: 20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                  ],
                ),
                Visibility(
                  visible: true,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          baseColor: Colors.grey[500]!,
          highlightColor: Colors.grey[100]!,
        ),
      );

    // if (!isWalletActive!) return Container();

    return Visibility(
        visible: Session.data.getBool('isLogin')! &&
            !loading &&
            isChatActive &&
            unread,
        child: Container(
          margin: EdgeInsets.only(left: 15, right: 15, top: 15),
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 40.h,
          decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey : Colors.grey[200],
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    ShaderMask(
                      child: Image(
                        image: AssetImage("images/lobby/icon-cs-app-bar.png"),
                        height: 18.h,
                      ),
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [primaryColor, primaryColor],
                          stops: [
                            0.0,
                            0.5,
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.translate("chat")!,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: responsiveFont(10)),
                          ),
                          Container(
                            width: 180.w,
                            child: Text(
                              lastMessage,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: responsiveFont(10)),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Visibility(
                  visible: true,
                  child: SizedBox(
                      height: 26.h,
                      child: InkWell(
                        child: Icon(
                          Icons.open_in_new,
                          color: isDarkMode ? Colors.black : Colors.grey,
                        ),
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatPage()))
                              .then((value) async {
                            await Provider.of<ChatProvider>(context,
                                    listen: false)
                                .checkUnreadMessage();
                          });
                        },
                      )))
            ],
          ),
        ));
  }
}
