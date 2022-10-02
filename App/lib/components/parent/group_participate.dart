import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/group.dart';
import 'package:solimage/utils/classes/user.dart';

class GroupParticipateDialog extends ConsumerWidget {
  GroupParticipateDialog({Key? key, required this.user}) : super(key: key);

  final AppUser? user;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
        title: const Text('グループに参加'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const SimpleDialogOption(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              onPressed: null,
              child: ListTile(
                  title: Text('グループに参加します'),
                  subtitle: Text('グループIDを入力してください'))),
          TextField(
              controller: _controller,
              decoration: const InputDecoration(
                  labelText: 'グループID', hintText: 'グループIDを入力してください'),
              keyboardType: TextInputType.number)
        ]),
        actions: <Widget>[
          TextButton(
              child: const Text('OK'),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  final id = int.tryParse(_controller.text);
                  if (id != null) {
                    final group = Group.getGroup(id);
                    group.then((group) {
                      if (user != null && group != null) {
                        if (user!.groups.contains(group.groupID)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('既に参加しているグループです')));
                        } else {
                          user!.groups.add(group.groupID);
                          group.addMember(user!.uid);
                          for (var expData in user!.expDatas) {
                            group.addExpData(expData);
                          }
                          Future.wait([
                            user!.save(),
                            group.update(),
                            ref.refresh(userProvider.future)
                          ]).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${group.groupName}に参加しました')));
                            Navigator.of(context).pop();
                          });
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
