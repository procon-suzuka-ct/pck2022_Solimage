import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef watch) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('おきにいり'),
      ),
    );
  }
}
