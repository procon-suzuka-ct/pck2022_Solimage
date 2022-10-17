import 'package:flutter/material.dart';

class TentativeCard extends StatelessWidget {
  const TentativeCard(
      {Key? key, required this.icon, required this.label, this.padding})
      : super(key: key);

  final Widget icon;
  final Widget label;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Card(
      child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
              padding: padding ?? const EdgeInsets.all(50.0),
              child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyLarge!,
                  child: Wrap(
                      direction: Axis.vertical,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runAlignment: WrapAlignment.center,
                      spacing: 10.0,
                      children: [icon, label]))),
          onTap: () {}));
}
