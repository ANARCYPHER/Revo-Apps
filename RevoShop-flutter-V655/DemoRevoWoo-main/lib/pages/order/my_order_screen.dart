import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/models/checkout_guest_model.dart';
import 'package:nyoba/models/order_model.dart';
import 'package:nyoba/pages/order/order_detail_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/widgets/order/order_list_shimmer.dart';
import 'package:nyoba/widgets/webview/checkout_webview.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../app_localizations.dart';
import '../../utils/utility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyOrder extends StatefulWidget {
  MyOrder({Key? key}) : super(key: key);

  @override
  _MyOrderState createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  String currentStatus = '';
  TextEditingController searchController = new TextEditingController();

  String search = '';
  int currType = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final ScrollController _scrollController = ScrollController();

  List<CheckoutGuest>? listOrderGuest = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          context.read<OrderProvider>().tempOrder.length % 10 == 0) {
        debugPrint("Load Data From Scroll");
        loadListOrder();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<OrderProvider>().resetPage();
      debugPrint("Load Data From Init");
      loadListOrder();
      loadListOrderGuest();
    });
  }

  loadNewListOrder() {
    context.read<OrderProvider>().resetPage();
    this.setState(() {});
    if (Session.data.getBool('isLogin')!) {
      if (isNumeric(search)) {
        context
            .read<OrderProvider>()
            .fetchOrders(status: currentStatus, orderId: search)
            .then((value) => this.setState(() {}));
      } else {
        context
            .read<OrderProvider>()
            .fetchOrders(status: currentStatus, search: search)
            .then((value) => this.setState(() {}));
      }
      _refreshController.refreshCompleted();
    }
  }

  loadListOrder() {
    this.setState(() {});
    if (Session.data.getBool('isLogin')!) {
      if (isNumeric(search)) {
        context
            .read<OrderProvider>()
            .fetchOrders(status: currentStatus, orderId: search)
            .then((value) => this.setState(() {}));
      } else {
        context
            .read<OrderProvider>()
            .fetchOrders(status: currentStatus, search: search)
            .then((value) => this.setState(() {}));
      }
      _refreshController.refreshCompleted();
    }
  }

  loadListOrderGuest() {
    final guestCheckoutActive =
        Provider.of<HomeProvider>(context, listen: false).guestCheckoutActive;
    this.setState(() {});
    if (!Session.data.getBool('isLogin')! && guestCheckoutActive) {
      if (Session.data.containsKey('order_guest')) {
        List orders = json.decode(Session.data.getString('order_guest')!);

        listOrderGuest =
            orders.map((order) => new CheckoutGuest.fromJson(order)).toList();
      }
    }
  }

  bool isNumeric(String s) {
    return int.tryParse(s) != null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.select((OrderProvider n) => n);
    final guestCheckoutActive =
        Provider.of<HomeProvider>(context, listen: false).guestCheckoutActive;

    Widget buildOrders = SmartRefresher(
      controller: _refreshController,
      scrollController: _scrollController,
      onRefresh: loadNewListOrder,
      child: Container(
        child: ListenableProvider.value(
          value: orders,
          child: Consumer<OrderProvider>(builder: (context, value, child) {
            if (value.isLoading && value.orderPage == 1) {
              return OrderListShimmer();
            }
            if (value.listOrder.isEmpty) {
              return buildTransactionEmpty();
            }
            printLog(value.listOrder.length.toString(), name: "length order");
            return ListView.builder(
                itemCount: value.listOrder.length,
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemBuilder: (context, i) {
                  return orderItem(value.listOrder[i]);
                });
          }),
        ),
      ),
    );

    Widget buildGuestOrders = Container(
      child: listOrderGuest!.isEmpty
          ? buildTransactionEmpty()
          : ListView.builder(
              itemCount: listOrderGuest!.length,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemBuilder: (context, i) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      print(listOrderGuest![i].url);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CheckoutWebView(
                                    url: listOrderGuest![i].url,
                                    fromMyOrder: true,
                                  )));
                    },
                    leading: Text((i + 1).toString()),
                    title: Text("#${listOrderGuest![i].orderId.toString()}"),
                    subtitle: Text(listOrderGuest![i].createdAt!),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                );
              }),
    );

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            // color: Colors.black,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.translate('my_order')!,
          style: TextStyle(
            // color: Colors.black,
            fontSize: responsiveFont(16),
          ),
        ),
      ),
      body: !Session.data.getBool('isLogin')! && guestCheckoutActive
          ? buildGuestOrders
          : !Session.data.getBool('isLogin')! && !guestCheckoutActive
              ? Center(
                  child: buildNoAuth(context),
                )
              : Container(
                  margin: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Container(
                        height: 30.h,
                        child: TextField(
                          controller: searchController,
                          style: TextStyle(fontSize: 14),
                          textAlignVertical: TextAlignVertical.center,
                          onSubmitted: (value) {
                            setState(() {});
                            context.read<OrderProvider>().resetPage();
                            loadListOrder();
                          },
                          onChanged: (value) {
                            setState(() {
                              search = value;
                            });
                          },
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            isDense: true,
                            isCollapsed: true,
                            filled: true,
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(5),
                              ),
                            ),
                            prefixIcon: Icon(Icons.search),
                            hintText: AppLocalizations.of(context)!
                                .translate('search_transaction'),
                            hintStyle: TextStyle(fontSize: responsiveFont(12)),
                          ),
                        ),
                      ),
                      Container(
                        height: 15,
                      ),
                      buildTabStatus(),
                      Container(
                        height: 10,
                      ),
                      Expanded(
                        child: buildOrders,
                      ),
                      if (orders.orderPage != 1 &&
                          orders.tempOrder.length % 10 == 0 &&
                          orders.isLoading)
                        Center(
                          child: customLoading(),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget orderItem(OrderModel orderModel) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: HexColor("c4c4c4")),
                  height: 50.h,
                  width: 50.h,
                  child: orderModel.productItems![0].image == null &&
                          orderModel.productItems![0].image == ''
                      ? Icon(
                          Icons.image_not_supported_outlined,
                        )
                      : CachedNetworkImage(
                          imageUrl: orderModel.productItems![0].image!,
                          placeholder: (context, url) => Container(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.image_not_supported_outlined)),
                ),
                Container(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        convertHtmlUnescape(
                            orderModel.productItems![0].productName!),
                        style: TextStyle(
                            fontSize: responsiveFont(12),
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${orderModel.productItems![0].quantity} ${AppLocalizations.of(context)!.translate('search_transaction')}",
                        style: TextStyle(fontSize: responsiveFont(10)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Visibility(
            visible: orderModel.productItems!.length > 1,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "+${orderModel.productItems!.length - 1} ${AppLocalizations.of(context)!.translate('other_product')}",
                style: TextStyle(fontSize: responsiveFont(10)),
              ),
            ),
          ),
          Container(
            height: 5,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('total_cost')!,
                      style: TextStyle(fontSize: responsiveFont(9)),
                    ),
                    Text(
                      stringToCurrency(
                          double.parse(orderModel.total!), context),
                      style: TextStyle(
                          fontSize: responsiveFont(10),
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [primaryColor, secondaryColor])),
                  height: 30.h,
                  child: TextButton(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrderDetail(
                                    orderId: orderModel.id.toString(),
                                  ))).then((value) {
                        // this.loadListOrder();
                      });
                    },
                    child: Text(
                      AppLocalizations.of(context)!.translate('more_detail')!,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: responsiveFont(10),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${AppLocalizations.of(context)!.translate('order_id')} : ",
                      style: TextStyle(
                        fontSize: responsiveFont(10),
                      ),
                    ),
                    Text("${orderModel.id}"),
                    Text(
                      convertDateFormatShortMonth(
                          DateTime.parse(orderModel.dateCreated!)),
                      style: TextStyle(
                          fontSize: responsiveFont(8),
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                buildStatusOrder(orderModel.status)
              ],
            ),
          ),
          Container(
            color: HexColor("c4c4c4"),
            height: 1,
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 10),
          ),
        ],
      ),
    );
  }

  Widget buildStatusOrder(String? status) {
    var color = 'FFFFFF';
    var colorText = 'FFFFFF';
    var statusText = '';

    if (status == 'pending') {
      color = 'FFCDD2';
      colorText = 'B71C1C';
      statusText = AppLocalizations.of(context)!.translate('pending')!;
    } else if (status == 'on-hold') {
      color = 'FFF9C4';
      colorText = 'F57F17';
      statusText = AppLocalizations.of(context)!.translate('on_hold')!;
    } else if (status == 'processing') {
      color = 'FFF9C4';
      colorText = 'F57F17';
      statusText = AppLocalizations.of(context)!.translate('processing')!;
    } else if (status == 'completed') {
      color = 'C8E6C9';
      colorText = '1B5E20';
      statusText = AppLocalizations.of(context)!.translate('completed')!;
    } else if (status == 'cancelled') {
      color = 'CFD8DC';
      colorText = '333333';
      statusText = AppLocalizations.of(context)!.translate('cancel')!;
    } else if (status == 'refunded') {
      color = 'B2EBF2';
      colorText = '006064';
      statusText = AppLocalizations.of(context)!.translate('refunded')!;
    } else if (status == 'failed') {
      color = 'FFCCBC';
      colorText = 'BF360C';
      statusText = AppLocalizations.of(context)!.translate('failed')!;
    }

    return Container(
      color: HexColor(color),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: Text(
        statusText,
        style:
            TextStyle(fontSize: responsiveFont(10), color: HexColor(colorText)),
      ),
    );
  }

  Widget buildTabStatus() {
    return Container(
      height: 65.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                currType = 0;
                currentStatus = '';
              });
              context.read<OrderProvider>().resetPage();
              loadListOrder();
            },
            child: Container(
              width: 70.w,
              height: 60.h,
              child: Column(
                children: [
                  Container(
                      width: 30.w,
                      height: 30.h,
                      child: currType == 0
                          ? Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Image.asset("images/order/all.png"))
                          : Image.asset("images/order/all_dark.png")),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate('all_transaction')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: responsiveFont(7.5)),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                currType = 1;
                currentStatus = 'pending';
              });
              context.read<OrderProvider>().resetPage();
              loadListOrder();
            },
            child: Container(
              width: 70.w,
              height: 60.h,
              child: Column(
                children: [
                  Container(
                      width: 30.w,
                      height: 30.h,
                      child: currType == 1
                          ? Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Image.asset("images/order/pending.png"))
                          : Image.asset("images/order/pending_dark.png")),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate('pending')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: responsiveFont(8)),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                currType = 2;
                currentStatus = 'on-hold';
              });
              context.read<OrderProvider>().resetPage();
              loadListOrder();
            },
            child: Container(
              width: 70.w,
              height: 60.h,
              child: Column(
                children: [
                  Container(
                      width: 30.w,
                      height: 30.h,
                      child: currType == 2
                          ? Container(
                              child: Image.asset("images/order/hold.png"),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            )
                          : Image.asset("images/order/hold_dark.png")),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate('on_hold')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: responsiveFont(8)),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                currType = 3;
                currentStatus = 'processing';
              });
              context.read<OrderProvider>().resetPage();
              loadListOrder();
            },
            child: Container(
              width: 70.w,
              height: 60.h,
              child: Column(
                children: [
                  Container(
                      width: 30.w,
                      height: 30.h,
                      child: currType == 3
                          ? Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Image.asset("images/order/processing.png"))
                          : Image.asset("images/order/processing_dark.png")),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate('processing')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: responsiveFont(8)),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                currType = 4;
                currentStatus = 'completed';
              });
              context.read<OrderProvider>().resetPage();
              loadListOrder();
            },
            child: Container(
              width: 70.w,
              height: 60.h,
              child: Column(
                children: [
                  Container(
                      width: 30.w,
                      height: 30.h,
                      child: currType == 4
                          ? Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Image.asset("images/order/completed.png"))
                          : Image.asset("images/order/completed_dark.png")),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate('completed')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: responsiveFont(8)),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                currType = 5;
                currentStatus = 'cancelled';
              });
              context.read<OrderProvider>().resetPage();
              loadListOrder();
            },
            child: Container(
              width: 70.w,
              height: 60.h,
              child: Column(
                children: [
                  Container(
                      width: 30.w,
                      height: 30.h,
                      child: currType == 5
                          ? Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Image.asset("images/order/cancel.png"))
                          : Image.asset("images/order/cancel_dark.png")),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate('cancel')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: responsiveFont(8)),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                currType = 6;
                currentStatus = 'refunded';
              });
              context.read<OrderProvider>().resetPage();
              loadListOrder();
            },
            child: Container(
              width: 70.w,
              height: 60.h,
              child: Column(
                children: [
                  Container(
                      width: 30.w,
                      height: 30.h,
                      child: currType == 6
                          ? Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Image.asset("images/order/refund.png"))
                          : Image.asset("images/order/refund_dark.png")),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate('refunded')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: responsiveFont(8)),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                currType = 7;
                currentStatus = 'failed';
              });
              context.read<OrderProvider>().resetPage();
              loadListOrder();
            },
            child: Container(
              width: 70.w,
              height: 60.h,
              child: Column(
                children: [
                  Container(
                      width: 30.w,
                      height: 30.h,
                      child: currType == 7
                          ? Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Image.asset("images/order/failed.png"))
                          : Image.asset("images/order/failed_dark.png")),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate('failed')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: responsiveFont(8)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildTransactionEmpty() {
    final noTransaction =
        Provider.of<HomeProvider>(context, listen: false).imageNoTransaction;
    return Center(
      child: Column(
        children: [
          noTransaction.image == null
              ? Icon(
                  Icons.shopping_cart,
                  color: primaryColor,
                  size: 75,
                )
              : CachedNetworkImage(
                  imageUrl: noTransaction.image!,
                  height: MediaQuery.of(context).size.height * 0.4,
                  placeholder: (context, url) => Container(),
                  errorWidget: (context, url, error) => Icon(
                        Icons.shopping_cart,
                        color: primaryColor,
                        size: 75,
                      )),
          Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              AppLocalizations.of(context)!.translate('no_transaction')!,
              style: TextStyle(
                  fontSize: responsiveFont(14), fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }
}
