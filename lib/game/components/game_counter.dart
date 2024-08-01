import 'package:arion/game/game.dart';
import 'package:arion/game/utils/app_theme.dart';
import 'package:arion/game/utils/string_manipulation.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameCounter extends PositionComponent with HasGameReference<ArionGame> {
  GameCounter({
    super.priority,
    super.position,
  });

  double elapsedSeconds = 0;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final formattedTime = elapsedSeconds.toFormattedTime;

    TextPainter(
      textAlign: TextAlign.center,
      text: TextSpan(
        text:
            "$formattedTime\nZombie Killed: ${game.zombieData.totalZombieKilled.value}",
        style: AppTheme.text,
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, const Offset(10, 10));
  }

  @override
  void update(double dt) {
    elapsedSeconds += dt;
    game.playerData.timer = elapsedSeconds;
    super.update(dt);
  }
}
