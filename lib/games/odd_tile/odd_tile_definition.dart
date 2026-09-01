import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'odd_tile_play.dart';

final oddTileGame = GameDefinition(
  id: 'odd_tile',
  title: '다른 색 찾기',
  howTo: '색이 미묘하게 다른 한 칸을 터치하세요.\n단계가 오를수록 어려워집니다.\n제한시간 30초, 틀리면 2초 감소!',
  icon: Icons.remove_red_eye,
  accent: GameColors.pink,
  buildPreview: () => const OddTilePreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (s) => '$s단계',
  shareBody: (s) => '다른 색 찾기 $s단계 클리어.\n눈썰미 좋으면 도전해봐.',
  buildPlay: (session) => OddTilePlay(session: session),
);
