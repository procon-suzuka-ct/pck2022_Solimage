import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/utils/classes/user.dart';

final userProvider = StreamProvider((ref) async* {
  final auth = await ref.watch(authProvider.future);

  if (auth != null) {
    var user = await AppUser.getUser(auth.uid);

    if (user == null) {
      user = AppUser(uid: auth.uid, name: auth.displayName!);
      await user.save();
    }
    yield user;
  } else {
    yield null;
  }
});

final photoURLProvider = StateProvider.autoDispose(
    (ref) => ref.watch(authProvider.select((value) => value.value?.photoURL)));
final nameProvider = StateProvider.autoDispose(
    (ref) => ref.watch(userProvider.select((value) => value.value?.name)));
final groupsProvider = StateProvider.autoDispose(
    (ref) => ref.watch(userProvider.select((value) => value.value?.groups)));
