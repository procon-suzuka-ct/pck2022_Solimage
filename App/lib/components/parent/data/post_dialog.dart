import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/utils/classes/expData.dart';

final _postingProvider = StateProvider.autoDispose((ref) => false);

class DataPostDialog extends ConsumerWidget {
  final ExpData expData;
  final String imagePath;

  const DataPostDialog(
      {Key? key, required this.expData, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posting = ref.watch(_postingProvider);

    return AlertDialog(
      title: Text(posting ? '投稿中' : '確認'),
      content: posting
          ? const Center(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: CircularProgressIndicator())
          : Text(
              '投稿してもよろしいでしょうか?${expData is RecommendData ? '\n既に投稿済みのオススメ情報がある場合、上書きされます' : ''}'),
      actions: [
        TextButton(
            onPressed: !posting
                ? () async {
                    ref.read(_postingProvider.notifier).state = true;

                    if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
                      await expData.saveImage(imagePath: imagePath);
                    }

                    await expData.save().then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('投稿しました')));
                      context.go('/parent');
                    });
                  }
                : null,
            child: const Text('はい')),
        TextButton(
            onPressed: !posting ? () => Navigator.of(context).pop() : null,
            child: const Text('いいえ')),
      ],
    );
  }
}
