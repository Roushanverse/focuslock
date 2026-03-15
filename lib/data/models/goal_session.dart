import 'package:hive/hive.dart';

/// Tracks a single focus session for statistics.
class GoalSession {
  final String id;
  final String goalId;
  final DateTime startTime;
  final DateTime? endTime;
  final int blockedAttempts;

  GoalSession({
    required this.id,
    required this.goalId,
    required this.startTime,
    this.endTime,
    this.blockedAttempts = 0,
  });

  /// Duration of the session.
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  GoalSession copyWith({
    String? id,
    String? goalId,
    DateTime? startTime,
    DateTime? endTime,
    int? blockedAttempts,
  }) {
    return GoalSession(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      blockedAttempts: blockedAttempts ?? this.blockedAttempts,
    );
  }
}

/// Hive TypeAdapter for GoalSession.
class GoalSessionAdapter extends TypeAdapter<GoalSession> {
  @override
  final int typeId = 3;

  @override
  GoalSession read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return GoalSession(
      id: fields[0] as String,
      goalId: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      blockedAttempts: fields[4] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, GoalSession obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.goalId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.blockedAttempts);
  }
}
