import 'package:flutter/material.dart';

import '../../models/game_record.dart';
import 'game_session.dart';

/// 게임 하나의 계약. 게임 추가 = 이 정의 + 플레이 위젯 + 레지스트리 1줄.
class GameDefinition {
  const GameDefinition({
    required this.id,
    required this.title,
    required this.howTo,
    required this.icon,
    required this.accent,
    required this.buildPreview,
    required this.order,
    required this.formatScore,
    required this.shareBody,
    required this.buildPlay,
  });

  /// 영구 저장 키 — 출시 후 절대 변경 금지.
  final String id;
  final String title;

  /// 인트로 화면에 보여줄 게임 방법 설명.
  final String howTo;
  final IconData icon;
  final Color accent;

  /// 홈 카드에 보여줄 미니 게임 장면 (실제 게임 화면 축소 재현).
  final Widget Function() buildPreview;
  final ScoreOrder order;

  /// 점수 표시 형식. 예: 234 → '234ms'
  final String Function(num score) formatScore;

  /// 공유 메시지용 자랑 문구 한 줄.
  final String Function(num score) shareBody;

  /// 플레이 위젯 생성. 게임이 끝나면 session.finish(score)를 호출한다.
  final Widget Function(GameSession session) buildPlay;
}
