import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'timing_bar_play.dart';

final timingBarGame = GameDefinition(
  id: 'timing_bar',
  title: '타이밍 스톱',
  howTo: '좌우로 움직이는 원이 정중앙에 왔을 때\n화면을 터치해 멈추세요.\n총 5라운드, 라운드마다 빨라집니다!\n(라운드당 100점, 500점 만점)',
  icon: Icons.filter_center_focus,
  accent: GameColors.purple,
  buildPreview: () => const TimingBarPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (s) => '$s점',
  shareBody: (s) => '타이밍 스톱 $s점 (500점 만점).\n타이밍 감각 자신 있으면 도전.',
  buildPlay: (session) => TimingBarPlay(session: session),
);
