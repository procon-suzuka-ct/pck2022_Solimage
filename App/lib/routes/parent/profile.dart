import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/utils/auth.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return ListView(children: [
      const ListTile(
          title: Text('ユーザー情報',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
              verticalDirection: VerticalDirection.down,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    margin: const EdgeInsets.all(10.0),
                    child: CircleAvatar(
                        radius: 64.0,
                        backgroundImage: NetworkImage('${user?.photoURL}'))),
                Text('${user?.displayName}さん',
                    style: const TextStyle(fontSize: 20.0))
              ])),
      Card(
          child: ListTile(
              title: const Text('名前'),
              trailing: const Icon(Icons.edit),
              onTap: () => showAnimatedDialog(
                  context: context,
                  animationType: DialogTransitionType.fadeScale,
                  builder: (context) => const UserNameDialog()))),
      Card(
          child: ListTile(
              title: const Text('ログアウト'),
              trailing: const Icon(Icons.logout),
              onTap: () => showAnimatedDialog(
                  context: context,
                  animationType: DialogTransitionType.fadeScale,
                  builder: (context) => const LogoutDialog()))),
      const ListTile(
          title: Text('グループ',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      Card(
          child: ListTile(
              title: const Text('グループA'),
              trailing: const Icon(Icons.info),
              onTap: () => showAnimatedDialog(
                  context: context,
                  animationType: DialogTransitionType.fadeScale,
                  builder: (context) =>
                      const GroupDialog(groupName: 'グループA')))),
      Card(
          child: ListTile(
              title: const Text('グループB'),
              trailing: const Icon(Icons.info),
              onTap: () => showAnimatedDialog(
                  context: context,
                  animationType: DialogTransitionType.fadeScale,
                  builder: (context) =>
                      const GroupDialog(groupName: 'グループB')))),
      Card(
          child: ListTile(
              title: const Text('グループC'),
              trailing: const Icon(Icons.info),
              onTap: () => showAnimatedDialog(
                  context: context,
                  animationType: DialogTransitionType.fadeScale,
                  builder: (context) =>
                      const GroupDialog(groupName: 'グループC')))),
      const ListTile(
          title: Text('アクセス履歴',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)))
    ]);
  }
}

class UserNameDialog extends StatelessWidget {
  const UserNameDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('名前'),
        content: const TextField(
            decoration: InputDecoration(hintText: '名前を入力してください')),
        actions: <Widget>[
          TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop()),
          TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}

class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
        title: const Text('確認'),
        content: const Text('ログアウトしてもよろしいでしょうか?'),
        actions: <Widget>[
          TextButton(
              child: const Text('はい'),
              onPressed: () async {
                await Auth().signOut();
                ref.refresh(userProvider);
              }),
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
        content: Column(mainAxisSize: MainAxisSize.min, children: const [
          Card(child: ListTile(title: Text('所属ユーザー数'))),
          Card(child: ListTile(title: Text('招待コード'))),
        ]),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          TextButton(
              child: const Text('グループから抜ける'),
              onPressed: () => Navigator.of(context).pop()),
          TextButton(
              child: const Text('閉じる'),
              onPressed: () => Navigator.of(context).pop())
        ],
      );
}
