import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/routes/parent/history.dart';
import 'package:solimage/routes/parent/settings.dart';

enum ParentScreens { history, settings }

final List<Map<String, dynamic>> parentScreenTabs = [
  {
    'selectedIcon': const Icon(Icons.history),
    'icon': const Icon(Icons.history_outlined),
    'label': '投稿履歴',
    'child': const HistoryScreen()
  },
  {
    'selectedIcon': const Icon(Icons.settings),
    'icon': const Icon(Icons.settings_outlined),
    'label': '設定',
    'child': const SettingsScreen()
  }
];

class ParentScreen extends ConsumerWidget {
  const ParentScreen({Key? key, required this.tab}) : super(key: key);

  final String? tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int tabIndex = ParentScreens.values.byName(tab!).index;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(parentScreenTabs[tabIndex]['label']),
        ),
        body: Container(
            margin: const EdgeInsets.all(10.0),
            child: parentScreenTabs[tabIndex]['child']),
        bottomNavigationBar: NavigationBar(
            destinations: parentScreenTabs
                .map((element) => NavigationDestination(
                      selectedIcon: element['selectedIcon'],
                      icon: element['icon'],
                      label: element['label'],
                    ))
                .toList(),
            selectedIndex: tabIndex,
            onDestinationSelected: (index) =>
                context.go('/parent/${ParentScreens.values[index].name}')),
        floatingActionButton: tabIndex == 0
            ? Wrap(spacing: 10.0, children: [
                FloatingActionButton.extended(
                    onPressed: () => context.go('/child/camera'),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('カメラ'),
                    heroTag: 'camera'),
                FloatingActionButton.extended(
                    onPressed: () => context.push('/parent/post'),
                    icon: const Icon(Icons.add),
                    label: const Text('投稿'),
                    heroTag: 'post')
              ])
            : null);
  }
}
