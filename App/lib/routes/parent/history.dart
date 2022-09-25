import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';

final _expDatasProvider = FutureProvider.autoDispose((ref) async =>
    await Future.wait((await ref
            .watch(userProvider.future)
            .then((value) => value?.expDatas ?? []))
        .map((expData) => ExpData.getExpData(expData))));

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expDatas = ref.watch(_expDatasProvider);

    return expDatas.maybeWhen(
        data: (data) => ListView(
            children: data
                .map((expData) => Card(
                    child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                            title: Text('${expData?.word}'),
                            trailing: const Icon(Icons.edit)),
                        onTap: () => context.push(
                            '/parent/post?expDataId=${expData?.dataId}'))))
                .toList()),
        orElse: () => const Center(child: CircularProgressIndicator()));
  }
}
