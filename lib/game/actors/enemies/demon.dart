import 'dart:async';

import 'package:arion/game/actors/enemies/enemy.dart';
import 'package:arion/game/actors/enemies/mixins/skills.dart';
import 'package:arion/game/enum/dialog.dart';
import 'package:arion/game/weapons/poison.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame_tiled/flame_tiled.dart';

class Demon extends Enemy with Skills {
  Demon({super.position}) : super(size: Vector2.all(64.0));

  bool isShooting = true;

  double speed = 15;
  late Vector2 directionTarget;
  double stopDistance = 0.1;

  late Vector2 randomPath;
  double? distanceToPoint;

  late Poison poison;

  bool isShowDialogKillDemon = true;

  @override
  Future<void> onLoad() async {
    initMovement();

    Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      randomPath = Vector2(position.x + getTargetDistance(250),
          position.y + getTargetDistance(250));
    });

    setIdleImage(game.images.load('demon/Idle.png'));
    setWalkImage(game.images.load('demon/Walk.png'));
    setDeathImage(game.images.load('demon/Death.png'));
    setAttackImage(game.images.load('demon/Attack.png'));
    setBurstImage(game.images.load('demon/Burst.png'));

    attackSpeed = 0.18;

    super.onLoad();
  }

  @override
  void update(double dt) {
    timeSinceLastAttack += dt;

    // set the layer
    priorityLayer();

    movement(dt);

    if (isZombieInRadius(ancestor.player.position, 150) &&
        isShowDialogKillDemon) {
      ancestor.player.resetMovement();
      game.showDialogBox(
        message: DialogBox.killDemon,
        onPressed: () async {
          initMovement(move: 150);
          game.popRoute();
          game.resumeEngine();
          isShowDialogKillDemon = false;
        },
      );
    }

    super.update(dt);
  }

  void initMovement({double? move}) {
    randomPath = Vector2(position.x + (move ?? 0), position.y);
    distanceToPoint = randomPath.distanceTo(position);
  }

  bool isZombieInRadius(Vector2 playerPosition, double radius) {
    double distance = playerPosition.distanceTo(position);
    return distance <= radius;
  }

  void movement(double dt) {
    speed = 15;
    double distanceToPlayer = ancestor.player.position.distanceTo(position);

    if ((distanceToPoint! > stopDistance) && distanceToPlayer > 60 && isAlive) {
      randomMovement(dt, speed, randomPath);
    } else if (distanceToPlayer.toInt() <= 60 && isAlive) {
      intersectWithPlayer(dt, distanceToPlayer);
    } else if (!isAlive) {
      death();
    }
  }

  Future<void> burst({double? attackPoint}) async {
    if (!game.playerData.isAlive) return;

    poison = Poison(direction: direction);
    poison.attackPoint = attackPoint!;
    if (!canAttack(poison.attackSpeed)) return;

    isBursting = true;
    await add(poison);
    timeSinceLastAttack = 0.0;
  }

  void intersectWithPlayer(double dt, double distanceToPlayer) {
    speed = 45;
    randomPath = ancestor.player.position;
    if (distanceToPlayer > 25 && distanceToPlayer.toInt() <= 50) {
      if (!isBursting && game.playerData.isAlive) {
        isAttacking = false;
        burst(attackPoint: 50.0);
      }
    } else if (distanceToPlayer.toInt() <= 25) {
      if (!isAttacking && game.playerData.isAlive) {
        isBursting = false;
        setAnimationToIdle();
        scratch(attackPoint: 30.0);
      }
    } else {
      isAttacking = false;
      isBursting = false;
      randomMovement(dt, speed, randomPath);
    }
  }

  void death() {
    isAttacking = false;
    isBursting = false;
    deathAnimation();

    final caveData = ancestor.map.tileMap.getLayer<TileLayer>('stoneblock');
    if (caveData?.class_ == 'Stoneblock') caveData?.visible = false;
    ancestor.hitCaveObstacle.removeFromParent();
  }

  @override
  void attacked(double attackPoint) {
    super.attacked(attackPoint);
    if (!isAlive) {
      ancestor.player.footStepAudioPlayer.pause();
      game.showDialogBox(message: DialogBox.bossDefeated);
    }
  }
}
