import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'number_grid_play.dart';

final numberGridGame = GameDefinition(
  id: 'number_grid',
  title: (l) => l.numberGridTitle,
  howTo: (l) => l.numberGridHowTo,
  icon: Icons.format_list_numbered,
  accent: GameColors.blue,
  buildPreview: () => const NumberGridPreview(accent: GameColors.blue),
  order: ScoreOrder.lowerIsBetter,
  formatScore: (l, s) => l.numberGridScore((s / 1000).toStringAsFixed(2)),
  shareBody: (l, s) => l.numberGridShare((s / 1000).toStringAsFixed(2)),
  buildPlay: (session) => NumberGridPlay(session: session),
);
