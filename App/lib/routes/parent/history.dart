import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';

final _expDatasProvider = FutureProvider((ref) async => await Future.wait(
    (await ref.watch(userProvider.selectAsync((data) => data?.expDatas ?? [])))
        .map((expData) => ExpData.getExpData(expData))));
final recommendDataProvider = FutureProvider((ref) async {
  final uid = await ref.watch(userProvider.selectAsync((data) => data?.uid));
  return uid != null ? await RecommendData.getRecommendData(uid) : null;
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expDatas = ref.watch(_expDatasProvider);
    final recommendData = ref.watch(recommendDataProvider);

    return expDatas.maybeWhen(
        data: (expDatas) => expDatas.isNotEmpty
            ? ListView(children: [
                const ListTile(
                    title: Text('オススメ情報',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold))),
                Card(
                    child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        onTap: recommendData.value != null
                            ? () => context.push(
                                '/parent/post?dataId=${recommendData.value!.userId}')
                            : () {},
                        child: recommendData.maybeWhen(
                            data: (recommendData) => recommendData != null
                                ? Column(children: [
                                    ListTile(
                                        title: Text('${recommendData.word}'),
                                        trailing: const Icon(Icons.edit))
                                  ])
                                : Container(
                                    margin: const EdgeInsets.all(20.0),
                                    child: Wrap(
                                        direction: Axis.vertical,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        runAlignment: WrapAlignment.center,
                                        spacing: 10.0,
                                        children: const [
                                          Icon(Icons.message, size: 30.0),
                                          Text('オススメ情報を投稿してみましょう!')
                                        ])),
                            orElse: () => Container(
                                margin: const EdgeInsets.all(20.0),
                                child: const Center(
                                    child: CircularProgressIndicator()))))),
                const ListTile(
                    title: Text('過去の投稿',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold))),
                ...expDatas
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
                                '/parent/post?dataId=${expData?.dataId}'))))
                    .toList()
              ])
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
