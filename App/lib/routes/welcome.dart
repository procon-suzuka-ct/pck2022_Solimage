import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/utils/auth.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
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
                  final user = await Auth().signIn();
                  if (user != null) {
                    await showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => const ModeSelectionDialog());
                    ref.read(userProvider.notifier).state = user;
                  }
                },
                child: const Text('ログイン'))
          ])));
}

class ModeSelectionDialog extends StatelessWidget {
  const ModeSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      SimpleDialog(title: const Text('ようこそ!'), children: [
        SimpleDialogOption(
            onPressed: () {},
            child: const ListTile(
                title: Text('主にSolimageを使うのは誰ですか?'),
                subtitle: Text('この設定は後から変更可能です'))),
        SimpleDialogOption(
            onPressed: () async {
              Navigator.of(context).pop();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt('mode', 0);
            },
            child: const ListTile(
              leading: Icon(Icons.face),
              title: Text('大人'),
              subtitle: Text('アプリを開いた時に大人用メニューが開かれます'),
            )),
        SimpleDialogOption(
            onPressed: () async {
              Navigator.of(context).pop();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt('mode', 1);
            },
            child: const ListTile(
              leading: Icon(Icons.child_care),
              title: Text('子ども'),
              subtitle: Text('アプリを開いた時にカメラが開かれます'),
            )),
      ]);
}
