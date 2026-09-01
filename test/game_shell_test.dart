import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_game/app/app_scope.dart';
import 'package:simple_game/core/feedback_service.dart';
import 'package:simple_game/core/records_repository.dart';
import 'package:simple_game/core/settings_controller.dart';
import 'package:simple_game/core/share_service.dart';
import 'package:simple_game/games/shell/game_definition.dart';
import 'package:simple_game/l10n/app_localizations.dart';
import 'package:simple_game/games/shell/game_shell_screen.dart';
import 'package:simple_game/models/game_record.dart';

/// 플레이 시작 즉시 고정 점수로 끝나는 가짜 게임 — 셸 전체 흐름 검증용.
class _InstantFinishPlay extends StatefulWidget {
  const _InstantFinishPlay({required this.onMount});

  final VoidCallback onMount;

  @override
  State<_InstantFinishPlay> createState() => _InstantFinishPlayState();
}

class _InstantFinishPlayState extends State<_InstantFinishPlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onMount());
  }

  @override
  Widget build(BuildContext context) => const Center(child: Text('playing'));
}

void main() {
  late RecordsRepository records;

  final fakeGame = GameDefinition(
    id: 'fake',
    title: (l) => '가짜 게임',
    howTo: (l) => '설명',
    icon: Icons.videogame_asset,
    accent: Colors.teal,
    buildPreview: () => const SizedBox.shrink(),
    order: ScoreOrder.higherIsBetter,
    formatScore: (l, s) => '$s점',
    shareBody: (l, s) => '$s점 달성',
    buildPlay: (session) =>
        _InstantFinishPlay(onMount: () => session.finish(42)),
  );

  Future<Widget> buildApp(GameDefinition definition) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsController(prefs)
      ..setSound(false)
      ..setHaptics(false);
    records = RecordsRepository(prefs);
    return AppScope(
      settings: settings,
      records: records,
      fx: FeedbackService(settings),
      share: const ShareService(),
      child: MaterialApp(
        // 셸 문구를 한국어로 고정해 검증한다. 언어 분기 자체는 widget_test 에서 본다.
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameShellScreen(definition: definition),
      ),
    );
  }

  /// 시작 버튼 이후 카운트다운(3-2-1-시작!)을 통과해 플레이 단계까지 진행.
  Future<void> passCountdown(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
  }

  testWidgets('셸 전체 흐름: 인트로 → 카운트다운 → 플레이 → 결과 + 기록 저장', (tester) async {
    await tester.pumpWidget(await buildApp(fakeGame));

    // 인트로: 제목·설명·시작 버튼·기록 없음
    expect(find.text('가짜 게임'), findsOneWidget);
    expect(find.text('설명'), findsOneWidget);
    expect(find.text('아직 아무도 도전하지 않았다'), findsOneWidget);

    // 시작 → 카운트다운 3-2-1-시작!
    await tester.tap(find.text('도전 시작'));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('2'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('1'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('시작!'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 450));

    // 플레이 위젯이 마운트되고 즉시 finish(42) 호출됨
    await tester.pumpAndSettle();

    // 결과 화면: 점수·신기록 배지·버튼들
    expect(find.text('42점'), findsOneWidget);
    expect(find.textContaining('신기록'), findsOneWidget);
    expect(find.text('자랑하기'), findsOneWidget);
    expect(find.text('한 번 더'), findsOneWidget);

    // 기록이 실제로 저장됐는지
    final saved = records.load('fake');
    expect(saved.best, 42);
    expect(saved.plays, 1);
  });

  testWidgets('다시하기 → 카운트다운부터 재시작, 동점은 신기록 아님', (tester) async {
    await tester.pumpWidget(await buildApp(fakeGame));

    await tester.tap(find.text('도전 시작'));
    await tester.pump();
    await passCountdown(tester);
    expect(find.text('42점'), findsOneWidget);

    await tester.tap(find.text('한 번 더'));
    await tester.pump();
    expect(find.text('3'), findsOneWidget); // 카운트다운 재시작
    await passCountdown(tester);

    expect(records.load('fake').plays, 2);
    expect(find.textContaining('신기록'), findsNothing);
    expect(find.textContaining('BEST'), findsOneWidget);
  });
}
