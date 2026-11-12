import 'package:flutter/services.dart';

/// Plays a notification alert beep on non-web platforms.
Future<void> playOnlineBookingBeep() async {
  try {
    await SystemSound.play(SystemSoundType.alert);
  } catch (_) {}
}
