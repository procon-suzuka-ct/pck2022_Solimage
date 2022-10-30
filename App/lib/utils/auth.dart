import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final _auth = FirebaseAuth.instance;

  //singleton
  static final Auth _instance = Auth._internal();
  Auth._internal();
  factory Auth() => _instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  GoogleSignInAccount? googleUser;

  final googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<User?> signIn() async {
    GoogleSignInAuthentication googleAuth;
    AuthCredential credential;

    try {
      googleUser = await googleSignIn.signIn();
    } catch (_) {
      return null;
    }

    if (googleUser != null) {
      googleAuth = await googleUser!.authentication;
      try {
        credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
      } catch (_) {
        return null;
      }

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

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await _auth.signOut();
    return;
  }

  User? currentUser() {
    return _auth.currentUser;
  }
}
