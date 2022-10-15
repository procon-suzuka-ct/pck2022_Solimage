import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as image;
import 'package:solimage/components/child_actions.dart';
import 'package:solimage/states/camera.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';
import 'package:solimage/utils/imageProcess/classifier.dart';

final _recommendedDataProvider = FutureProvider.autoDispose((ref) async {
  final uid = await ref.watch(userProvider.selectAsync((data) => data?.uid));
  return uid != null
      ? await RecommendData.getRecommendDataByCurrentUid(uid)
      : null;
});

final _classifierProvider = FutureProvider.autoDispose((ref) async {
  final imagePath = ref.watch(imagePathProvider);

  if (imagePath != null) {
    final classifier = Classifier.instance;
    await classifier.loadModel();
    final result = await classifier
        .predict(image.decodeImage(File(imagePath).readAsBytesSync())!);
    return result.label;
  }
  return null;
});

class StandbyDialog extends ConsumerWidget {
  const StandbyDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedData = ref.watch(_recommendedDataProvider);
    final classifier = ref.watch(_classifierProvider);

    return Stack(children: [
      recommendedData.maybeWhen(
          data: (data) => AlertDialog(
              title: Text(data != null
                  ? data.word!
                  : classifier.isLoading && classifier.valueOrNull != null
                      ? 'ちょっとまってね!'
                      : 'けっかをみてみよう!'),
              content: data != null
                  ? Container(
                      constraints: const BoxConstraints.tightFor(
                          width: 300, height: 300),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image:
                                  CachedNetworkImageProvider(data.imageUrl!))))
                  : null),
          orElse: () => const AlertDialog(
              content: Center(
                  heightFactor: 1.0, child: CircularProgressIndicator()))),
      ChildActions(actions: [
        ChildActionButton(
            child: const Text('もどる'),
            onPressed: () => Navigator.of(context).pop()),
        classifier.maybeWhen(
            data: (data) => ChildActionButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/child/result?word=$data');
                },
                child: const Text('けっかをみる', textAlign: TextAlign.center)),
            orElse: () => const Center(child: CircularProgressIndicator()))
      ])
    ]);
  }
}
