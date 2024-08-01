import 'dart:async' as async;
import 'dart:async';
import 'dart:math';

import 'package:arion/game/actors/enemies/demon.dart';
import 'package:arion/game/actors/player.dart';
import 'package:arion/game/components/arrow3_pickable.dart';
import 'package:arion/game/components/bridge.dart';
import 'package:arion/game/components/crossbow_pickable.dart';
import 'package:arion/game/components/game_counter.dart';
import 'package:arion/game/components/health_bar.dart';
import 'package:arion/game/components/obstacle.dart';
import 'package:arion/game/components/pick_and_put_button.dart';
import 'package:arion/game/components/potion.dart';
import 'package:arion/game/components/stones_pickable.dart';
import 'package:arion/game/components/zombie_spawner.dart';
import 'package:arion/game/enum/dialog.dart';
import 'package:arion/game/enum/direction.dart';
import 'package:arion/game/enum/weapon.dart';
import 'package:arion/game/game.dart';
import 'package:arion/game/input.dart';
import 'package:arion/game/weapons/weapon_indicator.dart';
import 'package:arion/game/widgets/default_button.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart' as experimental;
import 'package:flame/palette.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Gameplay extends Component with HasGameReference<ArionGame> {
  Gameplay({
    super.key,
    required this.onPausePressed,
  });

  static const id = 'Gameplay';

  final VoidCallback onPausePressed;

  late TiledComponent map;
  late World world;
  late CameraComponent camera;
  late Player player;
  late JoystickComponent joystick;
  late final DefaultButton _swordButton;
  late final DefaultButton _pauseButton;
  late final DefaultButton healthPotionButton;
  late final DefaultButton ragePotionButton;
  late final PickAndPutButton pickItemButton;
  late final PickAndPutButton putItemButton;
  late final DefaultButton _switchWeaponButton;
  WeaponIndicator? _selectedWeaponIndicator;
  bool showInstructionBuildingBridge = true;

  bool showInstructionFindCave = true;
  bool isFinishBuildingBridge = false;

  late bool hasCollided = false;
  ValueNotifier<bool> isStoneActive = ValueNotifier(false);
  late final PolygonHitbox hitCaveObstacle;

  // callbacks on the keyboard (for testing only)
  late final input = Input(
    keyCallbacks: {
      LogicalKeyboardKey.keyP: onPausePressed,
      LogicalKeyboardKey.space: () {
        if (pickItemButton.isVisible) {
          pickItemButton.onTap?.call();
        } else if (putItemButton.isVisible) {
          putItemButton.onTap?.call();
        } else if (_swordButton.isVisible) {
          _swordButton.onTap?.call();
        }
      },
      LogicalKeyboardKey.keyZ: () {
        if (_switchWeaponButton.isVisible) {
          _switchWeaponButton.onTap?.call();
        }
      },
      LogicalKeyboardKey.keyX: () {
        if (healthPotionButton.isVisible) {
          healthPotionButton.onTap?.call();
        }
      },
      LogicalKeyboardKey.keyC: () {
        if (ragePotionButton.isVisible) {
          ragePotionButton.onTap?.call();
        }
      },
    },
  );

  @override
  Future<void> onLoad() async {
    await _addWorld();
    await _addCamera();
    await _addJoystick();
    await _addActors();
    await _addCaveObstacle();
    await _addZombieSpawner();
    await _addMiniBoss();
    await _addButtons();
    await _addPotion();
    await _addWeapon();
    await _addPickableStones();
    await _addBridge();
    await Obstacle.defineObstacle(
      map: map,
      world: world,
      player: player,
      onGameFinished: () async {
        await player.footStepAudioPlayer.stop();
        game.onGameFinished();
      },
    );
    addStoneListener();

    return super.onLoad();
  }

  // load the actors
  Future<void> _addActors() async {
    player = Player(
      joystick: joystick,
      position: Vector2(320, 1440),
      map: map,
      camera: camera,
      world: world,
    );
    await world.add(player);
    camera.follow(player);
  }

  Future<void> _addCamera() async {
    final healthBar = HealthBar(priority: 1, position: Vector2(600, 16));
    final gameCounter = GameCounter(position: Vector2(270, 16));

    camera = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 320,
      hudComponents: [healthBar, gameCounter],
    );
    camera.setBounds(experimental.Rectangle.fromLTRB(
      640 / 2,
      320 / 2,
      map.width - 640 / 2,
      map.height - 320 / 2,
    ));
    await add(camera);
  }

  Future<void> _addPotion() async {
    final spawnPotionLayer = map.tileMap.getLayer<ObjectGroup>('Potion');
    final objects = spawnPotionLayer?.objects;

    if (objects == null) return;
    for (final object in objects) {
      if (object.class_ == "Health Potion") {
        final healthPotion = Potion(
          position: Vector2(object.x, object.y),
          imagePath: 'potion/health_potion.png',
          potionType: PotionType.health,
        );

        await world.add(healthPotion);
      } else if (object.class_ == 'Rage Potion') {
        final ragePotion = Potion(
          position: Vector2(object.x, object.y),
          imagePath: 'potion/rage_potion.png',
          potionType: PotionType.rage,
        );

        await world.add(ragePotion);
      }
    }
  }

  Future<void> _addWeapon() async {
    final spawnPotionLayer = map.tileMap.getLayer<ObjectGroup>('Weapon');
    final objects = spawnPotionLayer?.objects;

    if (objects == null) return;
    for (final object in objects) {
      if (object.class_ == "Crossbow") {
        final crossbow = CrossbowPickable(
          position: Vector2(object.x, object.y),
        );

        await world.add(crossbow);
      } else if (object.class_ == 'Arrow') {
        final arrow = Arrow3Pickable(
          position: Vector2(object.x, object.y),
        );

        await world.add(arrow);
      }
    }
  }

  Future<void> _addMiniBoss() async {
    final spawnMiniBoss = map.tileMap.getLayer<ObjectGroup>('Zombie Spawns');
    final objects = spawnMiniBoss?.objects;

    if (objects == null) return;
    for (final object in objects) {
      if (object.class_ == "Boss") {
        final boss = Demon();
        boss.position = Vector2(object.x, object.y);

        await world.add(boss);
      }
    }
  }

  Future<void> _addZombieSpawner() async {
    final spawnZombie = map.tileMap.getLayer<ObjectGroup>('Zombie Spawns');
    final objects = spawnZombie?.objects;

    if (objects == null) return;
    for (final object in objects) {
      if (object.class_ == "zombie_spawn") {
        final zombieSpawner = ZombieSpawner(
          world,
          player.position,
          Vector2(object.x, object.y),
          Random().nextDouble() * (15 - 10) + 10,
          false,
        );
        await world.add(zombieSpawner);
      }
      if (object.class_ == "zombie_spawn_after") {
        final zombieSpawner = ZombieSpawner(
          world,
          player.position,
          Vector2(object.x, object.y),
          Random().nextDouble() * (15 - 10) + 10,
          true,
        );
        await world.add(zombieSpawner);
      }
    }
    // every minutes add max zombies by 10 zombies
    async.Timer.periodic(const Duration(minutes: 1), (timer) {
      game.zombieData.maxTotalZombie.value += 10;
    });
  }

  Future<void> _addWorld() async {
    map = await TiledComponent.load('era1-zone1.tmx', Vector2.all(32));
    world = World(children: [map, input]);
    await add(world);
  }

  Future<void> _addJoystick() async {
    const joystickSize = 40.0;
    final knobPaint = BasicPalette.white.withAlpha(80).paint();
    final backgroundPaint = BasicPalette.white.withAlpha(40).paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: joystickSize / 2, paint: knobPaint),
      background: CircleComponent(radius: joystickSize, paint: backgroundPaint),
      position: Vector2(64, 256),
      size: joystickSize,
    );
    if (game.isJoystickNotifier.value) {
      await camera.viewport.add(joystick);
    }
  }

  Future<void> _addButtons() async {
    // Sword Button
    _swordButton = DefaultButton(
      buttonSprite: await game.loadSprite('sword_button.png'),
      buttonPriority: 2,
      onTap: () {
        player.showAttack(world: world);
      },
    )
      ..position = Vector2(544, 256)
      ..size = Vector2.all(75)
      ..anchor = Anchor.center
      ..isVisible = true;
    await camera.viewport.add(_swordButton);
    // Sword Button
    _pauseButton = DefaultButton(
      buttonSprite: await game.loadSprite('pause_button.png'),
      buttonPriority: 2,
      onTap: () {
        onPausePressed.call();
      },
    )
      ..position = Vector2(40, 40)
      ..size = Vector2.all(24)
      ..anchor = Anchor.center
      ..isVisible = true;
    await camera.viewport.add(_pauseButton);

    // Switch Weapon Button
    _selectedWeaponIndicator = WeaponIndicator(
      sprite: await getWeaponImageIndicator(player.selectedWeapon),
    )
      ..position = Vector2(608, 224)
      ..size = Vector2.all(24)
      ..anchor = Anchor.center
      ..isVisible = true;

    // Switch Weapon Button
    _switchWeaponButton = DefaultButton(
      buttonSprite: await game.loadSprite('switch_button.png'),
      buttonPriority: 2,
      onTap: () async {
        camera.viewport.remove(_selectedWeaponIndicator!);
        player.changeWeapon();
        _selectedWeaponIndicator = WeaponIndicator(
          sprite: await getWeaponImageIndicator(player.selectedWeapon),
        )
          ..position = Vector2(608, 224)
          ..size = Vector2.all(24)
          ..anchor = Anchor.center;
        await camera.viewport.add(_selectedWeaponIndicator!);
      },
    )
      ..position = Vector2(608, 224)
      ..size = Vector2.all(50)
      ..anchor = Anchor.center
      ..isVisible = true;
    await camera.viewport.add(_switchWeaponButton);

    await camera.viewport.add(_selectedWeaponIndicator!);

    // Pick and Put Button
    pickItemButton = PickAndPutButton(
      buttonSprite: await game.loadSprite('map/collectible/pick.png'),
      buttonPriority: 1,
    );

    putItemButton = PickAndPutButton(
      buttonSprite: await game.loadSprite('map/collectible/put.png'),
      buttonPriority: 1,
    );

    await camera.viewport.addAll([pickItemButton, putItemButton]);

    healthPotionButton = DefaultButton(
      buttonSprite: await game.loadSprite('potion/health_potion_button.png'),
      buttonPriority: 1,
      onTap: () async {
        healthPotionButton.isVisible = false;
        game.playerData.health.value = 400;
      },
    )
      ..position = Vector2(544 - 80, 256 + 20)
      ..size = Vector2.all(40)
      ..anchor = Anchor.center
      ..isVisible = false;

    await camera.viewport.add(healthPotionButton);

    ragePotionButton = DefaultButton(
      buttonSprite: await game.loadSprite('potion/rage_potion_button.png'),
      buttonPriority: 1,
      onTap: () async {
        ragePotionButton.isVisible = false;
        player.energyMultiplier *= 10;
        Future.delayed(const Duration(seconds: 5))
            .then((value) => player.energyMultiplier /= 10);
      },
    )
      ..position = Vector2(544 - 130, 256 + 20)
      ..size = Vector2.all(40)
      ..anchor = Anchor.center
      ..isVisible = false;

    await camera.viewport.add(ragePotionButton);
  }

  Future<Sprite> getWeaponImageIndicator(Weapon weapon) async {
    switch (weapon) {
      case Weapon.sword:
        return await game.loadSprite('sword.png');
      case Weapon.crossbow:
        return await game.loadSprite('crossbow.png');
    }
  }

  Future<void> _addCaveObstacle() async {
    final caveObstacle = map.tileMap.getLayer<ObjectGroup>('Cave Obstacle');

    final object = caveObstacle?.objects.first;

    if (object!.class_ == 'CaveOpen') {
      final vertices = <Vector2>[];
      for (final point in object.polygon) {
        vertices.add(Vector2(point.x + object.x, point.y + object.y));
      }

      hitCaveObstacle = PolygonHitbox(
        vertices,
        collisionType: CollisionType.passive,
        isSolid: true,
      );

      hitCaveObstacle.onCollisionCallback = (_, other) {
        if (!hasCollided) {
          player.collisionDirection = player.movementDirection;
          hasCollided = true;
        }
      };

      hitCaveObstacle.onCollisionEndCallback = (_) {
        player.collisionDirection = Direction.idle;
        hasCollided = false;
      };

      await map.add(hitCaveObstacle);
    }
  }

  Future<void> _addPickableStones({bool isActive = false}) async {
    final collectibleStones =
        map.tileMap.getLayer<ObjectGroup>('Collectible Stones');
    final objects = collectibleStones?.objects;

    for (var object in objects!) {
      if (object.class_ == 'CollectibleStone1') {
        final stonePickable = StonePickable(
          amount: 1,
          spriteData: Sprite(await game.images.load(
              'map/collectible/${isActive ? "stone-active-small" : "stone-pickable-small"}.png')),
          position: Vector2(object.x, object.y),
        );

        await world.add(stonePickable);
      } else if (object.class_ == 'CollectibleStone2') {
        final stonePickable = StonePickable(
          amount: 2,
          spriteData: Sprite(await game.images.load(
              'map/collectible/${isActive ? "stone-active-large" : "stone-pickable-large"}.png')),
          position: Vector2(object.x, object.y),
        );

        await world.add(stonePickable);
      }
    }
  }

  void addStoneListener() {
    isStoneActive.addListener(() async {
      if (isStoneActive.value) {
        for (final component in world.children.whereType<StonePickable>()) {
          world.remove(component);
        }
        await _addPickableStones(isActive: true);
      }
    });
  }

  Future<void> _addBridge() async {
    final bridgeAssembly =
        map.tileMap.getLayer<ObjectGroup>('Instruction Bridge');
    final objects = bridgeAssembly?.objects;

    for (var object in objects!) {
      final vertices = <Vector2>[];
      for (final point in object.polygon) {
        vertices.add(Vector2(point.x + object.x, point.y + object.y));
      }

      switch (object.class_) {
        case 'InstructionBuildBridge':
          final instructionBuildingBridge = Bridge(
            vertices: vertices,
          );

          instructionBuildingBridge.onCollisionCallback = (_, __) {
            player.footStepAudioPlayer.pause();
            player.resetMovement();
            isStoneActive.value = true;
            game.showDialogBox(
              message: DialogBox.buildingBridge,
              onPressed: () async {
                game.popRoute();

                await Future.delayed(const Duration(milliseconds: 100));

                game.showDialogBox(
                  message: DialogBox.carryStone,
                  onPressed: () async {
                    instructionBuildingBridge.removeFromParent();
                    game.popRoute();
                    game.resumeEngine();
                  },
                );
              },
            );
            showInstructionBuildingBridge = false;
          };

          instructionBuildingBridge.onCollisionEndCallback = (other) {
            player.collisionDirection = Direction.idle;
            player.hasCollided = false;
          };

          await world.add(instructionBuildingBridge);
          break;
        case 'InstructionFinishBridge':
          final instructionFinishBridge = Bridge(
            vertices: vertices,
          );

          instructionFinishBridge.onCollisionCallback = (_, __) {
            player.footStepAudioPlayer.pause();
            player.resetMovement();
            game.showDialogBox(
              message: DialogBox.finishingBridge,
              onPressed: () async {
                instructionFinishBridge.removeFromParent();
                game.popRoute();
                game.resumeEngine();
              },
            );
            showInstructionFindCave = false;
            isFinishBuildingBridge = true;
          };

          instructionFinishBridge.onCollisionEndCallback = (other) {
            player.collisionDirection = Direction.idle;
            player.hasCollided = false;
          };

          await world.add(instructionFinishBridge);
          break;
        case 'InstructionPutStone1':
          final assambleBridge = Bridge(
            vertices: vertices,
            instruction: Instruction.placementStone1,
          );

          assambleBridge.onCollisionCallback = (_, __) {
            assambleBridge.putStone(assambleBridge);
          };

          assambleBridge.onCollisionEndCallback = (other) {
            player.collisionDirection = Direction.idle;
            player.hasCollided = false;

            switchButton(showPrimary: true, pickAndPutButton: putItemButton);
          };

          await world.add(assambleBridge);
          break;
        case 'InstructionPutStone2':
          final assambleBridge = Bridge(
            instruction: Instruction.placementStone2,
            vertices: vertices,
          );

          assambleBridge.onCollisionCallback = (_, __) {
            assambleBridge.putStone(assambleBridge);
          };

          assambleBridge.onCollisionEndCallback = (other) {
            player.collisionDirection = Direction.idle;
            player.hasCollided = false;

            switchButton(showPrimary: true, pickAndPutButton: putItemButton);
          };

          await world.add(assambleBridge);
          break;
        case 'InstructionPutStone3':
          final assambleBridge = Bridge(
            instruction: Instruction.placementStone3,
            vertices: vertices,
          );

          assambleBridge.onCollisionCallback = (_, __) {
            assambleBridge.putStone(assambleBridge);
          };

          assambleBridge.onCollisionEndCallback = (other) {
            player.collisionDirection = Direction.idle;
            player.hasCollided = false;

            switchButton(showPrimary: true, pickAndPutButton: putItemButton);
          };

          await world.add(assambleBridge);
          break;
      }
    }
  }

  void switchButton(
      {required bool showPrimary, required PickAndPutButton pickAndPutButton}) {
    if (!showInstructionBuildingBridge) {
      pickAndPutButton.isVisible = !showPrimary;
      _swordButton.isVisible = showPrimary;
      _switchWeaponButton.isVisible = showPrimary;
      _selectedWeaponIndicator!.isVisible = showPrimary;

      pickAndPutButton.priority = !showPrimary ? 2 : 1;
      _swordButton.priority = showPrimary ? 2 : 1;
      _switchWeaponButton.priority = showPrimary ? 2 : 1;
      _selectedWeaponIndicator!.priority = showPrimary ? 2 : 1;
    }
  }
}
