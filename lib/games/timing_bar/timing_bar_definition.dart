import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'timing_bar_play.dart';

final timingBarGame = GameDefinition(
  id: 'timing_bar',
  title: (l) => l.timingBarTitle,
  howTo: (l) => l.timingBarHowTo,
  icon: Icons.filter_center_focus,
  accent: GameColors.purple,
  buildPreview: () => const TimingBarPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (l, s) => l.countPoints('$s'),
  shareBody: (l, s) => l.timingBarShare('$s'),
  buildPlay: (session) => TimingBarPlay(session: session),
);
