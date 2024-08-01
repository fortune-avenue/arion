import 'package:arion/game/components/custom_button.dart';
import 'package:arion/game/utils/app_theme.dart';
import 'package:flutter/material.dart';

class PauseGameMenu extends StatefulWidget {
  const PauseGameMenu({
    super.key,
    this.onResumePressed,
    this.onRestartPressed,
    this.onExitPressed,
    required this.isJoystickNotifier,
    this.onControlSwitchChanged,
  });

  static const id = 'PauseMenu';

  final VoidCallback? onResumePressed;
  final VoidCallback? onRestartPressed;
  final VoidCallback? onExitPressed;
  final Function(bool isJoystick)? onControlSwitchChanged;
  final ValueNotifier<bool> isJoystickNotifier;

  @override
  State<PauseGameMenu> createState() => _PauseGameMenuState();
}

class _PauseGameMenuState extends State<PauseGameMenu> {
  late bool isJoystick;

  @override
  void initState() {
    super.initState();
    isJoystick = widget.isJoystickNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.84,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/ui/Game Over Game Complete and Pause Board.png',
                  ),
                  fit: BoxFit.fitHeight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'PAUSE',
                    style: AppTheme.headline1,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Use Joystick?',
                        style: AppTheme.headline3.white,
                      ),
                      const SizedBox(width: 12),
                      Checkbox(
                        value: isJoystick,
                        onChanged: (value) {
                          if (value == null) return;
                          widget.onControlSwitchChanged?.call(value);
                          setState(() {
                            isJoystick = value;
                          });
                        },
                        fillColor: MaterialStatePropertyAll(Colors.red[900]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Use Keyboard?',
                        style: AppTheme.headline3.white,
                      ),
                      const SizedBox(width: 12),
                      Checkbox(
                        value: !isJoystick,
                        onChanged: (value) {
                          if (value == null) return;
                          widget.onControlSwitchChanged?.call(!isJoystick);
                          setState(() {
                            isJoystick = !isJoystick;
                          });
                        },
                        fillColor: MaterialStatePropertyAll(Colors.red[900]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  CustomButton(
                    text: 'Resume',
                    onTap: () {
                      widget.onResumePressed?.call();
                    },
                  ),
                  const SizedBox(height: 5),
                  CustomButton(
                    text: 'Restart',
                    onTap: () {
                      widget.onRestartPressed?.call();
                    },
                  ),
                  const SizedBox(height: 5),
                  CustomButton(
                    text: 'Exit',
                    onTap: () {
                      widget.onExitPressed?.call();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
