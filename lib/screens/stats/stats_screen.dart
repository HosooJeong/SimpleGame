import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/l10n_context.dart';
import '../../app/theme.dart';
import '../../games/game_registry.dart';
import 'sparkline.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final records = AppScope.of(context).records;
    final textTheme = Theme.of(context).textTheme;
    final l = context.l;

    return Scaffold(
      appBar: AppBar(title: Text(l.stats)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final game in allGames)
            Builder(builder: (context) {
              final record = records.load(game.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: game.accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(game.icon, color: game.accent, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(game.title(l), style: textTheme.titleLarge),
                        const Spacer(),
                        Text(l.playsCount(record.plays),
                            style: textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (record.plays == 0)
                      Text(l.noStatsYet, style: textTheme.bodySmall)
                    else ...[
                      Text(
                        game.formatScore(l, record.best!),
                        style: textTheme.displaySmall!
                            .copyWith(color: game.accent, fontSize: 28),
                      ),
                      const SizedBox(height: 12),
                      Sparkline(
                        values: [for (final e in record.history) e.score],
                        color: game.accent,
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
