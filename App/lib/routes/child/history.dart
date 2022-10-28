import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/child/child_actions.dart';
import 'package:solimage/components/tentative_card.dart';
import 'package:solimage/states/camera.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/word.dart';

final historiesProvider = FutureProvider((ref) async => Future.wait(
    (await ref.watch(userProvider.selectAsync((data) => data!.histories)))
        .map((history) => Word.getWord(history))));

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(historiesProvider);

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
              Expanded(
                  child: histories.maybeWhen(
                      data: (histories) => histories.isNotEmpty
                          ? ListView.builder(
                              itemCount: histories.length,
                              itemBuilder: (context, index) {
                                final history = histories[index];
                                return history != null
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(30.0),
                                                textStyle: const TextStyle(
                                                    fontSize: 30.0,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            child: Center(
                                                child: Text(history.word)),
                                            onPressed: () =>
                                                HapticFeedback.heavyImpact()
                                                    .then((_) {
                                                  ref
                                                      .read(imagePathProvider
                                                          .notifier)
                                                      .state = '';
                                                  context.push(
                                                      '/child/result?word=${history.key}');
                                                })))
                                    : const SizedBox.shrink();
                              })
                          : Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: TentativeCard(
                                      padding: const EdgeInsets.all(20.0),
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text('さつえいしてみよう!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onTap: () {
                                        HapticFeedback.heavyImpact();
                                        context.go('/child/camera');
                                      }))),
                      orElse: () =>
                          const Center(child: CircularProgressIndicator()))),
              ChildActions(actions: [
                ChildActionButton(
                    onPressed: () => context.pop(), child: const Text('もどる'))
              ])
            ])));
  }
}
