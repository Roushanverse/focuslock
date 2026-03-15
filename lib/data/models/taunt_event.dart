import 'package:hive/hive.dart';

/// Records each time a taunt was shown to the user.
class TauntEvent {
  final String id;
  final String memeCaption;
  final DateTime timestamp;
  final String packageName; // The app user tried to open

  TauntEvent({
    required this.id,
    required this.memeCaption,
    required this.timestamp,
    required this.packageName,
  });
}

/// Hive TypeAdapter for TauntEvent.
class TauntEventAdapter extends TypeAdapter<TauntEvent> {
  @override
  final int typeId = 4;

  @override
  TauntEvent read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return TauntEvent(
      id: fields[0] as String,
      memeCaption: fields[1] as String,
      timestamp: fields[2] as DateTime,
      packageName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TauntEvent obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memeCaption)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.packageName);
  }
}
