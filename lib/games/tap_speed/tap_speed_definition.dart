import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'tap_speed_play.dart';

final tapSpeedGame = GameDefinition(
  id: 'tap_speed',
  title: (l) => l.tapSpeedTitle,
  howTo: (l) => l.tapSpeedHowTo,
  icon: Icons.touch_app,
  accent: GameColors.yellow,
  buildPreview: () => const TapSpeedPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (l, s) => l.tapSpeedScore('$s'),
  shareBody: (l, s) => l.tapSpeedShare('$s'),
  buildPlay: (session) => TapSpeedPlay(session: session),
);
