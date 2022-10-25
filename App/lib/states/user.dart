import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/utils/classes/user.dart';

final userProvider = StreamProvider((ref) async* {
  final auth = await ref.watch(authProvider.future);
  var user = auth?.uid != null ? await AppUser.getUser(auth!.uid) : null;

  if (user != null) {
    yield* user.listener().map((snapshot) => snapshot.data() as AppUser?);
  } else if (auth != null) {
    user = AppUser(uid: auth.uid, name: auth.displayName ?? '');
    await user.save();
    yield user;
  }
});
