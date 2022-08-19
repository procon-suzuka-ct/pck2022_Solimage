import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/states/parent.dart';

final List<Map<String, dynamic>> parentScreenTabs = [
  {
    'selectedIcon': const Icon(Icons.history),
    'icon': const Icon(Icons.history_outlined),
    'label': '投稿履歴'
  },
  {
    'selectedIcon': const Icon(Icons.groups),
    'icon': const Icon(Icons.groups_outlined),
    'label': 'グループ'
  },
  {
    'selectedIcon': const Icon(Icons.person),
    'icon': const Icon(Icons.person_outline),
    'label': 'ユーザー情報'
  }
];

class ParentScreen extends ConsumerWidget {
  const ParentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(tabIndexProvider);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(parentScreenTabs[tabIndex]['label']),
        ),
        body: Center(child: Text(parentScreenTabs[tabIndex]['label'])),
        bottomNavigationBar: NavigationBar(
            destinations: parentScreenTabs
                .map((element) => NavigationDestination(
                      selectedIcon: element['selectedIcon'],
                      icon: element['icon'],
                      label: element['label'],
                    ))
                .toList(),
            selectedIndex: tabIndex,
            onDestinationSelected: (index) {
              ref.read(tabIndexProvider.notifier).state = index;
            }),
        floatingActionButton: tabIndex == 0
            ? Wrap(spacing: 10.0, children: [
                FloatingActionButton.extended(
                    onPressed: () => context.go('/child/camera'),
                    icon: const Icon(Icons.camera),
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
