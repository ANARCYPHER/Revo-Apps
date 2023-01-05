import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

stringToCurrency(num idr, context) {
  final currencySetting = Provider.of<HomeProvider>(context, listen: false);
  final appLanguage = Provider.of<AppNotifier>(context, listen: false);

  var symbol = 'AED';
  String? code = 'IDR';
  var thousandSeparator = '.';
  var decimalSeparator = ',';
  var decimalNumber = 0;
  bool invertSeparators = false;

  var currencyPos = "left";

  symbol = currencySetting.currency.description != null
      ? convertHtmlUnescape(currencySetting.currency.description!)
      : '';
  code = currencySetting.currency.title;
  decimalNumber = currencySetting.formatCurrency.slug != null
      ? int.parse(currencySetting.formatCurrency.slug!)
      : 0;
  thousandSeparator = currencySetting.formatCurrency.image ?? ".";
  decimalSeparator = currencySetting.formatCurrency.title ?? ",";

  currencyPos = currencySetting.currency.position!;

  if (thousandSeparator == '.' && decimalSeparator == '.') {
    decimalSeparator = ',';
  } else if (thousandSeparator == ',' && decimalSeparator == ',') {
    decimalSeparator = '.';
  }

  var pattern = '';

  if (appLanguage.appLocal == Locale("ar")) {
    if (currencyPos == 'left') {
      if (decimalNumber == 0) {
        pattern = '#$thousandSeparator###S';
      } else if (decimalNumber == 1) {
        pattern = '#$thousandSeparator###${decimalSeparator}0S';
      } else if (decimalNumber == 2) {
        pattern = '#$thousandSeparator###${decimalSeparator}00S';
      } else if (decimalNumber == 3) {
        pattern = '#$thousandSeparator###${decimalSeparator}000S';
      }
    } else if (currencyPos == 'left_space') {
      if (decimalNumber == 0) {
        pattern = '#$thousandSeparator### S';
      } else if (decimalNumber == 1) {
        pattern = '#$thousandSeparator###${decimalSeparator}0 S';
      } else if (decimalNumber == 2) {
        pattern = '#$thousandSeparator###${decimalSeparator}00 S';
      } else if (decimalNumber == 3) {
        pattern = '#$thousandSeparator###${decimalSeparator}000 S';
      }
    } else if (currencyPos == 'right') {
      if (decimalNumber == 0) {
        pattern = 'S#$thousandSeparator###';
      } else if (decimalNumber == 1) {
        pattern = 'S#$thousandSeparator###${decimalSeparator}0';
      } else if (decimalNumber == 2) {
        pattern = 'S#$thousandSeparator###${decimalSeparator}00';
      } else if (decimalNumber == 3) {
        pattern = 'S#$thousandSeparator###${decimalSeparator}000';
      }
    } else if (currencyPos == 'right_space') {
      if (decimalNumber == 0) {
        pattern = 'S #$thousandSeparator###';
      } else if (decimalNumber == 1) {
        pattern = 'S #$thousandSeparator###${decimalSeparator}0';
      } else if (decimalNumber == 2) {
        pattern = 'S #$thousandSeparator###${decimalSeparator}00';
      } else if (decimalNumber == 3) {
        pattern = 'S #$thousandSeparator###${decimalSeparator}000';
      }
    }
  } else {
    if (currencyPos == 'left') {
      if (decimalNumber == 0) {
        pattern = 'S#$thousandSeparator###';
      } else if (decimalNumber == 1) {
        pattern = 'S#$thousandSeparator###${decimalSeparator}0';
      } else if (decimalNumber == 2) {
        pattern = 'S#$thousandSeparator###${decimalSeparator}00';
      } else if (decimalNumber == 3) {
        pattern = 'S#$thousandSeparator###${decimalSeparator}000';
      }
    } else if (currencyPos == 'left_space') {
      if (decimalNumber == 0) {
        pattern = 'S #$thousandSeparator###';
      } else if (decimalNumber == 1) {
        pattern = 'S #$thousandSeparator###${decimalSeparator}0';
      } else if (decimalNumber == 2) {
        pattern = 'S #$thousandSeparator###${decimalSeparator}00';
      } else if (decimalNumber == 3) {
        pattern = 'S #$thousandSeparator###${decimalSeparator}000';
      }
    } else if (currencyPos == 'right') {
      if (decimalNumber == 0) {
        pattern = '#$thousandSeparator###S';
      } else if (decimalNumber == 1) {
        pattern = '#$thousandSeparator###${decimalSeparator}0S';
      } else if (decimalNumber == 2) {
        pattern = '#$thousandSeparator###${decimalSeparator}00S';
      } else if (decimalNumber == 3) {
        pattern = '#$thousandSeparator###${decimalSeparator}000S';
      }
    } else if (currencyPos == 'right_space') {
      if (decimalNumber == 0) {
        pattern = '#$thousandSeparator### S';
      } else if (decimalNumber == 1) {
        pattern = '#$thousandSeparator###${decimalSeparator}0 S';
      } else if (decimalNumber == 2) {
        pattern = '#$thousandSeparator###${decimalSeparator}00 S';
      } else if (decimalNumber == 3) {
        pattern = '#$thousandSeparator###${decimalSeparator}000 S';
      }
    }
  }

  if (thousandSeparator == '.' && decimalSeparator == ',') {
    invertSeparators = true;
  }

  final currency = Currency.create(code!, 3,
      invertSeparators: invertSeparators, symbol: symbol, pattern: pattern);
  final convertedPrice = Money.fromNumWithCurrency(idr, currency);
  return convertedPrice.toString();
}
