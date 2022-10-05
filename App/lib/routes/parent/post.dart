import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solimage/components/parent/data_delete.dart';
import 'package:solimage/components/parent/data_post.dart';
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
final _isRecommendDataProvider = StateProvider.autoDispose((ref) => false);
final _dataProvider =
    FutureProvider.autoDispose.family<ExpData?, String?>((ref, dataId) async {
  final uid = await ref.watch(userProvider.selectAsync((data) => data?.uid));
  var expData = dataId != null
      ? dataId != uid
          ? await ExpData.getExpData(int.parse(dataId))
          : await RecommendData.getRecommendData(dataId)
      : null;

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

    if (expData.runtimeType == RecommendData) {
      ref.read(_isRecommendDataProvider.notifier).state = true;
    }
  }

  return expData;
});

// TODO: 必須項目の確認機能を追加する
class PostScreen extends ConsumerWidget {
  const PostScreen({Key? key, this.dataId}) : super(key: key);

  final String? dataId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(_stepProvider);
    final word = ref.watch(_wordProvider);
    final meaning = ref.watch(_meaningProvider);
    final imageUrl = ref.watch(_imageUrlProvider);
    final expData = ref.watch(_dataProvider(dataId));
    final user = ref.watch(userProvider.future);
    final isRecommendData = ref.watch(_isRecommendDataProvider);

    final List<Map<String, dynamic>> textEdits = [
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
      // TODO: 実際のデータに差し替える
      Step(
          title: const Text('ワード'),
          subtitle: Text(word),
          content: TreeView(
              treeController: TreeController(allNodesExpanded: false),
              nodes: [
                TreeNode(content: const Text('生物'), children: [
                  TreeNode(
                      content: ElevatedButton(
                          onPressed: () {
                            ref.read(_wordProvider.notifier).state = '虫';
                            ref.read(_stepProvider.notifier).state = step + 1;
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
                                        ref.read(_wordProvider.notifier).state =
                                            '触角';
                                        ref.read(_stepProvider.notifier).state =
                                            step + 1;
                                      },
                                      child: const Text('触角')))
                            ])
                      ])
                ]),
              ],
              indent: 20.0)),
      Step(
          title: const Text('簡単な説明'),
          subtitle: Text(meaning),
          content: TextFormField(
              initialValue: meaning,
              decoration: const InputDecoration(labelText: '簡単な説明'),
              onChanged: (value) =>
                  ref.read(_meaningProvider.notifier).state = value)),
      // TODO: 具体例を追加する
      Step(
          title: const Text('5W1H'),
          content: Column(
              children: textEdits
                  .map((tile) => TextFormField(
                      initialValue: tile['state'],
                      decoration: InputDecoration(labelText: tile['title']),
                      onChanged: (value) =>
                          ref.read(tile['provider'].notifier).state = value))
                  .toList())),
      Step(
          title: const Text('画像'),
          content: Column(children: [
            if (imageUrl.isNotEmpty)
              Container(
                  margin: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: imageUrl.startsWith('http')
                          ? CachedNetworkImage(
                              height: 500.0,
                              imageUrl: imageUrl,
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()))
                          : Image.file(File(imageUrl)))),
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
                label: Text('画像を${imageUrl.isEmpty ? '追加' : '変更'}'))
          ])),
      Step(
        title: const Text('オススメ'),
        content: Checkbox(
            value: isRecommendData,
            onChanged: expData.value.runtimeType != RecommendData
                ? (value) {
                    ref.read(_isRecommendDataProvider.notifier).state =
                        value ?? false;
                  }
                : null),
      )
    ];

    return expData.maybeWhen(
        data: (data) => Scaffold(
              appBar: AppBar(title: const Text('投稿'), centerTitle: true),
              body: SingleChildScrollView(
                  child: Column(children: [
                if (data != null)
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                          leading: const Icon(Icons.info),
                          title: const Text('既に投稿済みです'),
                          trailing: ElevatedButton.icon(
                              onPressed: () async {
                                final awaitedUser = await user;
                                if (awaitedUser != null) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => DataDeleteDialog(
                                          user: awaitedUser, expData: data));
                                }
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('削除')))),
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
                                  alignment: WrapAlignment.center,
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
                    if (word.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ワードが選択されていません')));
                      return;
                    }

                    if (meaning.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('簡単な説明が入力されていません')));
                      return;
                    }

                    ExpData expData;

                    if (!isRecommendData) {
                      if (data != null) {
                        expData = data;
                      } else {
                        expData = ExpData(
                            word: '', meaning: '', userID: (await user)!.uid);
                        await expData.init();
                      }
                    } else {
                      expData = RecommendData(
                          word: '', meaning: '', userID: (await user)!.uid);
                    }

                    expData.setData(
                        word: word,
                        meaning: ref.read(_meaningProvider),
                        why: ref.read(_whyProvider),
                        what: ref.read(_whatProvider),
                        when: ref.read(_whenProvider),
                        where: ref.read(_whereProvider),
                        who: ref.read(_whoProvider),
                        how: ref.read(_howProvider));

                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => DataPostDialog(
                            expData: expData, imagePath: imageUrl));
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('投稿')),
            ),
        orElse: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())));
  }
}
