import 'dart:async';

import 'package:arion/game/actors/enemies/demon.dart';
import 'package:arion/game/actors/enemies/zombie.dart';
import 'package:arion/game/enum/direction.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:arion/game/utils/sound_effect.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class Crossbow extends PositionComponent
    with HasGameReference, HasAncestor<Gameplay> {
  Crossbow({
    required this.arrowPosition,
    required this.direction,
  });

  final Direction direction;
  final attackSpeed = 0.2; // Attack speed in seconds
  final energyUsed = 15.0; // Energy in seconds

  final Vector2 arrowPosition;

  late Arrow arrow;

  @override
  FutureOr<void> onLoad() {
    arrow = Arrow(position: arrowPosition, direction: direction);
    return super.onLoad();
  }

  void attack(World world, Direction movementDirection) {
    arrow = Arrow(position: arrowPosition, direction: movementDirection);
    world.add(arrow);

    // play sound crossbow
    SoundEffect.play(SoundEffect.crossbow);
  }
}

class Arrow extends PositionComponent
    with HasGameReference, HasAncestor<Gameplay>, CollisionCallbacks {
  Arrow({
    super.position,
    required this.direction,
  });

  late SpriteComponent _body;

  // bullet speed
  final double _speed = 200;

  // bullet direction
  final Direction direction;

  // bullet attack point
  final double attackPointZombie = 50;
  final double attackPointBoss = 10;

  @override
  Future<void> onLoad() async {
    // initiate the sprite component body
    _body = SpriteComponent(
      sprite: await _getSpriteByDirection(direction),
      anchor: Anchor.center,
      size: Vector2.all(32),
    );
    await add(_body);

    // add hitbox so that it can collapse
    final shape = CircleHitbox.relative(
      1,
      parentSize: _body.size,
      anchor: Anchor.center,
      collisionType: CollisionType.active,
    );
    add(shape);
  }

  // get the sprite by direction
  Future<Sprite> _getSpriteByDirection(Direction direction) async {
    final spriteSheet = SpriteSheet(
      image: await game.images.load('player/Arrow.png'),
      srcSize: Vector2.all(32),
    );
    switch (direction) {
      case Direction.up:
        return spriteSheet.getSprite(0, 0);
      case Direction.upLeft:
        return spriteSheet.getSprite(4, 0);
      case Direction.upRight:
        return spriteSheet.getSprite(5, 0);
      case Direction.right:
        return spriteSheet.getSprite(2, 0);
      case Direction.down:
        return spriteSheet.getSprite(1, 0);
      case Direction.downRight:
        return spriteSheet.getSprite(7, 0);
      case Direction.downLeft:
        return spriteSheet.getSprite(6, 0);
      case Direction.left:
        return spriteSheet.getSprite(3, 0);
      case Direction.idle:
        return spriteSheet.getSprite(1, 0);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // when collapse on zombie, remove the bullet and call the attacked function
    if (other is Zombie) {
      if (other.isAlive) {
        removeFromParent();
        other.attacked(attackPointZombie);
      }
    } else if (other is Demon) {
      if (other.isAlive) {
        removeFromParent();
        other.attacked(attackPointBoss);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // move the bullet with shoot direction
    position += _shootDirection * _speed * dt;
  }

  Vector2 get _shootDirection {
    switch (direction) {
      case Direction.up:
        return Vector2(0, -1);
      case Direction.upLeft:
        return Vector2(-1, -1);
      case Direction.upRight:
        return Vector2(1, -1);
      case Direction.right:
        return Vector2(1, 0);
      case Direction.down:
        return Vector2(0, 1);
      case Direction.downRight:
        return Vector2(1, 1);
      case Direction.downLeft:
        return Vector2(-1, 1);
      case Direction.left:
        return Vector2(-1, 0);
      case Direction.idle:
        return Vector2(0, 1);
    }
  }
}
