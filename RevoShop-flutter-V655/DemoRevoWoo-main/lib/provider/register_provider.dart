import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nyoba/models/login_model.dart';
import 'package:nyoba/services/register_api.dart';
import 'package:nyoba/utils/utility.dart';

class RegisterProvider with ChangeNotifier {
  LoginModel? userLogin;
  bool loading = false;
  String? message;

  Future<Map<String, dynamic>?> signUp(
      {firstname, lastname, email, username, password}) async {
    var result;
    await RegisterAPI()
        .register(firstname, lastname, email, username, password)
        .then((data) {
      result = data;
      loading = false;
      notifyListeners();
      printLog(result.toString());
    });
    return result;
  }
}
