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

final _recommendDataProvider = FutureProvider.autoDispose((ref) async {
  final uid = await ref.watch(userProvider.selectAsync((data) => data?.uid));
  final groups =
      await ref.watch(userProvider.selectAsync((data) => data?.groups));
  if (groups == null || groups.isEmpty) return null;
  final recommendData = uid != null
      ? await RecommendData.getRecommendDataByCurrentUid(uid)
      : null;

  if (recommendData != null) {
    await recommendData.addViews();
  }

  return recommendData;
});

final _classifierProvider = FutureProvider.autoDispose((ref) async {
  final imagePath = ref.watch(imagePathProvider);

  if (imagePath.isNotEmpty) {
    final classifier = Classifier.instance;
    await classifier.loadModel();
    final result = await classifier
        .predict(image.decodeImage(File(imagePath).readAsBytesSync())!);
    return result[0].label;
  }
  throw const FileSystemException();
});

class StandbyDialog extends ConsumerWidget {
  const StandbyDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendData = ref.watch(_recommendDataProvider);
    final classifier = ref.watch(_classifierProvider);

    return Stack(children: [
      recommendData.maybeWhen(
          data: (data) => AlertDialog(
              title: Text(data != null
                  ? data.word!
                  : classifier.isLoading && classifier.valueOrNull != null
                      ? 'ちょっとまってね!'
                      : 'けっかをみてみよう!'),
              content: data != null
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          constraints: const BoxConstraints.tightFor(
                              width: 300, height: 300),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      data.imageUrl!)))),
                      ChildActionButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.push('/child/result?userId=${data.userId}');
                          },
                          child: const Text('くわしく'))
                    ])
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
