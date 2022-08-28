import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:go_router/go_router.dart';

final wordProvider = StateProvider.autoDispose((ref) => '');
final descriptionProvider = StateProvider.autoDispose((ref) => '');
final whyProvider = StateProvider.autoDispose((ref) => '');
final whereProvider = StateProvider.autoDispose((ref) => '');
final whatProvider = StateProvider.autoDispose((ref) => '');
final whenProvider = StateProvider.autoDispose((ref) => '');
final howProvider = StateProvider.autoDispose((ref) => '');
final controllerProvider =
    Provider.autoDispose((ref) => TreeController(allNodesExpanded: false));

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

    final List<Map<String, dynamic>> textEditTiles = [
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
        children: [
          Card(
              child: ListTile(
                  title: const Text('ワード'),
                  subtitle: Text(word),
                  trailing: const Icon(Icons.edit),
                  onTap: () => showAnimatedDialog(
                      context: context,
                      animationType: DialogTransitionType.fadeScale,
                      builder: (context) => const WordSelectDialog()),
                  isThreeLine: true)),
          ...textEditTiles
              .map((tile) => Card(
                  child: ListTile(
                      title: Text(tile['title']),
                      subtitle: Text(tile['subtitle']),
                      trailing: const Icon(Icons.edit),
                      onTap: () => showAnimatedDialog(
                          context: context,
                          animationType: DialogTransitionType.fadeScale,
                          builder: (context) => TextEditDialog(
                              title: tile['title'],
                              provider: tile['provider'])),
                      isThreeLine: true)))
              .toList()
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showAnimatedDialog(
              context: context,
              animationType: DialogTransitionType.fadeScale,
              builder: (context) => const ConfirmDialog()),
          icon: const Icon(Icons.check),
          label: const Text('投稿')),
    );
  }
}

class WordButton extends ConsumerWidget {
  const WordButton({Key? key, required this.word}) : super(key: key);

  final String word;

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextButton(
      onPressed: () {
        ref.read(wordProvider.notifier).state = word;
        Navigator.of(context).pop(context);
      },
      child: Text(word));
}

class WordSelectDialog extends ConsumerWidget {
  const WordSelectDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(controllerProvider);

    return AlertDialog(
        scrollable: true,
        title: const Text('ワード'),
        content:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('以下からワードを選択してください', style: TextStyle(color: Colors.grey)),
          TreeView(
              treeController: controller,
              nodes: [
                TreeNode(content: const WordButton(word: '生物'), children: [
                  TreeNode(content: const WordButton(word: '虫'), children: [
                    TreeNode(
                        content: const WordButton(word: 'かまきり'),
                        children: [
                          TreeNode(content: const WordButton(word: '触角'))
                        ])
                  ])
                ]),
              ],
              indent: 20.0)
        ]));
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
            }),
        TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(context).pop())
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
