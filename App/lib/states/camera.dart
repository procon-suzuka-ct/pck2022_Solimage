import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/app.dart';

final controllerProvider = FutureProvider((ref) async {
  final lifecycle = ref.watch(appLifecycleProvider);
  final cameras = await availableCameras();

  if (cameras.isNotEmpty) {
    final controller = CameraController(cameras.first, ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420, enableAudio: false);

    if (controller.value.isInitialized) {
      if (lifecycle == AppLifecycleState.inactive) controller.dispose();
    } else {
      if (lifecycle == AppLifecycleState.resumed) {
        await controller.initialize();
        await controller.setFlashMode(FlashMode.off);
        await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      }
      return controller;
    }
  }

  return null;
});

final imagePathProvider = StateProvider<String>((ref) => '');
