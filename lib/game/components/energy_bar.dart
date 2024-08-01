import 'package:arion/game/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EnergyBar extends Component with HasGameReference<ArionGame> {
  late final RectangleComponent healthTextComponent;
  final Vector2? position;
  final double energy;
 
  EnergyBar({
    super.priority,
    this.position,
    required this.energy,
  });

  @override
  Future<void> onLoad() async {
    final backgroundHealthBar = RectangleComponent(
      size: Vector2(50, 16),
      anchor: Anchor.topRight,
      position: position,
      paint: Paint()..color = Colors.blue.shade50,
    );

    healthTextComponent = RectangleComponent(
      size: Vector2(energy < 50 ? energy : 50, 16),
      anchor: Anchor.topRight,
      position: position,
      paint: Paint()..color = Colors.blue,
    );
    await add(backgroundHealthBar);
    await add(healthTextComponent);
  }
}
