import 'package:flutter/material.dart';
import 'package:solimage/components/child/fwoh_card.dart';
import 'package:solimage/utils/classes/expData.dart';

final List<String> _cardLabels = [
  'なんで',
  'なに',
  'どこで',
  'いつ',
  'だれ',
  'どうやって',
];

class FWOHScreen extends StatelessWidget {
  const FWOHScreen({Key? key, required this.data}) : super(key: key);

  final ExpData data;

  @override
  Widget build(BuildContext context) {
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
                      word: data.word!,
                      label: _cardLabels[index],
                      description: cardDescriptions[index]))),
          FittedBox(
              fit: BoxFit.contain,
              child: Wrap(spacing: 10.0, children: [
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(30.0),
                        textStyle: const TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold)),
                    label: const Text('おもしろい'),
                    icon: const Icon(Icons.thumb_up, size: 50.0),
                    onPressed: () {}),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(30.0),
                        textStyle: const TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold)),
                    label: const Text('つまらない'),
                    icon: const Icon(Icons.thumb_down, size: 50.0),
                    onPressed: () {}),
              ]))
        ]));
  }
}
