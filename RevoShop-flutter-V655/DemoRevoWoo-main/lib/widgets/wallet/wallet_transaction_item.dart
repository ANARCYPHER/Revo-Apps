import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nyoba/models/wallet_model.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:shimmer/shimmer.dart';

class WalletTransactionItem extends StatelessWidget {
  final WalletModel? transaction;
  final bool? loading;
  WalletTransactionItem({this.transaction, this.loading});

  final f = DateFormat('dd MMMM, yyyy');

  @override
  Widget build(BuildContext context) {
    var _date = f.format(DateTime.parse(transaction!.date!));
    if (loading == true) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListTile(
          title: Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.white),
          ),
          subtitle: Container(
            height: 10,
            width: 15,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.white),
          ),
          trailing: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.white),
          ),
        ),
      );
    }
    return Container(
      child: ListTile(
        title: Text(transaction!.detail!),
        subtitle: Text(_date),
        trailing: Text(
          transaction!.type! == 'credit'
              ? "+${stringToCurrency(double.parse(transaction!.amount!), context)}"
              : "-${stringToCurrency(double.parse(transaction!.amount!), context)}",
          style: TextStyle(
              color:
                  transaction!.type! == 'credit' ? Colors.green : Colors.red),
        ),
      ),
    );
  }
}
