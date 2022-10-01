import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/utils/classes/user.dart';

class UserNameDialog extends ConsumerWidget {
  const UserNameDialog(
      {Key? key, required this.user, required this.nameProvider})
      : super(key: key);

  final AppUser? user;
  final FutureProvider<String?> nameProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(nameProvider);
    final controller = TextEditingController(text: name.value);

    return AlertDialog(
      title: const Text('名前'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const SimpleDialogOption(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            onPressed: null,
            child: ListTile(
                title: Text('名前を変更します'),
                subtitle: Text('名前はグループ内の人に公開されることがあります'))),
        TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '名前を入力してください'))
      ]),
      actions: <Widget>[
        TextButton(
            child: const Text('OK'),
            onPressed: () {
              if (user != null &&
                  controller.text.isNotEmpty &&
                  controller.text != name.value) {
                user!.setData(user!.uid, controller.text);
                ref.refresh(nameProvider);
                user!.save();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('名前を変更しました')));
              }
              Navigator.of(context).pop();
            }),
        TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
