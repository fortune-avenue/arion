import 'dart:async';

import 'package:arion/game/actors/player.dart';
import 'package:arion/game/enum/direction.dart';
import 'package:arion/game/game.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class Poison extends SpriteAnimationComponent
    with
        HasGameReference<ArionGame>,
        HasAncestor<Gameplay>,
        CollisionCallbacks {
  Poison({super.position, required this.direction})
      : super(size: Vector2.all(64.0));

  final Direction direction;

  late final SpriteAnimation _poisonDownAnimation;
  late final SpriteAnimation _poisonLeftAnimation;
  late final SpriteAnimation _poisonUpAnimation;
  late final SpriteAnimation _poisonRightAnimation;
  late final SpriteAnimation _poisonIdleAnimation;

  final double _animationSpeed = 0.05;

  // Poison attack point
  double attackPoint = 20.0;
  final attackSpeed = 0.4; // Attack speed in seconds

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // remove after finish
    removeOnFinish = true;

    // add the hitbox so that we can collapse with other
    await add(
      CircleHitbox.relative(
        1,
        parentSize: size / 1.6,
        position: Vector2.all(10),
        collisionType: CollisionType.active,
      ),
    );

    // load the animation
    await _loadAnimations().then((_) => {animation = _poisonIdleAnimation});
  }

  @override
  void update(double dt) {
    switch (direction) {
      case Direction.down:
        animation = _poisonDownAnimation;
        position = Vector2(0, 40);
        break;
      case Direction.up:
        animation = _poisonUpAnimation;
        position = Vector2(0, -40);
        break;
      case Direction.left:
        animation = _poisonLeftAnimation;
        position = Vector2(-40, 0);
        break;
      case Direction.right:
        animation = _poisonRightAnimation;
        position = Vector2(40, 0);
        break;
      case Direction.upLeft:
        animation = _poisonLeftAnimation;
        position = Vector2(-40, 0);
        break;
      case Direction.upRight:
        animation = _poisonRightAnimation;
        position = Vector2(40, 0);
        break;
      case Direction.downRight:
        animation = _poisonRightAnimation;
        position = Vector2(40, 0);
        break;
      case Direction.downLeft:
        animation = _poisonLeftAnimation;
        position = Vector2(-40, 0);
        break;
      case Direction.idle:
        animation = _poisonIdleAnimation;
        position = Vector2(0, 40);
        break;
    }
    super.update(dt);
  }

  // load the animation
  Future<void> _loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await game.images.load('demon/Poison.png'),
      srcSize: Vector2.all(64),
    );

    _poisonUpAnimation = spriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 8,
      loop: false,
    );

    _poisonRightAnimation = spriteSheet.createAnimation(
      row: 1,
      stepTime: _animationSpeed,
      to: 8,
      loop: false,
    );

    _poisonDownAnimation = spriteSheet.createAnimation(
      row: 2,
      stepTime: _animationSpeed,
      to: 8,
      loop: false,
    );

    _poisonLeftAnimation = spriteSheet.createAnimation(
      row: 3,
      stepTime: _animationSpeed,
      to: 8,
      loop: false,
    );

    _poisonIdleAnimation = spriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 8,
      loop: false,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      if (game.playerData.isAlive) {
        other.attacked(attackPoint);
      }
    }
  }
}
