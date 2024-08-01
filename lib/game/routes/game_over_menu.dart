import 'package:arion/game/components/custom_button.dart';
import 'package:arion/game/utils/app_theme.dart';
import 'package:flutter/material.dart';

class GameOverMenu extends StatelessWidget {
  const GameOverMenu({
    super.key,
    this.onRetryPressed,
    this.onExitPressed,
  });

  static const id = 'GameOverMenu';

  final VoidCallback? onRetryPressed;
  final VoidCallback? onExitPressed;

  @override
  Widget build(BuildContext context) {
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
                    'GAME OVER',
                    style: AppTheme.headline1,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Restart',
                    onTap: () {
                      onRetryPressed?.call();
                    },
                  ),
                  const SizedBox(height: 5),
                  CustomButton(
                    text: 'Exit',
                    onTap: () {
                      onExitPressed?.call();
                    },
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
