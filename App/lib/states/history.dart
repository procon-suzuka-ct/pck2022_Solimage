import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';

final recommendDataProvider = FutureProvider((ref) async {
  final uid = await ref.watch(userProvider.selectAsync((data) => data?.uid));
  return uid != null ? await RecommendData.getRecommendData(uid) : null;
});
