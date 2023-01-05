import 'package:share_plus/share_plus.dart';

import '../app_localizations.dart';

shareLinks(String type, String? url, context, lang) {
  // return Share.share("Let's see our $type, click me $url !");
  if (type == "blog") {
    return Share.share(
        "${AppLocalizations.of(context)!.translate('share_msg')!} ${AppLocalizations.of(context)!.translate('blog')!}, ${AppLocalizations.of(context)!.translate('share_msg2')!} $url !");
  } else if (type == "product") {
    return Share.share(
        "${AppLocalizations.of(context)!.translate('share_msg')!} ${AppLocalizations.of(context)!.translate('product')!}, ${AppLocalizations.of(context)!.translate('share_msg2')!} $url !");
    // return Share.share("Let's see our $type, click me $url !");
  } else if (type == "referal") {
    return Share.share("Share referal $url !");
  }
}
