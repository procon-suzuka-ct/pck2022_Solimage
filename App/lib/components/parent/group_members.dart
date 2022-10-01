import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/group.dart';
import 'package:solimage/utils/classes/user.dart';

final _groupMembersProvider = FutureProvider.autoDispose
    .family<List<AppUser?>, Group>((ref, group) =>
        Future.wait(group.members.map((member) => AppUser.getUser(member))));

class GroupMembersDialog extends ConsumerWidget {
  const GroupMembersDialog({Key? key, required this.group}) : super(key: key);

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final groupMembers = ref.watch(_groupMembersProvider(group));

    return AlertDialog(
        title: Text('${group.groupName}のメンバー'),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: groupMembers.maybeWhen(
                data: (members) => members
                    .map((member) => Card(
                        child: InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                                title: Text('${member?.name}'),
                                trailing: user.maybeWhen(
                                    data: (user) => group.adminId != member?.uid
                                        ? IconButton(
                                            onPressed: () async {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          '${member?.name}を削除しました')));
                                              if (member != null) {
                                                member.groups
                                                    .remove(group.groupID);
                                                await member.save();
                                                group.removeMember(member.uid);
                                                for (var expData
                                                    in member.expDatas) {
                                                  group.removeExpData(expData);
                                                }
                                                await group.update();
                                              }
                                            },
                                            icon:
                                                const Icon(Icons.person_remove))
                                        : null,
                                    orElse: () => null)),
                            onTap: () {})))
                    .toList(),
                orElse: () =>
                    const [Center(child: CircularProgressIndicator())])));
  }
}
