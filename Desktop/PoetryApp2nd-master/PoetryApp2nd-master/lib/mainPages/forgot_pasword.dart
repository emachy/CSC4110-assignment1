import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projectname/localization/l10n/language_constants.dart';

// Author: Birol
// This file deals with the Forgot Password Screen.  Here you can recover a lost password.

class ForgotPasswordScreen extends StatelessWidget {
  TextEditingController editController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
          child: Column(children: <Widget>[
        ClipRRect(
          borderRadius:
              BorderRadius.all(Radius.circular(20.0)), //add border radius here
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
            getTranslated(context, 'reset_password'),
            style: TextStyle(
              fontSize: 30.0,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: editController,
                decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Enter Email",
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  color: Colors.amber,
                  onPressed: () {
                    resetPassword(context);
                  },
                  child: Text(
                    "Reset password",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ])),
    ));
  }

  void resetPassword(BuildContext context) async {
    // This function resets a user's password if they enter the correct email.
    if (editController.text.length == 0 || !editController.text.contains("@")) {
      // If an accurate email is not entered, then the
      // function will not run.

      Fluttertoast.showToast(msg: "Enter valid email");
      return;
    }

    await FirebaseAuth
        .instance // The Firebase function will send the user an email to reset their password.
        .sendPasswordResetEmail(email: editController.text);
    Fluttertoast.showToast(
        msg:
            "Reset password link has sent your mail please use it to change the password.");
    Navigator.pop(context);
  }
}
