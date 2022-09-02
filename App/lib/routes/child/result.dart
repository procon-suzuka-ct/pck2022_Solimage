import 'dart:io';

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
          PageView(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Center(
                    child: Opacity(
                        opacity: 0.9,
                        child: Card(
                            child: Container(
                                margin: const EdgeInsets.all(20.0),
                                child: DefaultTextStyle(
                                    style: const TextStyle(
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.bold),
                                    child: Wrap(
                                        direction: Axis.vertical,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 10.0,
                                        children: const [
                                          Text('これは'),
                                          Text('かまきり',
                                              style: TextStyle(
                                                  fontSize: 36.0,
                                                  fontWeight: FontWeight.bold)),
                                          Text('です')
                                        ])))))),
                const Center(child: Text('かまきり')),
              ]),
          ChildActions(actions: [
            ChildActionButton(
                onPressed: () {
                  if (controller.page == 0) {
                    context.pop();
                  } else {
                    controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }
                },
                child: const Text('もどる')),
            ChildActionButton(
                onPressed: () => controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut),
                child: const Text('つぎへ'))
          ])
        ]));
  }
}
