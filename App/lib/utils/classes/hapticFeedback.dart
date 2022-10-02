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
          amplitude: amplitude < 255 ? amplitude : 255);
      await Future.delayed(Duration(milliseconds: delayTime));
    }
  }

  static Future<void> customVibrate(
          {List<int> pattern = const [],
          int duration = 500,
          int repeat = 1,
          List<int> intensities = const [],
          int amplitude = -1,
          int delayTime = 0}) async =>
      _vibrate(
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
}
