import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'chimp_play.dart';

final chimpGame = GameDefinition(
  id: 'chimp',
  title: (l) => l.chimpTitle,
  howTo: (l) => l.chimpHowTo,
  icon: Icons.apps_rounded,
  accent: GameColors.teal,
  buildPreview: () => const ChimpPreview(accent: GameColors.teal),
  order: ScoreOrder.higherIsBetter,
  formatScore: (l, s) => l.countItems('$s'),
  shareBody: (l, s) => l.chimpShare('$s'),
  buildPlay: (session) => ChimpPlay(session: session),
);
