import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'flash_count_play.dart';

final flashCountGame = GameDefinition(
  id: 'flash_count',
  title: '순간 셈',
  howTo: '점들이 아주 잠깐 나타났다 사라집니다.\n몇 개였는지 맞히세요.\n단계가 오를수록 많아지고, 더 짧게 보여요!',
  icon: Icons.grain_rounded,
  accent: GameColors.emerald,
  buildPreview: () => const FlashCountPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (s) => '$s단계',
  shareBody: (s) => '순간 셈 $s단계 통과.\n반의 반 초 만에 몇 개까지 세겠어?',
  buildPlay: (session) => FlashCountPlay(session: session),
);
