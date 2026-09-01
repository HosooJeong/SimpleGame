import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'fake_signal_play.dart';

final fakeSignalGame = GameDefinition(
  id: 'fake_signal',
  title: '가짜 신호',
  howTo: '초록 신호가 켜지면 흰 게이지가\n다 닳기 전에 터치!\n빨간 가짜 신호에는 절대 손대지 마세요.\n갈수록 빨라지고, 한 번 실수하면 끝!',
  icon: Icons.sensors_rounded,
  accent: GameColors.coral,
  buildPreview: () => const FakeSignalPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (s) => '$s개',
  shareBody: (s) => '가짜 신호 $s개 연속 통과.\n낚이지 않을 자신 있으면 와.',
  buildPlay: (session) => FakeSignalPlay(session: session),
);
