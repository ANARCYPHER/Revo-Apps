import 'dart:async';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nyoba/models/login_model.dart';
import 'package:nyoba/models/user_model.dart';
import 'package:nyoba/pages/auth/create_username_screen.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'dart:convert';
import 'package:nyoba/services/login_api.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'home_provider.dart';

class LoginProvider with ChangeNotifier {
  LoginModel? userLogin;
  bool loading = false;
  String? message;
  String? countryCode = '+62';

  Map<String, dynamic>? fbUserData;
  AccessToken? fbAccessToken;

  late FirebaseAuth _firebaseAuth;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<Map<String, dynamic>?> login(context, {username, password}) async {
    var result;
    try {
      loading = true;
      await LoginAPI().loginByDefault(username, password).then((data) {
        result = data;

        if (result['cookie'] != null) {
          UserModel user = UserModel.fromJson(result['user']);
          Session().saveUser(user, result['cookie']);
          Session.data.setString("login_type", 'default');
          final home = Provider.of<HomeProvider>(context, listen: false);

          home.isReload = true;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => HomeScreen()),
              (Route<dynamic> route) => false);
          inputDeviceToken();
        } else {
          snackBar(context, message: result['message'], color: Colors.red);
        }
        loading = false;

        notifyListeners();
        printLog(result.toString());
      });
    } catch (e) {
      print(e.toString());
      loading = false;
      notifyListeners();
      snackBar(context,
          message: 'Opps, something is wrong. Please contact the developer',
          color: Colors.red);
    }
    return result;
  }

  String messageError = "";

  Future<void> signInOTPv2(context, phone, countryCode,
      {username, email, firstname, lastname}) async {
    loading = true;
    notifyListeners();
    await LoginAPI()
        .loginByOTPv2(
      phone,
      countryCode,
      username: username,
      email: email,
      firstname: firstname,
      lastname: lastname,
    )
        .then((data) {
      final response = json.decode(data.body);
      printLog(json.encode(response), name: "response otp");
      messageError = "";
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);
        Session.data.setBool('isLogin', true);
        Session.data.setString("cookie", responseJson['cookie']);
        Session.data.setString("login_type", 'otp');

        if (responseJson['user'] != null &&
            responseJson['user'] != "User OTP") {
          Session.data.setString("firstname", responseJson['user']);
        } else {
          Session.data.setString("firstname", responseJson['user_login']);
        }
        Session.data.setInt("id", responseJson['wp_user_id']);
        final home = Provider.of<HomeProvider>(context, listen: false);

        home.isReload = true;
        loading = false;
        Session.data.remove('cart');
        inputDeviceToken();
        notifyListeners();
      } else if (response['message'].toString() == ("create username first")) {
        messageError = response['message'];
        loading = false;
        notifyListeners();
      } else if (response['message'].toString() ==
          ("username already exist, please try using another username")) {
        messageError = response['message'];
        loading = false;
        notifyListeners();
      } else if (response['message'].toString() ==
          ("email already exist, please try using another email")) {
        messageError = response['message'];
        loading = false;
        notifyListeners();
      } else {
        loading = false;
        notifyListeners();
      }
    });
  }

  Future<void> signInOTP(context, phone, {username}) async {
    loading = true;
    notifyListeners();
    await LoginAPI().loginByOTP(phone, username: username).then((data) {
      final response = json.decode(data.body);
      printLog(json.encode(response), name: "response otp");
      messageError = "";
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);
        Session.data.setBool('isLogin', true);
        Session.data.setString("cookie", responseJson['cookie']);
        Session.data.setString("login_type", 'otp');

        if (responseJson['user'] != null &&
            responseJson['user'] != "User OTP") {
          Session.data.setString("firstname", responseJson['user']);
        } else {
          Session.data.setString("firstname", responseJson['user_login']);
        }
        Session.data.setInt("id", responseJson['wp_user_id']);
        final home = Provider.of<HomeProvider>(context, listen: false);

        home.isReload = true;
        loading = false;
        Session.data.remove('cart');
        inputDeviceToken();
        notifyListeners();
      } else if (response['message'].toString() == ("create username first")) {
        messageError = response['message'];
        loading = false;
        notifyListeners();
      } else if (response['message'].toString() ==
          ("username already exist, please try using another username")) {
        messageError = response['message'];
        loading = false;
        notifyListeners();
      } else if (response['message'].toString() ==
          ("email already exist, please try using another email")) {
        messageError = response['message'];
        loading = false;
        notifyListeners();
      } else {
        loading = false;
        notifyListeners();
      }
    });
  }

  String? token = "";

  Future signInWithGoogle(context, {username}) async {
    loading = true;
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final GoogleSignIn? _googleSignIn = GoogleSignIn();

      GoogleSignInAccount? googleSignInAccount = await _googleSignIn?.signIn();
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        await LoginAPI()
            .loginByGoogle(googleSignInAuthentication.accessToken,
                username: username)
            .then((data) async {
          final responseJson = json.decode(data.body);
          token = googleSignInAuthentication.accessToken;
          messageError = "";
          if (responseJson['message'].toString() == ("create username first")) {
            messageError = responseJson['message'];
            loading = false;
            notifyListeners();
          } else if (responseJson['message'].toString() ==
              ("username already exist, please try using another username")) {
            messageError = responseJson['message'];
            loading = false;
            notifyListeners();
          } else if (responseJson['message'].toString() ==
              ("email already exist, please try using another email")) {
            messageError = responseJson['message'];
            loading = false;
            notifyListeners();
          } else if (data.statusCode == 200) {
            Session.data.setBool('isLogin', true);
            Session.data.setString("cookie", responseJson['cookie']);
            Session.data.setString("username", responseJson['user_login']);
            Session.data.setString("login_type", 'google');

            loading = false;
            final home = Provider.of<HomeProvider>(context, listen: false);
            home.isReload = true;
            await Provider.of<UserProvider>(context, listen: false)
                .fetchUserDetail();
            inputDeviceToken();
            notifyListeners();
            return responseJson;
          } else {
            loading = false;
            notifyListeners();
            return responseJson;
          }
        });
      }
    } catch (e) {
      printLog(e.toString(), name: 'Google SignIn Error');
      loading = false;
      notifyListeners();
      snackBar(context, message: "Google SignIn Cancelled");
    }
  }

  String prettyPrint(Map json) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String pretty = encoder.convert(json);
    return pretty;
  }

  Future<Map<String, dynamic>?> inputDeviceToken() async {
    var result;
    await LoginAPI().inputTokenAPI().then((data) {
      result = data;
      loading = false;
      notifyListeners();
      printLog(result.toString());
    });
    return result;
  }

  Future<bool?> forgotPassword(context, {email}) async {
    bool? isSuccess;
    loading = true;
    var result;
    await LoginAPI().forgotPasswordAPI(email).then((data) {
      result = data;

      if (result['status'] == 'success') {
        isSuccess = true;
      } else {
        isSuccess = false;
        snackBar(context, message: result['message'], color: Colors.red);
      }
      loading = false;

      notifyListeners();
      printLog(result.toString());
    });
    return isSuccess;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple(context, {username}) async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final firebaseAuth = FirebaseAuth.instance;
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    String? userEmail, userName, displayName;

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    printLog(appleCredential.toString(), name: 'Apple Credential');

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    printLog(oauthCredential.toString(), name: 'OAUTH');

    final dynamic authResult = await firebaseAuth
        .signInWithCredential(oauthCredential)
        .then((value) async {
      displayName =
          '${appleCredential.givenName} ${appleCredential.familyName}';
      userName = '${appleCredential.familyName}${appleCredential.familyName}';

      if (appleCredential.email != null) {
        userEmail = '${appleCredential.email}';
        Session.data.setString('email_apple', userEmail!);
      } else {
        userEmail = Session.data.getString('email_apple');
      }

      await LoginAPI()
          .loginByApple(userEmail.toString(), displayName.toString(),
              userName.toString().toLowerCase(),
              username1: username)
          .then((data) {
        printLog(data.toString(), name: 'API Apple SignIn');
        messageError = "";
        if (data['message'].toString() == ("create username first")) {
          messageError = data['message'];
          loading = false;
          notifyListeners();
        } else if (data['message'].toString() ==
            ("username already exist, please try using another username")) {
          messageError = data['message'];
          loading = false;
          notifyListeners();
        } else if (data['message'].toString() ==
            ("email already exist, please try using another email")) {
          messageError = data['message'];
          loading = false;
          notifyListeners();
        } else if (data['wp_user_id'] != null) {
          Session.data.setBool('isLogin', true);
          Session.data.setString("cookie", data['cookie']);
          Session.data.setString("username", data['user_login']);
          Session.data.setString("login_type", 'apple');

          final home = Provider.of<HomeProvider>(context, listen: false);
          home.isReload = true;

          loading = false;
          inputDeviceToken();
          notifyListeners();
          return data;
        } else {
          loading = false;
          notifyListeners();
          return data;
        }
      });
    });
    return authResult;
  }

  Future<void> signInWithFacebook(context, {username}) async {
    loading = true;
    notifyListeners();
    try {
      final LoginResult result = await FacebookAuth.instance
          .login(); // by the fault we request the email and the public profilea

      if (result.status == LoginStatus.success) {
        fbAccessToken = result.accessToken;

        final userData = await FacebookAuth.instance.getUserData();
        fbUserData = userData;
        printLog(prettyPrint(fbAccessToken!.toJson()), name: "facebook");
        await LoginAPI()
            .loginByFacebook(fbAccessToken?.token, username: username)
            .then((data) async {
          final responseJson = json.decode(data.body);
          token = fbAccessToken?.token;
          messageError = "";
          if (responseJson['message'].toString() == ("create username first")) {
            messageError = responseJson['message'];
            loading = false;
            notifyListeners();
          } else if (responseJson['message'].toString() ==
              ("username already exist, please try using another username")) {
            messageError = responseJson['message'];
            loading = false;
            notifyListeners();
          } else if (responseJson['message'].toString() ==
              ("email already exist, please try using another email")) {
            messageError = responseJson['message'];
            loading = false;
            notifyListeners();
          } else if (data.statusCode == 200) {
            Session.data.setBool('isLogin', true);
            Session.data.setString("cookie", responseJson['cookie']);
            Session.data.setString("username", responseJson['user_login']);
            Session.data.setString("login_type", 'facebook');

            final home = Provider.of<HomeProvider>(context, listen: false);
            home.isReload = true;

            loading = false;
            await Provider.of<UserProvider>(context, listen: false)
                .fetchUserDetail();
            inputDeviceToken();
            notifyListeners();
            return responseJson;
          } else {
            loading = false;
            notifyListeners();
            return responseJson;
          }
        });
      } else {
        print(result.status);
        print(result.message);
      }
    } catch (e) {
      printLog(e.toString(), name: 'Error FB SignIn');
      loading = false;
      notifyListeners();
      snackBar(context, message: "Facebook SignIn Cancelled");
    }
  }

  facebookSignOut() async {
    await FacebookAuth.instance.logOut();
    fbAccessToken = null;
    fbUserData = null;
    notifyListeners();
  }
}
