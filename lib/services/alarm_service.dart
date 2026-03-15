import 'package:flutter/services.dart';

/// Service to schedule and cancel native alarms.
class AlarmService {
  static const _channel = MethodChannel('focuslock/alarm');

  /// Schedule an alarm at the given time.
  Future<bool> scheduleAlarm(
    DateTime triggerTime, {
    int requestCode = 0,
    String memePath = '',
    String caption = 'Get back to work!',
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('scheduleAlarm', {
        'triggerTime': triggerTime.millisecondsSinceEpoch,
        'memePath': memePath,
        'caption': caption,
        'requestCode': requestCode,
      });
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Cancel a previously scheduled alarm.
  Future<bool> cancelAlarm(int requestCode) async {
    try {
      final result = await _channel.invokeMethod<bool>('cancelAlarm', {
        'requestCode': requestCode,
      });
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }
}
