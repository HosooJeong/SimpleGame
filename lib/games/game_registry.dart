import 'chimp/chimp_definition.dart';
import 'circle_draw/circle_draw_definition.dart';
import 'fake_signal/fake_signal_definition.dart';
import 'flash_count/flash_count_definition.dart';
import 'half_cut/half_cut_definition.dart';
import 'memory/memory_definition.dart';
import 'number_grid/number_grid_definition.dart';
import 'odd_tile/odd_tile_definition.dart';
import 'reaction/reaction_definition.dart';
import 'shell/game_definition.dart';
import 'shuffle_track/shuffle_track_definition.dart';
import 'stroop/stroop_definition.dart';
import 'tap_speed/tap_speed_definition.dart';
import 'timer_ten/timer_ten_definition.dart';
import 'timing_bar/timing_bar_definition.dart';

/// 게임 추가 시 여기에 한 줄만 추가하면 홈 그리드·통계 화면에 자동 반영된다.
final allGames = <GameDefinition>[
  reactionGame,
  numberGridGame,
  tapSpeedGame,
  timingBarGame,
  memoryGame,
  timerTenGame,
  oddTileGame,
  stroopGame,
  chimpGame,
  halfCutGame,
  circleDrawGame,
  shuffleTrackGame,
  flashCountGame,
  fakeSignalGame,
];

/// 공유 링크(`?game=<id>`)로 들어온 경우 해당 게임을 돌려준다.
/// 파라미터가 없거나 모르는 id면 null — 호출부는 홈을 그대로 보여주면 된다.
GameDefinition? gameFromUri(Uri uri) {
  final id = uri.queryParameters['game'];
  if (id == null) return null;
  for (final game in allGames) {
    if (game.id == id) return game;
  }
  return null;
}
