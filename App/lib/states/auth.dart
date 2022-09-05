import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/utils/auth.dart';

final authProvider = StateProvider((ref) => Auth().currentUser());
