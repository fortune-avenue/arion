import 'dart:async';

import 'package:arion/game/enum/direction.dart';
import 'package:arion/game/game.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:arion/game/weapons/claw.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Zombie extends SpriteAnimationComponent
    with HasGameReference<ArionGame>, HasAncestor<Gameplay> {
  Zombie({
    super.position,
    required this.playerPosition,
  }) : super(
          size: Vector2.all(32.0),
          anchor: Anchor.center,
        );

  final Vector2 playerPosition;
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

  final double _animationSpeed = 0.15;
  final double _attackSpeed = 0.10;

  // zombie speed is must less than player speed
  final _speed = 40.0;

  final _attackRadius = 15.0;

  // to determine which direction that zombie move
  Direction movementDirection = Direction.idle;
  Direction direction = Direction.down;

  // health of the zombie, create the health bar soon
  double health = 100.0;
  double maxHealth = 100.0; // Maximum health

  bool get isAlive => health > 0;

  bool isFollowing = true;
  bool isAttacking = false;
  bool isRadiusToAttack = false;

  double timeSinceLastAttack = 0.0; // Time since last attack

  @override
  Future<void> onLoad() async {
    // load all animation
    await _loadAnimations().then((_) => {animation = _idleDownAnimation});

    // add hitbox so we can detect if zombie collapse to other
    await _addShape();
  }

  Future<void> _addShape() async {
    await add(
      RectangleHitbox.relative(
        Vector2(0.6, 1),
        parentSize: size,
        collisionType: CollisionType.passive,
      ),
    );
  }

  bool canAttack(double attackSpeed) {
    return timeSinceLastAttack >= attackSpeed;
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

  @override
  void update(double dt) {
    _timeSinceLastAttack(dt);

    // set the layer
    setLayerPriority();

    _deathAnimation();

    if (isZombieInRadius(playerPosition, _attackRadius) && isAlive) {
      if (!isAttacking && game.playerData.isAlive) {
        showAttack();
      }
    } else {
      isAttacking = false;
      _movement(dt);
    }

    _attackAnimation();

    super.update(dt);
  }

  void setLayerPriority() {
    if (position.y < playerPosition.y) {
      priority = 0;
    } else {
      priority = 2;
    }
  }

  void _timeSinceLastAttack(double dt) {
    timeSinceLastAttack += dt;
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

  // animate when zombie death
  Future<void> _deathAnimation() async {
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

      Future.delayed(const Duration(seconds: 3)).then((value) {
        add(
          OpacityEffect.fadeOut(
            EffectController(duration: 1.0),
          ),
        );

        Future.delayed(const Duration(seconds: 1)).then((value) {
          removeFromParent();
        });
      });
    }
  }

  // handling movement on the zombie
  void _movement(double dt) {
    // move only if its still alive
    if (!isAlive) return;
    movementDirection = Direction.idle;

    if (isFollowing) {
      _moveTowards(playerPosition, dt);
    }
    _movementAnimation();

    // if zombie is in player radius, move towards player position and animate the zombie
    // if (isZombieInRadius(playerPosition, _followingRadius)) {
    //   isFollowing = true;
    // }
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

  // check if the zombie in player radius
  bool isZombieInRadius(Vector2 playerPosition, double radius) {
    double distance = playerPosition.distanceTo(position);
    return distance <= radius;
  }

  // move towards player position
  void _moveTowards(Vector2 playerPosition, double dt) {
    Vector2 directionVector = playerPosition - position;
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
    position += directionVector * _speed * dt;
  }

  // show the attack on the current weapon
  Future<void> showAttack() async {
    if (!game.playerData.isAlive) return;

    final claw = Claw(direction: direction);
    if (!canAttack(claw.attackSpeed)) return;
    isAttacking = true;
    await add(claw);
    timeSinceLastAttack = 0.0; // Reset time since last attack
  }

  // when zombie is attacked, reduce the value by the attack point
  void attacked(double attackPoint) {
    if (!isAlive) return;
    health -= attackPoint;
    if (!isAlive) {
      game.zombieData.totalZombie.value--;
      game.zombieData.totalZombieKilled.value++;
    }
  }

  void bounced({required double bounceAmount}) {
    double bounceX = 0.0;
    double bounceY = 0.0;

    switch (direction) {
      case Direction.up:
        bounceY = bounceAmount;
        break;
      case Direction.down:
        bounceY = -bounceAmount;
        break;
      case Direction.left:
      case Direction.upLeft:
      case Direction.downLeft:
        bounceX = bounceAmount;
        break;
      case Direction.right:
      case Direction.upRight:
      case Direction.downRight:
        bounceX = -bounceAmount;
        break;
      case Direction.idle:
    }

    position.addScaled(Vector2(bounceX, bounceY), 1);
  }

  Future<void> _loadAnimations() async {
    // WALK
    final walkSpriteSheet = SpriteSheet(
      image: await game.images.load('zombie/Walk.png'),
      srcSize: Vector2.all(32), // each tile size
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
      image: await game.images.load('zombie/Idle.png'),
      srcSize: Vector2.all(32),
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
      image: await game.images.load('zombie/Death.png'),
      srcSize: Vector2.all(32),
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
      image: await game.images.load('zombie/Attack.png'),
      srcSize: Vector2.all(32),
    );

    _attackDownAnimation = attackSpriteSheet.createAnimation(
      row: 0,
      stepTime: _attackSpeed,
      to: 5,
      loop: false,
    );

    _attackUpAnimation = attackSpriteSheet.createAnimation(
      row: 1,
      stepTime: _attackSpeed,
      to: 5,
      loop: false,
    );

    _attackRightAnimation = attackSpriteSheet.createAnimation(
      row: 2,
      stepTime: _attackSpeed,
      to: 5,
      loop: false,
    );

    _attackLeftAnimation = attackSpriteSheet.createAnimation(
      row: 3,
      stepTime: _attackSpeed,
      to: 5,
      loop: false,
    );
  }
}
