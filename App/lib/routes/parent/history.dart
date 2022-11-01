import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/card_tile.dart';
import 'package:solimage/components/connectivity.dart';
import 'package:solimage/components/parent/heading_tile.dart';
import 'package:solimage/components/tentative_card.dart';
import 'package:solimage/states/history.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';

final _expDatasProvider = FutureProvider((ref) async => await Future.wait(
    (await ref.watch(userProvider.selectAsync((data) => data?.expDatas ?? [])))
        .map((expData) => ExpData.getExpData(expData))));

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expDatas = ref.watch(_expDatasProvider);
    final recommendData = ref.watch(recommendDataProvider);

    return ListView(children: [
      const HeadingTile('オススメ中の投稿'),
      recommendData.maybeWhen(
          data: (recommendData) => recommendData != null
              ? CardTile(
                  onTap: () => checkConnectivity(context).then((_) => context
                      .push('/parent/post?dataId=${recommendData.userId}')),
                  child: ListTile(
                      leading: recommendData.imageUrl != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10.0)),
                                      child:
                                          CachedNetworkImage(fit: BoxFit.cover, imageUrl: recommendData.imageUrl!))))
                          : null,
                      title: Text(recommendData.word),
                      trailing: const Icon(Icons.edit)))
              : TentativeCard(icon: const Icon(Icons.message, size: 30.0), label: const Text('オススメの知識を投稿してみましょう!'), onTap: () => checkConnectivity(context).then((_) => context.push('/parent/post?recommend=true'))),
          orElse: () => Container(margin: const EdgeInsets.all(20.0), child: const Center(child: CircularProgressIndicator()))),
      const HeadingTile('過去の投稿'),
      ...expDatas.maybeWhen(
          data: (expDatas) => expDatas.isNotEmpty
              ? expDatas
                  .map((expData) => CardTile(
                      child: ListTile(
                          leading: expData?.imageUrl != null
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10.0)),
                                          child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: expData!.imageUrl!))))
                              : null,
                          title: Text('${expData?.word}'),
                          trailing: const Icon(Icons.edit)),
                      onTap: () => checkConnectivity(context).then((_) =>
                          context
                              .push('/parent/post?dataId=${expData?.dataId}'))))
                  .toList()
              : [
                  TentativeCard(
                      icon: const Icon(Icons.edit, size: 30.0),
                      label: const Text('知識を投稿しましょう!'),
                      onTap: () => checkConnectivity(context)
                          .then((_) => context.push('/parent/post')))
                ],
          orElse: () => const [Center(child: CircularProgressIndicator())])
    ]);
  }
}
