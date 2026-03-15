import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/meme.dart';

/// Repository for managing taunt memes.
class MemeRepository {
  static const String _boxName = 'memes';

  Box<Meme>? _memesBox;

  Future<Box<Meme>> get memesBox async {
    _memesBox ??= await Hive.openBox<Meme>(_boxName);
    return _memesBox!;
  }

  /// Load memes from the bundled JSON asset into Hive (only on first run).
  Future<void> initializeMemes() async {
    final box = await memesBox;
    if (box.isNotEmpty) return; // Already initialized

    try {
      final jsonString =
          await rootBundle.loadString('assets/memes/memes.json');
      final List<dynamic> memeList = json.decode(jsonString) as List<dynamic>;

      for (int i = 0; i < memeList.length; i++) {
        final data = memeList[i] as Map<String, dynamic>;
        final meme = Meme(
          id: const Uuid().v4(),
          imagePath: 'assets/memes/${data['image']}',
          caption: data['caption'] as String? ?? '',
          timesUsed: 0,
        );
        await box.put(meme.id, meme);
      }
    } catch (e) {
      // If asset loading fails, create some default memes
      final defaults = [
        Meme(
          id: const Uuid().v4(),
          imagePath: '',
          caption: 'Stay focused! You can do this!',
        ),
        Meme(
          id: const Uuid().v4(),
          imagePath: '',
          caption: 'Put the phone down and get back to work!',
        ),
        Meme(
          id: const Uuid().v4(),
          imagePath: '',
          caption: "Your future self will thank you for staying disciplined!",
        ),
      ];
      for (final meme in defaults) {
        await box.put(meme.id, meme);
      }
    }
  }

  /// Get all memes.
  Future<List<Meme>> getAllMemes() async {
    final box = await memesBox;
    return box.values.toList();
  }

  /// Get a random meme, weighted to prefer less-used ones.
  Future<Meme> getRandomMeme() async {
    final memes = await getAllMemes();
    if (memes.isEmpty) {
      return Meme(
        id: 'default',
        imagePath: '',
        caption: 'Focus! Stop procrastinating!',
      );
    }

    // Sort by usage count (least used first)
    memes.sort((a, b) => a.timesUsed.compareTo(b.timesUsed));

    // Pick from the bottom third (least used)
    final poolSize = max(1, (memes.length / 3).ceil());
    final pool = memes.sublist(0, poolSize);
    final selected = pool[Random().nextInt(pool.length)];

    // Increment usage
    selected.timesUsed++;
    final box = await memesBox;
    await box.put(selected.id, selected);

    return selected;
  }
}
