import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/components/app_detail.dart';
import 'package:solimage/components/mode_select.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/utils/auth.dart';

// TODO: （余裕があれば）紹介画面をもっと充実させたい
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
          body: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Solimageへ\nようこそ!",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 36, fontWeight: FontWeight.bold)),
                  Image.asset('assets/solimage.png', width: 240, height: 240),
                  ElevatedButton(
                      onPressed: () {
                        final auth = Auth().signIn();
                        auth.then((value) async {
                          if (value != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("ログインしました")));
                            await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const ModeSelectDialog());
                            ref.refresh(authProvider);
                          }
                        });
                      },
                      child: const Text('ログイン'))
                ]),
            Positioned(
                bottom: 20.0,
                child: ElevatedButton.icon(
                    icon: const Icon(Icons.info),
                    label: const Text('アプリについて'),
                    onPressed: () => showAppDetailDialog(context)))
          ]));
}
