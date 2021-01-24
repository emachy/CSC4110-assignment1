import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectname/mainPages/authentication.dart';
import 'package:projectname/localization/l10n/language_constants.dart';
import 'package:projectname/mainPages/loginScreen.dart';
//import 'package:projectname/tasks.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:projectname/mainPages/tasks.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import '../blocks/auth_bloc.dart';
import 'package:projectname/blocks/auth_bloc.dart';

import 'package:provider/provider.dart';

// Author: Birol
// This is the sign up page.  Users can sign up here for the first time using their emails.

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String email;
  String password;
  GlobalKey<FormState> formkey = GlobalKey<
      FormState>(); // The form keys are used for authentication purposes.
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  void handleSignup() {
    // The user is signed up for the first time.
    if (formkey.currentState.validate()) {
      // If the email and password is valid, the user is registered.
      formkey.currentState.save();
      signUp(email.trim(), password, context).then((value) {
        if (value != null) {
          inputData1(); // The user's uid is grabbed.
          //add user to database so that errors don't result
          Firestore.instance
              .collection('User-Database')
              .document(uid)
              .setData({'key': 1});

          Navigator.pushReplacement(
              // The user is brought to the home page.
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(), //simple fix
              ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var authBloc = Provider.of<AuthBloc>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(
                    Radius.circular(20.0)), //add border radius here
                child: Container(
                  height: 150.0,
                  width: 150.0,
                  child: Image.asset(
                    'images/logo/logo.png',
                  ), //add image location here
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  getTranslated(context, 'signup_here'),
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.90,
                child: Form(
                  key: formkey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: getTranslated(context, 'email')),
                        validator: (_val) {
                          // checking if the email is valid
                          if (_val.isEmpty) {
                            return getTranslated(context, 'empty_email');
                          } else {
                            return null;
                          }
                        },
                        onChanged: (val) {
                          email = val;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: getTranslated(context, 'password')),
                          validator: MultiValidator([
                            // Checking if the password is valid.
                            RequiredValidator(
                                errorText:
                                    getTranslated(context, 'empty_password')),
                            MinLengthValidator(6,
                                errorText:
                                    getTranslated(context, 'invailed_password'))
                          ]),
                          controller: _pass,
                          onChanged: (val) {
                            password = val;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText:
                                  getTranslated(context, 'confirm_password')),
                          validator: (val) => MatchValidator(
                                  // Making sure that the passwords match
                                  errorText: getTranslated(
                                      context, 'password_notMatch'))
                              .validateMatch(val, password),
                        ),
                      ),
                      RaisedButton(
                        // When this button is pressed, the user is signed in.
                        onPressed: handleSignup,
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text(
                          "Sign Up",
                        ),
                      ),
                      // If the user does not want to sign up, they can just use the other methods provided to them.
                      SignInButton(Buttons.Facebook,
                          onPressed: () => authBloc.loginFacebook()),
                      SignInButton(
                        Buttons.Google,
                        onPressed: () => googleSignIn().whenComplete(() async {
                          FirebaseUser user =
                              await FirebaseAuth.instance.currentUser();
                          //print('The user ID is');
                          //print(user.uid); //testing to see what's passed

                          inputData1(); //this gets the user id

                          if (user != null) {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => MyHomePage()));
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  // send to login screen
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Text(
                  getTranslated(context, 'login_here'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
