import 'dart:async';

import 'package:arion/game/game.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class StonePickable extends SpriteComponent
    with
        HasGameReference<ArionGame>,
        HasAncestor<Gameplay>,
        CollisionCallbacks {
  StonePickable({
    super.position,
    required this.spriteData,
    required this.amount,
  });

  final Sprite spriteData;
  final int amount;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    sprite = spriteData;

    await add(RectangleHitbox.relative(
      Vector2.all(1),
      parentSize: size,
      position: Vector2(8, 0),
    ));
  }
}
