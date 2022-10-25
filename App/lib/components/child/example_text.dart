import 'package:flutter/material.dart';

class ExampleText extends StatelessWidget {
  const ExampleText(this.data, {Key? key}) : super(key: key);

  final String? data;

  @override
  Widget build(BuildContext context) =>
      Text('例: ${data ?? ''}', style: Theme.of(context).textTheme.labelMedium);
}
