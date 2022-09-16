import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/states/preferences.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/auth.dart';
import 'package:solimage/utils/classes/group.dart';
import 'package:solimage/utils/classes/user.dart';

final _photoURLProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(authProvider.future).then((auth) => auth?.photoURL));
final _nameProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(userProvider.future).then((user) => user?.name));
final _groupsProvider = FutureProvider.autoDispose((ref) async =>
    await Future.wait((await ref
            .watch(userProvider.future)
            .then((user) => user?.groups ?? []))
        .map((groupID) => Group.getGroup(groupID))));

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
                photoURL.maybeWhen(
                    data: (data) => data != null
                        ? Container(
                            margin: const EdgeInsets.all(10.0),
                            child: CircleAvatar(
                                radius: 64.0,
                                backgroundImage: NetworkImage(data)))
                        : const SizedBox.shrink(),
                    orElse: () => const CircularProgressIndicator()),
                name.maybeWhen(
                    data: (data) =>
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('$dataさん',
                              style: const TextStyle(fontSize: 20.0)),
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) =>
                                      NameEditDialog(user: user.value)))
                        ]),
                    orElse: () => const CircularProgressIndicator())
              ])),
      Card(
          child: ListTile(
              title: const Text('ログアウト'),
              trailing: const Icon(Icons.logout),
              onTap: () => showDialog(
                  context: context,
                  builder: (context) =>
                      LogoutConfirmDialog(prefs: prefs.value)))),
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
          data: (data) => data
              .map((group) => group != null
                  ? Card(
                      child: ListTile(
                          title: Text(group.groupName),
                          trailing: const Icon(Icons.info),
                          onTap: () => showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => GroupDetailDialog(
                                  parentRef: ref, group: group))))
                  : const SizedBox.shrink())
              .toList(),
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
    final controller = TextEditingController(text: name.value);

    return AlertDialog(
      title: const Text('名前'),
      content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '名前を入力してください')),
      actions: <Widget>[
        TextButton(
            child: const Text('OK'),
            onPressed: () {
              if (controller.text.isNotEmpty && controller.text != name.value) {
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

class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({Key? key, required this.prefs}) : super(key: key);

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

class GroupDetailDialog extends ConsumerWidget {
  const GroupDetailDialog(
      {Key? key, required this.parentRef, required this.group})
      : super(key: key);

  final WidgetRef parentRef;
  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
        title: Text('${group.groupName}について'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Card(
              child: ListTile(
                  title: const Text('メンバー'),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) =>
                            GroupMemberListDialog(group: group));
                  })),
          Card(child: ListTile(title: Text('グループID: ${group.groupID}')))
        ]),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          TextButton(
              child: const Text('グループから抜ける'),
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (context) => GroupLeaveConfirmDialog(
                        parentRef: parentRef, group: group));
              }),
          TextButton(
              child: const Text('閉じる'),
              onPressed: () => Navigator.of(context).pop())
        ],
      );
}

class GroupMemberListDialog extends ConsumerWidget {
  const GroupMemberListDialog({Key? key, required this.group})
      : super(key: key);

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
      title: Text('${group.groupName}のメンバー'),
      content: FutureBuilder(future: Future.wait(group.members.map((uid) async {
        final user = await AppUser.getUser(uid);
        return Card(child: ListTile(title: Text('${user?.name}')));
      })), builder: (context, AsyncSnapshot<List<Card>> snapshot) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          if (snapshot.connectionState == ConnectionState.waiting)
            const Center(child: CircularProgressIndicator()),
          if (snapshot.hasData) ...snapshot.data!.toList()
        ]);
      }));
}

class GroupLeaveConfirmDialog extends ConsumerWidget {
  const GroupLeaveConfirmDialog(
      {Key? key, required this.parentRef, required this.group})
      : super(key: key);

  final WidgetRef parentRef;
  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;

    return AlertDialog(
      title: const Text('確認'),
      content: const Text('グループを脱退してもよろしいでしょうか?'),
      actions: <Widget>[
        TextButton(
            child: const Text('はい'),
            onPressed: () async {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${group.groupName}を脱退しました')));
              user!.groups.remove(group.groupID);
              await user.save();
              group.removeMember(user.uid);
              await group.save();
              parentRef.refresh(_groupsProvider);
            }),
        TextButton(
            child: const Text('いいえ'),
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
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
        TextButton(
            child: const Text('OK'),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${controller.text}を作成しました')));
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
            }),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
        title: const Text('グループに参加'),
        content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
                labelText: 'グループID', hintText: 'グループIDを入力してください'),
            keyboardType: TextInputType.number),
        actions: <Widget>[
          TextButton(
              child: const Text('OK'),
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  final group = Group.getGroup(int.parse(_controller.text));
                  group.then((value) async {
                    if (value != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${value.groupName}に参加しました')));
                      Navigator.of(context).pop();
                      user!.groups.add(value.groupID);
                      await user!.save();
                      value.addMember(user!.uid);
                      await value.save();
                      parentRef.refresh(_groupsProvider);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('そのグループは存在しません')));
                      Navigator.of(context).pop();
                    }
                  });
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
