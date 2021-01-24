import 'package:firebase_auth/firebase_auth.dart';

// Author: Birol
// In auth_services.dart, a class is defined that has methods that get the current user's credentials on login and a method that
// uses a user's credentials to logout of a program.

class AuthService {
  final _auth = FirebaseAuth
      .instance; // The entry point of the Firebase authentication SDK.

  Stream<FirebaseUser> get currentUser => _auth
      .onAuthStateChanged; // Grabs the current user's credentials on login.
  Future<AuthResult> signInWithCredentail(
          AuthCredential
              credential) => // Allows the user to sign in with their credentials.
      _auth.signInWithCredential(credential);
  Future<void> logout() =>
      _auth.signOut(); // Allows the user to sign out using their credentials.
}
