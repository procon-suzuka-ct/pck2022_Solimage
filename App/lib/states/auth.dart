import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/utils/auth.dart';

final userProvider = StateProvider((ref) => Auth().currentUser());
