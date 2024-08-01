import 'package:arion/game/components/custom_button.dart';
import 'package:arion/game/game.dart';
import 'package:arion/game/utils/app_theme.dart';
import 'package:arion/game/utils/string_manipulation.dart';
import 'package:flutter/material.dart';

class GameFinishedMenu extends StatelessWidget {
  const GameFinishedMenu({
    super.key,
    required this.game,
    this.onRetryPressed,
    this.onExitPressed,
  });

  static const id = 'GameFinishedMenu';

  final ArionGame game;
  final VoidCallback? onRetryPressed;
  final VoidCallback? onExitPressed;

  int get finalScore {
    const maxScoreTimer = 10000;
    int currentScoreTimer = game.playerData.timer.toInt();
    return maxScoreTimer -
        currentScoreTimer +
        game.zombieData.totalZombieKilled.value;
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = game.playerData.timer.toFormattedTime;
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.84,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/ui/Game Over Game Complete and Pause Board.png',
                  ),
                  fit: BoxFit.fitHeight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'GAME\nFINISHED',
                    style: AppTheme.headline1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Time: $formattedTime',
                    style: AppTheme.headline2.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Zombie Killed: ${game.zombieData.totalZombieKilled.value}',
                    style: AppTheme.headline2.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Final Score: $finalScore',
                    style: AppTheme.headline2.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Restart',
                    onTap: () => onRetryPressed?.call(),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    onTap: () => onExitPressed?.call(),
                    text: 'Exit',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
