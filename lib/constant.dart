import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:mobile_pos/model/user_role_model.dart';
import 'package:firebase_database/firebase_database.dart';

// const kMainColor = Color(0xFF3F8CFF);
const kMainColor = Color(0xFF203354);
const kGreyTextColor = Color(0xFF828282);
const kBorderColorTextField = Color(0xFFC2C2C2);
const kDarkWhite = Color(0xFFF1F7F7);
const kPremiumPlanColor = Color(0xFF8752EE);
const kPremiumPlanColor2 = Color(0xFFFF5F00);
const kTitleColor = Color(0xFF000000);
const categorybackground = Color(0xFFD9E7E5);
const fontcolor = Color(0xFF225C78);
const bgseletedcolor = Color(0xFF81B2CA);
const bluetxtcolor = Color(0xFF122265);
const pricecolor = Color(0xFFEE1E5F);
const textcolor = Color(0xFF677294);
const hometextcolor = Color(0xFF4F4F4F);
bool connected = false;
bool isfirsttimelogin = false;
bool isprofilesetup = false;
bool isPrintEnable = false;
bool isPrintEnableqr = false;
bool isPrintEnablelogo = false;
List<String> paymentsTypeList = [
  'Cash',
  'UPI Payment',
  'Debit/Credit Card',
  'Credit/Due'
];
List<String> paymentsTypeListcollection = [
  'Cash',
  'UPI Payment',
  'Debit/Credit Card',
  'Credit/Due'
];

List<String> paymentsTypeFilterList = [
  'All',
  'Cash',
  'UPI Payment',
  'Debit/Credit Card',
  'Credit/Due'
];
List<String> paymentsTypeList1 = [
  'Cash',
  'UPI Payment',
  'Debit/Credit Card',
];
bool isExpiringInFiveDays = false;
bool isExpiringInOneDays = false;
const String appVersion = '5.3';
String paypalClientId = '';
String paypalClientSecret = '';
const bool sandbox = true;

String purchaseCode = '528cdb9a-5d37-4292-a2b5-b792d5eca03a';

const kButtonDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(
    Radius.circular(5),
  ),
);

const kInputDecoration = InputDecoration(
  hintStyle: TextStyle(color: kBorderColorTextField),
  filled: true,
  fillColor: Colors.white70,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: kBorderColorTextField, width: 2),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6.0)),
    borderSide: BorderSide(color: kBorderColorTextField, width: 2),
  ),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(1.0),
    borderSide: const BorderSide(color: kBorderColorTextField),
  );
}

final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

List<String> businessCategory = [
  'Fashion Store',
  'Electronics Store',
  'Computer Store',
  'Vegetable Store',
  'Sweet Store',
  'Meat Store'
];
List<String> language = ['English'];

List<String> productCategory = [
  'Fashion',
  'Electronics',
  'Computer',
  'Gadgets',
  'Watches',
  'Cloths'
];

///______________________________________________________________________________________________
String constUserId = '';
bool isSubUser = false;
String subUserTitle = '';
String subUserEmail = '';
bool isSubUserDeleted = true;
//

UserRoleModel finalUserRoleModel = UserRoleModel(
  email: '',
  userTitle: '',
  databaseId: '',
  salePermission: true,
  partiesPermission: true,
  purchasePermission: true,
  productPermission: true,
  profileEditPermission: true,
  addExpensePermission: true,
  lossProfitPermission: true,
  dueListPermission: true,
  stockPermission: true,
  reportsPermission: true,
  salesListPermission: true,
  purchaseListPermission: true,
);

class CurrentUserData {
  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    constUserId = prefs.getString('userId') ?? '';
    isSubUser = prefs.getBool('isSubUser') ?? false;
    subUserEmail = prefs.getString('subUserEmail') ?? '';
    await updateData();
  }

  Future<void> updateData() async {
    // bool subUserEmailMatch = false;
    final prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance.ref(constUserId).child('User Role');
    ref.keepSynced(true);
    ref.orderByKey().get().then((value) async {
      for (var element in value.children) {
        var data =
            UserRoleModel.fromJson(jsonDecode(jsonEncode(element.value)));
        if (data.email == subUserEmail) {
          isSubUserDeleted = false;
          finalUserRoleModel = data;
          await prefs.setString('userTitle', data.userTitle);
          subUserTitle = prefs.getString('userTitle') ?? '';
        }
      }
    });
  }

  Future<bool> isSubUserEmailNotFound() async {
    bool isMailMatch = true;
    final ref = FirebaseDatabase.instance.ref(constUserId).child('User Role');

    await ref.orderByKey().get().then((value) async {
      for (var element in value.children) {
        var data =
            UserRoleModel.fromJson(jsonDecode(jsonEncode(element.value)));
        if (data.email == subUserEmail) {
          isMailMatch = false;
          return;
        }
      }
    });
    return isMailMatch;
  }

  void putUserData(
      {required String userId,
      required bool isSubUser,
      required String title,
      required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('subUserEmail', email);
    await prefs.setString('userTitle', title);
    await prefs.setBool('isSubUser', isSubUser);
    getUserData();
  }
}

bool newSelect = false;
