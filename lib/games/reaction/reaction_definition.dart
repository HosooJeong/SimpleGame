import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'reaction_play.dart';

final reactionGame = GameDefinition(
  id: 'reaction',
  title: '반응속도',
  howTo: '빨간 화면이 초록색으로 바뀌는 순간\n최대한 빨리 터치하세요.\n5회 평균으로 기록됩니다.\n초록색 전에 터치하면 그 라운드는 다시!',
  icon: Icons.bolt,
  accent: GameColors.red,
  buildPreview: () => const ReactionPreview(),
  order: ScoreOrder.lowerIsBetter,
  formatScore: (s) => '${s}ms',
  shareBody: (s) => '반응속도 평균 ${s}ms 찍었다.\n나보다 빠르면 인정.',
  buildPlay: (session) => ReactionPlay(session: session),
);
