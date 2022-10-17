import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/components/app_detail.dart';
import 'package:solimage/components/card_tile.dart';
import 'package:solimage/components/mode_select.dart';
import 'package:solimage/components/parent/group_create.dart';
import 'package:solimage/components/parent/group_detail.dart';
import 'package:solimage/components/parent/group_participate.dart';
import 'package:solimage/components/parent/user_logout.dart';
import 'package:solimage/components/parent/user_name.dart';
import 'package:solimage/components/tentative_card.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/states/preferences.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/group.dart';

final _photoURLProvider = FutureProvider(
    (ref) => ref.watch(authProvider.selectAsync((data) => data?.photoURL)));
final _nameProvider = FutureProvider(
    (ref) => ref.watch(userProvider.selectAsync((data) => data?.name)));

final _groupsProvider = FutureProvider((ref) async => await Future.wait(
    (await ref.watch(userProvider.selectAsync((data) => data?.groups ?? [])))
        .map((groupID) => Group.getGroup(groupID))));

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoURL = ref.watch(_photoURLProvider);
    final name = ref.watch(_nameProvider);
    final groups = ref.watch(_groupsProvider);
    final prefs = ref.watch(prefsProvider);
    final user = ref.watch(userProvider);

    return ListView(children: [
      Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
              verticalDirection: VerticalDirection.down,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                photoURL.maybeWhen(
                    data: (data) => data != null
                        ? Container(
                            margin: const EdgeInsets.all(10.0),
                            child: CircleAvatar(
                                radius: 64.0,
                                backgroundImage:
                                    CachedNetworkImageProvider(data)))
                        : const SizedBox.shrink(),
                    orElse: () => const CircularProgressIndicator()),
                name.maybeWhen(
                    data: (data) =>
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('$dataさん',
                              style: const TextStyle(fontSize: 20.0)),
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => UserNameDialog(
                                      user: user.value,
                                      nameProvider: _nameProvider)))
                        ]),
                    orElse: () => const CircularProgressIndicator())
              ])),
      CardTile(
          child: const ListTile(
              leading: Icon(Icons.change_circle),
              title: Text('モード切り替え'),
              subtitle: Text('アプリを開いた時の動作を切り替える')),
          onTap: () => showDialog(
              context: context,
              builder: (context) => const ModeSelectDialog())),
      CardTile(
          child:
              const ListTile(leading: Icon(Icons.logout), title: Text('ログアウト')),
          onTap: () => showDialog(
              context: context,
              builder: (context) => UserLogoutDialog(prefs: prefs.value))),
      CardTile(
          child:
              const ListTile(leading: Icon(Icons.info), title: Text('アプリについて')),
          onTap: () => showAppDetailDialog(context)),
      ListTile(
          title: const Text('グループ',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          trailing: Wrap(spacing: 10.0, children: [
            ElevatedButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => GroupCreateDialog(user: user.value),
                    useRootNavigator: false),
                child: const Text('作成')),
            ElevatedButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) =>
                        GroupParticipateDialog(user: user.value),
                    useRootNavigator: false),
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
                          onTap: () => showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) =>
                                  GroupDetailDialog(group: group)))
                      : const SizedBox.shrink())
                  .toList()
              : [
                  const TentativeCard(
                      icon: Icon(Icons.group, size: 30.0),
                      label: Text('グループに参加しましょう!'))
                ],
          orElse: () => const [Center(child: CircularProgressIndicator())]),
      // TODO: 親しみやすいUXに改良する
      const ListTile(
          title: Text('閲覧数',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      CardTile(
          padding: const EdgeInsets.all(30.0),
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200.0),
              // TODO: 実際のデータに差し替える
              child: LineChart(LineChartData(
                  lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.grey.withOpacity(0.8),
                          getTooltipItems: (touchedSpots) => touchedSpots
                              .map((item) => LineTooltipItem(
                                  item.y.toStringAsFixed(2),
                                  const TextStyle(color: Colors.white)))
                              .toList())),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                        spots: List.generate(
                            10,
                            (index) =>
                                FlSpot(index.toDouble(), index.toDouble())),
                        dotData: FlDotData(show: true))
                  ]))))
    ]);
  }
}
