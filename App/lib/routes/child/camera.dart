import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solimage/components/child_actions.dart';
import 'package:solimage/states/camera.dart';
import 'package:solimage/states/permission.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraPermission = ref.watch(cameraPermissionProvider);

    return cameraPermission.maybeWhen(
        data: (data) {
          if (data == PermissionStatus.granted) {
            final controller = ref.watch(controllerProvider);

            return controller.when(
                data: (controller) {
                  final size = MediaQuery.of(context).size;

                  return Scaffold(
                      body: Stack(fit: StackFit.expand, children: <Widget>[
                    if (controller != null)
                      Transform.scale(
                          scale: 1 /
                              (size.aspectRatio * controller.value.aspectRatio),
                          alignment: Alignment.center,
                          child: Center(child: CameraPreview(controller))),
                    Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                            margin: const EdgeInsets.all(10.0),
                            child: ElevatedButton.icon(
                                icon: const Icon(Icons.supervisor_account),
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const SwitchToParentDialog()),
                                label: const FittedBox(
                                  child: Text('大人用メニュー'),
                                ),
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(15.0))))),
                    ChildActions(actions: [
                      ChildActionButton(
                          onPressed: () async {
                            ref.read(imagePathProvider.notifier).state = null;
                            ref.read(imagePathProvider.notifier).state =
                                (await controller!.takePicture()).path;
                            await showDialog(
                                context: context,
                                barrierDismissible: false,
                                barrierColor: Colors.black.withOpacity(0.8),
                                builder: (context) =>
                                    StandbyDialog(controller: controller));
                          },
                          child: const Text('さつえい')),
                      ChildActionButton(
                          onPressed: () => context.push('/child/favorite'),
                          child: const Text('おきにいり'))
                    ])
                  ]));
                },
                error: (error, _) => Text('Error: $error'),
                loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator())));
          } else {
            return Scaffold(
                body: Center(
                    child: Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10.0,
                        children: [
                  const Text('カメラの許可が必要です'),
                  ElevatedButton(
                      onPressed: () {
                        final cameraPermission =
                            ref.watch(cameraPermissionProvider);

                        cameraPermission.maybeWhen(
                            data: (data) async {
                              if (data == PermissionStatus.granted) {
                                ref.refresh(controllerProvider);
                              } else {
                                ref.refresh(cameraPermissionProvider);
                                await openAppSettings();
                              }
                            },
                            orElse: () {});
                      },
                      child: const Text('許可する'))
                ])));
          }
        },
        orElse: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())));
  }
}

class SwitchToParentDialog extends StatelessWidget {
  const SwitchToParentDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('大人用メニューに切り替えてもよろしいですか？'),
        actions: <Widget>[
          TextButton(
              child: const Text('はい'), onPressed: () => context.go('/parent')),
          TextButton(
              child: const Text('いいえ'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}

class StandbyDialog extends StatelessWidget {
  const StandbyDialog({Key? key, required this.controller}) : super(key: key);

  final CameraController controller;

  @override
  Widget build(BuildContext context) => Stack(children: [
        const AlertDialog(
            title: Text('大人が伝えたいワード'),
            content: Center(heightFactor: 1.0, child: Text('簡単な説明'))),
        ChildActions(actions: [
          ChildActionButton(
              child: const Text('もどる'),
              onPressed: () => Navigator.of(context).pop()),
          ChildActionButton(
              child: const Text('けっかをみる', textAlign: TextAlign.center),
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/child/result');
              })
        ])
      ]);
}
