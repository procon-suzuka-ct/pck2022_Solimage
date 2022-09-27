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

// TODO: 投稿したイチオシ情報を最上部に追加する
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expDatas = ref.watch(_expDatasProvider);

    return expDatas.maybeWhen(
        data: (data) => ListView(
            // TODO: 投稿履歴がないときの代わりを追加する
            children: data
                .map((expData) => Card(
                    child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        // TODO: 詳細なデータを追加する
                        child: ListTile(
                            title: Text('${expData?.word}'),
                            trailing: const Icon(Icons.edit)),
                        onTap: () => context.push(
                            '/parent/post?expDataId=${expData?.dataId}'))))
                .toList()),
        orElse: () => const Center(child: CircularProgressIndicator()));
  }
}
