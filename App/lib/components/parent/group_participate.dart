import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/groups.dart';
import 'package:solimage/utils/classes/group.dart';
import 'package:solimage/utils/classes/user.dart';

class GroupParticipateDialog extends ConsumerWidget {
  GroupParticipateDialog(
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
                  final id = int.tryParse(_controller.text);
                  if (id != null) {
                    final group = Group.getGroup(id);
                    group.then((value) async {
                      if (user != null && value != null) {
                        if (user!.groups.contains(value.groupID)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('既に参加しているグループです')));
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${value.groupName}に参加しました')));
                          Navigator.of(context).pop();
                          user!.groups.add(value.groupID);
                          await user!.save();
                          value.addMember(user!.uid);
                          await value.save();
                          parentRef.refresh(groupsProvider);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('そのグループは存在しません')));
                        Navigator.of(context).pop();
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('正しいグループIDを入力してください')));
                    Navigator.of(context).pop();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('グループIDを入力してください')));
                  Navigator.of(context).pop();
                }
              }),
          TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}
