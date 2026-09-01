import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'shuffle_track_play.dart';

final shuffleTrackGame = GameDefinition(
  id: 'shuffle_track',
  title: (l) => l.shuffleTrackTitle,
  howTo: (l) => l.shuffleTrackHowTo,
  icon: Icons.shuffle_rounded,
  accent: GameColors.magenta,
  buildPreview: () => const ShuffleTrackPreview(accent: GameColors.magenta),
  order: ScoreOrder.higherIsBetter,
  formatScore: (l, s) => l.countLevel('$s'),
  shareBody: (l, s) => l.shuffleTrackShare('$s'),
  buildPlay: (session) => ShuffleTrackPlay(session: session),
);
