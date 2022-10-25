import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> showAppDetailDialog(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  showAboutDialog(
      context: context,
      applicationIcon:
          Image.asset('assets/solimage.png', width: 64, height: 64),
      applicationName: packageInfo.appName,
      applicationVersion: packageInfo.version,
      applicationLegalese: '@ホームな職場です');
}
