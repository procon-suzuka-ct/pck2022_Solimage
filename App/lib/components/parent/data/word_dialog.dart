import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/states/words.dart';
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
        content: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            runSpacing: 10.0,
            children: [
              const Text.rich(TextSpan(children: [
                TextSpan(text: '例えば、猫の肉球に関する投稿であれば「'),
                TextSpan(
                    text: 'にくきゅう',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '」を追加してください')
              ])),
              TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'ワード',
                      hintText: 'ワードを入力してください'))
            ]),
        actions: [
          user.maybeWhen(
              data: (user) => TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      final word = Word(
                          word: controller.text,
                          root: root,
                          key: controller.text);
                      word
                          .save()
                          .then((_) => ref.refresh(wordsProvider.future))
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ワードを追加しました')));
                        Navigator.of(context).pop();
                      });
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
