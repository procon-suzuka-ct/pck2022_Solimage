import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/router.dart';

class ParentScreenTab {
  final Icon icon;
  final String label;

  ParentScreenTab({required this.icon, required this.label});
}

final List<ParentScreenTab> parentScreenTabs = [
  ParentScreenTab(icon: const Icon(Icons.history), label: '投稿履歴'),
  ParentScreenTab(icon: const Icon(Icons.person), label: 'ユーザー情報'),
  ParentScreenTab(icon: const Icon(Icons.group), label: 'グループ')
];

class ParentScreen extends ConsumerWidget {
  const ParentScreen({Key? key, this.screen}) : super(key: key);

  final String? screen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ParentScreens.values.byName(screen!).index;
    final currentName = ParentScreens.values.elementAt(currentIndex).name;

    return Scaffold(
        appBar: AppBar(
          title: Text(parentScreenTabs[currentIndex].label),
        ),
        body: Center(child: Text(parentScreenTabs[currentIndex].label)),
        bottomNavigationBar: BottomNavigationBar(
            items: parentScreenTabs
                .map((element) => BottomNavigationBarItem(
                      icon: element.icon,
                      label: element.label,
                    ))
                .toList(),
            currentIndex: currentIndex,
            onTap: (index) {
              ref
                  .read(routerProvider)
                  .go('/parent/${ParentScreens.values[index].name}');
            }),
        floatingActionButton: currentName == 'history'
            ? Wrap(spacing: 10.0, children: [
                FloatingActionButton.extended(
                    onPressed: () {
                      ref.read(routerProvider).go('/camera');
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text('カメラ'),
                    heroTag: 'camera'),
                FloatingActionButton.extended(
                    onPressed: () {
                      ref.read(routerProvider).push('/parent/post');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('投稿'),
                    heroTag: 'post')
              ])
            : null);
  }
}
