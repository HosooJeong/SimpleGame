import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'memory_play.dart';

final memoryGame = GameDefinition(
  id: 'memory',
  title: (l) => l.memoryTitle,
  howTo: (l) => l.memoryHowTo,
  icon: Icons.psychology,
  accent: GameColors.green,
  buildPreview: () => const MemoryPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (l, s) => l.countLevel('$s'),
  shareBody: (l, s) => l.memoryShare('$s'),
  buildPlay: (session) => MemoryPlay(session: session),
);
