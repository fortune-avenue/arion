import 'dart:async';

import 'package:arion/game/actors/enemies/zombie.dart';
import 'package:arion/game/components/arrow3_pickable.dart';
import 'package:arion/game/components/collectible_item_list.dart';
import 'package:arion/game/components/crossbow_pickable.dart';
import 'package:arion/game/components/energy_bar.dart';
import 'package:arion/game/components/potion.dart';
import 'package:arion/game/components/stones_pickable.dart';
import 'package:arion/game/enum/dialog.dart';
import 'package:arion/game/enum/direction.dart';
import 'package:arion/game/enum/weapon.dart';
import 'package:arion/game/game.dart';
import 'package:arion/game/input.dart';
import 'package:arion/game/model/collectible_item.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:arion/game/utils/sound_effect.dart';
import 'package:arion/game/weapons/arrow.dart';
import 'package:arion/game/weapons/sword.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationComponent
    with
        HasGameReference<ArionGame>,
        HasAncestor<Gameplay>,
        CollisionCallbacks {
  Player({
    super.position,
    required this.joystick,
    required this.map,
    required this.camera,
    required this.world,
  }) : super(
          size: Vector2.all(32.0),
          anchor: Anchor.center,
          priority: 1, // to make it shows on top
        );

  final JoystickComponent joystick;
  final TiledComponent map;
  final CameraComponent camera;
  final World world;

  // walk
  late final SpriteAnimation _runDownAnimation;
  late final SpriteAnimation _runLeftAnimation;
  late final SpriteAnimation _runUpAnimation;
  late final SpriteAnimation _runRightAnimation;

  // idle
  late final SpriteAnimation _idleDownAnimation;
  late final SpriteAnimation _idleLeftAnimation;
  late final SpriteAnimation _idleUpAnimation;
  late final SpriteAnimation _idleRightAnimation;

  // death
  late final SpriteAnimation _deathDownAnimation;
  late final SpriteAnimation _deathLeftAnimation;
  late final SpriteAnimation _deathUpAnimation;
  late final SpriteAnimation _deathRightAnimation;

  // stab
  late final SpriteAnimation _stabDownAnimation;
  late final SpriteAnimation _stabLeftAnimation;
  late final SpriteAnimation _stabUpAnimation;
  late final SpriteAnimation _stabRightAnimation;

  // shoot
  late final SpriteAnimation _shootDownAnimation;
  late final SpriteAnimation _shootLeftAnimation;
  late final SpriteAnimation _shootUpAnimation;
  late final SpriteAnimation _shootRightAnimation;

  late final SpriteComponent pickedStone;

  // collide
  bool hasCollided = false;

  // bring
  bool bringStone = false;

  final double _animationSpeed = 0.15;

  // If Bring Stone then slower speed to 40
  set setSpeed(int data) => _speed;
  int get _speed => 80;

  List<Weapon> availableWeapons = [Weapon.sword];

  int selectedWeaponIndex = 0;

  Weapon get selectedWeapon => availableWeapons[selectedWeaponIndex];

  late Sword sword;
  late Crossbow crossbow;

  double energy = 0;
  double energyMultiplier = 10;
  // to determine which direction that player move
  Direction movementDirection = Direction.idle;
  Direction attackDirection = Direction.idle;
  Direction collisionDirection = Direction.idle;

  // state if the player attack using swords
  bool isStabbing = false;

  // state if the player attack using bullets
  bool isShooting = false;

  bool isMelee = false;

  double timeSinceLastAttack = 0.0; // Time since last attack

  int arrowLeft = 0;
  int stoneLeft = 0;

  late EnergyBar energyBar;
  late CollectibleItemList collectibleItemList;

  Map<String, CollectibleItem> collectibleItems = {};

  bool isShowOpeningDialog = true;
  bool isShowHealthPotionDialog = true;
  bool isShowRagePotionDialog = true;

  bool isMoveDown = false;
  bool isMoveUp = false;
  bool isMoveLeft = false;
  bool isMoveRight = false;
  // audio
  late AudioPlayer footStepAudioPlayer;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // load all animation
    await _loadAnimations().then((_) => {animation = _idleDownAnimation});
    await _initWeapon();

    // add hitbox so we can detect if player collapse to other
    _addShape();

    _addEnergyBar();
    _addCollectibleItems();
    _keyboardCallbacks();
    await _initializeFootstepAudio();

    _isJoystickListener();
  }

  void _addShape() {
    final shape = RectangleHitbox.relative(
      Vector2(0.6, 1),
      parentSize: size,
      collisionType: CollisionType.active,
    );
    add(shape);
  }

  Future<void> _initWeapon() async {
    sword = Sword(direction: attackDirection);
    crossbow = Crossbow(arrowPosition: position, direction: attackDirection);
    await add(crossbow);
  }

  void _keyboardCallbacks() {
    world.add(InputRepeat(
      keyDownCallbacks: {
        LogicalKeyboardKey.arrowDown: () {
          isMoveDown = true;
        },
        LogicalKeyboardKey.arrowLeft: () {
          isMoveLeft = true;
        },
        LogicalKeyboardKey.arrowRight: () {
          isMoveRight = true;
        },
        LogicalKeyboardKey.arrowUp: () {
          isMoveUp = true;
        },
      },
      keyUpCallbacks: {
        LogicalKeyboardKey.arrowDown: () {
          isMoveDown = false;
        },
        LogicalKeyboardKey.arrowLeft: () {
          isMoveLeft = false;
        },
        LogicalKeyboardKey.arrowRight: () {
          isMoveRight = false;
        },
        LogicalKeyboardKey.arrowUp: () {
          isMoveUp = false;
        },
      },
    ));
  }

  void _isJoystickListener() {
    game.isJoystickNotifier.addListener(() {
      if (game.isJoystickNotifier.value) {
        camera.viewport.add(joystick);
      } else {
        joystick.removeFromParent();
      }
    });
  }

  @override
  void update(double dt) {
    _showOpeningDialog();
    _timeSinceLastAttack(dt);
    _energyRegen(dt);
    _healthRegen();
    _deathAnimation();
    _movement(dt);
    _stabAnimation();
    _shootAnimation();
    camera.viewport.remove(energyBar);
    _addEnergyBar();
    camera.viewport.remove(collectibleItemList);
    _addCollectibleItems();
    super.update(dt);
  }

  void _healthRegen() {
    int maxHealth = 400;
    game.playerData.health.value < maxHealth
        ? game.playerData.health.value += 0.1
        : maxHealth;
  }

  void _energyRegen(double dt) {
    int maxEnergy = 50;
    energy < maxEnergy ? energy += dt * energyMultiplier : maxEnergy;
  }

  void _timeSinceLastAttack(double dt) {
    timeSinceLastAttack += dt;
  }

  void _showOpeningDialog() {
    if (isShowOpeningDialog) {
      isShowOpeningDialog = false;
      footStepAudioPlayer.pause();
      game.showDialogBox(
        message: DialogBox.opening,
        onPressed: () async {
          resetMovement();
          game.popRoute();

          await Future.delayed(const Duration(milliseconds: 100));

          game.showDialogBox(
            message: DialogBox.mission,
            onPressed: () async {
              resetMovement();
              game.popRoute();

              await Future.delayed(const Duration(milliseconds: 100));

              game.showDialogBox(
                message: DialogBox.energyManagement,
                onPressed: () async {
                  resetMovement();
                  game.popRoute();
                  footStepAudioPlayer.resume();
                  game.resumeEngine();
                },
              );
            },
          );
        },
      );
    }
  }

  void resetMovement() {
    isMoveDown = false;
    isMoveUp = false;
    isMoveLeft = false;
    isMoveRight = false;
  }

  Future<void> _addEnergyBar() async {
    energyBar = EnergyBar(
      priority: 1,
      position: Vector2(600, 48),
      energy: energy,
    );

    await camera.viewport.add(energyBar);
  }

  Future<void> _addCollectibleItems() async {
    collectibleItemList = CollectibleItemList(
      position: Vector2(600, 80),
      collectibleItems: collectibleItems,
    );

    await camera.viewport.add(collectibleItemList);
  }

  bool canAttack(double attackSpeed) {
    return timeSinceLastAttack >= attackSpeed;
  }

  bool _playerCannotMove() =>
      !game.playerData.isAlive || isStabbing || isShooting;

  // animate when player death
  void _deathAnimation() {
    if (!game.playerData.isAlive) {
      if (movementDirection == Direction.up) {
        animation = _deathUpAnimation;
      } else if (movementDirection == Direction.down) {
        animation = _deathDownAnimation;
      } else if (movementDirection == Direction.left ||
          movementDirection == Direction.upLeft ||
          movementDirection == Direction.downLeft) {
        animation = _deathLeftAnimation;
      } else if (movementDirection == Direction.right ||
          movementDirection == Direction.upRight ||
          movementDirection == Direction.downRight) {
        animation = _deathRightAnimation;
      } else {
        animation = _deathDownAnimation;
      }
    }
  }

  // animate when player stabs
  void _stabAnimation() {
    if (isStabbing) {
      if (attackDirection == Direction.up) {
        animation = _stabUpAnimation;
      } else if (attackDirection == Direction.down) {
        animation = _stabDownAnimation;
      } else if (attackDirection == Direction.left ||
          attackDirection == Direction.upLeft ||
          attackDirection == Direction.downLeft) {
        animation = _stabLeftAnimation;
      } else if (attackDirection == Direction.right ||
          attackDirection == Direction.upRight ||
          attackDirection == Direction.downRight) {
        animation = _stabRightAnimation;
      } else {
        animation = _stabDownAnimation;
      }
      // if animations over, set to false
      if (animationTicker?.isLastFrame == true) {
        isStabbing = false;
        animation = _idleDownAnimation;
      }
    }
  }

  // animate when player shoots
  void _shootAnimation() {
    if (isShooting) {
      if (attackDirection == Direction.up) {
        animation = _shootUpAnimation;
      } else if (attackDirection == Direction.down) {
        animation = _shootDownAnimation;
      } else if (attackDirection == Direction.left ||
          attackDirection == Direction.upLeft ||
          attackDirection == Direction.downLeft) {
        animation = _shootLeftAnimation;
      } else if (attackDirection == Direction.right ||
          attackDirection == Direction.upRight ||
          attackDirection == Direction.downRight) {
        animation = _shootRightAnimation;
      } else {
        animation = _shootDownAnimation;
      }
      // if animations over, set to false
      if (animationTicker?.isLastFrame == true) {
        isShooting = false;
        animation = _idleDownAnimation;
      }
    }
  }

  // when zombie is attacked, reduce the value by the attack point
  void attacked(double attackPoint) {
    if (!game.playerData.isAlive) return;
    game.playerData.health.value -= attackPoint;
  }

  void _moveDown(double dt) {
    animation = _runDownAnimation;
    if (y < map.height - height &&
        ![Direction.down, Direction.downRight, Direction.downLeft]
            .contains(collisionDirection)) {
      position.add(
        Vector2(
          0,
          1 * _speed * dt,
        ),
      );
    }
    movementDirection = Direction.down;
    attackDirection = Direction.down;
  }

  void _moveUp(double dt) {
    animation = _runUpAnimation;
    if (y > 0 &&
        ![Direction.up, Direction.upRight, Direction.upLeft]
            .contains(collisionDirection)) {
      position.add(
        Vector2(
          0,
          1 * _speed * -dt,
        ),
      );
    }

    movementDirection = Direction.up;
    attackDirection = Direction.up;
  }

  void _moveLeft(double dt) {
    animation = _runLeftAnimation;
    if (x > 0 &&
        ![Direction.left, Direction.upLeft, Direction.downLeft]
            .contains(collisionDirection)) {
      position.add(
        Vector2(
          1 * _speed * -dt,
          0,
        ),
      );
    }

    movementDirection = Direction.left;
    attackDirection = Direction.left;
  }

  void _moveRight(double dt) {
    animation = _runRightAnimation;
    if (x < map.width - width &&
        ![Direction.right, Direction.upRight, Direction.downRight]
            .contains(collisionDirection)) {
      position.add(
        Vector2(
          1 * _speed * dt,
          0,
        ),
      );
    }

    movementDirection = Direction.right;
    attackDirection = Direction.right;
  }

  void _moveUpLeft(double dt) {
    animation = _runLeftAnimation;
    if (y > 0 &&
        x > 0 &&
        ![
          Direction.upLeft,
          Direction.left,
          Direction.up,
          Direction.downLeft,
        ].contains(collisionDirection)) {
      position.add(
        Vector2(
              1 * _speed * -dt,
              1 * _speed * -dt,
            ) /
            1.5,
      );
    }

    movementDirection = Direction.upLeft;
    attackDirection = Direction.upLeft;
  }

  void _moveUpRight(double dt) {
    animation = _runRightAnimation;
    if (y > 0 &&
        x < map.width - width &&
        ![
          Direction.upRight,
          Direction.up,
          Direction.right,
          Direction.downRight,
        ].contains(collisionDirection)) {
      position.add(
        Vector2(
              1 * _speed * dt,
              1 * _speed * -dt,
            ) /
            1.5,
      );
    }

    movementDirection = Direction.upRight;
    attackDirection = Direction.upRight;
  }

  void _moveDownRight(double dt) {
    animation = _runRightAnimation;
    if (y < map.height - height &&
        x < map.width - width &&
        ![
          Direction.downRight,
          Direction.right,
          Direction.upRight,
          Direction.down,
        ].contains(collisionDirection)) {
      position.add(
        Vector2(
              1 * _speed * dt,
              1 * _speed * dt,
            ) /
            1.5,
      );
    }

    movementDirection = Direction.downRight;
    attackDirection = Direction.downRight;
  }

  void _moveDownLeft(double dt) {
    animation = _runLeftAnimation;
    if (y < map.height - height &&
        x > 0 &&
        ![
          Direction.downLeft,
          Direction.left,
          Direction.upLeft,
          Direction.down,
        ].contains(collisionDirection)) {
      position.add(
        Vector2(
              1 * _speed * -dt,
              1 * _speed * dt,
            ) /
            1.5,
      );
    }

    movementDirection = Direction.downLeft;
    attackDirection = Direction.downLeft;
  }

  void _idle() {
    if (attackDirection == Direction.up) {
      animation = _idleUpAnimation;
    } else if (attackDirection == Direction.down) {
      animation = _idleDownAnimation;
    } else if (attackDirection == Direction.left ||
        attackDirection == Direction.upLeft ||
        attackDirection == Direction.downLeft) {
      animation = _idleLeftAnimation;
    } else if (attackDirection == Direction.right ||
        attackDirection == Direction.upRight ||
        attackDirection == Direction.downRight) {
      animation = _idleRightAnimation;
    }

    movementDirection = Direction.idle;
  }

  Future _initializeFootstepAudio() async {
    footStepAudioPlayer = await SoundEffect.loop(SoundEffect.playerWalk);
    await footStepAudioPlayer.pause();
  }

  Future _playOrPauseFootstepAudio() async {
    if (isPlayerMoving() && footStepAudioPlayer.state == PlayerState.paused) {
      await footStepAudioPlayer.resume();
      return;
    }
    if (!isPlayerMoving() &&
        footStepAudioPlayer.state == PlayerState.playing) {
      await footStepAudioPlayer.pause();
    }
  }

  bool isPlayerMoving() {
    if (game.isJoystickNotifier.value) {
      return joystick.isDragged;
    } else {
      return (isMoveDown || isMoveLeft || isMoveUp || isMoveRight);
    }
  }

  // handling movement on the player
  void _movement(double dt) {
    // if player is alive, and not attacking, move the player
    _playOrPauseFootstepAudio();
    if (_playerCannotMove()) return;

    if (game.isJoystickNotifier.value) {
      switch (joystick.direction) {
        case JoystickDirection.down:
          _moveDown(dt);
          break;
        case JoystickDirection.up:
          _moveUp(dt);
          break;
        case JoystickDirection.left:
          _moveLeft(dt);
          break;
        case JoystickDirection.right:
          _moveRight(dt);
          break;
        case JoystickDirection.upLeft:
          _moveUpLeft(dt);
          break;
        case JoystickDirection.upRight:
          _moveUpRight(dt);
          break;
        case JoystickDirection.downRight:
          _moveDownRight(dt);
          break;
        case JoystickDirection.downLeft:
          _moveDownLeft(dt);
          break;
        case JoystickDirection.idle:
          _idle();
          break;
      }
      return;
    }

    if (isMoveUp && isMoveLeft) {
      _moveUpLeft(dt);
    } else if (isMoveUp && isMoveRight) {
      _moveUpRight(dt);
    } else if (isMoveDown && isMoveLeft) {
      _moveDownLeft(dt);
    } else if (isMoveDown && isMoveRight) {
      _moveDownRight(dt);
    } else if (isMoveDown) {
      _moveDown(dt);
    } else if (isMoveUp) {
      _moveUp(dt);
    } else if (isMoveLeft) {
      _moveLeft(dt);
    } else if (isMoveRight) {
      _moveRight(dt);
    } else {
      _idle();
    }
  }

  // show the attack on the current weapon
  Future<void> showAttack({
    required World world,
  }) async {
    if (!game.playerData.isAlive) return;
    if (selectedWeapon == Weapon.sword) {
      sword = Sword(direction: attackDirection);
      if (!canAttack(sword.attackSpeed)) return;
      if (energy < sword.energyUsed) return;
      isStabbing = true;
      energy -= sword.energyUsed;
      await add(sword);
    } else {
      if (!canAttack(crossbow.attackSpeed)) return;
      if (arrowLeft <= 0) return;
      if (energy < crossbow.energyUsed) return;
      isShooting = true;
      crossbow.attack(world, attackDirection);
      arrowLeft--;
      energy -= crossbow.energyUsed;
      collectibleItems.update(
        'Arrow',
        (value) => CollectibleItem(
          name: value.name,
          quantity: value.quantity - 1,
          image: value.image,
        ),
      );
    }
    timeSinceLastAttack = 0.0; // Reset time since last attack
  }

  // change the weapon
  void changeWeapon() {
    if (availableWeapons.length - 1 == selectedWeaponIndex) {
      selectedWeaponIndex = 0;
    } else {
      selectedWeaponIndex++;
    }

    switch (selectedWeapon) {
      case Weapon.sword:
        isMelee = true;
        break;
      case Weapon.crossbow:
        isMelee = false;
        break;
    }
  }

  // load the animation
  Future<void> _loadAnimations() async {
    // WALK
    final walkSpriteSheet = SpriteSheet(
      image: await game.images.load('player/Walk.png'),
      srcSize: Vector2.all(32),
    );

    _runDownAnimation = walkSpriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 4,
    );

    _runUpAnimation = walkSpriteSheet.createAnimation(
      row: 1,
      stepTime: _animationSpeed,
      to: 4,
    );

    _runRightAnimation = walkSpriteSheet.createAnimation(
      row: 2,
      stepTime: _animationSpeed,
      to: 4,
    );

    _runLeftAnimation = walkSpriteSheet.createAnimation(
      row: 3,
      stepTime: _animationSpeed,
      to: 4,
    );

    // IDLE
    final idleSpriteSheet = SpriteSheet(
      image: await game.images.load('player/Idle.png'),
      srcSize: Vector2.all(32),
    );

    _idleDownAnimation = idleSpriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 2,
    );

    _idleUpAnimation = idleSpriteSheet.createAnimation(
      row: 1,
      stepTime: _animationSpeed,
      to: 2,
    );

    _idleRightAnimation = idleSpriteSheet.createAnimation(
      row: 2,
      stepTime: _animationSpeed,
      to: 2,
    );

    _idleLeftAnimation = idleSpriteSheet.createAnimation(
      row: 3,
      stepTime: _animationSpeed,
      to: 2,
    );

    // DEATH
    final deathSpriteSheet = SpriteSheet(
      image: await game.images.load('player/Death.png'),
      srcSize: Vector2.all(32),
    );

    _deathDownAnimation = deathSpriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _deathUpAnimation = deathSpriteSheet.createAnimation(
      row: 1,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _deathRightAnimation = deathSpriteSheet.createAnimation(
      row: 2,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _deathLeftAnimation = deathSpriteSheet.createAnimation(
      row: 3,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    // STAB
    final stabSpriteSheet = SpriteSheet(
      image: await game.images.load('player/Stab.png'),
      srcSize: Vector2.all(32),
    );

    _stabDownAnimation = stabSpriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _stabUpAnimation = stabSpriteSheet.createAnimation(
      row: 1,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _stabRightAnimation = stabSpriteSheet.createAnimation(
      row: 2,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _stabLeftAnimation = stabSpriteSheet.createAnimation(
      row: 3,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    // SHOOT
    final shootSpriteSheet = SpriteSheet(
      image: await game.images.load('player/Crossbow.png'),
      srcSize: Vector2.all(32),
    );

    _shootDownAnimation = shootSpriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 6,
      loop: false,
    );

    _shootUpAnimation = shootSpriteSheet.createAnimation(
      row: 1,
      stepTime: _animationSpeed,
      to: 6,
      loop: false,
    );

    _shootRightAnimation = shootSpriteSheet.createAnimation(
      row: 2,
      stepTime: _animationSpeed,
      to: 6,
      loop: false,
    );

    _shootLeftAnimation = shootSpriteSheet.createAnimation(
      row: 3,
      stepTime: _animationSpeed,
      to: 6,
      loop: false,
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Zombie) {
      if (other.isAlive && game.playerData.isAlive) {
        setSpeed = 55;
      }
    } else {
      setSpeed = 80;
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Zombie) {
      if (other.isAlive && game.playerData.isAlive) {
        setSpeed = 55;
      }
    } else if (other is CrossbowPickable) {
      availableWeapons.add(Weapon.crossbow);
      other.removeFromParent();
    } else if (other is Arrow3Pickable) {
      arrowLeft += 3;
      if (collectibleItems.containsKey('Arrow')) {
        collectibleItems['Arrow'] = CollectibleItem(
          name: collectibleItems['Arrow']!.name,
          quantity: collectibleItems['Arrow']!.quantity + 3,
          image: collectibleItems['Arrow']!.image,
        );
      } else {
        collectibleItems.addAll({
          'Arrow': CollectibleItem(
            name: 'Arrow',
            quantity: 3,
            image: 'arrow_3.png',
          ),
        });
      }
      other.removeFromParent();
    } else if (other is Potion) {
      if (other.potionType == PotionType.health) {
        if (ancestor.healthPotionButton.isVisible) return;
        ancestor.healthPotionButton.isVisible = true;
        other.removeFromParent();
        if (isShowHealthPotionDialog) {
          isShowHealthPotionDialog = false;
          footStepAudioPlayer.pause();
          game.showDialogBox(
            message: DialogBox.healthPotion,
            onPressed: () async {
              resetMovement();
              game.popRoute();
              footStepAudioPlayer.resume();
              game.resumeEngine();
            },
          );
        }
      } else if (other.potionType == PotionType.rage) {
        if (ancestor.ragePotionButton.isVisible) return;
        ancestor.ragePotionButton.isVisible = true;
        other.removeFromParent();
        if (isShowRagePotionDialog) {
          footStepAudioPlayer.pause();
          isShowRagePotionDialog = false;
          game.showDialogBox(
            message: DialogBox.ragePotion,
            onPressed: () async {
              resetMovement();
              game.popRoute();
              footStepAudioPlayer.resume();
              game.resumeEngine();
            },
          );
        }
      }
    } else if (other is StonePickable) {
      ancestor.switchButton(
          showPrimary: false, pickAndPutButton: ancestor.pickItemButton);

      ancestor.pickItemButton.onTap = () async {
        if ((stoneLeft + other.amount) > 6) return;
        stoneLeft += other.amount;
        bringStone = true;
        setSpeed = 40;
        if (collectibleItems.containsKey('Stone')) {
          collectibleItems['Stone'] = CollectibleItem(
            name: collectibleItems['Stone']!.name,
            quantity: collectibleItems['Stone']!.quantity + other.amount,
            image: collectibleItems['Stone']!.image,
          );
        } else {
          collectibleItems.addAll({
            'Stone': CollectibleItem(
              name: 'Stone',
              quantity: other.amount,
              image:
                  'map/collectible/stone-indicator-${other.amount == 1 ? 'small' : 'large'}.png',
            ),
          });
        }
        other.removeFromParent();
      };
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Zombie) {
      setSpeed = 80;
    } else if (other is StonePickable) {
      ancestor.switchButton(
          showPrimary: true, pickAndPutButton: ancestor.pickItemButton);
      ancestor.pickItemButton.onTap = null;
    }
    super.onCollisionEnd(other);
  }
}
