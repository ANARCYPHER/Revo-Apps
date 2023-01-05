import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/models/user_model.dart';
import 'package:nyoba/pages/account/account_edit_screen.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uiblock/uiblock.dart';
import '../../app_localizations.dart';
import '../../utils/utility.dart';

class AccountDetailScreen extends StatefulWidget {
  AccountDetailScreen({Key? key}) : super(key: key);

  @override
  _AccountDetailScreenState createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  UserProvider? userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    loadDetail();
  }

  loadDetail() async {
    await Provider.of<UserProvider>(context, listen: false).fetchUserDetail();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBody = Container(
      child: ListenableProvider.value(
        value: userProvider,
        child: Consumer<UserProvider>(builder: (context, value, child) {
          if (value.loadingFetch) {
            return buildDetailLoading();
          }
          return buildDetail(value.user);
        }),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            // color: Colors.black,
          ),
        ),
        // backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.translate('account')!,
          style: TextStyle(
            fontSize: responsiveFont(16),
            fontWeight: FontWeight.w500,
            // color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: buildBody,
      ),
    );
  }

  buildDetail(UserModel user) {
    return Column(
      children: [
        buildTable(
            AppLocalizations.of(context)!.translate('first_name')!,
            user.firstname!.isEmpty
                ? AppLocalizations.of(context)!.translate('not_set')
                : user.firstname),
        buildTable(
            AppLocalizations.of(context)!.translate('last_name')!,
            user.lastname!.isEmpty
                ? AppLocalizations.of(context)!.translate('not_set')
                : user.lastname),
        buildTable(AppLocalizations.of(context)!.translate('username')!,
            user.username),
        buildTable(
            AppLocalizations.of(context)!.translate('email')!, user.email),
        buildTable(AppLocalizations.of(context)!.translate('phone_number')!,
            user.phoneNumber == "" ? "-" : "+${user.phoneNumber}",
            phone: true),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                backgroundColor: secondaryColor),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AccountEditScreen(
                            userModel: user,
                          ))).then((value) {
                loadDetail();
              });
            },
            child: Text(
              AppLocalizations.of(context)!.translate('edit_account')!,
              style: TextStyle(
                color: Colors.white,
                fontSize: responsiveFont(10),
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: MaterialButton(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            color: Colors.grey,
            onPressed: () async {
              _showAlertDeleteAccount();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                AppLocalizations.of(context)!.translate('delete_account')!,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAlertDeleteAccount() {
    SimpleDialog alert = SimpleDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              Text(
                "Do you want to delete your account?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              SizedBox(height: 20),
              Text(
                "Warning! This action cannot be reversed.",
                style: TextStyle(fontSize: 14),
                softWrap: true,
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        color: primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 0,
                        height: 40,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child:
                            Text(AppLocalizations.of(context)!.translate("no")!,
                                style: TextStyle(
                                  color: Colors.white,
                                )),
                      ),
                    ),
                    Container(width: 8),
                    Expanded(
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: primaryColor),
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 0,
                        height: 40,
                        onPressed: () async {
                          Navigator.pop(context);
                          _showAlertDeleteConfirmation();
                        },
                        child: Text(
                          AppLocalizations.of(context)!.translate("yes")!,
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showAlertDeleteConfirmation() {
    SimpleDialog alert = SimpleDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              Text(
                "Final Confirmation :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                "Do you want to delete your account?",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              Text(
                "Warning! This action cannot be reversed.",
                style: TextStyle(fontSize: 14),
                softWrap: true,
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        color: primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 0,
                        height: 40,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.translate("no")!,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(width: 8),
                    Expanded(
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: primaryColor),
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 0,
                        height: 40,
                        onPressed: () async {
                          Navigator.pop(context);
                          UIBlock.block(context);
                          context
                              .read<UserProvider>()
                              .deleteAccount()
                              .then((value) {
                            if (value!.statusCode == 200) {
                              UIBlock.unblock(context);
                              logout();
                            } else if (value.statusCode == 500) {
                              UIBlock.unblock(context);
                              snackBar(context, message: value.message!);
                            } else {
                              UIBlock.unblock(context);
                              snackBar(context,
                                  message: AppLocalizations.of(context)!
                                      .translate("error_occurred")!);
                            }
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context)!.translate("yes")!,
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  logout() async {
    final home = Provider.of<HomeProvider>(context, listen: false);
    var auth = FirebaseAuth.instance;
    // final AccessToken? accessToken = await FacebookAuth.instance.accessToken;

    Session().removeUser();
    if (auth.currentUser != null) {
      await GoogleSignIn().signOut();
    }
    // if (accessToken != null) {
    //   await FacebookAuth.instance.logOut();
    // }
    if (Session.data.getString('login_type') == 'apple') {
      await auth.signOut();
    }
    home.isReload = true;
    snackBar(context, message: "Successfully delete your account");
    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
        (Route<dynamic> route) => false);
  }

  buildDetailLoading() {
    return Column(
      children: [
        buildTableShimmer(
            AppLocalizations.of(context)!.translate('first_name')!),
        buildTableShimmer(
            AppLocalizations.of(context)!.translate('last_name')!),
        buildTableShimmer(AppLocalizations.of(context)!.translate('username')!),
        buildTableShimmer(AppLocalizations.of(context)!.translate('email')!),
      ],
    );
  }

  Widget buildTable(String type, String? data, {bool? phone = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Text(
              type,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: responsiveFont(10)),
            ),
            Spacer(),
            Container(
              width: !phone!
                  ? MediaQuery.of(context).size.width * 0.6
                  : data != "-"
                      ? MediaQuery.of(context).size.width * 0.42
                      : MediaQuery.of(context).size.width * 0.4,
              child: Text(": $data",
                  maxLines: 2,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: responsiveFont(10),
                      fontStyle: data ==
                              AppLocalizations.of(context)!.translate('not_set')
                          ? FontStyle.italic
                          : null)),
            ),
            Visibility(
                visible: phone,
                child: Container(
                  width: data == "-"
                      ? MediaQuery.of(context).size.width * 0.2
                      : MediaQuery.of(context).size.width * 0.18,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color:
                              data == "-" ? HexColor("c4271b") : Colors.green,
                          width: 1.5),
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(children: [
                    Icon(
                      data == "-" ? Icons.cancel_rounded : Icons.check_circle,
                      color: data == "-" ? HexColor("c4271b") : Colors.green,
                      size: 13,
                    ),
                    Text(
                      data == "-" ? "Unverified" : "Verified",
                      style: TextStyle(
                          color:
                              data == "-" ? HexColor("c4271b") : Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    )
                  ]),
                )),
          ]),
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.32,
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 3,
          color: HexColor("CCCCCC"),
        ),
      ]),
    );
  }

  Widget buildTableShimmer(String type) {
    return Shimmer.fromColors(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Table(
                children: [
                  TableRow(children: [
                    Text(
                      type,
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
                    ),
                    Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ]),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 3,
              color: HexColor("CCCCCC"),
            ),
          ]),
        ),
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!);
  }
}
