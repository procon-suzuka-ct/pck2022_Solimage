import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:solimage/utils/auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key, required this.auth}) : super(key: key);

  final Auth auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await auth.signIn();
            if (auth.currentUser() != null) {
              showDialog<void>(
                  context: context,
                  builder: (_) {
                    return UserDialog(user: auth.currentUser() as User);
                  }
              );
            }
          },
          child: const Text('Login'),
        ),
      ),
    );
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
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}