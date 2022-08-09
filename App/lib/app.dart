import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './routes/index.dart';

class SolimageApp extends StatelessWidget {
  SolimageApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: ThemeData(
      // This is the theme of your application.
      //
      // Try running your application with "flutter run". You'll see the
      // application has a blue toolbar. Then, without quitting the app, try
      // changing the primarySwatch below to Colors.green and then invoke
      // "hot reload" (press "r" in the console where you ran "flutter run",
      // or simply save your changes to "hot reload" in a Flutter IDE).
      // Notice that the counter didn't reset back to zero; the application
      // is not restarted.
      primarySwatch: Colors.blue,
    ),
    routerDelegate: router.routerDelegate,
    routeInformationParser: router.routeInformationParser,
    routeInformationProvider: router.routeInformationProvider,
  );

  final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
            path: '/',
            name: 'index',
            builder: (context, state) => IndexScreen(title: 'Solimage')
        )
      ]
  );
}