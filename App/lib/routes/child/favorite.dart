import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/child_actions.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('おきにいり'),
        ),
        body: ChildActions(actions: [
          ChildActionButton(
              onPressed: () => context.pop(),
              child: const Text('もどる', style: TextStyle(fontSize: 30.0)))
        ]));
  }
}
