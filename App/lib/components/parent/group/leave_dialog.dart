import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/group.dart';

class GroupLeaveDialog extends ConsumerWidget {
  const GroupLeaveDialog({Key? key, required this.group}) : super(key: key);

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
            onPressed: () {
              if (user != null) {
                user.groups.remove(group.groupID);
                group.removeMember(user.uid);
                for (var expData in user.expDatas) {
                  group.removeExpData(expData);
                }
                Future.wait([
                  user.save(),
                  group.update(),
                  ref.refresh(userProvider.future)
                ]).then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${group.groupName}を脱退しました')));
                });
              }
            }),
        TextButton(
            child: const Text('いいえ'),
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
