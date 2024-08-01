import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:arion/game/enum/dialog.dart';
import 'package:arion/game/utils/app_theme.dart';
import 'package:arion/game/utils/sound_effect.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class DialogOverlay extends StatefulWidget {
  const DialogOverlay({
    super.key,
    this.dialog,
    this.onPressed,
  });

  static const id = 'DialogOverlay';

  final DialogBox? dialog;
  final VoidCallback? onPressed;

  @override
  State<DialogOverlay> createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<DialogOverlay> {
  late AudioPlayer _runningTextAudioPlayer;

  @override
  void initState() {
    super.initState();
    SoundEffect.loop(SoundEffect.runningText).then((value) {
      _runningTextAudioPlayer = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * .5,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AspectRatio(
                aspectRatio: 100 / 32,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage('assets/images/ui/Instruction Board.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(52),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          contentDialog(widget.dialog ?? DialogBox.opening),
                          textStyle: AppTheme.headline2,
                          speed: const Duration(milliseconds: 40),
                        ),
                      ],
                      isRepeatingAnimation: false,
                      onFinished: () async {
                        await _runningTextAudioPlayer.stop();
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -20,
                right: -20,
                child: GestureDetector(
                  onTap: () async {
                    await _runningTextAudioPlayer.stop();
                    await SoundEffect.play(SoundEffect.button);
                    widget.onPressed?.call();
                  },
                  child: Image.asset(
                    'assets/images/ui/close_button.png',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
