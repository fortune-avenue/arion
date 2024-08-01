import 'package:arion/game/actors/enemies/zombie.dart';
import 'package:arion/game/game.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:flame/components.dart';

class ZombieSpawner extends Component
    with HasGameReference<ArionGame>, HasAncestor<Gameplay> {
  final World world;
  final Vector2 playerPosition;
  final Vector2 spawnPoint;
  final double spawnInterval;
  final bool isAfterBridge;

  double timeSinceLastSpawn = 0.0;

  bool isStartSpawning = false;

  ZombieSpawner(
    this.world,
    this.playerPosition,
    this.spawnPoint,
    this.spawnInterval,
    this.isAfterBridge,
  );

  @override
  void update(double dt) {
    super.update(dt);

    if (ancestor.isFinishBuildingBridge && !isAfterBridge) {
      isStartSpawning = false;
    }

    if (isZombieSpawnerInRadius(playerPosition, 300) &&
        isStartSpawning == false) {
      isStartSpawning = true;
      spawnZombie();
    }

    if (isStartSpawning) {
      timeSinceLastSpawn += dt;

      if (timeSinceLastSpawn >= spawnInterval) {
        spawnZombie();
        timeSinceLastSpawn = 0.0;
      }
    }
  }

  void spawnZombie() {
    if (game.zombieData.canSpawnZombie) {
      final zombieTemp = Zombie(playerPosition: playerPosition);
      zombieTemp.position.setFrom(spawnPoint);
      world.add(zombieTemp);
      game.zombieData.totalZombie.value++;
    }
  }

  bool isZombieSpawnerInRadius(Vector2 playerPosition, double radius) {
    double distance = playerPosition.distanceTo(spawnPoint);
    return distance <= radius;
  }
}
