import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class LoginAPI {
  loginByDefault(String? username, String? password) async {
    Map data = {'username': username, 'password': password};
    var response = await baseAPI.postAsync(
      '$loginDefault',
      data,
      isCustom: true,
    );
    return response;
  }

  loginByOTP(phone, {username}) async {
    var response = await baseAPI.getAsync(
        '$signInOTP?phone=$phone&username=$username',
        isCustom: true,
        printedLog: true);
    return response;
  }

  loginByOTPv2(phone, countryCode,
      {username, email, firstname, lastname}) async {
    String ref = "";
    if (Session.data.containsKey('ref')) {
      ref = Session.data.getString('ref')!;
    }
    printLog(ref, name: "CODE REFERAL");
    var response = await baseAPI.getAsync(
        '$signInOTP/v2?phone=$phone&ref_code=$ref&country_code=$countryCode&username=$username&email=$email&firstname=$firstname&lastname=$lastname',
        isCustom: true,
        printedLog: true);
    return response;
  }

  loginByGoogle(token, {username}) async {
    var response = await baseAPI.getAsync(
        '$signInGoogle?access_token=$token&username=$username',
        isCustom: true,
        printedLog: true);
    return response;
  }

  loginByFacebook(token, {username}) async {
    var response = await baseAPI.getAsync(
        '$signInFacebook?access_token=$token&username=$username',
        isCustom: true);
    return response;
  }

  loginByApple(email, displayName, userName, {username1}) async {
    Map data = {
      'email': email,
      'display_name': displayName,
      'user_name': userName,
      'username': username1
    };
    var response = await baseAPI.postAsync('$signInApple', data,
        isCustom: true, printedLog: true);
    return response;
  }

  inputTokenAPI() async {
    Map data = {
      'token': Session.data.getString('device_token'),
      'cookie': Session.data.getString('cookie')
    };
    printLog(data.toString(), name: 'Token Firebase');
    var response = await baseAPI.postAsync(
      '$inputTokenUrl',
      data,
      isCustom: true,
    );
    return response;
  }

  forgotPasswordAPI(String? email) async {
    Map data = {'email': email};
    var response = await baseAPI.postAsync(
      '$forgotPasswordUrl',
      data,
      isCustom: true,
    );
    return response;
  }
}
