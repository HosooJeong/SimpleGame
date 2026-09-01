import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'circle_draw_play.dart';

final circleDrawGame = GameDefinition(
  id: 'circle_draw',
  title: '완벽한 원',
  howTo: '한 획으로 최대한 완벽한 원을 그리세요.\n손을 떼는 순간 원형도를 채점합니다.\n너무 작거나 덜 이어진 원은 무효!',
  icon: Icons.gesture_rounded,
  accent: GameColors.cyan,
  buildPreview: () => const CircleDrawPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (s) => '${s.toStringAsFixed(1)}%',
  shareBody: (s) =>
      '손으로 원형도 ${s.toStringAsFixed(1)}% 원을 그렸다.\n한 획에 이만큼 그릴 수 있어?',
  buildPlay: (session) => CircleDrawPlay(session: session),
);
