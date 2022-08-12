import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solimage/states/router.dart';

class SolimageApp extends ConsumerWidget {
  const SolimageApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Solimage',
      theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          textTheme: Theme.of(context)
              .textTheme
              .apply(decoration: TextDecoration.none)),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
