import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';

final _wordProvider = StateProvider.autoDispose((ref) => '');
final _meaningProvider = StateProvider.autoDispose((ref) => '');
final _whyProvider = StateProvider.autoDispose((ref) => '');
final _whatProvider = StateProvider.autoDispose((ref) => '');
final _whereProvider = StateProvider.autoDispose((ref) => '');
final _whenProvider = StateProvider.autoDispose((ref) => '');
final _whoProvider = StateProvider.autoDispose((ref) => '');
final _howProvider = StateProvider.autoDispose((ref) => '');
final _imageUrlProvider = StateProvider.autoDispose((ref) => '');

class PostScreen extends ConsumerWidget {
  const PostScreen({Key? key, this.expDataId}) : super(key: key);

  final String? expDataId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final word = ref.watch(_wordProvider);

    final List<Map<String, dynamic>> textEditTiles = [
      {'title': '簡単な説明', 'provider': _meaningProvider},
      {'title': 'なぜ', 'provider': _whyProvider},
      {'title': 'なに', 'provider': _whatProvider},
      {'title': 'いつ', 'provider': _whenProvider},
      {'title': 'どこ', 'provider': _whereProvider},
      {'title': 'だれ', 'provider': _whoProvider},
      {'title': 'どうやって', 'provider': _howProvider},
      {'title': '画像のURL', 'provider': _imageUrlProvider}
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
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) => const WordSelectDialog()),
                  isThreeLine: true)),
          ...textEditTiles
              .map((tile) => Card(
                  child: ListTile(
                      title: Text(tile['title']),
                      subtitle: Text(ref.watch(tile['provider'])),
                      trailing: const Icon(Icons.edit),
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => TextEditDialog(
                              title: tile['title'],
                              provider: tile['provider'])),
                      isThreeLine: true)))
              .toList()
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final expData = ExpData(
                word: word,
                meaning: ref.read(_meaningProvider),
                userID: user.value!.uid);
            expData.setData(
                word: word,
                meaning: ref.read(_meaningProvider),
                why: ref.read(_whyProvider),
                what: ref.read(_whatProvider),
                when: ref.read(_whenProvider),
                where: ref.read(_whereProvider),
                who: ref.read(_whoProvider),
                how: ref.read(_howProvider),
                imageUrl: ref.read(_imageUrlProvider));
            await expData.init();

            return showDialog(
                context: context,
                builder: (context) => ConfirmDialog(expData: expData));
          },
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
        ref.read(_wordProvider.notifier).state = word;
        Navigator.of(context).pop(context);
      },
      child: Text(word));
}

class WordSelectDialog extends ConsumerWidget {
  const WordSelectDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TreeController(allNodesExpanded: false);

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

class ConfirmDialog extends ConsumerWidget {
  final ExpData expData;

  const ConfirmDialog({Key? key, required this.expData}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
        title: const Text('確認'),
        content: const Text('投稿してもよろしいでしょうか?'),
        actions: <Widget>[
          TextButton(
              child: const Text('はい'),
              onPressed: () => expData.save().then((_) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('投稿しました')));
                    ref.refresh(userProvider);
                    context.go('/parent');
                  })),
          TextButton(
              child: const Text('いいえ'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}
