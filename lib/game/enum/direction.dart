import 'package:flame/components.dart';

// 8 direction + idle
enum Direction {
  up,
  upLeft,
  upRight,
  right,
  down,
  downRight,
  downLeft,
  left,
  idle,
}

// mapping the joystick direction to direction
Direction toDirection(JoystickComponent joystick) {
  switch (joystick.direction) {
    case JoystickDirection.up:
      return Direction.up;
    case JoystickDirection.upLeft:
      return Direction.upLeft;
    case JoystickDirection.upRight:
      return Direction.upRight;
    case JoystickDirection.right:
      return Direction.right;
    case JoystickDirection.down:
      return Direction.down;
    case JoystickDirection.downRight:
      return Direction.downRight;
    case JoystickDirection.downLeft:
      return Direction.downLeft;
    case JoystickDirection.left:
      return Direction.left;
    case JoystickDirection.idle:
      return Direction.idle;
  }
}
