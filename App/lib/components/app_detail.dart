import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

Future<void> showAppDetailDialog(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  // TODO: アプリアイコンを追加する
  showAboutDialog(
      context: context,
      applicationName: packageInfo.appName,
      applicationVersion: packageInfo.version,
      applicationLegalese: '@ホームな職場です');
}
