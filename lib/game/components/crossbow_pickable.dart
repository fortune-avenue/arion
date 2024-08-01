import 'dart:async';

import 'package:arion/game/game.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CrossbowPickable extends SpriteComponent
    with
        HasGameReference<ArionGame>,
        HasAncestor<Gameplay>,
        CollisionCallbacks {
  CrossbowPickable({super.position});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    sprite = Sprite(
      await game.images.load('crossbow.png'),
    );

    size = Vector2.all(16);

    await add(RectangleHitbox.relative(
      Vector2.all(1),
      parentSize: Vector2(16, 32),
      position: Vector2(8, 0),
    ));
  }
}
