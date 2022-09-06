import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';

final _expDatasProvider =
    StateProvider((ref) => ref.watch(userProvider).value?.expDatas);

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expDatas = ref.watch(_expDatasProvider);

    return ListView(children: [
      if (expDatas != null)
        ...expDatas.map((expDataId) {
          final expData = ExpData.getExpData(expDataId);

          return FutureBuilder<ExpData?>(
              future: expData,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.data != null) {
                  return Card(
                      child: ListTile(
                          title: Text('${snapshot.data!.word}'),
                          trailing: const Icon(Icons.edit),
                          onTap: () => context.push('/parent/post')));
                }

                return const SizedBox();
              });
        })
    ]);
  }
}
