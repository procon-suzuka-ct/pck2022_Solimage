import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/camera.dart';

class ImageScreen extends ConsumerWidget {
  const ImageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(imagePathProvider);

    if (image != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(child: Image.file(File(image))),
        ),
      );
    } else {
      return const Scaffold(
          body: SafeArea(
        child: Center(child: CircularProgressIndicator()),
      ));
    }
  }
}
