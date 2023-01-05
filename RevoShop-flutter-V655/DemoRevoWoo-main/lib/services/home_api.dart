import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';

class HomeAPI {
  homeDataApi() async {
    String? code = Session.data.getString("language_code");
    String? cookie = Session.data.getString("cookie");
    var response = await baseAPI.getAsync('$homeUrl?cookie=$cookie&lang=$code',
        isCustom: true);
    return response;
  }
}
