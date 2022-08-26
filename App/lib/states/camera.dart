import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/app.dart';

final controllerProvider = FutureProvider((ref) async {
  final lifecycle = ref.watch(appLifecycleProvider);
  final controller = CameraController(
      (await availableCameras()).first, ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420, enableAudio: false);

  if (controller.value.isInitialized) {
    if (lifecycle == AppLifecycleState.paused) controller.dispose();
  } else {
    if (lifecycle == AppLifecycleState.resumed) await controller.initialize();
    controller.setFlashMode(FlashMode.off);
    controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
  }

  return controller;
});

final imageProvider =
    FutureProvider((ref) => ref.read(controllerProvider).value!.takePicture());
