import 'package:firebase_core/firebase_core.dart';

Future<FirebaseApp> firebaseInit() async {
  return await Firebase.initializeApp();
}
