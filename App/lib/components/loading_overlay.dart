import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({Key? key, this.visible = false}) : super(key: key);

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return visible
        ? Container(
            decoration:
                const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.8)),
            child: Wrap(
                direction: Axis.vertical,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: const <Widget>[CircularProgressIndicator()]),
          )
        : const SizedBox.shrink();
  }
}
