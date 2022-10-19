import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solimage/components/child/example_text.dart';
import 'package:solimage/components/parent/data/delete_dialog.dart';
import 'package:solimage/components/parent/data/post_dialog.dart';
import 'package:solimage/components/parent/data/word_tree.dart';
import 'package:solimage/states/post.dart';
import 'package:solimage/states/user.dart';
import 'package:solimage/utils/classes/expData.dart';

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
    ref.read(wordProvider.notifier).state = expData.word ?? '';
    ref.read(_meaningProvider.notifier).state = expData.meaning ?? '';
    ref.read(_whyProvider.notifier).state = expData.why ?? '';
    ref.read(_whatProvider.notifier).state = expData.what ?? '';
    ref.read(_whereProvider.notifier).state = expData.where ?? '';
    ref.read(_whenProvider.notifier).state = expData.when ?? '';
    ref.read(_whoProvider.notifier).state = expData.who ?? '';
    ref.read(_howProvider.notifier).state = expData.how ?? '';
    ref.read(_imageUrlProvider.notifier).state = expData.imageUrl ?? '';

    if (expData is RecommendData) {
      ref.read(_isRecommendDataProvider.notifier).state = true;
    }
  }

  return expData;
});
final _exampleDataProvider = FutureProvider((ref) => ExpData.getExpData(6));

class PostScreen extends ConsumerWidget {
  const PostScreen({Key? key, this.dataId}) : super(key: key);

  final String? dataId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(stepProvider);
    final word = ref.watch(wordProvider);
    final meaning = ref.watch(_meaningProvider);
    final why = ref.watch(_whyProvider);
    final what = ref.watch(_whatProvider);
    final where = ref.watch(_whereProvider);
    final when = ref.watch(_whenProvider);
    final who = ref.watch(_whoProvider);
    final how = ref.watch(_howProvider);
    final is5W1HValid = [why, what, when, where, who, how]
        .map((element) => element.isNotEmpty)
        .contains(true);
    final imageUrl = ref.watch(_imageUrlProvider);
    final expData = ref.watch(_dataProvider(dataId));
    final exampleData = ref.watch(_exampleDataProvider);
    final user = ref.watch(userProvider.future);
    final isRecommendData = ref.watch(_isRecommendDataProvider);
    final steps = [
      Step(
          title: const Text('オススメ'),
          subtitle: const Text('有効にすると、より多くの人に見てもらえます'),
          content: Checkbox(
              value: isRecommendData,
              onChanged: expData.value is! RecommendData
                  ? (value) {
                      ref.read(_isRecommendDataProvider.notifier).state =
                          value ?? false;
                    }
                  : null),
          state: step != 0 ? StepState.complete : StepState.indexed),
      Step(
          title: const Text('ワード'),
          subtitle: const Text('必須です'),
          content: const Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, child: WordTree()))),
          state: step != 1 && word.isNotEmpty
              ? StepState.complete
              : StepState.indexed),
      Step(
          title: const Text('簡単な説明'),
          subtitle: const Text('必須です'),
          content: exampleData.maybeWhen(
              data: (data) => Column(children: [
                    TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) =>
                            value == null || value.isEmpty ? '入力してください' : null,
                        initialValue: meaning,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: '簡単な説明'),
                        onChanged: (value) =>
                            ref.read(_meaningProvider.notifier).state = value),
                    ExampleText(data?.meaning)
                  ]),
              orElse: () => const Center(child: CircularProgressIndicator())),
          state: step != 2 && meaning.isNotEmpty
              ? StepState.complete
              : StepState.indexed),
      Step(
          title: const Text('画像'),
          subtitle: const Text('オススメする場合は必須です'),
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
                          .pickImage(source: ImageSource.camera))
                      ?.path;

                  if (path != null) {
                    ref.read(_imageUrlProvider.notifier).state = path;
                  }
                },
                icon: const Icon(Icons.camera_alt),
                label: Text('画像を${imageUrl.isEmpty ? '撮影' : '変更'}')),
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
          ]),
          state: step != 3 && (isRecommendData ? imageUrl.isNotEmpty : true)
              ? StepState.complete
              : StepState.indexed),
      Step(
          title: const Text('5W1H'),
          subtitle: const Text('可能な限り入力してください'),
          content: exampleData.maybeWhen(
              data: (data) => Wrap(spacing: 10.0, children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                            initialValue: why,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(), labelText: 'なぜ'),
                            onChanged: (value) =>
                                ref.read(_whyProvider.notifier).state = value)),
                    ExampleText(data?.why),
                    Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                            initialValue: what,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(), labelText: 'なに'),
                            onChanged: (value) => ref
                                .read(_whatProvider.notifier)
                                .state = value)),
                    ExampleText(data?.what),
                    Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                            initialValue: where,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(), labelText: 'どこ'),
                            onChanged: (value) => ref
                                .read(_whereProvider.notifier)
                                .state = value)),
                    ExampleText(data?.where),
                    Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                            initialValue: when,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(), labelText: 'いつ'),
                            onChanged: (value) => ref
                                .read(_whenProvider.notifier)
                                .state = value)),
                    ExampleText(data?.when),
                    Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                            initialValue: who,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(), labelText: 'だれ'),
                            onChanged: (value) =>
                                ref.read(_whoProvider.notifier).state = value)),
                    ExampleText(data?.who),
                    Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                            initialValue: how,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'どうやって'),
                            onChanged: (value) =>
                                ref.read(_howProvider.notifier).state = value)),
                    ExampleText(data?.how)
                  ]),
              orElse: () => const CircularProgressIndicator()),
          state:
              step != 4 && is5W1HValid ? StepState.complete : StepState.indexed)
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
                          title: Text('投稿済み\n閲覧数: ${data.views}回'),
                          trailing: ElevatedButton.icon(
                              onPressed: () async {
                                final awaitedUser = await user;
                                if (awaitedUser != null) {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
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
                        ? () => ref.read(stepProvider.notifier).state = step - 1
                        : null,
                    onStepContinue: step < steps.length - 1
                        ? () => ref.read(stepProvider.notifier).state = step + 1
                        : null,
                    onStepTapped: (index) =>
                        ref.read(stepProvider.notifier).state = index,
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
                    ScaffoldMessenger.of(context).clearSnackBars();

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

                    if (isRecommendData && imageUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('画像を追加してください')));
                      return;
                    }

                    if (!is5W1HValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('5W1Hは1つ以上入力してください')));
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
