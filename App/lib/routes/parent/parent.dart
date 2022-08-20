import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/states/parent.dart';

class ParentScreen extends ConsumerWidget {
  const ParentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(tabIndexProvider);

    final List<Map<String, dynamic>> parentScreenTabs = [
      {
        'selectedIcon': const Icon(Icons.history),
        'icon': const Icon(Icons.history_outlined),
        'label': '投稿履歴',
        'children': [
          Card(
              child: ListTile(
                  title: const Text('投稿したワード'),
                  trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.push('/parent/post'))))
        ]
      },
      {
        'selectedIcon': const Icon(Icons.settings),
        'icon': const Icon(Icons.settings_outlined),
        'label': '設定',
        'children': [
          const ListTile(
              title: Text('ユーザー情報',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
          Card(
              child: ListTile(
                  title: const Text('名前'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => showAnimatedDialog(
                        context: context,
                        animationType: DialogTransitionType.fadeScale,
                        barrierDismissible: true,
                        builder: (context) => const UserNameDialog()),
                  ))),
          const ListTile(
              title: Text('グループ',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
          Card(
              child: ListTile(
                  title: const Text('グループA'),
                  trailing: IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () => showAnimatedDialog(
                          context: context,
                          animationType: DialogTransitionType.fadeScale,
                          barrierDismissible: true,
                          builder: (context) =>
                              const GroupDialog(groupName: 'グループA'))))),
          Card(
              child: ListTile(
                  title: const Text('グループB'),
                  trailing: IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () => showAnimatedDialog(
                          context: context,
                          animationType: DialogTransitionType.fadeScale,
                          barrierDismissible: true,
                          builder: (context) =>
                              const GroupDialog(groupName: 'グループB'))))),
          Card(
              child: ListTile(
                  title: const Text('グループC'),
                  trailing: IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () => showAnimatedDialog(
                          context: context,
                          animationType: DialogTransitionType.fadeScale,
                          barrierDismissible: true,
                          builder: (context) =>
                              const GroupDialog(groupName: 'グループC'))))),
        ]
      }
    ];

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(parentScreenTabs[tabIndex]['label']),
        ),
        body: Container(
            margin: const EdgeInsets.all(10.0),
            child: ListView(children: parentScreenTabs[tabIndex]['children'])),
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

class UserNameDialog extends StatelessWidget {
  const UserNameDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('ユーザー名'),
        content: const TextField(
            decoration:
                InputDecoration(hintText: '名前を入力してください', labelText: '名前')),
        actions: <Widget>[
          TextButton(
              child: const Text('はい'),
              onPressed: () => Navigator.of(context).pop()),
          TextButton(
              child: const Text('いいえ'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}

class GroupDialog extends StatelessWidget {
  const GroupDialog({Key? key, required this.groupName}) : super(key: key);

  final String groupName;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(groupName),
        actions: <Widget>[
          TextButton(
              child: const Text('閉じる'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}
