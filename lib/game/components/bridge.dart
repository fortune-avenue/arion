import 'dart:async';

import 'package:arion/game/game.dart';
import 'package:arion/game/model/collectible_item.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:arion/game/utils/string_manipulation.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

enum Instruction {
  placementStone1,
  placementStone2,
  placementStone3,
}

class Bridge extends PositionComponent
    with
        HasGameReference<ArionGame>,
        HasAncestor<Gameplay>,
        CollisionCallbacks {
  Bridge({
    super.position,
    this.sizeComponent,
    this.vertices,
    this.instruction,
  });

  final Vector2? sizeComponent;
  final List<Vector2>? vertices;
  final Instruction? instruction;

  int arrangedStone = 0;
  late SpriteComponent bridge;

  bool get isAlive => true;

  @override
  Future<void> onLoad() async {
    await add(PolygonHitbox(
      vertices!,
      collisionType: CollisionType.passive,
      isSolid: true,
    ));
  }

  void putStone(PositionComponent other) {
    if (!ancestor.player.hasCollided) {
      ancestor.player.collisionDirection = ancestor.player.movementDirection;
      ancestor.player.hasCollided = true;
    }

    if (ancestor.player.bringStone && ancestor.player.stoneLeft <= 6) {
      ancestor.switchButton(
          showPrimary: false, pickAndPutButton: ancestor.putItemButton);

      ancestor.putItemButton.onTap = () async {
        ancestor.player.setSpeed = 80;
        ancestor.switchButton(
            showPrimary: true, pickAndPutButton: ancestor.putItemButton);

        final spawnBridge = ancestor.player.map.tileMap
            .getLayer<ObjectGroup>('Placement Bridge');
        final objects = spawnBridge?.objects;

        for (var object in objects!) {
          if (object.class_ == instruction?.name.capitalize()) {
            bridge = SpriteComponent(
              position: Vector2(object.x, object.y),
              anchor: Anchor.center,
              sprite:
                  Sprite(await game.images.load('map/collectible/bridge.png')),
            );

            await ancestor.world.add(bridge);

            int spaceAvailable = 6 - arrangedStone;

            // Move stones from stoneLeft to arrangedStone
            if (ancestor.player.stoneLeft <= spaceAvailable) {
              arrangedStone += ancestor.player.stoneLeft;
              ancestor.player.stoneLeft = 0;
            } else {
              arrangedStone = 6;
              ancestor.player.stoneLeft -= spaceAvailable;
            }

            ancestor.player.collectibleItems.update(
              'Stone',
              (value) => CollectibleItem(
                name: value.name,
                quantity: ancestor.player.stoneLeft,
                image: value.image,
              ),
            );

            if (arrangedStone == 6) {
              bridge.opacity = 1;
              other.removeFromParent();
            } else {
              bridge.opacity = arrangedStone / 6;
            }

            ancestor.player.bringStone = ancestor.player.stoneLeft != 0;
          }
        }
      };
    }
  }
}
