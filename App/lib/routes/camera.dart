import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solimage/states/camera.dart';
import 'package:solimage/states/permission.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraPermission = ref.watch(cameraPermissionProvider);

    if (cameraPermission.value == PermissionStatus.granted) {
      final controller = ref.watch(controllerProvider);
      return controller.when(
          data: (controller) {
            final height = MediaQuery.of(context).size.height;
            final width = height / controller.value.aspectRatio;
            return Scaffold(
                body: SafeArea(
                    child: Stack(children: <Widget>[
              Align(
                  alignment: Alignment.center,
                  child: AspectRatio(
                      aspectRatio: 9.0 / 16.0,
                      child: FittedBox(
                          alignment: Alignment.center,
                          fit: BoxFit.fitWidth,
                          child: SizedBox(
                              width: width,
                              height: height,
                              child: CameraPreview(controller))))),
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      height: 80.0,
                      margin: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                              child: ElevatedButton.icon(
                                  icon: const Icon(Icons.apps, size: 30.0),
                                  onPressed: () {
                                    context.go('/parent');
                                  },
                                  label: const FittedBox(
                                    child: Text('大人用\nメニュー',
                                        style: TextStyle(fontSize: 30.0)),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: const Size.fromHeight(100.0),
                                      padding: const EdgeInsets.all(10.0)))),
                          const SizedBox(width: 20.0),
                          Expanded(
                              child: ElevatedButton.icon(
                                  icon: const Icon(Icons.star, size: 30.0),
                                  onPressed: () {},
                                  label: const FittedBox(
                                    child: Text('おきにいり',
                                        style: TextStyle(fontSize: 30.0)),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: const Size.fromHeight(100.0),
                                      padding: const EdgeInsets.all(10.0)))),
                        ],
                      ))),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      height: 80.0,
                      margin: const EdgeInsets.all(20.0),
                      child: ElevatedButton.icon(
                          onPressed: () async {
                            final imagePath = ref.read(imagePathProvider.state);
                            imagePath.update((value) => null);
                            context.push('/image');
                            final image = await controller.takePicture();
                            imagePath.update((state) => image.path);
                          },
                          icon: const Icon(Icons.camera, size: 30.0),
                          label: const Text('さつえい',
                              style: TextStyle(fontSize: 30.0)),
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size.fromHeight(100.0),
                              padding: const EdgeInsets.all(20.0)))))
            ])));
          },
          error: (error, _) => Text('Error: $error'),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())));
    } else {
      return const Scaffold(
          body: Center(
        child: Text('カメラの許可が必要です'),
      ));
    }
  }
}
