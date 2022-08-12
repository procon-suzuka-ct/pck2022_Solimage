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
                    child: Stack(fit: StackFit.expand, children: <Widget>[
              AspectRatio(
                  aspectRatio: 9.0 / 16.0,
                  child: FittedBox(
                      alignment: Alignment.center,
                      fit: BoxFit.fitWidth,
                      child: SizedBox(
                          width: width,
                          height: height,
                          child: CameraPreview(controller)))),
              FittedBox(
                  alignment: Alignment.topCenter,
                  fit: BoxFit.fitWidth,
                  child: Container(
                      margin: const EdgeInsets.all(10.0),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        direction: Axis.horizontal,
                        spacing: 10,
                        children: <Widget>[
                          ElevatedButton(
                              onPressed: () {
                                context.push('/parent');
                              },
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(10.0)),
                              child: const Text('大人用ホーム',
                                  style: TextStyle(fontSize: 20.0))),
                          ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(10.0)),
                              child: const Text('りれき',
                                  style: TextStyle(fontSize: 20.0)))
                        ],
                      ))),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton.icon(
                          onPressed: () async {
                            final imagePath = ref.read(imagePathProvider.state);
                            imagePath.update((value) => null);
                            context.push('/image');
                            final image = await controller.takePicture();
                            imagePath.update((state) => image.path);
                          },
                          icon: const Icon(Icons.camera),
                          label: const Text('さつえい',
                              style: TextStyle(fontSize: 30.0)),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(10.0)))))
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
