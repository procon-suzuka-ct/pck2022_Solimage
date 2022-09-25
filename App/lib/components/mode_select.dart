import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeSelectDialog extends StatelessWidget {
  const ModeSelectDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      SimpleDialog(title: const Text('ようこそ!'), children: [
        const SimpleDialogOption(
            onPressed: null,
            child: ListTile(
                title: Text('主にSolimageを使うのは誰ですか?'),
                subtitle: Text('この設定は後から変更可能です'))),
        SimpleDialogOption(
            onPressed: () async {
              Navigator.of(context).pop();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt('mode', 0);
            },
            child: const ListTile(
              leading: Icon(Icons.face),
              title: Text('大人'),
              subtitle: Text('アプリを開いた時に大人用メニューが開かれます'),
            )),
        SimpleDialogOption(
            onPressed: () async {
              Navigator.of(context).pop();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt('mode', 1);
            },
            child: const ListTile(
              leading: Icon(Icons.child_care),
              title: Text('子ども'),
              subtitle: Text('アプリを開いた時にカメラが開かれます'),
            )),
      ]);
}
