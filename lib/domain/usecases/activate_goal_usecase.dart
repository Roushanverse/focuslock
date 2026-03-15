import '../../data/models/goal.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/blocking_service.dart';
import '../../services/foreground_service.dart';
import '../../services/notification_service.dart';

/// Activates a goal: starts blocking and foreground service.
class ActivateGoalUseCase {
  final GoalRepository goalRepository;
  final SettingsRepository settingsRepository;
  final BlockingService blockingService;
  final ForegroundService foregroundService;
  final NotificationService notificationService;

  ActivateGoalUseCase({
    required this.goalRepository,
    required this.settingsRepository,
    required this.blockingService,
    required this.foregroundService,
    required this.notificationService,
  });

  /// Activate the given goal immediately.
  Future<void> execute(Goal goal) async {
    goal.status = GoalStatus.active;
    await goalRepository.updateGoal(goal);
    await goalRepository.startSession(goal.id);

    // Start blocking
    final blockedApps = await settingsRepository.getBlockedApps();
    await blockingService.startBlocking(blockedApps);
    await foregroundService.startService();
    await settingsRepository.setBlockingActive(true);

    await notificationService.showNotification(
      title: '🎯 Focus Session Started!',
      body: '"${goal.title}" is now active. Stay focused!',
      id: goal.id.hashCode,
    );
  }
}
