import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'tap_speed_play.dart';

final tapSpeedGame = GameDefinition(
  id: 'tap_speed',
  title: '탭 스피드',
  howTo: '첫 터치와 동시에 10초 타이머가 시작됩니다.\n10초 동안 화면을 최대한 많이 탭하세요!',
  icon: Icons.touch_app,
  accent: GameColors.yellow,
  buildPreview: () => const TapSpeedPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (s) => '$s회',
  shareBody: (s) => '10초 동안 $s번 탭했다.\n손가락 스피드로 이겨볼 사람?',
  buildPlay: (session) => TapSpeedPlay(session: session),
);
