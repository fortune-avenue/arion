import 'package:arion/game/widgets/default_button.dart';
import 'package:flame/components.dart';

class PickAndPutButton extends DefaultButton {
  PickAndPutButton({required super.buttonPriority, super.buttonSprite});

  @override
  Future<void> onLoad() async {
    sprite = buttonSprite;
    this
      ..position = Vector2(544, 256)
      ..size = Vector2.all(75)
      ..anchor = Anchor.center
      ..isVisible = false;
  }
}
