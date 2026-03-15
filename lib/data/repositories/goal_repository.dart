import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/goal_session.dart';

/// Repository for managing focus goals in Hive.
class GoalRepository {
  static const String _boxName = 'goals';
  static const String _sessionsBoxName = 'goal_sessions';

  Box<Goal>? _goalsBox;
  Box<GoalSession>? _sessionsBox;

  Future<Box<Goal>> get goalsBox async {
    _goalsBox ??= await Hive.openBox<Goal>(_boxName);
    return _goalsBox!;
  }

  Future<Box<GoalSession>> get sessionsBox async {
    _sessionsBox ??= await Hive.openBox<GoalSession>(_sessionsBoxName);
    return _sessionsBox!;
  }

  /// Get all goals.
  Future<List<Goal>> getAllGoals() async {
    final box = await goalsBox;
    return box.values.toList();
  }

  /// Get goals by status.
  Future<List<Goal>> getGoalsByStatus(GoalStatus status) async {
    final goals = await getAllGoals();
    return goals.where((g) => g.status == status).toList();
  }

  /// Get active goals (currently in their focus window).
  Future<List<Goal>> getActiveGoals() async {
    return getGoalsByStatus(GoalStatus.active);
  }

  /// Get pending goals (scheduled but not yet started).
  Future<List<Goal>> getPendingGoals() async {
    return getGoalsByStatus(GoalStatus.pending);
  }

  /// Get a single goal by ID.
  Future<Goal?> getGoalById(String id) async {
    final box = await goalsBox;
    return box.get(id);
  }

  /// Add a new goal.
  Future<void> addGoal(Goal goal) async {
    final box = await goalsBox;
    await box.put(goal.id, goal);
  }

  /// Update an existing goal.
  Future<void> updateGoal(Goal goal) async {
    final box = await goalsBox;
    await box.put(goal.id, goal);
  }

  /// Delete a goal.
  Future<void> deleteGoal(String id) async {
    final box = await goalsBox;
    await box.delete(id);
  }

  /// Increment blocked attempts counter for a goal.
  Future<void> incrementBlockedAttempts(String goalId) async {
    final goal = await getGoalById(goalId);
    if (goal != null) {
      goal.blockedAttempts++;
      await updateGoal(goal);
    }
  }

  // --- GoalSession methods ---

  /// Start a new focus session.
  Future<GoalSession> startSession(String goalId) async {
    final box = await sessionsBox;
    final session = GoalSession(
      id: const Uuid().v4(),
      goalId: goalId,
      startTime: DateTime.now(),
    );
    await box.put(session.id, session);
    return session;
  }

  /// End a focus session.
  Future<void> endSession(String sessionId) async {
    final box = await sessionsBox;
    final session = box.get(sessionId);
    if (session != null) {
      final updated = session.copyWith(endTime: DateTime.now());
      await box.put(sessionId, updated);
    }
  }

  /// Get all sessions for a goal.
  Future<List<GoalSession>> getSessionsForGoal(String goalId) async {
    final box = await sessionsBox;
    return box.values.where((s) => s.goalId == goalId).toList();
  }

  /// Get all sessions (for statistics).
  Future<List<GoalSession>> getAllSessions() async {
    final box = await sessionsBox;
    return box.values.toList();
  }

  /// Get total focus hours for a specific date.
  Future<double> getFocusHoursForDate(DateTime date) async {
    final sessions = await getAllSessions();
    double totalMinutes = 0;
    for (final session in sessions) {
      if (session.endTime != null &&
          session.startTime.year == date.year &&
          session.startTime.month == date.month &&
          session.startTime.day == date.day) {
        totalMinutes += session.duration.inMinutes;
      }
    }
    return totalMinutes / 60.0;
  }

  /// Get focus hours for the last 7 days.
  Future<Map<DateTime, double>> getWeeklyFocusHours() async {
    final result = <DateTime, double>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      result[date] = await getFocusHoursForDate(date);
    }
    return result;
  }
}
