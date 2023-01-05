import '../app_localizations.dart';

buildNotificationTitle(String status, context) {
  String? title = 'Unknown';

  if (status == 'pending') {
    title = AppLocalizations.of(context)!.translate('title_order_pending');
  } else if (status == 'processing') {
    title = AppLocalizations.of(context)!.translate('title_order_processing');
  } else if (status == 'on-hold') {
    title = AppLocalizations.of(context)!.translate('title_order_on_hold');
  } else if (status == 'completed') {
    title = AppLocalizations.of(context)!.translate('title_order_complete');
  } else if (status == 'cancelled') {
    title = AppLocalizations.of(context)!.translate('title_order_cancel');
  } else if (status == 'refunded') {
    title = AppLocalizations.of(context)!.translate('title_order_refund');
  } else if (status == 'failed') {
    title = AppLocalizations.of(context)!.translate('title_order_failed');
  } else if (status == 'out-for-delivery') {
    title = "Out For Delivery";
  } else if (status == 'driver-assigned') {
    title = "Driver Assigned";
  } else if (status == 'failed-delivery') {
    title = "Failed Delivery";
  } else {
    title = status.replaceAll(RegExp('[^A-Za-z0-9]'), ' ');
  }

  return title;
}

buildNotificationSubtitle(String status, context) {
  var subtitle = 'Unknown';

  if (status == 'pending') {
    subtitle =
        ' ${AppLocalizations.of(context)!.translate('status_order_pending')}';
  } else if (status == 'processing') {
    subtitle =
        ' ${AppLocalizations.of(context)!.translate('status_order_processing')}';
  } else if (status == 'on-hold') {
    subtitle =
        ' ${AppLocalizations.of(context)!.translate('status_order_on_hold')}';
  } else if (status == 'completed') {
    subtitle =
        ' ${AppLocalizations.of(context)!.translate('status_order_complete')}';
  } else if (status == 'cancelled') {
    subtitle =
        ' ${AppLocalizations.of(context)!.translate('status_order_cancel')}';
  } else if (status == 'refunded') {
    subtitle =
        ' ${AppLocalizations.of(context)!.translate('status_order_refund')}';
  } else if (status == 'failed') {
    subtitle =
        ' ${AppLocalizations.of(context)!.translate('status_order_failed')}';
  } else {
    subtitle = ' ${status.replaceAll(RegExp('[^A-Za-z0-9]'), ' ')}';
  }

  return subtitle;
}
