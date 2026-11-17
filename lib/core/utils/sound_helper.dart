import 'package:flutter/foundation.dart';
import 'sound_helper_stub.dart'
    if (dart.library.html) 'sound_helper_web.dart';

class SoundHelper {
  SoundHelper._();

  static bool get isSpeaking => SoundPlatform.isSpeaking;
  static bool get isListening => SoundPlatform.isListening;
  static bool get isSpeechRecognitionSupported => SoundPlatform.isSpeechRecognitionSupported;

  static void speak(String text, {VoidCallback? onDone, VoidCallback? onError}) {
    SoundPlatform.speak(text, onDone: onDone, onError: onError);
  }

  static void stopSpeaking() {
    SoundPlatform.stopSpeaking();
  }

  static void playChime({bool isAlert = false}) {
    SoundPlatform.playChime(isAlert: isAlert);
  }

  static void startListening({
    required Function(String text) onResult,
    required VoidCallback onDone,
    VoidCallback? onError,
  }) {
    SoundPlatform.startListening(
      onResult: onResult,
      onDone: onDone,
      onError: onError,
    );
  }

  static void stopListening() {
    SoundPlatform.stopListening();
  }

  static void exportCsvFile(String filename, String content) {
    SoundPlatform.exportCsvFile(filename, content);
  }
}
