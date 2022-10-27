import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/camera.dart';
import 'package:solimage/utils/classes/expData.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({Key? key, required this.data}) : super(key: key);

  final ExpData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(imagePathProvider);
    final size = MediaQuery.of(context).size;

    return FittedBox(
        fit: BoxFit.contain,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(data.word,
                      style: const TextStyle(
                          fontSize: 40.0, fontWeight: FontWeight.bold))),
              ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: imagePath.isNotEmpty
                      ? Image.file(File(imagePath))
                      : data.imageUrl!.startsWith('data')
                          ? Image.memory(
                              UriData.parse(data.imageUrl!).contentAsBytes())
                          : CachedNetworkImage(imageUrl: data.imageUrl!)),
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                      width: size.width,
                      child: Center(
                          child: Text(data.meaning,
                              style: const TextStyle(fontSize: 22.0)))))
            ]));
  }
}
