import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/provider/membership_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';
import '../../provider/order_provider.dart';
import '../order/order_success_screen.dart';

class AccountMembershipScreen extends StatefulWidget {
  const AccountMembershipScreen({Key? key}) : super(key: key);

  @override
  State<AccountMembershipScreen> createState() =>
      _AccountMembershipScreenState();
}

class _AccountMembershipScreenState extends State<AccountMembershipScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<MembershipProvider>(context, listen: false).fetchMembership();
  }

  buyNow(ProductModel product) async {
    product.cartQuantity = 1;
    await Provider.of<OrderProvider>(context, listen: false)
        .buyNow(context, onFinishBuyNow: onFinishBuyNow, product: product);
  }

  Future onFinishBuyNow() async {
    //if (mounted) {
    print("masuk sini");
    await Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => OrderSuccess()));
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              // color: Colors.black,
            ),
          ),
          // backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.translate('membership_plan')!,
            style: TextStyle(
              fontSize: responsiveFont(16),
              fontWeight: FontWeight.w500,
              // color: Colors.black,
            ),
          ),
        ),
        body: Consumer<MembershipProvider>(
          builder: (context, value, child) {
            return value.isMembershipLoading
                ? customLoading()
                : Column(
                    children: [
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          AppLocalizations.of(context)!
                              .translate('select_membership')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 29),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: GridView.builder(
                            itemCount: value.listMemberships.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 4 / 6,
                            ),
                            itemBuilder: (context, index) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(value
                                            .listMemberships[index]
                                            .images[0]
                                            .src),
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 60.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                        ),
                                        child: Stack(
                                          children: [
                                            Text(
                                              value.listMemberships[index]
                                                  .productName,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14.h,
                                                fontWeight: FontWeight.bold,
                                                foreground: Paint()
                                                  ..style = PaintingStyle.stroke
                                                  ..strokeWidth = 1
                                                  ..color = Colors.white,
                                              ),
                                            ),
                                            Text(
                                              value.listMemberships[index]
                                                  .productName,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14.h,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(),
                                      ),
                                      Column(
                                        children: [
                                          value
                                                      .listMemberships[index]
                                                      .productMembership
                                                      .status ==
                                                  false
                                              ? SizedBox(
                                                  height: 20.h,
                                                )
                                              : value
                                                          .listMemberships[
                                                              index]
                                                          .productMembership
                                                          .endDate !=
                                                      "unlimited"
                                                  ? Stack(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Text(
                                                              value
                                                                  .listMemberships[
                                                                      index]
                                                                  .productMembership
                                                                  .endDate
                                                                  .toString()
                                                                  .split(" ")
                                                                  .first,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                foreground:
                                                                    Paint()
                                                                      ..style =
                                                                          PaintingStyle
                                                                              .stroke
                                                                      ..strokeWidth =
                                                                          1
                                                                      ..color =
                                                                          Colors
                                                                              .white,
                                                              ),
                                                            ),
                                                            Text(
                                                              value
                                                                  .listMemberships[
                                                                      index]
                                                                  .productMembership
                                                                  .endDate
                                                                  .toString()
                                                                  .split(" ")
                                                                  .first,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                  : Stack(
                                                      children: [
                                                        Text(
                                                          value
                                                              .listMemberships[
                                                                  index]
                                                              .productMembership
                                                              .endDate
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            foreground: Paint()
                                                              ..style =
                                                                  PaintingStyle
                                                                      .stroke
                                                              ..strokeWidth = 1
                                                              ..color =
                                                                  Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          value
                                                              .listMemberships[
                                                                  index]
                                                              .productMembership
                                                              .endDate
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                          Visibility(
                                              visible: value
                                                          .listMemberships[
                                                              index]
                                                          .productMembership
                                                          .status ==
                                                      true &&
                                                  value
                                                          .listMemberships[
                                                              index]
                                                          .productMembership
                                                          .endDate !=
                                                      "unlimited",
                                              child: Stack(
                                                children: [
                                                  Text(
                                                    value
                                                        .listMemberships[index]
                                                        .productMembership
                                                        .endDate
                                                        .toString()
                                                        .split(" ")
                                                        .last,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      foreground: Paint()
                                                        ..style =
                                                            PaintingStyle.stroke
                                                        ..strokeWidth = 1
                                                        ..color = Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    value
                                                        .listMemberships[index]
                                                        .productMembership
                                                        .endDate
                                                        .toString()
                                                        .split(" ")
                                                        .last,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 30.h,
                                      ),
                                      InkWell(
                                        onTap: value.listMemberships[index]
                                                    .productMembership.status ==
                                                false
                                            ? () {
                                                buyNow(value
                                                    .listMemberships[index]);
                                              }
                                            : () {},
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            color: value
                                                        .listMemberships[index]
                                                        .productMembership
                                                        .status ==
                                                    false
                                                ? primaryColor
                                                : secondaryColor,
                                          ),
                                          width: double.infinity,
                                          height: 30.h,
                                          child: Center(
                                            child: Text(
                                                value
                                                            .listMemberships[
                                                                index]
                                                            .productMembership
                                                            .status ==
                                                        false
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .translate('buy')!
                                                    : AppLocalizations.of(
                                                            context)!
                                                        .translate('active')!,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                )),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ));
  }
}
