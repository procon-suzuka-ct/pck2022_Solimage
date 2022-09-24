import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/components/app_detail.dart';
import 'package:solimage/components/parent/group_create.dart';
import 'package:solimage/components/parent/group_detail.dart';
import 'package:solimage/components/parent/group_participate.dart';
import 'package:solimage/components/parent/logout.dart';
import 'package:solimage/components/parent/user_name.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/states/groups.dart';
import 'package:solimage/states/preferences.dart';
import 'package:solimage/states/user.dart';

final _photoURLProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(authProvider.future).then((auth) => auth?.photoURL));
final _nameProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(userProvider.future).then((user) => user?.name));

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoURL = ref.watch(_photoURLProvider);
    final name = ref.watch(_nameProvider);
    final groups = ref.watch(groupsProvider);
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
      Card(
          child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const ListTile(
                  leading: Icon(Icons.logout), title: Text('ログアウト')),
              onTap: () => showDialog(
                  context: context,
                  builder: (context) => LogoutDialog(prefs: prefs.value)))),
      Card(
          child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const ListTile(
                  leading: Icon(Icons.info), title: Text('アプリについて')),
              onTap: () => showAppDetailDialog(context))),
      ListTile(
          title: const Text('グループ',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          trailing: Wrap(spacing: 10.0, children: [
            ElevatedButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) =>
                        GroupCreateDialog(parentRef: ref, user: user.value),
                    useRootNavigator: false),
                child: const Text('作成')),
            ElevatedButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => GroupParticipateDialog(
                        parentRef: ref, user: user.value),
                    useRootNavigator: false),
                child: const Text('参加'))
          ])),
      ...groups.maybeWhen(
          data: (data) => data
              .map((group) => group != null
                  ? Card(
                      child: InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                              leading: const Icon(Icons.group),
                              title: Text(group.groupName),
                              trailing: const Icon(Icons.info)),
                          onTap: () => showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => GroupDetailDialog(
                                  parentRef: ref, group: group))))
                  : const SizedBox.shrink())
              .toList(),
          orElse: () => const [Center(child: CircularProgressIndicator())]),
      const ListTile(
          title: Text('アクセス履歴',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      Card(
          child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                  margin: const EdgeInsets.all(20.0),
                  constraints: const BoxConstraints(maxHeight: 200.0),
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
                      ]))),
              onTap: () {}))
    ]);
  }
}
