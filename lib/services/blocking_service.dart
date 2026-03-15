import 'dart:async';
import 'package:flutter/services.dart';

/// Service to control app blocking via native AccessibilityService.
class BlockingService {
  static const _channel = MethodChannel('focuslock/blocking');
  static const _eventChannel = EventChannel('focuslock/blocked_events');

  StreamSubscription? _eventSubscription;
  final StreamController<Map<String, dynamic>> _blockedEventController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of blocked app events from native side.
  Stream<Map<String, dynamic>> get blockedEvents =>
      _blockedEventController.stream;

  /// Start blocking the given list of package names.
  Future<bool> startBlocking(List<String> packages) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'startBlocking',
        {'packages': packages},
      );
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Stop blocking all apps.
  Future<bool> stopBlocking() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopBlocking');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Check if blocking is currently active.
  Future<bool> isBlockingActive() async {
    try {
      final result = await _channel.invokeMethod<bool>('isBlockingActive');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Check if the accessibility service is enabled.
  Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('isAccessibilityServiceEnabled');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Open the accessibility settings page.
  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (_) {
      // Ignore
    }
  }

  /// Start listening for blocked app events from native side.
  void startListening() {
    _eventSubscription ??= _eventChannel
        .receiveBroadcastStream()
        .listen((event) {
      if (event is Map) {
        _blockedEventController.add(Map<String, dynamic>.from(event));
      }
    }, onError: (error) {
      // Stream error - ignore and continue
    });
  }

  /// Stop listening for events.
  void stopListening() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  /// Dispose resources.
  void dispose() {
    stopListening();
    _blockedEventController.close();
  }
}
