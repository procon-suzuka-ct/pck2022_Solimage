import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solimage/components/child/standby_dialog.dart';
import 'package:solimage/components/child_actions.dart';
import 'package:solimage/components/loading_overlay.dart';
import 'package:solimage/states/camera.dart';

final _cameraPermissionProvider =
    FutureProvider((ref) => Permission.camera.request());
final _isTakingPictureProvider = StateProvider<bool>((ref) => false);

class CameraScreen extends ConsumerWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraPermission = ref.watch(_cameraPermissionProvider);
    final isTakingPicture = ref.watch(_isTakingPictureProvider);

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
                                onPressed: () => ScaffoldMessenger.of(context)
                                        .showMaterialBanner(MaterialBanner(
                                            actions: [
                                          TextButton(
                                              onPressed: () {
                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentMaterialBanner();
                                                ScaffoldMessenger.of(context)
                                                    .clearMaterialBanners();
                                                context.go('/parent');
                                              },
                                              child: const Text('はい')),
                                          TextButton(
                                              onPressed: () =>
                                                  ScaffoldMessenger.of(context)
                                                      .clearMaterialBanners(),
                                              child: const Text('いいえ')),
                                        ],
                                            content: const Text(
                                                '大人用メニューに切り替えてもよろしいでしょうか?'))),
                                label: const FittedBox(
                                  child: Text('大人用メニュー'),
                                ),
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(15.0))))),
                    ChildActions(actions: [
                      ChildActionButton(
                          onPressed: !isTakingPicture
                              ? () async {
                                  ScaffoldMessenger.of(context)
                                      .clearMaterialBanners();
                                  ref
                                      .read(_isTakingPictureProvider.notifier)
                                      .state = true;
                                  ref.read(imagePathProvider.notifier).state =
                                      '';
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      barrierColor:
                                          Colors.black.withOpacity(0.8),
                                      builder: (context) =>
                                          const StandbyDialog());
                                  final path =
                                      (await controller.takePicture()).path;
                                  ref.read(imagePathProvider.notifier).state =
                                      path;
                                  ref
                                      .read(_isTakingPictureProvider.notifier)
                                      .state = false;
                                }
                              : null,
                          child: const Text('さつえい')),
                      ChildActionButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                            context.push('/child/history');
                          },
                          child: const Text('きろく'))
                    ]),
                    LoadingOverlay(visible: ref.watch(_isTakingPictureProvider))
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
                            ref.watch(_cameraPermissionProvider);

                        cameraPermission.maybeWhen(
                            data: (data) async {
                              if (data == PermissionStatus.granted) {
                                ref.refresh(controllerProvider);
                              } else {
                                ref.refresh(_cameraPermissionProvider);
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
