import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'half_cut_play.dart';

final halfCutGame = GameDefinition(
  id: 'half_cut',
  title: (l) => l.halfCutTitle,
  howTo: (l) => l.halfCutHowTo,
  icon: Icons.content_cut_rounded,
  accent: GameColors.lime,
  buildPreview: () => const HalfCutPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (l, s) => l.countPoints('$s'),
  shareBody: (l, s) => l.halfCutShare('$s'),
  buildPlay: (session) => HalfCutPlay(session: session),
);
