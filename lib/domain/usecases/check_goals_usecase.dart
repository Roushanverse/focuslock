import '../../data/models/goal.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/blocking_service.dart';
import '../../services/foreground_service.dart';
import '../../services/notification_service.dart';

/// Checks all goals and updates their status based on the current time.
/// Called periodically by WorkManager and on app startup.
class CheckGoalsUseCase {
  final GoalRepository goalRepository;
  final SettingsRepository settingsRepository;
  final BlockingService blockingService;
  final ForegroundService foregroundService;
  final NotificationService notificationService;

  CheckGoalsUseCase({
    required this.goalRepository,
    required this.settingsRepository,
    required this.blockingService,
    required this.foregroundService,
    required this.notificationService,
  });

  /// Run the check and update all goals.
  Future<void> execute() async {
    final goals = await goalRepository.getAllGoals();
    bool hasActiveGoals = false;

    for (final goal in goals) {
      if (goal.status == GoalStatus.pending) {
        if (goal.isInActiveWindow) {
          // Time to activate this goal
          await _activateGoal(goal);
          hasActiveGoals = true;
        } else if (goal.isExpired) {
          // Missed without even starting
          await _missGoal(goal);
        }
      } else if (goal.status == GoalStatus.active) {
        if (goal.isExpired) {
          // Active goal has expired – missed
          await _missGoal(goal);
        } else {
          hasActiveGoals = true;
        }
      }
    }

    // Update blocking based on whether any goals are active
    if (hasActiveGoals) {
      final blockedApps = await settingsRepository.getBlockedApps();
      await blockingService.startBlocking(blockedApps);
      await foregroundService.startService();
      await settingsRepository.setBlockingActive(true);
    } else {
      await blockingService.stopBlocking();
      await settingsRepository.setBlockingActive(false);
      // Don't stop foreground service here — let user control it
    }
  }

  Future<void> _activateGoal(Goal goal) async {
    goal.status = GoalStatus.active;
    await goalRepository.updateGoal(goal);
    await goalRepository.startSession(goal.id);

    await notificationService.showNotification(
      title: '🎯 Focus Session Started!',
      body: '"${goal.title}" is now active. Stay focused!',
      id: goal.id.hashCode,
    );
  }

  Future<void> _missGoal(Goal goal) async {
    goal.status = GoalStatus.missed;
    await goalRepository.updateGoal(goal);

    await notificationService.showTauntNotification(
      title: '😤 Goal Missed!',
      body: 'You missed "${goal.title}". Better luck next time!',
      id: goal.id.hashCode,
    );
  }
}
