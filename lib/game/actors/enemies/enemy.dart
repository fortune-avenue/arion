import 'dart:ui';

import 'package:arion/game/enum/direction.dart';
import 'package:arion/game/game.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:arion/game/weapons/claw.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' hide Image;

abstract class Enemy extends SpriteAnimationComponent
    with HasGameReference<ArionGame>, HasAncestor<Gameplay> {
  Enemy({super.position, super.size}) : super(anchor: Anchor.center);

  // health of the zombie, create the health bar soon
  double health = 150.0;
  double maxHealth = 150.0; // Maximum health

  bool get isAlive => health > 0;

  bool isFollowing = true;
  bool isAttacking = false;
  bool isRadiusToAttack = false;

  final double _animationSpeed = 0.15;
  double attackSpeed = 0.10;

  double timeSinceLastAttack = 0.0; // Time since last attack

  late final Future<Image> _idleImage;
  late final Future<Image> _walkImage;
  late final Future<Image> _deathImage;
  late final Future<Image> _attackImage;
  late final Future<Image> _burstImage;

  // walk animation
  late final SpriteAnimation _runDownAnimation;
  late final SpriteAnimation _runLeftAnimation;
  late final SpriteAnimation _runUpAnimation;
  late final SpriteAnimation _runRightAnimation;
  // idle animation
  late final SpriteAnimation _idleDownAnimation;
  late final SpriteAnimation _idleLeftAnimation;
  late final SpriteAnimation _idleUpAnimation;
  late final SpriteAnimation _idleRightAnimation;
  // death animation
  late final SpriteAnimation _deathDownAnimation;
  late final SpriteAnimation _deathLeftAnimation;
  late final SpriteAnimation _deathUpAnimation;
  late final SpriteAnimation _deathRightAnimation;
  // attack animation
  late final SpriteAnimation _attackDownAnimation;
  late final SpriteAnimation _attackLeftAnimation;
  late final SpriteAnimation _attackUpAnimation;
  late final SpriteAnimation _attackRightAnimation;
  // burst animation
  late final SpriteAnimation _burstDownAnimation;
  late final SpriteAnimation _burstLeftAnimation;
  late final SpriteAnimation _burstUpAnimation;
  late final SpriteAnimation _burstRightAnimation;

  // to determine which direction that zombie move
  Direction movementDirection = Direction.idle;
  Direction direction = Direction.idle;

  bool isBursting = false;

  @override
  Future<void> onLoad() async {
    await loadAnimation().then((_) => {animation = _idleDownAnimation});
    await add(
      RectangleHitbox.relative(
        Vector2(0.6, 1),
        parentSize: size,
        anchor: Anchor.center,
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void update(double dt) async {
    _burstAnimation();
    _attackAnimation();
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (isAlive) {
      double percentageHealth = (health / maxHealth * size.x).abs();
      canvas.drawRect(
        Rect.fromLTWH(0, -5, size.x, 5),
        Paint()..color = Colors.red.shade50,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, -5, percentageHealth, 5),
        Paint()..color = Colors.red,
      );
    }
    super.render(canvas);
  }

  // show the attack on the current weapon
  bool canAttack(double attackSpeed) => timeSinceLastAttack >= attackSpeed;
  Future<void> scratch({double? attackPoint}) async {
    if (!game.playerData.isAlive) return;

    final claw = Claw(direction: direction);
    claw.attackPoint = attackPoint!;
    if (!canAttack(claw.attackSpeed)) return;

    isAttacking = true;
    await add(claw);
    timeSinceLastAttack = 0.0; // Reset time since last attack
  }

  void moving({
    required double speed,
    required double dt,
    required Vector2 randomPosition,
  }) {
    Vector2 directionVector = randomPosition - position;
    directionVector.normalize(); // Normalize to get a unit vector

    // Determine the direction based on the vector components
    if (directionVector.y < -0.5) {
      if (directionVector.x < -0.5) {
        movementDirection = Direction.upLeft;
      } else if (directionVector.x > 0.5) {
        movementDirection = Direction.upRight;
      } else {
        movementDirection = Direction.up;
      }
      direction = movementDirection;
    } else if (directionVector.y > 0.5) {
      if (directionVector.x < -0.5) {
        movementDirection = Direction.downLeft;
      } else if (directionVector.x > 0.5) {
        movementDirection = Direction.downRight;
      } else {
        movementDirection = Direction.down;
      }
      direction = movementDirection;
    } else {
      if (directionVector.x < -0.5) {
        movementDirection = Direction.left;
        direction = movementDirection;
      } else if (directionVector.x > 0.5) {
        movementDirection = Direction.right;
        direction = movementDirection;
      } else {
        movementDirection = Direction.idle;
      }
    }

    // move
    position += directionVector * speed * dt;

    _movementAnimation();
  }

  void priorityLayer() {
    if (position.y < ancestor.player.position.y) {
      priority = 0;
    } else {
      priority = 2;
    }
  }

  // when zombie is attacked, reduce the value by the attack point
  void attacked(double attackPoint) {
    if (!isAlive) return;
    health -= attackPoint;
  }

  void bounced({required double bounceAmount}) {
    if (direction == Direction.up) {
      position.y += bounceAmount;
    } else if (direction == Direction.down) {
      position.y -= bounceAmount;
    } else if (direction == Direction.left ||
        direction == Direction.upLeft ||
        direction == Direction.downLeft) {
      position.x += bounceAmount;
    } else if (direction == Direction.right ||
        direction == Direction.upRight ||
        direction == Direction.downRight) {
      position.x -= bounceAmount;
    }
    position.normalized();
  }

  // animate when zombie death
  void deathAnimation() {
    if (!isAlive) {
      if (direction == Direction.up) {
        animation = _deathUpAnimation;
      } else if (direction == Direction.down) {
        animation = _deathDownAnimation;
      } else if (direction == Direction.left ||
          direction == Direction.upLeft ||
          direction == Direction.downLeft) {
        animation = _deathLeftAnimation;
      } else if (direction == Direction.right ||
          direction == Direction.upRight ||
          direction == Direction.downRight) {
        animation = _deathRightAnimation;
      } else {
        animation = _deathDownAnimation;
      }
    }
  }

  void _burstAnimation() {
    if (isBursting) {
      if (direction == Direction.up) {
        animation = _burstUpAnimation;
      } else if (direction == Direction.down) {
        animation = _burstDownAnimation;
      } else if (direction == Direction.left ||
          direction == Direction.upLeft ||
          direction == Direction.downLeft) {
        animation = _burstLeftAnimation;
      } else if (direction == Direction.right ||
          direction == Direction.upRight ||
          direction == Direction.downRight) {
        animation = _burstRightAnimation;
      } else {
        animation = _burstDownAnimation;
      }
      // if animations over, set to false
      if (animationTicker?.isLastFrame == true) {
        isBursting = false;
        animation = _idleDownAnimation;
      }
    }
  }

  // animate when player attacks
  void _attackAnimation() {
    if (isAttacking) {
      if (direction == Direction.up) {
        animation = _attackUpAnimation;
      } else if (direction == Direction.down) {
        animation = _attackDownAnimation;
      } else if (direction == Direction.left ||
          direction == Direction.upLeft ||
          direction == Direction.downLeft) {
        animation = _attackLeftAnimation;
      } else if (direction == Direction.right ||
          direction == Direction.upRight ||
          direction == Direction.downRight) {
        animation = _attackRightAnimation;
      } else {
        animation = _attackDownAnimation;
      }
      // if animations over, set to false
      if (animationTicker?.isLastFrame == true) {
        isAttacking = false;
        animation = _idleDownAnimation;
      }
    }
  }

  // move the zombie
  void _movementAnimation() {
    switch (movementDirection) {
      case Direction.down:
        animation = _runDownAnimation;
        break;
      case Direction.up:
        animation = _runUpAnimation;
        break;
      case Direction.left:
        animation = _runLeftAnimation;
        break;
      case Direction.right:
        animation = _runRightAnimation;
        break;
      case Direction.upLeft:
        animation = _runLeftAnimation;
        break;
      case Direction.upRight:
        animation = _runRightAnimation;
        break;
      case Direction.downRight:
        animation = _runRightAnimation;
        break;
      case Direction.downLeft:
        animation = _runLeftAnimation;
        break;
      case Direction.idle:
        if (direction == Direction.up) {
          animation = _idleUpAnimation;
        } else if (direction == Direction.down) {
          animation = _idleDownAnimation;
        } else if (direction == Direction.left ||
            direction == Direction.upLeft ||
            direction == Direction.downLeft) {
          animation = _idleLeftAnimation;
        } else if (direction == Direction.right ||
            direction == Direction.upRight ||
            direction == Direction.downRight) {
          animation = _idleRightAnimation;
        }
        break;
    }
  }

  Future<void> loadAnimation() async {
    // WALK
    final walkSpriteSheet = SpriteSheet(
      image: await _walkImage,
      srcSize: Vector2.all(64), // each tile size
    );

    _runDownAnimation = walkSpriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 10,
    );

    _runUpAnimation = walkSpriteSheet.createAnimation(
      row: 1,
      stepTime: _animationSpeed,
      to: 10,
    );

    _runRightAnimation = walkSpriteSheet.createAnimation(
      row: 2,
      stepTime: _animationSpeed,
      to: 10,
    );

    _runLeftAnimation = walkSpriteSheet.createAnimation(
      row: 3,
      stepTime: _animationSpeed,
      to: 10,
    );

    // IDLE
    final idleSpriteSheet = SpriteSheet(
      image: await _idleImage,
      srcSize: Vector2.all(64),
    );

    _idleDownAnimation = idleSpriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 5,
    );

    _idleUpAnimation = idleSpriteSheet.createAnimation(
      row: 1,
      stepTime: _animationSpeed,
      to: 5,
    );

    _idleRightAnimation = idleSpriteSheet.createAnimation(
      row: 2,
      stepTime: _animationSpeed,
      to: 5,
    );

    _idleLeftAnimation = idleSpriteSheet.createAnimation(
      row: 3,
      stepTime: _animationSpeed,
      to: 5,
    );

    // DEATH
    final deathSpriteSheet = SpriteSheet(
      image: await _deathImage,
      srcSize: Vector2.all(64),
    );

    _deathDownAnimation = deathSpriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 7,
      loop: false,
    );

    _deathUpAnimation = deathSpriteSheet.createAnimation(
      row: 1,
      stepTime: _animationSpeed,
      to: 7,
      loop: false,
    );

    _deathRightAnimation = deathSpriteSheet.createAnimation(
      row: 2,
      stepTime: _animationSpeed,
      to: 7,
      loop: false,
    );

    _deathLeftAnimation = deathSpriteSheet.createAnimation(
      row: 3,
      stepTime: _animationSpeed,
      to: 7,
      loop: false,
    );

    // ATTACK
    final attackSpriteSheet = SpriteSheet(
      image: await _attackImage,
      srcSize: Vector2.all(64),
    );

    _attackDownAnimation = attackSpriteSheet.createAnimation(
      row: 0,
      stepTime: attackSpeed,
      to: 5,
      loop: false,
    );

    _attackUpAnimation = attackSpriteSheet.createAnimation(
      row: 1,
      stepTime: attackSpeed,
      to: 5,
      loop: false,
    );

    _attackRightAnimation = attackSpriteSheet.createAnimation(
      row: 2,
      stepTime: attackSpeed,
      to: 5,
      loop: false,
    );

    _attackLeftAnimation = attackSpriteSheet.createAnimation(
      row: 3,
      stepTime: attackSpeed,
      to: 5,
      loop: false,
    );

    // BURST
    final burstSpriteSheet = SpriteSheet(
      image: await _burstImage,
      srcSize: Vector2.all(64),
    );

    _burstDownAnimation = burstSpriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 5,
    );

    _burstUpAnimation = burstSpriteSheet.createAnimation(
      row: 1,
      stepTime: _animationSpeed,
      to: 5,
    );

    _burstRightAnimation = burstSpriteSheet.createAnimation(
      row: 2,
      stepTime: _animationSpeed,
      to: 5,
    );

    _burstLeftAnimation = burstSpriteSheet.createAnimation(
      row: 3,
      stepTime: _animationSpeed,
      to: 5,
    );
  }

  void setIdleImage(Future<Image> image) => _idleImage = image;
  void setWalkImage(Future<Image> image) => _walkImage = image;
  void setDeathImage(Future<Image> image) => _deathImage = image;
  void setAttackImage(Future<Image> image) => _attackImage = image;
  void setBurstImage(Future<Image> image) => _burstImage = image;

  void setAnimationToIdle() => animation = _idleDownAnimation;
  void moveAnimationLeft() => animation = _runLeftAnimation;
  void moveAnimationRight() => animation = _runRightAnimation;
}
