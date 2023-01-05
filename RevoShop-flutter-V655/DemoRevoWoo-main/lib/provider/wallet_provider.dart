import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nyoba/services/session.dart';

import '../app_localizations.dart';
import '../models/wallet_model.dart';
import '../services/wallet_api.dart';
import '../utils/utility.dart';

class WalletProvider with ChangeNotifier {
  List<String>? tabWallet = ['list', 'topup', 'transfer'];
  String? selectedTab = 'list';
  bool? loadingTransaction = true;
  bool? loadingBalance = false;
  bool? isWalletActive = Session.data.getBool('isLogin');
  bool? loadingWeb = true;

  String? walletBalance;
  List<WalletModel>? listTransaction = [];

  String? urlTopUp, urlTransfer;

  List<WalletModel>? dummyTransaction = [
    WalletModel(
        id: '91',
        amount: '100.00000',
        date: '2022-02-22 15:43:04',
        detail: 'Wallet funds transfer to johndoe@example.com',
        type: 'debit'),
    WalletModel(
        id: '90',
        amount: '110.00000',
        date: '2022-02-22 15:43:04',
        detail: 'Gift',
        type: 'credit'),
    WalletModel(
        id: '89',
        amount: '105.00000',
        date: '2022-02-22 15:43:04',
        detail: 'Wallet funds transfer to johndoe@example.com',
        type: 'debit'),
    WalletModel(
        id: '88',
        amount: '300.00000',
        date: '2022-02-22 15:43:04',
        detail: 'TopUp',
        type: 'credit'),
    WalletModel(
        id: '88',
        amount: '300.00000',
        date: '2022-02-22 15:43:04',
        detail: 'TopUp',
        type: 'credit'),
    WalletModel(
        id: '88',
        amount: '300.00000',
        date: '2022-02-22 15:43:04',
        detail: 'TopUp',
        type: 'credit'),
  ];

  String? typeToTitle(String? _type, context) {
    String? _tempTitle = '';
    if (_type == 'list') {
      _tempTitle = AppLocalizations.of(context)?.translate('transaction_list');
    } else if (_type == 'topup') {
      _tempTitle = AppLocalizations.of(context)?.translate('topup');
    } else if (_type == 'transfer') {
      _tempTitle = AppLocalizations.of(context)?.translate('transfer');
    }
    return _tempTitle;
  }

  Future<bool> fetchBalance() async {
    bool _isValid = true;
    try {
      loadingBalance = true;
      await WalletAPI().balance().then((data) {
        if (data.statusCode == 200) {
          final responseJson = json.decode(data.body);

          printLog(responseJson.toString(), name: 'Wallet Balance');

          walletBalance = responseJson;
          isWalletActive = true;
          loadingBalance = false;
          notifyListeners();
        } else {
          print("Load Failed");
          _isValid = false;
          loadingBalance = false;
          isWalletActive = false;
          notifyListeners();
        }
      });
    } catch (e) {
      loadingBalance = false;
      _isValid = false;
      isWalletActive = false;
      notifyListeners();
    }
    return _isValid;
  }

  Future<bool> fetchTransaction() async {
    bool _isValid = true;
    try {
      loadingTransaction = true;
      await WalletAPI().listTransaction().then((data) {
        if (data.statusCode == 200) {
          final responseJson = json.decode(data.body);

          printLog(responseJson.toString(), name: 'Wallet Transaction');

          listTransaction!.clear();
          for (Map item in responseJson) {
            listTransaction!.add(WalletModel.fromJson(item));
          }

          loadingTransaction = false;
          notifyListeners();
        } else {
          print("Load Failed");
          _isValid = false;
          loadingTransaction = false;
          notifyListeners();
        }
      });
    } catch (e) {
      loadingTransaction = false;
      _isValid = false;
      notifyListeners();
    }
    return _isValid;
  }

  Future<bool> webViewWallet(String _type) async {
    bool _isValid = true;
    try {
      loadingWeb = true;
      await WalletAPI().webViewWallet(_type).then((value) async {
        printLog(value, name: 'Link $_type');
        if (_type == 'topup')
          urlTopUp = value;
        else if (_type == 'transfer') urlTransfer = value;
        loadingWeb = false;
        notifyListeners();
      });
    } catch (e) {
      printLog(e.toString(), name: 'Error WebView');
      _isValid = false;
      loadingWeb = false;
      notifyListeners();
    }
    return _isValid;
  }

  Future successTopUp() async {
    selectedTab = 'list';
    notifyListeners();
    fetchBalance();
  }

  onTabChange(value) {
    selectedTab = value;
    notifyListeners();
  }

  Future changeWalletStatus() async {
    isWalletActive = false;
    notifyListeners();
  }

  reset() {
    selectedTab = 'list';
    notifyListeners();
  }
}
