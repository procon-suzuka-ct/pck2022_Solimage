import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/group.dart';
import 'package:solimage/utils/classes/user.dart';

class GroupCreateDialog extends ConsumerWidget {
  const GroupCreateDialog({Key? key, required this.user}) : super(key: key);

  final AppUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    return AlertDialog(
      title: const Text('グループを作成'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        SimpleDialogOption(
            padding: EdgeInsets.zero,
            onPressed: null,
            child: ListTile(
                title: const Text('グループを作成します'),
                subtitle: Text('${user?.name}さんはグループの管理者になります'))),
        TextField(
            controller: controller,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'グループ名',
                hintText: 'グループ名を入力してください'))
      ]),
      actions: <Widget>[
        TextButton(
            child: const Text('OK'),
            onPressed: () {
              if (user != null && controller.text.isNotEmpty) {
                final group =
                    Group(groupName: controller.text, adminId: user!.uid);
                group.addMember(user!.uid);
                user!.expDatas.map((expData) => group.addExpData(expData));
                group.init().then((_) {
                  user!.groups.add(group.groupID);
                  return Future.wait([
                    user!.save(),
                    group.save(),
                    ref.refresh(userProvider.future)
                  ]);
                }).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${controller.text}を作成しました')));
                  Navigator.of(context).pop();
                });
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
