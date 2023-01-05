import 'package:flutter/material.dart';
import 'package:nyoba/provider/wallet_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

class WalletTabButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final listTab =
        Provider.of<WalletProvider>(context, listen: false).tabWallet;
    final selectedTab = Provider.of<WalletProvider>(context).selectedTab;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: GridView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: listTab!.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            crossAxisCount: 3,
            childAspectRatio: 2 / 1),
        itemBuilder: (context, i) {
          return InkWell(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: selectedTab == listTab[i]
                      ? primaryColor
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                Provider.of<WalletProvider>(context)
                    .typeToTitle(listTab[i], context)!,
                style: TextStyle(
                  fontSize: 12,
                    color: selectedTab == listTab[i]
                        ? Colors.white
                        : Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            onTap: () {
              Provider.of<WalletProvider>(context, listen: false).onTabChange(listTab[i]);
            },
          );
        },
      ),
    );
  }
}
