import 'package:flutter_test/flutter_test.dart';
import 'package:simple_game/core/share_service.dart';
import 'package:simple_game/games/game_registry.dart';

void main() {
  group('공유 링크', () {
    test('게임별 링크에 game 파라미터가 붙는다', () {
      expect(
        ShareService.gameUrl('circle_draw'),
        'https://hosoojeong.github.io/SimpleGame/?game=circle_draw',
      );
    });

    test('생성한 링크를 그대로 다시 파싱하면 같은 게임이 나온다', () {
      for (final game in allGames) {
        final uri = Uri.parse(ShareService.gameUrl(game.id));
        expect(gameFromUri(uri)?.id, game.id);
      }
    });

    test('파라미터가 없으면 null — 홈을 그대로 보여준다', () {
      expect(gameFromUri(Uri.parse(ShareService.shareUrl)), isNull);
    });

    test('모르는 id면 null', () {
      expect(
        gameFromUri(Uri.parse('${ShareService.shareUrl}?game=없는게임')),
        isNull,
      );
    });
  });
}
