import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:solimage/components/parent/data/word_button.dart';
import 'package:solimage/states/words.dart';
import 'package:solimage/utils/classes/word.dart';
import 'package:solimage/utils/word_nodes.dart';

class WordTree extends ConsumerWidget {
  const WordTree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(wordsProvider);
    print(words);
    final controller = TreeController();

    return words.maybeWhen(
        data: (words) {
          final wordMap = <String, List<Word>>{};
          for (final word in words) {
            if (wordMap.containsKey(word.root)) {
              wordMap[word.root]!.add(word);
            } else {
              wordMap[word.root] = [word];
            }
          }

          final List<TreeNode> nodes = wordMap['0'] != null
              ? wordMap['0']!
                  .map((rootWord) => generateNode(rootWord, wordMap))
                  .toList()
              : [];
          nodes.add(TreeNode(content: const AddWordButton(root: '0')));

          return TreeView(
              treeController: controller, indent: 20.0, nodes: nodes);
        },
        orElse: () => const Center(child: CircularProgressIndicator()));
  }
}
