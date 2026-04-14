import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playCountdownSound() async {
    try {
      await _player.play(AssetSource('sounds/beep_countdown.wav'));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing countdown sound: $e');
      }
    }
  }

  static Future<void> playStartSound() async {
    try {
      await _player.play(AssetSource('sounds/beep_start.wav'));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing start sound: $e');
      }
    }
  }
}
