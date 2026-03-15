import 'package:hive/hive.dart';

/// Represents a taunt meme used when the user tries to open blocked apps.
class Meme {
  final String id;
  final String imagePath; // Asset path, e.g., "assets/memes/meme_1.png"
  final String caption;
  int timesUsed;

  Meme({
    required this.id,
    required this.imagePath,
    required this.caption,
    this.timesUsed = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'caption': caption,
        'timesUsed': timesUsed,
      };

  factory Meme.fromJson(Map<String, dynamic> json) => Meme(
        id: json['id'] as String? ?? '',
        imagePath: json['image'] as String? ?? json['imagePath'] as String? ?? '',
        caption: json['caption'] as String? ?? '',
        timesUsed: json['timesUsed'] as int? ?? 0,
      );
}

/// Hive TypeAdapter for Meme.
class MemeAdapter extends TypeAdapter<Meme> {
  @override
  final int typeId = 2;

  @override
  Meme read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Meme(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      caption: fields[2] as String,
      timesUsed: fields[3] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Meme obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.caption)
      ..writeByte(3)
      ..write(obj.timesUsed);
  }
}
