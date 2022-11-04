import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/child/child_actions.dart';
import 'package:solimage/routes/child/children.dart';
import 'package:solimage/routes/child/fwoh.dart';
import 'package:solimage/routes/child/summary.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';
import 'package:solimage/utils/classes/word.dart';

final resultIndexProvider = StateProvider.autoDispose((ref) => 0);
final _expDataProviderFamily =
    FutureProvider.autoDispose.family<ExpData?, String>((ref, value) async {
      final user = await ref.read(userProvider.future);
  ExpData? expData = await ExpData.getExpDataByWord(word: value);
  final word = (await Word.getWord(value))!.key;

  if (expData != null && user != null && !(user.histories.contains(word))) {
    user.histories.add(word);
    await user.save();
  }

  expData ??= await RecommendData.getExpDataByWord(userId: value);
  expData ??= await ExpData.getExpData(0);

  return expData;
});

class ResultScreen extends ConsumerWidget {
  const ResultScreen({Key? key, this.word, this.userId}) : super(key: key);

  final String? word;
  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(resultIndexProvider);
    final expData = ref.watch(_expDataProviderFamily(word ?? userId!));
    final controller = PageController();

    return SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: expData.maybeWhen(
            data: (data) => Scaffold(
                appBar: currentPage != 0
                    ? AppBar(
                        centerTitle: true,
                        title: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(data?.word ?? word!,
                                style: const TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.bold))),
                        automaticallyImplyLeading: false,
                      )
                    : null,
                body: Column(children: [
                  Expanded(
                      child: PageView(
                          controller: controller,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (page) => ref
                              .read(resultIndexProvider.notifier)
                              .state = page,
                          children: [
                        SummaryScreen(data: data!),
                        FWOHScreen(data: data),
                        ChildrenScreen(label: word!)
                      ])),
                  ChildActions(actions: [
                    ChildActionButton(
                        onPressed: currentPage != 0
                            ? () => controller.previousPage(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut)
                            : () => context.pop(),
                        child: const Text('もどる')),
                    ChildActionButton(
                        onPressed: currentPage != 2
                            ? () => controller.nextPage(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut)
                            : () {
                                Navigator.of(context).popUntil((route) =>
                                    route.settings.name == '/child/camera');
                                context.go('/child/camera');
                              },
                        child: Text(currentPage != 2 ? 'くわしく' : 'カメラをひらく'))
                  ])
                ])),
            orElse: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()))));
  }
}
