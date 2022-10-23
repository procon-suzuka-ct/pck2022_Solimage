import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/utils/classes/word.dart';

final wordsProvider = FutureProvider((ref) => Word.getWords());
