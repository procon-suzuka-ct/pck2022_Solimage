import 'package:flutter_riverpod/flutter_riverpod.dart';

final stepProvider = StateProvider.autoDispose((ref) => 0);
final wordProvider = StateProvider.autoDispose((ref) => '');
