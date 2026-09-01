import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/game_record.dart';
import '../previews.dart';
import '../shell/game_definition.dart';
import 'stroop_play.dart';

final stroopGame = GameDefinition(
  id: 'stroop',
  title: '색깔 함정',
  howTo: '단어의 뜻과 글자 색이 일치하면 O,\n다르면 X를 누르세요.\n30초 동안 최대한 많이! (오답은 -1점)',
  icon: Icons.format_color_text_rounded,
  accent: GameColors.indigo,
  buildPreview: () => const StroopPreview(),
  order: ScoreOrder.higherIsBetter,
  formatScore: (s) => '$s점',
  shareBody: (s) => '색깔 함정 테스트 $s점.\n네 뇌는 안 속을 자신 있어?',
  buildPlay: (session) => StroopPlay(session: session),
);
