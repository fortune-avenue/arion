import 'dart:async';

import 'package:arion/game/components/dialog_overlay.dart';
import 'package:arion/game/enum/dialog.dart';
import 'package:arion/game/model/player_data.dart';
import 'package:arion/game/model/zombie_data.dart';
import 'package:arion/game/routes/game_finished_menu.dart';
import 'package:arion/game/routes/game_over_menu.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:arion/game/routes/main_menu.dart';
import 'package:arion/game/routes/pause_game_menu.dart';
import 'package:arion/game/routes/tutorial_menu.dart';
import 'package:arion/game/utils/sound_effect.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart' hide Route, OverlayRoute;

class ArionGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late final _routes = <String, Route>{
    MainMenu.id: OverlayRoute((context, game) {
      return MainMenu(
        onPlayPressed: () => _routeById(TutorialMenu.id),
      );
    }),
    TutorialMenu.id: OverlayRoute((context, game) {
      return TutorialMenu(
        onPlayTap: _startGameplay,
        onBackPressed: popRoute,
        isJoystickNotifier: isJoystickNotifier,
        onControlSwitchChanged: _onControlSwitchChanged,
      );
    }),
    PauseGameMenu.id: OverlayRoute((context, game) {
      return PauseGameMenu(
        onResumePressed: _resumeGame,
        onRestartPressed: _restartChapter,
        onExitPressed: _exitToMainMenu,
        isJoystickNotifier: isJoystickNotifier,
        onControlSwitchChanged: _onControlSwitchChanged,
      );
    }),
    GameOverMenu.id: OverlayRoute((context, game) {
      return GameOverMenu(
        onRetryPressed: _restartChapter,
        onExitPressed: _exitToMainMenu,
      );
    }),
    GameFinishedMenu.id: OverlayRoute((context, game) {
      return GameFinishedMenu(
        game: game as ArionGame,
        onRetryPressed: _restartChapter,
        onExitPressed: _exitToMainMenu,
      );
    }),
  };

  late final _router = RouterComponent(
    initialRoute: MainMenu.id,
    routes: _routes,
  );

  PlayerData playerData = PlayerData();
  ZombieData zombieData = ZombieData();
  ValueNotifier<bool> isJoystickNotifier = ValueNotifier(true);
  ValueNotifier<bool> isFinishBuildBrige = ValueNotifier(false);

  @override
  Future<void> onLoad() async {
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();

    await add(_router);
    return super.onLoad();
  }

  void _routeById(String id) {
    _router.pushNamed(id);
  }

  void popRoute() {
    _router.pop();
  }

  void _startGameplay() {
    _router.pop();
    _router.pushReplacement(
      Route(
        () => Gameplay(
          onPausePressed: _pauseGame,
          key: ComponentKey.named(Gameplay.id),
        ),
      ),
      name: Gameplay.id,
    );
  }

  void _onControlSwitchChanged(bool isJoystick) {
    isJoystickNotifier.value = isJoystick;
  }

  Future<void> _pauseGame() async {
    await SoundEffect.play(SoundEffect.button);
    _router.pushNamed(PauseGameMenu.id);
    pauseEngine();
  }

  void _dismissDialogBox() {
    _router.pop();
    resumeEngine();
  }

  Future<void> showDialogBox({
    required DialogBox message,
    VoidCallback? onPressed,
    bool isPauseEngine = true,
  }) async {
    _router.pushRoute(
      OverlayRoute((context, game) {
        return DialogOverlay(
          dialog: message,
          onPressed: onPressed ?? _dismissDialogBox,
        );
      }),
      name: DialogOverlay.id,
    );
    if (isPauseEngine) pauseEngine();
  }

  void _restartChapter() async {
    await SoundEffect.play(SoundEffect.button);

    final gameplay = findByKeyName<Gameplay>(Gameplay.id);

    if (gameplay != null) {
      playerData = PlayerData();
      zombieData = ZombieData();
      _startGameplay();
      resumeEngine();
    }
  }

  void _exitToMainMenu() async {
    _resumeGame();
    playerData.health.value = 400;
    _router.pushReplacementNamed(MainMenu.id);
  }

  void _resumeGame() async {
    _router.pop();
    resumeEngine();
  }

  void onGameOver() {
    pauseEngine();
    _router.pushNamed(GameOverMenu.id);
  }

  void onGameFinished() {
    pauseEngine();
    _router.pushNamed(GameFinishedMenu.id);
  }
}
