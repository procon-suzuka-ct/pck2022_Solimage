import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  static final Auth _instance = Auth._internal();
  final _auth = FirebaseAuth.instance;
  Auth._internal();
  factory Auth() => _instance;

  FutureOr<User?> signIn() async {
    final googleSignin = GoogleSignIn(scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ]);
    GoogleSignInAccount? googleUser;
    GoogleSignInAuthentication googleAuth;
    AuthCredential credential;

    googleUser = await googleSignin.signIn();
    if (googleUser != null) {
      googleAuth = await googleUser.authentication;
      credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      try {
        final result = await _auth.signInWithCredential(credential);
        final user = result.user;
        if (user != null) {
          return user;
        }
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  FutureOr<void> signOut() async {
    return _auth.signOut();
  }

  FutureOr<User?> currentUser() async {
    return _auth.currentUser;
  }
}
