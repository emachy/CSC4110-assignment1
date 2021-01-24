import 'package:flutter/material.dart';
import 'package:projectname/mainPages/authentication.dart';
import 'package:projectname/mainPages/forgot_pasword.dart';
import 'package:projectname/localization/l10n/language.dart';
import 'package:projectname/localization/l10n/language_constants.dart';
import 'package:projectname/mainPages/main.dart';
import 'package:projectname/mainPages/signupScreen.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'tasks.dart';
import 'dart:async';
import 'package:projectname/blocks/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

// Author: Birol, Ervin, Khaled
// This file deals with the page that allows you to login through your email, Google account, or Facebook account.
// This page also has links to other pages, such as the "Forgot my Password Page" and the "Sign Up" page.

// Author Birol ---

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StreamSubscription<FirebaseUser> loginStateSubscription;

  String email;
  String password;

  // add localization
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  @override
  void initState() {
    inputData1(); // This function grabs the uid before the user can be autologged into the system.
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    loginStateSubscription = authBloc.currentUser.listen((fbUser) {
      // If there is a Firebase user, the user can proceed to be logged in.
      if (fbUser != null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MyHomePage()));
      }
    });
    super.initState();
  }

  GlobalKey<FormState> formkey = GlobalKey<
      FormState>(); // This variable is used to check both the email and password fields of
  // the program.

  //-----------------------------------Birol Done

// Ervin
  void login() {
    // This function logins users using their email addresses.
    if (formkey.currentState.validate()) {
      formkey.currentState.save();
      signin(email, password, context).then((value) {
        if (value != null) {
          inputData1(); // This function grabs the uid before the user can be autologged into the system.
          profileSet(); // This creates a new user profile for a new user.
          //add user to database so that errors don't result
          Firestore.instance
              .collection('User-Database')
              .document(uid)
              .setData({'key': 1});
          Navigator.pushReplacement(
              // Navigate to the homepage.
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(),
              ));
        }
      });
    }
  }

// -------------------------------------------
// Author Birol ------------------------

  @override
  Widget build(BuildContext context) {
    var authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          // drop menue to select lang
          DropdownButton<Language>(
            underline: SizedBox(),
            icon: Icon(
              Icons.language,
              color: Colors.white,
            ),
            onChanged: (Language language) {
              _changeLanguage(language);
            },
            items: Language.languageList()
                .map<DropdownMenuItem<Language>>(
                  (e) => DropdownMenuItem<Language>(
                    value: e,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          e.flag,
                          style: TextStyle(fontSize: 30),
                        ),
                        Text(e.name)
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        title: Text(getTranslated(context, 'title')),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(
                    Radius.circular(20.0)), //add border radius here

//---------------------------

                // Ervin
                child: Container(
                  height: 150.0,
                  width: 150.0,
                  child: Image.asset(
                    'images/logo/logo.png',
                  ), //add image location here
                ),
                //---------------
              ),

              // Author Birol ------------------

              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  getTranslated(context, 'login_here'),
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
              ),

              //----------------------- Birol Done
              Container(
                width: MediaQuery.of(context).size.width * 0.90,
                child: Form(
                  key: formkey,
                  child: Column(
                    children: <Widget>[
                      // Ervin
                      TextFormField(
                        // text field for entering the email on the login page
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: getTranslated(context, 'email')),
                        validator: MultiValidator([
                          RequiredValidator(
                              errorText: getTranslated(context, 'empty_email')),
                          EmailValidator(
                              // Here the user's email address is evaluated.
                              errorText:
                                  getTranslated(context, 'invailed_email')),
                        ]),
                        onChanged: (val) {
                          email = val;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: TextFormField(
                          // text field for entering the password on the login page
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: getTranslated(context, 'password')),
                          validator: MultiValidator([
                            RequiredValidator(
                                // Here the user's password is evaluated.
                                errorText:
                                    getTranslated(context, 'empty_password')),
                            MinLengthValidator(6,
                                errorText: getTranslated(
                                    context, 'invailed_password')),
                          ]),
                          onChanged: (val) {
                            password = val;
                          },
                        ),
                      ),
                      // ------------------------------------------------ Birol Done

                      // Author Birol -------

                      RaisedButton(
                        // Here the user can login using their email.
                        // passing an additional context parameter to show dialog boxs
                        onPressed: login,
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text(
                          getTranslated(context, 'login'),
                        ),
                      ),
                      SignInButton(Buttons.Facebook, // Facebook login
                          onPressed: () => authBloc.loginFacebook()),
                    ],
                  ),
                ),
              ),
              SignInButton(
                // Google login
                Buttons.Google,
                onPressed: () => googleSignIn().whenComplete(() async {
                  FirebaseUser user = await FirebaseAuth.instance.currentUser();

                  inputData1(); //this gets the user id

                  if (user != null) {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                  }
                }),
              ),
              GestureDetector(
                child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(getTranslated(context, 'signup_here'))),
                onTap: () {
                  // send to login screen
                  Navigator.of(context).push(// Navigation to the sign up page.
                      MaterialPageRoute(builder: (context) => SignUpScreen()));
                },
              ),
              GestureDetector(
                child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(getTranslated(context, 'forget_password'))),
                onTap: () {
                  Navigator.push(
                      // Navigation to the forgot my password page.
                      context,
                      MaterialPageRoute(
                          builder: (_) => ForgotPasswordScreen()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

//---------------------------------------------- Birol Done
