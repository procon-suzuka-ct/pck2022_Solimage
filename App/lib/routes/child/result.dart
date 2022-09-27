import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/child_actions.dart';
import 'package:solimage/states/camera.dart';
import 'package:solimage/utils/classes/word.dart';

final _currentPageProvider = StateProvider.autoDispose((ref) => 0);
final _wordDataProviderFamily = FutureProvider.autoDispose
    .family<Word?, String>((ref, word) => Word.getWord(word));
final List<String> cardLabels = [
  'なんで',
  'なに',
  'どこで',
  'いつ',
  'だれ',
  'どうやって',
];

class ResultScreen extends ConsumerWidget {
  const ResultScreen({Key? key, required this.word}) : super(key: key);

  final String word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(imagePathProvider);
    final currentPage = ref.watch(_currentPageProvider);
    final wordData = ref.watch(_wordDataProviderFamily(word));
    final controller = PageController();
    var size = MediaQuery.of(context).size;
    final itemHeight = (size.height - 56 - 120) / 3;
    final itemWidth = size.width / 2;

    return wordData.maybeWhen(
        data: (data) => Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Container(
                  margin: const EdgeInsets.all(10.0),
                  child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(data?.word ?? word,
                          style: const TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold)))),
              automaticallyImplyLeading: false,
            ),
            body: Column(children: [
              Expanded(
                  child: PageView(
                      controller: controller,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) =>
                          ref.read(_currentPageProvider.notifier).state = page,
                      children: [
                    Center(
                        child: imagePath != null
                            ? Container(
                                margin: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: DecorationImage(
                                        image: FileImage(File(imagePath)),
                                        fit: BoxFit.cover)))
                            : const CircularProgressIndicator()),
                    GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        childAspectRatio: itemWidth / itemHeight,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                            6,
                            (index) => OpenContainer(
                                openColor: Colors.transparent,
                                closedColor: Colors.transparent,
                                openBuilder: (context, action) => Container(
                                    decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).backgroundColor),
                                    child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Center(
                                              child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(cardLabels[index],
                                                      style: const TextStyle(
                                                          fontSize: 30.0,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                          ChildActions(actions: [
                                            ChildActionButton(
                                                child: const Text('もどる'),
                                                onPressed: () =>
                                                    Navigator.of(context).pop())
                                          ])
                                        ])),
                                closedBuilder: (context, action) => Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor),
                                    child: Card(
                                        child: Center(
                                            child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: Text(cardLabels[index],
                                                    style: const TextStyle(
                                                        fontSize: 30.0,
                                                        fontWeight: FontWeight
                                                            .bold))))))))),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: Wrap(spacing: 20.0, children: [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(10.0),
                                          textStyle: const TextStyle(
                                              fontSize: 30.0,
                                              fontWeight: FontWeight.bold)),
                                      child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(children: const [
                                            Icon(Icons.thumb_up, size: 50.0),
                                            Text('おもしろい')
                                          ])),
                                      onPressed: () {}),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(10.0),
                                          textStyle: const TextStyle(
                                              fontSize: 30.0,
                                              fontWeight: FontWeight.bold)),
                                      child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(children: const [
                                            Icon(Icons.thumb_down, size: 50.0),
                                            Text('つまらない')
                                          ])),
                                      onPressed: () {})
                                ]))))
                  ])),
              ChildActions(actions: [
                ChildActionButton(
                    onPressed: currentPage != 0
                        ? () => controller.previousPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut)
                        : () => context.pop(),
                    child: const Text('もどる')),
                ChildActionButton(
                    onPressed: currentPage != 2
                        ? () => controller.nextPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut)
                        : null,
                    child: const Text('くわしく'))
              ])
            ])),
        orElse: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())));
  }
}
