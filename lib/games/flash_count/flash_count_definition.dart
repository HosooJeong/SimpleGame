import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'flash_count_play.dart';

final flashCountGame = GameDefinition(
  id: 'flash_count',
  title: (l) => l.flashCountTitle,
  howTo: (l) => l.flashCountHowTo,
  icon: Icons.grain_rounded,
  accent: GameColors.emerald,
  buildPreview: () => const FlashCountPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (l, s) => l.countLevel('$s'),
  shareBody: (l, s) => l.flashCountShare('$s'),
  buildPlay: (session) => FlashCountPlay(session: session),
);
