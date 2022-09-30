import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/child_actions.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/history.dart';
import 'package:solimage/utils/theme.dart';

final historiesProvider = FutureProvider.autoDispose((ref) async {
  final user = await ref.watch(userProvider.future);
  return History.getHistories(user!.uid);
});

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
                          : FittedBox(
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                              child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Card(
                                      child: InkWell(
                                          customBorder: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Container(
                                              margin:
                                                  const EdgeInsets.all(20.0),
                                              child: Wrap(
                                                  direction: Axis.vertical,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  alignment:
                                                      WrapAlignment.center,
                                                  runAlignment:
                                                      WrapAlignment.center,
                                                  spacing: 10.0,
                                                  children: const [
                                                    Icon(Icons.camera_alt,
                                                        size: 50.0),
                                                    Text('さつえいしてみよう!',
                                                        style: TextStyle(
                                                            fontSize: 30.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ])),
                                          onTap: () {})))),
                      orElse: () =>
                          const Center(child: CircularProgressIndicator()))),
              ChildActions(actions: [
                ChildActionButton(
                    onPressed: () => context.pop(), child: const Text('もどる'))
              ])
            ])));
  }
}
