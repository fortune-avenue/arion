import 'package:arion/game/actors/player.dart';
import 'package:arion/game/enum/direction.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Obstacle {
  static bool hasCollided = false;

  static final tree1 = Vector2(4, 295);

  static Future defineObstacle({
    required TiledComponent map,
    required World world,
    required Player player,
    Function? onGameFinished,
  }) async {
    final obstacleGroup = map.tileMap.getLayer<ObjectGroup>('obstacle');
    final objects = obstacleGroup?.objects;

    if (objects != null) {
      for (final object in objects) {
        switch (object.class_) {
          case 'river' || 'cave':
            final vertices = <Vector2>[];
            for (final point in object.polygon) {
              vertices.add(Vector2(point.x + object.x, point.y + object.y));
            }

            final hitbox = PolygonHitbox(
              vertices,
              collisionType: CollisionType.passive,
              isSolid: true,
            );

            hitbox.onCollisionCallback = (_, other) {
              if (!hasCollided) {
                player.collisionDirection = player.movementDirection;
                hasCollided = true;
              }
            };

            hitbox.onCollisionEndCallback = (other) {
              player.collisionDirection = Direction.idle;
              hasCollided = false;
            };

            await map.add(hitbox);
            break;
          case 'tree':
            if (object.name.isNotEmpty) {
              final propsImage = await Flame.images.load(
                'map/EPIC RPG World Pack - Ancient Ruins V 1.9.1/Props/Atlas-Props.png',
              );
              final spriteComponent = SpriteComponent(
                sprite: _getTreeSpriteByName(
                  name: object.name,
                  propsImage: propsImage,
                ),
                position: Vector2(object.x, object.y + 16),
                size: Vector2(125, 171),
                priority: 10,
                anchor: Anchor.bottomCenter,
              );
              world.add(spriteComponent);
            }
            await _addRectangleHitboxObstacle(
              object: object,
              player: player,
              world: world,
            );
            break;
          case 'stone':
            if (object.name == 'gate') {
              final propsImage = await Flame.images.load(
                'map/EPIC RPG World Pack - Ancient Ruins V 1.9.1/Props/Atlas-Props 2.png',
              );
              final sprite = Sprite(
                propsImage,
                srcPosition: Vector2(390, 1305),
                srcSize: Vector2(129, 98),
              );
              final spriteComponent = SpriteComponent(
                sprite: sprite,
                position: Vector2(
                  object.x - 12,
                  object.y + 8,
                ),
                size: Vector2(129, 98),
                priority: 10,
                anchor: Anchor.bottomLeft,
              );
              world.add(spriteComponent);
            }
            await _addRectangleHitboxObstacle(
              object: object,
              player: player,
              world: world,
            );
            break;
          case 'CaveFinish':
            final vertices = <Vector2>[];
            for (final point in object.polygon) {
              vertices.add(Vector2(point.x + object.x, point.y + object.y));
            }
            final hitbox = PolygonHitbox(
              vertices,
              collisionType: CollisionType.passive,
              isSolid: true,
            );

            hitbox.onCollisionCallback = (_, other) {
              onGameFinished?.call();
            };

            await world.add(hitbox);

            break;
        }
      }
    }
  }

  static Sprite _getTreeSpriteByName({
    required String name,
    required Image propsImage,
  }) {
    switch (name) {
      case 'tree_1':
        return Sprite(
          propsImage,
          srcPosition: Vector2(5, 683),
          srcSize: Vector2(102, 136),
        );
      case 'tree_2':
        return Sprite(
          propsImage,
          srcPosition: Vector2(4, 295),
          srcSize: Vector2(125, 171),
        );
      case 'tree_3':
        return Sprite(
          propsImage,
          srcPosition: Vector2(265, 289),
          srcSize: Vector2(103, 170),
        );
      case 'tree_4':
        return Sprite(
          propsImage,
          srcPosition: Vector2(3, 487),
          srcSize: Vector2(126, 171),
        );
      case 'tree_5':
        return Sprite(
          propsImage,
          srcPosition: Vector2(265, 481),
          srcSize: Vector2(103, 170),
        );
      case 'tree_6':
        return Sprite(
          propsImage,
          srcPosition: Vector2(136, 482),
          srcSize: Vector2(120, 173),
        );
      case 'tree_7':
        return Sprite(
          propsImage,
          srcPosition: Vector2(136, 482),
          srcSize: Vector2(120, 173),
        );
      case 'tree_8':
        return Sprite(
          propsImage,
          srcPosition: Vector2(387, 487),
          srcSize: Vector2(126, 171),
        );
      case 'tree_9':
        return Sprite(
          propsImage,
          srcPosition: Vector2(357, 683),
          srcSize: Vector2(102, 136),
        );
      case 'tree_10':
        return Sprite(
          propsImage,
          srcPosition: Vector2(709, 680),
          srcSize: Vector2(102, 136),
        );
      case 'tree_11':
        return Sprite(
          propsImage,
          srcPosition: Vector2(931, 690),
          srcSize: Vector2(112, 129),
        );
      case 'tree_12':
        return Sprite(
          propsImage,
          srcPosition: Vector2(836, 704),
          srcSize: Vector2(85, 116),
        );
      case 'tree_13':
        return Sprite(
          propsImage,
          srcPosition: Vector2(520, 290),
          srcSize: Vector2(120, 173),
        );
      case 'tree_14':
        return Sprite(
          propsImage,
          srcPosition: Vector2(1199, 869),
          srcSize: Vector2(62, 111),
        );
      case 'tree_15':
        return Sprite(
          propsImage,
          srcPosition: Vector2(1300, 696),
          srcSize: Vector2(83, 123),
        );
      case 'tree_16':
        return Sprite(
          propsImage,
          srcPosition: Vector2(1074, 854),
          srcSize: Vector2(74, 125),
        );
      case 'tree_17':
        return Sprite(
          propsImage,
          srcPosition: Vector2(1199, 709),
          srcSize: Vector2(62, 111),
        );
      case 'tree_18':
        return Sprite(
          propsImage,
          srcPosition: Vector2(1300, 857),
          srcSize: Vector2(83, 123),
        );
      case 'tree_19':
        return Sprite(
          propsImage,
          srcPosition: Vector2(1074, 694),
          srcSize: Vector2(74, 125),
        );
      default:
        return Sprite(
          propsImage,
          srcPosition: Vector2(4, 295),
          srcSize: Vector2(125, 171),
        );
    }
  }

  static Future _addRectangleHitboxObstacle({
    required TiledObject object,
    required World world,
    required Player player,
  }) async {
    final hitbox = RectangleHitbox(
      position: Vector2(object.x, object.y),
      collisionType: CollisionType.passive,
      isSolid: true,
      size: Vector2.all(16),
      anchor: Anchor.center,
    );

    hitbox.onCollisionCallback = (_, other) {
      if (!hasCollided) {
        player.collisionDirection = player.movementDirection;
        hasCollided = true;
      }
    };

    hitbox.onCollisionEndCallback = (other) {
      player.collisionDirection = Direction.idle;
      hasCollided = false;
    };

    await world.add(hitbox);
  }
}
