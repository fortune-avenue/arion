import 'package:arion/game/game.dart';
import 'package:arion/game/utils/sound_effect.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // cache audio
  await FlameAudio.audioCache.load(SoundEffect.button);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arion Game',
      home: GameWidget.controlled(
        gameFactory: ArionGame.new,
      ),
    );
  }
}
