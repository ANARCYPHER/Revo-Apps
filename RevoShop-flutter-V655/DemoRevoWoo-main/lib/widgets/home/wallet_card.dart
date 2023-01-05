import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/pages/wallet/wallet_detail_screen.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/wallet_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_localizations.dart';

class WalletCard extends StatelessWidget {
  final bool? showBtnMore;

  WalletCard({this.showBtnMore});

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<WalletProvider>(context).walletBalance;
    final loading = Provider.of<WalletProvider>(context).loadingBalance;
    final isWalletActive = Provider.of<HomeProvider>(context).isWalletActive;
    final isDarkMode = Provider.of<AppNotifier>(context).isDarkMode;

    if (loading! && isWalletActive)
      return Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 15),
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Shimmer.fromColors(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      child: Image(
                        image: AssetImage("images/lobby/wallet.png"),
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
                      width: 30,
                      height: 20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      width: 90,
                      height: 20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white),
                    ),
                  ],
                ),
                Visibility(
                  visible: showBtnMore!,
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

    if (!isWalletActive) return Container();

    return Visibility(
        visible: Session.data.getBool('isLogin')! && isWalletActive && !loading,
        child: Container(
          margin: EdgeInsets.only(left: 15, right: 15, top: 15),
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 40.h,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    ShaderMask(
                      child: Image(
                        image: AssetImage("images/lobby/wallet.png"),
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
                            AppLocalizations.of(context)!
                                .translate('wallet')!
                                .toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: responsiveFont(10)),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            stringToCurrency(
                                double.parse(balance ?? "0"), context),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: responsiveFont(10),
                                fontWeight: FontWeight.w700),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Visibility(
                  visible: showBtnMore!,
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
                                  builder: (context) => WalletDetail()));
                        },
                      )))
            ],
          ),
        ));
  }
}
