// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter/services.dart';

/// Plays a crisp two-tone chime via Web Audio API with SystemSound fallback.
Future<void> playOnlineBookingBeep() async {
  try {
    final audioCtxCtor = js.context['AudioContext'] ?? js.context['webkitAudioContext'];
    if (audioCtxCtor != null) {
      js.context.callMethod('eval', [
        '''
        (function() {
          try {
            var Ctx = window.AudioContext || window.webkitAudioContext;
            if (!Ctx) return;
            window.__bisheAudioCtx = window.__bisheAudioCtx || new Ctx();
            var ctx = window.__bisheAudioCtx;
            if (ctx.state === 'suspended') { ctx.resume(); }
            var now = ctx.currentTime;
            [880, 1174.66].forEach(function(freq, i) {
              var osc = ctx.createOscillator();
              var gain = ctx.createGain();
              osc.type = 'sine';
              osc.frequency.setValueAtTime(freq, now + i * 0.14);
              gain.gain.setValueAtTime(0.18, now + i * 0.14);
              gain.gain.exponentialRampToValueAtTime(0.001, now + i * 0.14 + 0.22);
              osc.connect(gain);
              gain.connect(ctx.destination);
              osc.start(now + i * 0.14);
              osc.stop(now + i * 0.14 + 0.23);
            });
          } catch (e) {}
        })();
        '''
      ]);
      return;
    }
  } catch (_) {}
  try {
    await SystemSound.play(SystemSoundType.alert);
  } catch (_) {}
}
