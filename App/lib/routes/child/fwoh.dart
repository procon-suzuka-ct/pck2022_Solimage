import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/components/child/fwoh_card.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';

final List<String> _cardLabels = [
  'なんで',
  'なに',
  'どこで',
  'いつ',
  'だれ',
  'どうやって',
];
final _goodProvider = FutureProvider.family<bool, int>((ref, dataId) async {
  final user = await ref.watch(userProvider.future);
  return user!.goodDatas.contains(dataId);
});
final _badProvider = FutureProvider.family<bool, int>((ref, dataId) async {
  final user = await ref.watch(userProvider.future);
  return user!.badDatas.contains(dataId);
});

class FWOHScreen extends ConsumerWidget {
  const FWOHScreen({Key? key, required this.data}) : super(key: key);

  final ExpData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final good = ref.watch(_goodProvider(data.dataId));
    final bad = ref.watch(_badProvider(data.dataId));
    final cardDescriptions = [
      data.why,
      data.what,
      data.where,
      data.when,
      data.who,
      data.how
    ];

    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          ...List.generate(
              cardDescriptions.length,
              (index) => Expanded(
                  child: FWOHCard(
                      word: data.word,
                      label: _cardLabels[index],
                      description: cardDescriptions[index]))),
          if (data is! RecommendData)
            Row(children: [
              Expanded(
                  child: SizedBox.fromSize(
                      size: const Size.fromHeight(100.0),
                      child: good.maybeWhen(
                          data: (good) => ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: good ? Colors.green : null,
                                  padding: const EdgeInsets.all(20.0),
                                  textStyle: const TextStyle(
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold)),
                              label: const FittedBox(
                                  fit: BoxFit.contain, child: Text('おもしろい')),
                              icon: const Icon(Icons.thumb_up, size: 30.0),
                              onPressed: () async {
                                final user =
                                    await ref.read(userProvider.future);
                                data.good(user!.uid);
                              }),
                          orElse: () => const Center(
                              child: CircularProgressIndicator())))),
              const SizedBox(width: 10.0),
              Expanded(
                  child: SizedBox.fromSize(
                      size: const Size.fromHeight(100.0),
                      child: bad.maybeWhen(
                          data: (bad) => ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: bad ? Colors.red : null,
                                  padding: const EdgeInsets.all(20.0),
                                  textStyle: const TextStyle(
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold)),
                              label: const FittedBox(
                                  fit: BoxFit.contain, child: Text('つまらない')),
                              icon: const Icon(Icons.thumb_down, size: 30.0),
                              onPressed: () async {
                                final user =
                                    await ref.read(userProvider.future);
                                data.bad(user!.uid);
                              }),
                          orElse: () => const Center(
                              child: CircularProgressIndicator()))))
            ])
        ]));
  }
}
