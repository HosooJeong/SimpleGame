import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'circle_draw_play.dart';

final circleDrawGame = GameDefinition(
  id: 'circle_draw',
  title: (l) => l.circleDrawTitle,
  howTo: (l) => l.circleDrawHowTo,
  icon: Icons.gesture_rounded,
  accent: GameColors.cyan,
  buildPreview: () => const CircleDrawPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (l, s) => '${s.toStringAsFixed(1)}%',
  shareBody: (l, s) => l.circleDrawShare(s.toStringAsFixed(1)),
  buildPlay: (session) => CircleDrawPlay(session: session),
);
