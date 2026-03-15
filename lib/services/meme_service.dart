import '../data/models/meme.dart';
import '../data/repositories/meme_repository.dart';

/// Service for retrieving memes for taunts.
class MemeService {
  final MemeRepository _repository;

  MemeService(this._repository);

  /// Initialize the meme database from assets on first run.
  Future<void> initialize() async {
    await _repository.initializeMemes();
  }

  /// Get a random meme, preferring less-used ones.
  Future<Meme> getRandomMeme() async {
    return _repository.getRandomMeme();
  }

  /// Get all memes.
  Future<List<Meme>> getAllMemes() async {
    return _repository.getAllMemes();
  }
}
