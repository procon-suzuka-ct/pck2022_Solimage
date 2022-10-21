import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/child_actions.dart';
import 'package:solimage/routes/child/conclusion.dart';
import 'package:solimage/routes/child/fwoh.dart';
import 'package:solimage/routes/child/summary.dart';
import 'package:solimage/utils/classes/expData.dart';

final _currentPageProvider = StateProvider.autoDispose((ref) => 0);
final _expDataProviderFamily =
    FutureProvider.autoDispose.family<ExpData?, String>((ref, word) async {
  /*
    final expData = await ExpData.getExpDataByWord(word: word);

    if (expData != null) await expData.addViews();
   */
  final expData = await ExpData.getExpData(0);

  return expData;
});

// TODO: 実際のデータに差し替える（ほぼ実装済み、動作未確認）
class ResultScreen extends ConsumerWidget {
  const ResultScreen({Key? key, required this.word}) : super(key: key);

  final String word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(_currentPageProvider);
    final expData = ref.watch(_expDataProviderFamily(word));
    final controller = PageController();

    return expData.maybeWhen(
        data: (data) => Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Container(
                  margin: const EdgeInsets.all(10.0),
                  child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(data?.word ?? word,
                          style: const TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold)))),
              automaticallyImplyLeading: false,
            ),
            body: Column(children: [
              Expanded(
                  child: PageView(
                      controller: controller,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) =>
                          ref.read(_currentPageProvider.notifier).state = page,
                      children: [
                    SummaryScreen(data: data!),
                    FWOHScreen(data: data, size: MediaQuery.of(context).size),
                    const ConclusionScreen()
                  ])),
              ChildActions(actions: [
                ChildActionButton(
                    onPressed: currentPage != 0
                        ? () => controller.previousPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut)
                        : () => context.pop(),
                    child: const Text('もどる')),
                currentPage != 2
                    ? ChildActionButton(
                        onPressed: () => controller.nextPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut),
                        child: const Text('くわしく'))
                    : const SizedBox()
              ])
            ])),
        orElse: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())));
  }
}
