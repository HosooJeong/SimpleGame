import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_record.dart';

class SaveOutcome {
  const SaveOutcome(this.record, this.isNewBest);

  final GameRecord record;
  final bool isNewBest;
}

class RecordsRepository {
  RecordsRepository(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String gameId) => 'rec.$gameId';

  GameRecord load(String gameId) =>
      GameRecord.fromJsonString(_prefs.getString(_key(gameId)));

  Future<SaveOutcome> addResult(
      String gameId, num score, ScoreOrder order) async {
    final before = load(gameId);
    final after = before.addResult(score, DateTime.now(), order);
    await _prefs.setString(_key(gameId), after.toJsonString());
    final isNewBest = before.best == null || after.best != before.best;
    return SaveOutcome(after, isNewBest);
  }

  Future<void> resetAll(Iterable<String> gameIds) async {
    for (final id in gameIds) {
      await _prefs.remove(_key(id));
    }
  }
}
