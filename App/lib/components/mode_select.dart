import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeSelectDialog extends StatelessWidget {
  const ModeSelectDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWelcomeScreen = GoRouter.of(context).location == '/';

    return AlertDialog(
      title: Text(isWelcomeScreen ? 'ようこそ!' : 'モード切り替え'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const SimpleDialogOption(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            onPressed: null,
            child: ListTile(
                title: Text('主にSolimageを使うのは誰ですか?'),
                subtitle: Text('この設定は後から変更可能です'))),
        SimpleDialogOption(
            onPressed: () async {
              if (!isWelcomeScreen) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('大人用モードに変更しました')));
              }
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
              if (!isWelcomeScreen) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('子ども向けモードに変更しました')));
              }
              Navigator.of(context).pop();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt('mode', 1);
            },
            child: const ListTile(
              leading: Icon(Icons.child_care),
              title: Text('子ども'),
              subtitle: Text('アプリを開いた時にカメラが開かれます'),
            )),
      ]),
      contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
      actions: [
        if (!isWelcomeScreen)
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'))
      ],
    );
  }
}
