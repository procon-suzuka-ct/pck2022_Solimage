import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/states/auth.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
        body: Center(
            child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: Axis.vertical,
                spacing: 20,
                children: <Widget>[
          Text("Solimageへ\nようこそ!",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 40, fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: () async {
              auth.signIn();
              if (auth.currentUser() != null) context.go('/child/camera');
            },
            child: const Text('ログイン'),
          )
        ])));
  }
}
