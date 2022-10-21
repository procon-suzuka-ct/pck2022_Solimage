import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../child_actions.dart';

class FWOHCard extends StatelessWidget {
  const FWOHCard(
      {Key? key, required this.word, required this.label, this.description})
      : super(key: key);

  final String word;
  final String label;
  final String? description;

  @override
  Widget build(BuildContext context) => OpenContainer(
      tappable: false,
      closedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      openBuilder: (context, action) => Container(
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
          child: Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  title: Text(word),
                  automaticallyImplyLeading: false),
              body: Column(mainAxisSize: MainAxisSize.max, children: [
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text('$label?',
                          style: const TextStyle(
                              overflow: TextOverflow.clip,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold)),
                      Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Text(description!,
                              style: const TextStyle(
                                  overflow: TextOverflow.clip, fontSize: 30.0)))
                    ])),
                ChildActions(actions: [
                  ChildActionButton(
                      child: const Text('もどる'),
                      onPressed: () => Navigator.of(context).pop())
                ])
              ]))),
      closedBuilder: (context, action) => Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(
                      fontSize: 30.0, fontWeight: FontWeight.bold)),
              onPressed: (description != null && description!.isNotEmpty)
                  ? action
                  : null,
              child: Center(
                  child: FittedBox(fit: BoxFit.contain, child: Text(label))))));
}
