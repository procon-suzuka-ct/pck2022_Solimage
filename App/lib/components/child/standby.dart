import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as image;
import 'package:solimage/components/child_actions.dart';
import 'package:solimage/utils/imageProcess/classifier.dart';

// TODO: 実際のデータに差し替える
class StandbyDialog extends StatelessWidget {
  const StandbyDialog(
      {Key? key, required this.controller, required this.decodedImage})
      : super(key: key);

  final CameraController controller;
  final image.Image decodedImage;

  @override
  Widget build(BuildContext context) => Stack(children: [
        const AlertDialog(
            title: Text('大人が伝えたいワード'),
            content: Center(heightFactor: 1.0, child: Text('簡単な説明'))),
        ChildActions(actions: [
          ChildActionButton(
              child: const Text('もどる'),
              onPressed: () => Navigator.of(context).pop()),
          FutureBuilder(
              future: () async {
                final classifier = Classifier.instance;
                await classifier.loadModel();
                final result = await classifier.predict(decodedImage);
                return result.label;
              }(),
              builder: (context, snapshot) => ChildActionButton(
                  onPressed: snapshot.connectionState == ConnectionState.done
                      ? () {
                          Navigator.of(context).pop();
                          context.push('/child/result?word=${snapshot.data}');
                        }
                      : null,
                  child: const Text('けっかをみる', textAlign: TextAlign.center)))
        ])
      ]);
}
