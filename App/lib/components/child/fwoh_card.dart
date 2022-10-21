import 'package:flutter/material.dart';

class FWOHCard extends StatelessWidget {
  const FWOHCard(
      {Key? key,
      required this.label,
      required this.description,
      required this.action})
      : super(key: key);

  final String label;
  final String description;
  final void Function() action;

  @override
  Widget build(BuildContext context) => Card(
      child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          onTap: action,
          child: Center(
              child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(description,
                      style: const TextStyle(
                          fontSize: 30.0, fontWeight: FontWeight.bold))))));
}
