import 'package:flutter/material.dart';
import 'package:solimage/utils/classes/expData.dart';

class DataDeleteDialog extends StatelessWidget {
  const DataDeleteDialog({Key? key, required this.expData}) : super(key: key);

  final ExpData expData;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('この投稿を削除してもよろしいでしょうか?'),
        actions: <Widget>[
          TextButton(
              child: const Text('はい'),
              onPressed: () {
                expData.delete();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('投稿を削除しました')));
              }),
          TextButton(
              child: const Text('いいえ'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}
