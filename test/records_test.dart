import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_game/core/records_repository.dart';
import 'package:simple_game/models/game_record.dart';

void main() {
  group('GameRecord', () {
    test('빈 기록에서 JSON 왕복', () {
      final record = const GameRecord()
          .addResult(234, DateTime.fromMillisecondsSinceEpoch(1000),
              ScoreOrder.lowerIsBetter)
          .addResult(210, DateTime.fromMillisecondsSinceEpoch(2000),
              ScoreOrder.lowerIsBetter);

      final restored = GameRecord.fromJsonString(record.toJsonString());

      expect(restored.best, 210);
      expect(restored.plays, 2);
      expect(restored.history.length, 2);
      expect(restored.history[0].score, 234);
      expect(restored.history[1].at.millisecondsSinceEpoch, 2000);
    });

    test('null·손상된 JSON은 빈 기록으로 복구', () {
      expect(GameRecord.fromJsonString(null).plays, 0);
      expect(GameRecord.fromJsonString('not json!').plays, 0);
      expect(GameRecord.fromJsonString('{"v":1,"hist":"bad"}').plays, 0);
    });

    test('lowerIsBetter: 낮은 점수만 best 갱신', () {
      var record = const GameRecord();
      record = record.addResult(300, DateTime.now(), ScoreOrder.lowerIsBetter);
      expect(record.best, 300);
      record = record.addResult(250, DateTime.now(), ScoreOrder.lowerIsBetter);
      expect(record.best, 250);
      record = record.addResult(400, DateTime.now(), ScoreOrder.lowerIsBetter);
      expect(record.best, 250);
    });

    test('higherIsBetter: 높은 점수만 best 갱신', () {
      var record = const GameRecord();
      record = record.addResult(5, DateTime.now(), ScoreOrder.higherIsBetter);
      record = record.addResult(9, DateTime.now(), ScoreOrder.higherIsBetter);
      record = record.addResult(7, DateTime.now(), ScoreOrder.higherIsBetter);
      expect(record.best, 9);
      expect(record.plays, 3);
    });

    test('히스토리는 최근 50개만 유지', () {
      var record = const GameRecord();
      for (var i = 1; i <= 60; i++) {
        record =
            record.addResult(i, DateTime.now(), ScoreOrder.higherIsBetter);
      }
      expect(record.history.length, GameRecord.historyLimit);
      expect(record.history.first.score, 11); // 1~10은 잘려나감
      expect(record.history.last.score, 60);
      expect(record.plays, 60);
    });
  });

  group('RecordsRepository', () {
    late RecordsRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repo = RecordsRepository(await SharedPreferences.getInstance());
    });

    test('첫 기록은 항상 신기록', () async {
      final outcome =
          await repo.addResult('reaction', 250, ScoreOrder.lowerIsBetter);
      expect(outcome.isNewBest, isTrue);
      expect(outcome.record.best, 250);
    });

    test('더 나쁜 기록은 신기록 아님, 동점도 신기록 아님', () async {
      await repo.addResult('reaction', 250, ScoreOrder.lowerIsBetter);
      final worse =
          await repo.addResult('reaction', 300, ScoreOrder.lowerIsBetter);
      expect(worse.isNewBest, isFalse);
      final tie =
          await repo.addResult('reaction', 250, ScoreOrder.lowerIsBetter);
      expect(tie.isNewBest, isFalse);
      final better =
          await repo.addResult('reaction', 200, ScoreOrder.lowerIsBetter);
      expect(better.isNewBest, isTrue);
    });

    test('저장 후 다시 로드해도 유지', () async {
      await repo.addResult('memory', 7, ScoreOrder.higherIsBetter);
      final loaded = repo.load('memory');
      expect(loaded.best, 7);
      expect(loaded.plays, 1);
    });

    test('resetAll은 지정한 게임 기록을 삭제', () async {
      await repo.addResult('memory', 7, ScoreOrder.higherIsBetter);
      await repo.addResult('reaction', 250, ScoreOrder.lowerIsBetter);
      await repo.resetAll(['memory', 'reaction']);
      expect(repo.load('memory').plays, 0);
      expect(repo.load('reaction').plays, 0);
    });
  });
}
