import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/Home/home_screen.dart';
import 'package:mobile_pos/Screens/Report/reports.dart';
import 'package:mobile_pos/Screens/Settings/settings_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:restart_app/restart_app.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../constant.dart';
import '../Authentication/phone.dart';
import '../Sales/sales_contact.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool isNoInternet = false;
  var currentemail = "";
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SalesContact(),
    Reports(),
    SettingScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void signOutAutoLogin() async {
    CurrentUserData currentUserData = CurrentUserData();
    if (await currentUserData.isSubUserEmailNotFound() && isSubUser) {
      await FirebaseAuth.instance.signOut();
      Future.delayed(const Duration(milliseconds: 5000), () async {
        EasyLoading.showError('User is deleted');
      });
      Future.delayed(const Duration(milliseconds: 1000), () async {
        Restart.restartApp();
      });
    }
  }

  checkactiveostatus(email) async* {
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
    yield sellerdata[0];
  }

  @override
  void initState() {
    super.initState();
    isSubUser ? signOutAutoLogin() : null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        } else {
          return showAlertDialog(context, () async {
            exit(1);
          });
        }
      },
      child: Scaffold(
        body: StreamBuilder(
            stream:
                checkactiveostatus(FirebaseAuth.instance.currentUser!.email),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return snapshot.data == 0
                  ? Center(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "your Account is Deactive please Contact to your Admistrative",
                              style: GoogleFonts.inter(
                                fontSize: 16.0,
                                color: kGreyTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.blue,
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  PhoneAuth().launch(context);
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool('isSubUser', false);
                                },
                                child: Text(
                                  "Log Out",
                                  style: GoogleFonts.inter(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: _widgetOptions.elementAt(_selectedIndex),
                    );
            }),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 6.0,
          selectedItemColor: kMainColor,
          // ignore: prefer_const_literals_to_create_immutables
          items: [
            BottomNavigationBarItem(
              icon: const Icon(FeatherIcons.home),
              label: lang.S.of(context).home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(FeatherIcons.shoppingCart),
              label: lang.S.of(context).sales,
            ),
            BottomNavigationBarItem(
              icon: const Icon(FeatherIcons.fileText),
              label: lang.S.of(context).reports,
            ),
            BottomNavigationBarItem(
                icon: const Icon(FeatherIcons.settings),
                label: lang.S.of(context).setting),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, Function? ontap) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        ontap!();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Exit app"),
      content: Text("Are you sure want to exit app ?"),
      actions: [
        cancelButton,
        continueButton,
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
}
