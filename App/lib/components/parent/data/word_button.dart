import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/components/parent/data/word_dialog.dart';
import 'package:solimage/states/post.dart';

class AddWordButton extends StatelessWidget {
  const AddWordButton({Key? key, required this.root}) : super(key: key);

  final String root;

  @override
  Widget build(BuildContext context) => TextButton.icon(
      onPressed: () => showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => DataAddWordDialog(root: root)),
      icon: const Icon(Icons.add),
      label: const Text('追加'));
}

class SelectWordButton extends ConsumerWidget {
  const SelectWordButton(this.word, {Key? key}) : super(key: key);

  final String word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(stepProvider);

    return TextButton(
        onPressed: () {
          ref.read(wordProvider.notifier).state = word;
          ref.read(stepProvider.notifier).state = step + 1;
        },
        child: Text(word));
  }
}
