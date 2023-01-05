import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nyoba/models/countries_model.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/widgets/form/textfield_widget.dart';

import '../../app_localizations.dart';
import '../../utils/utility.dart';

class AccountAddressEditScreen extends StatefulWidget {
  final dynamic data;
  final String? title;
  bool? isGuest = false;
  final List<String>? billing;
  final bool billingEmpty;
  AccountAddressEditScreen(
      {Key? key,
      this.data,
      this.title,
      this.billing,
      this.isGuest = false,
      this.billingEmpty = true})
      : super(key: key);

  @override
  _AccountAddressEditScreenState createState() =>
      _AccountAddressEditScreenState();
}

class _AccountAddressEditScreenState extends State<AccountAddressEditScreen> {
  bool checkedValue = false;
  UserProvider? userProvider;

  TextEditingController controllerName = new TextEditingController();
  TextEditingController controllerSurname = new TextEditingController();
  TextEditingController controllerCompany = new TextEditingController();
  TextEditingController controllerAddress = new TextEditingController();
  TextEditingController controllerAddressOpt = new TextEditingController();
  TextEditingController controllerTown = new TextEditingController();
  TextEditingController controllerPostCode = new TextEditingController();
  TextEditingController controllerPhone = new TextEditingController();
  TextEditingController controllerEmail = new TextEditingController();

  String? country;
  String? tempCountry;
  String? tempState;
  TextEditingController controllerState = new TextEditingController();

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!Session.data.getBool('isLogin')!) {
        if (widget.billingEmpty) {
          userProvider!.fetchCountries().then((value) {
            if (value) {
              // if (widget.title!.toLowerCase() == 'billing') {
              //   checkBilling();
              // }
              if (widget.isGuest!) {
                printLog("masuk guest");
                checkGuest();
              }
            }
          });
        }
        if (widget.isGuest!) {
          printLog("masuk guest");
          checkGuest();
        }
      } else {
        if (widget.title!.toLowerCase() == 'billing') {
          checkBilling();
        }
      }
    });
  }

  checkGuest() {
    final _billing = widget.billing;
    controllerName.text = _billing?[0] ?? "";
    controllerSurname.text = _billing?[1] ?? "";
    controllerCompany.text = _billing?[2] ?? "";
    controllerAddress.text = _billing?[6] ?? "";
    controllerAddressOpt.text = _billing?[7] ?? "";
    controllerTown.text = _billing?[5] ?? "";
    controllerPostCode.text = _billing?[8] ?? "";
    controllerPhone.text = _billing?[9] ?? "";
    controllerEmail.text = _billing?[10] ?? "";

    country = _billing?[11] ?? "";
    controllerState.text = _billing?[12] ?? "";
  }

  checkBilling() {
    final _billing = userProvider!.customerData?.billing;
    controllerName.text = _billing!.firstName ?? "";
    controllerSurname.text = _billing.lastName ?? "";
    controllerCompany.text = _billing.company ?? "";
    controllerAddress.text = _billing.address1 ?? "";
    controllerAddressOpt.text = _billing.address2 ?? "";
    controllerTown.text = _billing.city ?? "";
    controllerPostCode.text = _billing.postcode ?? "";
    controllerPhone.text = _billing.phone ?? "";
    controllerEmail.text = _billing.email ?? "";

    country = _billing.country;

    if (_billing.country != null) {
      context.read<UserProvider>().setCountries(_billing.country);
      context.read<UserProvider>().setStates(_billing.state);
      if (userProvider!.selectedStates != null) {
        printLog("MASUK SINI OI - ${json.encode(_billing)}");
        userProvider!
            .fetchCity(
                code: userProvider!.selectedStates!.code,
                bill: context.read<HomeProvider>().billingAddress)
            .then((data) {
          final temps = _billing.city!.split(" ");
          String tempKota = temps[1];
          String tempId = "";
          for (int i = 0; i < userProvider!.cities.length; i++) {
            if (userProvider!.cities[i].value == _billing.city!) {
              tempId = userProvider!.cities[i].cityId!.toString();
            }
          }
          context.read<UserProvider>().setCity(tempId);
          if (userProvider!.cities.length > 0) {
            userProvider!
                .fetchSubdistrict(
                    id: tempId,
                    bill: context.read<HomeProvider>().billingAddress)
                .then((value) async {
              final tempsa = _billing.address2!;
              String idSub = "";
              for (int i = 0; i < userProvider!.subdistrict.length; i++) {
                if (userProvider!.subdistrict[i].subdistrictName == tempsa) {
                  idSub = userProvider!.subdistrict[i].subdistrictId!;
                }
              }
              await context.read<UserProvider>().setSubdistrict(idSub);
              printLog(
                  "subdistrict : ${userProvider!.selectedSubdistrict!.subdistrictName}");
            });
          }
        });
      }
    }
    controllerState.text = _billing.state ?? "";
  }

  List<String> billingAddress = [];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);

    var save = () async {
      this.setState(() {});
      Session.data.setString("country_id", user.selectedCountries!.code!);
      if (user.selectedStates != null) {
        Session.data.setString("state_id", user.selectedStates!.code!);
      } else {
        Session.data.setString("state_id", controllerState.text);
      }
      Session.data.setString("postcode", controllerPostCode.text);
      Session.data.setString("city", controllerTown.text);
      Session.data.setString("subdistrict", controllerAddressOpt.text);
      printLog(Session.data.getString("state_id")!, name: "STATE ID");
      if (Session.data.getBool('isLogin')!) {
        if (widget.title!.toLowerCase() == 'billing') {
          await context
              .read<UserProvider>()
              .saveAddress(
                context,
                action: 'billing',
                billingaddress: controllerAddress.text,
                billingaddressopt: controllerAddressOpt.text,
                billingcity: controllerTown.text,
                billingcompany: controllerCompany.text,
                billingcountry: country,
                billingemail: controllerEmail.text,
                billingname: controllerName.text,
                billingphone: controllerPhone.text,
                billingpostal: controllerPostCode.text,
                billingsurname: controllerSurname.text,
                billingstate: controllerState.text,
              )
              .then((value) => this.setState(() {}));
        } else {
          await context
              .read<UserProvider>()
              .saveAddress(context)
              .then((value) => this.setState(() {}));
        }
        Navigator.pop(context, 200);
      } else {
        if (controllerName.text.isEmpty ||
            controllerSurname.text.isEmpty ||
            controllerAddress.text.isEmpty ||
            controllerPostCode.text.isEmpty ||
            controllerEmail.text.isEmpty ||
            controllerPhone.text.isEmpty ||
            country!.isEmpty ||
            controllerState.text.isEmpty ||
            controllerTown.text.isEmpty) {
          return snackBar(context,
              message: 'Required form field should not be empty');
        }
        billingAddress.clear();
        billingAddress.add(controllerName.text);
        billingAddress.add(controllerSurname.text);
        billingAddress.add(controllerCompany.text);
        billingAddress.add(userProvider!.countryName!);
        billingAddress.add(userProvider!.stateName!);
        billingAddress.add(controllerTown.text);
        billingAddress.add(controllerAddress.text);
        billingAddress.add(controllerAddressOpt.text);
        billingAddress.add(controllerPostCode.text);
        billingAddress.add(controllerPhone.text);
        billingAddress.add(controllerEmail.text);
        billingAddress.add(country!);
        billingAddress.add(controllerState.text);
        printLog("Address : $billingAddress");
        Navigator.pop(context, billingAddress);
      }
    };

    Widget buildBody = Container(
      child: ListenableProvider.value(
        value: user,
        child: Consumer<UserProvider>(builder: (context, value, child) {
          return value.loading
              ? customLoading()
              : Container(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormRevo(
                            txtController: controllerName,
                            label:
                                '${AppLocalizations.of(context)!.translate('first_name')}*'),
                        FormRevo(
                            txtController: controllerSurname,
                            label:
                                '${AppLocalizations.of(context)!.translate('last_name')}*'),
                        FormRevo(
                            txtController: controllerCompany,
                            label:
                                '${AppLocalizations.of(context)!.translate('comp_name')}'),
                        _buildDropdown(
                            '${AppLocalizations.of(context)!.translate('country')}*',
                            value,
                            'countries'),
                        value.selectedCountries == null
                            ? Container()
                            : value.selectedCountries!.states!.isEmpty
                                ? FormRevo(
                                    txtController: controllerState,
                                    label:
                                        '${AppLocalizations.of(context)!.translate('state')}*',
                                  )
                                : _buildDropdown(
                                    '${AppLocalizations.of(context)!.translate('state')}*',
                                    value,
                                    'states'),
                        value.cities.isEmpty
                            ? FormRevo(
                                txtController: controllerTown,
                                label:
                                    '${AppLocalizations.of(context)!.translate('town')}*')
                            : _buildDropdown(
                                '${AppLocalizations.of(context)!.translate('town')}*',
                                value,
                                'town'),

                        // FormRevo(
                        //   txtController: controllerAddressOpt,
                        //   label:
                        //       '${AppLocalizations.of(context)!.translate('placeholder_address')}',
                        //   hint:
                        //       '${AppLocalizations.of(context)!.translate('placeholder_address')}',
                        // ),
                        value.subdistrict.isEmpty || value.cities.isEmpty
                            ? FormRevo(
                                txtController: controllerAddressOpt,
                                label:
                                    '${AppLocalizations.of(context)!.translate('placeholder_address')}',
                                hint:
                                    '${AppLocalizations.of(context)!.translate('placeholder_address')}',
                              )
                            : Container(
                                child: value.loadingSub
                                    ? customLoading()
                                    : _buildDropdown(
                                        'Subdistrict*', value, 'subdistrict'),
                              ),
                        FormRevo(
                            txtController: controllerAddress,
                            label:
                                '${AppLocalizations.of(context)!.translate('street')}*'),
                        FormRevo(
                            txtController: controllerPostCode,
                            label:
                                '${AppLocalizations.of(context)!.translate('postcode')}*'),
                        Visibility(
                            visible: widget.title!.toLowerCase() == 'billing',
                            child: Column(
                              children: [
                                FormRevo(
                                    txtController: controllerPhone,
                                    label:
                                        '${AppLocalizations.of(context)!.translate('phone')}*'),
                                FormRevo(
                                    txtController: controllerEmail,
                                    label:
                                        '${AppLocalizations.of(context)!.translate('email_address')}*'),
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
                                    backgroundColor: value.loading
                                        ? Colors.grey
                                        : secondaryColor),
                                onPressed: value.loading ? null : save,
                                child: value.loading
                                    ? customLoading()
                                    : Text(
                                        AppLocalizations.of(context)!
                                            .translate('save')!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: responsiveFont(10),
                                        ),
                                      ))),

                        // FormRevo(
                        //     txtController: controllerTown,
                        //     label:
                        //         '${AppLocalizations.of(context)!.translate('town')}*'),
                        // FormRevo(
                        //     txtController: controllerAddress,
                        //     label:
                        //         '${AppLocalizations.of(context)!.translate('street')}*'),
                        // value.subdistrict.isEmpty || value.cities.isEmpty
                        //     ? FormRevo(
                        //         txtController: controllerAddressOpt,
                        //         label:
                        //             '${AppLocalizations.of(context)!.translate('placeholder_address')}',
                        //         hint:
                        //             '${AppLocalizations.of(context)!.translate('placeholder_address')}',
                        //       )
                        //     : Container(
                        //         child: value.loadingSub
                        //             ? customLoading()
                        //             : _buildDropdown(
                        //                 'Subdistrict*', value, 'subdistrict'),
                        // ),
                        // FormRevo(
                        //   txtController: controllerAddressOpt,
                        //   label:
                        //       '${AppLocalizations.of(context)!.translate('placeholder_address')}',
                        //   hint:
                        //       '${AppLocalizations.of(context)!.translate('placeholder_address')}',
                        // ),
                        // FormRevo(
                        //     txtController: controllerPostCode,
                        //     label:
                        //         '${AppLocalizations.of(context)!.translate('postcode')}*'),
                        // Visibility(
                        //     visible: widget.title!.toLowerCase() == 'billing',
                        //     child: Column(
                        //       children: [
                        //         FormRevo(
                        //             txtController: controllerPhone,
                        //             label:
                        //                 '${AppLocalizations.of(context)!.translate('phone')}*'),
                        //         FormRevo(
                        //             txtController: controllerEmail,
                        //             label:
                        //                 '${AppLocalizations.of(context)!.translate('email_address')}*'),
                        //       ],
                        //     )),
                        // Container(
                        //   height: 10,
                        // ),
                        // Container(
                        //   width: double.infinity,
                        //   child: TextButton(
                        //     style: TextButton.styleFrom(
                        //         padding: EdgeInsets.symmetric(vertical: 10),
                        //         backgroundColor: value.loading
                        //             ? Colors.grey
                        //             : secondaryColor),
                        //     onPressed: value.loading ? null : save,
                        //     child: value.loading
                        //         ? customLoading()
                        //         : Text(
                        //             AppLocalizations.of(context)!
                        //                 .translate('save')!,
                        //             style: TextStyle(
                        //               color: Colors.white,
                        //               fontSize: responsiveFont(10),
                        //             ),
                        //           ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                );
        }),
      ),
    );

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
            '${AppLocalizations.of(context)!.translate('my_address')}',
            style:
                TextStyle(fontSize: responsiveFont(16), color: secondaryColor),
          ),
        ),
        body: buildBody);
  }

  _buildDropdown(String? label, UserProvider? value, String? type) {
    var _value;
    if (value != null) {
      if (type == 'countries' && value.selectedCountries != null) {
        _value = value.selectedCountries!.code;
        country = value.selectedCountries!.code;
      } else if (type == 'states' && value.selectedStates != null) {
        _value = value.selectedStates!.code;
      } else if (type == 'town' && value.selectedCity != null) {
        _value = value.selectedCity!.cityId;
      } else if (type == "subdistrict" && value.selectedSubdistrict != null) {
        _value = value.selectedSubdistrict!.subdistrictId;
      }
    }
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: responsiveFont(8),
              // color: Colors.black54,
            ),
          ),
          Container(
            child: DropdownButton(
              isExpanded: true,
              underline: Container(
                height: 1.0,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFBDBDBD),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              hint: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Choose $label")),
              value: _value,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: type == 'countries'
                  ? value!.countries?.map((CountriesModel items) {
                      return DropdownMenuItem(
                          value: items.code,
                          child: Container(
                            child: Text(
                              items.name!,
                              style: TextStyle(
                                  color: _value != items.code
                                      ? Colors.black45
                                      : null),
                            ),
                          ));
                    }).toList()
                  : type == 'states'
                      ? value!.selectedCountries!.states!.map((States items) {
                          return DropdownMenuItem(
                              value: items.code,
                              child: Container(
                                child: Text(
                                  items.name!,
                                  style: TextStyle(
                                      color: _value != items.code
                                          ? Colors.black45
                                          : null),
                                ),
                              ));
                        }).toList()
                      : type == 'town'
                          ? value!.cities.map((City items) {
                              return DropdownMenuItem(
                                  value: items.cityId,
                                  child: Container(
                                    child: Text(
                                      items.value!,
                                      style: TextStyle(
                                          color: _value != items.cityId
                                              ? Colors.black45
                                              : null),
                                    ),
                                  ));
                            }).toList()
                          : value!.subdistrict.map((Subdistrict items) {
                              return DropdownMenuItem(
                                  value: items.subdistrictId,
                                  child: Container(
                                    child: Text(
                                      items.subdistrictName!,
                                      style: TextStyle(
                                          color: _value != items.subdistrictId
                                              ? Colors.black45
                                              : null),
                                    ),
                                  ));
                            }).toList(),
              onChanged: (val) {
                if (type == 'countries') {
                  context.read<UserProvider>().setCountries(val.toString());
                  context
                      .read<UserProvider>()
                      .fetchCity(
                          code: userProvider!.selectedStates == null
                              ? null
                              : userProvider!.selectedStates!.code!,
                          bill: context.read<HomeProvider>().billingAddress)
                      .then((value) {
                    context.read<UserProvider>().fetchSubdistrict(
                        id: userProvider!.selectedCity == null
                            ? null
                            : userProvider!.selectedCity!.cityId.toString(),
                        bill: context.read<HomeProvider>().billingAddress);
                  });
                  setState(() {
                    country = val.toString();
                    controllerState.clear();
                    controllerTown.clear();
                    controllerAddressOpt.clear();
                  });
                } else if (type == 'states') {
                  context.read<UserProvider>().setStates(val.toString());
                  context
                      .read<UserProvider>()
                      .fetchCity(
                          code: userProvider!.selectedStates!.code!,
                          bill: context.read<HomeProvider>().billingAddress)
                      .then((value) {
                    context.read<UserProvider>().fetchSubdistrict(
                        id: userProvider!.selectedCity!.cityId.toString(),
                        bill: context.read<HomeProvider>().billingAddress);
                  });

                  setState(() {
                    controllerState.text = val.toString();
                    controllerTown.clear();
                    controllerAddressOpt.clear();
                  });
                } else if (type == 'town') {
                  context.read<UserProvider>().setCity(val.toString());
                  context.read<UserProvider>().fetchSubdistrict(
                      id: val.toString(),
                      bill: context.read<HomeProvider>().billingAddress);
                  String temp = "";
                  for (int i = 0; i < userProvider!.cities.length; i++) {
                    if (userProvider!.cities[i].cityId == val) {
                      temp = userProvider!.cities[i].value!;
                    }
                  }
                  setState(() {
                    controllerTown.text = temp;
                    controllerAddressOpt.clear();
                  });
                  printLog("city : ${json.encode(controllerTown.text)}");
                } else {
                  context.read<UserProvider>().setSubdistrict(val.toString());
                  String temp = "";
                  for (int i = 0; i < userProvider!.subdistrict.length; i++) {
                    if (userProvider!.subdistrict[i].subdistrictId == val) {
                      temp = userProvider!.subdistrict[i].subdistrictName!;
                    }
                  }
                  setState(() {
                    controllerAddressOpt.text = temp;
                  });
                  printLog(
                      "address opt : ${json.encode(controllerAddressOpt.text)}");
                }
              },
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
