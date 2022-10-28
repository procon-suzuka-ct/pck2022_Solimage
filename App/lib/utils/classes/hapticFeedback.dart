import 'dart:math';
import 'package:vibration/vibration.dart';

class HapticFeedback {
  static Future<void> _vibrate(
      {List<int> pattern = const [],
      int duration = 500,
      int repeat = 1,
      List<int> intensities = const [],
      int amplitude = -1,
      int delayTime = 0}) async {
    for (var i = 0; i < repeat; i++) {
      await Vibration.vibrate(
          duration: duration,
          pattern: pattern,
          intensities: intensities,
          amplitude: min(amplitude, 255));
      await Future.delayed(Duration(milliseconds: delayTime));
    }
  }

  /// This is a method of create custom vibration pattern
  ///
  /// [pattern] is a list of vibration duration in milliseconds
  ///
  /// [intensities] is a list of vibration intensities in percentage
  ///
  /// [repeat] is a number of repeat vibration
  ///
  /// [delayTime] is a delay time between vibration
  ///
  /// [amplitude] is a vibration intensity in percentage (range: 0 - 255)
  ///
  /// [duration] is a vibration duration in milliseconds
  ///
  /// Example:
  /// ```dart
  /// HapticFeedback.vibrate(
  ///   pattern: [100, 100, 100, 100, 100, 100, 100, 100, 100, 100],
  ///   intensities: [100, 100, 100, 100, 100, 100, 100, 100, 100, 100],
  ///   repeat: 1,
  ///   delayTime: 0,
  ///   amplitude: 100,
  ///   duration: 1000);
  /// ```
  static Future<void> customVibrate(
          {List<int> pattern = const [],
          int duration = 500,
          int repeat = 1,
          List<int> intensities = const [],
          int amplitude = -1,
          int delayTime = 0}) async =>
      await _vibrate(
          pattern: pattern,
          duration: duration,
          repeat: repeat,
          intensities: intensities,
          amplitude: amplitude,
          delayTime: delayTime);

  static Future<void> lightImpact() async {
    await _vibrate(amplitude: 63, duration: 1);
  }

  static Future<void> mediumImpact() async {
    await _vibrate(amplitude: 127, duration: 2, delayTime: 10);
  }

  static Future<void> heavyImpact() async {
    await _vibrate(amplitude: 255, duration: 1, repeat: 3, delayTime: 10);
  }

  static Future<void> positiveImpact() async {
    await _vibrate(intensities: [31, 63, 127, 255], duration: 10);
  }

  static Future<void> negativeImpact() async {
    await _vibrate(intensities: [255, 127, 63, 31], duration: 10);
  }
}
