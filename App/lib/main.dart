import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/app.dart';
import 'package:solimage/utils/firebase.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await firebaseInit();
  FlutterError.onError = (errorDetails) => Future.wait([
        // Fluttertoast.showToast(msg: errorDetails.toStringShort()),
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails)
      ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const ProviderScope(child: SolimageApp()));
}
