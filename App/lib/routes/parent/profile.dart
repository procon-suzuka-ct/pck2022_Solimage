import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/auth.dart';
import 'package:solimage/utils/classes/group.dart';

final _photoURLProvider = StateProvider.autoDispose(
    (ref) => ref.watch(authProvider.select((value) => value.value?.photoURL)));
final _nameProvider = StateProvider.autoDispose(
    (ref) => ref.watch(userProvider.select((value) => value.value?.name)));
final _groupsProvider = StateProvider.autoDispose(
    (ref) => ref.watch(userProvider.select((value) => value.value?.groups)));

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoURL = ref.watch(_photoURLProvider);
    final name = ref.watch(_nameProvider);
    final groups = ref.watch(_groupsProvider);

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
                if (photoURL != null)
                  Container(
                      margin: const EdgeInsets.all(10.0),
                      child: CircleAvatar(
                          radius: 64.0,
                          backgroundImage: NetworkImage(photoURL))),
                if (name != null)
                  Text('$nameさん', style: const TextStyle(fontSize: 20.0))
              ])),
      Card(
          child: ListTile(
              title: const Text('名前'),
              trailing: const Icon(Icons.edit),
              onTap: () => showDialog(
                  context: context,
                  builder: (context) => const UserNameDialog()))),
      Card(
          child: ListTile(
              title: const Text('ログアウト'),
              trailing: const Icon(Icons.logout),
              onTap: () => showDialog(
                  context: context,
                  builder: (context) => const LogoutDialog()))),
      const ListTile(
          title: Text('グループ',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      if (groups != null)
        ...groups.map((groupId) {
          return FutureBuilder<Group?>(
              future: Group.getGroup(groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.data != null) {
                  return Card(
                      child: ListTile(
                          title: Text('${snapshot.data?.groupName}'),
                          trailing: const Icon(Icons.info),
                          onTap: () => showDialog(
                              context: context,
                              builder: (context) => GroupDialog(
                                  groupName: '${snapshot.data?.groupName}'))));
                }

                return const SizedBox();
              });
        }),
      const ListTile(
          title: Text('アクセス履歴',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)))
    ]);
  }
}

class UserNameDialog extends ConsumerWidget {
  const UserNameDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final name = ref.watch(_nameProvider);
    final controller = TextEditingController(text: name);

    return AlertDialog(
      title: const Text('名前'),
      content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '名前を入力してください')),
      actions: <Widget>[
        TextButton(
            child: const Text('OK'),
            onPressed: () async {
              user.value!.setData(user.value!.uid, controller.text);
              ref.refresh(_nameProvider);
              user.value!.save();
              Navigator.of(context).pop();
            }),
        TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
        title: const Text('確認'),
        content: const Text('ログアウトしてもよろしいでしょうか?'),
        actions: <Widget>[
          TextButton(
              child: const Text('はい'), onPressed: () => Auth().signOut()),
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
