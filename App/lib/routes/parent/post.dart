import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final wordProvider = StateProvider.autoDispose((ref) => '');
final descriptionProvider = StateProvider.autoDispose((ref) => '');
final whyProvider = StateProvider.autoDispose((ref) => '');
final whereProvider = StateProvider.autoDispose((ref) => '');
final whatProvider = StateProvider.autoDispose((ref) => '');
final whenProvider = StateProvider.autoDispose((ref) => '');
final howProvider = StateProvider.autoDispose((ref) => '');

class PostScreen extends ConsumerWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final word = ref.watch(wordProvider);
    final description = ref.watch(descriptionProvider);
    final why = ref.watch(whyProvider);
    final where = ref.watch(whereProvider);
    final what = ref.watch(whatProvider);
    final when = ref.watch(whenProvider);
    final how = ref.watch(howProvider);

    final List<Map<String, dynamic>> tiles = [
      {
        "title": "ワード",
        "subtitle": word,
        "provider": wordProvider,
      },
      {
        'title': '簡単な説明',
        'subtitle': description,
        'provider': descriptionProvider
      },
      {'title': 'なぜ', 'subtitle': why, 'provider': whyProvider},
      {'title': 'どこ', 'subtitle': where, 'provider': whereProvider},
      {'title': 'なに', 'subtitle': what, 'provider': whatProvider},
      {'title': 'いつ', 'subtitle': when, 'provider': whenProvider},
      {'title': 'どうやって', 'subtitle': how, 'provider': howProvider}
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        scrollDirection: Axis.vertical,
        children: tiles
            .map((tile) => Card(
                child: ListTile(
                    title: Text(tile['title']),
                    subtitle: Text(tile['subtitle']),
                    trailing: IconButton(
                        onPressed: () => showAnimatedDialog(
                            context: context,
                            animationType: DialogTransitionType.fadeScale,
                            builder: (context) => TextEditDialog(
                                title: tile['title'],
                                provider: tile['provider'])),
                        icon: const Icon(Icons.edit)),
                    isThreeLine: true)))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showAnimatedDialog(
              context: context,
              animationType: DialogTransitionType.fadeScale,
              barrierDismissible: true,
              builder: (context) => const ConfirmDialog()),
          icon: const Icon(Icons.check),
          label: const Text('投稿')),
    );
  }
}

class TextEditDialog extends ConsumerWidget {
  const TextEditDialog({Key? key, required this.title, required this.provider})
      : super(key: key);

  final String title;
  final AutoDisposeStateProvider<String> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(provider);
    final controller = TextEditingController(text: text);

    return AlertDialog(
      title: Text(title),
      content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: title)),
      actions: <Widget>[
        TextButton(
            child: const Text('OK'),
            onPressed: () {
              ref.read(provider.notifier).update((_) => controller.text);
              Navigator.of(context).pop();
            })
      ],
    );
  }
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('投稿してもよろしいでしょうか?'),
        actions: <Widget>[
          TextButton(
              child: const Text('はい'), onPressed: () => context.go('/parent')),
          TextButton(
              child: const Text('いいえ'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}
