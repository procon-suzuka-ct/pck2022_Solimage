import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/routes/camera.dart';
import 'package:solimage/routes/image.dart';
import 'package:solimage/routes/welcome.dart';

final routerProvider =
    Provider((ref) => GoRouter(initialLocation: '/', routes: [
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
              builder: (context, state) => const ImageScreen())
        ]));
