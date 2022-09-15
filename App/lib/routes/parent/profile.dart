import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/states/preferences.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/auth.dart';
import 'package:solimage/utils/classes/group.dart';
import 'package:solimage/utils/classes/user.dart';

final _photoURLProvider = StateProvider.autoDispose(
    (ref) => ref.watch(authProvider.select((value) => value.value?.photoURL)));
final _nameProvider = StateProvider.autoDispose(
    (ref) => ref.watch(userProvider.select((value) => value.value?.name)));
final _groupsProvider = FutureProvider.autoDispose((ref) async {
  final groupIds =
      ref.watch(userProvider.select((value) => value.value?.groups));
  return groupIds != null
      ? await Future.wait(groupIds.map((groupId) => Group.getGroup(groupId)))
      : null;
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoURL = ref.watch(_photoURLProvider);
    final name = ref.watch(_nameProvider);
    final groups = ref.watch(_groupsProvider);
    final prefs = ref.watch(prefsProvider);
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
                  builder: (context) => NameEditDialog(user: user.value)))),
      Card(
          child: ListTile(
              title: const Text('ログアウト'),
              trailing: const Icon(Icons.logout),
              onTap: () => showDialog(
                  context: context,
                  builder: (context) => LogoutDialog(prefs: prefs.value)))),
      ListTile(
          title: const Text('グループ',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          trailing: Wrap(spacing: 10.0, children: [
            ElevatedButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) =>
                        GroupCreationDialog(parentRef: ref, user: user.value),
                    useRootNavigator: false),
                child: const Text('作成')),
            ElevatedButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => GroupParticipationDialog(
                        parentRef: ref, user: user.value),
                    useRootNavigator: false),
                child: const Text('参加'))
          ])),
      ...groups.maybeWhen(
          data: (data) => (data != null
              ? data
                  .map((group) => group != null
                      ? Card(
                          child: ListTile(
                              title: Text(group.groupName),
                              trailing: const Icon(Icons.info),
                              onTap: () => showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) =>
                                      GroupDetailDialog(group: group))))
                      : const SizedBox.shrink())
                  .toList()
              : const [SizedBox.shrink()]),
          orElse: () => const [Center(child: CircularProgressIndicator())]),
      const ListTile(
          title: Text('アクセス履歴',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)))
    ]);
  }
}

class NameEditDialog extends ConsumerWidget {
  const NameEditDialog({Key? key, required this.user}) : super(key: key);

  final AppUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onPressed: () {
              if (controller.text.isNotEmpty && controller.text != name) {
                user!.setData(user!.uid, controller.text);
                ref.refresh(_nameProvider);
                user!.save();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('名前を変更しました')));
              }
              Navigator.of(context).pop();
            }),
        TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key, required this.prefs}) : super(key: key);

  final SharedPreferences? prefs;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('ログアウトしてもよろしいでしょうか?'),
        actions: <Widget>[
          TextButton(
              child: const Text('はい'),
              onPressed: () {
                Auth().signOut();
                prefs?.clear();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('ログアウトしました')));
              }),
          TextButton(
              child: const Text('いいえ'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}

class GroupDetailDialog extends StatelessWidget {
  const GroupDetailDialog({Key? key, required this.group}) : super(key: key);

  final Group group;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(group.groupName),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Card(child: ListTile(title: const Text('メンバー'), onTap: () {})),
          Card(child: ListTile(title: Text('グループID: ${group.groupID}')))
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

class GroupCreationDialog extends ConsumerWidget {
  const GroupCreationDialog(
      {Key? key, required this.parentRef, required this.user})
      : super(key: key);

  final WidgetRef parentRef;
  final AppUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    return AlertDialog(
      title: const Text('グループを作成'),
      content: TextField(
          controller: controller,
          decoration: const InputDecoration(
              labelText: 'グループ名', hintText: 'グループ名を入力してください')),
      actions: <Widget>[
        Builder(
            builder: (context) => TextButton(
                child: const Text('OK'),
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    Navigator.of(context).pop();
                    final group = Group(groupName: controller.text);
                    await group.init();
                    user?.groups.add(group.groupID);
                    await user?.save();
                    group.addMember(user!.uid);
                    await group.save();
                    parentRef.refresh(_groupsProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('グループ名を入力してください')));
                  }
                })),
        TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class GroupParticipationDialog extends ConsumerWidget {
  GroupParticipationDialog(
      {Key? key, required this.parentRef, required this.user})
      : super(key: key);

  final WidgetRef parentRef;
  final AppUser? user;
  final _controller = TextEditingController();
  final idProvider = StateProvider<String?>((ref) => null);
  late final getGroupProvider = FutureProvider((ref) async {
    final id = ref.read(idProvider);
    return id != null ? await Group.getGroup(int.parse(id)) : null;
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupRef = ref.watch(getGroupProvider);

    return AlertDialog(
      title: const Text('グループに参加'),
      content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
              labelText: 'グループID', hintText: 'グループIDを入力してください'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            ref.read(idProvider.notifier).state = value;
          }),
      actions: <Widget>[
        TextButton(
            child: const Text('OK'),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                groupRef.maybeWhen(
                    data: (group) async {
                      Navigator.of(context).pop();
                      if (group != null) {
                        user!.groups.add(group.groupID);
                        await user!.save();
                        group.addMember(user!.uid);
                        await group.save();
                        parentRef.refresh(_groupsProvider);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('そのグループは存在しません')));
                      }
                    },
                    orElse: () => null);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('グループIDを入力してください')));
              }
            }),
        TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
