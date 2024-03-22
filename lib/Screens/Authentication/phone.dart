import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/Screens/Authentication/phone_OTP_screen.dart';
import 'package:mobile_pos/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'login_form.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({Key? key}) : super(key: key);
  static String verify = '';
  static String phoneNumber = '';

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  TextEditingController countryController = TextEditingController();

  String phoneNumber = '';
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    countryController.text = "+91";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/logoandname.png',
                height: 50,
              ),
              const SizedBox(height: 25),
              Text(
                lang.S.of(context).phoneVerification,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                lang.S.of(context).registerTitle,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: countryController,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Text(
                      "|",
                      style: TextStyle(fontSize: 33, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                      onChanged: (value) {
                        phoneNumber = value;
                        PhoneAuth.phoneNumber = value;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Phone",
                      ),
                    ))
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kMainColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      if (phoneNumber.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Please enter phone number")));
                        return;
                      }
                      if (phoneNumber.length < 10 || phoneNumber.length > 10) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Please enter valid phone number")));
                        return;
                      }
                      EasyLoading.show(status: 'Loading', dismissOnTap: false);
                      try {
                        var activestatus =
                            await checkactiveostatus(phoneNumber);
                        if (activestatus == 1) {
                          await FirebaseAuth.instance.verifyPhoneNumber(
                            phoneNumber: countryController.text + phoneNumber,
                            verificationCompleted:
                                (PhoneAuthCredential credential) {},
                            verificationFailed: (FirebaseAuthException e) {},
                            codeSent:
                                (String verificationId, int? resendToken) {
                              EasyLoading.dismiss();
                              PhoneAuth.verify = verificationId;
                              const OTPVerify().launch(context);
                            },
                            codeAutoRetrievalTimeout:
                                (String verificationId) {},
                          );
                        } else {
                          EasyLoading.dismiss();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please Contact BestBills Team to Active Your Account'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      } catch (e) {
                        EasyLoading.showError('Error');
                      }
                    },
                    child: Text(lang.S.of(context).sendCode)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      const LoginForm(isEmailLogin: false).launch(context);
                    },
                    child: Text(lang.S.of(context).staffLogin, style: TextStyle(color: kMainColor),),
                  ),
                  Flexible(
                    child: TextButton(
                      onPressed: () {
                        const LoginForm(isEmailLogin: true).launch(context);
                      },
                      
                      child: Text(
                        lang.S.of(context).logInWithMail,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(color: kMainColor),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  checkactiveostatus(number) async {
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
        if (data['phoneNumber'].toString() == number) {
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
}
