import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/models/user_model.dart';
import 'package:nyoba/pages/account/account_edit_phone_screen.dart';
import 'package:nyoba/pages/auth/sign_in_otp_screen.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../provider/home_provider.dart';
import '../../provider/login_provider.dart';
import '../../utils/utility.dart';

class AccountEditScreen extends StatefulWidget {
  final UserModel? userModel;
  AccountEditScreen({Key? key, this.userModel}) : super(key: key);

  @override
  _AccountEditScreenState createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  bool isVisible = false;
  bool isVisibleNew = false;
  bool isVisibleNewRepeat = false;
  bool checkedValue = false;

  TextEditingController controllerFirstname = new TextEditingController();
  TextEditingController controllerLastname = new TextEditingController();
  TextEditingController controllerUsername = new TextEditingController();
  TextEditingController controllerEmail = new TextEditingController();
  TextEditingController controllerPassword = new TextEditingController();
  TextEditingController controllerPasswordConfirm = new TextEditingController();
  TextEditingController controllerOldPassword = new TextEditingController();
  TextEditingController controllerPhone = new TextEditingController();

  @override
  void initState() {
    super.initState();
    controllerEmail.text = widget.userModel!.email!;
    controllerUsername.text = widget.userModel!.username!;
    controllerFirstname.text = widget.userModel!.firstname!;
    controllerLastname.text = widget.userModel!.lastname!;
    controllerPhone.text = widget.userModel!.phoneNumber!;
  }

  String? countryCode = "";

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);

    logout() async {
      final home = Provider.of<HomeProvider>(context, listen: false);
      var auth = FirebaseAuth.instance;

      Session().removeUser();
      if (auth.currentUser != null) {
        await GoogleSignIn().signOut();
      }
      if (Session.data.getString('login_type') == 'apple') {
        await auth.signOut();
      }
      if (Session.data.getString('login_type') == 'facebook') {
        context.read<LoginProvider>().facebookSignOut();
      }
      setState(() {});
      home.isReload = true;
      await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
          (Route<dynamic> route) => false);
    }

    logoutPopDialog() {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            insetPadding: EdgeInsets.all(0),
            content: Builder(
              builder: (context) {
                return Container(
                  height: 150.h,
                  width: 330.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        AppLocalizations.of(context)!
                            .translate("your_sess_expired")!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: responsiveFont(14),
                            fontWeight: FontWeight.w500),
                      ),
                      Container(
                          child: Column(
                        children: [
                          Container(
                            color: Colors.black12,
                            height: 2,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => logout(),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15)),
                                      color: primaryColor),
                                  child: Text(
                                    "No",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ))
                    ],
                  ),
                );
              },
            )),
      );
    }

    var save = () async {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }

      this.setState(() {});
      if (controllerPassword.text != controllerPasswordConfirm.text) {
        snackBar(context,
            message: 'Your password and confirmation password does not match.');
      } else if (!EmailValidator.validate(controllerEmail.text)) {
        snackBar(context, message: 'Format email is wrong');
      } else {
        final Future<Map<String, dynamic>?> authResponse = user.updateUser(
            username: controllerUsername.text,
            password: controllerPassword.text,
            firstName: controllerFirstname.text,
            lastName: controllerLastname.text,
            oldPassword: controllerOldPassword.text,
            email: controllerEmail.text,
            phone: controllerPhone.text,
            countrycode: countryCode);

        authResponse.then((value) {
          printLog(value.toString());
          if (value!['is_success'] == true) {
            Navigator.pop(context);
            snackBar(context,
                message:
                    AppLocalizations.of(context)!.translate('succ_update_acc')!,
                color: Colors.green);
          } else {
            // printLog(value['message'], name: "error msg");
            // String errorMsg = value['message'].toString();
            if (value['message'].contains('cookie')) {
              printLog('cookie ditemukan');
              logoutPopDialog();
            }
            snackBar(context, message: value['message'], color: Colors.red);
          }
          this.setState(() {});
        });
      }
    };

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              // color: Colors.black,
            ),
          ),
          // backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.translate('edit_account')!,
            style:
                TextStyle(fontSize: responsiveFont(16), color: secondaryColor),
          ),
        ),
        body: Container(
          margin: EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                form(
                    AppLocalizations.of(context)!.translate('enter_firstname'),
                    AppLocalizations.of(context)!.translate('first_name'),
                    false,
                    controllerFirstname),
                Container(
                  height: 15,
                ),
                form(
                    AppLocalizations.of(context)!.translate('enter_lastname'),
                    AppLocalizations.of(context)!.translate('last_name'),
                    false,
                    controllerLastname),
                Container(
                  height: 15,
                ),
                form(
                    AppLocalizations.of(context)!.translate('enter_username'),
                    AppLocalizations.of(context)!.translate('username'),
                    true,
                    controllerUsername,
                    icon: "akun",
                    enable: false),
                Container(
                  height: 15,
                ),
                form(AppLocalizations.of(context)!.translate('enter_email'),
                    "Email", true, controllerEmail,
                    icon: "email", enable: true),
                Container(
                  height: 15,
                ),
                Row(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 12,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextField(
                        controller: controllerPhone,
                        enabled: false,
                        decoration: InputDecoration(
                            prefixIcon: Container(
                                padding: EdgeInsets.only(right: 5),
                                width: 24.w,
                                height: 24.h,
                                child: Icon(
                                  Icons.local_phone,
                                  size: 30,
                                  color: HexColor("464646"),
                                )),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: responsiveFont(10),
                            ),
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: responsiveFont(12),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: "Phone Number",
                            hintText: "Phone Number"),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPhoneScreen(
                                  phone: controllerPhone.text,
                                ),
                              )).then((value) {
                            setState(() {
                              controllerPhone.text = value[0];
                              countryCode = value[1];
                            });
                          });
                        },
                        child: Icon(
                          Icons.edit,
                          color: HexColor("464646"),
                        ))
                  ],
                ),
                Container(
                  height: 15,
                ),
                Visibility(
                    visible: Session.data.getString('login_type') == 'default',
                    child: Column(
                      children: [
                        passwordForm("Current Password", "Current Password",
                            controllerOldPassword, isVisible, 1),
                        Container(
                          height: 15,
                        ),
                        passwordForm(
                            AppLocalizations.of(context)!
                                .translate('new_password'),
                            "Password",
                            controllerPassword,
                            isVisibleNew,
                            2),
                        Container(
                          height: 15,
                        ),
                        passwordForm(
                            AppLocalizations.of(context)!
                                .translate('repeat_new_password'),
                            AppLocalizations.of(context)!
                                .translate('repeat_password'),
                            controllerPasswordConfirm,
                            isVisibleNewRepeat,
                            3),
                        Container(
                          height: 15,
                        ),
                      ],
                    )),
                Container(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        backgroundColor:
                            user.loading ? Colors.grey : secondaryColor),
                    onPressed: user.loading ? null : save,
                    child: user.loading
                        ? customLoading()
                        : Text(
                            AppLocalizations.of(context)!.translate('save')!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsiveFont(10),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget passwordForm(String? hints, String? label,
      TextEditingController controller, bool visible, int idx) {
    return Container(
      height: MediaQuery.of(context).size.height / 10,
      child: TextField(
        controller: controller,
        obscureText: visible ? false : true,
        decoration: InputDecoration(
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  if (idx == 1)
                    isVisible = !isVisible;
                  else if (idx == 2)
                    isVisibleNew = !isVisibleNew;
                  else if (idx == 3) isVisibleNewRepeat = !isVisibleNewRepeat;
                });
                print("masuk $visible");
              },
              child: Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Image.asset(visible
                      ? "images/account/melek.png"
                      : "images/account/merem.png")),
            ),
            prefixIcon: Container(
                alignment: Alignment.topCenter,
                width: 24.w,
                height: 24.h,
                padding: EdgeInsets.only(right: 5),
                child: Image.asset("images/account/lock.png")),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: responsiveFont(10),
            ),
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: responsiveFont(12),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelText: hints,
            hintText: label),
      ),
    );
  }

  Widget form(String? hints, String? label, bool prefix,
      TextEditingController controller,
      {String icon = "email", bool enable = true}) {
    return Container(
      height: MediaQuery.of(context).size.height / 12,
      child: TextField(
        controller: controller,
        enabled: enable,
        decoration: InputDecoration(
            prefixIcon: prefix
                ? Container(
                    padding: EdgeInsets.only(right: 5),
                    width: 24.w,
                    height: 24.h,
                    child: Image.asset("images/account/$icon.png"))
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
