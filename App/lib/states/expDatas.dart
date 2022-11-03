import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';

final expDatasProvider = FutureProvider((ref) async => await Future.wait(
    (await ref.watch(userProvider.selectAsync((data) => data?.expDatas ?? [])))
        .map((expData) => ExpData.getExpData(expData))));
