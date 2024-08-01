import 'package:flame_audio/flame_audio.dart';

import 'sound_effect.dart';

class BackSound {
  static AudioPlayer? _backSoundAudioPlayer;

  static Future initializeBackSound() async {
    if (_backSoundAudioPlayer?.state == PlayerState.playing) return;
    _backSoundAudioPlayer = await SoundEffect.loop(
      SoundEffect.backSound,
      volume: 0.05,
    );
  }

  static Future? resume() => _backSoundAudioPlayer?.resume();

  static Future? pause() => _backSoundAudioPlayer?.pause();

  static Future? stop() => _backSoundAudioPlayer?.stop();
}
