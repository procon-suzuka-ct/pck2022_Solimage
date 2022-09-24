import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solimage/utils/auth.dart';

class UserLogoutDialog extends StatelessWidget {
  const UserLogoutDialog({Key? key, required this.prefs}) : super(key: key);

  final SharedPreferences? prefs;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('ログアウトしてもよろしいでしょうか?'),
        actions: <Widget>[
          TextButton(
              child: const Text('はい'),
              onPressed: () {
                Auth().signOut();
                if (prefs != null) prefs!.clear();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('ログアウトしました')));
              }),
          TextButton(
              child: const Text('いいえ'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
}
