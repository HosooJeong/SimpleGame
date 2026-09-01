import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'number_grid_play.dart';

final numberGridGame = GameDefinition(
  id: 'number_grid',
  title: '숫자 순서',
  howTo: '흩어져 있는 1부터 25까지의 숫자를\n순서대로 최대한 빨리 터치하세요!',
  icon: Icons.format_list_numbered,
  accent: GameColors.blue,
  buildPreview: () => const NumberGridPreview(accent: GameColors.blue),
  order: ScoreOrder.lowerIsBetter,
  formatScore: (s) => '${(s / 1000).toStringAsFixed(2)}초',
  shareBody: (s) =>
      '1부터 25까지 ${(s / 1000).toStringAsFixed(2)}초 만에 클리어.\n더 빨리 할 수 있겠어?',
  buildPlay: (session) => NumberGridPlay(session: session),
);
