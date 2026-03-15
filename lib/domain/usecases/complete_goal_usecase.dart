import '../../data/models/goal.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/blocking_service.dart';
import '../../services/foreground_service.dart';
import '../../services/notification_service.dart';

/// Marks a goal as completed and stops blocking if no other active goals remain.
class CompleteGoalUseCase {
  final GoalRepository goalRepository;
  final SettingsRepository settingsRepository;
  final BlockingService blockingService;
  final ForegroundService foregroundService;
  final NotificationService notificationService;

  CompleteGoalUseCase({
    required this.goalRepository,
    required this.settingsRepository,
    required this.blockingService,
    required this.foregroundService,
    required this.notificationService,
  });

  /// Complete the given goal.
  Future<void> execute(Goal goal) async {
    goal.status = GoalStatus.completed;
    await goalRepository.updateGoal(goal);

    // End active session for this goal
    final sessions = await goalRepository.getSessionsForGoal(goal.id);
    for (final session in sessions) {
      if (session.endTime == null) {
        await goalRepository.endSession(session.id);
      }
    }

    // Check if there are other active goals
    final activeGoals = await goalRepository.getActiveGoals();
    if (activeGoals.isEmpty) {
      await blockingService.stopBlocking();
      await foregroundService.stopService();
      await settingsRepository.setBlockingActive(false);
    }

    await notificationService.showNotification(
      title: '🎉 Goal Completed!',
      body: 'Great job! You completed "${goal.title}"!',
      id: goal.id.hashCode,
    );
  }
}
