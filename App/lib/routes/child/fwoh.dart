import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/components/child/fwoh_card.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';
import 'package:solimage/utils/classes/hapticFeedback.dart';

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

class FWOHScreen extends ConsumerWidget {
  const FWOHScreen({Key? key, required this.data}) : super(key: key);

  final ExpData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final good = ref.watch(_goodProvider(data.dataId));
    final cardDescriptions = [
      data.why,
      data.what,
      data.where,
      data.when,
      data.who,
      data.how
    ];

    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          ...List.generate(
              cardDescriptions.length,
              (index) => Expanded(
                  child: FWOHCard(
                      word: data.word,
                      label: _cardLabels[index],
                      description: cardDescriptions[index]))),
          if (data is! RecommendData)
            SizedBox(
                height: 100.0,
                child: good.maybeWhen(
                    data: (good) => ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: good ? Colors.white : null,
                            backgroundColor: good ? Colors.green : null,
                            padding: const EdgeInsets.all(20.0),
                            textStyle: const TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold)),
                        label: const FittedBox(
                            fit: BoxFit.contain, child: Text('いいね')),
                        icon: Icon(good ? Icons.check : Icons.thumb_up,
                            size: 30.0),
                        onPressed: () async {
                          HapticFeedback.positiveImpact();
                          final user = await ref.read(userProvider.future);
                          data.good(user!.uid);
                        }),
                    orElse: () =>
                        const Center(child: CircularProgressIndicator())))
        ]));
  }
}
