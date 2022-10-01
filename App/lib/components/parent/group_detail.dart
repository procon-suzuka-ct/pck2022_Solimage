import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/components/parent/group_leave.dart';
import 'package:solimage/components/parent/group_members.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/group.dart';

class GroupDetailDialog extends ConsumerWidget {
  const GroupDetailDialog(
      {Key? key, required this.parentRef, required this.group})
      : super(key: key);

  final WidgetRef parentRef;
  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return AlertDialog(
      title: Text('${group.groupName}について'),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          children: user.maybeWhen(
              data: (user) => [
                    if (group.adminId == user?.uid)
                      SimpleDialogOption(
                          padding: EdgeInsets.zero,
                          onPressed: null,
                          child: ListTile(
                              title: const Text('グループを管理します'),
                              subtitle: Text('${user?.name}さんはグループの管理者です'))),
                    Card(
                        child: InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: const ListTile(
                                leading: Icon(Icons.person),
                                title: Text('メンバー一覧')),
                            onTap: () {
                              Navigator.of(context).pop();
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      GroupMembersDialog(group: group));
                            })),
                    Card(
                        child: InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                                leading: const Icon(Icons.qr_code),
                                title: const Text('グループID'),
                                subtitle: Text('${group.groupID}')),
                            onTap: () => Clipboard.setData(
                                    ClipboardData(text: '${group.groupID}'))
                                .then((_) => ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content: Text('クリップボードにコピーしました')))))),
                  ],
              orElse: () =>
                  const [Center(child: CircularProgressIndicator())])),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: <Widget>[
        user.maybeWhen(
            data: (user) => TextButton(
                onPressed: () async {
                  if (group.members.length != 1 && group.adminId != user?.uid) {
                    Navigator.of(context).pop();
                    await showDialog(
                        context: context,
                        builder: (context) => GroupLeaveDialog(
                            parentRef: parentRef, group: group));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('他にメンバーがいないグループは削除できません')));
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('グループから抜ける')),
            orElse: () => const CircularProgressIndicator()),
        TextButton(
            child: const Text('閉じる'),
            onPressed: () => Navigator.of(context).pop())
      ],
    );
  }
}
