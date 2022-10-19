import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/word.dart';

class DataAddWordDialog extends ConsumerWidget {
  const DataAddWordDialog({Key? key, required this.root}) : super(key: key);

  final String root;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final user = ref.watch(userProvider);

    return AlertDialog(
        title: const Text('ワードの追加'),
        content: TextField(
            controller: controller,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ワード',
                hintText: 'ワードを入力してください')),
        actions: [
          user.maybeWhen(
              data: (user) => TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      final word = Word(word: controller.text, root: root);
                      word.save().then((_) => ScaffoldMessenger.of(context)
                          .showSnackBar(
                              const SnackBar(content: Text('投稿しました'))));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ワードを入力してください')));
                    }
                  }),
              orElse: () => const Center(child: CircularProgressIndicator())),
          TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop()),
        ]);
  }
}
