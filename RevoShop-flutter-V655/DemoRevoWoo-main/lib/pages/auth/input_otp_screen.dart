import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../app_localizations.dart';

class InputOTP extends StatefulWidget {
  final String? phone;
  InputOTP({Key? key, this.phone}) : super(key: key);

  @override
  _InputOTPState createState() => _InputOTPState();
}

class _InputOTPState extends State<InputOTP> with CodeAutoFill {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _pinPutFocusNode = FocusNode();
  TextEditingController? _otpController;

  bool isResend = false;
  String? appSignature;
  String? otpCode;

  Future<String> getCode() async {
    return _otpController!.text;
  }

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    listenForCode();

    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.translate('input_otp')!,
          style: TextStyle(
            // color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(
            // color: secondaryColor,
            ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      // backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.translate('subtitle_input_otp')!,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Container(
                height: 12,
              ),
              autoPinPut(),
              Container(
                height: 12,
              ),
              Container(
                width: double.infinity,
                child: InkWell(
                  onTap: () => Navigator.pop(context, _otpController!.text),
                  child: Container(
                    height: 40.h,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text("Submit",
                          style:
                              TextStyle(fontSize: 16.0, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              Container(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(height: 4.0, color: Colors.black),
              ),
              CountdownTimer(
                endTime: DateTime.now().millisecondsSinceEpoch + 1000 * 60,
                widgetBuilder: (context, time) {
                  var textCountDown = '';
                  if (time != null) {
                    if (time.sec! >= 10)
                      textCountDown = '00:${time.sec}';
                    else
                      textCountDown = '00:0${time.sec}';
                  }

                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (time == null) {
                            setState(() => isResend = true);
                            FirebaseAuth auth = FirebaseAuth.instance;

                            await auth.verifyPhoneNumber(
                              phoneNumber: "+62" + widget.phone!,
                              timeout: Duration(minutes: 1),
                              verificationCompleted: (credential) {
                                print("completed $credential");
                              },
                              verificationFailed: (e) {
                                print(e.message);
                              },
                              codeSent: (verificationId,
                                  [forceResendingToken]) async {
                                final code = await getCode();

                                if (code.isNotEmpty) {
                                  PhoneAuthCredential phoneAuthCredential =
                                      PhoneAuthProvider.credential(
                                          verificationId: verificationId,
                                          smsCode: code);
                                  await auth
                                      .signInWithCredential(phoneAuthCredential)
                                      .then((value) async {
                                    if (value.user!.uid != '') {}
                                  });
                                }
                              },
                              codeAutoRetrievalTimeout: (verificationId) {
                                print('timeout');
                              },
                            );
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                              .translate('resend_code')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: time == null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: time != null,
                        child: Container(
                          margin: EdgeInsets.only(left: 12.0),
                          child: Text(
                            textCountDown,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  AppLocalizations.of(context)!.translate('or')!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)!.translate('change_number')!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pinPut() {
    final BoxDecoration pinPutDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: primaryColor));
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 40,
      textStyle: const TextStyle(color: Colors.black, fontSize: 20.0),
      decoration: pinPutDecoration,
    );

    return Pinput(
      showCursor: true,
      length: 6,
      focusNode: _pinPutFocusNode,
      controller: _otpController,
      onCompleted: (String pin) => print(pin),
      pinAnimationType: PinAnimationType.scale,
      defaultPinTheme: defaultPinTheme,
    );
  }

  Widget autoPinPut() {
    return PinFieldAutoFill(
      decoration: BoxLooseDecoration(
          textStyle: TextStyle(
              fontSize: 20,
              height: 1.2,
              color: Colors.black,
              fontWeight: FontWeight.bold),
          strokeColorBuilder: FixedColorBuilder(primaryColor),
          strokeWidth: 2),
      codeLength: 6,
      focusNode: _pinPutFocusNode,
      controller: _otpController,
      keyboardType: TextInputType.number,
      currentCode: _otpController!.text,
      onCodeSubmitted: (code) {},
      onCodeChanged: (code) {
        debugPrint("Code OTP : $code");
        if (code!.length == 6) {
          FocusScope.of(context).requestFocus(FocusNode());
          Navigator.pop(context, _otpController!.text);
        }
      },
    );
  }

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code!;
      _otpController!.text = code!;
    });
  }
}
