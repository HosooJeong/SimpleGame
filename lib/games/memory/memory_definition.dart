import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'memory_play.dart';

final memoryGame = GameDefinition(
  id: 'memory',
  title: '순서 기억',
  howTo: '상하좌우 버튼이 순서대로 반짝입니다.\n순서를 기억했다가 그대로 따라 누르세요.\n성공할 때마다 한 칸씩 길어집니다!',
  icon: Icons.psychology,
  accent: GameColors.green,
  buildPreview: () => const MemoryPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (s) => '$s단계',
  shareBody: (s) => '순서 기억 $s단계까지 성공.\n네 기억력은 몇 단계?',
  buildPlay: (session) => MemoryPlay(session: session),
);
