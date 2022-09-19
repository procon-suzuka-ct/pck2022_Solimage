import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/child_actions.dart';
import 'package:solimage/states/camera.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(imagePathProvider);
    final controller = PageController();
    var size = MediaQuery.of(context).size;
    final itemHeight = (size.height - 56 - 120) / 3;
    final itemWidth = size.width / 2;

    return Scaffold(
        backgroundColor: Colors.transparent,
        body:
            Stack(alignment: Alignment.center, fit: StackFit.expand, children: [
          Center(
              child: imagePath != null
                  ? Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: FileImage(File(imagePath)),
                              fit: BoxFit.cover)))
                  : const CircularProgressIndicator()),
          Column(children: [
            AppBar(
              centerTitle: true,
              title: const Text('けっか'),
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
            ),
            Expanded(
                child: PageView(
                    controller: controller,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                  GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      childAspectRatio: itemWidth / itemHeight,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(
                          6,
                          (index) => Card(
                              color: Colors.transparent,
                              child: OpenContainer(
                                  closedColor: Colors.transparent,
                                  openColor: Colors.transparent,
                                  openBuilder: (context, action) => Container(
                                      decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).backgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            const Center(child: Text('B')),
                                            ChildActions(actions: [
                                              ChildActionButton(
                                                  child: const Text('もどる'),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop())
                                            ])
                                          ])),
                                  closedBuilder: (context, action) => Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .backgroundColor
                                              .withOpacity(0.8),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: const Center(child: Text('A')))))))
                ])),
            ChildActions(actions: [
              ChildActionButton(
                  onPressed: () {
                    if (controller.page == 0) {
                      context.pop();
                    } else {
                      controller.previousPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut);
                    }
                  },
                  child: const Text('もどる')),
              ChildActionButton(
                  onPressed: () => controller.nextPage(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut),
                  child: const Text('つぎへ'))
            ])
          ])
        ]));
  }
}
