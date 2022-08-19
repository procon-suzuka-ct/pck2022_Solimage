import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StandbyScreen extends ConsumerWidget {
  const StandbyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Container(
            margin: const EdgeInsets.all(30.0),
            child: Column(
                verticalDirection: VerticalDirection.down,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('大人が伝えたいワード', style: TextStyle(fontSize: 30.0)),
                  const Text('簡単な説明'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () => context.go('/child/camera'),
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size.fromHeight(100.0),
                                  padding: const EdgeInsets.all(30.0)),
                              child: const FittedBox(
                                  child: Text('もどる',
                                      style: TextStyle(fontSize: 30.0))))),
                      const SizedBox(width: 20.0),
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () => context.replace('/child/result'),
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size.fromHeight(100.0),
                                  padding: const EdgeInsets.all(30.0)),
                              child: const FittedBox(
                                  child: Text('けっか',
                                      style: TextStyle(fontSize: 30.0)))))
                    ],
                  )
                ])));
  }
}
