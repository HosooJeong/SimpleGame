import 'package:flutter/material.dart';

import '../../app/chunky_button.dart';
import '../../app/l10n_context.dart';
import '../../app/theme.dart';
import 'game_definition.dart';

/// 공용 결과 화면 — 점수 카드·신기록 배지·자랑하기/한 번 더.
class ResultView extends StatelessWidget {
  const ResultView({
    super.key,
    required this.definition,
    required this.score,
    required this.isNewBest,
    required this.best,
    required this.abortMessage,
    required this.onShare,
    required this.onRetry,
    required this.onHome,
  });

  final GameDefinition definition;
  final num? score;
  final bool isNewBest;
  final num? best;
  final String? abortMessage;
  final VoidCallback onShare;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l = context.l;
    final aborted = score == null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          if (aborted) ...[
            const Icon(Icons.replay_rounded,
                size: 56, color: AppColors.textDim),
            const SizedBox(height: 16),
            Text(
              abortMessage ?? l.aborted,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ] else
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: cardDecoration(radius: 24),
              child: Column(
                children: [
                  Text(
                    definition.title(l),
                    style: const TextStyle(
                      fontFamily: 'Jua',
                      fontSize: 17,
                      color: AppColors.textDim,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    definition.formatScore(l, score!),
                    style: textTheme.displayLarge!.copyWith(
                      fontSize: 54,
                      color: definition.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isNewBest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: darken(AppColors.accent),
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 18, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            l.newRecord,
                            style: const TextStyle(
                              fontFamily: 'Jua',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (best != null)
                    Text(
                      '${l.bestPrefix} ${definition.formatScore(l, best!)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDim,
                      ),
                    ),
                ],
              ),
            ),
          const Spacer(),
          if (!aborted) ...[
            ChunkyButton(
              label: l.share,
              color: GameColors.blue,
              icon: Icons.share_rounded,
              onPressed: onShare,
            ),
            const SizedBox(height: 10),
          ],
          ChunkyButton(
            label: l.retry,
            color: AppColors.success,
            icon: Icons.replay_rounded,
            onPressed: onRetry,
          ),
          const SizedBox(height: 2),
          TextButton(
            onPressed: onHome,
            child: Text(
              l.home,
              style: const TextStyle(
                fontFamily: 'Jua',
                fontSize: 15,
                color: AppColors.textDim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
