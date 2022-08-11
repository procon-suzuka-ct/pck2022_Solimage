import 'package:firebase_auth/firebase_auth.dart';
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
              final User? user = await auth.signIn();
              if (user != null) {
                showDialog<void>(
                    context: context,
                    builder: (_) {
                      return UserDialog(user: user);
                    });
              }
            },
            child: const Text('ログイン'),
          )
        ])));
  }
}

class UserDialog extends StatelessWidget {
  const UserDialog({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('サインインしました'),
      content: Text('ユーザー名: ${user.displayName}'),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            context.replace('/camera');
          },
        ),
      ],
    );
  }
}
