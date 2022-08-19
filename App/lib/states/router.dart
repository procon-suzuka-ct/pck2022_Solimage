import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/routes/camera.dart';
import 'package:solimage/routes/image.dart';
import 'package:solimage/routes/parent.dart';
import 'package:solimage/routes/post.dart';
import 'package:solimage/routes/welcome.dart';
import 'package:solimage/states/auth.dart';

enum ParentScreens { history, user, group }

final routerProvider = Provider((ref) => GoRouter(
    initialLocation: '/camera',
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
          path: '/camera',
          name: 'camera',
          builder: (context, state) => const CameraScreen()),
      GoRoute(
          path: '/image',
          name: 'image',
          builder: (context, state) => const ImageScreen()),
      GoRoute(
          path: '/parent',
          name: 'parent',
          builder: (context, state) => const ParentScreen()),
      GoRoute(
        path: '/post',
        name: 'post',
        builder: (context, state) => const PostScreen(),
      )
    ],
    redirect: (state) {
      final isLoggedIn = ref.read(authProvider).currentUser() != null;
      if (!isLoggedIn) {
        return state.subloc == '/' ? null : '/';
      }

      return null;
    }));
