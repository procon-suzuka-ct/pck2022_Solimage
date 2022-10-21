import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:solimage/components/child/fwoh_card.dart';
import 'package:solimage/components/child_actions.dart';
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
  const FWOHScreen({Key? key, required this.data, required this.size})
      : super(key: key);

  final ExpData data;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final itemHeight = (size.height - 56 - 120) / 3;
    final itemWidth = size.width / 2;

    return GridView.count(
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
                    decoration:
                        BoxDecoration(color: Theme.of(context).backgroundColor),
                    child: Stack(alignment: Alignment.center, children: [
                      Center(
                          child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(_cardLabels[index],
                                  style: const TextStyle(
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold)))),
                      ChildActions(actions: [
                        ChildActionButton(
                            child: const Text('もどる'),
                            onPressed: () => Navigator.of(context).pop())
                      ])
                    ])),
                closedBuilder: (context, action) => FWOHCard(
                    label: _cardLabels[index],
                    description: _cardLabels[index],
                    action: action))));
  }
}
