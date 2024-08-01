import 'package:arion/game/components/custom_button.dart';
import 'package:arion/game/utils/sound_effect.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({
    super.key,
    this.onPlayPressed,
  });

  static const id = 'MainMenu';

  final VoidCallback? onPlayPressed;

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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                'assets/images/ui/Arion Title.png',
                width: MediaQuery.of(context).size.width * 0.4,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 15),
              CustomButton(
                text: 'Start Game',
                onTap: () async {
                  await SoundEffect.play(SoundEffect.button);
                  onPlayPressed?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
