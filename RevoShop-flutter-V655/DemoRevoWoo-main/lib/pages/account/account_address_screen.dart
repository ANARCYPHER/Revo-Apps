import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/models/customer_data_model.dart';
import 'package:nyoba/pages/account/account_address_edit_screen.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_localizations.dart';
import '../../utils/utility.dart';

class AccountAddressScreen extends StatefulWidget {
  AccountAddressScreen({Key? key}) : super(key: key);

  @override
  _AccountAddressScreenState createState() => _AccountAddressScreenState();
}

class _AccountAddressScreenState extends State<AccountAddressScreen> {
  UserProvider? userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    loadDetail();
  }

  loadDetail() async {
    await Provider.of<UserProvider>(context, listen: false).fetchAddress();
    await context.read<UserProvider>().fetchCountries();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBody = Container(
      child: ListenableProvider.value(
        value: userProvider,
        child: Consumer<UserProvider>(builder: (context, value, child) {
          if (value.loading) {
            return buildDetailLoading();
          }
          return buildDetail(value.customerData!);
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
          "${AppLocalizations.of(context)!.translate('my_address')}",
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

  buildDetail(CustomerData user) {
    return Column(
      children: [
        buildTable(AppLocalizations.of(context)!.translate('first_name')!,
            user.billing!.firstName!),
        buildTable(AppLocalizations.of(context)!.translate('last_name')!,
            user.billing!.lastName),
        buildTable(AppLocalizations.of(context)!.translate('comp_name')!,
            user.billing!.company),
        buildTable("${AppLocalizations.of(context)!.translate('address')}",
            user.billing!.address1),
        buildTable("Subdistrict", user.billing!.address2),
        buildTable("${AppLocalizations.of(context)!.translate('town')}",
            user.billing!.city),
        buildTable(
            "${AppLocalizations.of(context)!.translate('province')}",
            user.billing!.state == null
                ? ""
                : userProvider?.convertState(
                    user.billing!.country, user.billing!.state)),
        buildTable("${AppLocalizations.of(context)!.translate('country')}",
            userProvider?.convertCountry(user.billing!.country)),
        buildTable("${AppLocalizations.of(context)!.translate('postcode')}",
            user.billing!.postcode),
        buildTable("${AppLocalizations.of(context)!.translate('phone')}",
            user.billing!.phone),
        buildTable(
            "${AppLocalizations.of(context)!.translate('email_address')}",
            user.billing!.email),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                backgroundColor: secondaryColor),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AccountAddressEditScreen(
                            title: 'billing',
                          ))).then((value) {
                if (value == 200) {
                  loadDetail();
                }
              });
            },
            child: Text(
              '${AppLocalizations.of(context)!.translate('edit')}',
              style: TextStyle(
                color: Colors.white,
                fontSize: responsiveFont(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildDetailLoading() {
    return Column(
      children: [for (int i = 0; i < 8; i++) buildTableShimmer()],
    );
  }

  Widget buildTable(String type, String? data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Table(
            children: [
              TableRow(children: [
                Text(
                  type,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: responsiveFont(10)),
                ),
                Text(
                    ": ${data!.isNotEmpty ? data : "[${AppLocalizations.of(context)!.translate('not_set')}]"}",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: responsiveFont(10),
                        fontStyle: data ==
                                AppLocalizations.of(context)!
                                    .translate('not_set')
                            ? FontStyle.italic
                            : null)),
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
    );
  }

  Widget buildTableShimmer() {
    return Shimmer.fromColors(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    height: 25,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    height: 25,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
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
