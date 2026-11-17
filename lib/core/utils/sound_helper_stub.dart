import 'package:flutter/foundation.dart';

class SoundPlatform {
  static bool get isSpeaking => false;
  static bool get isListening => false;
  static bool get isSpeechRecognitionSupported => false;

  static void speak(String text, {VoidCallback? onDone, VoidCallback? onError}) {
    onDone?.call();
  }

  static void stopSpeaking() {}

  static void playChime({bool isAlert = false}) {}

  static void startListening({
    required Function(String text) onResult,
    required VoidCallback onDone,
    VoidCallback? onError,
  }) {
    onError?.call();
  }

  static void stopListening() {}

  static void exportCsvFile(String filename, String content) {}
}
