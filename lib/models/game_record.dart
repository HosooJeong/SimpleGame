import 'dart:convert';

/// 점수 방향 — 반응속도(ms)는 낮을수록, 단계·횟수는 높을수록 좋다.
enum ScoreOrder { lowerIsBetter, higherIsBetter }

class ResultEntry {
  const ResultEntry(this.score, this.at);

  final num score;
  final DateTime at;
}

/// 게임 하나의 영속 기록. shared_preferences에 JSON 문자열로 저장된다.
/// 스키마: {"v":1,"best":234,"plays":57,"hist":[[점수,epochMillis],...]}
class GameRecord {
  const GameRecord({this.best, this.plays = 0, this.history = const []});

  final num? best;
  final int plays;

  /// 오래된 것 → 최신 순, 최대 [historyLimit]개.
  final List<ResultEntry> history;

  static const historyLimit = 50;

  factory GameRecord.fromJsonString(String? source) {
    if (source == null) return const GameRecord();
    try {
      final map = jsonDecode(source) as Map<String, dynamic>;
      final hist = <ResultEntry>[
        for (final e in (map['hist'] as List? ?? const []))
          ResultEntry(
            (e as List)[0] as num,
            DateTime.fromMillisecondsSinceEpoch(e[1] as int),
          ),
      ];
      return GameRecord(
        best: map['best'] as num?,
        plays: map['plays'] as int? ?? 0,
        history: hist,
      );
    } catch (_) {
      // 손상된 데이터는 빈 기록으로 복구.
      return const GameRecord();
    }
  }

  String toJsonString() => jsonEncode({
        'v': 1,
        'best': best,
        'plays': plays,
        'hist': [
          for (final e in history) [e.score, e.at.millisecondsSinceEpoch],
        ],
      });

  GameRecord addResult(num score, DateTime at, ScoreOrder order) {
    final newHistory = [...history, ResultEntry(score, at)];
    if (newHistory.length > historyLimit) {
      newHistory.removeRange(0, newHistory.length - historyLimit);
    }
    final isBetter = best == null ||
        (order == ScoreOrder.lowerIsBetter ? score < best! : score > best!);
    return GameRecord(
      best: isBetter ? score : best,
      plays: plays + 1,
      history: newHistory,
    );
  }
}
