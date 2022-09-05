import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/utils/classes/user.dart';

final userProvider = StateProvider((ref) {
  final auth = ref.watch(authProvider);
  return auth != null ? AppUser(uid: auth.uid, name: auth.displayName!) : null;
});
