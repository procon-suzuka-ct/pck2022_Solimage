import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/groups.dart';
import 'package:solimage/utils/classes/group.dart';
import 'package:solimage/utils/classes/user.dart';

class GroupCreateDialog extends ConsumerWidget {
  const GroupCreateDialog(
      {Key? key, required this.parentRef, required this.user})
      : super(key: key);

  final WidgetRef parentRef;
  final AppUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    return AlertDialog(
      title: const Text('グループを作成'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        SimpleDialogOption(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            onPressed: null,
            child: ListTile(
                title: const Text('グループを作成します'),
                subtitle: Text('${user?.name}さんはグループの管理者になります'))),
        TextField(
            controller: controller,
            decoration: const InputDecoration(
                labelText: 'グループ名', hintText: 'グループ名を入力してください'))
      ]),
      actions: <Widget>[
        TextButton(
            child: const Text('OK'),
            onPressed: () async {
              if (user != null && controller.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${controller.text}を作成しました')));
                Navigator.of(context).pop();
                final group = Group(groupName: controller.text);
                await group.init();
                user!.groups.add(group.groupID);
                await user!.save();
                group.addMember(user!.uid);
                await group.save();
                parentRef.refresh(groupsProvider);
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
