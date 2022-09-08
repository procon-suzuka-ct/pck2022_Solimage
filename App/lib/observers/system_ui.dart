import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void changeSystemUi(Route<dynamic>? route, Route<dynamic>? previousRoute) {
  if (route?.settings.name?.contains('/child') == true ||
      previousRoute?.settings.name?.contains('/child') == true) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } else {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));
  }
}

class SystemUiObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      changeSystemUi(route, previousRoute);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      changeSystemUi(route, previousRoute);
}
