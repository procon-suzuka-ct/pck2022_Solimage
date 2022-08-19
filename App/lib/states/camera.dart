import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/app.dart';

final controllerProvider = FutureProvider((ref) async {
  final lifecycle = ref.watch(appLifecycleProvider);
  final controller = CameraController(
      (await availableCameras()).first, ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.yuv420, enableAudio: false);

  if (controller.value.isInitialized) {
    if (lifecycle == AppLifecycleState.paused) controller.dispose();
  } else {
    if (lifecycle == AppLifecycleState.resumed) await controller.initialize();
  }

  return controller;
});

final imagePathProvider = StateProvider<String?>((ref) => null);