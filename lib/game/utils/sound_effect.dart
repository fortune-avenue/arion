import 'package:flame_audio/flame_audio.dart';

class SoundEffect {
  static const sword = 'sword.wav';
  static const crossbow = 'crossbow.wav';
  static const button = 'button.mp3';
  static const zombieAttack = 'zombie_attack.wav';
  static const runningText = 'running-text.mp3';
  static const playerWalk = 'player-walk.wav';
  static const backSound = 'back-sound.wav';

  static Future play(
    String path, {
    double volume = 1,
  }) async {
    await FlameAudio.play(
      path,
      volume: volume,
    );
  }

  static Future<AudioPlayer> loop(
    String path, {
    double volume = 1,
  }) async {
    final audio = await FlameAudio.loop(
      path,
      volume: volume,
    );
    return audio;
  }


}
