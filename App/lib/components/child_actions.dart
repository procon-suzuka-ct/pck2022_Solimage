import 'package:flutter/material.dart';
import 'package:solimage/utils/classes/hapticFeedback.dart';

class ChildActions extends StatelessWidget {
  const ChildActions({Key? key, required this.actions, this.height = 100.0})
      : super(key: key);

  final List<Widget> actions;
  final double? height;

  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          height: height,
          margin: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 10.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: actions
                  .map((action) => Expanded(
                      child: Container(
                          margin: const EdgeInsets.only(right: 10.0),
                          child: action)))
                  .toList())));
}

class ChildActionButton extends StatelessWidget {
  const ChildActionButton({Key? key, required this.child, this.onPressed})
      : super(key: key);

  final Widget child;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
      onPressed: onPressed != null
          ? () {
              HapticFeedback.heavyImpact();
              onPressed!();
            }
          : null,
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(10.0),
          textStyle:
              const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
      child: FittedBox(fit: BoxFit.contain, child: child));
}
