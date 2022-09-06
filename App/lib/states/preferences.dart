import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefsProvider =
    StreamProvider((ref) => SharedPreferences.getInstance().asStream());
