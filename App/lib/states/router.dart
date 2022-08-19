import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/routes/camera.dart';
import 'package:solimage/routes/image.dart';
import 'package:solimage/routes/parent.dart';
import 'package:solimage/routes/post.dart';
import 'package:solimage/routes/welcome.dart';
import 'package:solimage/states/auth.dart';

final List<Map<String, dynamic>> routes = [
  {'path': '/', 'name': 'welcome', 'child': const WelcomeScreen()},
  {'path': '/camera', 'name': 'camera', 'child': const CameraScreen()},
  {'path': '/image', 'name': 'image', 'child': const ImageScreen()},
  {'path': '/parent', 'name': 'parent', 'child': const ParentScreen()},
  {'path': '/post', 'name': 'post', 'child': const PostScreen()}
];

final routerProvider = Provider((ref) => GoRouter(
    initialLocation: '/camera',
    routes: routes.map((route) {
      return GoRoute(
        path: route['path'],
        name: route['name'],
        builder: (context, state) => SafeArea(child: route['child']),
      );
    }).toList(),
    redirect: (state) {
      final isLoggedIn = ref.watch(authProvider).currentUser() != null;
      if (!isLoggedIn) {
        return state.subloc == '/' ? null : '/';
      }

      return null;
    }));
