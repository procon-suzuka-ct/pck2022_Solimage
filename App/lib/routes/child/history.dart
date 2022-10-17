import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/child_actions.dart';
import 'package:solimage/components/tentative_card.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/history.dart';
import 'package:solimage/utils/theme.dart';

final historiesProvider = FutureProvider.autoDispose((ref) async =>
    History.getHistories(
        await ref.watch(userProvider.selectAsync((data) => data!.uid))));

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(historiesProvider);

    return Theme(
        data: lightTheme,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: const Text('きろく'),
            ),
            // TODO: 実際のデータで検証する（実装済みで動作未確認）
            body: Column(children: [
              Expanded(
                  child: histories.maybeWhen(
                      data: (histories) => histories.isNotEmpty
                          ? ListView.builder(
                              itemCount: histories.length,
                              itemBuilder: (context, index) {
                                final history = histories[index];
                                return Card(
                                    child: InkWell(
                                        customBorder: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: ListTile(
                                            title: Text(history.word),
                                            subtitle: Text(
                                                '${history.year}/${history.month}/${history.day}'),
                                            onTap: () {})));
                              })
                          : const Padding(
                              padding: EdgeInsets.all(30.0),
                              child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: TentativeCard(
                                      padding: EdgeInsets.all(20.0),
                                      icon: Icon(Icons.camera_alt),
                                      label: Text('さつえいしてみよう!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))))),
                      orElse: () =>
                          const Center(child: CircularProgressIndicator()))),
              ChildActions(actions: [
                ChildActionButton(
                    onPressed: () => context.pop(), child: const Text('もどる'))
              ])
            ])));
  }
}
