import 'dart:async';

import 'package:arion/game/game.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

enum PotionType {
  health,
  rage,
}

class Potion extends SpriteAnimationComponent
    with
        HasGameReference<ArionGame>,
        HasAncestor<Gameplay>,
        CollisionCallbacks {
  Potion({super.position, required this.imagePath, required this.potionType});

  final double _animationSpeed = 0.15;
  final String imagePath;
  final PotionType potionType;

  late final SpriteAnimation _idleAnimation;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    await _loadAnimations().then((_) => {animation = _idleAnimation});

    await add(RectangleHitbox.relative(
      Vector2.all(1),
      parentSize: Vector2.all(16),
      position: Vector2(8, 0),
    ));
  }

  Future<void> _loadAnimations() async {
    final body = SpriteSheet(
      image: await game.images.load(imagePath),
      srcSize: Vector2.all(16),
    );
    // IDLE
    _idleAnimation = body.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 12,
    );
  }
}
