import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/pages/auth/create_username_screen.dart';
import 'package:nyoba/pages/auth/input_otp_screen.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/provider/login_provider.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../utils/utility.dart';
import 'package:auto_size_text/auto_size_text.dart';

class EditPhoneScreen extends StatefulWidget {
  final String? phone;
  EditPhoneScreen({Key? key, this.phone = ""}) : super(key: key);

  @override
  _EditPhoneScreenState createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
  bool isVisible = false;
  bool otpInvalid = false;

  TextEditingController phone = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  loginOTP(var _phone, countryCode) async {
    await Provider.of<LoginProvider>(context, listen: false)
        .signInOTPv2(context, _phone, countryCode, username: "")
        .then((value) {
      if (Provider.of<LoginProvider>(context, listen: false).messageError ==
          "create username first") {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateUsernameScreen(
                phone: _phone,
                countryCode: countryCode,
                from: "otp",
              ),
            ));
      } else if (Session.data.getString('cookie') != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
            (Route<dynamic> route) => false);
      }
    });
  }

  int? _forceResendingToken;

  @override
  Widget build(BuildContext context) {
    final authLogin = Provider.of<LoginProvider>(context, listen: false);

    signInOTP(String phoneNumber) async {
      FirebaseAuth auth = FirebaseAuth.instance;
      FocusScopeNode currentFocus = FocusScope.of(context);
      var countryCode =
          Provider.of<LoginProvider>(context, listen: false).countryCode!;
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      if (phoneNumber.startsWith('0')) {
        phoneNumber = phoneNumber.substring(1);
      }
      var phone =
          Provider.of<LoginProvider>(context, listen: false).countryCode! +
              phoneNumber;
      var phoneUser = Provider.of<LoginProvider>(context, listen: false)
              .countryCode!
              .replaceAll("+", "") +
          phoneNumber;
      await auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(minutes: 1),
        verificationCompleted: (credential) {
          print("completed $credential");
        },
        verificationFailed: (e) {
          print(e.message);
          return snackBar(context, message: e.message!, color: Colors.red);
        },
        forceResendingToken: _forceResendingToken,
        codeSent: (verificationId, [forceResendingToken]) async {
          _forceResendingToken = forceResendingToken;
          final code = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InputOTP(phone: phoneNumber)));
          if (code != null) {
            print(code);
            PhoneAuthCredential phoneAuthCredential =
                PhoneAuthProvider.credential(
                    verificationId: verificationId, smsCode: code);
            await auth
                .signInWithCredential(phoneAuthCredential)
                .then((value) async {
              if (value.user!.uid != '') {
                /*If Success*/
                print('Success');
                Navigator.pop(context, [phoneUser, countryCode.substring(1)]);
                // loginOTP(phoneUser, countryCode.substring(1));
              }
            }).catchError((error) {
              print(error);
              print('Failed');
              snackBar(context,
                  message:
                      AppLocalizations.of(context)!.translate('otp_invalid')!,
                  color: Colors.red);
            });
          } else {
            snackBar(context, message: 'Login by OTP cancelled.');
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          print('timeout');
        },
      );
    }

    Widget buildButton = Container(
      child: ListenableProvider.value(
        value: authLogin,
        child: Consumer<UserProvider>(builder: (context, value, child) {
          return Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                height: 40.h,
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      backgroundColor:
                          value.loadingCheckPhone || phone.text.length < 5
                              ? Colors.grey
                              : secondaryColor),
                  onPressed: () {
                    if (phone.text.isNotEmpty) {
                      setState(() {
                        otpInvalid = false;
                      });
                      String tempPhone = phone.text;
                      if (phone.text.startsWith('0')) {
                        tempPhone = phone.text.substring(1);
                      }
                      String phoneNum =
                          Provider.of<LoginProvider>(context, listen: false)
                                  .countryCode!
                                  .replaceAll("+", "") +
                              tempPhone;
                      context
                          .read<UserProvider>()
                          .checkPhoneNumber(
                              phone: phoneNum,
                              countryCode: Provider.of<LoginProvider>(context,
                                      listen: false)
                                  .countryCode!)
                          .then((value) {
                        if (value == "error") {
                          return snackBar(context,
                              message: AppLocalizations.of(context)!
                                  .translate("phone_alr_exist")!);
                        } else {
                          signInOTP(phone.text);
                        }
                      });
                    }
                  },
                  child: value.loadingCheckPhone
                      ? customLoading()
                      : Text(
                          AppLocalizations.of(context)!.translate("verify")!,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: responsiveFont(12),
                              fontWeight: FontWeight.bold),
                        ),
                ),
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
            AppLocalizations.of(context)!.translate("edit_phone_number")!,
            style:
                TextStyle(fontSize: responsiveFont(16), color: secondaryColor),
          ),
          // backgroundColor: Colors.white,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            children: [
              Text(
                widget.phone == ""
                    ? "${AppLocalizations.of(context)!.translate("pls_input_phone")!}"
                    : "${AppLocalizations.of(context)!.translate("pls_input_phone")!} ${AppLocalizations.of(context)!.translate("for_change")!} (${widget.phone})",
                style: TextStyle(
                  fontSize: responsiveFont(14),
                ),
              ),
              Container(
                height: 20,
              ),
              Container(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: secondaryColor),
                            borderRadius: BorderRadius.circular(8)),
                        child: CountryCodePicker(
                          onChanged: (e) {
                            Provider.of<LoginProvider>(context, listen: false)
                                .countryCode = e.dialCode;
                            print(e);
                          },
                          initialSelection:
                              Provider.of<LoginProvider>(context, listen: false)
                                  .countryCode,
                          padding: EdgeInsets.zero,
                          showFlagDialog: true,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(color: secondaryColor),
                              borderRadius: BorderRadius.circular(8)),
                          child: TextField(
                            controller: phone,
                            onChanged: (value) {
                              this.setState(() {});
                            },
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: responsiveFont(14),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                            ],
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsiveFont(14),
                                ),
                                hintText: AppLocalizations.of(context)!
                                    .translate('input_otp_hint')),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: phone.text.length < 5 && phone.text.isNotEmpty,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    alertPhone(context)!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              buildButton,
              Container(
                height: 15,
              ),
            ],
          ),
        ));
  }
}
