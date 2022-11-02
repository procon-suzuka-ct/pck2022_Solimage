import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as image;
import 'package:solimage/components/child/child_actions.dart';
import 'package:solimage/states/camera.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';
import 'package:solimage/utils/classes/user.dart';
import 'package:solimage/utils/classes/word.dart';
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

final _recommendUserProvider = FutureProvider.autoDispose((ref) async {
  final recommendData = await ref.watch(_recommendDataProvider.future);
  if (recommendData != null) {
    return AppUser.getUser(recommendData.userId);
  }
  return null;
});

final _labelsProvider = FutureProvider<Map<String, ExpData>>((ref) async {
  final imagePath = ref.watch(imagePathProvider);

  if (imagePath.isNotEmpty) {
    final classifier = Classifier.instance;
    await classifier.loadModel();
    final result = await classifier
        .predict(image.decodeImage(File(imagePath).readAsBytesSync())!);
    final labels = result.getRange(0, 5).toList();
    final expDatas = await Future.wait(result.getRange(0, 5).map(
        (label) async => await ExpData.getExpDataByWord(
            word: (await Word.getWord(label.label))!.word)));
    final map = <String, ExpData>{};
    for (final label in labels) {
      map[label.label] = expDatas[labels.indexOf(label)]!;
    }
    return map;
  }
  throw const FileSystemException();
});

final _currentPageProvider = StateProvider.autoDispose((ref) => 0);

class StandbyDialog extends ConsumerWidget {
  const StandbyDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendData = ref.watch(_recommendDataProvider);
    final recommendUser = ref.watch(_recommendUserProvider);
    final labels = ref.watch(_labelsProvider);
    final controller = PageController();
    final currentPage = ref.watch(_currentPageProvider);
    final pages = [
      recommendData.value != null && recommendUser.value != null
          ? AlertDialog(
              title: Center(
                  child: Text(recommendData.value!.word,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold))),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text("${recommendUser.value!.name}さんからおすすめされました",
                        style: const TextStyle(fontSize: 20))),
                Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: recommendData.value!.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: recommendData.value!.imageUrl!,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                            Icons
                                                .signal_wifi_statusbar_connected_no_internet_4,
                                            size: 60.0)))
                            : const Icon(Icons.no_photography, size: 60.0))),
                ChildActionButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ref.read(imagePathProvider.notifier).state = '';
                      context.push(
                          '/child/result?userId=${recommendData.value!.userId}');
                    },
                    child: const Text('みてみる'))
              ]))
          : const SizedBox.shrink(),
      AlertDialog(
          title: const Center(
              child: Text('どれだろう?',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
          content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 10.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('しゃしんにふれると、けっかをみられます',
                        style: TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center),
                    labels.maybeWhen(
                        data: (labels) => SizedBox(
                            width: 300.0,
                            child: GridView.count(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                children: labels.entries
                                    .map((label) => Card(
                                        child: InkWell(
                                            customBorder:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            onTap: () {
                                              HapticFeedback.heavyImpact();
                                              context.push(
                                                  '/child/result?word=${label.key}');
                                            },
                                            child: label.value.imageUrl != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: label.value.imageUrl!
                                                            .startsWith('data')
                                                        ? Image.memory(
                                                            UriData.parse(label.value.imageUrl!)
                                                                .contentAsBytes(),
                                                            fit: BoxFit.cover)
                                                        : CachedNetworkImage(
                                                            imageUrl: label
                                                                .value
                                                                .imageUrl!,
                                                            fit: BoxFit.cover,
                                                            placeholder: (context,
                                                                    url) =>
                                                                const Center(child: CircularProgressIndicator()),
                                                            errorWidget: (context, url, error) => const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4, size: 60.0)))
                                                : const Icon(Icons.no_photography, size: 60.0))))
                                    .toList())),
                        orElse: () => const Center(heightFactor: 1.0, child: CircularProgressIndicator()))
                  ])))
    ];
    pages.removeWhere((element) => element is SizedBox);

    return Column(mainAxisSize: MainAxisSize.max, children: [
      Expanded(
          child: recommendData.maybeWhen(
              data: (data) => PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: controller,
                  onPageChanged: (page) =>
                      ref.read(_currentPageProvider.notifier).state = page,
                  children: pages),
              orElse: () => const AlertDialog(
                  content: Center(
                      heightFactor: 1.0, child: CircularProgressIndicator())))),
      ChildActions(actions: [
        ChildActionButton(
            child: const Text('もどる'),
            onPressed: () => currentPage == 1 &&
                    recommendData.value != null &&
                    recommendUser.value != null
                ? controller.previousPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut)
                : Navigator.of(context).pop()),
        labels.maybeWhen(
            data: (data) => currentPage == 0 &&
                    recommendData.value != null &&
                    recommendUser.value != null
                ? ChildActionButton(
                    onPressed: () {
                      controller.nextPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut);
                    },
                    child: const Text('けっかをみる', textAlign: TextAlign.center))
                : ChildActionButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child:
                        const Text('もういちど\nさつえい', textAlign: TextAlign.center)),
            orElse: () => const Center(child: CircularProgressIndicator()))
      ])
    ]);
  }
}
