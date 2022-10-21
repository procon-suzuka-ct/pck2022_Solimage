import 'dart:io';

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
        child: imagePath.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Stack(alignment: Alignment.center, children: [
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                              image: FileImage(File(imagePath)),
                              fit: BoxFit.cover))),
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
                                child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(data.meaning!,
                                        style:
                                            const TextStyle(fontSize: 20.0))),
                                onTap: () {})))
                ]))
            : const CircularProgressIndicator());
  }
}
