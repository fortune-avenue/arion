import 'package:arion/game/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HealthBar extends Component with HasGameReference<ArionGame> {
  late final RectangleComponent healthTextComponent;
  final Vector2? position;

  HealthBar({
    super.priority,
    this.position,
  });

  @override
  Future<void> onLoad() async {
    final backgroundHealthBar = RectangleComponent(
      size: Vector2(100, 16),
      anchor: Anchor.topRight,
      position: position,
      paint: Paint()..color = Colors.green.shade50,
    );
    healthTextComponent = RectangleComponent(
      size: Vector2(100, 16),
      anchor: Anchor.topRight,
      position: position,
      paint: Paint()..color = Colors.green,
    );
    await add(backgroundHealthBar);
    await add(healthTextComponent);
    game.playerData.health.addListener(onHealthChange);
  }

  @override
  void onRemove() {
    removeListener();
    super.onRemove();
  }

  void onHealthChange() {
    final health = game.playerData.health.value;

    double healthDecresing = health / 4;
    healthTextComponent.size =
        Vector2(healthDecresing <= 0 ? 0 : health / 4, 16);

    if (healthDecresing <= 0) {
      removeListener();
      Future.delayed(const Duration(milliseconds: 500), () {
        game.onGameOver();
      });
    }
  }

  void removeListener() {
    game.playerData.health.removeListener(onHealthChange);
  }
}
