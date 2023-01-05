import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/provider/wallet_provider.dart';
import 'package:nyoba/widgets/home/wallet_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/widgets/wallet/wallet_tab_button.dart';
import 'package:nyoba/widgets/wallet/wallet_transaction_item.dart';
import 'package:nyoba/widgets/webview/checkout_webview.dart';
import 'package:nyoba/widgets/webview/wallet_webview.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';
import '../../provider/home_provider.dart';
import '../../services/session.dart';
import '../../utils/utility.dart';
import '../order/order_detail_screen.dart';

class WalletDetail extends StatefulWidget {
  WalletDetail({Key? key}) : super(key: key);

  @override
  _WalletDetailState createState() => _WalletDetailState();
}

class _WalletDetailState extends State<WalletDetail> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<WalletProvider>().reset();
      context.read<WalletProvider>().fetchBalance();
      context.read<WalletProvider>().fetchTransaction();
      context.read<WalletProvider>().webViewWallet('topup');
      context.read<WalletProvider>().webViewWallet('transfer');
    });
  }

  Future onTransferFinished() async {
    context.read<WalletProvider>().fetchBalance();
    context.read<WalletProvider>().fetchTransaction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            // color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.translate('wallet')!,
          style: TextStyle(
            fontSize: responsiveFont(16),
            fontWeight: FontWeight.w500,
            // color: Colors.black
          ),
        ),
      ),
      body: Container(
        child: CustomScrollView(
          physics: ScrollPhysics(),
          slivers: [
            SliverAppBar(
                floating: false,
                snap: false,
                // backgroundColor: Colors.white,
                expandedHeight: 170,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                        child: WalletCard(
                          showBtnMore: false,
                        ),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      WalletTabButton(),
                      SizedBox(
                        height: 10.h,
                      ),
                    ],
                  ),
                )),
            SliverFillRemaining(fillOverscroll: true, child: buildContent())
          ],
        ),
      ),
      // Container(
      //   child: Column(
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.fromLTRB(15, 40, 15, 0),
      //         child: WalletCard(
      //           isFromHome: false,
      //           showBtnMore: false,
      //         ),
      //       ),
      //       SizedBox(
      //         height: 15.h,
      //       ),
      //       WalletTabButton(),
      //       SizedBox(
      //         height: 10.h,
      //       ),
      //       Expanded(child: buildContent())
      //     ],
      //   ),
      // ),
    );
  }

  Widget buildContent() {
    final listTransaction =
        Provider.of<WalletProvider>(context).listTransaction;
    final listDummy = Provider.of<WalletProvider>(context).dummyTransaction;
    final loading = Provider.of<WalletProvider>(context).loadingTransaction;
    final selectedTab = Provider.of<WalletProvider>(context).selectedTab;
    final urlTopUp = Provider.of<WalletProvider>(context).urlTopUp;
    final urlTransfer = Provider.of<WalletProvider>(context).urlTransfer;

    if (selectedTab == "list")
      return listTransaction!.isEmpty
          ? buildTransactionEmpty()
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: loading! ? 6 : listTransaction.length,
              itemBuilder: (context, i) {
                return WalletTransactionItem(
                  transaction: loading ? listDummy![i] : listTransaction[i],
                  loading: loading,
                );
              });
    else if (selectedTab == "topup")
      return CheckoutWebView(
        withAppBar: false,
        url: urlTopUp,
        onFinish: topUpPopDialog,
      );
    else
      return WalletWebView(
        withAppBar: false,
        url: urlTransfer,
        onFinish: onTransferFinished,
      );
  }

  Future topUpPopDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
            child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
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
                                    .translate('topup_success')!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: responsiveFont(14),
                                    fontWeight: FontWeight.w500),
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
                              Container(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: () {
                                    onTransferFinished();
                                    Navigator.pop(context);
                                    Provider.of<WalletProvider>(context,
                                            listen: false)
                                        .onTabChange('list');
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    decoration:
                                        BoxDecoration(color: primaryColor),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('check_wallet')!,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: () {
                                    onTransferFinished();
                                    Provider.of<WalletProvider>(context,
                                            listen: false)
                                        .onTabChange('list');
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => OrderDetail(
                                                  orderId: Session.data
                                                      .getString(
                                                          'order_number'),
                                                )));
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                        ),
                                        color: Colors.white),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('check_order_wallet')!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                        ],
                      ),
                    );
                  },
                )),
            onWillPop: () async => false));
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
