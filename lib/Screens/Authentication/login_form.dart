import '../../constant.dart';
import 'forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/repository/login_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Authentication/register_form.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key, this.isEmailLogin = false}) : super(key: key);

  final bool isEmailLogin;

  @override
  // ignore: library_private_types_in_public_api
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool showPassword = true;
  bool firsttime = true;
  // late String email, password;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer(builder: (context, ref, child) {
          final loginProvider = ref.watch(logInProvider);
          if (firsttime == true) {
            print("asdsadsa");
            loginProvider.setdata();
            firsttime = false;
          }

          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 80,
                    child: Image.asset(
                      'images/logoandname.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: globalKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: loginProvider.emailtext,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: lang.S.of(context).emailText,
                              hintText:
                                  lang.S.of(context).enterYourEmailAddress,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email can\'n be empty';
                              } else if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              loginProvider.email = value!;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            controller: loginProvider.passwordtext,
                            obscureText: showPassword,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: lang.S.of(context).password,
                              hintText: lang.S.of(context).pleaseEnterAPassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                icon: Icon(showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password can\'t be empty';
                              } else if (value.length < 4) {
                                return 'Please enter a bigger password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              loginProvider.password = value!;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          const ForgotPassword().launch(context);
                          // Navigator.pushNamed(context, '/forgotPassword');
                        },
                        child: Text(
                          lang.S.of(context).forgotPassword,
                          style: GoogleFonts.inter(
                            color: kGreyTextColor,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ],
                  ).visible(widget.isEmailLogin),

                  ButtonGlobalWithoutIcon(
                      buttontext: lang.S.of(context).logIn,
                      buttonDecoration:
                          kButtonDecoration.copyWith(color: kMainColor),
                      onPressed: () {
                        if (validateAndSave()) {
                          loginProvider.signIn(
                              context, widget.isEmailLogin == true ? 0 : 1);
                        }
                      },
                      buttonTextColor: Colors.white),
                  Align(
                    alignment: Alignment.center,
                    child: CheckboxListTile(
                      activeColor: kMainColor,
                      title: Text("Remember me"),
                      value: loginProvider.checked,
                      onChanged: (newValue) {
                        if (validateAndSave()) {
                          setState(() {
                            loginProvider.checked = !loginProvider.checked;
                          });

                          if (loginProvider.checked) {
                            print("----remeber-----");
                            loginProvider.remeberpassword(loginProvider.checked,
                                loginProvider.email, loginProvider.password);
                            // ref.refresh(logInProvider);
                          } else {
                            print("----reset-----");
                            loginProvider.resetember();
                            // ref.refresh(logInProvider);
                          }
                        }
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lang.S.of(context).noAcc,
                        style: GoogleFonts.inter(
                            color: kGreyTextColor, fontSize: 15.0),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigator.pushNamed(context, '/signup');
                          const RegisterScreen().launch(context);
                        },
                        child: Text(
                          lang.S.of(context).register,
                          style: GoogleFonts.inter(
                            color: kMainColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).visible(widget.isEmailLogin),

                  TextButton(
                    onPressed: () {
                      const LoginForm(isEmailLogin: false).launch(context);
                    },
                    child: Text(
                      lang.S.of(context).staffLogin,
                      style: TextStyle(color: kMainColor),
                    ),
                  ).visible(widget.isEmailLogin),
                  // TextButton(
                  //   onPressed: () {
                  //     const PhoneAuth().launch(context);
                  //   },
                  //   child: Text(
                  //     lang.S.of(context).loginWithPhone,
                  //     style: TextStyle(color: kMainColor),
                  //   ),
                  // ).visible(widget.isEmailLogin),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
