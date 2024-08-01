import 'package:arion/game/components/custom_button.dart';
import 'package:arion/game/utils/app_theme.dart';
import 'package:arion/game/utils/back_sound.dart';
import 'package:arion/game/utils/sound_effect.dart';
import 'package:flutter/material.dart';

class TutorialMenu extends StatefulWidget {
  const TutorialMenu({
    super.key,
    this.onPlayTap,
    this.onBackPressed,
    this.onControlSwitchChanged,
    required this.isJoystickNotifier,
  });

  static const id = 'GameChapterMenu';

  final VoidCallback? onPlayTap;
  final VoidCallback? onBackPressed;
  final Function(bool isJoystick)? onControlSwitchChanged;
  final ValueNotifier<bool> isJoystickNotifier;

  @override
  State<TutorialMenu> createState() => _TutorialMenuState();
}

class _TutorialMenuState extends State<TutorialMenu> {
  late bool isJoystick;

  @override
  void initState() {
    super.initState();
    isJoystick = widget.isJoystickNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ui/Title Screen.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'TUTORIAL',
                style: AppTheme.headline1,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
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
                      children: [
                        const SizedBox(height: 48),
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
                              fillColor:
                                  MaterialStatePropertyAll(Colors.red[900]),
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
                                widget.onControlSwitchChanged
                                    ?.call(!isJoystick);
                                setState(() {
                                  isJoystick = !isJoystick;
                                });
                              },
                              fillColor:
                                  MaterialStatePropertyAll(Colors.red[900]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Expanded(
                          child: Image.asset(
                            isJoystick
                                ? 'assets/images/ui/joystick_tutorial.png'
                                : 'assets/images/ui/keyboard_tutorial.png',
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomButton(
                              text: 'Back',
                              onTap: () async {
                                _onBackPressed();
                              },
                            ),
                            const SizedBox(width: 16),
                            CustomButton(
                              text: 'Start Game',
                              onTap: () async {
                                await SoundEffect.play(SoundEffect.button);
                                await BackSound.initializeBackSound();
                                widget.onPlayTap?.call();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBackPressed() async {
    await SoundEffect.play(SoundEffect.button);
    widget.onBackPressed?.call();
  }
}
