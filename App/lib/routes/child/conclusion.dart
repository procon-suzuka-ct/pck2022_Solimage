import 'package:flutter/material.dart';

// TODO: 画面の情報量を増やす
class ConclusionScreen extends StatelessWidget {
  const ConclusionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FittedBox(
              fit: BoxFit.contain,
              child: Wrap(spacing: 20.0, children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(10.0),
                        textStyle: const TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold)),
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(children: const [
                          Icon(Icons.thumb_up, size: 50.0),
                          Text('おもしろい')
                        ])),
                    onPressed: () {}),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(10.0),
                        textStyle: const TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold)),
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(children: const [
                          Icon(Icons.thumb_down, size: 50.0),
                          Text('つまらない')
                        ])),
                    onPressed: () {})
              ]))));
}
