import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_game/app/app.dart';
import 'package:simple_game/app/app_scope.dart';
import 'package:simple_game/core/feedback_service.dart';
import 'package:simple_game/core/records_repository.dart';
import 'package:simple_game/core/settings_controller.dart';
import 'package:simple_game/core/share_service.dart';
import 'package:simple_game/games/game_registry.dart';

void main() {
  testWidgets('홈 화면에 게임 14개 타일이 모두 보인다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsController(prefs);

    await tester.pumpWidget(
      AppScope(
        settings: settings,
        records: RecordsRepository(prefs),
        fx: FeedbackService(settings),
        share: const ShareService(),
        child: const SnackGameApp(),
      ),
    );

    expect(allGames.length, 14);
    for (final game in allGames) {
      // 그리드가 스크롤 없이도 렌더링되도록 충분히 스크롤하며 확인.
      await tester.scrollUntilVisible(find.text(game.title), 100);
      expect(find.text(game.title), findsOneWidget);
    }
  });
}
