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
    final int currentIndex = ParentScreens.values.byName(screen!).index;

    return Scaffold(
      appBar: AppBar(
        title: Text(parentScreenTabs[currentIndex].label),
      ),
      body: Text(parentScreenTabs[currentIndex].label),
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
    );
  }
}
