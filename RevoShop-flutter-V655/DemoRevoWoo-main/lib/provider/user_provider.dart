import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/models/basic_response.dart';
import 'package:nyoba/models/billing_address_model.dart';
import 'package:nyoba/models/countries_model.dart';
import 'package:nyoba/models/customer_data_model.dart';
import 'package:provider/provider.dart';
import 'package:nyoba/models/point_model.dart';
import 'package:nyoba/models/user_model.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/services/user_api.dart';
import 'package:nyoba/utils/utility.dart';

import '../models/referal_model.dart';

class UserProvider with ChangeNotifier {
  UserModel _user = new UserModel();
  ReferalModel refModel = new ReferalModel();

  UserModel get user => _user;

  bool loading = false;
  bool loadDelete = false;
  bool loadingFetch = false;
  bool loadingCheckPhone = false;

  PointModel? point;

  CustomerData? customerData;
  List<CountriesModel>? countries;

  CountriesModel? selectedCountries;
  States? selectedStates;

  bool? membershipActive = false;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  Future<String> checkPhoneNumber({String? phone, String? countryCode}) async {
    loadingCheckPhone = true;
    String res = "";
    try {
      await UserAPI()
          .checkPhoneNumber(phone: phone, countryCode: countryCode)
          .then((data) {
        if (data['status'] == "success") {
          loadingCheckPhone = false;
          notifyListeners();
          res = data['message'];
        } else {
          loadingCheckPhone = false;
          notifyListeners();
          res = data['status'];
        }
      });
    } catch (e) {
      print(e.toString());
      res = "";
      loadingCheckPhone = false;
      notifyListeners();
    }
    return res;
  }

  Future<Map<String, dynamic>?> fetchUserDetail() async {
    loadingFetch = true;
    var result;
    await UserAPI().fetchDetail().then((data) {
      result = data;
      printLog(result.toString(), name: "RESULT DATA");

      if (result["code"] != "invalid_login") {
        UserModel userModel = UserModel.fromJson(result['user']);

        if (result.toString().contains("referral")) {
          printLog("referall tidak null");
          refModel = ReferalModel.fromJson(result['referral']);
          printLog(jsonEncode(refModel), name: "REFFMODEL");
        }

        if (result.toString().contains("membership_plan")) {
          membershipActive = true;
          Session.data.setString('membershipPlan', result['membership_plan']);
          notifyListeners();
        }

        printLog(jsonEncode(refModel), name: "REFF MODEL");

        if (result['poin'] != null) {
          point = PointModel.fromJson(result['poin']);
        }
        Session.data.setString("country_id", result['user']['billing_country']);
        Session.data
            .setString("state_id", result['user']['billing_state_name']);
        Session.data.setString("postcode", result['user']['billing_postcode']);
        Session().saveUser(userModel, Session.data.getString('cookie')!);

        this.setUser(userModel);

        print(point.toString());
        loadingFetch = false;
        notifyListeners();
      }
    });
    loadingFetch = false;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>?> updateUser(
      {String? firstName,
      String? lastName,
      String? username,
      String? email,
      required String password,
      String? oldPassword,
      String? countrycode,
      String? phone}) async {
    loading = true;
    var result;
    await UserAPI()
        .updateUserInfo(
            firstName: firstName,
            lastName: lastName,
            password: password,
            oldPassword: oldPassword,
            email: email,
            countryCode: countrycode,
            phone: phone)
        .then((data) {
      result = data;
      printLog(result.toString());

      if (result['is_success'] == true) {
        Session.data.setString('cookie', result['cookie']);
      }

      loading = false;
      notifyListeners();
    });
    return result;
  }

  Future<BasicResponse?> deleteAccount() async {
    BasicResponse? _result;
    try {
      loadDelete = true;
      Map data = {
        "cookie": Session.data.getString('cookie'),
      };
      print(data);
      var response = await baseAPI.postAsync(
        'delete-account',
        data,
        isCustom: true,
      );
      if (response != null) {
        printLog(response.toString(), name: 'Response Delete Account');
        loadDelete = false;
        if (response['status'] == "success") {
          _result = BasicResponse(200, response['message']);
        } else {
          _result = BasicResponse(500, response['message']);
        }
        notifyListeners();
      }
      return _result;
    } catch (e) {
      printLog(e.toString(), name: "Error");
      _result = BasicResponse(500, e.toString());
      notifyListeners();
      return _result;
    }
  }

  Future<BasicResponse?> fetchAddress() async {
    BasicResponse? _result;
    loading = true;
    try {
      var response = await baseAPI.getAsync(
        'customers/${Session.data.getInt('id')}',
      );
      final result = json.decode(response.body);

      if (response.statusCode == 200) {
        printLog("Status Code OK");
        if (result['id'] != null) {
          printLog("ID Exists ${result['id']}");
          customerData = new CustomerData.fromJson(result);
          _result = BasicResponse(200, "Success");
        } else {
          _result = BasicResponse(500, "Failed");
        }
        loading = false;
        notifyListeners();
        return _result;
      } else {
        loading = false;
        _result = BasicResponse(500, result['message']);
        notifyListeners();
        return _result;
      }
    } catch (e) {
      loading = false;
      printLog(e.toString(), name: "Error");
      _result = BasicResponse(500, e.toString());
      notifyListeners();
      return _result;
    }
  }

  Future<BasicResponse?> saveAddress(
    context, {
    String? action = 'billing',
    String? billingname = '',
    String? billingsurname = '',
    String? billingcompany = '',
    String? billingaddress = '',
    String? billingaddressopt = '',
    String? billingcity = '',
    String? billingcountry = '',
    String? billingemail = '',
    String? billingpostal = '',
    String? billingphone = '',
    String? billingstate = '',
  }) async {
    BasicResponse? _result;
    try {
      if (action == 'billing') {
        if (billingname!.isEmpty ||
            billingsurname!.isEmpty ||
            billingaddress!.isEmpty ||
            billingpostal!.isEmpty ||
            billingemail!.isEmpty ||
            billingphone!.isEmpty ||
            billingcountry!.isEmpty ||
            billingstate!.isEmpty ||
            billingcity!.isEmpty) {
          return snackBar(context,
              message: 'Required form field should not be empty');
        }
      }
      if (!EmailValidator.validate(billingemail!)) {
        return snackBar(context, message: 'Format email is wrong');
      }
      loading = true;
      Map data = {
        "cookie": Session.data.getString('cookie'),
        "action": action,
        "first_name": billingname,
        "last_name": billingsurname,
        "company": billingcompany,
        "address_1": billingaddress,
        "address_2": billingaddressopt,
        "city": billingcity,
        "postcode": billingpostal,
        "country": billingcountry,
        "state": billingstate,
        "phone": billingphone,
        "email": billingemail
      };
      print(data);
      var response = await baseAPI.postAsync(
        'customer/address',
        data,
        isCustom: true,
      );
      if (response != null) {
        printLog(response.toString(), name: 'Response Save Account Address');
        loading = false;
        if (response['status'] == "success") {
          _result = BasicResponse(200, response['message']);
          snackBar(context,
              message: 'Address changed successfully.', color: Colors.green);
          Navigator.pop(context, 200);
        } else {
          _result = BasicResponse(500, response['message']);
          snackBar(context,
              message: 'Address changed failed, ${response['message']}',
              color: Colors.red);
        }
        notifyListeners();
      }
      return _result;
    } catch (e) {
      printLog(e.toString(), name: "Error");
      _result = BasicResponse(500, e.toString());
      loading = false;
      notifyListeners();
      return _result;
    }
  }

  bool loadingCity = true;
  List<City> cities = [];

  Future<BasicResponse?> fetchCity(
      {String? code, List<BillingAddress>? bill}) async {
    BasicResponse? _result;
    loadingCity = true;
    cities.clear();
    printLog("billing address : ${json.encode(bill)}");
    if (bill![0].type == "dropdown_woongkir") {
      try {
        var response = await baseAPI.getAsync('states?code=$code',
            isCustom: true, printedLog: true);
        final result = json.decode(response.body);
        printLog("city : ${result}");
        if (result != null) {
          loadingCity = false;
          printLog("Status Code OK");
          if (result['cities'] != null) {
            printLog("Cities :  ${result['cities']}");
            result['cities'].forEach((v) {
              cities.add(City.fromJson(v));
            });
            selectedCity = cities.first;
            _result = BasicResponse(200, "Success");
          } else {
            _result = BasicResponse(500, "Failed");
          }
          notifyListeners();
          return _result;
        } else {
          loadingCity = false;
          printLog("CITIES : OKE");
          _result = BasicResponse(500, result['message']);
          notifyListeners();
          return _result;
        }
      } catch (e) {
        loadingCity = false;
        printLog(e.toString(), name: "Error");
        _result = BasicResponse(500, e.toString());
        notifyListeners();
        return _result;
      }
    }
  }

  bool loadingSub = true;
  List<Subdistrict> subdistrict = [];

  Future<BasicResponse?> fetchSubdistrict(
      {String? id, List<BillingAddress>? bill}) async {
    BasicResponse? _result;
    loadingSub = true;
    subdistrict.clear();
    if (bill![1].type == "dropdown_woongkir") {
      print("a");
      try {
        var response = await baseAPI.getAsync('cities?id=$id', isCustom: true);
        final result = json.decode(response.body);
        printLog("subdistrict : ${result}");
        if (result != null) {
          loadingSub = false;
          printLog("Status Code OK");
          if (result['subdistricts'] != null) {
            printLog("Subdistricts :  ${json.encode(result['subdistricts'])}");
            result['subdistricts'].forEach((v) {
              subdistrict.add(Subdistrict.fromJson(v));
            });
            selectedSubdistrict = subdistrict.first;
            _result = BasicResponse(200, "Success");
          } else {
            _result = BasicResponse(500, "Failed");
          }
          notifyListeners();
          return _result;
        } else {
          loadingSub = false;
          printLog("Subdistrict : OKE");
          _result = BasicResponse(500, result['message']);
          notifyListeners();
          return _result;
        }
      } catch (e) {
        loadingSub = false;
        printLog(e.toString(), name: "Error");
        _result = BasicResponse(500, e.toString());
        notifyListeners();
        return _result;
      }
    }
  }

  Future<bool> fetchCountries() async {
    loading = true;
    bool _isSuccess = false;
    try {
      var response = await baseAPI.getAsync('data/countries');

      countries = [];
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);

        for (Map item in responseJson) {
          countries!.add(CountriesModel.fromJson(item));
        }

        selectedCountries = countries!.first;
        selectedStates = countries!.first.states!.first;
        loading = false;
        _isSuccess = true;
        notifyListeners();
      } else {
        loading = false;
        _isSuccess = false;
        notifyListeners();
      }
    } catch (e) {
      loading = false;
      _isSuccess = false;
      notifyListeners();
    }
    return _isSuccess;
  }

  String? countryName;
  String? stateName;

  setCountries(value) {
    if (value != null) {
      print(value);
      countries!.forEach((element) {
        if (element.code == value) {
          print("Found");
          countryName = element.name;
          selectedCountries = element;
          notifyListeners();
          if (selectedCountries!.states!.isNotEmpty) {
            printLog("states : ${selectedCountries!.states!.first}");
            selectedStates = selectedCountries!.states!.first;
            stateName = selectedCountries!.states!.first.name;
            notifyListeners();
          } else {
            selectedStates = null;
          }
        }
      });
    }
    notifyListeners();
  }

  setStates(value) {
    if (selectedCountries!.states!.isNotEmpty) {
      List<States> _states = selectedCountries!.states!;
      selectedStates = value == null ? null : _states.first;
      if (value != null) {
        print(value);
        _states.forEach((element) {
          if (element.code == value) {
            print("Found");
            stateName = element.name;
            selectedStates = element;
          } else {
            selectedCity = null;
          }
        });
      }
    }
    notifyListeners();
  }

  City? selectedCity;

  setCity(value) {
    if (cities.isNotEmpty) {
      List<City> _cities = cities;
      selectedCity = value == null ? null : _cities.first;
      String temps = "";
      for (int i = 0; i < cities.length; i++) {
        if (cities[i].cityId == value) {
          temps = cities[i].value!;
        }
      }
      printLog(json.encode(cities), name: "kota");
      final kota = temps.split(" ");
      String tempKota = kota[1];
      if (value != null) {
        _cities.forEach((element) {
          if (element.value == temps) {
            print("Found");
            selectedCity = element;
            print("b : $selectedCity");
          }
        });
      }
    }
    notifyListeners();
  }

  Subdistrict? selectedSubdistrict;

  setSubdistrict(value) {
    if (subdistrict.isNotEmpty) {
      printLog("c : $value");
      List<Subdistrict> _subdistrict = subdistrict;
      printLog(value.toString());
      selectedSubdistrict = value == null ? null : _subdistrict.first;
      String temps = "";
      for (int i = 0; i < subdistrict.length; i++) {
        if (subdistrict[i].subdistrictId == value) {
          temps = subdistrict[i].subdistrictName!;
        }
      }
      if (value != null) {
        _subdistrict.forEach((element) {
          if (element.subdistrictName == temps) {
            print("Found");
            selectedSubdistrict = element;
            print("b : $selectedSubdistrict");
          }
        });
      }
    }
    notifyListeners();
  }

  String convertState(country, state) {
    String _name = state ?? "";
    if (country != null && country != '') {
      if (countries!.isNotEmpty) {
        countries!.forEach((element) {
          if (element.code == country) {
            if (state != null && state != '' && element.states!.isNotEmpty) {
              element.states!.forEach((st) {
                if (st.code == state) {
                  _name = st.name!;
                }
              });
            }
          }
        });
      }
    }
    return _name;
  }

  String convertCountry(country) {
    String _name = country ?? "";
    if (country != null && country != '') {
      if (countries!.isNotEmpty) {
        countries!.forEach((element) {
          if (element.code == country) {
            _name = element.name!;
          }
        });
      }
    }
    return _name;
  }
}
