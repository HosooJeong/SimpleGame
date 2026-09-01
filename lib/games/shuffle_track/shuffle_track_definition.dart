import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'shuffle_track_play.dart';

final shuffleTrackGame = GameDefinition(
  id: 'shuffle_track',
  title: '셔플 추적',
  howTo: '별이 든 타일을 눈으로 끝까지 쫓으세요.\n섞기가 끝나면 별이 있는 타일을 터치!\n단계가 오를수록 더 빠르게, 더 많이 섞여요.',
  icon: Icons.shuffle_rounded,
  accent: GameColors.magenta,
  buildPreview: () => const ShuffleTrackPreview(accent: GameColors.magenta),
  order: ScoreOrder.higherIsBetter,
  formatScore: (s) => '$s단계',
  shareBody: (s) => '셔플 추적 $s단계까지 쫓아냈다.\n눈 빠르면 따라와봐.',
  buildPlay: (session) => ShuffleTrackPlay(session: session),
);
