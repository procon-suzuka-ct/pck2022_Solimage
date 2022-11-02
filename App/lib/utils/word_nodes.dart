import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:solimage/components/parent/data/word_button.dart';
import 'package:solimage/utils/classes/word.dart';

TreeNode generateNode(Word rootWord, Map<String, List<Word>> wordMap) {
  final List<TreeNode> children = wordMap[rootWord.word] != null
      ? wordMap[rootWord.word]!
          .map((word) => generateNode(word, wordMap))
          .toList()
      : [];
  if (rootWord.root != '0') {
    children.add(TreeNode(content: AddWordButton(root: rootWord.word)));
  }

  return TreeNode(content: SelectWordButton(rootWord.word), children: children);
}
