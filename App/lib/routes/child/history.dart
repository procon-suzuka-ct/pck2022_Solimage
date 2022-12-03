import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/child/child_actions.dart';
import 'package:solimage/components/parent/heading_tile.dart';
import 'package:solimage/components/tentative_card.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';

final historiesProvider = FutureProvider((ref) async {
  final histories =
      await ref.watch(userProvider.selectAsync((data) => data!.histories));
  final expDatas = await Future.wait(
      histories.map((history) => ExpData.getExpDataByWord(word: history)));
  final map = <String, ExpData?>{};
  for (final history in histories) {
    final expData = expDatas[histories.indexOf(history)];
    if (expData != null) map[history] = expData;
  }
  return map.entries.map((e) => e).toList();
});
final goodDatasProvider = FutureProvider((ref) async {
  final goodDatas =
      await ref.watch(userProvider.selectAsync((data) => data!.goodDatas));
  final expDatas = await Future.wait(
      goodDatas.map((goodData) => ExpData.getExpDataByWord(word: goodData)));
  expDatas.removeWhere((element) => element == null);
  return expDatas;
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(historiesProvider);
    final goodDatas = ref.watch(goodDatasProvider);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('きろく',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              const HeadingTile('しらべたもの'),
              Expanded(
                  child: histories.maybeWhen(
                      data: (histories) => histories.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(children: [
                                ...histories
                                    .getRange(
                                        0,
                                        histories.length > 2
                                            ? 2
                                            : histories.length)
                                    .map((history) => Expanded(
                                        child: Card(
                                            child: InkWell(
                                                customBorder:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                onTap: () {
                                                  HapticFeedback.heavyImpact();
                                                  context.push(
                                                      '/child/result?word=${history.key}');
                                                },
                                                child: Column(children: [
                                                  Expanded(
                                                      child: history.value!.imageUrl != null
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      10.0),
                                                              child: history
                                                                      .value!
                                                                      .imageUrl!
                                                                      .startsWith(
                                                                          'data')
                                                                  ? Image.memory(UriData.parse(history.value!.imageUrl!).contentAsBytes(),
                                                                      fit: BoxFit
                                                                          .cover)
                                                                  : CachedNetworkImage(
                                                                      imageUrl: history
                                                                          .value!
                                                                          .imageUrl!,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                      errorWidget: (context, url, error) => const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4, size: 60.0)))
                                                          : const Icon(Icons.no_photography, size: 60.0)),
                                                  Text(history.value!.word,
                                                      style: const TextStyle(
                                                          fontSize: 24.0))
                                                ])))))
                                    .toList(),
                                if (histories.length == 1)
                                  const Expanded(child: SizedBox())
                              ]))
                          : Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: TentativeCard(
                                      padding: const EdgeInsets.all(20.0),
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text('しらべてみよう!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onTap: () {
                                        HapticFeedback.heavyImpact();
                                        context.go('/child/camera');
                                      }))),
                      orElse: () =>
                          const Center(child: CircularProgressIndicator()))),
              if (histories.value != null &&
                  histories.value!.length > 2 == true)
                OpenContainer(
                    openBuilder: (context, action) => Scaffold(
                        appBar: AppBar(
                          automaticallyImplyLeading: false,
                          centerTitle: true,
                          title: const Text('しらべたもの',
                              style: TextStyle(
                                  fontSize: 30.0, fontWeight: FontWeight.bold)),
                        ),
                        body: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(children: [
                              Expanded(
                                  child: GridView.count(
                                      crossAxisCount: 2,
                                      children: histories.value!
                                          .map((history) => Card(
                                              child: InkWell(
                                                  customBorder:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  onTap: () {
                                                    HapticFeedback
                                                        .heavyImpact();
                                                    context.push(
                                                        '/child/result?word=${history.key}');
                                                  },
                                                  child: Column(children: [
                                                    Expanded(
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    10.0),
                                                            child: history
                                                                    .value!
                                                                    .imageUrl!
                                                                    .startsWith(
                                                                        'data')
                                                                ? Image.memory(
                                                                    UriData.parse(history.value!.imageUrl!)
                                                                        .contentAsBytes(),
                                                                    fit: BoxFit
                                                                        .cover)
                                                                : CachedNetworkImage(
                                                                    imageUrl: history
                                                                        .value!
                                                                        .imageUrl!,
                                                                    fit:
                                                                        BoxFit.cover))),
                                                    Text(history.value!.word,
                                                        style: const TextStyle(
                                                            fontSize: 24.0))
                                                  ]))))
                                          .toList())),
                              ChildActions(actions: [
                                ChildActionButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('もどる'))
                              ])
                            ]))),
                    closedBuilder: (context, action) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: ChildActionButton(
                            onPressed: action, child: const Text('くわしく')))),
              const HeadingTile('いいねしたもの'),
              Expanded(
                  child: goodDatas.maybeWhen(
                      data: (goodDatas) => goodDatas.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(children: [
                                ...goodDatas
                                    .getRange(
                                        0,
                                        goodDatas.length > 2
                                            ? 2
                                            : goodDatas.length)
                                    .map((goodData) => Expanded(
                                        child: Card(
                                            child: InkWell(
                                                customBorder:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                onTap: () {
                                                  HapticFeedback.heavyImpact();
                                                  context.push(
                                                      '/child/result?word=${goodData.word}');
                                                },
                                                child: Column(children: [
                                                  Expanded(
                                                      child: goodData!.imageUrl != null
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      10.0),
                                                              child: goodData
                                                                      .imageUrl!
                                                                      .startsWith(
                                                                          'data')
                                                                  ? Image.memory(
                                                                      UriData.parse(goodData.imageUrl!)
                                                                          .contentAsBytes(),
                                                                      fit: BoxFit
                                                                          .cover)
                                                                  : CachedNetworkImage(
                                                                      imageUrl:
                                                                          goodData.imageUrl!,
                                                                      fit: BoxFit.cover,
                                                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                      errorWidget: (context, url, error) => const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4, size: 60.0)))
                                                          : const Icon(Icons.no_photography, size: 60.0)),
                                                  Text(goodData.word,
                                                      style: const TextStyle(
                                                          fontSize: 24.0))
                                                ])))))
                                    .toList(),
                                if (goodDatas.length == 1)
                                  const Expanded(child: SizedBox())
                              ]))
                          : Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: TentativeCard(
                                      padding: const EdgeInsets.all(20.0),
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text('しらべてみよう!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onTap: () {
                                        HapticFeedback.heavyImpact();
                                        context.go('/child/camera');
                                      }))),
                      orElse: () =>
                          const Center(child: CircularProgressIndicator()))),
              if (goodDatas.value != null &&
                  goodDatas.value!.length > 2 == true)
                OpenContainer(
                    openBuilder: (context, action) => Scaffold(
                        appBar: AppBar(
                          automaticallyImplyLeading: false,
                          centerTitle: true,
                          title: const Text('いいねしたもの',
                              style: TextStyle(
                                  fontSize: 30.0, fontWeight: FontWeight.bold)),
                        ),
                        body: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(children: [
                              Expanded(
                                  child: GridView.count(
                                      crossAxisCount: 2,
                                      children: goodDatas.value!
                                          .map((goodData) => Card(
                                              child: InkWell(
                                                  customBorder:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  onTap: () {
                                                    HapticFeedback
                                                        .heavyImpact();
                                                    context.push(
                                                        '/child/result?word=${goodData.word}');
                                                  },
                                                  child: Column(children: [
                                                    Expanded(
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    10.0),
                                                            child: goodData!
                                                                    .imageUrl!
                                                                    .startsWith(
                                                                        'data')
                                                                ? Image.memory(
                                                                    UriData.parse(goodData.imageUrl!)
                                                                        .contentAsBytes(),
                                                                    fit: BoxFit
                                                                        .cover)
                                                                : CachedNetworkImage(
                                                                    imageUrl:
                                                                        goodData
                                                                            .imageUrl!,
                                                                    fit: BoxFit
                                                                        .cover))),
                                                    Text(goodData.word,
                                                        style: const TextStyle(
                                                            fontSize: 24.0))
                                                  ]))))
                                          .toList())),
                              ChildActions(actions: [
                                ChildActionButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('もどる'))
                              ])
                            ]))),
                    closedBuilder: (context, action) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: ChildActionButton(
                            onPressed: action, child: const Text('くわしく')))),
              ChildActions(actions: [
                ChildActionButton(
                    onPressed: () => context.pop(), child: const Text('もどる'))
              ])
            ])));
  }
}
