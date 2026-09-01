import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'stroop_play.dart';

final stroopGame = GameDefinition(
  id: 'stroop',
  title: (l) => l.stroopTitle,
  howTo: (l) => l.stroopHowTo,
  icon: Icons.format_color_text_rounded,
  accent: GameColors.indigo,
  buildPreview: () => const StroopPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (l, s) => l.countPoints('$s'),
  shareBody: (l, s) => l.stroopShare('$s'),
  buildPlay: (session) => StroopPlay(session: session),
);
