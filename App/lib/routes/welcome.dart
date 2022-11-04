import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:introduction_screen/introduction_screen.dart";
import 'package:solimage/components/connectivity.dart';
import "package:solimage/components/mode_select.dart";
import 'package:solimage/states/auth.dart';
import 'package:solimage/utils/auth.dart';

final _introIndexProvider = StateProvider.autoDispose((ref) => 0);

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introIndex = ref.watch(_introIndexProvider);

    return Scaffold(
        body: IntroductionScreen(
            pages: [
          PageViewModel(
              titleWidget: Text("Solimageへ\nようこそ",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 30, fontWeight: FontWeight.bold)),
              body: '',
              image:
                  Image.asset("assets/solimage.png", width: 200, height: 200)),
          PageViewModel(
              titleWidget: Text("カメラで撮影して\n調べましょう",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 30, fontWeight: FontWeight.bold)),
              bodyWidget: Text("撮影した写真から\n5W1Hの形式で知識を得られます",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center),
              image: const Icon(Icons.camera_alt, size: 160)),
          PageViewModel(
              titleWidget: Text("子どもの知識を\n増やしましょう",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 30, fontWeight: FontWeight.bold)),
              bodyWidget: Text("経験や言い伝えなどのあなたの知識を\n子どもたちに広げましょう",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center),
              image: const Icon(Icons.message, size: 160)),
          PageViewModel(
              titleWidget: Text("グループに\n参加しましょう",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 30, fontWeight: FontWeight.bold)),
              bodyWidget: Text("グループ内の他のメンバーと、\nグループならではの知識を共有できます",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center),
              image: const Icon(Icons.groups, size: 160))
        ],
            showBackButton: introIndex != 0 ? true : false,
            back: const Text("戻る"),
            next: const Text("次へ"),
            done: const Text("ログイン"),
            onChange: (index) =>
                ref.read(_introIndexProvider.notifier).state = index,
            onDone: () => checkConnectivity(context)
                .then((_) => ref.read(authProvider.future).then((auth) async {
                      await Auth().signIn().then((value) async {
                        if (value != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("ログインしました")));
                          await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const ModeSelectDialog());
                          await ref.refresh(authProvider.future);
                        }
                      });
                    }))));
  }
}
