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

    if (cameraPermission.value == PermissionStatus.granted) {
      final controller = ref.watch(controllerProvider);

      return controller.when(
          data: (controller) {
            final size = MediaQuery.of(context).size;
            var scale = size.aspectRatio * controller.value.aspectRatio;
            if (scale < 1) scale = 1 / scale;

            return Scaffold(
                body: Stack(fit: StackFit.expand, children: <Widget>[
              Transform.scale(
                  scale: scale,
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
                              barrierDismissible: true,
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
                      showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.8),
                          builder: (context) =>
                              StandbyDialog(controller: controller));
                      ref.read(imagePathProvider.notifier).state =
                          (await controller.takePicture()).path;
                    },
                    child: const Text('さつえい')),
                ChildActionButton(
                    onPressed: () => context.push('/child/favorite'),
                    child: const Text('おきにいり'))
              ])
            ]));
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
