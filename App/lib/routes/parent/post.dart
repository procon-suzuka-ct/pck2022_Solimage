import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solimage/components/parent/post.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';

final _stepProvider = StateProvider.autoDispose((ref) => 0);
final _wordProvider = StateProvider.autoDispose((ref) => '');
final _meaningProvider = StateProvider.autoDispose((ref) => '');
final _whyProvider = StateProvider.autoDispose((ref) => '');
final _whatProvider = StateProvider.autoDispose((ref) => '');
final _whereProvider = StateProvider.autoDispose((ref) => '');
final _whenProvider = StateProvider.autoDispose((ref) => '');
final _whoProvider = StateProvider.autoDispose((ref) => '');
final _howProvider = StateProvider.autoDispose((ref) => '');
final _imageUrlProvider = StateProvider.autoDispose((ref) => '');
final _expDataProvider =
    FutureProvider.autoDispose.family<ExpData, String?>((ref, expDataId) async {
  var expData =
      expDataId != null ? await ExpData.getExpData(int.parse(expDataId)) : null;
  final user = await ref.watch(userProvider.future);

  if (expData != null) {
    ref.read(_wordProvider.notifier).state = expData.word ?? '';
    ref.read(_meaningProvider.notifier).state = expData.meaning ?? '';
    ref.read(_whyProvider.notifier).state = expData.why ?? '';
    ref.read(_whatProvider.notifier).state = expData.what ?? '';
    ref.read(_whereProvider.notifier).state = expData.where ?? '';
    ref.read(_whenProvider.notifier).state = expData.when ?? '';
    ref.read(_whoProvider.notifier).state = expData.who ?? '';
    ref.read(_howProvider.notifier).state = expData.how ?? '';
    ref.read(_imageUrlProvider.notifier).state = expData.imageUrl ?? '';
  } else {
    expData = ExpData(word: '', meaning: '', userID: user!.uid);
    await expData.init();
  }

  return expData;
});

class PostScreen extends ConsumerWidget {
  const PostScreen({Key? key, this.expDataId}) : super(key: key);

  final String? expDataId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(_stepProvider);
    final word = ref.watch(_wordProvider);
    final imageUrl = ref.watch(_imageUrlProvider);
    final expData = ref.watch(_expDataProvider(expDataId));

    final List<Map<String, dynamic>> textEdits = [
      {
        'title': '簡単な説明',
        'provider': _meaningProvider,
        'state': ref.watch(_meaningProvider)
      },
      {
        'title': 'なぜ',
        'provider': _whyProvider,
        'state': ref.watch(_whyProvider)
      },
      {
        'title': 'なに',
        'provider': _whatProvider,
        'state': ref.watch(_whatProvider)
      },
      {
        'title': 'どこで',
        'provider': _whereProvider,
        'state': ref.watch(_whereProvider)
      },
      {
        'title': 'いつ',
        'provider': _whenProvider,
        'state': ref.watch(_whenProvider)
      },
      {
        'title': 'だれ',
        'provider': _whoProvider,
        'state': ref.watch(_whoProvider)
      },
      {
        'title': 'どうやって',
        'provider': _howProvider,
        'state': ref.watch(_howProvider)
      }
    ];

    final steps = [
      Step(
          title: const Text('ワード'),
          subtitle: Text(word),
          content: TreeView(
              treeController: TreeController(allNodesExpanded: false),
              nodes: [
                TreeNode(
                    content: ElevatedButton(
                        onPressed: () {
                          ref.read(_wordProvider.notifier).state = '生物';
                          ref.read(_stepProvider.notifier).state = step + 1;
                        },
                        child: const Text('生物')),
                    children: [
                      TreeNode(
                          content: ElevatedButton(
                              onPressed: () {
                                ref.read(_wordProvider.notifier).state = '虫';
                                ref.read(_stepProvider.notifier).state =
                                    step + 1;
                              },
                              child: const Text('虫')),
                          children: [
                            TreeNode(
                                content: ElevatedButton(
                                    onPressed: () {
                                      ref.read(_wordProvider.notifier).state =
                                          'かまきり';
                                      ref.read(_stepProvider.notifier).state =
                                          step + 1;
                                    },
                                    child: const Text('かまきり')),
                                children: [
                                  TreeNode(
                                      content: ElevatedButton(
                                          onPressed: () {
                                            ref
                                                .read(_wordProvider.notifier)
                                                .state = '触角';
                                            ref
                                                .read(_stepProvider.notifier)
                                                .state = step + 1;
                                          },
                                          child: const Text('触角')))
                                ])
                          ])
                    ]),
              ],
              indent: 20.0)),
      ...textEdits.map((tile) => Step(
          title: Text(tile['title']),
          subtitle: Text(tile['state']),
          content: TextFormField(
              initialValue: tile['state'],
              decoration: InputDecoration(labelText: tile['title']),
              onChanged: (value) =>
                  ref.read(tile['provider'].notifier).state = value))),
    ];

    return expData.maybeWhen(
        data: (data) => Scaffold(
              appBar: AppBar(
                title: const Text('投稿'),
              ),
              body: SingleChildScrollView(
                  child: Column(children: [
                if (imageUrl.isNotEmpty)
                  Container(
                      margin: const EdgeInsets.all(10.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: imageUrl.startsWith('http')
                              ? CachedNetworkImage(
                                  height: 300.0,
                                  imageUrl: imageUrl,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()))
                              : Image.file(File(imageUrl), height: 300.0))),
                ElevatedButton.icon(
                    onPressed: () async {
                      final path = (await ImagePicker()
                              .pickImage(source: ImageSource.gallery))
                          ?.path;

                      if (path != null) {
                        ref.read(_imageUrlProvider.notifier).state = path;
                      }
                    },
                    icon: const Icon(Icons.cloud_upload),
                    label: Text('画像を${imageUrl.isEmpty ? '追加' : '変更'}')),
                Stepper(
                    physics: const NeverScrollableScrollPhysics(),
                    currentStep: step,
                    onStepCancel: step != 0
                        ? () =>
                            ref.read(_stepProvider.notifier).state = step - 1
                        : null,
                    onStepContinue: step < steps.length - 1
                        ? () =>
                            ref.read(_stepProvider.notifier).state = step + 1
                        : null,
                    onStepTapped: (index) =>
                        ref.read(_stepProvider.notifier).state = index,
                    steps: steps,
                    controlsBuilder:
                        (BuildContext context, ControlsDetails details) =>
                            Container(
                                width: double.infinity,
                                margin: const EdgeInsets.all(10.0),
                                child: Wrap(
                                  spacing: 10.0,
                                  children: <Widget>[
                                    ElevatedButton(
                                      //13
                                      onPressed: details.onStepContinue,
                                      child: const Text('次へ'),
                                    ),
                                    ElevatedButton(
                                      //14
                                      onPressed: details.onStepCancel,
                                      child: const Text('戻る'),
                                    ),
                                  ],
                                )))
              ])),
              floatingActionButton: FloatingActionButton.extended(
                  onPressed: () async {
                    expData.value?.setData(
                        word: word,
                        meaning: ref.read(_meaningProvider),
                        why: ref.read(_whyProvider),
                        what: ref.read(_whatProvider),
                        when: ref.read(_whenProvider),
                        where: ref.read(_whereProvider),
                        who: ref.read(_whoProvider),
                        how: ref.read(_howProvider));

                    return expData.value != null
                        ? showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => PostDialog(
                                expData: expData.value!, imagePath: imageUrl))
                        : null;
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('投稿')),
            ),
        orElse: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())));
  }
}
