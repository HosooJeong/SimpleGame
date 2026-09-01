import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'chimp_play.dart';

final chimpGame = GameDefinition(
  id: 'chimp',
  title: '순간 기억',
  howTo: '숫자들의 위치를 기억하세요.\n1을 누르는 순간 나머지가 가려집니다.\n순서대로 끝까지 누르면 숫자가 하나 늘어요.\n(침팬지는 평균 9개까지 외운다고 합니다)',
  icon: Icons.apps_rounded,
  accent: GameColors.teal,
  buildPreview: () => const ChimpPreview(accent: GameColors.teal),
  order: ScoreOrder.higherIsBetter,
  formatScore: (s) => '$s개',
  shareBody: (s) => '순간 기억력 $s개.\n침팬지는 평균 9개 외운다는데, 너는?',
  buildPlay: (session) => ChimpPlay(session: session),
);
