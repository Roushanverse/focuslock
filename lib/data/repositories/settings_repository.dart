import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/taunt_event.dart';

/// Repository for app settings and taunt event history.
class SettingsRepository {
  static const String _settingsBoxName = 'settings';
  static const String _tauntsBoxName = 'taunt_events';

  // Settings keys
  static const String _blockedAppsKey = 'blocked_apps';
  static const String _serviceEnabledKey = 'service_enabled';
  static const String _blockingActiveKey = 'blocking_active';

  Box? _settingsBox;
  Box<TauntEvent>? _tauntsBox;

  Future<Box> get settingsBox async {
    _settingsBox ??= await Hive.openBox(_settingsBoxName);
    return _settingsBox!;
  }

  Future<Box<TauntEvent>> get tauntsBox async {
    _tauntsBox ??= await Hive.openBox<TauntEvent>(_tauntsBoxName);
    return _tauntsBox!;
  }

  // --- Blocked Apps ---

  /// Default list of blocked app package names.
  static const List<String> defaultBlockedApps = [
    'com.instagram.android',
    'com.google.android.youtube',
    'com.whatsapp',
    'com.facebook.katana',
    'com.twitter.android',
    'com.zhiliaoapp.musically', // TikTok
    'com.snapchat.android',
    'com.reddit.frontpage',
  ];

  /// Get the list of blocked app package names.
  Future<List<String>> getBlockedApps() async {
    final box = await settingsBox;
    final apps = box.get(_blockedAppsKey);
    if (apps == null) {
      // Initialize with defaults
      await setBlockedApps(defaultBlockedApps);
      return defaultBlockedApps;
    }
    return List<String>.from(apps as List);
  }

  /// Set the list of blocked app package names.
  Future<void> setBlockedApps(List<String> apps) async {
    final box = await settingsBox;
    await box.put(_blockedAppsKey, apps);
  }

  /// Add a package to the blocked list.
  Future<void> addBlockedApp(String packageName) async {
    final apps = await getBlockedApps();
    if (!apps.contains(packageName)) {
      apps.add(packageName);
      await setBlockedApps(apps);
    }
  }

  /// Remove a package from the blocked list.
  Future<void> removeBlockedApp(String packageName) async {
    final apps = await getBlockedApps();
    apps.remove(packageName);
    await setBlockedApps(apps);
  }

  // --- Service Settings ---

  /// Get whether the service is enabled.
  Future<bool> isServiceEnabled() async {
    final box = await settingsBox;
    return box.get(_serviceEnabledKey, defaultValue: true) as bool;
  }

  /// Set whether the service is enabled.
  Future<void> setServiceEnabled(bool enabled) async {
    final box = await settingsBox;
    await box.put(_serviceEnabledKey, enabled);
  }

  /// Get whether blocking is currently active.
  Future<bool> isBlockingActive() async {
    final box = await settingsBox;
    return box.get(_blockingActiveKey, defaultValue: false) as bool;
  }

  /// Set whether blocking is currently active.
  Future<void> setBlockingActive(bool active) async {
    final box = await settingsBox;
    await box.put(_blockingActiveKey, active);
  }

  // --- Taunt Events ---

  /// Record a taunt event.
  Future<void> addTauntEvent(
      String memeCaption, String packageName) async {
    final box = await tauntsBox;
    final event = TauntEvent(
      id: const Uuid().v4(),
      memeCaption: memeCaption,
      timestamp: DateTime.now(),
      packageName: packageName,
    );
    await box.put(event.id, event);
  }

  /// Get recent taunt events (last N).
  Future<List<TauntEvent>> getRecentTaunts({int limit = 50}) async {
    final box = await tauntsBox;
    final events = box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events.take(limit).toList();
  }

  /// Get total taunt count.
  Future<int> getTotalTauntCount() async {
    final box = await tauntsBox;
    return box.length;
  }
}
