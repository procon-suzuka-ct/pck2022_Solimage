import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
    FutureProvider.autoDispose.family<void, String>((ref, expDataId) async {
  final expData = await ExpData.getExpData(int.parse(expDataId));

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
  }
});

class PostScreen extends ConsumerWidget {
  const PostScreen({Key? key, this.expDataId}) : super(key: key);

  final String? expDataId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(_stepProvider);
    final user = ref.watch(userProvider);
    final word = ref.watch(_wordProvider);
    final imageUrl = ref.watch(_imageUrlProvider);

    if (expDataId != null) ref.watch(_expDataProvider(expDataId!));

    final List<Map<String, dynamic>> textEditTiles = [
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
      ...textEditTiles.map((tile) {
        final controller = TextEditingController.fromValue(TextEditingValue(
            text: tile['state'],
            selection: TextSelection.collapsed(offset: tile['state'].length)));

        controller.addListener(
            () => ref.read(tile['provider'].notifier).state = controller.text);

        return Step(
            title: Text(tile['title']),
            subtitle: Text(ref.watch(tile['provider'])),
            content: TextField(
                controller: controller,
                decoration: InputDecoration(labelText: tile['title'])));
      })
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿'),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        if (File(imageUrl).existsSync())
          Container(
              constraints: const BoxConstraints(maxHeight: 300.0),
              margin: const EdgeInsets.all(10.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image(image: FileImage(File(imageUrl))))),
        ElevatedButton.icon(
            onPressed: () async => ref.read(_imageUrlProvider.notifier).state =
                (await ImagePicker().pickImage(source: ImageSource.gallery))!
                    .path,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('画像を追加')),
        Stepper(
            physics: const NeverScrollableScrollPhysics(),
            currentStep: step,
            onStepCancel: step != 0
                ? () => ref.read(_stepProvider.notifier).state = step - 1
                : null,
            onStepContinue: step < steps.length - 1
                ? () => ref.read(_stepProvider.notifier).state = step + 1
                : null,
            onStepTapped: (index) =>
                ref.read(_stepProvider.notifier).state = index,
            steps: steps,
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return Container(
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
                  ));
            })
      ])),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final ExpData expData;
            if (expDataId != null) {
              expData = (await ExpData.getExpData(int.parse(expDataId!)))!;
            } else {
              expData = ExpData(
                  word: word,
                  meaning: ref.read(_meaningProvider),
                  userID: user.value!.uid);
              await expData.init();
            }
            expData.setData(
                word: word,
                meaning: ref.read(_meaningProvider),
                why: ref.read(_whyProvider),
                what: ref.read(_whatProvider),
                when: ref.read(_whenProvider),
                where: ref.read(_whereProvider),
                who: ref.read(_whoProvider),
                how: ref.read(_howProvider),
                imageUrl: ref.read(_imageUrlProvider));

            return showDialog(
                context: context,
                builder: (context) => ConfirmDialog(expData: expData));
          },
          icon: const Icon(Icons.check),
          label: const Text('投稿')),
    );
  }
}

class ConfirmDialog extends ConsumerWidget {
  final ExpData expData;

  const ConfirmDialog({Key? key, required this.expData}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
        title: const Text('確認'),
        content: const Text('投稿してもよろしいでしょうか?'),
        actions: <Widget>[
          TextButton(
              child: const Text('はい'),
              onPressed: () => expData.save().then((_) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('投稿しました')));
                    ref.refresh(userProvider);
                    context.go('/parent');
                  })),
          TextButton(
              child: const Text('いいえ'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}
