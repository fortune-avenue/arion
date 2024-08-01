import 'package:arion/game/game.dart';
import 'package:arion/game/model/collectible_item.dart';
import 'package:arion/game/utils/app_theme.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CollectibleItemList extends Component with HasGameReference<ArionGame> {
  final Vector2 position;
  final Map<String, CollectibleItem> collectibleItems;

  CollectibleItemList({
    required this.position,
    required this.collectibleItems,
  });

  @override
  Future<void> onLoad() async {
    int index = 0;

    for (CollectibleItem collectibleItem in collectibleItems.values) {
      if (collectibleItem.quantity <= 0) return;
      final image =
          SpriteComponent(sprite: await game.loadSprite(collectibleItem.image))
            ..position = Vector2(position.x - (index * 24) - 8, position.y)
            ..size = Vector2.all(32)
            ..anchor = Anchor.center;

      final background = RectangleComponent(
        size: Vector2.all(16),
        anchor: Anchor.center,
        position: Vector2(position.x - (index * 24) - 8, position.y),
        paint: Paint()..color = Colors.blue.shade50,
      );

      final text = TextComponent(text: 'x${collectibleItem.quantity}')
        ..position = Vector2(position.x - (index * 24) - 8, position.y + 16)
        ..textRenderer = TextPaint(
          style: AppTheme.subText,
        )
        ..anchor = Anchor.center;

      await add(background);
      await add(image);
      await add(text);
      index++;
    }
  }
}
