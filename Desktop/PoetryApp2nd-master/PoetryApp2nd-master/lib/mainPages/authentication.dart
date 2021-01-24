import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Author: Birol
// This file deals with signing into Google or with your email.
// Basically it's the same as the Facebook authentication, but for Google or an email address.
// This code also signs a user up if they are using their email address for the first time.

FirebaseAuth auth = FirebaseAuth.instance;
final gooleSignIn = GoogleSignIn();

// a simple sialog to be visible everytime some error occurs
showErrDialog(BuildContext context, String err) {
  // to hide the keyboard, if it is still p
  FocusScope.of(context).requestFocus(new FocusNode());
  return showDialog(
    context: context,
    child: AlertDialog(
      title: Text("Error"),
      content: Text(err),
      actions: <Widget>[
        OutlineButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Ok"),
        ),
      ],
    ),
  );
}

// A custom function that signs people in using their Google account.
Future<bool> googleSignIn() async {
  GoogleSignInAccount googleSignInAccount =
      await gooleSignIn.signIn(); // The Google account of the user is obtained.

  if (googleSignInAccount != null) {
    // If the Google account is real, the authentication process is started.
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
        // The user's authentication credentials are obtained.
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    AuthResult result = await auth.signInWithCredential(credential);

    FirebaseUser user = await auth.currentUser();

    Firestore
        .instance // The user's name is stored onto a database if they are a new user.
        .collection('User-Database')
        .document(user.uid)
        .setData({'key': 1});

    return Future.value(
        true); // The future value is returned as true in order to avoid any errors if one wishes to not log in
    // when the dialog is active.
  }
}

// instead of returning true or false
// returning user to directly access UserID
Future<FirebaseUser> signin(
    // This function signs a user in using their email and password.
    String email,
    String password,
    BuildContext context) async {
  try {
    AuthResult result = // authenticating results.
        await auth.signInWithEmailAndPassword(email: email, password: password);
    FirebaseUser user = result.user;
    //return Future.value(true);
    return Future.value(user);
  } catch (e) {
    // simply passing error code as a message
    print(e.code);
    switch (e.code) {
      case 'ERROR_INVALID_EMAIL':
        showErrDialog(context, e.code);
        break;
      case 'ERROR_WRONG_PASSWORD':
        showErrDialog(context, e.code);
        break;
      case 'ERROR_USER_NOT_FOUND':
        showErrDialog(context, e.code);
        break;
      case 'ERROR_USER_DISABLED':
        showErrDialog(context, e.code);
        break;
      case 'ERROR_TOO_MANY_REQUESTS':
        showErrDialog(context, e.code);
        break;
      case 'ERROR_OPERATION_NOT_ALLOWED':
        showErrDialog(context, e.code);
        break;
    }
    // since we are not actually continuing after displaying errors
    // the false value will not be returned
    // hence we don't have to check the value returned in from the signin function
    // whenever we call it anywhere
    return Future.value(null);
  }
}

// change to Future<FirebaseUser> for returning a user
Future<FirebaseUser> signUp(
    // This function signs a user up for the first time using their email.
    String email,
    String password,
    BuildContext context) async {
  try {
    AuthResult result = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return Future.value(user);
    // return Future.value(true);
  } catch (error) {
    switch (error.code) {
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        showErrDialog(context, "Email Already Exists");
        break;
      case 'ERROR_INVALID_EMAIL':
        showErrDialog(context, "Invalid Email Address");
        break;
      case 'ERROR_WEAK_PASSWORD':
        showErrDialog(context, "Please Choose a stronger password");
        break;
    }
    return Future.value(null);
  }
}

Future<bool> signOutUser() async {
  // This function signs out users that are using their Google email.
  FirebaseUser user = await auth.currentUser();
  print(user.providerData[1].providerId);
  if (user.providerData[1].providerId == 'google.com') {
    await gooleSignIn.disconnect();
  }
  await auth.signOut();
  return Future.value(true);
}
