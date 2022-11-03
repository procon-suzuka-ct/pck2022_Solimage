import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:solimage/utils/classes/expData.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({Key? key, required this.data}) : super(key: key);

  final ExpData data;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(data.word,
                    style: const TextStyle(
                        fontSize: 40.0, fontWeight: FontWeight.bold))),
            Expanded(
                child: data.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: data.imageUrl!.startsWith('data')
                            ? Image.memory(
                                UriData.parse(data.imageUrl!).contentAsBytes(),
                                fit: BoxFit.contain)
                            : CachedNetworkImage(
                                imageUrl: data.imageUrl!,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => const Icon(
                                    Icons
                                        .signal_wifi_statusbar_connected_no_internet_4,
                                    size: 60.0)))
                    : const Icon(Icons.no_photography, size: 80.0))
          ]));
}
