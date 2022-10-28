import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:solimage/components/mode_select.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/utils/auth.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
          body: IntroductionScreen(
              pages: [
            PageViewModel(
                title: 'Solimageへ\nようこそ!',
                bodyWidget: ElevatedButton(
                    onPressed: () => Auth().signIn().then((value) async {
                          if (value != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("ログインしました")));
                            await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const ModeSelectDialog());
                            ref.refresh(authProvider);
                          }
                        }),
                    child: const Text('はじめる')),
                image: Image.asset('assets/solimage.png',
                    width: 240, height: 240)),
            PageViewModel(
                title: 'Solimageへ\nようこそ!',
                bodyWidget: ElevatedButton(
                    onPressed: () => Auth().signIn().then((value) async {
                          if (value != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("ログインしました")));
                            await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const ModeSelectDialog());
                            ref.refresh(authProvider);
                          }
                        }),
                    child: const Text('はじめる')),
                image:
                    Image.asset('assets/solimage.png', width: 240, height: 240))
          ],
              showBackButton: true,
              showSkipButton: false,
              back: const Text('Back'),
              next: const Text('Next'),
              done: const Text("Done",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onDone: () {}));
}
