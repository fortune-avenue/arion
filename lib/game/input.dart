import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class Input extends Component with KeyboardHandler, HasGameReference {
  Input({Map<LogicalKeyboardKey, VoidCallback>? keyCallbacks})
      : _keyCallbacks = keyCallbacks ?? <LogicalKeyboardKey, VoidCallback>{};

  final Map<LogicalKeyboardKey, VoidCallback> _keyCallbacks;

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (game.paused) return super.onKeyEvent(event, keysPressed);

    if (event is RawKeyDownEvent && event.repeat == false) {
      for (final entry in _keyCallbacks.entries) {
        if (entry.key == event.logicalKey) {
          entry.value.call();
        }
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }
}

class InputRepeat extends Component with KeyboardHandler, HasGameReference {
  InputRepeat(
      {Map<LogicalKeyboardKey, VoidCallback>? keyDownCallbacks,
      Map<LogicalKeyboardKey, VoidCallback>? keyUpCallbacks})
      : _keyDownCallbacks =
            keyDownCallbacks ?? <LogicalKeyboardKey, VoidCallback>{},
        _keyUpCallbacks =
            keyUpCallbacks ?? <LogicalKeyboardKey, VoidCallback>{};

  final Map<LogicalKeyboardKey, VoidCallback> _keyDownCallbacks;
  final Map<LogicalKeyboardKey, VoidCallback> _keyUpCallbacks;

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (game.paused) return super.onKeyEvent(event, keysPressed);

    if (event is RawKeyDownEvent) {
      for (final entry in _keyDownCallbacks.entries) {
        if (entry.key == event.logicalKey) {
          entry.value.call();
        }
      }
    } else if (event is RawKeyUpEvent) {
      for (final entry in _keyUpCallbacks.entries) {
        if (entry.key == event.logicalKey) {
          entry.value.call();
        }
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
