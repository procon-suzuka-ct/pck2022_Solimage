import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/observers/system_ui.dart';
import 'package:solimage/routes/child/camera.dart';
import 'package:solimage/routes/child/history.dart';
import 'package:solimage/routes/child/result.dart';
import 'package:solimage/routes/parent/parent.dart';
import 'package:solimage/routes/parent/post.dart';
import 'package:solimage/routes/welcome.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/states/preferences.dart';
import 'package:solimage/utils/stream_listenable.dart';

final List<Map<String, dynamic>> routes = [
  {'path': '/child/camera', 'child': const CameraScreen()},
  {'path': '/child/history', 'child': const HistoryScreen()},
  {'path': '/parent', 'child': const ParentScreen()},
  {'path': '/', 'child': const WelcomeScreen()}
];

final routerProvider = Provider((ref) => GoRouter(
    initialLocation: '/',
    routes: [
      ...routes.map((route) => GoRoute(
            path: route['path'],
            name: route['path'],
            builder: (context, state) => SafeArea(child: route['child']),
          )),
      GoRoute(
          path: '/child/result',
          name: '/child/result',
          builder: (context, state) =>
              SafeArea(child: ResultScreen(word: state.queryParams['word']!))),
      GoRoute(
          path: '/parent/post',
          name: '/parent/post',
          builder: (context, state) => SafeArea(
              child: PostScreen(expDataId: state.queryParams['expDataId']))),
    ],
    observers: [SystemUiObserver()],
    redirect: (context, state) async {
      final auth = await ref.read(authProvider.future);
      final prefs = await ref.read(prefsProvider.future);

      WidgetsBinding.instance
          .addPostFrameCallback((_) => FlutterNativeSplash.remove());

      if (auth == null) {
        if (state.subloc != '/') {
          return '/';
        }
      } else if (state.subloc == '/') {
        final mode = prefs.getInt('mode');
        if (mode == 0) {
          return '/parent';
        } else if (mode == 1) {
          return '/child/camera';
        }
      }
      return null;
    },
    refreshListenable:
        Listenable.merge([StreamListenable(ref.watch(authProvider.stream))]),
    debugLogDiagnostics: true));
