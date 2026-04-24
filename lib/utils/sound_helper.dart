import 'package:audioplayers/audioplayers.dart';

class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playCountdownSound() async {
    try {
      await _player.play(AssetSource('sounds/beep_countdown.wav'));
    } catch (_) {
      // Sound playback failed silently
    }
  }

  static Future<void> playStartSound() async {
    try {
      await _player.play(AssetSource('sounds/beep_start.wav'));
    } catch (_) {
      // Sound playback failed silently
    }
  }
}
