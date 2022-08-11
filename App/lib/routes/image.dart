import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageProvider = StateProvider<String>((ref) => '');

class ImageScreen extends ConsumerWidget {
  const ImageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(imageProvider);

    return Scaffold(
      body: Center(
        child: Image.file(File(image)),
      ),
    );
  }
}