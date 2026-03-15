import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../data/models/goal.dart';
import '../data/repositories/goal_repository.dart';
import '../data/repositories/settings_repository.dart';

/// Task names for WorkManager.
const String checkGoalsTaskName = 'com.focuslock.checkGoals';
const String periodicCheckTaskName = 'com.focuslock.periodicCheck';

/// Top-level callback dispatcher for WorkManager.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(GoalStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(GoalAdapter());
      }

      final goalRepo = GoalRepository();
      final settingsRepo = SettingsRepository();

      switch (task) {
        case checkGoalsTaskName:
        case periodicCheckTaskName:
        case Workmanager.iOSBackgroundTask:
          await _checkAndUpdateGoals(goalRepo, settingsRepo);
          break;
      }
      return true;
    } catch (e) {
      return false;
    }
  });
}

Future<void> _checkAndUpdateGoals(
  GoalRepository goalRepo,
  SettingsRepository settingsRepo,
) async {
  final goals = await goalRepo.getAllGoals();
  bool hasActiveGoals = false;

  for (final goal in goals) {
    if (goal.status == GoalStatus.pending && goal.isInActiveWindow) {
      goal.status = GoalStatus.active;
      await goalRepo.updateGoal(goal);
      hasActiveGoals = true;
    } else if (goal.status == GoalStatus.active) {
      if (goal.isExpired) {
        goal.status = GoalStatus.missed;
        await goalRepo.updateGoal(goal);
      } else {
        hasActiveGoals = true;
      }
    } else if (goal.status == GoalStatus.pending && goal.isExpired) {
      goal.status = GoalStatus.missed;
      await goalRepo.updateGoal(goal);
    }
  }

  if (hasActiveGoals) {
    await settingsRepo.setBlockingActive(true);
  } else {
    await settingsRepo.setBlockingActive(false);
  }
}

class WorkManagerService {
  Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  Future<void> registerPeriodicCheck() async {
    await Workmanager().registerPeriodicTask(
      periodicCheckTaskName,
      periodicCheckTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.notRequired),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  Future<void> runImmediateCheck() async {
    await Workmanager().registerOneOffTask(
      '${checkGoalsTaskName}_${DateTime.now().millisecondsSinceEpoch}',
      checkGoalsTaskName,
    );
  }

  Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
