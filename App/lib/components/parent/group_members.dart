import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/utils/classes/group.dart';
import 'package:solimage/utils/classes/user.dart';

// TODO: 機能を追加する
class GroupMembersDialog extends ConsumerWidget {
  const GroupMembersDialog({Key? key, required this.group}) : super(key: key);

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
      title: Text('${group.groupName}のメンバー'),
      content: FutureBuilder(future: Future.wait(group.members.map((uid) async {
        final user = await AppUser.getUser(uid);
        return Card(
            child: InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(title: Text('${user?.name}')),
                onTap: () {}));
      })), builder: (context, AsyncSnapshot<List<Card>> snapshot) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          if (snapshot.connectionState == ConnectionState.waiting)
            const Center(child: CircularProgressIndicator()),
          if (snapshot.hasData) ...snapshot.data!.toList()
        ]);
      }));
}
