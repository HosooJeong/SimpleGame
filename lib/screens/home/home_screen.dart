import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/chunky_button.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../games/game_registry.dart';
import '../../games/shell/game_definition.dart';
import '../../games/shell/game_shell_screen.dart';
import '../settings/settings_screen.dart';
import '../stats/stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _open(Widget screen) async {
    await Navigator.push(
        context, MaterialPageRoute<void>(builder: (_) => screen));
    // 게임/설정에서 돌아오면 최고기록 표시 갱신.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final records = AppScope.of(context).records;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Stack(
        children: [
          // 배경 장식 도형 — 단색 배경의 밋밋함을 깨는 요소.
          const Positioned(top: -60, right: -50, child: _BgBlob(190)),
          const Positioned(top: 300, left: -70, child: _BgBlob(160)),
          const Positioned(bottom: -50, right: -30, child: _BgBlob(150)),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              Strings.appName,
                              style: TextStyle(
                                fontFamily: 'BlackHanSans',
                                fontSize: 34,
                                color: AppColors.accent,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              Strings.homeTagline,
                              style: const TextStyle(
                                fontFamily: 'Jua',
                                fontSize: 15,
                                color: AppColors.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ChunkyIconButton(
                        icon: Icons.bar_chart_rounded,
                        onPressed: () => _open(const StatsScreen()),
                      ),
                      const SizedBox(width: 8),
                      ChunkyIconButton(
                        icon: Icons.settings_rounded,
                        onPressed: () => _open(const SettingsScreen()),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.98,
                  children: [
                    for (final game in allGames)
                      _GameTile(
                        game: game,
                        best: records.load(game.id).best,
                        onTap: () =>
                            _open(GameShellScreen(definition: game)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BgBlob extends StatelessWidget {
  const _BgBlob(this.size);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.bgShape,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 풀블리드 게임 카드 — 카드 전체가 게임색, 같은 색상의 상→하 그라데이션과
/// 흰 타이포 오버레이. 누르면 살짝 축소.
class _GameTile extends StatefulWidget {
  const _GameTile(
      {required this.game, required this.best, required this.onTap});

  final GameDefinition game;
  final num? best;
  final VoidCallback onTap;

  @override
  State<_GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<_GameTile> {
  bool _pressed = false;

  static const _textShadows = [
    Shadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 3),
  ];

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final best = widget.best;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                lighten(game.accent, 0.07),
                game.accent,
                darken(game.accent, 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: game.accent.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -26,
                  left: -22,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                  child: Column(
                    children: [
                      Expanded(child: Center(child: game.buildPreview())),
                      Text(
                        game.title,
                        style: const TextStyle(
                          fontFamily: 'Jua',
                          fontSize: 17,
                          color: Colors.white,
                          shadows: _textShadows,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      if (best == null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: darken(game.accent, 0.1),
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      else
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: '${Strings.bestPrefix} ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.75),
                                shadows: _textShadows,
                              ),
                            ),
                            TextSpan(
                              text: game.formatScore(best),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: _textShadows,
                              ),
                            ),
                          ]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
