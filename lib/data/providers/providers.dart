import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import '../models/taunt_event.dart';
import '../repositories/goal_repository.dart';
import '../repositories/meme_repository.dart';
import '../repositories/settings_repository.dart';
import '../../services/blocking_service.dart';
import '../../services/foreground_service.dart';
import '../../services/alarm_service.dart';
import '../../services/meme_service.dart';
import '../../services/notification_service.dart';
import '../../services/workmanager_service.dart';
import '../../domain/usecases/check_goals_usecase.dart';
import '../../domain/usecases/activate_goal_usecase.dart';
import '../../domain/usecases/complete_goal_usecase.dart';
import '../../domain/usecases/miss_goal_usecase.dart';

// ─── Repositories ────────────────────────────────────────────────────

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository();
});

final memeRepositoryProvider = Provider<MemeRepository>((ref) {
  return MemeRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

// ─── Services ────────────────────────────────────────────────────────

final blockingServiceProvider = Provider<BlockingService>((ref) {
  return BlockingService();
});

final foregroundServiceProvider = Provider<ForegroundService>((ref) {
  return ForegroundService();
});

final alarmServiceProvider = Provider<AlarmService>((ref) {
  return AlarmService();
});

final memeServiceProvider = Provider<MemeService>((ref) {
  return MemeService(ref.read(memeRepositoryProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final workManagerServiceProvider = Provider<WorkManagerService>((ref) {
  return WorkManagerService();
});

// ─── Use Cases ───────────────────────────────────────────────────────

final checkGoalsUseCaseProvider = Provider<CheckGoalsUseCase>((ref) {
  return CheckGoalsUseCase(
    goalRepository: ref.read(goalRepositoryProvider),
    settingsRepository: ref.read(settingsRepositoryProvider),
    blockingService: ref.read(blockingServiceProvider),
    foregroundService: ref.read(foregroundServiceProvider),
    notificationService: ref.read(notificationServiceProvider),
  );
});

final activateGoalUseCaseProvider = Provider<ActivateGoalUseCase>((ref) {
  return ActivateGoalUseCase(
    goalRepository: ref.read(goalRepositoryProvider),
    settingsRepository: ref.read(settingsRepositoryProvider),
    blockingService: ref.read(blockingServiceProvider),
    foregroundService: ref.read(foregroundServiceProvider),
    notificationService: ref.read(notificationServiceProvider),
  );
});

final completeGoalUseCaseProvider = Provider<CompleteGoalUseCase>((ref) {
  return CompleteGoalUseCase(
    goalRepository: ref.read(goalRepositoryProvider),
    settingsRepository: ref.read(settingsRepositoryProvider),
    blockingService: ref.read(blockingServiceProvider),
    foregroundService: ref.read(foregroundServiceProvider),
    notificationService: ref.read(notificationServiceProvider),
  );
});

final missGoalUseCaseProvider = Provider<MissGoalUseCase>((ref) {
  return MissGoalUseCase(
    goalRepository: ref.read(goalRepositoryProvider),
    settingsRepository: ref.read(settingsRepositoryProvider),
    blockingService: ref.read(blockingServiceProvider),
    foregroundService: ref.read(foregroundServiceProvider),
    memeService: ref.read(memeServiceProvider),
    notificationService: ref.read(notificationServiceProvider),
  );
});

// ─── State Providers ─────────────────────────────────────────────────

/// All goals (refreshable).
final goalListProvider = FutureProvider<List<Goal>>((ref) async {
  final repo = ref.read(goalRepositoryProvider);
  return repo.getAllGoals();
});

/// Only active goals.
final activeGoalsProvider = FutureProvider<List<Goal>>((ref) async {
  final repo = ref.read(goalRepositoryProvider);
  return repo.getActiveGoals();
});

/// Only pending goals.
final pendingGoalsProvider = FutureProvider<List<Goal>>((ref) async {
  final repo = ref.read(goalRepositoryProvider);
  return repo.getPendingGoals();
});

/// Blocked apps list.
final blockedAppsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  return repo.getBlockedApps();
});

/// Whether blocking is currently active.
final blockingActiveProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  return repo.isBlockingActive();
});

/// Weekly focus hours for statistics.
final weeklyFocusHoursProvider =
    FutureProvider<Map<DateTime, double>>((ref) async {
  final repo = ref.read(goalRepositoryProvider);
  return repo.getWeeklyFocusHours();
});

/// Whether accessibility service is enabled.
final accessibilityEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(blockingServiceProvider);
  return service.isAccessibilityServiceEnabled();
});

/// Whether the blocking service is enabled in settings.
final serviceEnabledProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  return repo.isServiceEnabled();
});

/// Recent taunt events for statistics.
final recentTauntsProvider = FutureProvider<List<TauntEvent>>((ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  return repo.getRecentTaunts();
});
