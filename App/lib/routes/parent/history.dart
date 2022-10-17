import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/tentative_card.dart';
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

    return ListView(children: [
      const ListTile(
          title: Text('オススメ中の投稿',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      recommendData.maybeWhen(
          data: (recommendData) => recommendData != null
              ? Card(
                  child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      onTap: () => context
                          .push('/parent/post?dataId=${recommendData.userId}'),
                      child: ListTile(
                          leading: recommendData.imageUrl != null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10.0)),
                                          child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl:
                                                  recommendData.imageUrl!))))
                              : null,
                          title: Text('${recommendData.word}'),
                          trailing: const Icon(Icons.edit))))
              : const TentativeCard(
                  icon: Icon(Icons.message, size: 30.0),
                  label: Text('オススメ情報を投稿してみましょう!')),
          orElse: () => Container(
              margin: const EdgeInsets.all(20.0),
              child: const Center(child: CircularProgressIndicator()))),
      const ListTile(
          title: Text('過去の投稿',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      ...expDatas.maybeWhen(
          data: (expDatas) => expDatas.isNotEmpty
              ? expDatas
                  .map((expData) => Card(
                      child: InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                              leading: expData?.imageUrl != null
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: AspectRatio(
                                          aspectRatio: 1.0,
                                          child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10.0)),
                                              child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl:
                                                      expData!.imageUrl!))))
                                  : null,
                              title: Text('${expData?.word}'),
                              trailing: const Icon(Icons.edit)),
                          onTap: () => context
                              .push('/parent/post?dataId=${expData?.dataId}'))))
                  .toList()
              : [
                  const TentativeCard(
                      icon: Icon(Icons.edit, size: 30.0),
                      label: Text('知識を投稿しましょう!'))
                ],
          orElse: () => const [Center(child: CircularProgressIndicator())])
    ]);
  }
}
