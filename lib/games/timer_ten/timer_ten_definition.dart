import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'timer_ten_play.dart';

final timerTenGame = GameDefinition(
  id: 'timer_ten',
  title: (l) => l.timerTenTitle,
  howTo: (l) => l.timerTenHowTo,
  icon: Icons.timer,
  accent: GameColors.orange,
  buildPreview: () => const TimerTenPreview(),
  order: ScoreOrder.lowerIsBetter,
  formatScore: (l, s) => l.timerTenScore((s / 1000).toStringAsFixed(3)),
  shareBody: (l, s) => l.timerTenShare((s / 1000).toStringAsFixed(3)),
  buildPlay: (session) => TimerTenPlay(session: session),
);
