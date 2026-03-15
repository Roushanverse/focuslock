import 'package:flutter/services.dart';

/// Service to control the native foreground service.
class ForegroundService {
  static const _channel = MethodChannel('focuslock/service');

  /// Start the foreground service.
  Future<bool> startService() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('startForegroundService');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Stop the foreground service.
  Future<bool> stopService() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('stopForegroundService');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Check if the foreground service is currently running.
  Future<bool> isServiceRunning() async {
    try {
      final result = await _channel.invokeMethod<bool>('isServiceRunning');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }
}
