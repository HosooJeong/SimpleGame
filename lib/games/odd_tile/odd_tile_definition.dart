import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'odd_tile_play.dart';

final oddTileGame = GameDefinition(
  id: 'odd_tile',
  title: (l) => l.oddTileTitle,
  howTo: (l) => l.oddTileHowTo,
  icon: Icons.remove_red_eye,
  accent: GameColors.pink,
  buildPreview: () => const OddTilePreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (l, s) => l.countLevel('$s'),
  shareBody: (l, s) => l.oddTileShare('$s'),
  buildPlay: (session) => OddTilePlay(session: session),
);
