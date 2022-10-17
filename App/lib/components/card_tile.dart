import 'package:flutter/material.dart';

class CardTile extends StatelessWidget {
  const CardTile({Key? key, required this.child, this.padding, this.onTap})
      : super(key: key);

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) => Card(
      child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: onTap ?? () {},
          child: Padding(
              padding: padding ?? const EdgeInsets.all(5.0), child: child)));
}
