import 'package:hive/hive.dart';

/// Status of a focus goal.
enum GoalStatus {
  pending,  // Scheduled but not yet started
  active,   // Currently in focus session
  completed, // Successfully completed
  missed,   // Deadline passed without completion
}

/// Represents a focus goal / session.
class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final int durationMinutes; // Focus duration in minutes
  final bool isRecurring;
  GoalStatus status;
  final DateTime createdAt;
  int blockedAttempts; // Number of times user tried blocked apps

  Goal({
    required this.id,
    required this.title,
    this.description = '',
    required this.deadline,
    required this.durationMinutes,
    this.isRecurring = false,
    this.status = GoalStatus.pending,
    DateTime? createdAt,
    this.blockedAttempts = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  /// The time when blocking should start (deadline - duration).
  DateTime get startTime =>
      deadline.subtract(Duration(minutes: durationMinutes));

  /// Whether the goal is currently in its active time window.
  bool get isInActiveWindow {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(deadline);
  }

  /// Whether the deadline has passed.
  bool get isExpired => DateTime.now().isAfter(deadline);

  /// Remaining time until deadline, or Duration.zero if expired.
  Duration get remainingTime {
    final diff = deadline.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    int? durationMinutes,
    bool? isRecurring,
    GoalStatus? status,
    DateTime? createdAt,
    int? blockedAttempts,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isRecurring: isRecurring ?? this.isRecurring,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      blockedAttempts: blockedAttempts ?? this.blockedAttempts,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'durationMinutes': durationMinutes,
        'isRecurring': isRecurring,
        'status': status.index,
        'createdAt': createdAt.toIso8601String(),
        'blockedAttempts': blockedAttempts,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        deadline: DateTime.parse(json['deadline'] as String),
        durationMinutes: json['durationMinutes'] as int,
        isRecurring: json['isRecurring'] as bool? ?? false,
        status: GoalStatus.values[json['status'] as int],
        createdAt: DateTime.parse(json['createdAt'] as String),
        blockedAttempts: json['blockedAttempts'] as int? ?? 0,
      );
}

/// Hive TypeAdapter for GoalStatus enum.
class GoalStatusAdapter extends TypeAdapter<GoalStatus> {
  @override
  final int typeId = 0;

  @override
  GoalStatus read(BinaryReader reader) {
    return GoalStatus.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, GoalStatus obj) {
    writer.writeInt(obj.index);
  }
}

/// Hive TypeAdapter for Goal.
class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 1;

  @override
  Goal read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Goal(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String? ?? '',
      deadline: fields[3] as DateTime,
      durationMinutes: fields[4] as int,
      isRecurring: fields[5] as bool? ?? false,
      status: GoalStatus.values[fields[6] as int],
      createdAt: fields[7] as DateTime,
      blockedAttempts: fields[8] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(9) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.deadline)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.isRecurring)
      ..writeByte(6)
      ..write(obj.status.index)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.blockedAttempts);
  }
}
