import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Screens/Authentication/success_screen.dart';

final logInProvider = ChangeNotifierProvider((ref) => LogInRepo());

class LogInRepo extends ChangeNotifier {
  TextEditingController emailtext = TextEditingController();
  TextEditingController passwordtext = TextEditingController();
  String email = '';
  String password = '';
  bool checked = false;
  checkactiveostatus(email) async {
    String key = '';
    var sellerdata = [];

    await FirebaseDatabase.instance
        .ref()
        .child('Admin Panel')
        .child('Seller List')
        .orderByKey()
        .get()
        .then((value) async {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['email'].toString() == email) {
          key = element.key.toString();
        }
      }
    });
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("Admin Panel/Seller List/$key");
    var data = await ref.get();
    for (var element in data.children) {
      sellerdata.add(element.value);
    }
    return sellerdata[0];
  }

  setdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();

    email = prefs.getString('email') == null
        ? ""
        : prefs.getString('email').toString();
    emailtext.text = prefs.getString('email') == null
        ? ""
        : prefs.getString('email').toString();
    print("email" + email.toString());
    password = prefs.getString('password') == null
        ? ""
        : prefs.getString('password').toString();
    passwordtext.text = prefs.getString('password') == null
        ? ""
        : prefs.getString('password').toString();
    checked = prefs.getBool('remeber') == null
        ? false
        : prefs.getBool('remeber') as bool;
    notifyListeners();
  }

  Future<void> signIn(BuildContext context, [stafflogin = 0]) async {
    EasyLoading.show(status: 'Login...');
    try {
      final prefs = await SharedPreferences.getInstance();
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print(userCredential.user?.email.toString());
      // ignore: unnecessary_null_comparison
      if (userCredential != null) {
        var activestatus = await checkactiveostatus(email);
        print("satff login.." + stafflogin.toString());
        if (stafflogin == 0) {
          if (activestatus == 1) {
            EasyLoading.showSuccess('Successful')
                .then((value) => prefs.setBool('isfirsttime', true));
            print("asdsadsads" + prefs.getBool('remeber').toString());
            if (prefs.getBool('remeber') == true) {
              remeberpasswordlogin(email, password, true);
              notifyListeners();
            } else {
              print("---reset-----");
              resetember();
              email = "";
              password = "";
              notifyListeners();
            }
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SuccessScreen(
                          email: email,
                        )),
              );
            });
          } else {
            EasyLoading.dismiss();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Please Contact BestBills Team to Active Your Account'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        } else {
          EasyLoading.showSuccess('Successful')
              .then((value) => prefs.setBool('isfirsttime', true));
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SuccessScreen(
                        email: email,
                      )),
            );
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      EasyLoading.showError(e.message.toString());
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found for that email.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong password provided for that user.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      EasyLoading.showError('Failed with Error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  remeberpassword(value, email, password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);
    prefs.setBool('remeber', value);
  }

  remeberpasswordlogin(email, password, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);
    prefs.setBool('remeber', value);
  }

  resetember() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
