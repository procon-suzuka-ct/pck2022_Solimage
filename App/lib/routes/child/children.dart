import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/components/parent/heading_tile.dart';
import 'package:solimage/components/tentative_card.dart';
import 'package:solimage/routes/child/result.dart';
import 'package:solimage/utils/classes/expData.dart';
import 'package:solimage/utils/classes/word.dart';

final _wordProvider =
    FutureProvider.family<Word?, String>((ref, word) => Word.getWord(word));
final _childrenProvider =
    FutureProvider.family<List<ExpData?>, Word?>((ref, word) async {
  if (word == null) return [];
  final children = await ExpData.getChilds(word: word.word);
  children.removeWhere((child) => child == null);
  children.shuffle();
  return children
      .getRange(0, children.length > 2 ? 2 : children.length)
      .toList();
});
final _othersProvider =
    FutureProvider.family<List<ExpData?>, Word?>((ref, word) async {
  if (word == null) return [];
  final children = await ExpData.getChilds(word: word.root);
  children.removeWhere((child) => child!.word == word.word);
  children.removeWhere((child) => child == null);
  children.shuffle();
  return children
      .getRange(0, children.length > 2 ? 2 : children.length)
      .toList();
});

class ChildrenScreen extends ConsumerWidget {
  const ChildrenScreen({Key? key, required this.label}) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final word = ref.watch(_wordProvider(label));
    final children = ref.watch(_childrenProvider(word.value));
    final others = ref.watch(_othersProvider(word.value));

    return word.maybeWhen(
        data: (word) => Padding(
            padding: const EdgeInsets.all(10.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const HeadingTile('もっとくわしく'),
              Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10.0, left: 10.0, right: 10.0),
                  child: Text('${word?.word}について、さらにくわしくしらべてみよう',
                      style: Theme.of(context).textTheme.headlineSmall)),
              Expanded(
                  child: children.maybeWhen(
                      data: (children) => children.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                  children: children
                                      .map((child) => Card(
                                          child: InkWell(
                                              customBorder:
                                                  RoundedRectangleBorder(
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
                                                            child: child
                                                                    .imageUrl!
                                                                    .startsWith(
                                                                        'data')
                                                                ? Image.memory(
                                                                    UriData.parse(child.imageUrl!)
                                                                        .contentAsBytes(),
                                                                    fit: BoxFit
                                                                        .cover)
                                                                : CachedNetworkImage(
                                                                    imageUrl: child
                                                                        .imageUrl!,
                                                                    fit: BoxFit.cover,
                                                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                    errorWidget: (context, url, error) => const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4, size: 60.0)))
                                                        : const Icon(Icons.no_photography, size: 60.0)),
                                                Text(child.word,
                                                    style: const TextStyle(
                                                        fontSize: 24.0))
                                              ]))))
                                      .toList()))
                          : FittedBox(
                              fit: BoxFit.fitWidth,
                              child: TentativeCard(
                                  padding: const EdgeInsets.all(20.0),
                                  icon: const Icon(Icons.no_photography),
                                  label: const Text('まだないよ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  onTap: () => HapticFeedback.heavyImpact())),
                      orElse: () =>
                          const Center(child: CircularProgressIndicator()))),
              const HeadingTile('これもみてみよう'),
              Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10.0, left: 10.0, right: 10.0),
                  child: Text('${word?.word}ににているものについて、しらべてみよう',
                      style: Theme.of(context).textTheme.headlineSmall)),
              Expanded(
                  child: others.maybeWhen(
                      data: (others) => others.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                  children: others
                                      .map((other) => Expanded(
                                          child: Card(
                                              child: InkWell(
                                                  customBorder:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  onTap: () {
                                                    HapticFeedback
                                                        .heavyImpact();
                                                    ref
                                                        .read(
                                                            resultIndexProvider
                                                                .notifier)
                                                        .state = 0;
                                                    context.push(
                                                        '/child/result?word=${other.word}');
                                                  },
                                                  child: Column(children: [
                                                    Expanded(
                                                        child: other!.imageUrl !=
                                                                null
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        10.0),
                                                                child: other
                                                                        .imageUrl!
                                                                        .startsWith(
                                                                            'data')
                                                                    ? Image.memory(
                                                                        UriData.parse(other.imageUrl!)
                                                                            .contentAsBytes(),
                                                                        fit: BoxFit
                                                                            .cover)
                                                                    : CachedNetworkImage(
                                                                        imageUrl:
                                                                            other.imageUrl!,
                                                                        fit: BoxFit.cover,
                                                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                        errorWidget: (context, url, error) => const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4, size: 60.0)))
                                                            : const Icon(Icons.no_photography, size: 60.0)),
                                                    Text(other.word,
                                                        style: const TextStyle(
                                                            fontSize: 24.0))
                                                  ])))))
                                      .toList()))
                          : FittedBox(
                              fit: BoxFit.fitWidth,
                              child: TentativeCard(
                                  padding: const EdgeInsets.all(20.0),
                                  icon: const Icon(Icons.no_photography),
                                  label: const Text('まだないよ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  onTap: () => HapticFeedback.heavyImpact())),
                      orElse: () =>
                          const Center(child: CircularProgressIndicator())))
            ])),
        orElse: () => const Center(child: CircularProgressIndicator()));
  }
}
