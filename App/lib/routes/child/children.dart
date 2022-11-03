import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/tentative_card.dart';
import 'package:solimage/routes/child/result.dart';
import 'package:solimage/utils/classes/expData.dart';

final _childrenProvider = FutureProvider.autoDispose
    .family<List<ExpData?>, String>((ref, word) async {
  final children = await ExpData.getChilds(word: word);
  children.removeWhere((child) => child == null);
  return children;
});

class ChildrenScreen extends ConsumerWidget {
  const ChildrenScreen({Key? key, required this.word}) : super(key: key);

  final String word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(_childrenProvider(word));

    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          const Text('しゃしんにふれると、けっかをみられます',
              style: TextStyle(fontSize: 20.0), textAlign: TextAlign.center),
          Expanded(
              child: children.maybeWhen(
                  data: (children) => children.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: GridView.count(
                              crossAxisCount: 2,
                              children: children
                                  .map((child) => Card(
                                      child: InkWell(
                                          customBorder: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          onTap: () {
                                            HapticFeedback.heavyImpact();
                                            ref
                                                .read(resultIndexProvider
                                                    .notifier)
                                                .state = 0;
                                            context.push(
                                                '/child/result?word=${child.word}');
                                          },
                                          child: Column(children: [
                                            Expanded(
                                                child: child!.imageUrl != null
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10.0),
                                                        child: child.imageUrl!.startsWith('data')
                                                            ? Image.memory(
                                                                UriData.parse(child.imageUrl!)
                                                                    .contentAsBytes(),
                                                                fit: BoxFit
                                                                    .cover)
                                                            : CachedNetworkImage(
                                                                imageUrl: child
                                                                    .imageUrl!,
                                                                fit: BoxFit
                                                                    .cover,
                                                                placeholder:
                                                                    (context, url) =>
                                                                        const Center(child: CircularProgressIndicator()),
                                                                errorWidget: (context, url, error) => const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4, size: 60.0)))
                                                    : const Icon(Icons.no_photography, size: 60.0)),
                                            Text(child.word,
                                                style: const TextStyle(
                                                    fontSize: 24.0))
                                          ]))))
                                  .toList()))
                      : Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: TentativeCard(
                                  padding: const EdgeInsets.all(20.0),
                                  icon: const Icon(Icons.no_photography),
                                  label: const Text('みつかりません',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  onTap: () => HapticFeedback.heavyImpact()))),
                  orElse: () =>
                      const Center(child: CircularProgressIndicator())))
        ]));
  }
}
