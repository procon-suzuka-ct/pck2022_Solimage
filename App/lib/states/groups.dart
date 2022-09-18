import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/group.dart';

final groupsProvider = FutureProvider.autoDispose((ref) async =>
    await Future.wait((await ref
            .watch(userProvider.future)
            .then((user) => user?.groups ?? []))
        .map((groupID) => Group.getGroup(groupID))));
