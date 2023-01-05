import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/login_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

class CreateUsernameScreen extends StatefulWidget {
  String? phone;
  String? from;
  String? countryCode;
  CreateUsernameScreen(
      {Key? key, this.phone, this.from, this.countryCode = '62'})
      : super(key: key);

  @override
  State<CreateUsernameScreen> createState() => _CreateUsernameScreenState();
}

class _CreateUsernameScreenState extends State<CreateUsernameScreen> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController username = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController firstName = new TextEditingController();
  TextEditingController lastName = new TextEditingController();

  bool validate = false;

  @override
  Widget build(BuildContext context) {
    final authLogin = Provider.of<LoginProvider>(context, listen: false);

    login(BuildContext context) async {
      if (username.text.isNotEmpty &&
          firstName.text.isNotEmpty &&
          lastName.text.isNotEmpty) {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        if (widget.from == "otp") {
          if (email.text.isNotEmpty) {
            if (email.text.contains(" ") ||
                !email.text.contains('@') ||
                !email.text.contains('.')) {
              snackBar(context, message: 'Please enter a valid email');
            } else {
              await Provider.of<LoginProvider>(context, listen: false)
                  .signInOTPv2(
                context,
                widget.phone,
                widget.countryCode,
                username: username.text,
                email: email.text,
                firstname: firstName.text,
                lastname: lastName.text,
              )
                  .then((value) {
                printLog(
                    Provider.of<LoginProvider>(context, listen: false)
                        .messageError
                        .toString(),
                    name: "Error");
                if (Provider.of<LoginProvider>(context, listen: false)
                        .messageError ==
                    "username already exist, please try using another username") {
                  printLog("masuk validate username");
                  validate = true;
                  snackBar(context,
                      message:
                          'username already exist, please try using another username');
                } else if (Provider.of<LoginProvider>(context, listen: false)
                        .messageError ==
                    "email already exist, please try using another email") {
                  printLog("masuk validate email");
                  validate = true;
                  snackBar(context,
                      message:
                          'email already exist, please try using another email');
                } else if (Session.data.getString('cookie') != null) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomeScreen()),
                      (Route<dynamic> route) => false);
                }
                setState(() {
                  //isSuccess = value;
                });
              });
            }
          } else {
            await Provider.of<LoginProvider>(context, listen: false)
                .signInOTPv2(
              context,
              widget.phone,
              widget.countryCode,
              username: username.text,
              email: email.text,
              firstname: firstName.text,
              lastname: lastName.text,
            )
                .then((value) {
              if (Provider.of<LoginProvider>(context, listen: false)
                      .messageError ==
                  "username already exist, please try using another username") {
                printLog("masuk validate username");
                validate = true;
                snackBar(context,
                    message:
                        'username already exist, please try using another username');
              } else if (Provider.of<LoginProvider>(context, listen: false)
                      .messageError ==
                  "email already exist, please try using another email") {
                printLog("masuk validate email");
                validate = true;
                snackBar(context,
                    message:
                        'email already exist, please try using another email');
              } else if (Session.data.getString('cookie') != null) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomeScreen()),
                    (Route<dynamic> route) => false);
              }
              setState(() {
                //isSuccess = value;
              });
            });
          }
        } else if (widget.from == "google") {
          await Provider.of<LoginProvider>(context, listen: false)
              .signInWithGoogle(context, username: username.text)
              .then((value) {
            if (Provider.of<LoginProvider>(context, listen: false)
                    .messageError ==
                "username already exist, please try using another username") {
              validate = true;
              snackBar(context,
                  message:
                      'username already exist, please try using another username');
            } else if (Provider.of<LoginProvider>(context, listen: false)
                    .messageError ==
                "email already exist, please try using another email") {
              printLog("masuk validate email");
              validate = true;
              snackBar(context,
                  message:
                      'email already exist, please try using another email');
            } else if (Session.data.getString('cookie') != null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => HomeScreen()),
                  (Route<dynamic> route) => false);
            }
            setState(() {
              //isSuccess = value;
            });
          });
        } else if (widget.from == "facebook") {
          await Provider.of<LoginProvider>(context, listen: false)
              .signInWithFacebook(context, username: username.text)
              .then((value) {
            if (Provider.of<LoginProvider>(context, listen: false)
                    .messageError ==
                "username already exist, please try using another username") {
              validate = true;
              snackBar(context,
                  message:
                      'username already exist, please try using another username');
            } else if (Provider.of<LoginProvider>(context, listen: false)
                    .messageError ==
                "email already exist, please try using another email") {
              printLog("masuk validate email");
              validate = true;
              snackBar(context,
                  message:
                      'email already exist, please try using another email');
            } else if (Session.data.getString('cookie') != null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => HomeScreen()),
                  (Route<dynamic> route) => false);
            }
            setState(() {
              //isSuccess = value;
            });
          });
        } else if (widget.from == "apple") {
          await Provider.of<LoginProvider>(context, listen: false)
              .signInWithApple(context, username: username.text)
              .then((value) {
            if (Provider.of<LoginProvider>(context, listen: false)
                    .messageError ==
                "username already exist, please try using another username") {
              validate = true;
              snackBar(context,
                  message:
                      'username already exist, please try using another username');
            } else if (Provider.of<LoginProvider>(context, listen: false)
                    .messageError ==
                "email already exist, please try using another email") {
              printLog("masuk validate email");
              validate = true;
              snackBar(context,
                  message:
                      'email already exist, please try using another email');
            } else if (Session.data.getString('cookie') != null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => HomeScreen()),
                  (Route<dynamic> route) => false);
            }
            setState(() {
              //isSuccess = value;
            });
          });
        }
      } else {
        snackBar(context, message: 'Fill all required forms');
      }
    }

    Widget buildButton = Container(
      child: ListenableProvider.value(
        value: authLogin,
        child: Consumer<LoginProvider>(builder: (context, value, child) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            height: 40,
            child: TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: value.loading || username.text.length < 3
                      ? Colors.grey
                      : secondaryColor),
              onPressed: () {
                login(context);
              },
              child: value.loading
                  ? customLoading()
                  : Text(
                      AppLocalizations.of(context)!.translate('submit')!,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: responsiveFont(12),
                          fontWeight: FontWeight.bold),
                    ),
            ),
          );
        }),
      ),
    );

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                // color: Colors.black,
              )),
          title: AutoSizeText(
            AppLocalizations.of(context)!.translate("create_username")!,
            style:
                TextStyle(fontSize: responsiveFont(16), color: secondaryColor),
          ),
          // backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Container(
            // height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!
                      .translate("pls_enter_username")!,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: responsiveFont(10),
                  ),
                ),
                Container(
                  height: 20,
                ),
                Container(
                  child: form(
                      AppLocalizations.of(context)!.translate('username'),
                      AppLocalizations.of(context)!.translate('enter_username'),
                      true,
                      username,
                      icon: "akun"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        child: form(
                          AppLocalizations.of(context)!.translate('first_name'),
                          AppLocalizations.of(context)!
                              .translate('enter_firstname'),
                          false,
                          firstName,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.w,
                    ),
                    Expanded(
                      child: Container(
                        child: form(
                          AppLocalizations.of(context)!.translate('last_name'),
                          AppLocalizations.of(context)!
                              .translate('enter_lastname'),
                          false,
                          lastName,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  child: form(
                    AppLocalizations.of(context)!.translate('email'),
                    AppLocalizations.of(context)!.translate('enter_email'),
                    true,
                    email,
                    icon: "email",
                  ),
                ),
                buildButton,
                Container(
                  height: 15,
                ),
              ],
            ),
          ),
        ));
  }

  Widget form(String? hints, String? label, bool prefix,
      TextEditingController controller,
      {String icon = "akun"}) {
    final isDarkMode = Provider.of<AppNotifier>(context).isDarkMode;
    return Container(
      height: MediaQuery.of(context).size.height / 9,
      child: TextField(
        controller: controller,
        onChanged: (value) {
          setState(() {
            validate = false;
          });
        },
        decoration: InputDecoration(
            prefixIcon: prefix
                ? Container(
                    padding: EdgeInsets.only(right: 5),
                    width: 24,
                    height: 24,
                    child: Image.asset(
                      "images/account/$icon.png",
                      color: isDarkMode ? Colors.white : null,
                    ),
                  )
                : null,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: responsiveFont(10),
            ),
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: responsiveFont(12),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelText: label,
            hintText: hints),
      ),
    );
  }
}
