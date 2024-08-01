import 'dart:async';

import 'package:arion/game/actors/enemies/demon.dart';
import 'package:arion/game/actors/enemies/zombie.dart';
import 'package:arion/game/enum/direction.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:arion/game/utils/sound_effect.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class Sword extends SpriteAnimationComponent
    with HasGameReference, HasAncestor<Gameplay>, CollisionCallbacks {
  Sword({super.position, required this.direction})
      : super(size: Vector2.all(32.0));

  final Direction direction;

  late final SpriteAnimation _swordDownAnimation;
  late final SpriteAnimation _swordLeftAnimation;
  late final SpriteAnimation _swordUpAnimation;
  late final SpriteAnimation _swordRightAnimation;
  late final SpriteAnimation _swordIdleAnimation;

  final double _animationSpeed = 0.05;

  // sword attack point
  final attackPointZombie = 35.0;
  final attackPointBoss = 5.0;
  final attackSpeed = 0.25; // Attack speed in seconds
  final energyUsed = 9.0; // Energy in seconds

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // remove after finish
    removeOnFinish = true;

    // add the hitbox so that we can collapse with other
    await add(
      RectangleHitbox.relative(
        Vector2.all(1),
        parentSize: size,
        anchor: Anchor.center,
      ),
    );

    // load the animation
    await _loadAnimations().then((_) => {animation = _swordIdleAnimation});

    // play sound sword
    SoundEffect.play(SoundEffect.sword);
  }

  @override
  void update(double dt) {
    /// when sword show, show the animation and the position added by 20
    /// so it not showing inside the body player, but outside instead
    switch (direction) {
      case Direction.down:
        animation = _swordDownAnimation;
        position = Vector2(0, 20);
        break;
      case Direction.up:
        animation = _swordUpAnimation;
        position = Vector2(0, -20);
        break;
      case Direction.left:
        animation = _swordLeftAnimation;
        position = Vector2(-20, 0);
        break;
      case Direction.right:
        animation = _swordRightAnimation;
        position = Vector2(20, 0);
        break;
      case Direction.upLeft:
        animation = _swordLeftAnimation;
        position = Vector2(-20, 0);
        break;
      case Direction.upRight:
        animation = _swordRightAnimation;
        position = Vector2(20, 0);
        break;
      case Direction.downRight:
        animation = _swordRightAnimation;
        position = Vector2(20, 0);
        break;
      case Direction.downLeft:
        animation = _swordLeftAnimation;
        position = Vector2(-20, 0);
        break;
      case Direction.idle:
        animation = _swordIdleAnimation;
        position = Vector2(0, 20);
        break;
    }
    super.update(dt);
  }

  // load the animation
  Future<void> _loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await game.images.load('sword_spritesheet.png'),
      srcSize: Vector2(29.0, 32.0),
    );

    _swordDownAnimation = spriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _swordLeftAnimation = spriteSheet.createAnimation(
      row: 1,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _swordUpAnimation = spriteSheet.createAnimation(
      row: 2,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _swordRightAnimation = spriteSheet.createAnimation(
      row: 3,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _swordIdleAnimation = spriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Zombie) {
      // if collapse with zombie, call attacked and send the attack point
      if (other.isAlive) {
        other.attacked(attackPointZombie);
        other.bounced(bounceAmount: 10);
      }
    } else if (other is Demon) {
      if (other.isAlive) {
        other.attacked(attackPointBoss);
        other.bounced(bounceAmount: 8);
      }
    }
  }
}
