import 'dart:math';

import 'package:arion/game/actors/enemies/enemy.dart';
import 'package:arion/game/enum/direction.dart';
import 'package:flame/game.dart';

mixin Skills on Enemy {
  int getTargetDistance(int value) {
    int randomInt = Random().nextInt(value);
    randomInt = randomInt < 150 ? 150 : randomInt;
    return randomInt * (Random().nextBool() ? -1 : 1);
  }

  void randomMovement(double dt, double speed, Vector2 randomPosition) {
    isAttacking = false;
    isBursting = false;

    if (!isAlive) return;
    movementDirection = Direction.idle;

    moving(dt: dt, speed: speed, randomPosition: randomPosition);
  }
}
