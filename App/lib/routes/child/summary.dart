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

    return Center(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: FittedBox(
                          fit: BoxFit.cover,
                          child: imagePath.isNotEmpty
                              ? Image.file(File(imagePath))
                              : CachedNetworkImage(imageUrl: data.imageUrl!))),
                  if (data.meaning != null)
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(10.0))),
                            margin: EdgeInsets.zero,
                            child: InkWell(
                                customBorder: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(10.0))),
                                child: Center(
                                    heightFactor: 1.0,
                                    child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(data.meaning!,
                                            style: const TextStyle(
                                                fontSize: 22.0)))),
                                onTap: () {})))
                ])));
  }
}
