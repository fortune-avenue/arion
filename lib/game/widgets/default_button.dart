import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

class DefaultButton extends SpriteComponent
    with HasGameReference, TapCallbacks, HasVisibility {
  VoidCallback? onTap;
  Sprite? buttonSprite;
  int buttonPriority;
  DefaultButton({
    this.onTap,
    this.buttonSprite,
    required this.buttonPriority,
  });
  @override
  Future<void> onLoad() async {
    sprite = buttonSprite;
    priority = buttonPriority;
    super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap?.call();
    super.onTapDown(event);
  }
}
