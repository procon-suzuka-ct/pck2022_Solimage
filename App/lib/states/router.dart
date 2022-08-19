import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/routes/child/camera.dart';
import 'package:solimage/routes/child/favorite.dart';
import 'package:solimage/routes/child/image.dart';
import 'package:solimage/routes/parent/parent.dart';
import 'package:solimage/routes/parent/post.dart';
import 'package:solimage/routes/welcome.dart';
import 'package:solimage/states/auth.dart';

final List<Map<String, dynamic>> routes = [
  {'path': '/', 'name': 'welcome', 'child': const WelcomeScreen()},
  {'path': '/child/camera', 'name': 'camera', 'child': const CameraScreen()},
  {
    'path': '/child/favorite',
    'name': 'favorite',
    'child': const FavoriteScreen()
  },
  {'path': '/child/image', 'name': 'image', 'child': const ImageScreen()},
  {'path': '/parent', 'name': 'parent', 'child': const ParentScreen()},
  {'path': '/parent/post', 'name': 'post', 'child': const PostScreen()}
];

final routerProvider = Provider((ref) => GoRouter(
    initialLocation: '/child/camera',
    routes: routes
        .map((route) => GoRoute(
              path: route['path'],
              name: route['name'],
              builder: (context, state) => SafeArea(child: route['child']),
            ))
        .toList(),
    redirect: (state) {
      if (!(ref.watch(authProvider).currentUser() != null)) {
        return state.subloc == '/' ? null : '/';
      }

      return null;
    }));
