import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'half_cut_play.dart';

final halfCutGame = GameDefinition(
  id: 'half_cut',
  title: '반반 자르기',
  howTo: '절단선을 드래그로 움직여서\n양쪽 넓이가 똑같아지는 지점에 놓으세요.\n손을 떼는 순간 확정! 총 5라운드, 새 도형!\n(라운드당 100점, 500점 만점)',
  icon: Icons.content_cut_rounded,
  accent: GameColors.lime,
  buildPreview: () => const HalfCutPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (s) => '$s점',
  shareBody: (s) => '반반 자르기 $s점 (500점 만점).\n네 눈대중은 몇 점짜리야?',
  buildPlay: (session) => HalfCutPlay(session: session),
);
