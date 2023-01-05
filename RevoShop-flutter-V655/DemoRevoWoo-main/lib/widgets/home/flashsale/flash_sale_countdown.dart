import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:nyoba/pages/product/product_more_screen.dart';
import 'package:nyoba/provider/flash_sale_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/flashsale/flash_sale_container.dart';
import 'package:provider/provider.dart';

import '../../../app_localizations.dart';
import '../../../models/product_model.dart';

class FlashSaleCountdown extends StatelessWidget {
  final List<dynamic>? dataFlashSaleCountDown;
  final List<ProductModel>? dataFlashSaleProducts;
  final AnimationController? colorAnimationController;
  final AnimationController? textAnimationController;

  final bool? loading;
  final Animation? colorTween, titleColorTween, iconColorTween, moveTween;

  FlashSaleCountdown(
      {Key? key,
      this.dataFlashSaleCountDown,
      this.dataFlashSaleProducts,
      this.colorAnimationController,
      this.textAnimationController,
      this.colorTween,
      this.titleColorTween,
      this.iconColorTween,
      this.moveTween,
      this.loading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flashSale = Provider.of<FlashSaleProvider>(context, listen: false);
    int endTime, timeNow;

    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 30;
    timeNow = DateTime.now().millisecondsSinceEpoch + 1000 * 30;
    if (dataFlashSaleCountDown != null &&
        !loading! &&
        dataFlashSaleCountDown!.isNotEmpty) {
      endTime = DateTime.parse(dataFlashSaleCountDown![0].endDate)
          .millisecondsSinceEpoch;
    }
    if (dataFlashSaleCountDown!.isEmpty || endTime < timeNow) {
      return Container();
    }

    return Consumer<HomeProvider>(builder: (context, value, _) {
      if (value.loading) {
        return customLoading();
      }
      return Column(
        children: [
          !value.loading
              ? Visibility(
                  visible:
                      dataFlashSaleCountDown!.isNotEmpty && endTime > timeNow,
                  child: CountdownTimer(
                    endTime: endTime,
                    widgetBuilder: (_, CurrentRemainingTime? time) {
                      if (time == null) {
                        value.fetchHome(context);
                        return Container();
                      } else {
                        int? hours = time.hours ?? 0;
                        if (time.days != null && time.days != 0) {
                          hours = (time.days! * 24) + time.hours!;
                        } else if (time.hours != null) {
                          hours = time.hours;
                        } else if (time.hours == null) {
                          hours = 0;
                        } else if (time.hours == null &&
                            time.min == null &&
                            time.sec == null) {
                          flashSale.fetchFlashSale();
                          return Text('Flash Sale END');
                        }
                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  left: 15, bottom: 6, right: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .translate('flashsale')!,
                                    style: TextStyle(
                                        fontSize: responsiveFont(14),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductMoreScreen(
                                                    include: flashSale
                                                        .flashSales[0].products,
                                                    name: 'FLASH SALE',
                                                  )));
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('more')!,
                                      style: TextStyle(
                                          fontSize: responsiveFont(12),
                                          fontWeight: FontWeight.w600,
                                          color: secondaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 30,
                              margin: EdgeInsets.only(left: 15, bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                      width: responsiveFont(24),
                                      height: responsiveFont(24),
                                      child: Icon(
                                        Icons.electric_bolt_sharp,
                                        color: primaryColor,
                                      )
                                      // Image.asset("images/lobby/thunder.png")
                                      ),
                                  Container(
                                    width: 10,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: secondaryColor,
                                        borderRadius: BorderRadius.circular(5)),
                                    width: hours! < 100 ? 30 : 40,
                                    child: Text(
                                      hours < 10 ? "0$hours" : "$hours",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: responsiveFont(10)),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: responsiveFont(12)),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        color: secondaryColor,
                                        borderRadius: BorderRadius.circular(5)),
                                    width: 25,
                                    child: Text(
                                      time.min == null
                                          ? "00"
                                          : time.min! < 10
                                              ? "0${time.min}"
                                              : "${time.min}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: responsiveFont(10)),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: responsiveFont(12)),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        color: secondaryColor,
                                        borderRadius: BorderRadius.circular(5)),
                                    width: 25,
                                    child: Text(
                                      time.sec! < 10
                                          ? "0${time.sec}"
                                          : "${time.sec}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: responsiveFont(10)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            !value.loading
                                ? FlashSaleContainer(
                                    textAnimationController:
                                        textAnimationController,
                                    colorAnimationController:
                                        colorAnimationController,
                                    colorTween: colorTween,
                                    iconColorTween: iconColorTween,
                                    moveTween: moveTween,
                                    titleColorTween: titleColorTween,
                                    dataProducts: dataFlashSaleProducts,
                                    loading: loading,
                                    customImage:
                                        dataFlashSaleCountDown![0].image,
                                  )
                                : Container(),
                          ],
                        );
                      }
                    },
                  ))
              : Container(),
          //flash sale countdown & card product item
        ],
      );
    });
  }
}
