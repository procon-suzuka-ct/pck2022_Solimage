import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityErrorDialog extends StatelessWidget {
  const ConnectivityErrorDialog({Key? key, required this.result})
      : super(key: key);

  final ConnectivityResult result;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('ネットワークエラー'),
        content: const Text('ネットワークに接続されていません'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
}

Future<void> checkConnectivity(BuildContext context) async {
  final result = await Connectivity().checkConnectivity();

  if (result == ConnectivityResult.none) {
    await showDialog(
      context: context,
      builder: (context) {
        return ConnectivityErrorDialog(result: result);
      },
    );
    return Future.error('ネットワークに接続されていません');
  }
}
