import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'fake_signal_play.dart';

final fakeSignalGame = GameDefinition(
  id: 'fake_signal',
  title: (l) => l.fakeSignalTitle,
  howTo: (l) => l.fakeSignalHowTo,
  icon: Icons.sensors_rounded,
  accent: GameColors.coral,
  buildPreview: () => const FakeSignalPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (l, s) => l.countItems('$s'),
  shareBody: (l, s) => l.fakeSignalShare('$s'),
  buildPlay: (session) => FakeSignalPlay(session: session),
);
