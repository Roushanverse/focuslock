import '../../data/models/goal.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/blocking_service.dart';
import '../../services/foreground_service.dart';
import '../../services/meme_service.dart';
import '../../services/notification_service.dart';

/// Marks a goal as missed, sends a taunt, and stops blocking if no other active goals.
class MissGoalUseCase {
  final GoalRepository goalRepository;
  final SettingsRepository settingsRepository;
  final BlockingService blockingService;
  final ForegroundService foregroundService;
  final MemeService memeService;
  final NotificationService notificationService;

  MissGoalUseCase({
    required this.goalRepository,
    required this.settingsRepository,
    required this.blockingService,
    required this.foregroundService,
    required this.memeService,
    required this.notificationService,
  });

  /// Miss the given goal.
  Future<void> execute(Goal goal) async {
    goal.status = GoalStatus.missed;
    await goalRepository.updateGoal(goal);

    // End active session for this goal
    final sessions = await goalRepository.getSessionsForGoal(goal.id);
    for (final session in sessions) {
      if (session.endTime == null) {
        await goalRepository.endSession(session.id);
      }
    }

    // Send a taunt
    final meme = await memeService.getRandomMeme();
    await settingsRepository.addTauntEvent(
      meme.caption,
      'goal_missed',
    );

    await notificationService.showTauntNotification(
      title: '😤 You Failed!',
      body: meme.caption,
      id: goal.id.hashCode,
    );

    // Check if there are other active goals
    final activeGoals = await goalRepository.getActiveGoals();
    if (activeGoals.isEmpty) {
      await blockingService.stopBlocking();
      await foregroundService.stopService();
      await settingsRepository.setBlockingActive(false);
    }
  }
}
