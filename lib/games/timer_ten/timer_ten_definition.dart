import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'timer_ten_play.dart';

final timerTenGame = GameDefinition(
  id: 'timer_ten',
  title: '정확한 10초',
  howTo: '타이머가 3초까지만 보이고 그 뒤엔 가려집니다.\n감각만으로 정확히 10.00초가 되는 순간\n화면을 터치하세요!',
  icon: Icons.timer,
  accent: GameColors.orange,
  buildPreview: () => const TimerTenPreview(),
  order: ScoreOrder.lowerIsBetter,
  formatScore: (s) => '±${(s / 1000).toStringAsFixed(3)}초',
  shareBody: (s) =>
      '눈 감고 10초 맞추기, 오차 ±${(s / 1000).toStringAsFixed(3)}초.\n네 시간 감각도 테스트해봐.',
  buildPlay: (session) => TimerTenPlay(session: session),
);
