import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/states/expdata.dart';

// TODO: 投稿したイチオシ情報を最上部に追加する
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expDatas = ref.watch(expDatasProvider);

    return expDatas.maybeWhen(
        data: (data) => data.isNotEmpty
            ? ListView(
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
                    .toList())
            : Center(
                child: Card(
                    child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                            margin: const EdgeInsets.all(20.0),
                            child: Wrap(
                                direction: Axis.vertical,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                spacing: 10.0,
                                children: const [
                                  Icon(Icons.edit, size: 30.0),
                                  Text('知識を投稿しましょう!')
                                ])),
                        onTap: () {}))),
        orElse: () => const Center(child: CircularProgressIndicator()));
  }
}
