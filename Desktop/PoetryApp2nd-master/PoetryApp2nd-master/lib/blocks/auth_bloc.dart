import 'package:projectname/servicesFace/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:projectname/mainPages/tasks.dart';

// Author: Birol
// In auth_bloc.dart, the authentication services for Facebook are handled.

class AuthBloc {
  final authService =
      AuthService(); // authServices calls a class that handles Login and Logout methods.
  final fb =
      FacebookLogin(); // Calls an object of the FacebookLogin class that allows you to log into the app using Facebook.

  Stream<FirebaseUser> get currentUser => authService
      .currentUser; // The Facebook user's credentials are obtained for login.

  loginFacebook() async {
    // A more formalized function that logs a user into Argot using Facebook.
    print('Starting Facebook Login');

    final res = await fb.logIn(permissions: [
      // Gathering permissions from the Facebook application in order to log in.
      FacebookPermission.publicProfile,
      FacebookPermission.email
    ]);

    switch (res.status) {
      // Depending on if the permissions are valid or not, the user is either logged in or not.
      case FacebookLoginStatus.Success:
        print('It worked');

        //Get Token
        final FacebookAccessToken fbToken = res.accessToken;

        //Convert to Auth Credential
        final AuthCredential credential =
            FacebookAuthProvider.getCredential(accessToken: fbToken.token);

        //User Credential to Sign in with Firebase
        final result = await authService.signInWithCredentail(credential);

        print('${result.user.displayName} is now logged in');
        inputData1(); // In the case of a successful login, the uid of the user is grabbed so that the user can access their own
        //  Firebase data.

        break;
      case FacebookLoginStatus.Cancel:
        print('The user canceled the login');
        break;
      case FacebookLoginStatus.Error:
        print('There was an error');
        break;
    }
  }

  logout() {
    authService.logout();
  }
}
