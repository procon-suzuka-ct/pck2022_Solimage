import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostScreen extends ConsumerWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿'),
      ),
      body: const Center(
        child: Text('投稿'),
      ),
    );
  }
}
