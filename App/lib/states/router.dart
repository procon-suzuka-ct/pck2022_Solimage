import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/routes/camera.dart';
import 'package:solimage/routes/image.dart';
import 'package:solimage/routes/parent.dart';
import 'package:solimage/routes/post.dart';
import 'package:solimage/routes/welcome.dart';
import 'package:solimage/states/auth.dart';

final routerProvider = Provider((ref) => GoRouter(
    initialLocation: '/camera',
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const SafeArea(child: WelcomeScreen()),
      ),
      GoRoute(
          path: '/camera',
          name: 'camera',
          builder: (context, state) => const SafeArea(child: CameraScreen())),
      GoRoute(
          path: '/image',
          name: 'image',
          builder: (context, state) => const SafeArea(child: ImageScreen())),
      GoRoute(
          path: '/parent',
          name: 'parent',
          builder: (context, state) => const SafeArea(child: ParentScreen())),
      GoRoute(
        path: '/post',
        name: 'post',
        builder: (context, state) => const SafeArea(child: PostScreen()),
      )
    ],
    redirect: (state) {
      final isLoggedIn = ref.watch(authProvider).currentUser() != null;
      if (!isLoggedIn) {
        return state.subloc == '/' ? null : '/';
      }

      return null;
    }));
