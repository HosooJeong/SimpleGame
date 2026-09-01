import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_game/app/app.dart';
import 'package:simple_game/app/app_scope.dart';
import 'package:simple_game/core/feedback_service.dart';
import 'package:simple_game/core/records_repository.dart';
import 'package:simple_game/core/settings_controller.dart';
import 'package:simple_game/core/share_service.dart';
import 'package:simple_game/games/game_registry.dart';
import 'package:simple_game/l10n/app_localizations.dart';

void main() {
  /// 시스템 언어를 지정해 앱을 띄운다.
  Future<void> pumpApp(WidgetTester tester, List<Locale> systemLocales) async {
    tester.platformDispatcher.localesTestValue = systemLocales;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

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
  }

  /// 홈 그리드를 스크롤하며 14개 게임 제목이 해당 언어로 모두 보이는지 확인.
  Future<void> expectAllTitles(WidgetTester tester, Locale locale) async {
    final l = await AppLocalizations.delegate.load(locale);
    expect(allGames.length, 14);
    for (final game in allGames) {
      await tester.scrollUntilVisible(find.text(game.title(l)), 100);
      expect(find.text(game.title(l)), findsOneWidget);
    }
  }

  testWidgets('시스템 언어가 한국어면 한국어로 표시된다', (tester) async {
    await pumpApp(tester, const [Locale('ko')]);

    expect(find.text('네 한계를 증명해봐'), findsOneWidget);
    await expectAllTitles(tester, const Locale('ko'));
  });

  testWidgets('시스템 언어가 한국어가 아니면 영어로 표시된다', (tester) async {
    await pumpApp(tester, const [Locale('ja'), Locale('fr')]);

    expect(find.text('Prove your limits'), findsOneWidget);
    await expectAllTitles(tester, const Locale('en'));
  });

  testWidgets('한국어가 뒤에 있어도 한국어를 고른다', (tester) async {
    await pumpApp(tester, const [Locale('de'), Locale('ko')]);

    expect(find.text('네 한계를 증명해봐'), findsOneWidget);
  });
}
