import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/card_tile.dart';
import 'package:solimage/components/connectivity.dart';
import 'package:solimage/components/mode_select.dart';
import 'package:solimage/components/parent/group/create_dialog.dart';
import 'package:solimage/components/parent/group/detail_dialog.dart';
import 'package:solimage/components/parent/group/participate_dialog.dart';
import 'package:solimage/components/parent/heading_tile.dart';
import 'package:solimage/components/parent/user/logout_dialog.dart';
import 'package:solimage/components/parent/user/name_dialog.dart';
import 'package:solimage/components/tentative_card.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/states/preferences.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';
import 'package:solimage/utils/classes/group.dart';

final _photoURLProvider = FutureProvider(
    (ref) => ref.watch(authProvider.selectAsync((data) => data?.photoURL)));
final _nameProvider = FutureProvider(
    (ref) => ref.watch(userProvider.selectAsync((data) => data?.name)));
final _groupsProvider = FutureProvider((ref) async => await Future.wait(
    (await ref.watch(userProvider.selectAsync((data) => data?.groups ?? [])))
        .map((groupID) => Group.getGroup(groupID))));
final _expDatasProvider = FutureProvider((ref) async {
  final expDataIds =
      await ref.watch(userProvider.selectAsync((data) => data?.expDatas));
  final List<ExpData?> expDatas = expDataIds != null && expDataIds.isNotEmpty
      ? await Future.wait(
          expDataIds.map((expDataId) => ExpData.getExpData(expDataId)))
      : [];
  expDatas.removeWhere((element) => element == null);
  return expDatas;
});
final _recommendDataProvider = FutureProvider((ref) async {
  final uid = await ref.watch(userProvider.selectAsync((data) => data?.uid));
  return uid != null ? await RecommendData.getRecommendData(uid) : null;
});
final _totalViewsProvider = FutureProvider((ref) async {
  int totalViews = 0;
  final expDatas = await ref.watch(_expDatasProvider.future);
  final recommendData = await ref.watch(_recommendDataProvider.future);

  for (final expData in expDatas) {
    if (expData != null) totalViews += expData.views;
  }
  if (recommendData != null) totalViews += recommendData.views;

  return totalViews;
}, dependencies: [_expDatasProvider, _recommendDataProvider]);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoURL = ref.watch(_photoURLProvider);
    final name = ref.watch(_nameProvider);
    final groups = ref.watch(_groupsProvider);
    final prefs = ref.watch(prefsProvider);
    final user = ref.watch(userProvider);
    final totalViews = ref.watch(_totalViewsProvider);
    final expDatas = ref.watch(_expDatasProvider);

    return ListView(children: [
      Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
              verticalDirection: VerticalDirection.down,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                photoURL.maybeWhen(
                    data: (data) => data != null
                        ? Card(
                            elevation: 8.0,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                                imageUrl: data,
                                width: 160.0,
                                height: 160.0,
                                fit: BoxFit.contain))
                        : const SizedBox.shrink(),
                    orElse: () => const CircularProgressIndicator()),
                name.maybeWhen(
                    data: (data) =>
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('$dataさん',
                              style: Theme.of(context).textTheme.titleLarge),
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => checkConnectivity(context).then(
                                  (_) => showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => UserNameDialog(
                                          user: user.value,
                                          nameProvider: _nameProvider))))
                        ]),
                    orElse: () => const CircularProgressIndicator())
              ])),
      HeadingTile('グループ',
          trailing: Wrap(spacing: 10.0, children: [
            ElevatedButton(
                onPressed: () => checkConnectivity(context).then((_) =>
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            GroupCreateDialog(user: user.value))),
                child: const Text('作成')),
            ElevatedButton(
                onPressed: () => checkConnectivity(context).then((_) =>
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            GroupParticipateDialog(user: user.value))),
                child: const Text('参加'))
          ])),
      ...groups.maybeWhen(
          data: (data) => data.isNotEmpty
              ? data
                  .map((group) => group != null
                      ? CardTile(
                          child: ListTile(
                              leading: const Icon(Icons.group),
                              title: Text(group.groupName),
                              trailing: const Icon(Icons.info)),
                          onTap: () => checkConnectivity(context).then((_) =>
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) =>
                                      GroupDetailDialog(group: group))))
                      : const SizedBox.shrink())
                  .toList()
              : [
                  TentativeCard(
                      icon: const Icon(Icons.group, size: 30.0),
                      label: const Text('グループに参加しましょう!'),
                      onTap: () => showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              GroupParticipateDialog(user: user.value)))
                ],
          orElse: () => const [Center(child: CircularProgressIndicator())]),
      HeadingTile('興味',
          trailing: totalViews.maybeWhen(
              data: (data) => Text('閲覧数の合計: $data回'),
              orElse: () => const CircularProgressIndicator())),
      ...expDatas.maybeWhen(
          data: (expDatas) => expDatas.isNotEmpty
              ? [
                  HeadingTile(
                      '閲覧数上位${expDatas.length > 3 ? 3 : expDatas.length}投稿を表示しています',
                      style: Theme.of(context).textTheme.bodyLarge),
                  ...expDatas
                      .asMap()
                      .entries
                      .sortedByCompare((element) => element.value!.views,
                          (a, b) => a.compareTo(b))
                      .getRange(0, 3)
                      .map((entry) => CardTile(
                          child: ListTile(
                              leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.blueGrey,
                                            shape: BoxShape.circle),
                                        child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text('${entry.key + 1}',
                                                style: const TextStyle(
                                                    color: Colors.white)))),
                                    entry.value?.imageUrl != null
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 10.0),
                                            child: AspectRatio(
                                                aspectRatio: 1.0,
                                                child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                    child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        imageUrl: entry.value!
                                                            .imageUrl!))))
                                        : const SizedBox.shrink()
                                  ]),
                              title: Text('${entry.value?.word}'),
                              trailing: const Icon(Icons.edit)),
                          onTap: () => checkConnectivity(context).then((_) =>
                              context.push(
                                  '/parent/post?dataId=${entry.value?.dataId}'))))
                      .toList()
                ]
              : [
                  TentativeCard(
                      icon: const Icon(Icons.edit, size: 30.0),
                      label: const Text('知識を投稿しましょう!'),
                      onTap: () => checkConnectivity(context)
                          .then((_) => context.push('/parent/post')))
                ],
          orElse: () => [const Center(child: CircularProgressIndicator())]),
      const HeadingTile('設定'),
      CardTile(
          child: const ListTile(
              leading: Icon(Icons.change_circle),
              title: Text('モード切り替え'),
              subtitle: Text('アプリを開いた時の動作を切り替える')),
          onTap: () => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const ModeSelectDialog())),
      CardTile(
          child:
              const ListTile(leading: Icon(Icons.logout), title: Text('ログアウト')),
          onTap: () => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => UserLogoutDialog(prefs: prefs.value))),
      /*
        CardTile(
            child:
                const ListTile(leading: Icon(Icons.info), title: Text('アプリについて')),
            onTap: () => showAppDetailDialog(context)),
       */
    ]);
  }
}
