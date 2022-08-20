import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/camera.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(imageProvider);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Center(
      child: image.when(
          data: (data) => AspectRatio(
              aspectRatio: 9.0 / 16.0,
              child: SizedBox(
                  height: height,
                  child: Image.file(File(data.path), fit: BoxFit.fitHeight))),
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => Text('エラーが発生しました: $error')),
    ));
  }
}
