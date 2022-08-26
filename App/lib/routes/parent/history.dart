import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(children: [
        Card(
            child: ListTile(
                title: const Text('投稿したワード'),
                trailing: const Icon(Icons.edit),
                onTap: () => context.push('/parent/post')))
      ]);
}
