import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'reaction_play.dart';

final reactionGame = GameDefinition(
  id: 'reaction',
  title: (l) => l.reactionTitle,
  howTo: (l) => l.reactionHowTo,
  icon: Icons.bolt,
  accent: GameColors.red,
  buildPreview: () => const ReactionPreview(),
  order: ScoreOrder.lowerIsBetter,
  formatScore: (l, s) => '${s}ms',
  shareBody: (l, s) => l.reactionShare('$s'),
  buildPlay: (session) => ReactionPlay(session: session),
);
