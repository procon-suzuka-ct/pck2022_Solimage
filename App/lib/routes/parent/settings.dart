import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(children: [
        const ListTile(
            title: Text('ユーザー情報',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
        Card(
            child: ListTile(
                title: const Text('名前'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => showAnimatedDialog(
                      context: context,
                      animationType: DialogTransitionType.fadeScale,
                      barrierDismissible: true,
                      builder: (context) => const UserNameDialog()),
                ))),
        const ListTile(
            title: Text('グループ',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
        Card(
            child: ListTile(
                title: const Text('グループA'),
                trailing: IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () => showAnimatedDialog(
                        context: context,
                        animationType: DialogTransitionType.fadeScale,
                        barrierDismissible: true,
                        builder: (context) =>
                            const GroupDialog(groupName: 'グループA'))))),
        Card(
            child: ListTile(
                title: const Text('グループB'),
                trailing: IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () => showAnimatedDialog(
                        context: context,
                        animationType: DialogTransitionType.fadeScale,
                        barrierDismissible: true,
                        builder: (context) =>
                            const GroupDialog(groupName: 'グループB'))))),
        Card(
            child: ListTile(
                title: const Text('グループC'),
                trailing: IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () => showAnimatedDialog(
                        context: context,
                        animationType: DialogTransitionType.fadeScale,
                        barrierDismissible: true,
                        builder: (context) =>
                            const GroupDialog(groupName: 'グループC'))))),
        const ListTile(
            title: Text('アクセス履歴',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)))
      ]);
}

class UserNameDialog extends StatelessWidget {
  const UserNameDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('ユーザー名'),
        content: const TextField(
            decoration:
                InputDecoration(hintText: '名前を入力してください', labelText: '名前')),
        actions: <Widget>[
          TextButton(
              child: const Text('はい'),
              onPressed: () => Navigator.of(context).pop()),
          TextButton(
              child: const Text('いいえ'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}

class GroupDialog extends StatelessWidget {
  const GroupDialog({Key? key, required this.groupName}) : super(key: key);

  final String groupName;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(groupName),
        actions: <Widget>[
          TextButton(
              child: const Text('閉じる'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}
